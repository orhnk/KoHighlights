{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = [
    pkgs.python3
    pkgs.python3Packages.pyside2
    pkgs.python3Packages.beautifulsoup4
    pkgs.python3Packages.requests
    pkgs.python3Packages.packaging
    pkgs.python3Packages.future
  ];
}
