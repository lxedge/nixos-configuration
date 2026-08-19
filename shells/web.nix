{ pkgs }:

pkgs.mkShell {
  name = "web-dev-env";

  buildInputs = with pkgs; [
    nodejs
    pnpm
    typescript
    typescript-language-server
    vscode-langservers-extracted
    biome
    bun
  ];

  shellHook = ''
    export PATH="$PWD/node_modules/.bin:$PATH"

    echo "------ Web development env loaded:"
    echo "--- node:  $(node --version)"
    echo "--- pnpm:  $(pnpm --version)"
    echo "--- tsc:   $(tsc --version)"
    echo "--- biome: $(biome --version)"
    echo "------ Web development env loaded."
  '';
}
