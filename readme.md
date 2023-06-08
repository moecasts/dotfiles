# Setup

## i3

### Basic
```bash
sudo pacman i3-gaps lightdm
```

### i3lock-fancy 
```bash
yay -S i3lock-fancy-git
```

## Fonts

### Fira Code Nerd font
```bash
sudo pacman -S otf-nerd-fonts-fira-code
```

### For Powerline
```bash
yay -S ttf-dejavu-sans-mono-powerline-git
```

### For Chinese
```bash
sudo pacman -S noto-fonts-cjk adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts
```

## Vim

### Install Vim-Plug

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### Install plugins
```bash
:PlugInstall
```

## ZSH

### Install Oh-My-Zsh

### Install plugins
```bash
# curl
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# wget
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

#### zsh-autosuggestions

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

then, add to your `~/.zshrc`

```
plugins=(zsh-autosuggestions)
```

#### zsh-syntax-highlighting 

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

then, add to your `~/.zshrc`

```
plugins = (zsh-syntax-highlighting)
```
