#!/bin/bash
#
# [PlexGuide Menu]
#
# GitHub:   https://github.com/Admin9705/PlexGuide.com-The-Awesome-Plex-Server
# Author:   Admin9705 - Deiteq
# URL:      https://plexguide.com
#
# PlexGuide Copyright (C) 2018 PlexGuide.com
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################
export NCURSES_NO_UTF8_ACS=1

bash /opt/plexguide/menus/gce/gcechecker.sh

edition=$( cat /var/plexguide/pg.edition ) 1>/dev/null 2>&1
version=$( cat /var/plexguide/pg.version ) 1>/dev/null 2>&1

HEIGHT=18
WIDTH=40
CHOICE_HEIGHT=12
BACKTITLE="Visit PlexGuide.com - Automations Made Simple"
TITLE="$edition - $version"

OPTIONS=(A "Install RClone"
         B "Configure RCLONE"
         C "Deploy PG Drive"
         D "PG SuperTransfer2"
         E "PG Programs"
         F "PG Server NET Benchmarks"
         G "PG Trek"
         H "PG Troubleshooting Actions"
         I "PG Backup & Restore"
         J "PG Updates"
         K "PG Edition Switch"
         Z "Exit")

CHOICE=$(dialog --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)
case $CHOICE in
        A)
curl https://rclone.org/install.sh | sudo bash -s beta
sleep 1
dialog --title "RClone Status" --msgbox "\nThe LATEST RCLONE Beta is now Installed!" 0 0

# allows others to access fuse
tee "/etc/fuse.conf" > /dev/null <<EOF
# /etc/fuse.conf - Configuration file for Filesystem in Userspace (FUSE)
# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#mount_max = 1000
# Allow non-root users to specify the allow_other or allow_root mount options.
user_allow_other
EOF

            chown 1000:1000 /usr/bin/rclone 1>/dev/null 2>&1
            chmod 755 /usr/bin/rclone 1>/dev/null 2>&1
            ;;
        B)
            clear
            #### RClone Missing Warning - START
            file="/usr/bin/rclone" 1>/dev/null 2>&1
              if [ -e "$file" ]
                then
                  echo "" 1>/dev/null 2>&1
                else
                  dialog --title "WARNING!" --msgbox "\nYou Need to Install RClone First" 0 0
                  bash /opt/plexguide/menus/mount/main.sh
                  exit
              fi
            #### RClone Missing Warning - END
            rclone config
            touch /mnt/gdrive/plexguide/ 1>/dev/null 2>&1
            #### GREP Checks
            tdrive=$(grep "tdrive" /root/.config/rclone/rclone.conf)
            gdrive=$(grep "gdrive" /root/.config/rclone/rclone.conf)
            mkdir -p /root/.config/rclone/
            chown -R 1000:1000 /root/.config/rclone/
            cp ~/.config/rclone/rclone.conf /root/.config/rclone/ 1>/dev/null 2>&1
            ;;
        C)
            clear
            #### RClone Missing Warning
            file="/usr/bin/rclone" 1>/dev/null 2>&1
              if [ -e "$file" ]
                then
                  echo "" 1>/dev/null 2>&1
                else
                  dialog --title "WARNING!" --msgbox "\nYou Need to Install RClone First!" 0 0
                  bash /opt/plexguide/menus/pgdrive/main.sh
                  exit
              fi

            ansible-playbook /opt/plexguide/ansible/plexguide.yml --tags gce #1>/dev/null 2>&1
            dialog --title "NOTE" --msgbox "\nPG Drive Deployed!!" 0 0
            ;;
        D)    
        clear
        bash /opt/plexguide/scripts/supertransfer/config.sh
        ansible-playbook /opt/plexguide/ansible/plexguide.yml --tags supertransfer2
        journalctl -f -u supertransfer2
            ;;
        E)
            bash /opt/plexguide/menus/benchmark/main.sh ;;
        F)
            bash /opt/plexguide/menus/info-tshoot/info.sh ;;
        G)
            bash /opt/plexguide/menus/info-tshoot/tshoot.sh ;;

        H)
            bash /opt/plexguide/menus/backup-restore/main.sh ;;
        I)
            bash /opt/plexguide/scripts/upgrade/main.sh
            bash /opt/plexguide/scripts/message/ending.sh
            exit 0 ;;
        J)
            bash /opt/plexguide/scripts/baseinstall/edition.sh
            ;;
        Z)
            bash /opt/plexguide/scripts/message/ending.sh
            exit 0 ;;
esac

## repeat menu when exiting
bash /opt/plexguide/menus/gce.sh
