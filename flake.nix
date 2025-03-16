{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      pythonEnv = pkgs.python3.withPackages (ps: [
        ps.pyside2
        ps.beautifulsoup4
        ps.requests
        ps.packaging
        ps.future
      ]);
    in {
      packages.default = pkgs.stdenv.mkDerivation {
        name = "kohighlights";
        src = ./.;

        nativeBuildInputs = [
          pkgs.qt5.wrapQtAppsHook
          pkgs.makeWrapper
          pkgs.copyDesktopItems
        ];

        buildInputs = [pythonEnv];

        desktopItems = [
          (pkgs.makeDesktopItem {
            name = "kohighlights";
            desktopName = "KoHighlights";
            exec = "kohighlights";
            icon = "kohighlights";
            categories = ["Utility"];
            comment = "Kindle Highlights Manager";
            terminal = false;
          })
        ];

        installPhase = ''
          mkdir -p $out/bin $out/share/kohighlights

          # Copy application files
          cp *.py $out/share/kohighlights/

          # Copy icons
          mkdir -p $out/share/icons/hicolor/48x48/apps
          cp assets/icon-48x48.png $out/share/icons/hicolor/48x48/apps/kohighlights.png

          # Create wrapper script
          makeWrapper ${pythonEnv}/bin/python $out/bin/kohighlights \
            --add-flags "$out/share/kohighlights/main.py" \
            --set QT_DEBUG_PLUGINS "1" \
            --prefix PYTHONPATH : "$out/share/kohighlights" \
            --prefix QT_PLUGIN_PATH : "${pkgs.qt5.qtbase.bin}/${pkgs.qt5.qtbase.qtPluginPrefix}"

          # Install desktop file (handled automatically by copyDesktopItems)
          install -Dm644 ${pkgs.makeDesktopItem {
            name = "kohighlights";
            desktopName = "KoHighlights";
            exec = "$out/bin/kohighlights";
            icon = "kohighlights";
            categories = ["Utility"];
            comment = "Kindle Highlights Manager";
            terminal = false;
          }}/share/applications/* $out/share/applications/kohighlights.desktop
        '';
      };

      apps.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/kohighlights";
      };

      devShells.default = pkgs.mkShell {
        packages = [
          pythonEnv
          pkgs.qt5.qtbase
        ];
      };
    });
}
