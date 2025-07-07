set -g fish_greeting
set -g fish_command_timeout 2000
set -g fish_key_bindings fish_vi_key_bindings

if status is-interactive
    # Commands to run in interactive sessions can go here
    if type -q starship
	starship init fish | source
    end
    if type -q fastfetch
	    fastfetch
    end
end
set -x SHELL /usr/bin/fish
abbr mkdir 'mkdir -p'
alias ll='ls -latr'

if type -q atuin
    atuin init fish | source
end

bind -M insert  ctrl-e 'nvim'
bind -M default ctrl-e 'nvim'
