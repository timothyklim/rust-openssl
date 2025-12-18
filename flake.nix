{
  description = "rust-openssl flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, fenix }:
    with flake-utils.lib; eachSystem [ system.x86_64-linux system.aarch64-linux system.aarch64-darwin ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ fenix.overlays.default ] ++ [
            (self: super: rec {
              rust_pinned = self.fenix.default;
            })
          ];
        };
        rustPlatform = with pkgs; makeRustPlatform { inherit (rust_pinned) cargo rustc; };
      in
      rec {
        devShell = with pkgs; mkShell {
          nativeBuildInputs = [ pkg-config openssl ] ++ lib.optionals stdenv.isDarwin [ libiconv ];
          buildInputs = [ rust_pinned.toolchain ];
        };
        formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      });
}
