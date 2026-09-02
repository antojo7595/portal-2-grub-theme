#!/bin/bash

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run script as root, I cannot change the theme without that (hint: sudo ./install.sh)"
  exit 1
fi

# Define theme's name
THEME_NAME="portal-2-theme"
THEME_DIR="/boot/grub/themes/$THEME_NAME"

# Verify source directory exists before proceeding
if [ ! -d "$THEME_NAME" ]; then
  echo "Error: Directory '$THEME_NAME' not found in current path."
  echo "Make sure you are running this script from the correct folder."
  exit 1
fi

echo "Starting installation for: $THEME_NAME..."

# Create GRUB theme directory if it doesn't exist
mkdir -p /boot/grub/themes

# Copy files to system dir
echo "Copying files to $THEME_DIR..."
# If theme already exists (update), remove it first
rm -rf "$THEME_DIR"
cp -a "$THEME_NAME" "$THEME_DIR"

# Verify theme.txt was actually copied
if [ ! -f "$THEME_DIR/theme.txt" ]; then
  echo "Error: theme.txt not found in $THEME_DIR. Installation aborted."
  exit 1
fi

# Modify GRUB's config
echo "Configuring /etc/default/grub..."
# Check if grub default config exists
if [ -f /etc/default/grub ]; then
  # Deleting the GRUB_THEME line so we can paste it below without duplicates
  sed -i '/^GRUB_THEME=/d' /etc/default/grub
  # Ngl this may be useful for someone... probably
  sed -i 's/^GRUB_TERMINAL_OUTPUT="console"/#GRUB_TERMINAL_OUTPUT="console"/' /etc/default/grub
  # Adds the route of the new theme
  echo -e "\nGRUB_THEME=\"$THEME_DIR/theme.txt\"" >> /etc/default/grub
else
  echo "Error: /etc/default/grub not found."
  exit 1
fi

# Update GRUB
echo "Updating GRUB..."
if command -v update-grub &>/dev/null; then
  update-grub # For Debian, Ubuntu, Linux Mint
elif command -v grub-mkconfig &>/dev/null; then
  grub-mkconfig -o /boot/grub/grub.cfg # For Arch Linux
elif command -v grub2-mkconfig &>/dev/null; then
  grub2-mkconfig -o /boot/grub2/grub.cfg # For Fedora, CentOS
else
  echo "WARN: Script couldn't update GRUB automatically."
  echo "Please, update GRUB manually and you're done."
  exit 1
fi

echo "Installation completed! Now you can delete this directory."
