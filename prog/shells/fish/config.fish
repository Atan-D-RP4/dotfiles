# Skip non-interactive shells
if not status is-interactive
    exit
end

set -g fish_greeting
set -g fish_command_timeout 2000
set -g fish_key_bindings fish_vi_key_bindings

# Commands to run in interactive sessions can go here
if type -q starship
    starship init fish | source
    # set -x STARSHIP_CACHE $XDG_CACHE_HOME/starship
    # set -x STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/starship.toml
end

if type -q fastfetch
    # Check if shell is in Neovim terminal
    if test -z "$NVIM"
        fastfetch
    end
end

set -x SHELL /usr/bin/fish

abbr mkdir 'mkdir -p'
alias ll='ls -latr'

if type -q deno
    function bw
        deno run -A npm:@bitwarden/cli $argv
    end
end

if type -q k3s
    function kubectl
        k3s kubectl --kubeconfig=$XDG_CONFIG_HOME/.kube/config $argv
    end
end

if type -q atuin
    atuin init fish | source
end

if type -q curl
    function wttr
        if test (count $argv) -eq 0
            curl wttr.in
        else
            curl wttr.in/$argv
        end
    end
end

if type -q nvim
    bind -M insert  ctrl-e 'nvim'
    bind -M insert  ctrl-shift-e 'sudo -E nvim' repaint

    bind -M default ctrl-e 'nvim'
    bind -M default ctrl-shift-e 'sudo -E nvim' repaint

    bind -M insert  ctrl-o 'nvim +Oil' repaint
    bind -M default  ctrl-o 'nvim +Oil' repaint
end

if type -q mpv && type -q uv
    function ytplay
        set url $(yt-dlp -g "ytsearch:$(read --prompt 'echo "Song Name: "')")
        if test -n "$url"
            mpv --no-video "$url"
        else
            echo "No results found."
        end
    end
end
