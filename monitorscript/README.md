# Description
monitor aptos validator node and full node performance.

+ For validator node:
  
Check the node running status,latest sync and recently proposals count. If the sync stopped 2 mins, it will restart the node. If 24 mins no new proposals, it will restart the node.

+  For full node:
  
Check the node running status,latest sync. If the sync stopped 2 mins, it will restart the node.

# How to use

```
cd <aptos testnet validator folder>
wget https://raw.githubusercontent.com/silentnoname/aptos-node/main/monitorscript/validatormonitor.sh
nohup bash validatormonitor.sh >>validator.log
```

```
cd <aptos testnet full node folder>
wget https://raw.githubusercontent.com/silentnoname/aptos-node/main/monitorscript/fullnodemonitor.sh
nohup bash fullnodemonitor.sh >>fullnode.log
```

## Check log
```
cd <aptos testnet validator node folder>
cat validator.log
```

```
cd <aptos testnet full node folder>
cat fullnode.log
```


