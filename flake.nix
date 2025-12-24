{
  description = "NixOS Plymouth Theme - Nix Bloom";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "nixos-plymouth-nix-bloom";
        version = "0.1.0";
        src = ./.;

        dontBuild = true;

        installPhase = ''
          mkdir -p $out/share/plymouth/themes/nix-bloom
          cp * $out/share/plymouth/themes/nix-bloom/
          
          # Fix paths in .plymouth file
          sed -i "s@/usr/share/plymouth/themes/nix-bloom@$out/share/plymouth/themes/nix-bloom@g" $out/share/plymouth/themes/nix-bloom/nix-bloom.plymouth
        '';

        meta = with pkgs.lib; {
          description = "NixOS Plymouth nix-bloom theme";
          platforms = platforms.linux;
        };
      };
    };
}
