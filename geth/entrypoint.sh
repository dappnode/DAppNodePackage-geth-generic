#!/bin/sh

case "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_PRATER" in
"prysm-prater.dnp.dappnode.eth")
  echo "Using prysm-prater.dnp.dappnode.eth"
  JWT_PATH="/security/prysm/jwtsecret.hex"
  ;;
"lighthouse-prater.dnp.dappnode.eth")
  echo "Using lighthouse-prater.dnp.dappnode.eth"
  JWT_PATH="/security/lighthouse/jwtsecret.hex"
  ;;
"teku-prater.dnp.dappnode.eth")
  echo "Using teku-prater.dnp.dappnode.eth"
  JWT_PATH="/security/teku/jwtsecret.hex"
  ;;
"nimbus-prater.dnp.dappnode.eth")
  echo "Using nimbus-prater.dnp.dappnode.eth"
  JWT_PATH="/security/nimbus/jwtsecret.hex"
  ;;
"lodestar-prater.dnp.dappnode.eth")
  echo "Using lodestar-prater.dnp.eth"
  JWT_PATH="/security/lodestar/jwtsecret.hex"
  ;;
esac

case "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_HOLESKY" in
"prysm-holesky.dnp.dappnode.eth")
  echo "Using prysm-holesky.dnp.dappnode.eth"
  JWT_PATH="/security/prysm/jwtsecret.hex"
  ;;
"lighthouse-holesky.dnp.dappnode.eth")
  echo "Using lighthouse-holesky.dnp.dappnode.eth"
  JWT_PATH="/security/lighthouse/jwtsecret.hex"
  ;;
"lodestar-holesky.dnp.dappnode.eth")
  echo "Using lodestar-holesky.dnp.dappnode.eth"
  JWT_PATH="/security/lodestar/jwtsecret.hex"
  ;;
"teku-holesky.dnp.dappnode.eth")
  echo "Using teku-holesky.dnp.dappnode.eth"
  JWT_PATH="/security/teku/jwtsecret.hex"
  ;;
"nimbus-holesky.dnp.dappnode.eth")
  echo "Using nimbus-holesky.dnp.dappnode.eth"
  JWT_PATH="/security/nimbus/jwtsecret.hex"
  ;;
esac

case "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_LUKSO" in
"prysm-lukso.dnp.dappnode.eth")
  echo "Using prysm-lukso.dnp.dappnode.eth"
  JWT_PATH="/security/prysm/jwtsecret.hex"
  ;;
"lighthouse-lukso.dnp.dappnode.eth")
  echo "Using lighthouse-lukso.dnp.dappnode.eth"
  JWT_PATH="/security/lighthouse/jwtsecret.hex"
  ;;
"lodestar-lukso.dnp.dappnode.eth")
  echo "Using lodestar-lukso.dnp.dappnode.eth"
  JWT_PATH="/security/lodestar/jwtsecret.hex"
  ;;
"teku-lukso.dnp.dappnode.eth")
  echo "Using teku-lukso.dnp.dappnode.eth"
  JWT_PATH="/security/teku/jwtsecret.hex"
  ;;
"nimbus-lukso.dnp.dappnode.eth")
  echo "Using nimbus-lukso.dnp.dappnode.eth"
  JWT_PATH="/security/nimbus/jwtsecret.hex"
  ;;
esac

case "$_DAPPNODE_GLOBAL_CONSENSUS_CLIENT_MAINNET" in
"prysm.dnp.dappnode.eth")
  echo "Using prysm.dnp.dappnode.eth"
  JWT_PATH="/security/prysm/jwtsecret.hex"
  ;;
"lighthouse.dnp.dappnode.eth")
  echo "Using lighthouse.dnp.dappnode.eth"
  JWT_PATH="/security/lighthouse/jwtsecret.hex"
  ;;
"teku.dnp.dappnode.eth")
  echo "Using teku.dnp.dappnode.eth"
  JWT_PATH="/security/teku/jwtsecret.hex"
  ;;
"lodestar.dnp.dappnode.eth")
  echo "Using lodestar.dnp.dappnode.eth"
  JWT_PATH="/security/lodestar/jwtsecret.hex"
  ;;
"nimbus.dnp.dappnode.eth")
  echo "Using nimbus.dnp.dappnode.eth"
  JWT_PATH="/security/nimbus/jwtsecret.hex"
  ;;
esac

# If JWT_PATH is not set, set it to Sepolia
# TODO: Sepolia should have its own global envs
if [ -z "$JWT_PATH" ]; then
  echo "Using sepolia JWT"
  JWT_PATH="/security/sepolia/jwtsecret.hex"
fi

# Print the jwt to the dappmanager
JWT=$(cat $JWT_PATH)
curl -X POST "http://my.dappnode/data-send?key=jwt&data=${JWT}"

# Set the value of the P2P_PORT and add network to EXTRA_FLAGS depending on NETWORK
case "$NETWORK" in
"goerli")
  P2P_PORT=30803
  EXTRA_FLAGS="--goerli $EXTRA_FLAGS"
  ;;
"holesky")
  P2P_PORT=31403
  EXTRA_FLAGS="--holesky $EXTRA_FLAGS"
  ;;
"lukso")
  P2P_PORT=33141

  echo "[INFO - entrypoint] Initializing Geth from genesis"
  geth --datadir=$DATA_DIR init /config/genesis.json

  # TODO: Check if this is correct
  EXTRA_FLAGS="--networkid 42 \
  --miner.gasprice 4200000000 \
  --miner.gaslimit 42000000 \
  --bootnodes enode://c2bb19ce658cfdf1fecb45da599ee6c7bf36e5292efb3fb61303a0b2cd07f96c20ac9b376a464d687ac456675a2e4a44aec39a0509bcb4b6d8221eedec25aca2@34.147.73.193:30303","enode://276f14e4049840a0f5aa5e568b772ab6639251149a52ba244647277175b83f47b135f3b3d8d846cf81a8e681684e37e9fc10ec205a9841d3ae219aa08aa9717b@34.32.192.211:30303 \
  --maxpeers 50 $EXTRA_FLAGS"
  ;;
"mainnet")
  P2P_PORT=30403
  # Mainnet network is set by default
  ;;
"sepolia")
  P2P_PORT=35415
  EXTRA_FLAGS="--sepolia $EXTRA_FLAGS"
  ;;
esac

exec geth \
  --datadir $DATA_DIR \
  --syncmode ${SYNCMODE:-snap} \
  --port ${P2P_PORT} \
  --authrpc.jwtsecret ${JWT_PATH} \
  $EXTRA_FLAGS
