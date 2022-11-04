{
  description = "rust-openssl flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fenix }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ fenix.overlay ] ++ [
          (self: super: rec {
            rust_pinned = self.fenix.default;
          })
        ];
      };
      rustPlatform = with pkgs; makeRustPlatform { inherit (rust_pinned) cargo rustc; };
    in
    rec {
      devShells.${system}.default = with pkgs; mkShell {
        nativeBuildInputs = [ pkgconfig openssl ];
        buildInputs = [ rust_pinned.toolchain ];
      };
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
    };
}
