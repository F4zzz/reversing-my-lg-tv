# Auditoria do YouTube AdFree (v0.5.3)

Antes de botar o [`webosbrew/youtube-webos`](https://github.com/webosbrew/youtube-webos)
na TV, eu auditei o app inteiro. Esta é a conta do que foi conferido na **v0.5.3** (data:
2026-10-23). A ideia é você **repetir** isso na versão que for instalar — se algum item
mudar, pare e revise.

## O que o app é

O YouTube oficial na TV é o site **youtube.com/tv** rodando num navegador interno. O
AdFree abre **esse mesmo site** e injeta um _user script_ que remove os anúncios e pula
patrocínios (SponsorBlock). Ele **não precisa de root**, não chama serviços do sistema
(`luna://`) e não mexe em boot nem em DRM.

## 1. Hash do pacote

O `sha256` do IPK tem que bater com o `ipkHash` publicado no
`youtube.leanback.v4.manifest.json` da release (o mesmo hash que o Homebrew Channel usa
pra instalar).

```
v0.5.3: 9c4f1dd0b04fd712adb6a9a1c5838da49b1003cd96de8354c10467b52d73259d
```
```sh
shasum -a 256 youtube.leanback.v4_0.5.3_all.ipk
```

## 2. O pacote corresponde ao código-fonte?

O IPK é gerado pelo GitHub Actions a partir da tag. Os `.map` embutidos no pacote permitem
comparar o código empacotado com os arquivos de `src/` da tag.

- Na v0.5.3, os **26 arquivos de código bateram**.
- Só os CSS diferem, porque saem **processados** pela compilação — o que é esperado.

## 3. Pra onde ele se conecta

Procurando por URLs e por `fetch`, `XMLHttpRequest`, `WebSocket`, `sendBeacon`, `luna://`
e `eval`, a lista completa de destinos na v0.5.3 foi:

| Destino | O que é |
|---|---|
| `youtube.com` | o próprio YouTube |
| `fonts.googleapis.com` / `fonts.gstatic.com` | uma fonte |
| `sponsorblock.inf.re` | SponsorBlock — recebe **só 4 caracteres de um hash** do ID do vídeo, então o servidor **não sabe** o que você assiste |

O resto que aparece numa busca ingênua (`https://a`, `https://x`, `new Function`,
`XMLHttpRequest`) vem de **bibliotecas de compatibilidade** (core-js, whatwg-fetch), não da
lógica do app.

## 4. Conta e dados

- O único cookie que ele altera é o `PREF` (idioma). **Nada da sessão sai da TV.**
- Usado **sem login**.

## 5. Scripts de instalação

O pacote **não tem scripts de instalação** — o `control.tar.gz` só tem o arquivo
`control`. Ou seja, instalar o IPK não roda código extra na TV.

## Conclusão

Na v0.5.3: código idêntico ao fonte público, fala só com YouTube + fonte + SponsorBlock
(e esse recebe só um pedaço de hash), não pede root, não tem script de instalação e não
exfiltra dados da conta. Por isso foi pra TV.

> ⚠️ **Repita a auditoria a cada versão.** Não atualize o AdFree pelo Homebrew Channel sem
> auditar de novo — a atualização traz código não auditado.
