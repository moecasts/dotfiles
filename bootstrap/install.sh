#!/bin/bash

# Get current script directory
SCRIPT_DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

# Detect OS
OS="$(uname -s)"

# Current .zshrc path
ZSHRC_PATH="$HOME/.zshrc"

# Installation options
INSTALL_ALL=true
INSTALL_HOMEBREW=false
INSTALL_OHMYZSH=false
INSTALL_NVM=false
INSTALL_RUST=false
INSTALL_GO=false
INSTALL_TMUX=false
INSTALL_FNM=false
INSTALL_WECHAT=false
INSTALL_QQ=false
INSTALL_NETEASE_MUSIC=false
INSTALL_WEZTERM=false
INSTALL_LAZYGIT=false
INSTALL_FZF=false
INSTALL_RIPGREP=false
INSTALL_KARABINER=false
INSTALL_RECTANGLE=false
INSTALL_FD=false
INSTALL_NVIM_SRC=false
INSTALL_YAZI=false
INSTALL_POSTMAN=false

SUDO="sudo"
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
fi

# Parse command line arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    --help)
      echo -e 'Usage: ./install.sh [options]
Options:
  --homebrew    Install Homebrew package manager
  --ohmyzsh     Install Oh My Zsh shell framework
  --nvm         Install Node Version Manager (nvm)
  --rust        Install Rust programming language
  --go          Install Go programming language
  --fnm         Install Fast Node Manager (fnm)
  --wechat      Install WeChat
  --qq          Install QQ
  --netease     Install NetEase Music
  --wezterm     Install WezTerm terminal
  --lazygit     Install LazyGit (Git UI)
  --fzf         Install fzf (Fuzzy finder)
  --ripgrep     Install ripgrep (Fast text search)
  --karabiner   Install Karabiner-Elements (keyboard customizer)
  --rectangle   Install Rectangle (window manager)
  --fd          Install fd (simple, fast alternative to find)
  --nvim-src    Install Neovim from source (latest stable)
  --yazi        Install yazi (terminal file manager)
  --postman     Install Postman (API development platform)
If no options are provided, an interactive menu will be shown.'
      exit 0
      ;;
    --homebrew)
      INSTALL_ALL=false
      INSTALL_HOMEBREW=true
      ;;
    --ohmyzsh)
      INSTALL_ALL=false
      INSTALL_OHMYZSH=true
      ;;
    --nvm)
      INSTALL_ALL=false
      INSTALL_NVM=true
      ;;
    --rust)
      INSTALL_ALL=false
      INSTALL_RUST=true
      ;;
    --go)
      INSTALL_ALL=false
      INSTALL_GO=true
      ;;
    --tmux)
      INSTALL_ALL=false
      INSTALL_TMUX=true
      ;;
    --fnm)
      INSTALL_ALL=false
      INSTALL_FNM=true
      ;;
    --wechat)
      INSTALL_ALL=false
      INSTALL_WECHAT=true
      ;;
    --qq)
      INSTALL_ALL=false
      INSTALL_QQ=true
      ;;
    --netease)
      INSTALL_ALL=false
      INSTALL_NETEASE_MUSIC=true
      ;;
    --wezterm)
      INSTALL_ALL=false
      INSTALL_WEZTERM=true
      ;;
    --lazygit)
      INSTALL_ALL=false
      INSTALL_LAZYGIT=true
      ;;
    --fzf)
      INSTALL_ALL=false
      INSTALL_FZF=true
      ;;
    --ripgrep)
      INSTALL_ALL=false
      INSTALL_RIPGREP=true
      ;;
    --karabiner)
      INSTALL_ALL=false
      INSTALL_KARABINER=true
      ;;
    --rectangle)
      INSTALL_ALL=false
      INSTALL_RECTANGLE=true
      ;;
    --fd)
      INSTALL_ALL=false
      INSTALL_FD=true
      ;;
    --nvim-src)
      INSTALL_ALL=false
      INSTALL_NVIM_SRC=true
      ;;
    --yazi)
      INSTALL_ALL=false
      INSTALL_YAZI=true
      ;;
    --postman)
      INSTALL_ALL=false
      INSTALL_POSTMAN=true
      ;;
    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
    esac
    shift
  done
}

