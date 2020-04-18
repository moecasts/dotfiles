# Installation Guide

```bash
# Connect to the internet
## if you are using wifi, please run the following command
wifi-menu
## else
dhcpcd

# Update the system clock
timedatectl set-ntp true

# Partition the disks
## if your block device is nvme0n1
## follow the tips to partition the disk
cfdisk /dev/nvme0n1

## list the partition
fdisk -l

# Format the partitions
mkfs.ext4 /dev/nvme0n1pX

# Mount the file systems
mount /dev/nvme0n1pX /mnt
mkdir /mnt/boot

## nvme0n1pY is the EFI partition
mount /dev/nvme0n1pY /mnt/boot

# Select the mirrors
## write the mirrors you want at the top of the file
vim /etc/pacman.d/mirrorlist

# Install essential packages:qwq
pacstrap /mnt base base-devel linux linux-firmware

# Fstab
## Generate an fstab file (use -U or -L to define by UUID or labels, respectively)
genfstab -U /mnt >> /mnt/etc/fstab

## Check the resulting /mnt/etc/fstab file, and edit it in case of errors
cat /mnt/etc/fstab

# Chroot
arch-chroot /mnt

# Time zone
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc

# Install the nesscery packages
## gvim support system clipboard.
pacman -S gvim dialog wpa_supplicant networkmanager dhcpcd

# Localization
## uncomment en_US.UTF-8 UTF-8 and other needed locales
vim /etc/locale.gen
# generate the locales
locale-gen

## Create the locale.conf file, and set the LANG variable accordingly
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Network configuration
## Create the hostname file
echo "myhostnane" >> /etc/hostname

## Add matching entries to hosts
vim /etc/hosts
### add following content at the tail
127.0.0.1	localhost
::1		localhost
127.0.0.1	myhostname.localdomain	myhostname

# Root password
passwd

# Microcode
pacman -S intel-ucode # if you are using intel cpu
pacman -S amd-ucode # if you are using amd cpu

# Boot loader
pacman -S os-prober ntfs-3g grub efibootmgr
## install grub.(bootloader-id can be set what you want)
grub-install --efi-directory=/boot --bootloader-id=ARCH
grub-mkconfig -o /boot/grub/grub.cfg

# Roboot
exit
umount /mnt/boot
umount /mnt
reboot
```



# Setup

## Beep

```bash
# temporary
## disable
rmmod pcspkr 
## enable
modprobe pcspk

# forever
echo "rmmod pcspkr" >> /etc/profile
```



## Swap

```bash
sudo fallocate -l 4G /swapfile

sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo vim /etc/fstab

# add to the end
/swapfile none swap defaults 0 0
```

## Create User

```bash
# set the the username what you want
useradd -m -G wheel username
# set password
passwd username

# config sudo
## uncomment %wheel ALL=(ALL)ALL
visudo

# reboot
```

### Mirrors

```bash
sudo vim /etc/pacman.conf
# uncomment
[multilib]
Include = /etc/pacman.d/mirrorlist

# add
[archlinuxcn]
SigLevel = Optional TrustedOnly
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
# write and exit :wq

# update
sudo pacman -Syy
sudo pacman -S archlinuxcn-keyring
```



### Install basic tools

```bash
sudo pacman -S zsh git wget yay

# change aururl
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save
```

## Desktop environment

### Xorg

```bash
# Driver installation
## lspci | grep -e VGA -e 3D
lspci | grep -e VGA -e 3D
## show list of open-source video drivers
pacman -Ss xf86-video
## install your video drivers
### intel
sudo pacman -S xf86-video-intel
### amdgpu
sudo pacman -S xf86-video-amdgpu

# Xorg installation
sudo pacman -S xorg
```

### ALSA

```bash
sudo pacman -S alsa-utils
```

### Lightdm

```bash
sudo pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings numlockx
# test
lightdm --test-mod --debug
# auto start
sudo systemctl enable lightdm
```

## i3

```bash
sudo pacman -S i3
```

### i3lock-fancy 
```bash
yay -S i3lock-fancy-git
```

## Network

```bash
# install
sudo pacman -S networkmanager network-manager-applet

# start
sudo systemctl enable NetworkManager
```

## Fonts

### Fira Code Nerd font
```bash
yay -S otf-nerd-fonts-fira-code
```

### For Powerline
```bash
yay -S ttf-dejavu-sans-mono-powerline-git
```

### For Chinese
```bash
sudo pacman -S noto-fonts-cjk adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts
```
### For Polybar

```bash
yay -S siji-git
```

## Input Methods

### Fcitx

```bash
# install
sudo pacman -S fcitx-im fcitx-configtool fcitx-googlepinyin

# config
# sudo vim ~/.xprofile # 如果使用 bash 作为默认 shell
sudo vim ~/.zprofile # 如果使用 zsh 作为默认 shell

# 添加一下内容
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
# 关闭并保存文件
:wq!
```

## Virtualbox

```bash
sudo pacman -S virtualbox

sudo modprobe vboxdrv vboxnetadp vboxnetflt
```



## Tools

### Nitrogen

wallpaper setter

```bash
sudo pacman -S nitrogen
```

### Neofetch

```bash
sudo pacman -S neofetch
```

### Ranger

command file manager

```bash
sudo pacman -S ranger
```

### Ueberzug

preview images

```bash
yay -S python-ueberzug
```



### Broswer

#### Google-Chrome
```bash
sudo pacman -S google-chrome
```
### Vim

#### Install Vim-Plug

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

#### Install plugins
```bash
:PlugInstall
```

### ZSH

install zsh

```bash
sudo pacman -S zsh
```



#### Install Oh-My-Zsh

```bash
# curl
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# wget
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

#### Install plugins

##### zsh-autosuggestions

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

then, add to your `~/.zshrc`

```
plugins=(zsh-autosuggestions)
```

##### zsh-syntax-highlighting 

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

then, add to your `~/.zshrc`

```
plugins = (zsh-syntax-highlighting)
```
