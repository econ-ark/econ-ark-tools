#!/bin/bash
# configure existing users

if [[ "$#" -ne 1 ]]; then
    echo 'usage: config-user userid'
fi

user="$1" # userid
user_dir=/home/$user && [[ "$user" == "root" ]] && user_dir=/root

# Configure emacs for non-root users (root configured by install-emacs)
[[ "$user" != "root" ]] && sudo -u $user /var/local/config/emacs-user.sh $user

# Let user control networks
sudo adduser $user netdev &>/dev/null

# Get to systemwide GitHub via ~/GitHub whoever you are
[[ ! -e $user_dir/GitHub ]] && ln -s /usr/local/share/data/GitHub $user_dir/GitHub

# Everything should be accessible to members of the econ-ark group
[[ "$user" != "root" ]] && chown -Rf $user:econ-ark $user_dir

# Remove linux automatically created directories like "Music" and "Pictures"
# if they exist
cd $user_dir
for d in Templates Music Pictures Videos Documents; do
    [[ -d "$d" ]] && rm -Rf "$d"
done

# If installer ISO exists, make that obvious to user
[[ ! -e $user_dir/installer ]] && [[ -e /installer ]] && [[ ! -s /installer ]] && ln -s /installer $user_dir/installer

# make "About_This" easy to find 
[[ ! -e $user_dir/About_This_Install ]] && ln -s /var/local/About_This_Install $user_dir/About_This_Install

# Add stuff to bash login script
bashadd=$user_dir/.bash_aliases
[[ -e "$bashadd" ]] && mv "$bashadd" "$bashadd""_orig_$(</var/local/status/build_time.txt)"
if [[ "$user" == "root" ]]; then
    ln -s /var/local/sys_root_dir/home/user_root/bash_aliases "$bashadd"
else
    ln -s /var/local/sys_root_dir/home/user_regular/bash_aliases "$bashadd"
fi

# Make ~/.bash_aliases be owned by the user instead of root
chmod a+x "$bashadd"
chown $user:$user "$bashadd" 

# Make Chrome the default
sudo -u $user xdg-settings set default-web-browser google-chrome.desktop

# Make sure that everything in the home user's path is owned by home user 
chown -Rf $user:$user $user_dir

if [[ ! "$user" == "root" ]]; then # never run latex as root
    # Configure latexmkrc: https://mg.readthedocs.io/latexmk.html
    ltxmkrc=$user_dir/.latekmkrc
    sudo echo "'"'$dvi_previewer = start xdvi -watchfile 1.5'"';" > "$ltxmkrc"
    sudo echo "'"'$ps_previewer = start gv --watch'"';" >> "$ltxmkrc"
    sudo echo "'"'$pdf_previewer = start evince'"';" >> "$ltxmkrc"
    sudo chmod a+rwx "$ltxmkrc"
fi

# If some version of conda is installed, init it for the user
[[ ! -z $(which conda) ]] && conda init bash
