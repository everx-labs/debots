pragma ton-solidity >=0.40.0;

interface IUserInfo {

    function getAccount(uint32 answerId) external returns (address value);
    function getPublicKey(uint32 answerId) external returns (uint256 value);

}

library UserInfo {

    uint256 constant ID = 0xa56115147709ed3437efb89460b94a120b7fe94379c795d1ebb0435a847ee580;
    int8 constant DEBOT_WC = -31;

    function getAccount(uint32 answerId) public pure {
        address addr = address.makeAddrStd(DEBOT_WC, ID);
        IUserInfo(addr).getAccount(answerId);
    }

    function getPublicKey(uint32 answerId) public pure {
        address addr = address.makeAddrStd(DEBOT_WC, ID);
        IUserInfo(addr).getPublicKey(answerId);
    }

}

contract UserInfoABI is IUserInfo {

    function getAccount(uint32 answerId) external override returns (address value) {}
    function getPublicKey(uint32 answerId) external override returns (uint256 value) {}

}

