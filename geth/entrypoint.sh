#!/bin/sh

set_jwt_path() {
  CLIENT=$1
  echo "Using $CLIENT JWT"
  JWT_PATH="/security/$CLIENT/jwtsecret.hex"
}

set_network_specific_config() {
  CONSENSUS_DNP=$1
  P2P_PORT=$2
  EXTRA_FLAGS="$3 $EXTRA_FLAGS"

  echo "[INFO - entrypoint] Initializing $NETWORK specific config for client"

  # If consensus client is prysm-prater.dnp.dappnode.eth --> CLIENT=prysm
  CLIENT=$(echo $CONSENSUS_DNP | cut -d'.' -f1 | cut -d'-' -f1)

  # TODO: This should be a global env for all the networks
  [ "$NETWORK" = "sepolia" ] && set_jwt_path "sepolia" || set_jwt_path "$CLIENT"

  [ "$1" = "lukso" ] && geth --datadir="$DATA_DIR" init /config/genesis.json

}

JWT=$(cat "$JWT_PATH") || {
  echo "[ERROR - entrypoint] Reading JWT file failed"
  exit 1
}

curl -X POST "http://my.dappnode/data-send?key=jwt&data=${JWT}" || {
  echo "[ERROR - entrypoint] JWT could not be posted to package info"
}

case "$NETWORK" in
"goerli") set_network_specific_config "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_PRATER" 30803 "--goerli" ;;
"holesky") set_network_specific_config "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_HOLESKY" 31403 "--holesky" ;;
"lukso")
  set_network_specific_config "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_LUKSO" 33141 "--networkid 42 --miner.gasprice 4200000000 --miner.gaslimit 42000000 --bootnodes enode://c2bb19ce658cfdf1fecb45da599ee6c7bf36e5292efb3fb61303a0b2cd07f96c20ac9b376a464d687ac456675a2e4a44aec39a0509bcb4b6d8221eedec25aca2@34.147.73.193:30303,enode://276f14e4049840a0f5aa5e568b772ab6639251149a52ba244647277175b83f47b135f3b3d8d846cf81a8e681684e37e9fc10ec205a9841d3ae219aa08aa9717b@34.32.192.211:30303 --maxpeers 50"
  ;;
"mainnet") set_network_specific_config "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_MAINNET" 30403 "--mainnet" ;;
"sepolia") set_network_specific_config "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_SEPOLIA" 35415 "--sepolia" ;;
*)
  echo "Unsupported network: $NETWORK"
  exit 1
  ;;
esac

exec geth \
  --datadir $DATA_DIR \
  --syncmode ${SYNCMODE:-snap} \
  --port ${P2P_PORT} \
  --authrpc.jwtsecret ${JWT_PATH} \
  $EXTRA_FLAGS
