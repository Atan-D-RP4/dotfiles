set -g fish_greeting

if status is-interactive
    # Commands to run in interactive sessions can go here
    if type -q starship
	starship init fish | source
    end
    if type -q fastfetch
	    fastfetch
    end
end
abbr mkdir 'mkdir -p'
alias ll='ls -latr'
