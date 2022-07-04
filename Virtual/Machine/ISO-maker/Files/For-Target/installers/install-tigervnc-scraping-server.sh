#!/bin/bash
myuser=$USER
mypass="kra-noce"

# If a previous version exists, delete it
[[ -e /home/$myuser/.vnc ]] && rm -Rf /home/$myuser/.vnc  
mkdir -p /home/$myuser/.vnc

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
[[ "$USER" == "root" ]] && cd /root/.vnc || cd /home/$myuser/.vnc
echo '#!/bin/sh' > xstartup
echo '[[ ! -e .Xresources ]] && touch .Xresources' >> xstartup
echo "startxfce4 & " >> xstartup
chmod a+x xstartup
chown $myuser:$myuser xstartup

