# Os 36 domínios que a TV chama sozinha

Estes são os domínios de backend da LG que a TV contata e que o script
[`80-privacy-hardening`](../1-root-e-privacidade/scripts/80-privacy-hardening) joga para
`127.0.0.1` e `::1` no `/etc/hosts`. A função de cada grupo está inferida pelo nome do
subdomínio e pelo comportamento — onde não é certeza, está dito.

O que o script **não bloqueia** de propósito, pra não quebrar a TV: a **Content Store**
(`lgtvsdp.com`, `lgappstv.com`), serviços de voz, streaming (Netflix, YouTube) e a AWS.

## nextlgsdp.com — plataforma de entrega / estatística (4)
```
nextlgsdp.com
ibs.nextlgsdp.com
ibsstat.nextlgsdp.com
rdx2.nextlgsdp.com
```
Backend "SDP" da LG; os subdomínios `ibsstat`/`rdx` têm cara de coleta de estatística de
uso.

## lgtvcommon.com — recomendação, configuração e beacon (12)
```
lgtvcommon.com         nudge.lgtvcommon.com       homeprv.lgtvcommon.com
wiseconfig.lgtvcommon.com   pnv.lgtvcommon.com    recommend.lgtvcommon.com
cdpsvc.lgtvcommon.com  cpauth.lgtvcommon.com      cdpbeacon.lgtvcommon.com
rdl.lgtvcommon.com     wiseresource.lgtvcommon.com   qcardservice.lgtvcommon.com
```
O grupo mais pesado. `recommend`, `nudge` e `homeprv` alimentam recomendação e conteúdo da
home; `cdpbeacon` tem nome de **beacon** (telemetria); `cpauth` é autenticação desse
serviço de conteúdo. (Nos testes de DRM, os suspeitos de interferir eram daqui — ver o
aviso de DRM na parte 1.)

## lggalleryplus.com / wiselg.com — galeria e proteção de tela (2)
```
lggalleryplus.com
tv.wiselg.com
```
Conteúdo da "galeria"/screensaver.

## lgsmartad.com — anúncios (2)
```
lgsmartad.com
info.lgsmartad.com
```
O nome já diz: plataforma de **anúncios** da LG ("smart ad").

## ngfts.lge.com — entrega de arquivos (4)
```
ngfts.lge.com   qt2-ngfts.lge.com   kic-ngfts.lge.com   kic-qt2-ngfts.lge.com
```
CDN de arquivos da LG (ativos de recomendação/anúncio e afins).

## lgtviot.com — IoT e push (7)
```
lgtviot.com         api.lgtviot.com    commonpush.lgtviot.com   sports.lgtviot.com
ocp.lgtviot.com     push.lgtviot.com   buddy.lgtviot.com
```
Serviços de IoT e **notificação push** da TV.

## lgthinq.com — ThinQ (3)
```
lgthinq.com   common.lgthinq.com   connect-client.lgthinq.com
```
Plataforma **ThinQ** (conta/IoT da LG).

## lge.com — atualização de software (2)
```
nsu.lge.com   snu-dev.lge.com
```
Relacionados a atualização de software. (O Homebrew Channel já adiciona `snu/su/su-ssl.lge.com`
por conta própria quando você liga o "Block OTA Updates" — isto aqui complementa.)

---

Conferência na TV, com algo tocando na tela:
```sh
grep -c '^127.0.0.1' /etc/hosts   # >= 38 = 2 do Homebrew Channel + 36 daqui
```
