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

contract DeployerDebot is Debot, 
                        IAccManCallbacks,
                        IonQueryAccounts,
                        IonUpdateAccountPublicInvites,
                        IonQueryPublicInvites
{
    bytes m_icon;

    address m_accman;
    TvmCell m_accountImage;
    uint256 m_ownerKey;
    uint32 m_sbHandle;
    address m_wallet;
    address m_account;
    uint256[] m_newOwners;
    uint32 m_continue;

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
        m_continue = 0;
        if (m_wallet == address(0)) {
            UserInfo.getAccount(tvm.functionId(setWalletAddress));
        } else {
            _start();
        }
    }

    function _start() private {
        Menu.select("I can manage your wallet accounts.", "", [
            MenuItem("Deploy new account", "", tvm.functionId(menuDeployAccount)),
            MenuItem("Show all your accounts", "", tvm.functionId(menuViewAccounts)),
            MenuItem("Show accounts by key", "", tvm.functionId(menuViewAccountsByKey)),
            MenuItem("Update account owners", "", tvm.functionId(menuUpdateOwners))
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
        if (m_ownerKey == 0) {
            UserInfo.getPublicKey(tvm.functionId(setOwnerKey));
        }

        if (m_ownerKey != 0 && m_wallet != address(0)) {
            m_continue = tvm.functionId(accmanInvokeDeploy);
            getSigningBox();
        }
    }

    function menuUpdateOwners(uint32 index) public {
        index;
        UserInfo.getPublicKey(tvm.functionId(setKey));
        AddressInput.get(tvm.functionId(enterAccount), "enter account address:");
    }

    function menuViewAccountsByKey(uint32 index) public {
        index;
        Terminal.input(tvm.functionId(enterOneKey), "enter public key:", false);
        
    }

    function enterOneKey(string value) public {
        (uint256 key, bool res) = _parseKey(value);
        if (!res) return;
        AccMan(m_accman).invokeQueryPublicInvites(key);
    }

    function setKey(uint256 value) public {
        m_ownerKey = value;
    }

    function enterAccount(address value) public {
        m_account = value;
        enterKey(".");
    }

    function enterKey(string value) public {
        bool res = true;
        uint256 key = 0;
        if (value != ".") {
            (key, res) = _parseKey(value);
        }
        if (!res) {
            m_continue = tvm.functionId(updateInvites);
            getSigningBox();
        } else {
            m_newOwners.push(key);
            Terminal.input(tvm.functionId(enterKey), "enter new owner key:", false);
        }
    }

    function updateInvites() public {
        AccMan(m_accman).invokeUpdateAccountPublicInvites(
            m_account,
            [m_ownerKey],
            m_newOwners,
            m_wallet,
            m_sbHandle
        );
    }

    function onUpdateAccountPublicInvites(Status status) external override {
        Terminal.print(0, status == Status.Success ? "succeded" : "failed");
        this.start();
    }

    function setOwnerKey(uint256 value) public {
        require(value != 0);
        m_ownerKey = value;
        m_continue = tvm.functionId(accmanInvokeDeploy);
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
        _start();
    }

    function setSigningBoxHandle(uint32 handle) public {
        m_sbHandle = handle;
        Terminal.print(m_continue, "");
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
        Terminal.print(0, format("You deployed {} accounts", accounts.length));
        for (uint i = 0; i < accounts.length; i++) {
            Terminal.print(0, format("{}", accounts[i]));
        }
        this.start();
    }

    function onQueryPublicInvites(address[] accounts) external override {
        Terminal.print(0, format("You own {} accounts", accounts.length));
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
        return [ Terminal.ID, AddressInput.ID, UserInfo.ID ];
    }

    //
    // Private Helpers
    //

    function _parseKey(string value) private returns (uint256, bool) {
        (uint256 key, bool res) = stoi("0x" + value);
        if (!res) {
            Terminal.print(0, "Invalid public key.");
            return (0, false);
        }
        return (key, res);
    }

}