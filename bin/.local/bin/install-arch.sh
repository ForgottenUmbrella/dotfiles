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
# TODO home partition

# Encryption (LVM on LUKS)
cryptsetup luksFormat --type luks2 "/dev/$disk$root_partnum"
cryptsetup open "/dev/$disk$root_partnum" luks
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate --size "$(awk '/MemTotal/ {print $2}' /proc/meminfo)"K vg0 --name swap
mkswap /dev/vg0/swap
lvcreate --size 100%FREE vg0 --name root
mkfs.ext4 /dev/vg0/root
# TODO encrypt boot

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
pacstrap /mnt base linux linux-firmware base-devel pkgstats efibootmgr grub nftables \
         fish git fwupd man-db man-pages zsh zsh-autosuggestions zsh-syntax-highlighting \
         mlocate apparmor emacs \
         texinfo pulseaudio pulseaudio-bluetooth pulsemixer gnome-keyring \
         networkmanager cups nss-mdns gutenprint sane chrony pacman-contrib \
         ghostscript gsfonts foomatic-db-engine foomatic-db foomatic-db-ppds \
         foomatic-db-nonfree foomatic-db-nonfree-ppds foomatic-db-gutenprint-ppds \
         system-config-printer stow trash-cli xclip \
         i3-gaps picom dunst python-pywal xautolock playerctl \
         termite feh mpv kdeconnect skanlite zathura zathura-pdf-mupdf mpd ncmpcpp \
         lib32-mpg123 earlyoom
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
systemctl enable chronyd

# Networking
systemctl enable NetworkManager.service

# Locale
echo 'Uncomment the needed locales'
vim /etc/locale.gen
locale-gen
echo 'Set the LANG variable accordingly (e.g. en_US.UTF8)'
vim /etc/locale.conf
if [ "$keymap" != 'us' ]
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
sed --in-place \
    "s#^\(GRUB_CMDLINE_LINUX\)=\"\
#\1=\"/dev/$disk$root_partnum:root:allow-discards \
resume=/dev/$disk$root_partnum/swap#\"" /etc/default/grub
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

# AUR
git clone https://aur.archlinux.org/yay.git
pushd yay
su -- "$username" -c makepkg --syncdeps --install
popd

# Firewall
systemctl enable nftables.service

# Codecs
yay --sync codecs

# Printing
systemctl enable org.cups.cupsd.socket avahi-daemon.service
sed --in-place 's/resolve/mdns_minimal [NOTFOUND=return]/' /etc/nsswitch.conf

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
                pacman --sync nvidia lib32-nvidia-utils nvidia-utils nvidia-settings
                break
            else
                echo 'Invalid driver name'
            fi
        done
    else
        echo 'Invalid GPU brand'
    fi
done

# Security
sed --in-place \
    "s#^\(GRUB_CMDLINE_LINUX\)="\"\
    #\1=\"apparmor=1 security=apparmor\"" /etc/default/grub

    systemctl enable apparmor.service

# Personal apps and AUR TODO move all personals and optionals from pacstrap
yay --sync --refresh --sysupgrade keepassxc dropbox anki firefox-beta \
    wine-staging wine-nine wine-gecko wine-mono wpgtk-git mantablockscreen \
    rofi-lbonn-wayland-git rofi-dmenu btmenu keepmenu clerk-git polybar \
    noto-fonts-cjk tamsyn-font terminus-font-ttf ttf-symbola nerd-fonts-fira-mono \
    ttf-font-awesome ttf-ms-fonts \
    gammastep acpilight pulseaudio-ctl mpdris2 kunst-git xorg-xwininfo \
    ranger-git python-ueberzug dxvk-bin ashuffle kvantum-qt5 lxappearance

# Optimisations
systemctl enable fstrim.timer
systemctl enable earlyoom.service
# TODO install linux-zen if desktop not laptop
# TODO install tlp if laptop not desktop

# Program setup TODO

reboot
