pragma ton-solidity >=0.43.0;

interface IMultisig {
    function submitTransaction(
        address  dest,
        uint128 value,
        bool bounce,
        bool allBalance,
        TvmCell payload)
    external returns (uint64 transId);

    function sendTransaction(
        address  dest,
        uint128 value,
        bool bounce,
        uint8 flags,
        TvmCell payload)
    external;
}