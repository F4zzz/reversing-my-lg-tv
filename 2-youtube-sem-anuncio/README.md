# 2. YouTube sem anúncio

Instalar o **YouTube AdFree** ([`webosbrew/youtube-webos`](https://github.com/webosbrew/youtube-webos))
no lugar do YouTube oficial da TV. Sem anúncio, sem patrocinado no meio do vídeo (via
SponsorBlock) e sem precisar de login.

> ⚠️ Precisa da **parte 1 feita** (root + Homebrew Channel). Leia o
> [aviso do repositório](../README.md). Bloquear o anúncio do YouTube **fere os Termos de
> Serviço** dele (questão civil, não crime) — você decide se topa.

**Versão de referência:** YouTube AdFree **v0.5.3**, auditada em 2026-10-23 (a auditoria
completa está em [`findings/auditoria-youtube-adfree.md`](../findings/auditoria-youtube-adfree.md)).

> ⚠️ **Não atualize o AdFree pelo Homebrew Channel.** A atualização traz código que **você
> não auditou** (e volta o ícone de "cone"). Pra atualizar, refaça os passos com a versão
> nova, auditando de novo.

## 0. Por que funciona (e por que adblock não resolve)

- O app oficial do YouTube na TV é o site **youtube.com/tv** rodando num navegador
  interno. O AdFree abre **esse mesmo site** e injeta um script que remove os anúncios e
  pula patrocínios (SponsorBlock).
- Ele **não precisa de root**, não chama serviços do sistema (`luna://`) e não mexe em
  boot nem em DRM. Netflix e os outros apps não são afetados.
- **Por que não dá pra bloquear por DNS (Pi-hole etc.):** o YouTube entrega os anúncios
  pelos **mesmos domínios** dos vídeos. Bloqueou o anúncio, bloqueou o vídeo.

## 1. Auditar a versão (antes de instalar qualquer coisa)

Nunca instale às cegas. O passo a passo da auditoria que eu fiz está em
[`findings/auditoria-youtube-adfree.md`](../findings/auditoria-youtube-adfree.md). Em
resumo:

1. Baixe o **código-fonte na tag da versão** e o **IPK só da release oficial**:
   <https://github.com/webosbrew/youtube-webos/releases>. Sem mirrors nem forks.
2. **Hash:** o `sha256` do IPK tem que bater com o `ipkHash` publicado no
   `youtube.leanback.v4.manifest.json` da release (o mesmo que o Homebrew usa).
   - v0.5.3: `9c4f1dd0b04fd712adb6a9a1c5838da49b1003cd96de8354c10467b52d73259d`
3. **O pacote corresponde ao código-fonte?** Abra os `.map` dentro do IPK e compare com os
   arquivos de `src/` da tag — o código tem que ser idêntico (só os CSS diferem, por
   serem processados na compilação, o que é normal).
4. **Pra onde ele se conecta** (procure URLs, `fetch`, `XMLHttpRequest`, `WebSocket`,
   `sendBeacon`, `luna://`, `eval`): na v0.5.3, só **youtube.com**, as fontes do Google e
   o **SponsorBlock** (que recebe só 4 caracteres de um hash do ID do vídeo — não sabe o
   que você assiste).

**Se qualquer item mudar numa versão nova, pare e revise antes de instalar.**

## 2. Achar a TV na rede e conectar

O IP muda (DHCP) — **reserve um IP fixo** pra TV no roteador pra facilitar. Pra achar:
```sh
for i in $(seq 1 254); do (nc -z -G 1 192.168.0.$i 3001 2>/dev/null && echo 192.168.0.$i) & done; wait
```
(troque `192.168.0` pela faixa da sua rede; a porta **3001** é a da LG). Conecte com a sua
chave:
```sh
ssh -i ~/.ssh/id_ed25519_lgtv root@<IP-DA-TV>
```
Se você usa o `ares-cli` da LG, aponte o device pro IP atual:
```sh
ares-setup-device -m lgtv -i "host=<IP-DA-TV>"
```

## 3. Remover o YouTube oficial

O AdFree usa o **mesmo ID** (`youtube.leanback.v4`), então o oficial precisa sair antes.
Há duas cópias na TV:

| Onde | O que é | Mexer? |
|---|---|---|
| `/media/cryptofs/apps/.../youtube.leanback.v4` | o app real baixado da loja (v1.3.92) | **Sim**, é removível |
| `/mnt/otncabi/.../youtube.leanback.v4` | _stub_ de fábrica da LG (atalho que baixa o app), em squashfs só-leitura | **Não mexer** |

Na TV, por SSH:
```sh
luna-send -i luna://com.webos.appInstallService/remove \
  '{"id":"youtube.leanback.v4","subscribe":true}'
```
O processo termina quando aparecer `"state":"removed"`. Confirme que a pasta em
`/media/cryptofs/apps` sumiu. (Encerre o `luna-send` com Ctrl-C depois.)

## 4. Instalar o AdFree

A forma mais confiável (o `ares-install` às vezes falha com `Unable to exec`): copie o IPK
e instale pelo serviço da TV.
```sh
scp -i ~/.ssh/id_ed25519_lgtv <caminho-do-ipk>/youtube.leanback.v4_*.ipk \
  root@<IP-DA-TV>:/tmp/yt.ipk
# na TV:
luna-send -i luna://com.webos.applicationManager/closeByAppId '{"id":"youtube.leanback.v4"}'
luna-send -i luna://com.webos.appInstallService/dev/install \
  '{"id":"youtube.leanback.v4","ipkUrl":"/tmp/yt.ipk","subscribe":true}'
rm /tmp/yt.ipk
```
Termina em `"state":"installed"`. O app vai pra `/media/developer/apps/...`.

## 5. (Opcional) Deixar com a cara oficial do YouTube

Direto da release, o AdFree vem com um ícone de "cone". Se quiser que fique **idêntico ao
YouTube de fábrica** na home, o [`tools/rebrand.sh`](tools/rebrand.sh) baixa a release,
**confere o hash**, troca **só** o ícone/nome e **aborta se o código mudar** (ou seja, o
código auditado continua byte a byte igual).

> Este repo **não inclui o logo do YouTube** (é marca registrada). Baixe o logo oficial do
> [Wikimedia Commons](https://commons.wikimedia.org/wiki/File:YouTube_full-color_icon_(2017).svg),
> salve como `tools/youtube-logo.svg` e **use por sua conta** — é um passo cosmético,
> opcional, e cada um responde pelo uso de marca de terceiros.

```sh
tools/rebrand.sh <IP-DA-TV> [versão] [sha256]
# saída: tools/build/out/youtube.leanback.v4_<versão>_all.ipk  → instale com o passo 4
```
Os ícones pequenos são copiados do _stub_ de fábrica da própria TV (por isso ela precisa
estar ligada e acessível por SSH).

## 6. Conferir

1. Abra o YouTube e assista alguns vídeos: **não deve aparecer anúncio**.
2. O **botão verde** do controle abre os ajustes do AdFree e do SponsorBlock.
3. Se a lista de apps ainda mostrar o ícone antigo, **reinicie a TV** (cache de ícones da
   LG).

## Reverter (voltar ao YouTube oficial)

```sh
luna-send -i luna://com.webos.appInstallService/remove '{"id":"youtube.leanback.v4","subscribe":true}'
```
Depois abra o ícone "YouTube" de fábrica (o _stub_), que rebaixa o app oficial da loja.
