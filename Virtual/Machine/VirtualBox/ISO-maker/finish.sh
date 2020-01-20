#!/bin/bash
scriptDir="$(dirname "`realpath $0`")"
cd "$scriptDir"
echo ''
myuser="econ-ark"
finish="finish_modified-for-$myuser.sh"
rm "$finish"
touch "$finish"
sudo chmod a+xw "$finish"

echo '#!/bin/bash' > "$finish"

echo '# Update everything ' >> "$finish"
echo 'sudo apt -y update && sudo apt -y upgrade' >> "$finish"
cat ~/GitHub/ccarrollATjhuecon/Methods/Tools/Install/Languages/Anaconda3-Latest.sh | fgrep -v "!/bin/bash"        >> "$finish"
echo '# Get default packages for Econ-ARK machine' >> "$finish"
echo 'sudo apt -y install git bash-completion xsel cifs-utils openssh-server nautilus-share xclip texlive-full emacs auctex' >> "$finish"

cat ~/GitHub/ccarrollATjhuecon/Methods/Tools/Install/Toolkits/ARK.sh                        | fgrep -v "!/bin/bash"  >> "$finish"
cat ~/GitHub/ccarrollATjhuecon/Methods/Tools/Install/Packages/VirtualBox-Guest-Additions.sh | fgrep -v "!/bin/bash" >> "$finish"
echo "mkdir -p /home/$myuser/GitHub/econ-ark ; ln -s /usr/local/share/GitHub/econ-ark /home/$myuser/GitHub/econ-ark" >> "$finish" 
echo "chown -Rf $myuser:$myuser /usr/local/share/GitHub/econ-ark # Make it be owned by econ-ark user " >> "$finish" 

echo ''                                               >> "$finish" 
echo 'echo Finished automatic installations.  Rebooting.'  >> "$finish" 
echo 'reboot ' >> "$finish" 

chmod a+x "$finish"


