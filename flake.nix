{
  description = "ML env with GPU for CUDA and Metal";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ];
          config.allowUnfree = true;
          config.cudaSupport = true;
        };
      in
      {
        devShell =
          if pkgs.stdenv.isLinux
          then (pkgs.buildFHSUserEnv {
            name = "cuda-env";
            targetPkgs = pkgs:
              with pkgs;
              [
                ollama
                python312
                python312Packages.pip
                python312Packages.virtualenv
                cudaPackages.cudatoolkit
                cudaPackages.cudnn
                linuxPackages.nvidia_x11
              ];
            runScript = "zsh";
            profile = ''
              CUDA_PATH=${pkgs.cudaPackages.cudatoolkit}
            '';
          }).env
          else
            pkgs.mkShell.override { } {
              # runtime environment
              buildInputs = with pkgs;
                [
                  ollama
                  python312
                  python312Packages.pip
                  python312Packages.virtualenv
                ];
              # ++ lib.optionals pkgs.stdenv.isDarwin [
              #   pkgs.libiconv
              #   pkgs.darwin.apple_sdk.frameworks.Metal
              #   pkgs.darwin.apple_sdk.frameworks.MetalPerformanceShaders
              #   pkgs.darwin.apple_sdk.frameworks.Security
              #   pkgs.darwin.apple_sdk.frameworks.CoreServices
              #   pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
              # ];
            };
      }
    );
}

