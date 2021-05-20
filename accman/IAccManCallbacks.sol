pragma ton-solidity >=0.43.0;

enum Status {
    Success, IsNoRoot, EmptyAccount, ZeroKey, InvalidSigningBoxHandle, MultisigFailed, RootFailed
}

interface IAccManCallbacks {
    function onAccountDeploy(Status status, address addr) external;
}

interface IonQueryAccounts {
    function onQueryAccounts(address[] invites) external;
}