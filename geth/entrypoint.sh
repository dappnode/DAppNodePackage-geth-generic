#!/bin/sh

handle_network() {
  case "$NETWORK" in
  "holesky")
    export GETH_HOLESKY=true
    set_network_specific_config
    ;;
  "lukso")
    set_network_specific_config "--networkid 42 --miner.gasprice 1000000000 --miner.gaslimit 42000000 --bootnodes enode://c2bb19ce658cfdf1fecb45da599ee6c7bf36e5292efb3fb61303a0b2cd07f96c20ac9b376a464d687ac456675a2e4a44aec39a0509bcb4b6d8221eedec25aca2@34.147.73.193:30303,enode://276f14e4049840a0f5aa5e568b772ab6639251149a52ba244647277175b83f47b135f3b3d8d846cf81a8e681684e37e9fc10ec205a9841d3ae219aa08aa9717b@34.32.192.211:30303 --maxpeers 50"
    ;;
  "mainnet")
    export GETH_MAINNET=true
    set_network_specific_config
    ;;
  "sepolia")
    export GETH_SEPOLIA=true
    set_network_specific_config
    ;;
  *)
    echo "Unsupported network: $NETWORK"
    exit 1
    ;;
  esac
}

set_network_specific_config() {
  config_flags=$1

  if [ -n "$config_flags" ]; then
    EXTRA_FLAGS="$config_flags $EXTRA_FLAGS"
  fi

  echo "[INFO - entrypoint] Initializing $NETWORK specific config for client"

  set_consensus_dnp

  # If consensus client is prysm-prater.dnp.dappnode.eth --> CLIENT=prysm
  consensus_client=$(echo "$CONSENSUS_DNP" | cut -d'.' -f1 | cut -d'-' -f1)

  if [ "$NETWORK" = "sepolia" ]; then
    set_jwt_path "sepolia"
  else
    set_jwt_path "$consensus_client"
  fi

  [ "$1" = "lukso" ] && geth --datadir="$DATA_DIR" init /config/genesis.json

}

set_consensus_dnp() {
  uppercase_network=$(echo "$NETWORK" | tr '[:lower:]' '[:upper:]')
  consensus_dnp_var="_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_${uppercase_network}"
  eval "CONSENSUS_DNP=\${$consensus_dnp_var}"
}

set_jwt_path() {
  consensus_client=$1
  echo "[INFO - entrypoint] Using $consensus_client JWT"
  JWT_PATH="/security/$consensus_client/jwtsecret.hex"

  if [ ! -f "${JWT_PATH}" ]; then
    echo "[ERROR - entrypoint] JWT not found at ${JWT_PATH}"
    exit 1
  fi
}

post_jwt_to_dappmanager() {
  echo "[INFO - entrypoint] Posting JWT to Dappmanager"
  JWT=$(cat "${JWT_PATH}")

  curl -X POST "http://my.dappnode/data-send?key=jwt&data=${JWT}" || {
    echo "[ERROR - entrypoint] JWT could not be posted to package info"
  }
}

run_client() {
  # shellcheck disable=SC2086
  exec geth \
    --datadir "${DATA_DIR}" \
    --syncmode "${SYNCMODE:-snap}" \
    --port "${P2P_PORT}" \
    --authrpc.jwtsecret "${JWT_PATH}" ${EXTRA_FLAGS}
}

handle_network
post_jwt_to_dappmanager
run_client
