ARG UPSTREAM_VERSION

FROM ethereum/client-go:${UPSTREAM_VERSION}

ARG NETWORK
ARG P2P_PORT

COPY /security /security
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apk update && apk add curl

# If NETWORK == lukso mkdir /config
RUN if [ "${NETWORK}" = "lukso" ]; then \
    mkdir /config && \
    curl -L https://raw.githubusercontent.com/lukso-network/network-configs/main/mainnet/shared/genesis.json -o /config/genesis.json; \
    fi

ENV GETH_AUTHRPC_ADDR=0.0.0.0 \ 
    GETH_AUTHRPC_PORT=8551 \
    GETH_AUTHRPC_VHOSTS=* \
    GETH_HTTP_API=eth,engine,net,web3,txpool \
    GETH_HTTP=true \
    GETH_HTTP_ADDR=0.0.0.0 \
    GETH_WS=true \
    GETH_WS_ADDR=0.0.0.0 \
    GETH_METRICS=true \
    GETH_METRICS_ADDR=0.0.0.0 \
    DATA_DIR=/data \
    P2P_PORT=${P2P_PORT} \
    NETWORK=${NETWORK}

# TODO: Should we add this?
#GETH_HTTP_CORSDOMAIN="*" \
#GETH_WS_ORIGINS="*" \

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
