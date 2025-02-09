#!/bin/bash

# Function to enable debug mode if necessary
DEBUG=false
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

# Backup current configuration files
backup_config() {
  if [ -d "$HOME/.config" ]; then
    rm -rf $HOME/.config-bak
    cp -R $HOME/.config $HOME/.config-bak
  fi
}

# Remove any current symlinks managed by stow
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

# Remove conflicting config files that may interfere with stow symlinks
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

# Execute the configuration update tasks
remove_stow_symlinks
backup_config
remove_matching_conflicting_config
symlink_dotfiles
source "$HOME/.zshrc"
