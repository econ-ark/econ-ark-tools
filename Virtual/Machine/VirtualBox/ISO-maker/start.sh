#!/bin/bash
scriptDir="$(dirname "`realpath $0`")"
cd "$scriptDir"
myuser="econ-ark"
start="start_modified-for-$myuser.sh"
rm "$start"
touch "$start"
sudo chmod a+xw "$start"

echo '#!/bin/bash' > "$start"

echo '# Autostart terminal upon autologin so that ~/.bash_alias will be executed automatically' >> "$start"
cat "$scriptDir/xfce4-terminal_autostart.sh"  | fgrep -v "#!/bin/bash" >> "$start"

echo '# Set up vnc server so students can connect to instructor machine' >> "$start"
cat "$scriptDir/vncserver_default_password_setup.sh" | fgrep -v "#!/bin/bash"  >> "$start"

# Reset hostname; setup bashrc 
cat "$scriptDir/start_modified-for-econ-ark_start.sh" | fgrep -v "#!/bin/bash" >> "$start"

chmod a+x "$start"

