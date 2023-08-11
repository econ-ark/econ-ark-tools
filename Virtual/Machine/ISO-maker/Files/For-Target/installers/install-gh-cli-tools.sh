#!/bin/bash

[[ -e /var/local/status/verbose ]] && set -x && set -v 

# 20230711: 
# From https://github.com/cli/cli/blob/trunk/docs/install_linux.md 
# Install gh github command line tools 

# Get curl if not already present 
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)

# Get keyring
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg 
if [[ "$?" == 0 ]]; then  # curl command succeeded
    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt -y install gh
else
    echo "WARNING: failed to install gh; \ntry rerunning with \n/var/local/installers/install-gh-cli-tools.sh" >> About_This_Install/XUBUNTARK-body.md
fi

