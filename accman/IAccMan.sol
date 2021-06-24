pragma ton-solidity >=0.43.0;

interface IAccMan {
    function invokeDeployAccount(
        TvmCell image,
        uint256 ownerKey,
        address wallet,
        uint32 sbHandle,
        TvmCell args
    ) external;

    function invokeQueryAccounts(uint256 ownerKey) external;

    function invokeCreatePublicInvite(
        uint256 userKey,
        address account,
        address wallet,
        uint32 sbHandle
    ) external;

    function invokeCreatePrivateInvite(
        uint256 userKey,
        address account,
        string nonce,
        address wallet,
        uint32 sbHandle
    ) external;

    function invokeQueryPublicInvites(uint256 userKey) external;


    function invokeQueryPrivateInvites(uint256 userKey) external;
}