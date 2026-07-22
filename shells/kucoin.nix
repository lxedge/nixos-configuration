{
  pkgs,
  baseShell,
  goShell,
}:

let
  privateRepo = "bitbucket.kucoin.net";
in
pkgs.mkShell {
  inputsFrom = [
    baseShell
    goShell
  ];

  shellHook = ''
    if command -v go >/dev/null 2>&1; then
      go env -w GOPRIVATE="${privateRepo}"
      go env -w GONOSUMDB="${privateRepo}"
    fi

    if [ -d .git ]; then
      git config core.hooksPath .githooks
      echo "git hooks configured"
    fi
  '';
}
