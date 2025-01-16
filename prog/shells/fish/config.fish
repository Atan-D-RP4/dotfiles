set -g fish_greeting
if status is-interactive
    # Commands to run in interactive sessions can go here
	# Check if the fastfetch exists is available
	if type -q fastfetch
		fastfetch
	end
end
abbr mkdir 'mkdir -p'
alias ll='ls -latr'
