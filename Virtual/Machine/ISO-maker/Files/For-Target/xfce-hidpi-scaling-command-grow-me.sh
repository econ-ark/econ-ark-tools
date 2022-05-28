#!/bin/bash
# Google xfce-hidpi-scaling-command.sh
# Run this with bash -u so it will get the environment variables
# 2 times scaling

xfconf-query --channel xsettings --property /Gdk/WindowScalingFactor --set 2 && xfconf-query --channel xfwm4 --property /general/theme --set Default-xhdpi && xfconf-query --channel xsettings --property /Gtk/CursorThemeSize --set 48 && xfce4-panel -r
