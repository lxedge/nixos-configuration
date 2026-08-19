{ pkgs }:

pkgs.mkShell {
  name = "evm-dev-env";

  buildInputs = with pkgs; [
    nodejs_26
    typescript
    typescript-language-server
    prettier
    eslint
    pnpm
    yarn
    solc-select
    vscode-solidity-server
    foundry
  ];

  shellHook = ''
    echo "------ EVM development env loaded:"
    echo "--- node:        $(node -v)"
    echo "--- npm:         $(npm -v)"
    echo "--- pnpm:        $(pnpm -v)"
    echo "--- yarn:        $(yarn -v)"
    echo "--- tsc:         $(tsc -v)"
    echo "--- forge:       $(forge --version)"
    echo "--- solc-select: $(solc-select versions 2>/dev/null | tr '\n' ' ')"
    echo "------ EVM development env loaded."
  '';
}
