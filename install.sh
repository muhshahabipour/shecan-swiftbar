#!/bin/bash

set -e

INSTALL_DIR="$HOME/.shecan"
SWIFTBAR_PLUGINS="$HOME/Library/Application Support/SwiftBar/Plugins"

echo "Installing Shecan DNS Manager..."

# 1. Create install directory
mkdir -p "$INSTALL_DIR/icons"

# 2. Copy icons
cp -r icons/* "$INSTALL_DIR/icons/"

# 3. Copy action script
cp shecan-action.sh "$INSTALL_DIR/shecan-action.sh"
chmod +x "$INSTALL_DIR/shecan-action.sh"

# 4. Install shecan CLI to /usr/local/bin
sed "s|__INSTALL_DIR__|$INSTALL_DIR|g" shecan > /tmp/shecan_install
sudo cp /tmp/shecan_install /usr/local/bin/shecan
sudo chmod +x /usr/local/bin/shecan
rm /tmp/shecan_install
echo "✅ shecan CLI installed to /usr/local/bin/shecan"

# 5. Install SwiftBar plugin
if [ -d "$SWIFTBAR_PLUGINS" ]; then
  sed "s|__INSTALL_DIR__|$INSTALL_DIR|g" shecan.10s.sh > "$SWIFTBAR_PLUGINS/shecan.10s.sh"
  chmod +x "$SWIFTBAR_PLUGINS/shecan.10s.sh"
  echo "✅ SwiftBar plugin installed"
else
  echo "⚠️  SwiftBar not found. Install SwiftBar and run this script again."
  echo "    Or manually copy shecan.10s.sh to your SwiftBar plugins directory."
fi

# 6. sudoers entry for networksetup (no password prompt)
SUDOERS_LINE="%admin ALL=(ALL) NOPASSWD: /usr/sbin/networksetup"
if ! sudo grep -q "networksetup" /etc/sudoers 2>/dev/null; then
  echo "$SUDOERS_LINE" | sudo tee -a /etc/sudoers > /dev/null
  echo "✅ sudoers updated (no password for networksetup)"
fi

# 7. DDNS password (optional)
echo ""
read -p "Enter your Shecan DDNS password (leave empty to skip): " DDNS_PASS
if [ -n "$DDNS_PASS" ]; then
  echo "DDNS_PASSWORD=$DDNS_PASS" > "$HOME/.shecan_config"
  chmod 600 "$HOME/.shecan_config"
  echo "✅ DDNS password saved to ~/.shecan_config"
fi

echo ""
echo "✅ Installation complete!"
echo "   Refresh SwiftBar to see the Shecan icon in your menu bar."
