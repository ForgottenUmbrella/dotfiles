#!/bin/bash
# Install Arch Linux as the only OS
set -o nounset
set -o errexit

# Keyboard
while true
do
    read -e -p 'Keymap: ' -i 'us' -r keymap
    if find /usr/share/kbd/keymaps "*$keymap*"
    then
        break
    else
        echo 'Invalid keymap'
    fi
done
if [ "$keymap" = 'us' ]
then
    is_default_keymap=true
else
    is_default_keymap=false
fi
loadkeys "$keymap"

# Networking
ping archlinux.org || wifi-menu

# Time
timedatectl set-ntp true

# Encryption preparation
lsblk
echo 'Ensure the computer is connected to a stable power source'
while true
do
    read -e -p 'SSD to be encrypted (sdX): ' -i 'sda' -r disk
    if [ -b "/dev/$disk" ]
    then
        break
    else
        echo 'Invalid disk name'
    fi
done
cryptsetup open --type plain --key-file /dev/urandom "/dev/$disk" to_be_wiped
dd if=/dev/zero of/dev/mapper/to_be_wiped status=progress bs=1M
cryptsetup close to_be_wiped

# Partitioning
if [ ! -d /sys/firmware/efi/efivars ]
then
    echo 'BIOS/MBR is unsupported'
    exit 1
fi
efi_partnum=1
boot_partnum=2
root_partnum=3
sgdisk --clear --new $efi_partnum:0:+100M --typecode $efi_partnum:ef00 "$disk"
mkfs.fat -F32 "/dev/$disk$efi_partnum"
sgdisk --new $boot_partnum:0:+200M --typecode $boot_partnum:8300 "$disk"
mkfs.ext2 "/dev/$disk$boot_partnum"
sgdisk --new "$root_partnum:0:$(sgdisk --end-of-largest "$disk")" \
    --typecode $root_partnum:8e00 "$disk"
mkfs.ext4 "/dev/$disk$root_partnum"

# Encryption (LVM on LUKS)
cryptsetup luksFormat --type luks2 "/dev/$disk$root_partnum"
cryptsetup open "/dev/$disk$root_partnum" luks
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate --size "$(awk '/MemTotal/ {print $2}' /proc/meminfo)"K vg0 --name swap
mkswap /dev/vg0/swap
lvcreate --size 100%FREE vg0 --name root
mkfs.ext4 /dev/vg0/root

# Mounting
mount /dev/vg0/root /mnt
mkdir /mnt/boot
mount "/dev/$disk$boot_partnum" /mnt/boot
swapon /dev/vg0/swap

# Mirrors
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
while true
do
    read -e -p 'Country (proper case): ' -i 'Australia' -r country
    if grep /etc/pacman.d/mirrorlist.backup "^## $country$"
    then
        break
    else
        echo 'Invalid country name'
    fi
done
awk "/^## $country$/{f=1}f==0{next}/^$/{exit}{print substr(\$0, 2)}" \
    /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

# Base installation
pacstrap /mnt base base-devel pkgstats efibootmgr grub fish git iptables fwupd \
    xorg pulseaudio pulseaudio-bluetooth gnome-keyring networkmanager nm-connection-editor \
    cups sane stow trash-cli xsel \
    compton dunst rofi polybar python-pywal xautolock redshift \
    playerctl \
    termite feh mpv kdeconnect skanlite zathura zathura-pdf-mupdf mpd ncmpcpp \
    wine wine_gecko wine-mono
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

# Time
while true
do
    read -e -p 'City (proper case): ' -i 'Melbourne' -r city
    if [ -e "/usr/share/zoneinfo/$country/$city" ]
    then
        break
    else
        echo 'Invalid city name'
    fi
done
ln --symbolic --force "/usr/share/zoneinfo/$country/$city" /etc/localtime
hwclock --systohc
systemctl enable systemd-timesyncd

# Locale
echo 'Uncomment the needed locales'
vim /etc/locale.gen
locale-gen
echo 'Set the LANG variable accordingly (e.g. en_US.UTF8)'
vim /etc/locale.conf
if [ "$is_default_keymap" != true ]
then
    echo "KEYMAP=$keymap" >> /etc/vconsole.conf
    keymap_hook='keymap'
else
    keymap_hook=''
fi

# Hostname
hostname_regex='[a-z]+'
while true
do
    read -p "Hostname ($hostname_regex): " -r hostname
    if [[ "$hostname" =~ ^"$hostname_regex"$ ]]
    then
        break
    else
        echo 'Invalid hostname'
    fi
done
echo "$hostname" >> /etc/hostname
echo "127.0.1.1 $hostname.localdomain $hostname"

# Microcode
while true
do
    read -e -p 'CPU brand (intel or amd): ' -r cpu_brand
    if [ "$cpu_brand" = 'intel' ] || [ "$cpu_brand" = 'amd' ]
    then
        break
    else
        echo 'Invalid CPU brand'
    fi
done
pacman --sync "$cpu_brand-ucode"

