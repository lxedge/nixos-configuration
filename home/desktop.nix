{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    google-chrome
    brave
    telegram-desktop
    wechat-uos
    feishu
    # qqmusic
    discord
    zoom-us
    #
    corectrl
    wezterm
    emacs-pgtk
    vscode
    claude-code
    inputs.oh-my-pi.packages.${pkgs.system}.default
    dbeaver-bin
    k3s
    pandoc
    bun
  ];
}
