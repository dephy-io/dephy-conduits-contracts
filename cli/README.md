# public-vendor

## Cli

Prepare environmental variables:

```bash
source .env
```

### Help

```bash
pnpm run cli --help
```

### List

```bash
pnpm run cli list \
--rpc $BASE_SEPOLIA_RPC_URL \
--privatekey $PRIVATE_KEY \
--marketplace {marketplace address} \
--device {device address} \
--minRentalDays 1 \
--maxRentalDays 30 \
--rentCurrency "0x0000000000000000000000000000000000000000" \
--dailyRent {value in ether} \
--rentRecipient {recipient address} \
--accessURI "http://youruri.com/"
```

### Delist

```bash
pnpm run cli delist \
--rpc $BASE_SEPOLIA_RPC_URL \
--privatekey $PRIVATE_KEY \
--marketplace {marketplace address} \
--device {device address}
```

### Relist

```bash
pnpm run cli relist \
--rpc $BASE_SEPOLIA_RPC_URL \
--privatekey $PRIVATE_KEY \
--marketplace {marketplace address} \
--device {device address} \
--minRentalDays 1 \
--maxRentalDays 30 \
--rentCurrency "0x0000000000000000000000000000000000000000" \
--dailyRent {value in ether} \
--rentRecipient {recipient address} \
--accessURI "http://youruri.com/"
```

### Rent

```bash
pnpm run cli rent \
--rpc $BASE_SEPOLIA_RPC_URL \
--privatekey $PRIVATE_KEY \
--marketplace {marketplace address} \
--device {device address} \
--tenant {tenant address} \
--rentalDays {days} \
--prepaidRent {value in ether}
```

### PayRent

```bash
pnpm run cli payRent \
--rpc $BASE_SEPOLIA_RPC_URL \
--privatekey $PRIVATE_KEY \
--marketplace {marketplace address} \
--device {device address} \
--rent {value in ether}
```

### EndLease

```bash
pnpm run cli endLease \
--rpc $BASE_SEPOLIA_RPC_URL \
--privatekey $PRIVATE_KEY \
--marketplace {marketplace address} \
--device {device address}
```

### Withdraw

```bash
pnpm run cli withdraw \
--rpc $BASE_SEPOLIA_RPC_URL \
--privatekey $PRIVATE_KEY \
--marketplace {marketplace address} \
--device {device address}
```
