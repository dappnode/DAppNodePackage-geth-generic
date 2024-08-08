#!/bin/sh

# shellcheck disable=SC1091
. /etc/profile

JWT_SECRET=$(get_jwt_secret_by_network "${NETWORK}")
echo "${JWT_SECRET}" >"${JWT_PATH}"

case "$NETWORK" in
"holesky")
  NETWORK_FLAGS="--holesky"
  ;;
"lukso")
  NETWORK_FLAGS="--networkid 42 --miner.gasprice 1000000000 --miner.gaslimit 42000000 --bootnodes enode://c2bb19ce658cfdf1fecb45da599ee6c7bf36e5292efb3fb61303a0b2cd07f96c20ac9b376a464d687ac456675a2e4a44aec39a0509bcb4b6d8221eedec25aca2@34.147.73.193:30303,enode://276f14e4049840a0f5aa5e568b772ab6639251149a52ba244647277175b83f47b135f3b3d8d846cf81a8e681684e37e9fc10ec205a9841d3ae219aa08aa9717b@34.32.192.211:30303 --maxpeers 50"
  geth --datadir="$DATA_DIR" init /config/genesis.json
  ;;
"mainnet")
  NETWORK_FLAGS="--mainnet"
  ;;
"sepolia")
  NETWORK_FLAGS="--sepolia"
  ;;
*)
  echo "[ERROR - entrypoint] Unsupported network: $NETWORK"
  exit 1
  ;;
esac

echo "[INFO - entrypoint] Starting geth with network flags: $NETWORK_FLAGS"

post_jwt_to_dappmanager "${JWT_PATH}"

# shellcheck disable=SC2086
exec geth \
  --datadir "${DATA_DIR}" \
  --syncmode "${SYNCMODE:-snap}" \
  --port "${P2P_PORT}" \
  --authrpc.jwtsecret "${JWT_PATH}" ${NETWORK_FLAGS} ${EXTRA_OPTS}
