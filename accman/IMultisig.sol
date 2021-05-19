pragma ton-solidity >=0.43.0;

interface IMultisig {
    function submitTransaction(
        address  dest,
        uint128 value,
        bool bounce,
        bool allBalance,
        TvmCell payload)
    external returns (uint64 transId);

    function confirmTransaction(uint64 transactionId) external;

    function getCustodians() external returns (CustodianInfo[] custodians);
    function getTransactions() external returns (Transaction[] transactions);
}