#!/bin/sh

SUPPORTED_NETWORKS="holesky mainnet"

# shellcheck disable=SC1091
. /etc/profile

handle_network() {
  case "$NETWORK" in
  "holesky")
    set_execution_config_by_network "${NETWORK}" "${SUPPORTED_NETWORKS}" "--holesky"
    ;;
  "lukso")
    set_execution_config_by_network "${NETWORK}" "${SUPPORTED_NETWORKS}" "--networkid 42 --miner.gasprice 1000000000 --miner.gaslimit 42000000 --bootnodes enode://c2bb19ce658cfdf1fecb45da599ee6c7bf36e5292efb3fb61303a0b2cd07f96c20ac9b376a464d687ac456675a2e4a44aec39a0509bcb4b6d8221eedec25aca2@34.147.73.193:30303,enode://276f14e4049840a0f5aa5e568b772ab6639251149a52ba244647277175b83f47b135f3b3d8d846cf81a8e681684e37e9fc10ec205a9841d3ae219aa08aa9717b@34.32.192.211:30303 --maxpeers 50"
    geth --datadir="$DATA_DIR" init /config/genesis.json

    ;;
  "mainnet")
    set_execution_config_by_network "${NETWORK}" "${SUPPORTED_NETWORKS}" "--mainnet"
    ;;
  "sepolia")
    set_execution_config_by_network "${NETWORK}" "${SUPPORTED_NETWORKS}" "--sepolia"
    export JWT_PATH="/security/sepolia/jwtsecret.hex"
    ;;
  esac

}

run_client() {
  # shellcheck disable=SC2086
  exec geth \
    --datadir "${DATA_DIR}" \
    --syncmode "${SYNCMODE:-snap}" \
    --port "${P2P_PORT}" \
    --authrpc.jwtsecret "${JWT_PATH}" ${EXTRA_OPTS}
}

handle_network
post_jwt_to_dappmanager
run_client
