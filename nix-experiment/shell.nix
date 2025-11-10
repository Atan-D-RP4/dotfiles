{ config, ... }:

{
  home.shellAliases = {
    g = "git";
    gs = "git status";
    t = "tmux";
    ll = "ls -l";
  };
}