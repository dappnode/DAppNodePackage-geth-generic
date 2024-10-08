ARG UPSTREAM_VERSION
FROM ethereum/client-go:${UPSTREAM_VERSION}

ARG NETWORK
ARG P2P_PORT
ARG STAKER_SCRIPTS_VERSION
ARG DATA_DIR

ENV GETH_HTTP=true \
    GETH_HTTP_CORSDOMAIN=* \
    GETH_HTTP_API=eth,engine,net,web3,txpool \
    GETH_HTTP_ADDR=0.0.0.0 \
    GETH_HTTP_VHOSTS=* \
    GETH_AUTHRPC_ADDR=0.0.0.0 \ 
    GETH_AUTHRPC_PORT=8551 \
    GETH_AUTHRPC_VHOSTS=* \
    GETH_WS=true \
    GET_WS_ORIGINS=* \
    GETH_WS_ADDR=0.0.0.0 \
    GETH_WS_PORT=8546 \
    GETH_METRICS=true \
    GETH_METRICS_ADDR=0.0.0.0 \
    DATA_DIR=${DATA_DIR} \
    P2P_PORT=${P2P_PORT} \
    JWT_PATH=/jwtsecret.hex \
    STAKER_SCRIPTS_URL=https://github.com/dappnode/staker-package-scripts/releases/download/${STAKER_SCRIPTS_VERSION}

ADD ${STAKER_SCRIPTS_URL}/execution_tools.sh /etc/profile.d/

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apk update && apk add curl && apk cache clean && \
    chmod +rx /usr/local/bin/entrypoint.sh /etc/profile.d/execution_tools.sh

# If NETWORK == lukso mkdir /config
RUN if [ "${NETWORK}" = "lukso" ]; then \
    mkdir /config && \
    curl -L https://raw.githubusercontent.com/lukso-network/network-configs/main/mainnet/shared/dencun/genesis.json -o /config/genesis.json; \
    fi

# This env changes the variant
# Placed at the end to regenerate the least amount of layers
ENV NETWORK=${NETWORK}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
