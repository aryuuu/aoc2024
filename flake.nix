{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = { self, nixpkgs, systems, ... } @ inputs:
    let
      inherit (nixpkgs) lib;
      eachSystem = lib.genAttrs (import systems);
      pkgsFor = eachSystem (system:
        import nixpkgs {
          system = system;
          overlays = [
            # Other overlays
            (final: prev: {
              zigpkgs = inputs.zig.packages.${prev.system};
              zig = inputs.zig.packages.${prev.system};
            })
          ];
        }
      );
    in
    {
      devShells = eachSystem (system: {
        default = pkgsFor.${system}.mkShell {
          packages = [ 
            pkgsFor.${system}.zig."master" 
            pkgsFor.${system}.fish 
          ];
        };
      });
    };
}
