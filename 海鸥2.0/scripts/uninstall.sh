#!/bin/bash
# Seagull Uninstall (macOS)
# Wrapper for uninstall

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
UNINSTALL_SCRIPT="$PARENT_DIR/卸载.command"

if [ -f "$UNINSTALL_SCRIPT" ]; then
    chmod +x "$UNINSTALL_SCRIPT"
    bash "$UNINSTALL_SCRIPT"
else
    # Inline uninstall
    USER_HOME="$HOME"
    CLAUDE_DIR="$USER_HOME/.claude"

    echo "Removing Seagull config from $CLAUDE_DIR..."

    for f in CLAUDE.md system-prompt.md config.toml; do
        if [ -f "$CLAUDE_DIR/$f" ]; then
            rm -f "$CLAUDE_DIR/$f"
            echo "  Removed $f"
        fi
    done

    # Desktop version dirs
    for dir in \
        "$USER_HOME/Library/Application Support/claude" \
        "$USER_HOME/Library/Application Support/claude-code" \
        "$USER_HOME/Library/Application Support/Claude" \
        "$USER_HOME/Library/Application Support/Claude Code"; do
        if [ -d "$dir" ]; then
            for f in CLAUDE.md system-prompt.md config.toml; do
                rm -f "$dir/$f" 2>/dev/null
            done
            echo "  Cleaned: $dir"
        fi
    done

    echo "Done."
fi
