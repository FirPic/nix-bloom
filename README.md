# NixOS Plymouth Theme: Nix Bloom

This repository packages the "nix-bloom" Plymouth theme for use with NixOS.

## Usage in NixOS

You can use this theme by adding the flake to your system configuration.

### Using Flakes

1.  Add the input to your `flake.nix`:

    ```nix
    {
      inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        
        # Add this theme as an input
        plymouth-theme.url = "path:/path/to/extracted/folder/nixos-plymouth-load-unload";
        # OR if pushed to git:
        # plymouth-theme.url = "github:username/repo";
      };

      outputs = { self, nixpkgs, plymouth-theme, ... }: {
        nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            {
              # Overlay or directly add the package
              nixpkgs.overlays = [
                (final: prev: {
                  load-unload-theme = plymouth-theme.packages.${prev.system}.default;
                })
              ];
            }
          ];
        };
      };
    }
    ```

2.  Configure Plymouth in your `configuration.nix`:

    ```nix
    { config, pkgs, ... }:

    {
      boot.plymouth = {
        enable = true;
        theme = "nix-bloom";
        themePackages = [ pkgs.load-unload-theme ];
      };
    }
    ```

### Without Flakes (Standalone Derivation)

If you are not using flakes, you can simple import the derivation.

1.  In `configuration.nix`:

    ```nix
    { config, pkgs, ... }:
    
    let 
      loadUnloadTheme = pkgs.callPackage ./path/to/nixos-plymouth-load-unload/package.nix {};
      # Note: You would need to extract the derivation logic from flake.nix into a package.nix 
      # or simply use callPackage on a folder if it had a default.nix.
      # Since we are using a flake.nix, it is easiest to just use `builtins.getFlake` if you have a flake-compatible nix version enabled.
    in
    {
      boot.plymouth = {
        enable = true;
        theme = "nix-bloom";
        themePackages = [ 
           (pkgs.stdenv.mkDerivation {
              pname = "nixos-plymouth-load-unload";
              version = "0.1.0";
              src = ./path/to/theme/files; # Point this to the local folder
              
              dontBuild = true;
              
              installPhase = ''
                mkdir -p $out/share/plymouth/themes/nix-bloom
                cp * $out/share/plymouth/themes/nix-bloom/
                sed -i "s@/usr/share/plymouth/themes/nix-bloom@$out/share/plymouth/themes/nix-bloom@g" $out/share/plymouth/themes/nix-bloom/nix-bloom.plymouth
              '';
           })
        ];
      };
    }
    ```

## Testing

After rebuilding (`nixos-rebuild switch`), you can test the theme without rebooting (if plymouth is running, though usually a reboot is best):

```bash
sudo plymouthd ; sudo plymouth --show-splash ; sleep 5; sudo plymouth --quit
```
