#!/bin/sh

# shellcheck disable=SC1091
. /etc/profile

JWT_SECRET=$(get_jwt_secret_by_network "${NETWORK}")
echo "${JWT_SECRET}" >"${JWT_PATH}"

# https://github.com/lukso-network/network-configs/blob/main/mainnet/geth/geth.toml
LUKSO_BOOTNODES="enode://276f14e4049840a0f5aa5e568b772ab6639251149a52ba244647277175b83f47b135f3b3d8d846cf81a8e681684e37e9fc10ec205a9841d3ae219aa08aa9717b@34.32.192.211:30303,enode://681d89b95ec3fa21eac53959372b434ef252dcabbeb10ecbafe04e15b78d9078d16c5e374dc14a12703eb561dc0a7fe6c6165f355c3e52dfd0a0bfc554008325@178.104.110.158:30303,enode://319520060dd569ae12f3424e2f9302fcfcf33fc48554bb1075b5992af38c4ab816519866a86387de5bee3a251fcf4542ee7855319efdb3c44e57127fc20b9577@57.128.184.30:30310"

case "$NETWORK" in
"hoodi")
  NETWORK_FLAGS="--hoodi"
  ;;
"lukso")
  NETWORK_FLAGS="--networkid 42 --miner.gasprice 1000000 --miner.gaslimit 42000000 --bootnodes $LUKSO_BOOTNODES --maxpeers 50"
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
  --metrics \
  --metrics.addr 0.0.0.0 \
  --authrpc.jwtsecret "${JWT_PATH}" ${NETWORK_FLAGS} ${EXTRA_OPTS}
