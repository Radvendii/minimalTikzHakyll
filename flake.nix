{
  description = "Minimal Tikz Hakyll Example";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    inherit (nixpkgs) lib;
    pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) stdenv glibcLocales mkShell haskellPackages makeWrapper;
      name = "minimalTikzHakyll";
      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          ./css
          ./index.md
          ./templates
          ./site.hs
          ./package.yaml
        ];
      };
      builder = haskellPackages.callCabal2nix name src {};
      haskell-env = pkgs.ghc.withHoogle (hp: with hp; [ haskell-language-server cabal-install ] ++ builder.buildInputs);
      websiteBuildInputs = with pkgs; [
        # other inputs you need to build the website. e.g.
        rubber
        texliveFull
        poppler_utils
      ];
      wrappedBuilder = stdenv.mkDerivation {
        name = "${name}-builder-wrapped";
        src = builder;
        nativeBuildInputs = [
          makeWrapper
        ];
        buildCommand = ''
          cp -r $src $out
          chmod -R +w $out
          wrapProgram $out/bin/${name} \
            --prefix PATH : ${lib.makeBinPath websiteBuildInputs}
        '';
      };
  in {
    packages = rec {
      inherit (pkgs) rubber poppler_utils;
      texlive = pkgs.texliveFull;

      inherit builder wrappedBuilder;
      default = website;
      website = stdenv.mkDerivation {
        inherit name src;
        buildInputs = [ builder ] ++ websiteBuildInputs;
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
        # don't look in fcaches for this; speeds things up a little
        allowSubstitutes = false;
        buildPhase = ''
          ${name} build
        '';
        installPhase = ''
          cp -R _site $out
        '';
        dontStrip = true;
      };
    };
    devShells.default = mkShell {
      name = "${name}-env";
      buildInputs = [ haskell-env ] ++ websiteBuildInputs;

      shellHook = ''
        export HAKYLL_ENV="development"

        export HIE_HOOGLE_DATABASE="${haskell-env}/share/doc/hoogle/default.hoo"
        export NIX_GHC="${haskell-env}/bin/ghc"
        export NIX_GHCPKG="${haskell-env}/bin/ghc-pkg"
        export NIX_GHC_DOCDIR="${haskell-env}/share/doc/ghc/html"
        export NIX_GHC_LIBDIR=$( $NIX_GHC --print-libdir )
      '';
    };
    apps.default = {
      type = "app";
      program = wrappedBuilder + "/bin/${name}";
    };
  });
}
