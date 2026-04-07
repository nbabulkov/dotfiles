#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script only supports macOS. $(uname) support is not yet implemented." >&2
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo ""
    echo "Install dotfiles from this repo to the system."
    echo ""
    echo "Options:"
    echo "  --claude-dir DIR   Base Claude directory (default: ~/.claude)"
    echo "  --skills-dir DIR   Target directory for Claude skills (default: ~/.claude/skills)"
    echo "  --agents-dir DIR   Target directory for Claude agents (default: ~/.claude/agents)"
    echo "  --yes              Apply all changes without prompting"
    echo "  --dry-run          Show what would change without applying"
    echo "  --help             Show this help message"
}

CLAUDE_DIR=~/.claude
SKILLS_DIR=""
AGENTS_DIR=""
AUTO_YES=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --claude-dir) CLAUDE_DIR="$2"; shift 2 ;;
        --skills-dir) SKILLS_DIR="$2"; shift 2 ;;
        --agents-dir) AGENTS_DIR="$2"; shift 2 ;;
        --yes)        AUTO_YES=true; shift ;;
        --dry-run)    DRY_RUN=true; shift ;;
        --help)       usage; exit 0 ;;
        *)            echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
done

if [[ -z "$SKILLS_DIR" ]]; then
    SKILLS_DIR="$CLAUDE_DIR/skills"
fi
if [[ -z "$AGENTS_DIR" ]]; then
    AGENTS_DIR="$CLAUDE_DIR/agents"
fi

APPLIED=0
SKIPPED=0

# Backup directory (timestamped)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

backup_file() {
    local file="$1"
    [[ ! -f "$file" ]] && return
    local rel="${file#"$HOME"/}"
    local backup_path="$BACKUP_DIR/$rel"
    mkdir -p "$(dirname "$backup_path")"
    cp "$file" "$backup_path"
}

# Map: repo path -> system path
declare -a FILE_PAIRS=(
    ".zshrc|$HOME/.zshrc"
    ".bashrc|$HOME/.bashrc"
    ".bash_aliases|$HOME/.bash_aliases"
    ".gitconfig|$HOME/.gitconfig"
    ".vimrc|$HOME/.vimrc"
    "nvim/init.lua|$HOME/.config/nvim/init.lua"
    ".tmux.conf|$HOME/.tmux.conf"
    "ghostty/config|$HOME/.config/ghostty/config"
    "zellij/config.kdl|$HOME/.config/zellij/config.kdl"
    "cursor/settings.json|$HOME/Library/Application Support/Cursor/User/settings.json"
)

# Collect files that differ
declare -a CHANGED_SRC=()
declare -a CHANGED_DST=()
declare -a NEW_SRC=()
declare -a NEW_DST=()

for pair in "${FILE_PAIRS[@]}"; do
    src="$DOTFILES_DIR/${pair%%|*}"
    dst="${pair#*|}"

    [[ ! -f "$src" ]] && continue

    if [[ ! -f "$dst" ]]; then
        NEW_SRC+=("$src")
        NEW_DST+=("$dst")
    elif ! diff -q "$src" "$dst" &>/dev/null; then
        CHANGED_SRC+=("$src")
        CHANGED_DST+=("$dst")
    fi
done

# Collect changed skills
declare -a SKILL_CHANGED_SRC=()
declare -a SKILL_CHANGED_NAME=()

if [[ -d "$DOTFILES_DIR/skills" ]]; then
    while IFS= read -r skill_md; do
        skill_root="$(dirname "$skill_md")"
        skill_name="${skill_root#"$DOTFILES_DIR/skills"/}"
        target="$SKILLS_DIR/$skill_name"

        if [[ ! -d "$target" ]]; then
            SKILL_CHANGED_SRC+=("$skill_root")
            SKILL_CHANGED_NAME+=("$skill_name [new]")
        elif ! diff -rq "$skill_root" "$target" &>/dev/null; then
            SKILL_CHANGED_SRC+=("$skill_root")
            SKILL_CHANGED_NAME+=("$skill_name [changed]")
        fi
    done < <(find "$DOTFILES_DIR/skills" -name "SKILL.md" -type f)
fi

# Collect changed agents
declare -a AGENT_CHANGED_SRC=()
declare -a AGENT_CHANGED_NAME=()
declare -a AGENT_FILE_CHANGED_SRC=()
declare -a AGENT_FILE_CHANGED_DST=()
declare -a AGENT_FILE_CHANGED_NAME=()

