pragma ton-solidity >=0.43.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "../Debot.sol";
//import "../Terminal.sol";
import "IMultisig.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/SigningBoxInput/SigningBoxInput.sol";
import "IAccManCallbacks.sol";

enum Status {
    Success, IsNoRoot
}

contract AccMan is Debot {
    bytes m_icon;

    // StateInit
    TvmCell m_accountBaseImage;
    TvmCell m_inviteImage;
    TvmCell m_inviteRootImage;

    address m_invoker;
    TvmCell m_accountImage;
    uint256 m_ownerKey;
    address m_wallet;
    TvMCell m_args;
    uint16 m_currentSeqno;

    uint32 m_gotoId;
    bool m_deployInProgress;

    modifier onlyOwner() {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        _;
    }

    function setIcon(bytes icon) public onlyOwner {
        m_icon = icon;
    }

    function setAccountBase(TvmCell image) public onlyOwner {
        m_accountBaseImage = image;
    }

    function setInvite(TvmCell image) public onlyOwner {
        m_inviteImage = image;
    }

    function setInviteRootImage(TvmCell image) public onlyOwner {
        m_inviteRootImage = image;
    }

    /// @notice Entry point function for DeBot.
    function start() public override {
        
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Account Manager";
        version = "0.2.0";
        publisher = "TON Labs";
        caption = "Managing user accounts";
        author = "TON Labs";
        support = address.makeAddrStd(0, 0x841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94);
        hello = "Hello, I am an Account Manager DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID ];
    }

    function invokeDeployAccount(
        TvmCell image,
        uint256 ownerKey,
        address wallet,
        uint32 sbHandle,
        TvmCell args
    ) public {
        m_invoker = msg.sender;
        m_ownerKey = ownerKey;
        m_accountImage = image;
        m_wallet = wallet;
        m_args = args;
        m_sbHandle = sbHandle;
        calcSeqno();
    }

    function _calcRoot() private returns (address) {
        TvmCell rootImage = tvm.insertPubkey(m_inviteRootImage, m_ownerKey);
        return address(tvm.hash(rootImage));
    }

    function checkRoot() public {
        address rootAddr = _calcRoot();
        Sdk.getAccountType(tvm.functionId(checkRootState), rootAddr);
    }

    function menuCheckRoot(uint32 index) public {
        checkRoot();
    }

    function checkRootState(int8 acc_type) public {
        if (acc_type != 1) {
            string prompt; 
            if (m_deployInProgress) {
                Menu.select("Waiting for the Invite Root deployment...", "", [ MenuItem("Check again", "", tvm.functionId(menuCheckRoot)) ]);
                return;
            } else {
                prompt = "AccMan needs to deploy Invite Root to manage your accounts (y/n)";
                ConfirmInput.get(tvm.functionId(deployRoot), prompt);
            }
        }

        Sdk.signHash(tvm.functionId(setSignature), m_sbHandle, tvm.hash(m_accountImage.toSlice().loadRef()));
        
    }

    function createSelfInvite() public {
        address account = address(buildAccount(m_ownerKey, m_currentSeqno));
        ptional(uint256) pubkey = 0;
        optional(uint32) sbhandle = m_sbHandle;
        InviteRoot(_calcRoot()).createOwnerInvite{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: 0,
            expire: 0,
            signBoxHandle: sbhandle,
            callbackId: tvm.functionId(reportSuccess),
            onErrorId: tvm.functionId(onError)
        }(account);
    }

    function setSignature(bytes signature) public {
        TvmCell body = tvm.encodeBody(
            AccMan.deployAccount, m_ownerKey, m_currentSeqno, 
            m_accountImage.toSlice().loadRef(), signature, m_args
        );
        callMultisig(body, 3 ton, tvm.functionId(checkAccount));
    }

    function checkAccount() public {
        address account = address(buildAccount(m_ownerKey, m_currentSeqno));
        Sdk.getAccountCodeHash(tvm.functionId(checkHash), account);
    }

    function menuCheckAccount(uint32 index) public {
        index;
        checkAccount();
    }

    function checkHash(uint256 code_hash) public {
        if (code_hash == tvm.hash(buildAccount(m_ownerKey, m_currentSeqno)) || code_hash == 0) {
            Menu.select("Waiting for the Account deployment...", "", [ MenuItem("Check again", "", tvm.functionId(menuCheckAccount)) ]);
            return;
        }

        createSelfInvite();
    }

    function reportSuccess() public {
        IAccManCallbacks(m_invoker).onAccountDeploy(Status.Success, address(buildAccount(m_ownerKey, m_currentSeqno)));
    }

    function deployRoot(bool value) public {
        if (!value) {
            IAccManCallbacks(m_invoker).onAccountDeploy(Status.IsNoRoot, address(0));
        }
        TvmCell body = tvm.encodeBody(AccMan.deployInviteRoot, m_ownerKey);
        m_deployInProgress = true;
        callMultisig(body, 1 ton, tvm.functionId(checkRoot));
    }

    function calcSeqno() private {
        m_currentSeqno = 0;
        // TODO: introduce new type of invite - self, and query only selfinvites.
        Sdk.getAccountsDataByHash(tvm.functionId(setResult), tvm.hash(buildInviteCode(1, _calcRoot())));
    }

    function callMultisig(TvmCell payload, uint128 value, uint32 gotoId) public {
        optional(uint256) pubkey = m_ownerKey;
        optional(uint32) sbhandle = m_sbHandle;
        m_gotoId = gotoId;
        IMultisig(m_wallet).submitTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: 0,
            expire: 0,
            signBoxHandle: sbhandle,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        }(address(this), value, true, false, payload);
    }

    function onSuccess(uint64 transId) public {
        if (m_gotoId == tvm.functionId(checkRoot)) {
            this.checkRoot();
        }
    }

    function setResult(AccData[] accounts) public {
        uint16 counter = 0;
        for (uint i = 0; i < accounts.length; i++) {
            uint256 pubkey = accounts.data.toSlice().decode(uint256);
            if (pubkey == m_ownerKey) {
                counter++;
            }
        }
        m_currentSeqno = counter;

        checkRoot();
    }

    //
    // Helpers
    //

    

    function buildAccount(uint256 ownerKey, uint16 seqno) private returns (TvmCell image) {
        TvmCell code = m_accountBaseImage.toSlice().loadRef();
        TvmCell newImage = tvm.buildStateInit({
            code: code,
            pubkey: ownerKey,
            varInit: { seqno: seqno },
            contr: AccBase
        });

        image = newImage;
    }

    function buildInviteCode(uint8 inviteType, address inviteRoot) private returns (TvmCell) {
        TvmBuilder saltBuilder;
        // uint8 (invite type) + address (invite root addr).
        saltBuilder.store(inviteType, inviteRoot);
        TvmCell code = tvm.setCodeSalt(
            m_inviteImage.toSlice().loadRef(),
            saltBuilder.toCell()
        );

        return code;
    }

    //
    // Onchain functions
    //

    function deployAccount(uint256 ownerKey, uint16 seqno, TvmCell code, bytes signature, TvmCell args) public {
        TvmCell state = buildAccount(ownerKey, seqno);
        address account = new AccBase{value: 0, flag: 64, stateInit: state}();
        AccBase(account).upgrade(code, signature, args);
    }

    function deployInviteRoot(uint256 ownerKey) public {
        TvmCell state = tvm.insertPubkey(m_inviteRootImage, ownerKey);
        new InviteRoot {value: 0, flag: 64, stateInit: state}(m_inviteImage);
    }
}