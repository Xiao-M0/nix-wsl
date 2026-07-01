{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wsl-module.url = "github:nix-community/nixos-wsl";
    nixos-vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    wsl-module,
    nixos-vscode-server,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    inputs = {
      inherit nixpkgs home-manager wsl-module nixos-vscode-server;
    };
  in {
    nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit pkgs inputs;};
      modules = [
        wsl-module.nixosModules.wsl
        home-manager.nixosModules.home-manager
        nixos-vscode-server.nixosModules.default
        ./system.nix
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.xiaomo = import ./home-manager.nix;
          home-manager.extraSpecialArgs = {inherit pkgs;};
        }
      ];
    };
  };
}
