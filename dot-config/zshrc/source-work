# Source work-specific configurations if the directory exists
if [[ -d "$HOME/.work/zshrc" ]]; then
  for file in $HOME/.work/zshrc/*; do
    if [[ -f "$file" && -r "$file" ]]; then
      source "$file"   # or . "$file"
    fi
  done
fi