if [[ -d "$DOTFILES_DIR/agents" ]]; then
    while IFS= read -r agent_md; do
        agent_root="$(dirname "$agent_md")"
        agent_name="${agent_root#"$DOTFILES_DIR/agents"/}"
        target="$AGENTS_DIR/$agent_name"

        if [[ ! -d "$target" ]]; then
            AGENT_CHANGED_SRC+=("$agent_root")
            AGENT_CHANGED_NAME+=("$agent_name [new]")
        elif ! diff -rq "$agent_root" "$target" &>/dev/null; then
            AGENT_CHANGED_SRC+=("$agent_root")
            AGENT_CHANGED_NAME+=("$agent_name [changed]")
        fi
    done < <(find "$DOTFILES_DIR/agents" -name "AGENT.md" -type f)

    while IFS= read -r agent_file; do
        rel_path="${agent_file#"$DOTFILES_DIR/agents"/}"
        target="$AGENTS_DIR/$rel_path"

        if [[ ! -f "$target" ]]; then
            AGENT_FILE_CHANGED_SRC+=("$agent_file")
            AGENT_FILE_CHANGED_DST+=("$target")
            AGENT_FILE_CHANGED_NAME+=("$rel_path [new]")
        elif ! diff -q "$agent_file" "$target" &>/dev/null; then
            AGENT_FILE_CHANGED_SRC+=("$agent_file")
            AGENT_FILE_CHANGED_DST+=("$target")
            AGENT_FILE_CHANGED_NAME+=("$rel_path [changed]")
        fi
    done < <(find "$DOTFILES_DIR/agents" -name "*.md" -type f ! -name "AGENT.md")
fi

# Summary
total=$(( ${#CHANGED_SRC[@]} + ${#NEW_SRC[@]} + ${#SKILL_CHANGED_SRC[@]} + ${#AGENT_CHANGED_SRC[@]} + ${#AGENT_FILE_CHANGED_SRC[@]} ))
if [[ $total -eq 0 ]]; then
    echo "All dotfiles are up to date."
    exit 0
fi

echo "Files to install:"
for i in "${!CHANGED_SRC[@]}"; do
    echo "  [changed] ${CHANGED_DST[$i]}"
done
for i in "${!NEW_SRC[@]}"; do
    echo "  [new]     ${NEW_DST[$i]}"
done
for i in "${!SKILL_CHANGED_NAME[@]}"; do
    echo "  [skill]   ${SKILL_CHANGED_NAME[$i]}"
done
for i in "${!AGENT_CHANGED_NAME[@]}"; do
    echo "  [agent]   ${AGENT_CHANGED_NAME[$i]}"
done
for i in "${!AGENT_FILE_CHANGED_NAME[@]}"; do
    echo "  [agent]   ${AGENT_FILE_CHANGED_NAME[$i]}"
done
echo ""

if [[ "$DRY_RUN" == false && "$AUTO_YES" == false ]]; then
    read -rp "Proceed? [y/N] " answer
    case "$answer" in
        [yY]|[yY][eE][sS]) ;;
        *) echo "Aborted."; exit 0 ;;
    esac
    echo ""
fi

BACKED_UP=false

ensure_backup_dir() {
    if [[ "$BACKED_UP" == false ]]; then
        mkdir -p "$BACKUP_DIR"
        BACKED_UP=true
    fi
}

# Process changed files (show diff, ask to replace)
for i in "${!CHANGED_SRC[@]}"; do
    src="${CHANGED_SRC[$i]}"
    dst="${CHANGED_DST[$i]}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $dst"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    diff --color=auto -u "$dst" "$src" || true
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        echo "  (dry-run) would replace"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    if [[ "$AUTO_YES" == true ]]; then
        apply=true
    else
        read -rp "  Replace? [y/N] " answer
        case "$answer" in
            [yY]|[yY][eE][sS]) apply=true ;;
            *) apply=false ;;
        esac
    fi

    if [[ "$apply" == true ]]; then
        ensure_backup_dir
        backup_file "$dst"
        cp "$src" "$dst"
        echo "  -> applied (backup: $BACKUP_DIR)"
        APPLIED=$((APPLIED + 1))
    else
        echo "  -> skipped"
        SKIPPED=$((SKIPPED + 1))
    fi
    echo ""
done

# Process new files (no diff to show, just confirm)
for i in "${!NEW_SRC[@]}"; do
    src="${NEW_SRC[$i]}"
    dst="${NEW_DST[$i]}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  [new] $dst"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [[ "$DRY_RUN" == true ]]; then
        echo "  (dry-run) would create"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    if [[ "$AUTO_YES" == true ]]; then
        apply=true
    else
        read -rp "  Create? [y/N] " answer
        case "$answer" in
            [yY]|[yY][eE][sS]) apply=true ;;
            *) apply=false ;;
        esac
    fi

    if [[ "$apply" == true ]]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo "  -> created"
        APPLIED=$((APPLIED + 1))
    else
        echo "  -> skipped"
        SKIPPED=$((SKIPPED + 1))
    fi
    echo ""
