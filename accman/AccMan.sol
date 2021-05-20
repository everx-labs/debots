pragma ton-solidity >=0.43.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "../Debot.sol";
import "IMultisig.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/SigningBoxInput/SigningBoxInput.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Menu/Menu.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/ConfirmInput/ConfirmInput.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Terminal/Terminal.sol";
import "IAccManCallbacks.sol";
import "../Sdk.sol";
import "InviteRoot.sol";
import "AccBase.sol";

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
    TvmCell m_args;
    uint32 m_sbHandle;
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

    function setInviteRoot(TvmCell image) public onlyOwner {
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
        return [ Menu.ID, SigningBoxInput.ID ];
    }

    /// @notice API function.
    function invokeDeployAccount(
        TvmCell image,
        uint256 ownerKey,
        address wallet,
        uint32 sbHandle,
        TvmCell args
    ) public {
        m_invoker = msg.sender;
        if (image.toSlice().empty()) {
            returnOnDeployError(Status.EmptyAccount);
            return;
        }
        if (ownerKey == 0) {
            returnOnDeployError(Status.ZeroKey);
            return;
        }
        if (sbHandle == 0) {
            returnOnDeployError(Status.InvalidSigningBoxHandle);
            return;
        }
        m_ownerKey = ownerKey;
        m_accountImage = image;
        m_wallet = wallet;
        m_args = args;
        m_sbHandle = sbHandle;
        calcSeqno();
    }

    /// @notice API function.
    function invokeQueryAccounts(
        uint256 ownerKey
    ) public {
        m_invoker = msg.sender;
        m_ownerKey = ownerKey;
        Sdk.getAccountsDataByHash(
            tvm.functionId(setInvites),
            tvm.hash(buildInviteCode(1, _calcRoot())),
            address.makeAddrStd(-1, 0)
        );
    }

    function setInvites(AccData[] accounts) public view {
        address[] addrs;
        for (uint i = 0; i < accounts.length; i++) {
            (, , , address acc) = accounts[i].data.toSlice().decode(uint256, uint64, bool, address);
            addrs.push(acc);
        }

        IonQueryAccounts(m_invoker).onQueryAccounts(addrs);
    }

    function _calcRoot() private view returns (address) {
        TvmCell rootImage = tvm.insertPubkey(m_inviteRootImage, m_ownerKey);
        return address(tvm.hash(rootImage));
    }

    function checkRoot() public {
        address rootAddr = _calcRoot();
        Sdk.getAccountType(tvm.functionId(checkRootState), rootAddr);
    }

    function menuCheckRoot(uint32 index) public {
        index;
        checkRoot();
    }

    function checkRootState(int8 acc_type) public {
        if (acc_type != 1) {
            string prompt; 
            if (m_deployInProgress) {
                Menu.select("Waiting for the Invite Root deployment...", "", [ MenuItem("Check again", "", tvm.functionId(menuCheckRoot)) ]);
            } else {
                prompt = "AccMan needs to deploy Invite Root to manage your accounts";
                ConfirmInput.get(tvm.functionId(deployRoot), prompt);
            }
        } else {
            Terminal.print(0, format("Your Invite Root is active: {}.", _calcRoot()));
            this.signAccountCode();
        }
    }

    function signAccountCode() public {
        Sdk.signHash(tvm.functionId(setSignature), m_sbHandle, tvm.hash(m_accountImage.toSlice().loadRef()));
    }

    function createSelfInvite() public view {
        address account = address(tvm.hash(buildAccount(m_ownerKey, m_currentSeqno)));
        optional(uint32) sbhandle = m_sbHandle;
        InviteRoot(_calcRoot()).createOwnerInvite{
            abiVer: 2,
            extMsg: true,
            sign: true,
            time: 0,
            expire: 0,
            signBoxHandle: sbhandle,
            callbackId: tvm.functionId(reportSuccess),
            onErrorId: tvm.functionId(onRootError)
        }(account);
    }

    function onRootError(uint32 sdkError, uint32 exitCode) public {
        // TODO: handle errors
        Terminal.print(0, format("Error: sdk code = {}, exit code = {}", sdkError, exitCode));
        returnOnDeployError(Status.RootFailed);
    }

    function setSignature(bytes signature) public {
        Terminal.print(0, "Deploying account...");
        TvmCell body = tvm.encodeBody(
            AccMan.deployAccount, m_ownerKey, m_currentSeqno, 
            m_accountImage.toSlice().loadRef(), signature, m_args
        );
        this.callMultisig(body, 3 ton, tvm.functionId(checkAccount));
    }

    function checkAccount() public {
        address account = address(tvm.hash(buildAccount(m_ownerKey, m_currentSeqno)));
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
        Terminal.print(0, "Creating self invite...");
        this.createSelfInvite();
    }

    function reportSuccess() public view {
        returnOnDeployStatus(Status.Success, address(tvm.hash(buildAccount(m_ownerKey, m_currentSeqno))));
    }

    function deployRoot(bool value) public {
        if (!value) {
            IAccManCallbacks(m_invoker).onAccountDeploy(Status.IsNoRoot, address(0));
        }
        TvmCell body = tvm.encodeBody(AccMan.deployInviteRoot, m_ownerKey);
        m_deployInProgress = true;
        callMultisig(body, 2 ton, tvm.functionId(checkRoot));
    }

    function calcSeqno() private {
        m_currentSeqno = 0;
        // TODO: introduce new type of invite - self, and query only selfinvites.
        Sdk.getAccountsDataByHash(
            tvm.functionId(setResult),
            tvm.hash(buildInviteCode(1, _calcRoot())),
            address.makeAddrStd(-1, 0)
        );
    }

    function callMultisig(TvmCell payload, uint128 value, uint32 gotoId) public {
        optional(uint256) pubkey = m_ownerKey;
        optional(uint32) sbhandle = m_sbHandle;
        m_gotoId = gotoId;
        IMultisig(m_wallet).sendTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: 0,
            expire: 0,
            signBoxHandle: sbhandle,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        }(address(this), value, true, 2, payload);
    }

    function onSuccess() public view {
        if (m_gotoId == tvm.functionId(checkRoot)) {
            this.checkRoot();
        } else {
            this.checkAccount();
        }
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        // TODO: handle errors
        Terminal.print(0, format("Error: sdk code = {}, exit code = {}", sdkError, exitCode));
        returnOnDeployError(Status.MultisigFailed);
    }

    function setResult(AccData[] accounts) public {
        uint16 counter = 0;
        for (uint i = 0; i < accounts.length; i++) {
            uint256 pubkey = accounts[i].data.toSlice().decode(uint256);
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

    function returnOnDeployStatus(Status status, address addr) internal view {
        IAccManCallbacks(m_invoker).onAccountDeploy(status, addr);
    }

    function returnOnDeployError(Status status) internal view {
        returnOnDeployStatus(status, address(0));
    }

    function buildAccount(uint256 ownerKey, uint16 seqno) private view returns (TvmCell image) {
        TvmCell code = m_accountBaseImage.toSlice().loadRef();
        TvmCell newImage = tvm.buildStateInit({
            code: code,
            pubkey: ownerKey,
            varInit: { seqno: seqno },
            contr: AccBase
        });

        image = newImage;
    }

    function buildInviteCode(uint8 inviteType, address inviteRoot) private view returns (TvmCell) {
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
        require(msg.value >= 2 ton, 102);
        TvmCell state = buildAccount(ownerKey, seqno);

        address account = new AccBase{value: 1 ton, flag: 1, bounce: true, stateInit: state}();
        AccBase(account).upgrade{value: 0, flag: 64, bounce: true}(code, signature, args);
    }

    function deployInviteRoot(uint256 ownerKey) public {
        TvmCell state = tvm.insertPubkey(m_inviteRootImage, ownerKey);
        new InviteRoot {value: 0, flag: 64, stateInit: state}(m_inviteImage);
    }

    //
    // Get-methods
    //

}