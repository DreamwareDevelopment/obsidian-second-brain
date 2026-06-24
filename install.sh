#!/bin/bash

set -e

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SKILLS_DIR="$CLAUDE_DIR/skills"

echo "Installing obsidian-second-brain..."

# Create directories if needed
mkdir -p "$COMMANDS_DIR"
mkdir -p "$SKILLS_DIR"

# Detect platform once
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=1 ;;
  *) IS_WINDOWS=0 ;;
esac

# Link commands into ~/.claude/commands/ (copy on Windows without Developer Mode)
echo "Installing slash commands..."
COMMANDS_COPIED=0
for file in "$SKILL_DIR/commands/"*.md; do
  name=$(basename "$file")
  dest="$COMMANDS_DIR/$name"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "  skipping $name (already exists)"
  elif [ "$IS_WINDOWS" -eq 0 ]; then
    ln -s "$file" "$dest"
    echo "  linked $name"
  elif MSYS=winsymlinks:nativestrict ln -s "$file" "$dest" 2>/dev/null; then
    echo "  linked $name"
  else
    cp "$file" "$dest"
    COMMANDS_COPIED=1
    echo "  installed $name"
  fi
done
if [ "$COMMANDS_COPIED" -eq 1 ]; then
  echo "  (symlinks require Developer Mode - commands were copied; run update.sh to refresh)"
fi

# Link skill into ~/.claude/skills/
SKILL_LINK="$SKILLS_DIR/obsidian-second-brain"
if [ -e "$SKILL_LINK" ]; then
  echo "Skill already linked at $SKILL_LINK"
elif [ "$IS_WINDOWS" -eq 0 ]; then
  ln -s "$SKILL_DIR" "$SKILL_LINK"
  echo "Skill linked at $SKILL_LINK"
else
  if MSYS=winsymlinks:nativestrict ln -s "$SKILL_DIR" "$SKILL_LINK" 2>/dev/null; then
    echo "Skill linked at $SKILL_LINK"
  else
    echo "Symlink failed (requires Developer Mode). For the cleanest setup,"
    echo "clone the repo directly into the skills folder:"
    echo "  git clone https://github.com/eugeniughelbur/obsidian-second-brain ~/.claude/skills/obsidian-second-brain"
    echo "Then re-run install.sh from that location."
  fi
fi

echo ""
echo "Done. Restart Claude Code to activate the commands."
echo ""
echo "Next steps:"
echo "  1. Run /obsidian-init to generate your vault's _CLAUDE.md"
