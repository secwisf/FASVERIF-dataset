# Datasets for "Automated Inference on Financial Security of Ethereum Smart Contracts"

# Real World Dataset
This dataset consists of real-world smart contracts crawled from Etherscan (https://etherscan.io).
The contracts are divided into two categories, namely ***finance-related*** and ***others***.
Specifically, the contracts in the former are related to cryptocurrencies, i.e., their execution may change token balances or ether balances of some accounts, while contracts in the latter are not related to cryptocurrencies.
The contracts in ***finance-related*** can be further divided into three subclasses, namely ***ether-related***, ***token-related*** and ***indirect-related***.
* *ether-related*, contracts which carries out operations related to ether.
* *token-related*, contracts which implements or manages a kind of tokens.
* *indirect-related*, contracts which implements certain functions used in *ether-related* or *token-related* contracts.


 The file ***data.xlsx*** is a summary (or can also be used as an index) of the dataset. There are four columns in *data.xlsx*, explained in detail as follows.

 |column      |description|
 |:---        |:---|
 |FILE        |name of a `.sol` file|
 |CONTRACT    |name of a contract in the file|
 |TYPE        |*ether-related*, *token-related*, *ether-related & token-related*, *indirect-related* or *others*|
 |VARIABLE    |variable indicating the balance of a kind of tokens, only necessary when a contract is *token-related* and implements a kind of tokens


# Vulnerability Dataset
This dataset consists of smart contracts collected from other works.
Specifically, the contracts in ***overflow*** are collected from https://github.com/kupl/VeriSmart-benchmarks/tree/master/benchmarks/cve, 
the contracts in ***transaction_order_dependency*** is collected from https://drive.google.com/file/d/1190VXwu502M-vgT8yyuFp0lFUVlxnMhO/view?usp=sharing,
the rest of contracts are from https://github.com/gongbell/ContractFuzzer and https://github.com/smartbugs/smartbugs.
We filter out contracts with incomplete codes and contracts that are not currently supported by FASVERIF.

The xlsx files are summaries of contracts with different types of vulnerabilities and the verification results of different tools on these contracts. 
Specifially, ***gs_result.xlsx*** is corresponding to ***gasless_send***, ***over_result.xlsx*** is corresponding to ***overflow***, ***r_result.xlsx*** is corresponding to ***reentrancy***, ***td_result.xlsx*** is corresponding to ***timestamp_dependency***, and ***tod_result.xlsx*** is corresponding to ***transaction_order_dependency***.

 |column      |description|
 |:---        |:---|
 |sol         |name of a `.sol` file|
 |toolname    |the verification result of the corresponding tool on this contract, N means negative, i.e., without this kind of vulnerabilities, and P means the opposite

