#!/bin/bash

set -ev

JWT=$1
BRANCH=$2

curl 'https://storage.googleapis.com/genesis-public/cli/dev/bin/linux/amd64/whiteblock' --output ./wb
chmod +x ./wb

./wb login $JWT 2265

echo "building gethc node..."
./wb build -b ethclassic --git-repo https://github.com/etclabscore/go-ethereum.git --git-repo-branch development -n 1 -m 0 -c 0 -y -p0=8570:8545

echo "building parity node..."
./wb build append -b parity -n 1 -m 0 -c 0 -y -p0=8571:8545

echo "pulling latest testing script from github..."
git clone https://github.com/ChainSafe/Attalus.git
cd ./Attalus
git fetch origin
git checkout origin/stephanie/whiteblockChainID
yarn install

PK=0x$(../wb get account info | jq '.[].privateKey' | tr -d '"')

echo $PK

echo "running script"
yarn start --pk $PK --rpcport http://wbm-greg.boxes.whiteblock.io:8570  && ../wb done