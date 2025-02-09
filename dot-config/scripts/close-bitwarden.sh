aerospace list-windows --all --json | jq -r '.[] | select(.["app-name"] == "Bitwarden") | .["window-id"]' | xargs -I {} aerospace close --window-id {}
