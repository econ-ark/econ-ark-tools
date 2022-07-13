#!/bin/bash

[[ -e /var/local/status/verbose ]] && set -x && set -v 

# Install gh github command line tools 
curl -SL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
if [[ "$?" == 0 ]]; then  # command succeeded
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt -y install gh
else
    echo "WARNING: failed to install gh; \ntry rerunning with \n/var/local/installers/install-gh-cli-tools.sh" >> About_This_Install/XUBUNTARK-body.md
fi

