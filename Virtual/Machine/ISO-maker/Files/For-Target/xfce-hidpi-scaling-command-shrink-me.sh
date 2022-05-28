#!/bin/bash
# Google xfce-hidpi-scaling-command.sh
# normal scaling
# normal scaling
xfconf-query --channel xsettings --property /Gdk/WindowScalingFactor --set 1 && xfconf-query --channel xfwm4 --property /general/theme --set Default && xfconf-query --channel xsettings --property /Gtk/CursorThemeSize --set 16 && xfce4-panel -r

