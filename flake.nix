{
  description = "lukebentleyfox.net flake";
  
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixops-plugged.url  = "github:lukebfox/nixops-plugged";
    utils.url   = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, nixops-plugged, utils, ... }:
    let
      domain = "lukebentleyfox.net";
      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      };
    in {
      overlay = final: prev: {
        blog = prev.callPackage ./blog {};
      };
      
      nixopsConfigurations.default = {
        inherit nixpkgs;
        network.description = domain;
        defaults.nixpkgs.pkgs = pkgsFor "x86_64-linux";
        defaults._module.args = {
          inherit domain;
        };
        webserver = import ./machine;
      };

    } // utils.lib.eachDefaultSystem (system:
      let pkgs = pkgsFor system;
      in {
        defaultPackage = pkgs.blog;
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.zola
            nixops-plugged.defaultPackage.${system}
          ];
        };
      });
}
