{
  description = "Home Manager configuration of jaysa";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "ocf-nix/nixpkgs";
    };
    firefox-addons = { url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"; inputs.nixpkgs.follows = "ocf-nix/nixpkgs"; };
    nix4nvchad = { url = "github:nix-community/nix4nvchad"; inputs.nixpkgs.follows = "ocf-nix/nixpkgs"; };
    ocf-nix.url = "github:ocf/nix";
    
    # Cosmic Applets
    ocf-paper-genmon-applet.url = "github:BNH440/ocf-paper-genmon-applet";
    ocf-logout-applet.url = "github:BNH440/ocf-logout-applet";
  };

  outputs =
    inputs@{ ocf-nix, home-manager, firefox-addons, ocf-paper-genmon-applet, ocf-logout-applet, ... }:
    let
      inherit (ocf-nix.inputs) nixpkgs;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      homeConfigurations."blakeh" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
	extraSpecialArgs = {
	  inherit system inputs;
	};
      };
    };
}
