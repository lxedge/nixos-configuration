{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    google-chrome
    brave
    telegram-desktop
    wechat-uos
    qqmusic
    discord
    #
    corectrl
    wezterm
    emacs-pgtk
    vscode
    claude-code
    dbeaver-bin
    k3s
    pandoc
    bun
  ];
}
