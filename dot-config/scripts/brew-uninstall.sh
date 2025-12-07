#!/usr/bin/env zsh

# Build aligned list of installed formulae and casks
choices=$(
  {
    brew list --formula | awk '{print "  [formula] " $1}'
    brew list --cask    | awk '{print "   [cask]    " $1}'
  } | column -t -s ' ' \
    | fzf --height=50% --min-height=15 --reverse -m \
          --header='[brew:uninstall] Select items to remove' \
          --preview-window=right:70% \
          --preview '
            pkg=$(echo {} | sed "s/.*] *//")
            echo "Package info:" 
            brew info "$pkg" 2>/dev/null | sed "s/^/  /"
            echo ""
            echo "Reverse dependencies (installed):"
            brew uses --installed "$pkg" 2>/dev/null | sed "s/^/  /"
          '
)

[[ -z "$choices" ]] && return

echo "$choices" | while read -r line; do
  type=$(echo "$line" | grep -o '\[.*\]' | head -n1)
  pkg=$(echo "${line#*]}" | xargs)

  if [[ "$type" == "[formula]" ]]; then
    echo "Uninstalling formula: $pkg"
    brew uninstall "$pkg"
  else
    echo "Uninstalling cask: $pkg"
    brew uninstall --cask "$pkg"
  fi
done
