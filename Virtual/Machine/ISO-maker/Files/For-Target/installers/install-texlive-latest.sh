#!/bin/bash

# Exit on any error
set -e

# Update system
sudo apt update

# Install required dependencies
sudo apt install -y wget perl

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download the TeX Live installer
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz

# Extract the installer
tar -xzf install-tl-unx.tar.gz

# Change to the extracted directory
pwd
read answer

cd install-tl-2*

# Create a configuration file for non-interactive installation
cat <<EOF
 EOF > texlive.profile
selected_scheme scheme-small
TEXDIR /usr/local/texlive/2024
TEXMFCONFIG ~/.texlive2024/texmf-config
TEXMFHOME ~/texmf
TEXMFLOCAL /usr/local/texlive/texmf-local
TEXMFSYSCONFIG /usr/local/texlive/2024/texmf-config
TEXMFSYSVAR /usr/local/texlive/2024/texmf-var
TEXMFVAR ~/.texlive2024/texmf-var
binary_x86_64-linux 1
instopt_adjustpath 0
instopt_adjustrepo 1
instopt_letter 0
instopt_portable 0
instopt_write18_restricted 1
tlpdbopt_autobackup 1
tlpdbopt_backupdir tlpkg/backups
tlpdbopt_create_formats 1
tlpdbopt_desktop_integration 1
tlpdbopt_file_assocs 1
tlpdbopt_generate_updmap 0
tlpdbopt_install_docfiles 1
tlpdbopt_install_srcfiles 1
tlpdbopt_post_code 1
tlpdbopt_sys_bin /usr/local/bin
tlpdbopt_sys_info /usr/local/share/info
tlpdbopt_sys_man /usr/local/share/man
tlpdbopt_w32_multi_user 1
EOF

# Run the installer non-interactively
sudo ./install-tl --profile=texlive.profile

# Add TeX Live to PATH
echo 'export PATH="/usr/local/texlive/2024/bin/x86_64-linux:$PATH"' >> ~/.bashrc
echo 'export MANPATH="/usr/local/texlive/2024/texmf-dist/doc/man:$MANPATH"' >> ~/.bashrc
echo 'export INFOPATH="/usr/local/texlive/2024/texmf-dist/doc/info:$INFOPATH"' >> ~/.bashrc

# Source the updated .bashrc
source ~/.bashrc

# Clean up
cd
rm -rf "$TEMP_DIR"

echo "TeX Live installation complete. Please restart your terminal or run 'source ~/.bashrc' to update your PATH."

EOF
