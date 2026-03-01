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

# Separate formulae and casks
formulae=()
casks=()

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  
  pkg=$(echo "$line" | awk '{print $NF}')
  
  if [[ "$line" =~ \[formula\] ]]; then
    formulae+=("$pkg")
  elif [[ "$line" =~ \[cask\] ]]; then
    casks+=("$pkg")
  fi
done <<< "$outdated_choices"

# Upgrade all formulae at once
if [[ ${#formulae[@]} -gt 0 ]]; then
  echo "Upgrading ${#formulae[@]} formula(e): ${formulae[*]}"
  brew upgrade "${formulae[@]}"
fi

# Upgrade all casks at once
if [[ ${#casks[@]} -gt 0 ]]; then
  echo "Upgrading ${#casks[@]} cask(s): ${casks[*]}"
  brew upgrade --cask "${casks[@]}"
fi
