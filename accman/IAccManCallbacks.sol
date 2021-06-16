pragma ton-solidity >=0.43.0;

enum Status {
    Success, IsNoRoot, EmptyAccount, ZeroKey, InvalidSigningBoxHandle, 
    MultisigFailed, RootFailed, RootFrozen,
    LowWalletBalance, InactiveWallet
}

interface IAccManCallbacks {
    function onAccountDeploy(Status status, address addr) external;
}

interface IonQueryAccounts {
    function onQueryAccounts(address[] invites) external;
}

interface IonQueryPublicInvites {
    function onQueryPublicInvites(address[] accounts) external;
}

interface IonQueryPrivateInvites {
    function onQueryPrivateInvites(address[] accounts) external;
}

interface IonCreatePublicInvite {
    function onCreatePublicInvite(Status status) external;
}

interface IonCreatePrivateInvite {
    function onCreatePrivateInvite(Status status) external;
}