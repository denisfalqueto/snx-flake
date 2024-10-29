{
  description = "Linux client for Checkpoint VPN tunnels";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        nativeBuildInputs = with pkgs; [
            which
            su
        ];

        buildInputs = with pkgs; [
            libstdcxx5
        ];
      in
      {
        packages.snx = pkgs.stdenv.mkDerivation rec {
          inherit nativeBuildInputs buildInputs;
          pname = "snx";
          version = "1.0.0";

          src = pkgs.requireFile {
            name = "snx_install.sh";
            url = "https://192.100.177.1";
            hash = "sha256-HjTsiI+6nyfHV2xL6stHpiIcbaVv/JdB8uUYGFX7WiU=";
          };
          dontUnpack = true;

          buildPhase = ''
            # ARCHIVE_OFFSET FROM snx_install.sh FILE
            ARCHIVE_OFFSET=103

            tail -n +$ARCHIVE_OFFSET ${src} > ./snx.tar.bz2
            tar -xvf ./snx.tar.bz2
          '';

          installPhase = ''
            install -D -m0755 "snx" "$out/usr/bin/snx"
            install -d -m0700 "$out/etc/snx"
            install -d -m0700 "$out/etc/snx/tmp"
          '';

          meta = {
            description = "Linux client for Checkpoint VPN tunnels";
            homepage = "https://192.100.177.1";
          };
        };

        defaultPackage = self.packages.${system}.snx;

        nixosModules = {
          config = {
            environment.systemPackages = [ self.defaultPackage.${system} ];
          };
        };
      }
    );
}
