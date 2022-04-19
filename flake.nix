{
  description = "Minimal Tikz Hakyll Example";
  inputs.hakyll-flakes.url = "github:Radvendii/hakyll-flakes";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { self, hakyll-flakes, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (
      system:
      nixpkgs.lib.recursiveUpdate
      (hakyll-flakes.lib.mkAllOutputs {
        inherit system;
        name = "minimalTikzHakyll";
        src = ./.;
        websiteBuildInputs = with nixpkgs.legacyPackages.${system}; [
          rubber
          texlive.combined.scheme-full
          poppler_utils
        ];
      }) {
        packages = { inherit (nixpkgs.legacyPackages.${system}) rubber poppler_utils; texlive = nixpkgs.legacyPackages.${system}.texlive.combined.scheme-full; };
      }
    );
}
