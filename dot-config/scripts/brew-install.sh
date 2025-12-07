#!/usr/bin/env zsh

# Get the latest version of brew and of the formulae list
brew update
# This is done because the list of formulae and casks is lazy loaded after an update.
# We force a rebuild by making a search before proceeding with the script.
brew search bat >/dev/null 2>&1
brew search firefox > /dev/null 2>&1

# Build aligned list of formulae and casks
choices=$(
  {
    brew formulae | awk '{print "  [formula] " $1}'
    brew casks    | awk '{print "   [cask]    " $1}'
  } | column -t -s ' ' \
    | fzf --height=50% --min-height=15 --reverse -m \
          --header='[brew:install]' \
          --preview-window=right:70% \
          --preview '
            # extract pkg name from the selected line
            pkg=$(echo {} | sed "s/.*] *//")
            brew info "$pkg" 2>/dev/null | sed "s/^/  /"
          '
)

[[ -z "$choices" ]] && return

echo "$choices" | while read -r line; do
  # Extract the marker: [formula] or [cask]
  type=$(echo "$line" | grep -o '\[.*\]' | head -n1)

  # Extract package name after "] "
  pkg=$(echo "${line#*]}" | xargs)

  if [[ "$type" == "[formula]" ]]; then
    echo "Installing formula: $pkg"
    brew install "$pkg"
  else
    echo "Installing cask: $pkg"
    brew install --cask "$pkg"
  fi
done
