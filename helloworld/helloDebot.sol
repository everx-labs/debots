pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "../Debot.sol";
import "../Terminal.sol";
import "../AddressInput.sol";
import "../AmountInput.sol";
import "../ConfirmInput.sol";
import "../Sdk.sol";
import "../Menu.sol";

contract HelloDebot is Debot {

    function start() public override {
        Terminal.print(0, "Hello, World!");
        _start();
    }

    function _start() private {

    }

    function _version(uint24 major, uint24 minor, uint24 fix) private pure inline returns (uint24) {
        return (major << 16) | (minor << 8) | (fix);
    }

    function getVersion() public override returns (string name, uint24 semver) {
        (name, semver) = ("HelloWorld DeBot", _version(0,1,0));
    }

}