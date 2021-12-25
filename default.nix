{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/a7ecde854aee5c4c7cd6177f54a99d2c1ff28a31.tar.gz") { }
}:

pkgs.crystal.buildCrystalPackage rec {
  pname = "dmnd-bot";
  version = "0.2.0";
  src = builtins.path { path = ./.; name = pname; };

  hardsFile = ./shards.nix;

  postPatch = ''
    substituteInPlace spec/syncplay_bot_spec.cr \
        --replace 'syncplay' '${pkgs.syncplay}/bin/syncplay' 
  '';

  checkInputs = [
    pkgs.syncplay
  ];
}
