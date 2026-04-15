#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Snapshot dotfiles from the system into this repo."
    echo ""
    echo "Options:"
    echo "  --claude-dir DIR   Base Claude directory (default: ~/.claude)"
    echo "  --skills-dir DIR   Source directory for Claude skills (default: ~/.claude/skills)"
    echo "  --agents-dir DIR   Source directory for Claude agents (default: ~/.claude/agents)"
    echo "  --help             Show this help message"
}

CLAUDE_DIR=~/.claude
SKILLS_DIR=""
AGENTS_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --claude-dir)
            CLAUDE_DIR="$2"
            shift 2
            ;;
        --skills-dir)
            SKILLS_DIR="$2"
            shift 2
            ;;
        --agents-dir)
            AGENTS_DIR="$2"
            shift 2
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [[ -z "$SKILLS_DIR" ]]; then
    SKILLS_DIR="$CLAUDE_DIR/skills"
fi
if [[ -z "$AGENTS_DIR" ]]; then
    AGENTS_DIR="$CLAUDE_DIR/agents"
fi

UPDATED=0

log() { echo "  $1"; }

# Copy src to dest only if src exists and is newer
copy_if_newer() {
    local src="$1" dest="$2"
    if [[ ! -f "$src" ]]; then
        log "skip (not found): $src"
        return
    fi
    if [[ ! -f "$dest" ]] || [[ "$src" -nt "$dest" ]]; then
        cp "$src" "$dest"
        log "copy: $src -> $dest"
        UPDATED=$((UPDATED + 1))
    else
        log "ok (up to date): $dest"
    fi
}

echo "Snapshotting dotfiles to $DOTFILES_DIR..."

echo "Shell configs:"
copy_if_newer ~/.zshrc "$DOTFILES_DIR/.zshrc"
copy_if_newer ~/.bashrc "$DOTFILES_DIR/.bashrc"
copy_if_newer ~/.bash_aliases "$DOTFILES_DIR/.bash_aliases"

echo "Git:"
copy_if_newer ~/.gitconfig "$DOTFILES_DIR/.gitconfig"

echo "Editors:"
copy_if_newer ~/.vimrc "$DOTFILES_DIR/.vimrc"
if [[ -d ~/.config/nvim ]]; then
    mkdir -p "$DOTFILES_DIR/nvim"
    rsync -a --delete --exclude='.claude' --exclude='lazy-lock.json' ~/.config/nvim/ "$DOTFILES_DIR/nvim/"
    log "sync: ~/.config/nvim -> nvim/"
    UPDATED=$((UPDATED + 1))
else
    log "skip (not found): ~/.config/nvim"
fi

echo "Terminal:"
copy_if_newer ~/.tmux.conf "$DOTFILES_DIR/.tmux.conf"
copy_if_newer ~/.config/ghostty/config "$DOTFILES_DIR/ghostty/config"
copy_if_newer ~/.config/zellij/config.kdl "$DOTFILES_DIR/zellij/config.kdl"

echo "Cursor:"
case "$(uname)" in
    Darwin) CURSOR_SETTINGS=~/Library/Application\ Support/Cursor/User/settings.json ;;
    *)      CURSOR_SETTINGS=~/.config/Cursor/User/settings.json ;;
esac
copy_if_newer "$CURSOR_SETTINGS" "$DOTFILES_DIR/cursor/settings.json"
if command -v code &>/dev/null; then
    code --list-extensions > "$DOTFILES_DIR/cursor/extensions.txt"
    log "copy: code --list-extensions -> cursor/extensions.txt"
else
    log "skip (code not in PATH): cursor/extensions.txt"
fi

echo "Claude skills (from $SKILLS_DIR):"
if [[ -d "$SKILLS_DIR" ]]; then
    mkdir -p "$DOTFILES_DIR/skills"
    # Find valid skills — directories containing a SKILL.md — and copy them
    find "$SKILLS_DIR" -name "SKILL.md" -type f | while read -r skill_md; do
        skill_root="$(dirname "$skill_md")"
        skill_name="${skill_root#"$SKILLS_DIR"/}"
        log "copy: $skill_root -> skills/$skill_name"
        cp -R "$skill_root" "$DOTFILES_DIR/skills/"
    done
else
    log "skip (not found): $SKILLS_DIR"
fi

echo "Claude agents (from $AGENTS_DIR):"
if [[ -d "$AGENTS_DIR" ]]; then
    mkdir -p "$DOTFILES_DIR/agents"
    # Copy directory-style agents (dirs containing AGENT.md)
    find "$AGENTS_DIR" -name "AGENT.md" -type f | while read -r agent_md; do
        agent_root="$(dirname "$agent_md")"
        agent_name="${agent_root#"$AGENTS_DIR"/}"
        log "copy: $agent_root -> agents/$agent_name"
        cp -R "$agent_root" "$DOTFILES_DIR/agents/"
    done

    # Copy file-style agents (*.md files, e.g. rate.md)
    find "$AGENTS_DIR" -name "*.md" -type f ! -name "AGENT.md" | while read -r agent_file; do
        rel_path="${agent_file#"$AGENTS_DIR"/}"
        dst="$DOTFILES_DIR/agents/$rel_path"
        mkdir -p "$(dirname "$dst")"
        log "copy: $agent_file -> agents/$rel_path"
        cp "$agent_file" "$dst"
    done
else
    log "skip (not found): $AGENTS_DIR"
fi

echo "Done. $UPDATED file(s) updated."
