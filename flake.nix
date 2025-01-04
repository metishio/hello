{
  description = "example server";

  # Add your nix dependencies here.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    garnix-lib.url = "github:garnix-io/garnix-lib";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ]
      (system:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        {
          # Here you can define packages that your flake outputs.
          packages = {
            backend = pkgs.callPackage ./backend { };
          };
          devShells.default = pkgs.mkShell
            {
              # nativeBuildInputs = [ pkgs.nodejs pkgs.go pkgs.gopls ];
              nativeBuildInputs = [ pkgs.go pkgs.gopls ];
            };
        })
    //
    {
      nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          inputs.garnix-lib.nixosModules.garnix
          {
            _module.args = { self = inputs.self; };
          }
          # This is where the server is defined.
          ./hosts/server.nix
        ];
      };
    };
}
