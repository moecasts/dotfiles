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
    selected=(true true true true true true)

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
      options=("Homebrew" "Oh My Zsh" "nvm" "Rust" "Go" "tmux")
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
  # Install dependencies
  if [ "$OS" = "Darwin" ]; then
    brew install automake pkg-config libevent ncurses
  else
    if command -v apt-get &>/dev/null; then
      $SUDO apt-get install -y automake pkg-config libevent-dev libncurses5-dev build-essential
    elif command -v yum &>/dev/null; then
      $SUDO yum install -y automake pkg-config libevent-devel ncurses-devel make gcc
    elif command -v dnf &>/dev/null; then
      $SUDO dnf install -y automake pkg-config libevent-devel ncurses-devel make gcc
    elif command -v pacman &>/dev/null; then
      $SUDO pacman -S --noconfirm automake pkg-config libevent ncurses make gcc
    fi
  fi

  # Install tmux from source
  if ! command -v tmux &>/dev/null; then
    echo "Installing tmux from source..."
    TMUX_VERSION=3.3a
    TMUX_DIR=/tmp/tmux-$TMUX_VERSION

    # Download and build tmux
    curl -L https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz -o /tmp/tmux.tar.gz
    tar xf /tmp/tmux.tar.gz -C /tmp
    cd $TMUX_DIR
    ./configure && make
    $SUDO make install
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

  echo "Setup complete!"
}

run "$@"
