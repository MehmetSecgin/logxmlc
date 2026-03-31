#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-${LOGXMLC_INSTALL_DIR:-$HOME/.local/bin}}"
GITHUB_REPO="${LOGXMLC_GITHUB_REPO:-}"
GITHUB_REF="${LOGXMLC_GITHUB_REF:-main}"
SOURCE_URL="${LOGXMLC_SOURCE_URL:-}"

SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  SCRIPT_PATH="${BASH_SOURCE[0]}"
  if [[ "$SCRIPT_PATH" != "bash" && "$SCRIPT_PATH" != "/dev/fd/"* && -e "$SCRIPT_PATH" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
  fi
fi

LOCAL_SOURCE=""
if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/logxmlc" ]]; then
  LOCAL_SOURCE="$SCRIPT_DIR/logxmlc"
fi

if [[ -z "$LOCAL_SOURCE" && -z "$SOURCE_URL" && -n "$GITHUB_REPO" ]]; then
  SOURCE_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_REF/logxmlc"
fi

if [[ -z "${HOME:-}" ]]; then
  echo "HOME must be set." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required but was not found on PATH." >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

if [[ -n "$LOCAL_SOURCE" ]]; then
  install -m 755 "$LOCAL_SOURCE" "$TARGET_DIR/logxmlc"
elif [[ -n "$SOURCE_URL" ]]; then
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required for remote installation." >&2
    exit 1
  fi
  tmpfile="$(mktemp)"
  trap 'rm -f "$tmpfile"' EXIT
  curl -fsSL "$SOURCE_URL" -o "$tmpfile"
  install -m 755 "$tmpfile" "$TARGET_DIR/logxmlc"
else
  echo "Could not find a local logxmlc file to install." >&2
  echo "If running via curl, set LOGXMLC_GITHUB_REPO or LOGXMLC_SOURCE_URL." >&2
  exit 1
fi

ln -sf "$TARGET_DIR/logxmlc" "$TARGET_DIR/logxml"

echo "Installed:"
echo "  $TARGET_DIR/logxmlc"
echo "  $TARGET_DIR/logxml"

case ":$PATH:" in
  *":$TARGET_DIR:"*)
    echo "$TARGET_DIR is already on PATH."
    ;;
  *)
    echo "Add this to your shell profile to use it everywhere:"
    echo "  export PATH=\"$TARGET_DIR:\$PATH\""
    ;;
esac

echo "Try it with:"
echo "  printf '%s\n' 'INFO <?xml version=\"1.0\"?><root><a>1</a></root>' | logxmlc"
