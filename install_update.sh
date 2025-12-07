#!/bin/bash

# Function to install or update a program using Homebrew
brew_install() {
  echo "Installing $1"
  if brew list $1 &>/dev/null; then
    echo "$1 is already installed. Attempting to update..."
    brew upgrade $1 && echo "$1 has been updated."
  else
    brew install $1 && echo "$1 is installed"
  fi
}

# Function to install or update a cask program using Homebrew
brew_install_cask() {
  echo "Installing $1"
  if brew list $1 &>/dev/null; then
    echo "$1 is already installed. Attempting to update..."
    brew upgrade --cask $1 && echo "$1 has been updated."
  else
    brew install --cask $1 && echo "$1 is installed"
  fi
}

# Install or update essential programs
brew_install "ripgrep"
brew_install_cask "ghostty"
brew_install_cask "firefox"
brew_install "starship"
brew_install_cask "nikitabobko/tap/aerospace"
brew_install "eza"
brew_install "zoxide"
brew_install "bat"
brew_install "nvim"
brew_install "fzf"
brew_install_cask "aldente"
brew_install "git"
brew_install "nushell"
brew_install "carapace"
brew_install "font-jetbrains-mono-nerd-font"
brew_install "stow"
brew_install "zsh-syntax-highlighting"
brew_install "navi"
brew_install "atuin"
brew_install "dysk"
