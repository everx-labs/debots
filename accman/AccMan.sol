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
import "../Upgradable.sol";
import "IAccManCallbacks.sol";

contract AccMan is Debot, Upgradable {
    uint128 constant DEPLOY_ROOT_FEE = 1 ton;
    uint128 constant DEPLOY_ACCOUNT_FEE = 1 ton;
    uint128 constant DEPLOY_INVITE_FEE = 0.3 ton;

    struct MultisigArgs {
        address dest;
        uint128 value;
        TvmCell payload;
    }

    bytes m_icon;

    // StateInit
    TvmCell m_accountBaseImage;
    TvmCell m_inviteImage;
    TvmCell m_inviteRootImage;

    // invoke arguments
    address m_invoker;
    TvmCell m_accountImage;
    uint256 m_ownerKey;
    address m_wallet;
    TvmCell m_args;
    uint32 m_sbHandle;
    uint16 m_currentSeqno;
    address m_account;
    string m_nonce;
    mapping(uint256 => bool) m_ownerKeys;
    MultisigArgs m_callArgs;
    optional(uint256, bool) m_currOwner;
    // Temp variable - accumulator for found accounts.
    address[] m_addrs;

    // helper vars
    uint32 m_gotoId;
    uint32 m_continue;

    Invoke m_invokeType;
    uint8 m_deployFlags;

    enum Invoke {
        NewAccount,
        NewPublicInvite,
        NewPrivateInvite,
        QueryAccounts,
        QueryPublicInvites,
        QueryPrivateInvites
    }

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
        version = "0.3.0";
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

    //
    // API functions
    //

    /// @notice API function.
    function invokeDeployAccount(
        TvmCell image,
        uint256 deployerKey,
        uint256[] ownerKeys,
        address wallet,
        uint32 sbHandle,
        TvmCell args
    ) public {
        m_deployFlags = 0;
        m_invokeType = Invoke.NewAccount;
        m_invoker = msg.sender;
        if (image.toSlice().empty()) {
            returnOnError(Status.EmptyAccount);
            return;
        }
        if (deployerKey == 0) {
            returnOnError(Status.ZeroKey);
            return;
        }
        if (sbHandle == 0) {
            returnOnError(Status.InvalidSigningBoxHandle);
            return;
        }
        delete m_ownerKeys;
        for (uint256 key: ownerKeys) {
            if (key != deployerKey && key != 0) {
                m_ownerKeys[key] = false;
            }
        }
        m_ownerKey = deployerKey;
        m_accountImage = image;
        m_wallet = wallet;
        m_args = args;
        m_sbHandle = sbHandle;
        calcSeqno();
    }

    /// @notice API function.
    function invokeQueryAccounts(uint256 ownerKey) public {
        m_invokeType = Invoke.QueryAccounts;
        m_invoker = msg.sender;
        m_ownerKey = ownerKey;
        delete m_addrs;
        Sdk.getAccountsDataByHash(
            tvm.functionId(setInvites),
            tvm.hash(buildInviteCode(InviteType.Self, _calcRoot())),
            address.makeAddrStd(-1, 0)
        );
    }

    /// @notice API function.
    function invokeCreatePublicInvite(
        uint256 userKey,
        address account,
        address wallet,
        uint32 sbHandle
    ) public {
        m_deployFlags = 0;
        m_invokeType = Invoke.NewPublicInvite;
        m_invoker = msg.sender;
        if (sbHandle == 0) {
            return returnOnError(Status.InvalidSigningBoxHandle);
        }
        m_ownerKey = userKey;
        m_sbHandle = sbHandle;
        m_wallet = wallet;
        m_account = account;
        m_continue = tvm.functionId(createPubInvite);
        _checkWallet();
    }

    /// @notice API function.
    function invokeCreatePrivateInvite(
        uint256 userKey,
        address account,
        string nonce,
        address wallet,
        uint32 sbHandle
    ) public {
        m_deployFlags = 0;
        m_invokeType = Invoke.NewPrivateInvite;
        m_invoker = msg.sender;
        if (sbHandle == 0) {
            return returnOnError(Status.InvalidSigningBoxHandle);
        }
        m_ownerKey = userKey;
        m_sbHandle = sbHandle;
        m_wallet = wallet;
        m_account = account;
        m_nonce = nonce;
        m_continue = tvm.functionId(createPrivInvite);
        _checkWallet();
    }

    /// @notice API function.
    function invokeQueryPublicInvites(uint256 userKey) public {
        m_invokeType = Invoke.QueryPublicInvites;
        m_invoker = msg.sender;
        m_ownerKey = userKey;
        Sdk.getAccountsDataByHash(
            tvm.functionId(setAllPublicInvitesForUser),
            tvm.hash(buildInviteCode(InviteType.Public, _calcRoot())),
            address.makeAddrStd(-1, 0)
        );
    }

    /// @notice API function.
    function invokeQueryPrivateInvites(uint256 userKey) public {
        m_invokeType = Invoke.QueryPrivateInvites;
        m_invoker = msg.sender;
        m_ownerKey = userKey;
        Sdk.getAccountsDataByHash(
            tvm.functionId(setAllPrivateInvitesForUser),
            tvm.hash(buildInviteCode(InviteType.Private, _calcRoot())),
            address.makeAddrStd(-1, 0)
        );
    }

    /* TODO: implement add/remove nonces
    /// @notice API function.
    function invokeAddInvites(
        uint256 ownerKey,
        uint32 sbRootHandle,
        uint256[] nonceHashes
    ) public {

    }

    /// @notice API function.
    function invokeRemoveInvites() public {
        
    }
    */

    /////////////////////////////////////////////////////////////////////////////////////////////////
    
    function createPrivInvite() public {
        // TODO: check that nonce is valid;
        m_deployFlags |= CREATE_INVITE;
        TvmCell body = tvm.encodeBody(AccMan.deployInvite, m_ownerKey, 
            InviteType.Private, m_account, m_nonce, m_deployFlags);
        this.callMultisig(address(this), body, _calcFee(m_deployFlags, 1), tvm.functionId(completePrivInvite));
    }

    function createPubInvite() public {
        m_deployFlags |= CREATE_INVITE;
        TvmCell body = tvm.encodeBody(AccMan.deployInvite, m_ownerKey, 
            InviteType.Public, m_account, "", m_deployFlags);
        this.callMultisig(address(this), body, _calcFee(m_deployFlags, 1), tvm.functionId(completePubInvite));
    }

    function completePrivInvite() public view {
        IonCreatePrivateInvite(m_invoker).onCreatePrivateInvite(Status.Success);
    }

    function completePubInvite() public view {
        IonCreatePublicInvite(m_invoker).onCreatePublicInvite(Status.Success);
    }

    function setAllPublicInvitesForUser(AccData[] accounts) public view {
        address[] addrs;
        for (uint i = 0; i < accounts.length; i++) {
            addrs.push(_decodeAccountAddress(accounts[i].data));
        }
        IonQueryPublicInvites(m_invoker).onQueryPublicInvites(addrs);
    }

    function setAllPrivateInvitesForUser(AccData[] accounts) public view {
        address[] addrs;
        for (uint i = 0; i < accounts.length; i++) {
            addrs.push(_decodeAccountAddress(accounts[i].data));
        }
        IonQueryPrivateInvites(m_invoker).onQueryPrivateInvites(addrs);
    }

    function setInvites(AccData[] accounts) public {
        for (uint i = 0; i < accounts.length; i++) {
            m_addrs.push(_decodeAccountAddress(accounts[i].data));
        }
        
        if (accounts.length != 0) {
            Sdk.getAccountsDataByHash(
                tvm.functionId(setInvites),
                tvm.hash(buildInviteCode(InviteType.Self, _calcRoot())),
                accounts[accounts.length - 1].id
            );
        } else {
            IonQueryAccounts(m_invoker).onQueryAccounts(m_addrs);
        }
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
            if (acc_type == 2) {
                // frozen account
                returnOnError(Status.RootFrozen);
                return;
            }
            m_deployFlags |= CREATE_ROOT;
            Terminal.print(0, "User Invite Root is inactive.");
        } else {
            Terminal.print(0, format("Invite Root is active: {}.", _calcRoot()));
        }
        m_currOwner = m_ownerKeys.min();
        this.checkCurrentOwnerRoot();
    }

    function checkCurrentOwnerRoot() public {
        if (m_currOwner.hasValue()) {
            (uint256 key, ) = m_currOwner.get();
            Sdk.getAccountType(tvm.functionId(setCurrentRootState), _calcRootByKey(key));
        } else {
            Terminal.print(m_continue, "");
        }
    }

    function setCurrentRootState(int8 acc_type) public {
        if (!m_currOwner.hasValue()) {
            Terminal.print(m_continue, "");
            return;
        }
        (uint256 key, ) = m_currOwner.get();
        if (acc_type == 1) {
            m_ownerKeys[key] = true;
        }
        m_currOwner = m_ownerKeys.next(key);
        this.checkCurrentOwnerRoot();
    }

    function signAccountCode() public {
        Sdk.signHash(tvm.functionId(setSignature), m_sbHandle, tvm.hash(m_accountImage.toSlice().loadRef()));
    }

    function onRootError(uint32 sdkError, uint32 exitCode) public {
        // TODO: handle errors
        Terminal.print(0, format("[DEBUG] Error: sdk code = {}, exit code = {}", sdkError, exitCode));
        returnOnError(Status.RootFailed);
    }

    function setSignature(bytes signature) public {
        m_deployFlags |= CREATE_ACC | CREATE_INVITE;
        uint128 ownerCount = 1;
        uint128 totalFee = 0;
        for ((uint256 k, bool isActiveRoot): m_ownerKeys) {
            ownerCount++;
            if (!isActiveRoot) {
                totalFee += _calcFee(CREATE_ROOT, 0);
            }
        }
        totalFee += _calcFee(m_deployFlags, ownerCount);
        TvmCell body = tvm.encodeBody(
            AccMan.deployAccount, m_ownerKey, m_ownerKeys, m_currentSeqno, 
            m_accountImage.toSlice().loadRef(), signature, m_args, 
            m_deployFlags
        );
        this.callMultisig(address(this), body, totalFee, tvm.functionId(checkAccount));
    }

    function checkAccount() public {
        address account = address(tvm.hash(buildAccount(m_ownerKey, m_currentSeqno)));
        Sdk.getAccountCodeHash(tvm.functionId(checkHash), account);
    }

    function menuCheckAccount(uint32 index) public {
        index;
        checkAccount();
    }

    function checkHash(uint256 code_hash) public view {
        TvmCell accImage = buildAccount(m_ownerKey, m_currentSeqno);
        address addr = address(tvm.hash(accImage));
        if (code_hash == tvm.hash(accImage.toSlice().loadRef()) || code_hash == 0) {
            returnOnError(Status.AccountUpdateFailed);
            return;
        }
        this.reportSuccess();
    }

    function reportSuccess() public view {
        returnOnDeployStatus(Status.Success, address(tvm.hash(buildAccount(m_ownerKey, m_currentSeqno))));
    }

    function calcSeqno() private {
        m_currentSeqno = 0;
        Sdk.getAccountsDataByHash(
            tvm.functionId(setResult),
            tvm.hash(buildInviteCode(InviteType.Self, _calcRoot())),
            address.makeAddrStd(-1, 0)
        );
    }

    function callMultisig(address dest, TvmCell payload, uint128 value, uint32 gotoId) public {
        Sdk.getBalance(tvm.functionId(callMultisig2), m_wallet);
        m_gotoId = gotoId;
        m_callArgs = MultisigArgs(dest, value, payload);
    }

    function callMultisig2(uint128 nanotokens) public {
        if (m_callArgs.value + 0.1 ton >= nanotokens) {
            return returnOnError(Status.LowWalletBalance);
        }
        optional(uint256) pubkey = m_ownerKey;
        optional(uint32) sbhandle = m_sbHandle;
        // TODO: allow transfer only from multisig with 1 custodian.
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
        }(m_callArgs.dest, m_callArgs.value, true, 3, m_callArgs.payload);
        delete m_callArgs;
    }

    function onSuccess() public view {
        if (m_gotoId == tvm.functionId(checkRoot)) {
            this.checkRoot();
        } else if (m_gotoId == tvm.functionId(checkAccount)) {
            this.checkAccount();
        } else if (m_gotoId == tvm.functionId(completePubInvite)) {
            this.completePubInvite();
        } else if (m_gotoId == tvm.functionId(reportSuccess)) {
            this.reportSuccess();
        }
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        // TODO: handle errors
        Terminal.print(0, format("Error: sdk code = {}, exit code = {}", sdkError, exitCode));
        returnOnError(Status.MultisigFailed);
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

        m_continue = tvm.functionId(signAccountCode);
        _checkWallet();
    }

    //
    // Checkers
    //

    function _checkWallet() private {
        Sdk.getBalance(tvm.functionId(checkWalletBalance), m_wallet);
    }

    function checkWalletBalance(uint128 nanotokens) public {
        if (nanotokens < 3 ton) {
            return returnOnError(Status.LowWalletBalance);
        }
        Sdk.getAccountType(tvm.functionId(checkWalletType), m_wallet);
    }

    function checkWalletType(int8 acc_type) public view {
        if (acc_type != 1) {
            return returnOnError(Status.InactiveWallet);
        }
        this.checkRoot();
    }
    //
    // Helpers
    //

    function _calcRoot() private view returns (address) {
        return _calcRootByKey(m_ownerKey);
    }

    function _calcRootByKey(uint256 key) private view returns (address) {
        TvmCell rootImage = tvm.insertPubkey(m_inviteRootImage, key);
        return address(tvm.hash(rootImage));
    }

    function returnOnDeployStatus(Status status, address addr) internal view {
        IAccManCallbacks(m_invoker).onAccountDeploy(status, addr);
    }

    function returnOnError(Status status) internal view {
        if (m_invokeType == Invoke.NewAccount) {
            returnOnDeployStatus(status, address(0));
        } else if (m_invokeType == Invoke.NewPublicInvite) {
            IonCreatePublicInvite(m_invoker).onCreatePublicInvite(status);
        } else if (m_invokeType == Invoke.NewPrivateInvite) {
            IonCreatePrivateInvite(m_invoker).onCreatePrivateInvite(status);
        }
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

    function buildInviteCode(InviteType inviteType, address inviteRoot) private view returns (TvmCell) {
        TvmBuilder saltBuilder;
        // uint8 (invite type) + address (invite root addr).
        saltBuilder.store(uint8(inviteType), inviteRoot);
        TvmCell code = tvm.setCodeSalt(
            m_inviteImage.toSlice().loadRef(),
            saltBuilder.toCell()
        );

        return code;
    }

    function _decodeAccountAddress(TvmCell data) internal pure returns (address) {
        // decode invite contract data manually:
        // pubkey, timestamp, ctor flag, address
        (, , , address acc) = data.toSlice().decode(uint256, uint64, bool, address);
        return acc;
    }

    //
    // Onchain functions
    //

    uint8 constant CREATE_ACC = 1;
    uint8 constant CREATE_ROOT = 2;
    uint8 constant CREATE_INVITE = 4;

    function _calcFee(uint8 flags, uint128 inviteCount) private pure returns (uint128) {
        uint128 totalFee = (flags & CREATE_ACC) != 0 ? DEPLOY_ACCOUNT_FEE : 0;
        if (flags & CREATE_ROOT != 0) {
            totalFee += DEPLOY_ROOT_FEE;
        }
        if (flags & CREATE_INVITE != 0) {
            totalFee += DEPLOY_INVITE_FEE * inviteCount;
        }
        return totalFee;
    }

    function deployAccount(
        uint256 deployerKey,
        mapping(uint256 => bool) ownerKeys,
        uint16 seqno,
        TvmCell code,
        bytes signature,
        TvmCell args,
        uint8 flags
    ) public view {
        uint128 inviteCount = 1;
        uint128 totalFee = 0;
        for ((uint256 k, bool isActiveRoot): ownerKeys) {
            inviteCount++;
            if (!isActiveRoot) {
                totalFee += _calcFee(CREATE_ROOT, 0);
            }
        }
        totalFee += _calcFee(flags, inviteCount);
        require(msg.value >= totalFee, 102);

        if (flags & CREATE_ROOT != 0) {
            deployInviteRoot(deployerKey);
        }

        if (flags & CREATE_ACC != 0) {
            require(tvm.checkSign(tvm.hash(code), signature.toSlice(), deployerKey), 103);

            TvmCell state = buildAccount(deployerKey, seqno);
            address account = new AccBase{value: DEPLOY_ACCOUNT_FEE - 0.1 ton, flag: 1, bounce: true, stateInit: state}();
            AccBase(account).upgrade{value: 0.1 ton, flag: 1, bounce: true}(code, signature, args);

            if (flags & CREATE_INVITE != 0) {
                deployInvite(deployerKey, InviteType.Self, account, "", 0);

                for ((uint256 key, bool isActiveRoot): ownerKeys) {
                    deployInvite(key, InviteType.Public, account, "", !isActiveRoot ? CREATE_ROOT : 0);
                }
                // TODO: support private invites
            }
        }
    }

    function deployInvite(
        uint256 ownerKey,
        InviteType invType,
        address account,
        string nonce,
        uint8 flags
    ) public view {
        uint128 fee = _calcFee(flags | CREATE_INVITE, 1);
        require(msg.value >= fee, 102);

        if (flags & CREATE_ROOT != 0) {
            deployInviteRoot(ownerKey);
        }
        
        TvmCell rootImage = tvm.insertPubkey(m_inviteRootImage, ownerKey);
        address root = address(tvm.hash(rootImage));
        if (invType == InviteType.Public) {
            InviteRoot(root).createPublicInvite{
                value: DEPLOY_INVITE_FEE - 0.01 ton, flag: 0, bounce: true
            }(account);
        } else if (invType == InviteType.Private) {
            InviteRoot(root).createPrivateInvite{
                value: DEPLOY_INVITE_FEE - 0.01 ton, flag: 0, bounce: true
            }(nonce, account);
        } else if (invType == InviteType.Self) {
            InviteRoot(root).createSelfInvite{
                value: DEPLOY_INVITE_FEE - 0.01 ton, flag: 0, bounce: true
            }(account);
        }
    }

    function deployInviteRoot(uint256 ownerKey) public view {
        uint128 fee = _calcFee(CREATE_ROOT, 0);
        require(msg.value >= fee, 102);
        TvmCell state = tvm.insertPubkey(m_inviteRootImage, ownerKey);
        new InviteRoot {value: fee - 0.01 ton, flag: 1, stateInit: state}(m_inviteImage, address(this));
    }

    //
    // Get-methods
    //

    function getImages() public view returns (
        TvmCell accountBaseImage, TvmCell inviteImage, TvmCell inviteRootImage
    ) {
        accountBaseImage = m_accountBaseImage;
        inviteImage = m_inviteImage;
        inviteRootImage = m_inviteRootImage;
    }


    //
    // Upgradable Impl
    //

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

}