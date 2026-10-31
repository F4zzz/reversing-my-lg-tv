# Colar no Claude — Root + bloquear o monitoramento

Copie **tudo** abaixo da linha e cole numa conversa com o [Claude](https://claude.ai) — de
preferência o **Claude Code**, que roda comando no seu próprio PC. Troque o que estiver
entre `< >`.

---

Você vai me ajudar a ganhar root e bloquear o monitoramento da **minha própria** TV LG.
É pesquisa de privacidade no meu aparelho. Trabalhe assim, sem exceção:

- Me guie **um passo de cada vez** e **espere eu confirmar** o resultado antes de seguir.
- **Explique todo comando** antes de eu rodar, principalmente os que mexem na TV.
- Agimos **só na minha rede local**, por SSH, **na minha TV**. Nunca em outro aparelho.
- Se algo não bater com o esperado, **pare e me pergunte** em vez de chutar.
- Nunca me mande rodar comando destrutivo sem explicar o risco e eu confirmar.
- **Nunca** me oriente a atualizar o firmware da TV (isso remove o root).

Minha TV (eu confirmo ou corrijo):
- Modelo: `<ex: LG UK6540PSB>`, webOS `<ex: 4.x>`.
- Já conferi em https://cani.rootmy.tv/ que ela é rooteável: `<sim / não / não sei>`.

O processo (o passo a passo completo está em
https://github.com/F4zzz/reversing-my-lg-tv/tree/main/1-root-e-privacidade):

1. **Root** com a ferramenta pública `dejavuln-autoroot` (eu executo pelo pendrive,
   seguindo o guia oficial do webosbrew). Me ajude a conferir os pré-requisitos e, no
   fim, a confirmar que deu certo (o Homebrew Channel aparece na lista de apps).
2. **Fechar a segurança**: ligar o SSH, instalar a minha chave pública e **desligar a
   senha padrão** (`alpine`).
3. **Bloquear o monitoramento**: instalar em `/var/lib/webosbrew/init.d/` o script
   `80-privacy-hardening` (joga os domínios de telemetria/ACR/anúncios da LG pro
   `127.0.0.1` e encerra o `acr2`), e desligar o **Live Plus (ACR)** no menu da TV.
4. **Conferir** que o bloqueio aplicou de verdade (`grep -c '^127.0.0.1' /etc/hosts` >= 38
   e o log em `/tmp/privacy-hardening.log`).

Se em algum momento um app de streaming parar de tocar com erro de DRM, me avise — a gente
desativa o script (renomeia pra `.disabled`), tira da tomada 30 s e investiga.

Comece conferindo comigo os pré-requisitos do passo 1.
