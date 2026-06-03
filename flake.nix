{
  description = "A Nix-flake-based Zig development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # stable Nixpkgs

  outputs =
    { self, ... }@inputs:

    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import inputs.nixpkgs {
              inherit system;
            };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs, system }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              zig
              zls
              lldb
              elan
              self.formatter.${system}
            ];

            # elan's `lean`/`lake` are symlinks to a multi-call binary that
            # dispatches on argv[0]; Zig's findProgram resolves symlinks and
            # breaks that. Put the active toolchain's real binaries on PATH.
            shellHook = ''
              if lean_path=$(elan which lean 2>/dev/null); then
                export PATH="$(dirname "$lean_path"):$PATH"
              else
                echo "elan: could not resolve the toolchain pinned in lean-toolchain (network needed on first run?)" >&2
              fi
            '';
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs, ... }: pkgs.nixfmt);
    };
}
