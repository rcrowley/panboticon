set -e -x

TMP="$(mktemp)"
trap "rm -f \"$TMP\"" EXIT

sudo apt-get -y install "nvme-cli"
sudo nvme list -o "json" |
jq -r '.Devices[] | select(.ModelNumber == "Amazon EC2 NVMe Instance Storage") | .DevicePath' >"$TMP"
RAID_DEVICES="$(wc -l "$TMP" | cut -d " " -f 1)"
if [ "$RAID_DEVICES" -eq 0 ]
then exit
fi

if [ ! -b "/dev/md0" ]
then
    sudo xargs mdadm --create "/dev/md0" --chunk 16 --force --level 0 --raid-devices "$RAID_DEVICES" <"$TMP"
    sudo mdadm --detail --scan | sudo tee -a "/etc/mdadm/mdadm.conf"
    sudo update-initramfs -u
    until sudo mdadm --detail "/dev/md0" | grep -q "State : clean"
    do
        sleep 2
        printf "." >&2
    done
fi

if [ ! -d "/mnt/instance-storage/lost+found" ]
then
    sudo mkfs.ext4 -C "16384" -O "bigalloc" -m 0 "/dev/md0"
    MOUNT="$(systemd-escape --path "/mnt/instance-storage" --suffix "mount")"
    sudo mkdir -p "/mnt/instance-storage"
    sudo tee "/etc/systemd/system/$MOUNT" <<EOF
[Unit]
DefaultDependencies=no
Description=/mnt/instance-storage
[Mount]
What=/dev/md0
Where=/mnt/instance-storage
Type=ext4
Options=defaults,discard,noatime,nobarrier
[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable --now "$MOUNT"
fi
