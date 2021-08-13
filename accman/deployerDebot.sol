pragma ton-solidity >=0.43.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "../Debot.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Terminal/Terminal.sol";
import "AccMan.sol";
import "IAccManCallbacks.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/AddressInput/AddressInput.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/UserInfo/UserInfo.sol";

contract DeployerDebot is Debot, IAccManCallbacks, IonQueryAccounts {
    bytes m_icon;

    address m_accman;
    TvmCell m_accountImage;
    uint256 m_ownerKey;
    uint32 m_sbHandle;
    address m_wallet;

    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    function setAccount(TvmCell image) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_accountImage = image;
    }

    function setAccman(address addr) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_accman = addr;
    }

    /// @notice Entry point function for DeBot.
    function start() public override {
        Menu.select("I can manage your wallet accounts.", "", [
            MenuItem("Deploy new account", "", tvm.functionId(menuDeployAccount)),
            MenuItem("Show all your accounts", "", tvm.functionId(menuViewAccounts))
        ]);
        
    }

    function menuViewAccounts(uint32 index) public {
        index;
        if (m_ownerKey == 0) {
            UserInfo.getPublicKey(tvm.functionId(setOwnerKey2));
        } else {
            AccMan(m_accman).invokeQueryAccounts(m_ownerKey);
        }
    }

    function setOwnerKey2(uint256 value) public {
        require(value != 0);
        m_ownerKey = value;
        AccMan(m_accman).invokeQueryAccounts(m_ownerKey);
    }

    function menuDeployAccount(uint32 index) public {
        index;
        if (m_wallet == address(0)) {
            UserInfo.getAccount(tvm.functionId(setWalletAddress));
        }
        if (m_ownerKey == 0) {
            UserInfo.getPublicKey(tvm.functionId(setOwnerKey));
        }

        if (m_ownerKey != 0 && m_wallet != address(0)) {
            getSigningBox();
        }
    }

    function setOwnerKey(uint256 value) public {
        require(value != 0);
        m_ownerKey = value;
        getSigningBox();
    }

    function getSigningBox() public {
        uint256[] keys = [m_ownerKey];
        if (m_sbHandle == 0) {
            SigningBoxInput.get(
                tvm.functionId(setSigningBoxHandle),
                "Choose your keys to sign transactions from multisig.",
                keys
            );
        } else {
            setSigningBoxHandle(m_sbHandle);
        }
    }

    function setWalletAddress(address value) public {
        m_wallet = value;
        if (m_ownerKey != 0) {
            getSigningBox();
        }
    }

    function setSigningBoxHandle(uint32 handle) public {
        m_sbHandle = handle;
        accmanInvokeDeploy();
    }


    function accmanInvokeDeploy() public view {
        TvmBuilder args;
        args.store(uint(228));
        uint256[] emptyArray;
        AccMan(m_accman).invokeDeployAccount(
            m_accountImage,
            m_ownerKey,
            emptyArray,
            m_wallet,
            m_sbHandle,
            args.toCell()
        );
    }

    function onAccountDeploy(Status status, address addr) external override {
        uint8 stat = uint8(status);
        if (status == Status.Success) {
            Terminal.print(0, format("Account successfully deployed:\n{}", addr));
        } else {
            Terminal.print(0, format("Account deploy failed. Error status {}", stat));
        }

        this.start();
    }

    function onQueryAccounts(address[] accounts) external override {
        Terminal.print(0, format("You have {} accounts:", accounts.length));
        for (uint i = 0; i < accounts.length; i++) {
            Terminal.print(0, format("{}", accounts[i]));
        }

        this.start();
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Account Deployer";
        version = "0.2.0";
        publisher = "TON Labs";
        caption = "Account Deployment";
        author = "TON Labs";
        support = address.makeAddrStd(0, 0);
        hello = "Hello, I am a Deployer DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID ];
    }

    //
    // Private Helpers
    //

    function _parseKey(string value) private returns (bool) {
        (uint256 key, bool res) = stoi("0x" + value);
        if (!res) {
            Terminal.print(tvm.functionId(Debot.start), "Invalid public key.");
            return res;
        }
        m_ownerKey = key;
        return res;
    }

}