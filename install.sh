#!/bin/bash

# 1. Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please, run script as root, i cannot change theme without that (hint, sudo ./install.sh)"
  exit 1
fi

# Define theme's name
THEME_NAME="portal-2-theme"
THEME_DIR="/boot/grub/themes/$THEME_NAME"

echo "Starting instalation for: $THEME_NAME..."

# 2. Create GRUB theme things if doesn't exists atp
mkdir -p /boot/grub/themes

# 3. Copy files to system dir
echo "Copying files to $THEME_DIR..."
# If theme alr exists (update), get the fuhh out of here
rm -rf "$THEME_DIR" 
cp -a "$THEME_NAME" "$THEME_DIR"

# 4. Modify GRUB's config
echo "Configurating /etc/default/grub..."
# Deleting the GRUB_THEME thing so i can just paste it below without any problems
sed -i '/^GRUB_THEME=/d' /etc/default/grub
# Adds the route of the new theme
echo "GRUB_THEME=\"$THEME_DIR/theme.txt\"" >> /etc/default/grub

# 5. Update GRUB (why it cannot be the same for all?)
echo "Updating grub..."
if command -v update-grub &> /dev/null; then
    update-grub # For Debian, Ubuntu, Linux Mint
elif command -v grub-mkconfig &> /dev/null; then
    grub-mkconfig -o /boot/grub/grub.cfg # For Arch Linux
elif command -v grub2-mkconfig &> /dev/null; then
    grub2-mkconfig -o /boot/grub2/grub.cfg # For Fedora, CentOS
else
    echo "WARN: Script couldn't update GRUB automatically."
    echo "Please, update GRUB manually and ur done."
    exit 1
fi

echo "Instalation complete!"
