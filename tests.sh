#!/usr/bin/env nix-shell
#!nix-shell shell.nix --arg testing true -i bash
set -euo pipefail

pushd spec/test_certs
./create_certs.sh
popd

crystal spec
crystal tool format --check