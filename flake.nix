{
  description = "ML env with GPU for CUDA and Metal";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
          ];
          config.allowUnfree = true;
          config.cudaSupport = true;
        };
      in {
        devShell =
          (pkgs.buildFHSUserEnv {
            name = "cuda-env";
            targetPkgs = pkgs: (with pkgs; [
              cudatoolkit
              linuxPackages.nvidia_x11
              ollama
              python312
              python312Packages.pip
              python312Packages.virtualenv
            ]);
            multiPkgs = pkgs: with pkgs; [zlib];
            runScript = "zsh";
            profile = ''
              DIRENV_DISABLE=avoid-recursion;
              CUDA_PATH=${pkgs.cudatoolkit}
              # LD_LIBRARY_PATH=${pkgs.linuxPackages.nvidia_x11}/lib
              EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
              EXTRA_CCFLAGS="-I/usr/include"
            '';
          })
          .env;

        # devShell = pkgs.mkShell.override {} {
        #   # build environment
        #   nativeBuildInputs = with pkgs;
        #     [
        #       # clang
        #       # openssl.dev
        #       # pkg-config
        #     ]
        #     ++ lib.optionals pkgs.stdenv.isLinux
        #     [
        #       cudaPackages.cudatoolkit
        #       cudaPackages.cudnn
        #       linuxPackages.nvidia_x11
        #     ];

        #   # runtime environment
        #   buildInputs = with pkgs;
        #     [
        #       cudaPackages.cudatoolkit
        #       cudaPackages.cudnn
        #       linuxPackages.nvidia_x11
        #       ollama
        #       python312
        #       python312Packages.pip
        #       python312Packages.virtualenv
        #     ]
        #     ++ lib.optionals pkgs.stdenv.isDarwin [
        #       pkgs.libiconv
        #       pkgs.darwin.apple_sdk.frameworks.Metal
        #       pkgs.darwin.apple_sdk.frameworks.MetalPerformanceShaders
        #       pkgs.darwin.apple_sdk.frameworks.Security
        #       pkgs.darwin.apple_sdk.frameworks.CoreServices
        #       pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
        #     ];

        # shellHook =
        #   if pkgs.stdenv.isLinux
        #   then ''
        #     # LD_LIBRARY_PATH="${pkgs.linuxPackages.nvidia_x11}/lib"
        #     # CUDA_ROOT="${pkgs.cudaPackages.cudatoolkit}"
        #     CUDA_PATH="${pkgs.cudaPackages.cudatoolkit}"
        #     CUDN_LIB="${pkgs.cudaPackages.cudnn}"
        #     EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
        #     EXTRA_CCFLAGS="-I/usr/include"
        #   ''
        #   else '''';

        # CUDA_ROOT =
        #   if pkgs.stdenv.isLinux
        #   then v"${pkgs.cudaPackages.cudatoolkit}"
        #   else "";
        # CUDA_PATH =
        #   if pkgs.stdenv.isLinux
        #   then "${pkgs.cudaPackages.cudatoolkit}"
        #   else "";
        # CUDNN_LIB =
        #   if pkgs.stdenv.isLinux
        #   then "${pkgs.cudaPackages.cudnn}"
        #   else "";

        # EXTRA_LDFLAGS =
        #   if pkgs.stdenv.isLinux
        #   then "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
        #   else "";

        # EXTRA_CCFLAGS = "-I/usr/include";
        # };

        # defaultPackage = pkgs.mkRustPackage {
        #   cargoSha256 = "46652094fc5f1f00761992c876b6712052edd15eefd93b2e309833a30af94a95";
        #   src = ./.;
        # };
      }
    );
}
