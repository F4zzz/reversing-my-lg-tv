# Colar no Claude — YouTube sem anúncio

Copie **tudo** abaixo da linha e cole numa conversa com o [Claude](https://claude.ai) — de
preferência o **Claude Code**, que roda comando no seu próprio PC. Troque o que estiver
entre `< >`.

---

Você vai me ajudar a instalar o **YouTube AdFree** (`webosbrew/youtube-webos`) no lugar do
YouTube oficial da **minha própria** TV LG, que já está **rooteada** (tem o Homebrew
Channel). Trabalhe assim, sem exceção:

- Me guie **um passo de cada vez** e **espere eu confirmar** o resultado antes de seguir.
- **Explique todo comando** antes de eu rodar.
- Agimos **só na minha rede local**, por SSH, **na minha TV**.
- **Auditar vem antes de instalar.** Nunca me mande instalar um pacote sem a gente
  conferir o hash e as conexões primeiro.
- Se algo não bater com o esperado, **pare e me pergunte**.

Minha TV (eu confirmo ou corrijo):
- Modelo: `<ex: LG UK6540PSB>`, webOS `<ex: 4.x>`, já rooteada: `<sim / não>`.
- IP na rede: `<ex: 192.168.0.x — ou me ajude a achar>`.
- Minha chave SSH: `<ex: ~/.ssh/id_ed25519_lgtv>`.

O processo (o passo a passo completo está em
https://github.com/F4zzz/reversing-my-lg-tv/tree/main/2-youtube-sem-anuncio):

1. **Auditar** a release oficial da versão que eu vou instalar: conferir o `sha256` do IPK
   contra o `ipkHash` do manifest, comparar o código embutido com o `src/` da tag, e
   listar **todas** as conexões de rede (deve falar só com youtube.com, fontes do Google e
   SponsorBlock). Se algo destoar, pare.
2. **Achar a TV** na rede (porta 3001) e conectar por SSH.
3. **Remover o YouTube oficial** (`youtube.leanback.v4`) — só a cópia em
   `/media/cryptofs/apps`, **nunca** o stub em `/mnt/otncabi`.
4. **Instalar** o IPK do AdFree (via `scp` + `luna-send .../dev/install`).
5. (Opcional) **Deixar com a cara oficial** com o `tools/rebrand.sh` — mas só se eu
   quiser, e me lembrando que eu preciso baixar o logo do YouTube por conta própria.
6. **Conferir**: abrir o YouTube e ver que não aparece anúncio; o botão verde abre os
   ajustes.

Explique por que bloquear por DNS (Pi-hole) não funciona pro YouTube, e comece me ajudando
a auditar a release (passo 1).
