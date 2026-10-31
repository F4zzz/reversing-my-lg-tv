# findings — a engenharia reversa

A parte de análise, separada do passo a passo. É o que sustenta o "reversing" do nome:
não é só rodar ferramenta pronta, é entender o que a TV faz e o que o app faz antes de
confiar neles.

- [`dominios-monitoramento.md`](dominios-monitoramento.md) — os **36 domínios** da LG que
  a TV contata e que o `80-privacy-hardening` derruba, agrupados por função.
- [`auditoria-youtube-adfree.md`](auditoria-youtube-adfree.md) — a **auditoria completa**
  do YouTube AdFree antes de instalar: hash, comparação com o código-fonte público e
  todas as conexões de rede.

## O que é fato e o que não é (honestidade importa)

- **Comprovado:** o ACR (reconhecimento de conteúdo, "Live Plus") vem **ligado de
  fábrica**. Os domínios abaixo são infraestrutura de telemetria / ACR / anúncios / IoT da
  própria LG.
- **Não afirmo** que "a TV vivia cheia de propaganda na tela" — isso eu **não** medi. O
  que eu tratei foi o **monitoramento** (o phone-home) e o ACR.
- A falha de root é uma **variante** no mesmo componente da CVE-2023-6319, **não** a CVE
  original já corrigida (detalhe na [parte 1](../1-root-e-privacidade/README.md)).
