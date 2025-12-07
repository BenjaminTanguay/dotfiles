#!/usr/bin/env zsh

# Refresh brew data
brew update >/dev/null 2>&1

# Get list of outdated formulae and casks
outdated_choices=$(
  {
    brew outdated --formula | awk '{print "  [formula] " $1}'
    brew outdated --cask    | awk '{print "   [cask]    " $1}'
  } | column -t -s ' ' \
    | fzf --height=50% --min-height=15 --reverse -m \
          --header='[brew:update]' \
          --preview-window=right:70% \
          --preview '
            pkg=$(echo {} | sed "s/.*] *//")
            brew info "$pkg" 2>/dev/null | sed "s/^/  /"
          '
)

# Exit if nothing selected
[[ -z "$outdated_choices" ]] && return

# Update selected items
echo "$outdated_choices" | while read -r line; do
  type=$(echo "$line" | grep -o '\[.*\]' | head -n1)
  pkg=$(echo "${line#*]}" | xargs)

  if [[ "$type" == "[formula]" ]]; then
    echo "Updating formula: $pkg"
    brew upgrade "$pkg"
  else
    echo "Updating cask: $pkg"
    brew upgrade --cask "$pkg"
  fi
done
