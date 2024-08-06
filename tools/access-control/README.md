# Tool Access Control

## Cli

Prepare environmental variables:

```bash
source .env
```

### Help

```bash
pnpm run cli --help
```

### Create AccessToken

```bash
pnpm run cli createAccessToken \
--rpc $BNB_TESTNET_RPC_URL \
--privatekey $PRIVATE_KEY \
--accessTokenFactory {accessTokenFactory address}
--product {product address}
```

### Mint

```bash
pnpm run cli mint \
--rpc $BNB_TESTNET_RPC_URL \
--privatekey $PRIVATE_KEY \
--accessTokenFactory {accessTokenFactory address}
--product {product address}
--tokenId {product token id}
--user {user address}
```

### Burn

```bash
pnpm run cli burn \
--rpc $BNB_TESTNET_RPC_URL \
--privatekey $PRIVATE_KEY \
--accessTokenFactory {accessTokenFactory address}
--product {product address}
--tokenId {product token id}
```

### Access Control

```bash
pnpm run cli accessControl \
--rpc $BNB_TESTNET_RPC_URL \
--accessTokenFactory {accessTokenFactory address}
--product {product address}
--tokenId {product token id}
--user {user address}
```
