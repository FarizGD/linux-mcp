#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/linux-mcp"
BIN_DIR="$HOME/.local/bin"
VENV="$DATA_DIR/venv"

if [[ "${EUID}" -eq 0 ]]; then
  echo "Do not install Linux-MCP as root. Run this script as your normal desktop user." >&2
  exit 1
fi

command -v python3 >/dev/null 2>&1 || {
  echo "Missing python3. Install it with: sudo apt install python3 python3-venv python3-pip" >&2
  exit 1
}

mkdir -p "$DATA_DIR" "$BIN_DIR"
python3 -m venv "$VENV"
"$VENV/bin/python" -m pip install --upgrade pip
"$VENV/bin/python" -m pip install "$ROOT"

# Legacy playbooks use "pkg". Map the supported actions to Ubuntu's apt tools.
cat > "$VENV/bin/pkg" <<'PKG'
#!/usr/bin/env bash
set -Eeuo pipefail
action="${1:-}"
shift || true
case "$action" in
  update) exec apt-get update "$@" ;;
  upgrade) exec apt-get upgrade "$@" ;;
  install) exec apt-get install "$@" ;;
  uninstall|remove) exec apt-get remove "$@" ;;
  autoremove) exec apt-get autoremove "$@" ;;
  clean) exec apt-get clean "$@" ;;
  search) exec apt-cache search "$@" ;;
  show) exec apt-cache show "$@" ;;
  list-installed) exec dpkg-query -W -f='${Package} ${Version}\n' ;;
  *) echo "pkg compatibility: supported actions: update, upgrade, install, uninstall, remove, autoremove, clean, search, show, list-installed" >&2; exit 2 ;;
esac
PKG
chmod 0755 "$VENV/bin/pkg"

for command_name in linux-mcp linux-native-mcp termux-mcp termux-native-mcp; do
  cat > "$BIN_DIR/$command_name" <<EOF
#!/usr/bin/env bash
export PATH="$VENV/bin:\$PATH"
exec "$VENV/bin/$command_name" "\$@"
EOF
  chmod 0755 "$BIN_DIR/$command_name"
done

echo
echo "Linux-MCP installed."
echo "Ensure $BIN_DIR is in PATH: export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "Start REST API: linux-mcp"
echo "Start native MCP (stdio): linux-native-mcp --stdio"
