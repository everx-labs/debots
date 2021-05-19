pragma ton-solidity >=0.43.0;

enum Status {
    Success, IsNoRoot
}

interface IAccManCallbacks {
    function onAccountDeploy(Status status, address addr) external;
}