# reversing-my-lg-tv

Fiz engenharia reversa na minha própria TV LG pra tirar o monitoramento dela e ainda
rodar YouTube sem anúncio. Aqui está tudo documentado: o passo a passo pra fazer na mão
e, se você não manja da parte técnica, um arquivo pra **colar no Claude** e deixar ele
te guiar.

> **Veio do vídeo?** É aqui mesmo. Pula pra [Os dois processos](#os-dois-processos).

TV de referência deste guia: **LG UK6540PSB, webOS 4.x** (firmware 05.50.70). Outros
modelos e versões: confira a sua em [cani.rootmy.tv](https://cani.rootmy.tv/).

## ⚠️ Aviso — leia antes de qualquer coisa

- Isto é **pesquisa no meu próprio aparelho**. Faça **só na sua própria TV**. Mexer em
  equipamento que não é seu pode ser crime.
- **Fins educativos e de privacidade.** Nada aqui é conselho jurídico.
- **Pode anular a garantia.** Modificar o software da TV provavelmente invalida a
  garantia do fabricante.
- **Por sua conta e risco.** O root é _userland_ e reversível (um _factory reset_ volta
  tudo ao normal), mas toda modificação tem risco, inclusive o de inutilizar o aparelho
  se você fizer algo errado. Se não entende um passo, **não rode**. Eu **não me
  responsabilizo** por nada que aconteça com a sua TV.
- **Não atualize o firmware** da TV antes nem depois do root: uma atualização pode fechar
  a falha e remover o root.
- Bloquear o anúncio do YouTube **fere os Termos de Serviço do YouTube** (questão civil,
  de contrato — não é crime). Você decide se topa.
- Este repositório **não contém o exploit** nem ensina a montá-lo. Ele aponta para as
  ferramentas públicas e já auditadas pela comunidade.
- Software distribuído **"no estado em que se encontra", sem garantia de nenhum tipo**,
  como diz a [licença](LICENSE).

## Os dois processos

### 1. Root + bloquear o monitoramento → [`1-root-e-privacidade/`](1-root-e-privacidade/)
Ganhar root na TV com uma ferramenta pública (DejaVuln), desligar o ACR, bloquear a
telemetria e derrubar os 36 domínios que a TV fica chamando sozinha.
- 🤖 Colar no Claude: [`prompt.md`](1-root-e-privacidade/prompt.md)
- 📖 Passo a passo: [`README.md`](1-root-e-privacidade/README.md)

### 2. YouTube sem anúncio → [`2-youtube-sem-anuncio/`](2-youtube-sem-anuncio/)
Instalar o YouTube AdFree (open source), auditado antes de entrar na TV, no lugar do
YouTube oficial. Sem anúncio, sem patrocinado no meio do vídeo, sem login.
- 🤖 Colar no Claude: [`prompt.md`](2-youtube-sem-anuncio/prompt.md)
- 📖 Passo a passo: [`README.md`](2-youtube-sem-anuncio/README.md)

> A parte 2 depende da parte 1 (precisa de root / Homebrew Channel). Faça na ordem.

## Como usar com o Claude

1. Entre na pasta do processo que você quer.
2. Abra o `prompt.md` e **copie o conteúdo inteiro**.
3. Cole numa conversa com o [Claude](https://claude.ai) — de preferência o **Claude Code**,
   que roda comando no seu próprio PC — e siga o que ele pedir. Ele vai te guiar um passo
   de cada vez, conferindo cada etapa antes de ir pra próxima.

Prefere fazer na mão e entender tudo? Siga o `README.md` de cada pasta.

## O que eu descobri (a engenharia reversa)

Em [`findings/`](findings/) está a parte de RE de verdade:
- [a lista dos 36 domínios](findings/dominios-monitoramento.md) que a TV chamava e o que
  cada grupo faz;
- [a auditoria completa do app de YouTube](findings/auditoria-youtube-adfree.md) — hash,
  comparação com o código-fonte público e todas as conexões de rede que ele faz.

## Créditos

Isto é um guia em cima do trabalho de muita gente boa. Obrigado:
- [Homebrew Channel](https://github.com/webosbrew/webos-homebrew-channel) e
  [cani.rootmy.tv](https://cani.rootmy.tv/) — [webosbrew](https://github.com/webosbrew)
- [dejavuln-autoroot](https://github.com/throwaway96/dejavuln-autoroot) — throwaway96
- [youtube-webos / YouTube AdFree](https://github.com/webosbrew/youtube-webos) — webosbrew
- [SponsorBlock](https://sponsor.ajay.app/)

## Licença

[MIT](LICENSE). Sem garantia de nenhum tipo.
