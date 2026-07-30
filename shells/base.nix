{ pkgs }:

pkgs.mkShell {
  name = "base-dev-env";

  buildInputs = with pkgs; [
    libiconv
    gnumake
    git
    curl
    direnv
    nix-direnv
    jq
    yq
    just
    zellij
    kdlfmt
    podman
    podman-tui
    pandoc
  ];
}
