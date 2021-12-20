{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/0fe6b1ccde4f80ff7a3c969dffb57a811932dc38.tar.gz") { }
}:

pkgs.crystal.buildCrystalPackage rec {
  pname = "dmnd_bot";
  version = "0.2.0";
  src = builtins.path { path = ./.; name = pname; };

  format = "shards";

  postPatch = ''
    substituteInPlace spec/syncplay_bot_spec.cr \
        --replace 'syncplay' '${pkgs.syncplay}/bin/syncplay' 
  '';

  checkInputs = [
    pkgs.syncplay
  ];
}
