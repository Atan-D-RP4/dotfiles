set -g fish_greeting
set -g fish_command_timeout 2000
set -g fish_key_bindings fish_vi_key_bindings

if status is-interactive
    # Commands to run in interactive sessions can go here
    if type -q starship
	starship init fish | source
    end
    if type -q fastfetch && test -z "$NVIM"
	fastfetch
    end
end
set -x SHELL /usr/bin/fish

abbr mkdir 'mkdir -p'
alias ll='ls -latr'
alias bw='deno run -A npm:@bitwarden/cli'
alias qodo='deno run -A npm:@qodo/command'
alias gemini='deno run -A npm:@google/gemini-cli'

if type -q k3s
    alias kubectl='k3s kubectl --kubeconfig=$XDG_CONFIG_HOME/.kube/config'
end

if type -q atuin
    atuin init fish | source
end

bind -M insert  ctrl-e 'nvim'
bind -M default ctrl-e 'nvim'

bind -M insert  alt-e 'sudo -E nvim' repaint
bind -M default alt-e 'sudo -E nvim' repaint

