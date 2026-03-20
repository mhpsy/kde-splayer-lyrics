#!/bin/bash
set -e

PLASMOID_DIR="$HOME/.local/share/plasma/plasmoids/org.mhpsy.splayer.lyrics"

# Remove old version if exists
if [ -d "$PLASMOID_DIR" ]; then
    echo "Removing old installation..."
    rm -rf "$PLASMOID_DIR"
fi

# Copy files
echo "Installing plasmoid..."
mkdir -p "$PLASMOID_DIR"
cp -r contents metadata.json "$PLASMOID_DIR/"

echo "Installed to $PLASMOID_DIR"
echo ""
echo "To activate: Right-click panel → Add Widgets → Search 'SPlayer Lyrics'"
echo "To reload after changes: kquitapp6 plasmashell && kstart plasmashell"
