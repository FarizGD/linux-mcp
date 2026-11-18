# Linux-MCP

A local-first MCP and HTTP automation server for **Ubuntu and Linux desktops/servers**. This is the Linux port of Termux-MCP. It keeps the existing REST API, native MCP transports, command safety gates, capability tokens, audit trail, playbooks and smart tools while using the host Linux environment instead of Android/Termux paths.

> Android-only capabilities (Termux:API, SMS, phone calls, Android UI automation, Android camera/sensors and Android storage intents) are not available on a normal Ubuntu machine. They are not emulated. Use Linux-native tools and integrations for host capabilities.

## Requirements

- Ubuntu 22.04 or newer (other systemd-based Debian/Ubuntu derivatives should work)
- Python 3.10+
- `git`, `curl`, `procps`, `iproute2`, `util-linux`, `tar`, `gzip`
- Optional: `systemd`, `network-manager`, `upower`, `brightnessctl`, `pactl`, `ffmpeg`, `tesseract-ocr`

## Install

```bash
sudo apt update
sudo apt install -y git python3 python3-venv python3-pip curl procps iproute2 util-linux tar gzip
git clone https://github.com/FarizGD/linux-mcp.git
cd linux-mcp
./scripts/install-ubuntu.sh
```

The installer creates an isolated virtual environment at `~/.local/share/linux-mcp/venv`, installs the project, and adds `linux-mcp` and `linux-native-mcp` launchers to `~/.local/bin`. Add that directory to PATH if needed:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Run

REST API:

```bash
linux-mcp
```

Native MCP over stdio:

```bash
linux-native-mcp --stdio
```

Native MCP over Streamable HTTP:

```bash
linux-native-mcp
```

Default endpoints:

- REST API: `http://127.0.0.1:8080`
- Native MCP: `http://127.0.0.1:8081/mcp`
- Health check: `http://127.0.0.1:8080/ping`

## Connect an MCP client

For a local stdio client:

```json
{
  "mcpServers": {
    "linux": {
      "command": "/home/YOUR_USER/.local/bin/linux-native-mcp",
      "args": ["--stdio"]
    }
  }
}
```

For a client supporting Streamable HTTP:

```json
{
  "mcpServers": {
    "linux": {
      "url": "http://127.0.0.1:8081/mcp"
    }
  }
}
```

Replace the example home path with the output of `echo "$HOME"`.

## Configuration

| Variable | Default | Description |
|---|---|---|
| `TERMUX_MCP_HOST` | `127.0.0.1` | HTTP bind address |
| `TERMUX_MCP_PORT` | `8080` | REST API port |
| `TERMUX_MCP_TIMEOUT` | `0` | Shell command timeout in seconds; 0 disables the global timeout |
| `TERMUX_MCP_MAX_OUTPUT` | `20000` | Maximum streamed output bytes per command |
| `TERMUX_MCP_AUTH_TOKEN` | generated/empty per existing auth behavior | Bearer token |
| `TERMUX_MCP_HOME` | `$HOME` | Home directory used by the server |

Keep the server bound to loopback unless remote access is required. When binding to a non-loopback address, configure authentication first. Do not expose an unauthenticated shell server to the internet.

## Linux compatibility

- Uses the real Linux home directory and filesystem instead of Termux's hard-coded Android home.
- Uses Ubuntu's `apt`/ `apt-get` package manager. A small `pkg` compatibility command is installed inside the private virtual environment for legacy playbooks and commands.
- Shell commands run as the account that starts the server. The server does not silently run commands with `sudo`.
- Android-only endpoints return an unavailable-command error when the required Termux API executable is absent. They do not pretend to control Linux hardware.
- Use normal Linux tools such as `nmcli`, `upower`, `pactl`, `brightnessctl`, `loginctl`, and `systemctl` through the guarded shell tools where installed.

## Security

The existing command risk gate, policy checks, capability-token scopes, path restrictions, file snapshots, and event logging are retained. Run as an unprivileged user. Grant elevated access only for individual operations that genuinely require it.

## Development and tests

```bash
source .venv/bin/activate
python -m pytest
```

The original `termux-mcp` and `termux-native-mcp` command names remain available as compatibility aliases. The Python import package remains `termux_mcp` to preserve compatibility with the upstream code.

## License

AGPL-3.0. See [LICENSE](LICENSE).
