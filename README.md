# ETH_Transfer_Shuffle
To install solc or build from source code from solidity:
'''
npm install -g solc
'''
To compile to generate TransferHelper.abi and TransferHelper.bin
```
solc -o build --bin --abi *.sol  --overwrite
```