{
  description = "A nix-flake-based coq development environment with tlc";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachSystem
      [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ]
      (
        system:
        let
          coq-overlay = final: prev: {
            coq-tlc = import ./.nix/coq-overlays/tlc {
              inherit (final) lib which;
              inherit (final.coqPackages) mkCoqDerivation coq;
            };
          };
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ coq-overlay ];
          };
        in
        {
          devShells.default = pkgs.mkShell {
            packages =
              (with pkgs; [
                coq
                ocaml
                ocamlformat
                coq-tlc
              ])
              ++ (with pkgs.ocamlPackages; [
                dune_3
                findlib # Note: [findlib] is necessary for [dune] to find [pprint].
                odoc
                pprint
                menhir
              ]);
          };
        }
      );
}
