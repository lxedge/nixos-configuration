{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  services.xserver.enable = true;
  services.xserver.xkb.options = "ctrl:nocaps";
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.v2raya.enable = true;
  services.v2raya.cliPackage = pkgs.xray;
  services.flatpak.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    man
    man-pages
    man-pages-posix
    libnotify
    vim
    wget
    nixfmt
    nixd
    tree
    zip
    unzip
    btop
    bat
    gcc
    cmake
    gnumake
    pkg-config
    libtool
    openssl
    ripgrep
    # ripgrep-all
    tokei
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    wqy_microhei
    fira-code
    nerd-fonts.fira-code
    nerd-fonts.meslo-lg
    nerd-fonts.jetbrains-mono
    maple-mono.CN
  ];
}
