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

    oh-my-pi = {
      url = "github:can1357/oh-my-pi";
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
            home-manager.users.miles = {
              imports = [ ./home ];
              _module.args = { inherit inputs; };
            };
          }

          (
            { pkgs, ... }:
            let
              linuxPkgs = makePkgs "x86_64-linux";

              baseShell = import ./shells/base.nix { pkgs = linuxPkgs; };
              goShell = import ./shells/go.nix { pkgs = linuxPkgs; };
              webShell = import ./shells/web.nix { pkgs = linuxPkgs; };
              evmShell = import ./shells/evm.nix { pkgs = linuxPkgs; };
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
          evmShell = import ./shells/evm.nix { pkgs = targetPkgs; };
        in
        {
          base = baseShell;
          go = goShell;
          web = webShell;
          evm = evmShell;
          kucoin = import ./shells/kucoin.nix {
            pkgs = targetPkgs;
            inherit
              baseShell
              goShell
              webShell
              evmShell
              ;
          };

        }
      );
    };
}
