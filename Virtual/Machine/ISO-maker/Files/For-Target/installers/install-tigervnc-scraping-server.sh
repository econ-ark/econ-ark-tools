#!/bin/bash

myuser=$1
mypass="kra-noce"

# https://askubuntu.com/questions/328240/assign-vnc-password-using-script
prog=/usr/bin/vncpasswd
/usr/bin/expect <<EOF
spawn "$prog"
expect "Password:"
send "$mypass\r"
expect "Verify:"
send "$mypass\r"
expect "Would you like to enter a view-only password (y/n)?"
send "y\r"
expect "Password:"
send "$myuser-watch\r"
expect "Verify:"
send "$myuser-watch\r"
expect eof
exit
EOF

# Enable xfce4 startup on vnc
# $USER will be root if the script is run with sudo (as in start.sh)
if [[ "$USER" == "root" ]]; then
    cd /root/.vnc
    ln -s /root/.vnc /home/$myuser/.vnc
else
    cd /home/$myuser/.vnc
fi

echo '#!/bin/sh' > xstartup
echo '[[ ! -e .Xresources ]] && touch .Xresources' >> xstartup
echo "startxfce4 & " >> xstartup
chmod a+x xstartup
chown $myuser:$myuser xstartup

