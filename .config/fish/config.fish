function fish_prompt
    string join '' -- (set_color normal) (prompt_pwd) (set_color cyan) ' < '
end

set fish_greeting ""
fish_add_path ~/.local/bin

if status is-interactive
end

alias upd="sudo emerge --ask --update --deep --newuse -q @world"
alias f="clear && fastfetch"
alias clock="tty-clock -c -s -C 7"
alias gitsync="dots-sync"
