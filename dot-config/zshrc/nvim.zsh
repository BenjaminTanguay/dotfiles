function nvims() {
        config=$(find -L "${XDG_CONFIG_HOME:-$HOME/.config}" -mindepth 2 -maxdepth 2 -name init.lua -o -name init.vim | \
        awk -F/ '{print $(NF-1)}' | \
        fzf --prompt 'Neovim config' --layout=reverse --border --exit-0)
        if [[ -z $config ]]; then
          echo "Nothing selected"
          return 0
        elif [[ $config == "default" ]]; then
          config=""
        fi
        NVIM_APPNAME=$config nvim $@
}
alias ns=nvims
