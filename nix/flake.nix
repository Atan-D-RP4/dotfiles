{
  description = "Atan's NixOS + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Helper: standalone HM config (for testing without NixOS)
      mkHome = username: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./hosts/${username}/home.nix ];
      };

      # Helper: NixOS config with HM as module
      mkHost = hostname: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${hostname}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.atan = ./hosts/${hostname}/home.nix;
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };
    in
    {
      # Standalone Home Manager (test without NixOS)
      homeConfigurations."atan" = mkHome "atan";

      # NixOS system configs (add your hosts here)
      nixosConfigurations = {
        # atan-desktop = mkHost "atan-desktop";
        # atan-laptop = mkHost "atan-laptop";
      };
    };
}
