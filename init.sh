#!/bin/bash

# Enable debug mode and redirect output to a file
DEBUG=true
DEBUG_LOG="debug_output.log"

# Function to enable debug mode if necessary
enable_debug() {
  if [[ "$DEBUG" == true ]]; then
    echo "Debug mode is enabled. Logging to $DEBUG_LOG"
    exec 3>&2            # Save current stderr to file descriptor 3
    exec 2>>"$DEBUG_LOG" # Redirect stderr (which is used by -x) to the log file
    set -x               # Enable command tracing
  fi
}

# Function to disable debug mode
disable_debug() {
  if [[ "$DEBUG" == true ]]; then
    set +x    # Disable command tracing
    exec 2>&3 # Restore stderr to its original state (before redirection)
    echo "Debug mode is disabled"
  fi
}

backup_config() {

  if [ -d "$HOME/.config" ]; then
    rm -rf $HOME/.config-bak
    cp -R $HOME/.config $HOME/.config-bak
  fi

}

oh-my-zsh_install() {
  # Check if Oh My Zsh is installed
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is not installed. Installing now..."

    enable_debug
    if [ -f "$HOME/.zshrc" ]; then
      rm -f $HOME/.zshrc.backup
      mv $HOME/.zshrc $HOME/.zshrc.backup
    fi

    export ZSH="$HOME/.oh-my-zsh"
    # Install Oh My Zsh using the official script if not installed
    $(sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended")
    sleep 2
    if [ -f "$HOME/.zshrc.backup" ]; then
      rm -f $HOME/.zshrc
      mv $HOME/.zshrc.backup $HOME/.zshrc
    fi

    # Check if installation was successful
    if [ -d "$HOME/.oh-my-zsh" ]; then
      echo "Oh My Zsh installed successfully!"
    else
      echo "Something went wrong during the installation. Please check the error messages above."
    fi

    disable_debug
  else
    echo "Oh My Zsh is already installed!"
  fi
}

remove_stow_symlinks() {
  # Check if 'stow' is installed
  if command -v stow &>/dev/null; then
    echo "Removing current symlink managed by stow for update"
    stow -D .
  fi
}

# This function symlinks everything from the .dotfiles folder except the .config folder itself
# so that other configurations are not lost
symlink_dotfiles() {
  # Get the path to the script's directory
  local SCRIPT_DIR="$(dirname "$(realpath "$0")")"

  # Change to the dotfiles root directory
  cd "$SCRIPT_DIR" || return 1

  # Symlink all files in the root of the dotfiles directory (excluding .config)
  stow --no-folding --dotfiles --adopt -R .
}

# By definition, a folder within .config is either managed entirely by stow or completly ignored by it.
remove_matching_conflicting_config() {
  # Get the directory where the script is located (the root of .dotfiles)
  local SCRIPT_DIR="$(dirname "$(realpath "$0")")"

  # Define the .config directories
  local DOTFILES_CONFIG_DIR="$SCRIPT_DIR/dot-config"
  local USER_CONFIG_DIR="$HOME/.config"

  # Loop through each directory in $DOTFILES_CONFIG_DIR
  for dir in "$DOTFILES_CONFIG_DIR"/*; do
    # Only process directories
    if [ -d "$dir" ]; then
      local dir_name=$(basename "$dir")
      local user_dir="$USER_CONFIG_DIR/$dir_name"

      # Check if the corresponding directory exists in $USER_CONFIG_DIR
      if [ -d "$user_dir" ]; then
        echo "Removing directory: $user_dir"
        rm -rf "$user_dir"
      fi
    fi
  done

  rm $HOME/.zshrc

  echo "Finished removing matching directories."
}

brew_install() {
  echo "Installing $1"
  if brew list $1 &>/dev/null; then
    echo "$1 is already installed. Attempting to update..."
    brew upgrade $1 && echo "$1 has been updated."
  else
    brew install $1 && echo "$1 is installed"
  fi
}

brew_install_cask() {
  echo "Installing $1"
  if brew list $1 &>/dev/null; then
    echo "$1 is already installed. Attempting to update..."
    brew upgrade --cask $1 && echo "$1 has been updated."
  else
    brew install --cask $1 && echo "$1 is installed"
  fi
}

remove_stow_symlinks
backup_config
oh-my-zsh_install

brew_install "ripgrep"
brew_install_cask "ghostty"
brew_install_cask "firefox"
brew_install "starship"
brew_install_cask "nikitabobko/tap/aerospace"
brew_install eza
brew_install zoxide
brew_install bat
brew_install nvim
brew_install fzf
brew_install_cask aldente
brew_install git
brew_install nushell
brew_install carapace
brew_install font-jetbrains-mono-nerd-font
brew_install stow

remove_matching_conflicting_config_dirs
symlink_dotfiles

cd $HOME/.dotfiles && git checkout HEAD dot-zshrc
