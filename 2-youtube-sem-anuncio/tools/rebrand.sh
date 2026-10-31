#!/bin/sh
# rebrand.sh — deixa o YouTube AdFree com o visual oficial do YouTube (nome,
# icones, fundos). So troca imagens e o appinfo; o codigo auditado sai
# byte-identico, e o script ABORTA se nao sair.
#
# Uso: ./rebrand.sh <ip-da-tv> [versao] [sha256-do-ipk-oficial]
# Saida: tools/build/out/youtube.leanback.v4_<versao>_all.ipk
#
# PRE-REQUISITO (nao vem neste repo, por ser marca registrada):
#   baixe o logo oficial do YouTube do Wikimedia Commons e salve como
#   tools/youtube-logo.svg. Passo cosmetico e opcional; o uso de marca de
#   terceiros e de responsabilidade de quem roda.
#
# Variaveis de ambiente opcionais:
#   SSH_KEY   (default ~/.ssh/id_ed25519_lgtv)
#   CHROME    (default Google Chrome do macOS)
set -eu

TV_IP="${1:?uso: $0 <ip-da-tv> [versao] [sha256]}"
VERSION="${2:-0.5.3}"
EXPECTED_SHA="${3:-9c4f1dd0b04fd712adb6a9a1c5838da49b1003cd96de8354c10467b52d73259d}"

HERE="$(cd "$(dirname "$0")" && pwd)"
BUILD="$HERE/build"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_ed25519_lgtv}"
# A TV costuma trocar de IP (DHCP). Na primeira conexao voce confirma/aceita a
# host key dela; depois disso a verificacao normal do SSH ja protege.
SSH_OPTS="-i $SSH_KEY"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
APP_DIR="usr/palm/applications/youtube.leanback.v4"
STUB_DIR="/mnt/otncabi/usr/palm/applications/youtube.leanback.v4"
IPK_NAME="youtube.leanback.v4_${VERSION}_all.ipk"

if [ ! -f "$HERE/youtube-logo.svg" ]; then
  echo "falta $HERE/youtube-logo.svg (veja o cabecalho deste script)" >&2
  exit 1
fi

# ares-cli quebra no Node 26; use o 22 se precisar.
# export PATH="/opt/homebrew/opt/node@22/bin:$PATH"

rm -rf "$BUILD" && mkdir -p "$BUILD/orig" "$BUILD/render" "$BUILD/out"
cd "$BUILD"

echo "1/6 baixando release oficial v$VERSION"
curl -sfL -o "$IPK_NAME" \
  "https://github.com/webosbrew/youtube-webos/releases/download/v$VERSION/$IPK_NAME"

echo "2/6 conferindo hash"
ACTUAL_SHA="$(shasum -a 256 "$IPK_NAME" | cut -d' ' -f1)"
if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
  echo "HASH DIFERENTE: esperado $EXPECTED_SHA, veio $ACTUAL_SHA" >&2
  exit 1
fi

echo "3/6 extraindo"
(cd orig && ar x "../$IPK_NAME" && tar xzf data.tar.gz)
cp -R "orig/$APP_DIR" app

echo "4/6 copiando icones oficiais da LG (stub de fabrica na TV)"
scp -q $SSH_OPTS "root@$TV_IP:$STUB_DIR/icon.png" "root@$TV_IP:$STUB_DIR/largeIcon.png" app/

echo "5/6 renderizando icones e fundos com o logo do YouTube"
LOGO="$(sed '1{/^<?xml/d;}' "$HERE/youtube-logo.svg")"
LOGO_DARK="$(printf '%s' "$LOGO" | sed 's/rgb(40, 40, 40)/#ffffff/g')"

render() { # nome largura altura fundo svg largura-do-logo
  cat > "render/$1.html" <<EOF
<!doctype html><html><head><meta charset="utf-8"><style>
html,body{margin:0;width:$2px;height:$3px;background:$4;overflow:hidden}
body{display:flex;align-items:center;justify-content:center}
svg{width:$6px;height:auto;display:block}</style></head><body>$5</body></html>
EOF
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=1 --window-size="$2,$3" \
    --screenshot="$BUILD/render/$1.png" "file://$BUILD/render/$1.html" >/dev/null 2>&1
}

# Icones no estilo do icone oficial da LG: fundo branco, logo colorido.
render mediumLargeIcon 115 115 '#ffffff' "$LOGO" 94
render extraLargeIcon 192 192 '#ffffff' "$LOGO" 158
# Telas no fundo escuro do YouTube TV, com o texto do logo em branco.
render bgImage 1920 1080 '#0f0f0f' "$LOGO_DARK" 560
cp render/mediumLargeIcon.png render/extraLargeIcon.png render/bgImage.png app/
cp render/bgImage.png app/imageForRecents.png
cp render/bgImage.png app/splashBackground-v1.png

python3 -I - app/appinfo.json <<'EOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    info = json.load(f)
info["title"] = "YouTube"
info["iconColor"] = "#ffffff"
with open(path, "w") as f:
    json.dump(info, f, indent=2, ensure_ascii=False)
EOF

echo "6/6 empacotando e conferindo que o codigo nao mudou"
ares-package --no-minify app -o out >/dev/null
mkdir chk && (cd chk && ar x "../out/$IPK_NAME" && tar xzf data.tar.gz)
for f in index.html index.js webOSUserScripts/userScript.js; do
  if ! cmp -s "orig/$APP_DIR/$f" "chk/$APP_DIR/$f"; then
    echo "CODIGO ALTERADO: $f — abortando" >&2
    exit 1
  fi
done

echo "OK: $BUILD/out/$IPK_NAME (codigo identico ao oficial auditado)"
