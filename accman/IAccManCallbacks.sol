pragma ton-solidity >=0.43.0;

interface IAccManCallbacks {
    function onAccountDeploy(Status status, address addr) external;
}