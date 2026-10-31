# 1. Root + bloquear o monitoramento

Ganhar root na TV e cortar o monitoramento: ACR desligado, telemetria bloqueada e os
domínios que a TV chama sozinha jogados pro buraco.

> ⚠️ Leia o [aviso do repositório](../README.md) antes.
> Só na sua própria TV, por sua conta e risco, pode anular a garantia.
> **Não atualize o firmware** em momento nenhum — uma atualização fecha a falha e remove
> o root.

**Referência deste guia:** LG **UK6540PSB**, **webOS 4.x**, firmware **05.50.70** (build
de abr/2025). Modelo/versão diferentes: confira a sua em
[cani.rootmy.tv](https://cani.rootmy.tv/) antes de começar.

## A falha (com precisão, sem drama)

O root sai de uma falha de **command injection** no serviço do webOS que lê os
**metadados de áudio** (as "informações de música") e roda como **root**. É da mesma
família da **CVE-2023-6319** (Bitdefender, divulgada em 2024; a LG corrigiu em
22/03/2024).

Detalhe honesto e importante: o firmware desta TV é de **abril/2025**, ou seja,
_posterior_ ao patch de 2024, e mesmo assim rooteou com o **DejaVuln**. Logo, **não é
exatamente a CVE-2023-6319 já corrigida** — é uma **variante no mesmo componente** que
continuou explorável ("déjà vu"). Antes de afirmar que "as versões novas estão seguras",
confira a sua em [cani.rootmy.tv](https://cani.rootmy.tv/) e no
[guia oficial do DejaVuln](https://www.webosbrew.org/guides/rooting/dejavuln/).

Este repo **não traz o exploit nem ensina a montá-lo**. Você usa a ferramenta pública,
pronta e auditada pela comunidade.

## 0. Confirmar que a sua TV é rootável

1. Na TV: **Configurações → Geral → Sobre esta TV** e anote a **"Versão do webOS TV"**
   (não a "Versão do software").
2. No PC, abra [cani.rootmy.tv](https://cani.rootmy.tv/), selecione o seu modelo/versão e
   confirme que aparece como rootável via **DejaVuln**.

## 1. Rootear (você executa, pelo pendrive)

Siga o **guia oficial**, que é mantido e atualizado:
<https://www.webosbrew.org/guides/rooting/dejavuln/>. Resumo do que ele pede:

1. Um pendrive em **FAT32** ou **NTFS**, uma só partição.
2. Baixe **somente** o release oficial do
   [dejavuln-autoroot](https://github.com/throwaway96/dejavuln-autoroot/releases). Não use
   mirrors nem forks. (Vale auditar o conteúdo antes — foi o que eu fiz.)
3. Extraia o `.zip` na **raiz** do pendrive e crie um arquivo vazio `autoroot.telnet` na
   raiz (liga um shell de emergência durante o processo).
4. Na TV: desinstale o app **"Developer Mode"** se tiver, e **desligue o Quick Start+**
   (Configurações → Geral) — se o Homebrew não aparecer depois, essa é a causa comum.
5. Abra o app de **Música/Media Player**, ache no pendrive o arquivo de nome gigante e
   **tente tocá-lo**. Vai dar erro de reprodução (é esperado) e, em alguns segundos,
   aparecem os avisos até **"Rooting complete"**. Reinicie quando ele pedir.
6. Depois do reboot, confirme que o **Homebrew Channel** apareceu na lista de apps.

O DejaVuln é **userland** (não mexe em firmware/bootloader) e **reversível**: desinstalar
o Homebrew Channel ou dar _factory reset_ volta a TV ao estado de fábrica.

## 2. Fechar a segurança na hora (SSH só por chave)

Depois do root, a TV fica com SSH e uma senha padrão conhecida (`alpine`). **Feche isso
antes de confiar na TV na rede.**

1. No **app Homebrew Channel**, ligue **"SSH Server"** e **"Block OTA Updates"** (bloqueia
   atualização automática).
2. No seu PC, gere uma chave dedicada e copie a pública pra TV:
   ```sh
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_lgtv -C "lgtv"
   ssh-copy-id -i ~/.ssh/id_ed25519_lgtv.pub root@<IP-DA-TV>   # senha: alpine
   ```
3. Entre por chave e, seguindo o
   [guia de SSH do webosbrew](https://www.webosbrew.org/), **desative o login por senha**.
   O IP da TV muda (DHCP) — o ideal é **reservar um IP fixo** pra ela no seu roteador.
   ```sh
   ssh -i ~/.ssh/id_ed25519_lgtv root@<IP-DA-TV>
   ```

## 3. Bloquear o monitoramento

Dois passos: desligar o ACR no menu e instalar o script de bloqueio.

**3.1. Desligar o ACR (reconhecimento de conteúdo).** Na TV, desligue o **"Live Plus"**
(Configurações → Geral → Live Plus). É ele que identifica o que aparece na tela.

**3.2. Instalar o script de boot.** O [`scripts/80-privacy-hardening`](scripts/80-privacy-hardening)
roda a cada boot (via Homebrew Channel) e:
- joga **36 domínios** de telemetria / ACR / anúncios / IoT da LG para `127.0.0.1` e `::1`
  no `/etc/hosts` (a lista e o porquê de cada grupo estão em
  [`findings/dominios-monitoramento.md`](../findings/dominios-monitoramento.md));
- encerra os daemons `acr2`, `homekit` e `airplay` se estiverem rodando;
- **confere** que aplicou e **reaplica em background** (o sistema recria o `/etc/hosts`
  tarde no boot — sem isso, o bloqueio se perde silenciosamente).

Ele **não** bloqueia a Content Store, streaming, nem AWS, pra não quebrar a TV. Nada é
escrito no `rootfs` (usa _bind-mount_ de um arquivo em `/tmp`); é **reversível** apagando
o arquivo.

Instale por SSH:
```sh
scp -i ~/.ssh/id_ed25519_lgtv scripts/80-privacy-hardening \
  root@<IP-DA-TV>:/var/lib/webosbrew/init.d/
ssh -i ~/.ssh/id_ed25519_lgtv root@<IP-DA-TV> \
  'chmod +x /var/lib/webosbrew/init.d/80-privacy-hardening'
```
Reinicie a TV (de preferência **tirando da tomada** por uns 30 s).

**Bônus (opcional, só memória):** em TVs apertadas de RAM, o
[`scripts/85-no-netflix-preload`](scripts/85-no-netflix-preload) impede o Quick Start+ de
deixar o Netflix pré-carregado (liberou ~65 MB na minha). Instala do mesmo jeito. Não tem
a ver com privacidade — pule se não precisar.

## 4. Conferir

Por SSH, com algo tocando na tela:
```sh
grep -c '^127.0.0.1' /etc/hosts     # deve dar >= 38 (2 do Homebrew + 36 do script)
cat /tmp/privacy-hardening.log      # deve dizer "ok: 38 entradas"
mount | grep hosts                  # o bind-mount do /etc/hosts ativo
```

## ⚠️ Se algum app de streaming parar de tocar

Num teste meu, apps com DRM (Netflix, Crunchyroll) chegaram a falhar com erro de
reprodução depois de mexidas no boot. **Não está 100% confirmado** se foi o bloqueio de
domínios ou só a TV travada — mas, se acontecer com você:

1. Desative o script (renomear pra `.disabled` faz o Homebrew ignorá-lo):
   ```sh
   ssh -i ~/.ssh/id_ed25519_lgtv root@<IP-DA-TV> \
     'mv /var/lib/webosbrew/init.d/80-privacy-hardening \
         /var/lib/webosbrew/init.d/80-privacy-hardening.disabled'
   ```
2. **Tire a TV da tomada por 30 s** e religue. Teste de novo.
3. Se voltar, reative o script bisseccionando os domínios (comente blocos no arquivo) pra
   achar qual atrapalha — os suspeitos são os de `lgtvcommon.com`.

## Reverter tudo

Desinstalar o **Homebrew Channel** e/ou fazer **factory reset** volta a TV ao estado de
fábrica. O root é userland; não há dano permanente.