# Bootloader
mount "/dev/$disk$efi_partnum" /efi
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
sed --in-place
    "s#^\(GRUB_CMDLINE_LINUX\)=.*\
#\1=/dev/$disk$root_partnum:root:allow-discards \
resume=/dev/$disk$root_partnum/swap#" /etc/default/grub
grub-mkconfig --output /boot/grub/grub.cfg

# Initial ramdisk
sed --in-place \
    "s/^\(HOOKS\).*/\1=(base udev autodetect keyboard $keymap_hook consolefont \
modconf block encrypt lvm2 resume filesystems fsck)" /etc/mkinitcpio.conf
mkinitcpio --preset linux

# Root
passwd

# Multilib
sed --in-place 's/^#\(\[multilib\]\)$/\1/' /etc/pacman.conf
sed --in-place '/^\[multilib\]$/{n;s/#//}' /etc/pacman.conf

# AUR
git clone https://aur.archlinux.org/yay.git
pushd yay
makepkg --syncdeps --install
popd

# Users
username_regex='[a-z_][a-z0-9_]{0,30}'
while true
do
    read -p "Username ($username_regex): " -r username
    if [[ "$username" =~ ^"$username_regex"$ ]]
    then
        break
    else
        echo 'Invalid username'
    fi
done
useradd --create-home "$username" --shell /bin/fish
passwd "$username"
usermod --append --gid wheel "$username"
sed --in-place 's/^#\(auth	required	pam_wheel.so use_sid\)$/\1/' /etc/pam.d/su
sed --in-place 's/^#\(auth	required	pam_wheel.so use_sid\)$/\1/' \
    /etc/pam.d/su-1

# Firewall
iptables --new-chain TCP
iptables --new-chain UDP
iptables --policy FORWARD DROP
iptables --policy OUTPUT ACCEPT
iptables --policy INPUT DROP
iptables --append INPUT --match conntrack --ctstate RELATED,ESTABLISHED \
    --jump ACCEPT
iptables --append INPUT --in-interface lo --jump ACCEPT
iptables --append INPUT --match conntrack --ctstate INVALID --jump DROP
iptables --append INPUT --protocol icmp --icmp-type 8 --match conntrack \
    --ctstate NEW --jump ACCEPT
iptables --append INPUT --protocol udp --match conntrack --ctstate NEW --jump UDP
iptables --append INPUT --protocol tcp --syn --match conntrack --ctstate NEW \
    --jump TCP
iptables --append INPUT --protocol udp --jump REJECT \
    --reject-with icmp-port-unreachable
iptables --append INPUT --protocol tcp --jump REJECT --reject-with tcp-reset
iptables --append INPUT --jump REJECT --reject-with icmp-proto-unreachable
iptables --append TCP --protocol tcp --dport 22 --jump ACCEPT
iptables --table raw --in-interface PREROUTING --match rpfilter --invert \
    --jump DROP
iptables-save > /etc/iptables/iptables.rules
systemctl enable iptables

# Codecs
yay --sync codecs

# Printing
systemctl enable org.cups.cupsd

# Graphics
while true
do
    read -p 'GPU brand (intel, amd or nvidia): ' -r gpu_brand
    if [ "$gpu_brand" = 'intel' ]
    then
        pacman --sync vulkan-intel lib32-mesa
        while true
        do
            read -p 'Newer than 8th gen (yes or no)? ' -r cannon_lake
            if [ "$cannon_lake" = 'yes' ]
            then
                pacman --sync intel-media-driver
                break
            elif [ "$cannon_lake" = 'no' ]
            then
                pacman --sync libva-intel-driver
                break
            else
                echo 'Invalid response'
            fi
        done
        break
    elif [ "$gpu_brand" = 'amd' ]
    then
        pacman --sync xf86-video-ati mesa-vdpau lib32-mesa libva-mesa-driver
        break
    elif [ "$gpu_brand" = 'nvidia' ]
    then
        while true
        do
            read -e -p 'Open source (nouveau) or proprietary (nvidia): ' \
                -i 'nouveau' -r nvidia_driver
            if [ "$nvidia_driver" = 'nouveau' ]
            then
                pacman --sync xf86-video-nouveau lib32-mesa libva-mesa-driver \
                    mesa-vdpau
                break
            elif [ "$nvidia_driver" = 'nvidia' ]
            then
                pacman --sync nvidia lib32-nvidia-utils nvidia-utils
                break
            else
                echo 'Invalid driver name'
            fi
        done
    else
        echo 'Invalid GPU brand'
    fi
done

# Personal apps and AUR
yay --sync --refresh --sysupgrade keepassxc dropbox gpmdp anki firefox-nightly \
    texlive-most emacs-lucid \
    i3-gaps wpgtk-git betterlockscreen \
    network-manager-dmenu-git btmenu keepmenu clerk-git \
    tamsyn-font terminus-font-ttf ttf-symbola nerd-fonts-fira-mono font-awesome ttf-ms-fonts noto-fonts-cjk \
    brillo playerctl pulseaudio-ctl mpdris2 mpd-notification ranger-git ueberzug
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

reboot
