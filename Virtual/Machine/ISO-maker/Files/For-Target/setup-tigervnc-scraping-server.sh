#!/bin/bash
myuser=$USER
# scraping server means that you're not allowing vnc client to spawn new x sessions
sudo apt -y install tigervnc-scraping-server

# Allow interactive commands to be preseeded
sudo apt -y install expect

# If a previous version exists, delete it
[[ -e /home/$myuser/.vnc ]] && rm -Rf /home/$myuser/.vnc  
sudo -u $myuser mkdir -p /home/$myuser/.vnc

# https://askubuntu.com/questions/328240/assign-vnc-password-using-script
prog=/usr/bin/vncpasswd
sudo -u "$myuser" /usr/bin/expect <<EOF
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

# Enable xrdp server on startup
cd /home/$myuser/.vnc
echo '#!/bin/sh' > xstartup
echo 'xrdp $HOME/.Xresources' >> xstartup
echo "startxfce4 & " >> xstartup
sudo chmod a+x xstartup
sudo chown $myuser:$myuser xstartup

# If x0vncserver not running 
pgrep x0vncserver > /dev/null # Silence it
# "$?" -eq 1 implies that no such process exists, in which case it should be started
[[ $? -eq 1 ]] && (x0vncserver -display :0 -PasswordFile=/home/"$myuser"/.vnc/passwd &> /dev/null &)

