{
  description = "Development environment with Node.js, npm, Pandoc, TeX Live, and bash";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          pkgs.pandoc
          pkgs.texlive.combined.scheme-full
        ];

        # Optional: helpful environment variables
        shellHook = ''
          echo "✅ Development environment loaded."
          echo "📦 Node version: $(node --version)"
          echo "📄 Pandoc version: $(pandoc --version | head -n 1)"
          echo "📝 XeLaTeX version: $(xelatex --version | head -n 1)"
        '';
      };
    });
}