# If no arguments specified, show interactive menu
probe_interactive() {
  if $INSTALL_ALL; then
    # Initialize all options to true (select all by default)
    selected=(true true true true true true true true true true true true true true true true true true true true)

    cursor=0

    old_stty_cfg=$(stty -g) # 保存终端设置

    restore_stty() {
      stty "$old_stty_cfg" # 恢复终端设置
    }

    cleanup() {
      restore_stty
      exit 1
    }

    while true; do
      clear
      echo -e "Use arrow keys to navigate, space to select/deselect, enter to confirm:\n"
      options=("Homebrew" "Oh My Zsh" "nvm" "Rust" "Go" "tmux" "fnm" "WeChat" "QQ" "NetEase Music" "WezTerm" "LazyGit" "fzf" "ripgrep" "Karabiner" "Rectangle" "fd" "Neovim (source)" "Yazi" "Postman")
      echo "Please select components to install:"

      # Display option list
      for i in "${!options[@]}"; do
        # Highlight current cursor position
        [ $i -eq $cursor ] && printf "\e[7m"

        # Show selection status
        if [[ "${selected[i]}" == "true" ]]; then
          printf "[✔] %s" "${options[i]}"
        else
          printf "[ ] %s" "${options[i]}"
        fi

        # Reset text formatting
        [ $i -eq $cursor ] && printf "\e[0m"
        printf "\n"
      done

      # Handle keyboard input
      # 禁用输入缓冲（确保立即读取字符）

      stty raw -echo -icanon             # 进入原始模式：禁用回显和规范输入处理
      key=$(dd bs=1 count=1 2>/dev/null) # 读取单个字节
      restore_stty

      if [ "$key" = "A" ]; then
        ((cursor--))
        [ $cursor -lt 0 ] && cursor=$((${#options[@]} - 1))
      elif [ "$key" = "B" ]; then
        ((cursor++))
        [ $cursor -ge ${#options[@]} ] && cursor=0
      elif [ "$key" = " " ]; then
        if [[ "${selected[cursor]}" == "true" ]]; then
          selected[cursor]=false
        else
          selected[cursor]=true
        fi
      elif [ "$key" = $'\n' ] || [ "$key" = $'\r' ]; then
        INSTALL_HOMEBREW=${selected[0]}
        INSTALL_OHMYZSH=${selected[1]}
        INSTALL_NVM=${selected[2]}
        INSTALL_RUST=${selected[3]}
        INSTALL_GO=${selected[4]}
        INSTALL_TMUX=${selected[5]}
        INSTALL_FNM=${selected[6]}
        INSTALL_WECHAT=${selected[7]}
        INSTALL_QQ=${selected[8]}
        INSTALL_NETEASE_MUSIC=${selected[9]}
        INSTALL_WEZTERM=${selected[10]}
        INSTALL_LAZYGIT=${selected[11]}
        INSTALL_FZF=${selected[12]}
        INSTALL_RIPGREP=${selected[13]}
        INSTALL_KARABINER=${selected[14]}
        INSTALL_RECTANGLE=${selected[15]}
        INSTALL_FD=${selected[16]}
        INSTALL_NVIM_SRC=${selected[17]}
        INSTALL_YAZI=${selected[18]}
        INSTALL_POSTMAN=${selected[19]}
        INSTALL_ALL=false # 关闭全选模式

        echo -e "\n"

        restore_stty
        break

      elif [ "$key" = $'\x03' ]; then # Ctrl+C 的 ASCII 码是 0x03
        cleanup
      fi
    done
  fi
}

install_homebrew() {
  if [ "$OS" = "Darwin" ]; then
    if ! command -v brew &>/dev/null; then
      echo "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  fi
}

install_ohmyzsh() {
  if ! command -v zsh &>/dev/null; then
    echo "Installing zsh..."
    if [ "$OS" = "Darwin" ]; then
      brew install zsh
    else
      if command -v apt-get &>/dev/null; then
        $SUDO apt-get install -y zsh
      elif command -v yum &>/dev/null; then
        $SUDO yum install -y zsh
      elif command -v dnf &>/dev/null; then
        $SUDO dnf install -y zsh
      elif command -v pacman &>/dev/null; then
        $SUDO pacman -S --noconfirm zsh
      fi
    fi
  fi

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # Install plugins
    echo "Setting up oh-my-zsh plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    # Update .zshrc with plugins
    ZSH_PLUGIN_LIST="z zsh-autosuggestions zsh-syntax-highlighting git"

    sed -i.bak -E \
      -e "s/^plugins=\(\)$/plugins=($ZSH_PLUGIN_LIST)/" \
      -e "s/^plugins=\(([^)]+)\)$/plugins=(\1 $ZSH_PLUGIN_LIST)/" \
      "$ZSHRC_PATH"

    # Remove duplicate plugins
    awk '/^plugins=\(/{s=$0; sub(/^plugins=\(/,"",s); sub(/\)$/,"",s); n=split(s,arr," "); new=""; delete seen; for(i=1;i<=n;i++){if(!seen[arr[i]]++){new=(new?new" ":"") arr[i]}}; $0="plugins=("new")"} 1' $ZSHRC_PATH >zshrc.tmp && mv zshrc.tmp $ZSHRC_PATH
  fi
}

install_nvm() {
  if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

    # Load nvm in current shell
    source "$ZSHRC_PATH"

    # Install latest LTS Node version
    nvm install --lts
  fi
}

install_rust() {
  if ! command -v rustup &>/dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  fi
}

install_go() {
  if ! command -v go &>/dev/null; then
    echo "Installing Go..."
    if [ "$OS" = "Darwin" ]; then
      brew install go
    else
      curl -O https://dl.google.com/go/go1.20.5.linux-amd64.tar.gz
      $SUDO tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz
      rm go1.20.5.linux-amd64.tar.gz
      echo '
# go
export PATH=$PATH:/usr/local/go/bin
' >>$ZSHRC_PATH
      source $ZSHRC_PATH
    fi
  fi
}

# Install tmux from source and configuration
install_tmux() {
  # Prefer Homebrew on macOS
  if [ "$OS" = "Darwin" ]; then
    if command -v brew &>/dev/null; then
      if ! command -v tmux &>/dev/null; then
        echo "Installing tmux via Homebrew..."
        brew install tmux
      else
        echo "tmux is already installed via Homebrew or system."
      fi
    fi
  fi

  # If tmux still not installed, build from source
  if ! command -v tmux &>/dev/null; then
    # Install dependencies
    if [ "$OS" = "Darwin" ]; then
      brew install automake pkg-config libevent ncurses utf8proc
    else
      if command -v apt-get &>/dev/null; then
        $SUDO apt-get install -y automake pkg-config libevent-dev libncurses5-dev build-essential libutf8proc-dev
      elif command -v yum &>/dev/null; then
        $SUDO yum install -y automake pkg-config libevent-devel ncurses-devel make gcc utf8proc-devel
      elif command -v dnf &>/dev/null; then
        $SUDO dnf install -y automake pkg-config libevent-devel ncurses-devel make gcc utf8proc-devel
      elif command -v pacman &>/dev/null; then
        $SUDO pacman -S --noconfirm automake pkg-config libevent ncurses make gcc utf8proc
      fi
    fi

    echo "Installing tmux from source..."
    TMUX_VERSION=3.3a
    TMUX_DIR=/tmp/tmux-$TMUX_VERSION

    # Download and build tmux
    curl -L https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz -o /tmp/tmux.tar.gz
    tar xf /tmp/tmux.tar.gz -C /tmp
    cd $TMUX_DIR

    CONFIG_OK=false
    if [ "$OS" = "Darwin" ]; then
      # Help the configure script find Homebrew-installed libraries/headers
      if command -v brew &>/dev/null; then
        BREW_PREFIX=$(brew --prefix 2>/dev/null)
        UTF8_PREFIX=$(brew --prefix utf8proc 2>/dev/null || echo "$BREW_PREFIX")
        export PKG_CONFIG_PATH="$UTF8_PREFIX/lib/pkgconfig:$BREW_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
        export CPPFLAGS="-I$UTF8_PREFIX/include -I$BREW_PREFIX/include ${CPPFLAGS:-}"
        export LDFLAGS="-L$UTF8_PREFIX/lib -L$BREW_PREFIX/lib ${LDFLAGS:-}"
      fi
    fi

    echo "Configuring tmux with --enable-utf8proc..."
    if ./configure --enable-utf8proc; then
      CONFIG_OK=true
    else
      echo "utf8proc not found; falling back to --disable-utf8proc"
      if ./configure --disable-utf8proc; then
        CONFIG_OK=true
      fi
    fi

    if [ "$CONFIG_OK" = true ]; then
      make
      $SUDO make install || true
    else
      echo "Failed to configure tmux. Please check dependencies and try again." >&2
      cd -
      rm -rf $TMUX_DIR /tmp/tmux.tar.gz
      return 1
    fi

    cd -
    rm -rf $TMUX_DIR /tmp/tmux.tar.gz
  fi

  # Install gpakosz/.tmux configuration
  if [ ! -d "$HOME/.tmux" ]; then
    echo "Installing .tmux configuration..."
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
    ln -s -f "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
    find "$SCRIPT_DIR/../tmux" -type f -exec ln -sf {} "$HOME/" \;
    echo "Tmux configuration installed. You may want to customize ~/.tmux.conf.local"
  fi
}

install_fnm() {
  if ! command -v fnm &>/dev/null; then
    echo "Installing fnm..."
    curl -fsSL https://fnm.vercel.app/install | bash

    # Add fnm to shell configuration
    echo '
# fnm
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd)"
' >> "$ZSHRC_PATH"

    # Load fnm in current shell
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env --use-on-cd)"

    # Install latest LTS Node version
    fnm install --lts
    fnm use lts-latest
  fi
}

install_wechat() {
  if [ "$OS" = "Darwin" ]; then
    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
      echo "Homebrew is required but not installed. Please install Homebrew first."
      return 1
    fi

    if ! brew list --cask wechat &>/dev/null; then
      echo "Installing WeChat..."
      brew install --cask wechat
    else
      echo "WeChat is already installed."
    fi
  else
    echo "WeChat installation is only supported on macOS with Homebrew."
  fi
}

install_qq() {
  if [ "$OS" = "Darwin" ]; then
    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
      echo "Homebrew is required but not installed. Please install Homebrew first."
      return 1
    fi

    if ! brew list --cask qq &>/dev/null; then
      echo "Installing QQ..."
      brew install --cask qq
    else
      echo "QQ is already installed."
    fi
  else
    echo "QQ installation is only supported on macOS with Homebrew."
  fi
}

install_netease_music() {
  if [ "$OS" = "Darwin" ]; then
    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
      echo "Homebrew is required but not installed. Please install Homebrew first."
      return 1
    fi

    if ! brew list --cask neteasemusic &>/dev/null; then
      echo "Installing NetEase Music..."
      brew install --cask neteasemusic
    else
      echo "NetEase Music is already installed."
    fi
  else
    echo "NetEase Music installation is only supported on macOS with Homebrew."
  fi
}

install_wezterm() {
  if [ "$OS" = "Darwin" ]; then
    # Check if Homebrew is installed
    if ! command -v brew &>/dev/null; then
      echo "Homebrew is required but not installed. Please install Homebrew first."
      return 1
    fi

    if ! brew list --cask wezterm &>/dev/null; then
      echo "Installing WezTerm..."
      brew install --cask wezterm
    else
      echo "WezTerm is already installed."
    fi

    # Create WezTerm config directory if it doesn't exist
    WEZTERM_CONFIG_DIR="$HOME/.config/wezterm"
    if [ ! -d "$WEZTERM_CONFIG_DIR" ]; then
      echo "Creating WezTerm config directory..."
      mkdir -p "$WEZTERM_CONFIG_DIR"
    fi

    # Link WezTerm configuration file
    WEZTERM_CONFIG_FILE="$WEZTERM_CONFIG_DIR/wezterm.lua"
    DOTFILES_WEZTERM_CONFIG="$SCRIPT_DIR/../wezterm/wezterm.lua"

    if [ -f "$DOTFILES_WEZTERM_CONFIG" ]; then
      if [ -L "$WEZTERM_CONFIG_FILE" ] || [ -f "$WEZTERM_CONFIG_FILE" ]; then
        echo "WezTerm config file already exists. Backing up..."
        mv "$WEZTERM_CONFIG_FILE" "$WEZTERM_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
      fi

      echo "Linking WezTerm configuration..."
      ln -sf "$DOTFILES_WEZTERM_CONFIG" "$WEZTERM_CONFIG_FILE"
      echo "WezTerm configuration linked successfully!"
    else
      echo "Warning: WezTerm config file not found at $DOTFILES_WEZTERM_CONFIG"
    fi
  else
    echo "WezTerm installation is only supported on macOS with Homebrew."
  fi
}

install_lazygit() {
  if ! command -v lazygit &>/dev/null; then
    echo "Installing LazyGit..."

    if [ "$OS" = "Darwin" ]; then
      # Try Homebrew first
      if command -v brew &>/dev/null; then
        echo "Installing LazyGit via Homebrew..."
        brew install lazygit
      else
        echo "Homebrew not found, installing LazyGit from GitHub releases..."
        # Get latest release URL
        LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION#v}_Darwin_x86_64.tar.gz"

        # Download and install
        curl -L "$LAZYGIT_URL" -o /tmp/lazygit.tar.gz
        tar -xzf /tmp/lazygit.tar.gz -C /tmp
        $SUDO mv /tmp/lazygit /usr/local/bin/
        rm /tmp/lazygit.tar.gz
      fi
    else
      # Linux installation
      if command -v apt-get &>/dev/null; then
        echo "Installing LazyGit via apt..."
        $SUDO apt-get update
        $SUDO apt-get install -y lazygit
      elif command -v yum &>/dev/null; then
        echo "Installing LazyGit via yum..."
        $SUDO yum install -y lazygit
      elif command -v dnf &>/dev/null; then
        echo "Installing LazyGit via dnf..."
        $SUDO dnf install -y lazygit
      elif command -v pacman &>/dev/null; then
        echo "Installing LazyGit via pacman..."
        $SUDO pacman -S --noconfirm lazygit
      else
        echo "Installing LazyGit from GitHub releases..."
        # Get latest release URL for Linux
        LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        LAZYGIT_URL="https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz"

        # Download and install
        curl -L "$LAZYGIT_URL" -o /tmp/lazygit.tar.gz
        tar -xzf /tmp/lazygit.tar.gz -C /tmp
        $SUDO mv /tmp/lazygit /usr/local/bin/
        rm /tmp/lazygit.tar.gz
      fi
    fi
  else
    echo "LazyGit is already installed."
  fi

  # Link LazyGit config (if present in repo)
  backup_and_link "$SCRIPT_DIR/../lazygit/config.yml" "$HOME/.config/lazygit/config.yml"
}

install_fzf() {
  if ! command -v fzf &>/dev/null; then
    echo "Installing fzf..."

    if [ "$OS" = "Darwin" ]; then
      # Try Homebrew first
      if command -v brew &>/dev/null; then
        echo "Installing fzf via Homebrew..."
        brew install fzf
      else
        echo "Homebrew not found, installing fzf from GitHub..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --key-bindings --completion --no-update-rc
      fi
    else
      # Linux installation
      if command -v apt-get &>/dev/null; then
        echo "Installing fzf via apt..."
        $SUDO apt-get update
        $SUDO apt-get install -y fzf
      elif command -v yum &>/dev/null; then
        echo "Installing fzf via yum..."
        $SUDO yum install -y fzf
      elif command -v dnf &>/dev/null; then
        echo "Installing fzf via dnf..."
        $SUDO dnf install -y fzf
      elif command -v pacman &>/dev/null; then
        echo "Installing fzf via pacman..."
        $SUDO pacman -S --noconfirm fzf
      else
        echo "Installing fzf from GitHub..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --key-bindings --completion --no-update-rc
      fi
    fi
  else
    echo "fzf is already installed."
  fi
}

install_ripgrep() {
  if ! command -v rg &>/dev/null; then
    echo "Installing ripgrep..."

    if [ "$OS" = "Darwin" ]; then
      # Try Homebrew first
      if command -v brew &>/dev/null; then
        echo "Installing ripgrep via Homebrew..."
        brew install ripgrep
      else
        echo "Homebrew not found, installing ripgrep from GitHub releases..."
        # Get latest release URL
        RIPGREP_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        RIPGREP_URL="https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION#v}-x86_64-unknown-linux-musl.tar.gz"

        # Download and install
        curl -L "$RIPGREP_URL" -o /tmp/ripgrep.tar.gz
        tar -xzf /tmp/ripgrep.tar.gz -C /tmp
        $SUDO mv /tmp/ripgrep-*/rg /usr/local/bin/
        rm -rf /tmp/ripgrep-* /tmp/ripgrep.tar.gz
      fi
    else
      # Linux installation
      if command -v apt-get &>/dev/null; then
        echo "Installing ripgrep via apt..."
        $SUDO apt-get update
        $SUDO apt-get install -y ripgrep
      elif command -v yum &>/dev/null; then
        echo "Installing ripgrep via yum..."
        $SUDO yum install -y ripgrep
      elif command -v dnf &>/dev/null; then
        echo "Installing ripgrep via dnf..."
        $SUDO dnf install -y ripgrep
      elif command -v pacman &>/dev/null; then
        echo "Installing ripgrep via pacman..."
        $SUDO pacman -S --noconfirm ripgrep
      else
        echo "Installing ripgrep from GitHub releases..."
        # Get latest release URL
        RIPGREP_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        RIPGREP_URL="https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION#v}-x86_64-unknown-linux-musl.tar.gz"

        # Download and install
        curl -L "$RIPGREP_URL" -o /tmp/ripgrep.tar.gz
        tar -xzf /tmp/ripgrep.tar.gz -C /tmp
        $SUDO mv /tmp/ripgrep-*/rg /usr/local/bin/
        rm -rf /tmp/ripgrep-* /tmp/ripgrep.tar.gz
      fi
    fi
  else
    echo "ripgrep is already installed."
  fi
}

install_karabiner() {
  if [ "$OS" = "Darwin" ]; then
    if ! command -v brew &>/dev/null; then
      echo "Homebrew is required but not installed. Please install Homebrew first."
      return 1
    fi

    # Prefer Homebrew cask per official docs
    # Ref: https://github.com/pqrs-org/Karabiner-Elements
    if ! brew list --cask karabiner-elements &>/dev/null; then
      echo "Installing Karabiner-Elements..."
      brew install --cask karabiner-elements
    else
      echo "Karabiner-Elements is already installed."
    fi

    # Link Karabiner config (if present)
    backup_and_link "$SCRIPT_DIR/../karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
  else
    echo "Karabiner-Elements installation is only supported on macOS with Homebrew."
  fi
}

install_rectangle() {
  if [ "$OS" = "Darwin" ]; then
    if ! command -v brew &>/dev/null; then
      echo "Homebrew is required but not installed. Please install Homebrew first."
      return 1
    fi

    # Rectangle official cask
    # Ref: https://github.com/rxhanson/Rectangle
    if ! brew list --cask rectangle &>/dev/null; then
      echo "Installing Rectangle..."
      brew install --cask rectangle
    else
      echo "Rectangle is already installed."
    fi

    # Link Rectangle preferences (if present)
    backup_and_link "$SCRIPT_DIR/../rectangle/com.knollsoft.Rectangle.plist" "$HOME/Library/Preferences/com.knollsoft.Rectangle.plist"
  else
    echo "Rectangle installation is only supported on macOS with Homebrew."
  fi
}

install_fd() {
  if ! command -v fd &>/dev/null && ! command -v fdfind &>/dev/null; then
    echo "Installing fd..."

    if [ "$OS" = "Darwin" ]; then
      if command -v brew &>/dev/null; then
        echo "Installing fd via Homebrew..."
        brew install fd
      else
        echo "Homebrew not found. Installing via cargo as fallback..."
        if command -v cargo &>/dev/null; then
          cargo install fd-find
        else
          echo "cargo not found. Please install Homebrew or Rust (cargo)."
          return 1
        fi
      fi
    else
      if command -v apt-get &>/dev/null; then
        echo "Installing fd via apt (package name: fd-find)..."
        $SUDO apt-get update
        $SUDO apt-get install -y fd-find
        if [ ! -e /usr/local/bin/fd ] && command -v fdfind &>/dev/null; then
          $SUDO ln -sf "$(command -v fdfind)" /usr/local/bin/fd
        fi
      elif command -v yum &>/dev/null; then
        echo "Installing fd via yum..."
        $SUDO yum install -y fd-find || $SUDO yum install -y fd
      elif command -v dnf &>/dev/null; then
        echo "Installing fd via dnf..."
        $SUDO dnf install -y fd-find || $SUDO dnf install -y fd
      elif command -v pacman &>/dev/null; then
        echo "Installing fd via pacman (package name: fd)..."
        $SUDO pacman -S --noconfirm fd
      else
        echo "No supported package manager found. Installing via cargo..."
        if command -v cargo &>/dev/null; then
          cargo install fd-find
        else
          echo "cargo not found. Please install a package manager or Rust (cargo)."
          return 1
        fi
      fi
    fi
  else
    echo "fd is already installed."
  fi
}

install_nvim_from_source() {
  echo "Installing Neovim from source..."

  # Dependencies
  if [ "$OS" = "Darwin" ]; then
    if command -v brew &>/dev/null; then
      brew install cmake ninja gettext libtool automake pkg-config unzip curl
    else
      echo "Homebrew not found. Attempting to proceed, but build may fail without deps."
    fi
  else
    if command -v apt-get &>/dev/null; then
      $SUDO apt-get update
      $SUDO apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl
    elif command -v dnf &>/dev/null; then
      $SUDO dnf install -y ninja-build libtool autoconf automake cmake gcc-c++ make pkgconfig gettext curl unzip
    elif command -v yum &>/dev/null; then
      $SUDO yum install -y ninja-build libtool autoconf automake cmake gcc-c++ make pkgconfig gettext curl unzip
    elif command -v pacman &>/dev/null; then
      $SUDO pacman -S --noconfirm base-devel cmake ninja gettext curl unzip
    fi
  fi

  # Clone source (shallow)
  TMP_NVIM_DIR="/tmp/nvim-src-$(date +%s)"
  LATEST_TAG=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' || true)
  if [ -n "$LATEST_TAG" ]; then
    echo "Shallow cloning Neovim tag $LATEST_TAG..."
    git clone --depth 1 --branch "$LATEST_TAG" https://github.com/neovim/neovim.git "$TMP_NVIM_DIR"
  else
    echo "Shallow cloning Neovim master (latest tag not resolved)..."
    git clone --depth 1 https://github.com/neovim/neovim.git "$TMP_NVIM_DIR"
  fi
  cd "$TMP_NVIM_DIR"

  # Checkout latest stable tag if available; fallback already handled above
  if [ -z "$LATEST_TAG" ]; then
    if git fetch --tags && git tag -l | grep -E '^v[0-9]+' >/dev/null 2>&1; then
      LATEST_TAG=$(git tag -l | sort -V | tail -n 1)
      echo "Checking out tag $LATEST_TAG"
      git checkout "$LATEST_TAG" || true
    else
      echo "No tags found; building from current branch"
    fi
  fi

  make CMAKE_BUILD_TYPE=Release
  $SUDO make install

  cd - >/dev/null
  rm -rf "$TMP_NVIM_DIR"

  if command -v nvim &>/dev/null; then
    echo "Neovim installed: $(nvim --version | head -n1)"
    # Link Neovim config after successful install
    backup_and_link "$SCRIPT_DIR/../nvim" "$HOME/.config/nvim"
  else
    echo "Neovim installation appears to have failed."
    return 1
  fi
}

install_yazi() {
  if ! command -v yazi &>/dev/null; then
    echo "Installing yazi..."

    if [ "$OS" = "Darwin" ]; then
      if command -v brew &>/dev/null; then
        brew install yazi
      else
        echo "Homebrew not found. Installing via cargo as fallback..."
        if command -v cargo &>/dev/null; then
          cargo install --locked yazi-fm yazi-cli
        else
          echo "cargo not found. Please install Homebrew or Rust (cargo)."
          return 1
        fi
      fi
    else
      if command -v apt-get &>/dev/null; then
        $SUDO apt-get update
        $SUDO apt-get install -y yazi
      elif command -v dnf &>/dev/null; then
        $SUDO dnf install -y yazi
      elif command -v pacman &>/dev/null; then
        $SUDO pacman -S --noconfirm yazi
      else
        echo "No supported package manager found. Installing via cargo..."
        if command -v cargo &>/dev/null; then
          cargo install --locked yazi-fm yazi-cli
        else
          echo "cargo not found. Please install a package manager or Rust (cargo)."
          return 1
        fi
      fi
    fi
  else
    echo "yazi is already installed."
  fi

  # Link yazi config if present in repo
  backup_and_link "$SCRIPT_DIR/../yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
}

install_postman() {
  if [ "$OS" = "Darwin" ]; then
    if ! command -v brew &>/dev/null; then
      echo "Homebrew is required but not installed. Please install Homebrew first."
      return 1
    fi

    if ! brew list --cask postman &>/dev/null; then
      echo "Installing Postman..."
      brew install --cask postman
    else
      echo "Postman is already installed."
    fi

    # Link Postman config if present in repo
    backup_and_link "$SCRIPT_DIR/../postman" "$HOME/.config/Postman"
  else
    echo "Postman installation is only supported on macOS with Homebrew."
  fi
}

backup_and_link() {
  local src="$1"
  local dst="$2"

  if [ ! -e "$src" ]; then
    return 0
  fi

  # If already a symlink to the same source, skip
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "Already linked: $dst -> $src"
    return 0
  fi

  local dst_dir
  dst_dir=$(dirname "$dst")
  if [ ! -d "$dst_dir" ]; then
    mkdir -p "$dst_dir"
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "Backing up existing: $dst"
    mv "$dst" "$dst.backup.$(date +%Y%m%d_%H%M%S)"
  fi

  echo "Linking $dst -> $src"
  ln -s "$src" "$dst"
}

# Check for essential dependencies
check_dependencies() {
  local missing=()
  local required=("curl" "git")

  for cmd in "${required[@]}"; do
    if ! command -v $cmd &>/dev/null; then
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    echo "Missing required dependencies: ${missing[*]}"

    if [ "$OS" = "Darwin" ]; then
      echo "Installing missing dependencies using xcode-select..."
      xcode-select --install
    elif command -v apt-get &>/dev/null; then
      echo "Installing missing dependencies using apt-get..."
      $SUDO apt-get update
      $SUDO apt-get install -y "${missing[@]}"
    elif command -v yum &>/dev/null; then
      echo "Installing missing dependencies using yum..."
      $SUDO yum install -y "${missing[@]}"
    elif command -v dnf &>/dev/null; then
      echo "Installing missing dependencies using dnf..."
      $SUDO dnf install -y "${missing[@]}"
    elif command -v pacman &>/dev/null; then
      echo "Installing missing dependencies using pacman..."
      $SUDO pacman -S --noconfirm "${missing[@]}"
    else
      echo "Could not install dependencies automatically. Please install these manually: ${missing[*]}"
      exit 1
    fi
  fi
}

run() {
  parse_args "$@"

  probe_interactive

  # Check dependencies before proceeding
  check_dependencies

  # Main installation logic
  if $INSTALL_HOMEBREW || $INSTALL_ALL; then
    install_homebrew
  fi

  if $INSTALL_OHMYZSH || $INSTALL_ALL; then
    install_ohmyzsh
  fi

  if $INSTALL_NVM || $INSTALL_ALL; then
    install_nvm
  fi

  if $INSTALL_RUST || $INSTALL_ALL; then
    install_rust
  fi

  if $INSTALL_GO || $INSTALL_ALL; then
    install_go
  fi

  if $INSTALL_TMUX || $INSTALL_ALL; then
    install_tmux
  fi

  if $INSTALL_FNM || $INSTALL_ALL; then
    install_fnm
  fi

  if $INSTALL_WECHAT || $INSTALL_ALL; then
    install_wechat
  fi

  if $INSTALL_QQ || $INSTALL_ALL; then
    install_qq
  fi

  if $INSTALL_NETEASE_MUSIC || $INSTALL_ALL; then
    install_netease_music
  fi

  if $INSTALL_WEZTERM || $INSTALL_ALL; then
    install_wezterm
  fi

  if $INSTALL_LAZYGIT || $INSTALL_ALL; then
    install_lazygit
  fi

  if $INSTALL_FZF || $INSTALL_ALL; then
    install_fzf
  fi

  if $INSTALL_RIPGREP || $INSTALL_ALL; then
    install_ripgrep
  fi

  if $INSTALL_KARABINER || $INSTALL_ALL; then
    install_karabiner
  fi

  if $INSTALL_RECTANGLE || $INSTALL_ALL; then
    install_rectangle
  fi

  if $INSTALL_FD || $INSTALL_ALL; then
    install_fd
  fi

  if $INSTALL_NVIM_SRC || $INSTALL_ALL; then
    install_nvim_from_source
  fi

  if $INSTALL_YAZI || $INSTALL_ALL; then
    install_yazi
  fi

  if $INSTALL_POSTMAN || $INSTALL_ALL; then
    install_postman
  fi

  echo "Setup complete!"
}

run "$@"