done

# Skills (with diff/confirm)
for i in "${!SKILL_CHANGED_SRC[@]}"; do
    skill_root="${SKILL_CHANGED_SRC[$i]}"
    skill_name="${SKILL_CHANGED_NAME[$i]}"
    target="$SKILLS_DIR/${skill_name%% \[*\]}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  [skill] $skill_name -> $target"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ -d "$target" ]]; then
        diff --color=auto -ru "$target" "$skill_root" || true
    else
        echo "  (new skill, no diff)"
    fi
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        echo "  (dry-run) would install skill"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    if [[ "$AUTO_YES" == true ]]; then
        apply=true
    else
        read -rp "  Install? [y/N] " answer
        case "$answer" in
            [yY]|[yY][eE][sS]) apply=true ;;
            *) apply=false ;;
        esac
    fi

    if [[ "$apply" == true ]]; then
        if [[ -d "$target" ]]; then
            ensure_backup_dir
            mkdir -p "$BACKUP_DIR/skills"
            cp -R "$target" "$BACKUP_DIR/skills/"
        fi
        mkdir -p "$target"
        cp -R "$skill_root/" "$target/"
        echo "  -> installed"
        APPLIED=$((APPLIED + 1))
    else
        echo "  -> skipped"
        SKIPPED=$((SKIPPED + 1))
    fi
    echo ""
done

# Agents (with diff/confirm)
for i in "${!AGENT_CHANGED_SRC[@]}"; do
    agent_root="${AGENT_CHANGED_SRC[$i]}"
    agent_name="${AGENT_CHANGED_NAME[$i]}"
    target="$AGENTS_DIR/${agent_name%% \[*\]}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  [agent] $agent_name -> $target"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ -d "$target" ]]; then
        diff --color=auto -ru "$target" "$agent_root" || true
    else
        echo "  (new agent, no diff)"
    fi
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        echo "  (dry-run) would install agent"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    if [[ "$AUTO_YES" == true ]]; then
        apply=true
    else
        read -rp "  Install? [y/N] " answer
        case "$answer" in
            [yY]|[yY][eE][sS]) apply=true ;;
            *) apply=false ;;
        esac
    fi

    if [[ "$apply" == true ]]; then
        if [[ -d "$target" ]]; then
            ensure_backup_dir
            mkdir -p "$BACKUP_DIR/agents"
            cp -R "$target" "$BACKUP_DIR/agents/"
        fi
        mkdir -p "$target"
        cp -R "$agent_root/" "$target/"
        echo "  -> installed"
        APPLIED=$((APPLIED + 1))
    else
        echo "  -> skipped"
        SKIPPED=$((SKIPPED + 1))
    fi
    echo ""
done

# Agent files (with diff/confirm)
for i in "${!AGENT_FILE_CHANGED_SRC[@]}"; do
    src="${AGENT_FILE_CHANGED_SRC[$i]}"
    dst="${AGENT_FILE_CHANGED_DST[$i]}"
    name="${AGENT_FILE_CHANGED_NAME[$i]}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  [agent] $name -> $dst"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ -f "$dst" ]]; then
        diff --color=auto -u "$dst" "$src" || true
    else
        echo "  (new agent file, no diff)"
    fi
    echo ""

    if [[ "$DRY_RUN" == true ]]; then
        echo "  (dry-run) would install agent"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    if [[ "$AUTO_YES" == true ]]; then
        apply=true
    else
        read -rp "  Install? [y/N] " answer
        case "$answer" in
            [yY]|[yY][eE][sS]) apply=true ;;
            *) apply=false ;;
        esac
    fi

    if [[ "$apply" == true ]]; then
        mkdir -p "$(dirname "$dst")"
        if [[ -f "$dst" ]]; then
            ensure_backup_dir
        fi
        backup_file "$dst"
        cp "$src" "$dst"
        echo "  -> installed"
        APPLIED=$((APPLIED + 1))
    else
        echo "  -> skipped"
        SKIPPED=$((SKIPPED + 1))
    fi
    echo ""
done

echo "Done. $APPLIED applied, $SKIPPED skipped."
if [[ "$BACKED_UP" == true ]]; then
    echo "Backups saved to: $BACKUP_DIR"
fi
