# based on https://github.com/crystal-lang/crystal/blob/master/shell.nix
#
# This nix-shell script can be used to get a complete development environment
# for the Crystal compiler.
#
# You can choose which llvm version use and, on Linux, choose to use musl.
#
# $ nix-shell --pure
# $ nix-shell --pure --arg llvm 10
# $ nix-shell --pure --arg llvm 10 --arg musl true
# $ nix-shell --pure --arg llvm 9
# $ nix-shell --pure --arg llvm 9 --argstr system i686-linux
# ...
# $ nix-shell --pure --arg llvm 6
#
# Futhermore you can add choose to install further software to test the bot against
# an actual syncplay server
#
# $ nix-shell --pure --arg testing true
#
# If needed, you can use https://app.cachix.org/cache/crystal-ci to avoid building
# packages that are not available in Nix directly. This is mostly useful for musl.
#
# $ nix-env -iA cachix -f https://cachix.org/api/v1/install
# $ cachix use crystal-ci
# $ nix-shell --pure --arg musl true
#

{llvm ? 10, musl ? false, system ? builtins.currentSystem, testing ? false}:

let
  nixpkgs = import (builtins.fetchTarball {
    name = "nixpkgs-20.03";
    url = "https://github.com/NixOS/nixpkgs/archive/2d580cd2793a7b5f4b8b6b88fb2ccec700ee1ae6.tar.gz";
    sha256 = "1nbanzrir1y0yi2mv70h60sars9scwmm0hsxnify2ldpczir9n37";
  }) {
    inherit system;
  };

  pkgs = if musl then nixpkgs.pkgsMusl else nixpkgs;

  genericBinary = { url, sha256 }:
    pkgs.stdenv.mkDerivation rec {
      name = "crystal-binary";
      src = builtins.fetchTarball { inherit url sha256; };

      buildCommand = ''
        mkdir -p $out

        # Darwin packages use embedded/bin/crystal
        if [ -f "${src}/embedded/bin/crystal" ]; then
          cp -R ${src}/{src,bin,embedded/*} $out/
        fi
        # Linux packages use lib/crystal/bin/crystal
        if [ -f "${src}/lib/crystal/bin/crystal" ]; then
          cp -R ${src}/* $out
          cp -R ${src}/share/crystal/src $out
        fi
      '';
    };

  # Hashes obtained using `nix-prefetch-url --unpack <url>`
  latestCrystalBinary = genericBinary ({
    x86_64-darwin = {
      url = "https://github.com/crystal-lang/crystal/releases/download/1.2.2/crystal-1.2.2-1-darwin-universal.tar.gz";
      sha256 = "sha256:1y7bcwl6jybg28sdd9xrgkxbz3ysdqn1jlgapi50avc47h30kgbb";
    };

    x86_64-linux = {
      url = "https://github.com/crystal-lang/crystal/releases/download/1.2.2/crystal-1.2.2-1-linux-x86_64.tar.gz";
      sha256 = "sha256:1cxkyq7n2xw6h9c99h28c2ssf3viiw1vigb0w6l2rpnw4f55fbqz";
    };
  }.${pkgs.stdenv.system});

  pkgconfig = pkgs.pkgconfig;

  llvm_suite = ({
    llvm_10 = {
      llvm = pkgs.llvm_10;
      extra = [ pkgs.lld_10 pkgs.lldb_10 ];
    };
    llvm_9 = {
      llvm = pkgs.llvm_9;
      extra = [ ]; # lldb it fails to compile on Darwin
    };
    llvm_8 = {
      llvm = pkgs.llvm_8;
      extra = [ ]; # lldb it fails to compile on Darwin
    };
    llvm_7 = {
      llvm = pkgs.llvm;
      extra = [ pkgs.lldb ];
    };
    llvm_6 = {
      llvm = pkgs.llvm_6;
      extra = [ ]; # lldb it fails to compile on Darwin
    };
  }."llvm_${toString llvm}");

  boehmgc = pkgs.stdenv.mkDerivation rec {
    pname = "boehm-gc";
    version = "8.2.0";

    src = builtins.fetchTarball {
      url = "https://github.com/ivmai/bdwgc/releases/download/v${version}/gc-${version}.tar.gz";
      sha256 = "0f3m27sfc4wssdvk32vivdg64b04ydw0slxm45zdv23qddrihxq4";
    };

    configureFlags = [
      "--disable-debug"
      "--disable-dependency-tracking"
      "--disable-shared"
      "--enable-large-config"
    ];

    enableParallelBuilding = true;
  };

  stdLibDeps = with pkgs; [
      boehmgc gmp libevent libiconv libxml2 libyaml openssl pcre zlib
    ] ++ stdenv.lib.optionals stdenv.isDarwin [ libiconv ];

  tools = with pkgs; [ pkgs.hostname pkgs.git llvm_suite.extra ] ++ lib.optionals testing [ syncplay openssl ];
  libraries = with pkgs; lib.strings.concatStringsSep ":" (lib.lists.forEach stdLibDeps (x: "${x}/lib/"));
in

pkgs.stdenv.mkDerivation rec {
  name = "crystal-dev";

  buildInputs = tools ++ stdLibDeps ++ [
    latestCrystalBinary
    pkgconfig
    llvm_suite.llvm
    pkgs.libffi
  ];

  LLVM_CONFIG = "${llvm_suite.llvm}/bin/llvm-config";
  CRYSTAL_LIBRARY_PATH = "${libraries}:${latestCrystalBinary}/lib";
  CRYSTAL_PATH = "lib:${latestCrystalBinary}/src/";

  MACOSX_DEPLOYMENT_TARGET = "10.11";
}
