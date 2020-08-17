# Version with nolapic in boot line
grub_base="$(sed -e ":a" -e "N" -e '$!ba' -e 's/\n/\\n/g' grub_base.cfg)"
cat grub_base.cfg grub_more.cfg > grub_full.cfg
grub_full="$(sed -e ":a" -e "N" -e '$!ba' -e 's/\n/\\n/g' grub_full.cfg)"

