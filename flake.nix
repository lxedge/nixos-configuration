{
  description = "Personal NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    solc = {
      url = "github:hellwolf/solc.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      # flake-utils,
      home-manager,
      rust-overlay,
      solc,
      ...
    }@inputs:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      makePkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            rust-overlay.overlays.default
            solc.overlay
          ];
          config.allowUnfree = true;
        };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.miles = import ./home;
          }

          (
            { pkgs, ... }:
            let
              linuxPkgs = makePkgs "x86_64-linux";

              baseShell = import ./shells/base.nix { pkgs = linuxPkgs; };
              goShell = import ./shells/go.nix { pkgs = linuxPkgs; };
              webShell = import ./shells/web.nix { pkgs = linuxPkgs; };

              evmShell = import ./shells/evm.nix {
                pkgs = linuxPkgs;
                inherit solc;
              };
            in
            {
              nixpkgs.overlays = [ rust-overlay.overlays.default ];

              environment.systemPackages = [
                pkgs.rust-bin.stable.latest.default
              ]
              ++ baseShell.buildInputs
              ++ goShell.buildInputs
              ++ webShell.buildInputs
              ++ evmShell.buildInputs;
            }
          )
        ];
      };

      devShells = nixpkgs.lib.genAttrs supportedSystems (
        system:
        let
          targetPkgs = makePkgs system;
          baseShell = import ./shells/base.nix { pkgs = targetPkgs; };
          goShell = import ./shells/go.nix { pkgs = targetPkgs; };
          webShell = import ./shells/web.nix { pkgs = targetPkgs; };
        in
        {
          base = baseShell;
          go = goShell;
          web = webShell;
          kucoin = import ./shells/kucoin.nix {
            pkgs = targetPkgs;
            inherit baseShell goShell;
          };
          evm = import ./shells/evm.nix {
            pkgs = targetPkgs;
            inherit solc;
          };

        }
      );
    };
}
