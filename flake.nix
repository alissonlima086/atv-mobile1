{
  description = "Dev shell Flutter - Warframe Codex";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        androidComposition = pkgs.androidenv.composeAndroidPackages {
          platformVersions = [ "33" "34" "35" "36" ];
          buildToolsVersions = [ "34.0.0" "35.0.0" "36.0.0" "28.0.3" ];
          includeEmulator = false;
          includeSystemImages = false;
          includeNDK = true;
          ndkVersions = [ "28.2.13676358" ];
          extraLicenses = [
            "android-googletv-license"
            "android-sdk-arm-dbt-license"
            "android-sdk-preview-license"
            "google-gdk-license"
            "intel-android-extra-license"
            "intel-android-sysimage-license"
            "mips-android-sysimage-license"
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            flutter
            gnumake
            androidComposition.androidsdk
            jdk17

            libGL
            libx11
            libxext
            libxrender
          ];

          ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
          ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
          ANDROID_NDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk/ndk/28.2.13676358";
          JAVA_HOME = "${pkgs.jdk17}";

          shellHook = ''
            export PATH="$PATH:$HOME/.pub-cache/bin"
            echo "Flutter dev shell - rode 'flutter doctor' para conferir o setup"
          '';
        };
      });
}

