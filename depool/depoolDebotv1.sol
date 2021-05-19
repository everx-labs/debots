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
import "../Upgradable.sol";
import "../Transferable.sol";
import "DePoolRounds.sol";

interface IMultisig {
    function submitTransaction(
        address  dest,
        uint128 value,
        bool bounce,
        bool allBalance,
        TvmCell payload)
    external returns (uint64 transId);
}

interface IDepool {
    function getDePoolInfo() external view returns (
        bool poolClosed,
        uint64 minStake,
        uint64 validatorAssurance,
        uint8 participantRewardFraction,
        uint8 validatorRewardFraction,
        uint64 balanceThreshold,

        address validatorWallet,
        address[] proxies,

        uint64 stakeFee,
        uint64 retOrReinvFee,
        uint64 proxyFee
    );

    function getParticipants() external view returns (address[] participants);

    function getParticipantInfo(address addr) external view
        returns (
            uint64 total,
            uint64 withdrawValue,
            bool reinvest,
            uint64 reward,
            mapping (uint64 => uint64) stakes,
            mapping (uint64 => InvestParams) vestings,
            mapping (uint64 => InvestParams) locks,
            address vestingDonor,
            address lockDonor
        );

    function addOrdinaryStake(uint64 stake) external;
    function withdrawFromPoolingRound(uint64 withdrawValue) external;
    function withdrawPart(uint64 withdrawValue) external;
    function withdrawAll() external;
}
/// @notice Depool Debot v1 (with debot interfaces).
contract DepoolDebot is Debot, Upgradable, Transferable {

    address m_depool;
    uint128 m_balance;
    address m_wallet;
    uint128 m_walletBalance;
    uint128 m_stake;
    uint128 m_instantStake;
    /*
        Storage
    */
    struct DepoolInfo {
        bool poolClosed;
        uint64 minStake;
        uint64 validatorAssurance;
        uint8 participantRewardFraction;
        uint8 validatorRewardFraction;
        uint64 balanceThreshold;

        address validatorWallet;
        address[] proxies;

        uint64 stakeFee;
        uint64 retOrReinvFee;
        uint64 proxyFee;
    }

    struct StakeData {
        uint64 stake;
        bool reinvest;
        address beneficiary;
        uint32 total;
        uint32 withdrawal;
    }

    struct Participant {
        uint64 total;
        uint64 withdrawValue;
        bool reinvest;
        uint64 reward;
        mapping (uint64 => uint64) stakes;
        mapping (uint64 => InvestParams) vestings;
        mapping (uint64 => InvestParams) locks;
        address vestingDonor;
        address lockDonor;
    }

    // target depool rounds
    mapping(uint64 => RoundsBase.TruncatedRound) m_rounds;
    // tartarget depool participants list
    address[] m_participants;
    // target depool global parameters
    DepoolInfo m_info;
    // arguments for depositing stake
    StakeData m_stakeData;
    // participant address
    address m_participant;
    // staking details about m_participant
    Participant m_participantInfo;

    string m_icon;

    bool m_invoked;
    // Default constructor

    function setIcon(string icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    function start() public override {
        _start();
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "DePool";
        version = "1.3.0";
        publisher = "TON Labs";
        caption = "DeBot that helps you manage your stakes";
        author = "TON Labs";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, I can help you manage your stakes in Depool. I am in development now.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, AmountInput.ID, Menu.ID, ConfirmInput.ID, AddressInput.ID ];
    }

    function _start() private {
        AddressInput.get(tvm.functionId(setDepool), "Which DePool are you interested in?");
    }

    function setDepool(address value) public {
        m_depool = value;
        gotoDePoolChecks();
    }

    function gotoDePoolChecks() public {
        Sdk.getAccountType(tvm.functionId(checkStatus), m_depool);
	}

    function checkStatus(int8 acc_type) public {
        if (!_checkActiveStatus(acc_type, "DePool")) {
            _start();
            return;
        } 

        Sdk.getAccountCodeHash(tvm.functionId(checkDepoolHash), m_depool);
    }

    function checkDepoolHash(uint256 code_hash) public {
        if (code_hash != 0x14e20e304f53e6da152eb95fffc993dbd28245a775d847eed043f7c78a503885) {
            Terminal.print(tvm.functionId(Debot.start), "This is not a DePool v3. Enter another address.");
            return;
        }
        _getRounds(tvm.functionId(setRounds));
        _getDePoolInfo(tvm.functionId(setDepoolInfo));
        _getParticipants(tvm.functionId(setParticipants));
        Sdk.getBalance(tvm.functionId(setBalance), m_depool);
        if (m_invoked) {
            this.invoke2();
        } else {
            this.preMain();
        }
    }

    function setBalance(uint128 nanotokens) public {
        m_balance = nanotokens;
    }

    function preMain() public {
        uint64 totalStake = totalParticipantFunds();
        string totStakeStr = tokensToStr(totalStake);
        string valAssuranceStr = tokensToStr(m_info.validatorAssurance);
        string minStakeStr = tokensToStr(m_info.minStake);
        string result = format("DePool information:\nReward fee: {}%\nLock-up period: {} hours\nParticipants: {}\nBalance: {}\nAssurance: {}\nMin. stake: {}",
            m_info.validatorRewardFraction, uint32(54),
            m_participants.length, totStakeStr, valAssuranceStr,  minStakeStr);

        Terminal.print(tvm.functionId(mainMenu), result);
    }

    function selectWallet() public {
        AddressInput.get(tvm.functionId(checkWallet), "What wallet to use to make a stake?");
    }

    function checkWallet(address value) public {
        m_wallet = value;
        Sdk.getAccountType(tvm.functionId(checkWallet2), m_wallet);
        Sdk.getBalance(tvm.functionId(setWalletBalance), m_wallet);
    }

    function checkWallet2(int8 acc_type) public {
        if (!_checkActiveStatus(acc_type, "Wallet")) return;
        if (m_invoked) {
            this.invoke1();
        } else {
            this.checkStake();
        }
    }

    function checkStake() public {
        bool exist = _findParticipant(m_wallet);
        if (!exist) {
            Terminal.print(tvm.functionId(showStakeMenu), "You don't have a stake in this DePool yet.");
        } else {
            _getParticipantInfo(m_wallet, tvm.functionId(setParticipantInfo));
        }
    }

    function mainMenu() public {
        _mainMenu();
    }

    function backToMain(uint32 index) public {
        index;
        _mainMenu();
    }

    function setWalletBalance(uint128 nanotokens) public {
        m_walletBalance = nanotokens;
    }

    function _mainMenu() private {
        MenuItem[] items = [
            MenuItem("Stake", "", tvm.functionId(stakeMore)),
            MenuItem("View rounds", "", tvm.functionId(showRounds))
        ];
        Menu.select("What would you like to do next?", "", items);
    }

    function showRounds(uint32 index) public {
        index;
        for ((uint64 id, RoundsBase.TruncatedRound round): m_rounds) {
            RoundStep step = round.step;
            string stepDesc;
            if (step != RoundStep.PrePooling) {
                if (step == RoundStep.Pooling) {
                    stepDesc = "receiving stakes from participants";
                }
                if (step == RoundStep.WaitingValidatorRequest) {
                    stepDesc = "waiting for election request from validator";
                }
                if (step == RoundStep.WaitingIfStakeAccepted) {
                    stepDesc = "waiting for answer from elector";
                }
                if (step == RoundStep.WaitingValidationStart) {
                    stepDesc = "checking elections result";
                }
                if (step == RoundStep.WaitingIfValidatorWinElections) {
                    stepDesc = "checking elections result";
                }
                if (step == RoundStep.WaitingUnfreeze) {
                    if (round.completionReason == CompletionReason.Undefined) {
                        stepDesc = "elections won, validating";
                    } else {
                        stepDesc = "elections lost, awaiting the end of the validation period";
                    }
                }
                if (step == RoundStep.WaitingReward) {
                    stepDesc = "requesting for reward";
                }
                if (step == RoundStep.Completing) {
                    stepDesc = "completing";
                }
                if (step == RoundStep.Completed) {
                    stepDesc = "completed";
                }

                Terminal.print(0, format("Round {}\nStatus: {}\nStake: {}\nMembers: {}\n",
                    id, stepDesc, tokensToStr(round.stake), round.participantQty));
            }
        }

        _mainMenu();
    }

    function stakeMore(uint32 index) public {
        index = index;
        selectWallet();
    }

    function showStakeMenu() public {
        MenuItem[] items;
        items.push( MenuItem("Deposit ordinary stake", "", tvm.functionId(stake)) );
        if (m_participantInfo.total != 0) {
            items.push( MenuItem("Withdraw stake", "", tvm.functionId(unstake)) );
        }

        Menu.select("Staking options:", "", items);
    }

    function stake(uint32 index) public {
        index = index;
        if (m_walletBalance < m_info.minStake + m_info.stakeFee) {
            Terminal.print(0, "Wallet balance is less then required minimal stake.");
            gotoDePoolChecks();
            return;
        }
        AmountInput.get(tvm.functionId(setAmount), "How many tokens to stake?", 9, m_info.minStake + m_info.stakeFee, m_walletBalance);
    }

    function unstake(uint32 index) public {
        index = index;
        m_instantStake = 0;
        if (m_participantInfo.total != 0) {
            for ((uint64 id, RoundsBase.TruncatedRound round): m_rounds) {
                if (round.step == RoundStep.Pooling) {
                    optional(uint64) optStake = m_participantInfo.stakes.fetch(id);
                    if (optStake.hasValue()) {
                        m_instantStake = optStake.get();
                    }
                }
            }
            Terminal.print(0, format("Tokens to withdraw: {}\nInstant withdraw: {}\nAlready requested to withdraw: {}",
                tokensToStr(m_participantInfo.total), tokensToStr(m_instantStake), tokensToStr(m_participantInfo.withdrawValue)));
                Terminal.print(0, "Requested stake will be returned to the wallet after the end of lock-up period.\nBut instant withdrawal will be completed in a couple of seconds.");
            ConfirmInput.get(tvm.functionId(unstake2), "Ready to withdraw?");
        }
    }

    function unstake2(bool value) public {
        if (!value) {
            gotoDePoolChecks();
            return;
        }
        AmountInput.get(tvm.functionId(unstake3), "How many tokens to withdraw?", 9, m_info.minStake, m_participantInfo.total);
    }

    function unstake3(uint128 value) public view {
        optional(uint256) pubkey = 0;
        TvmCell payload;
        if (value <= m_instantStake) {
            payload = tvm.encodeBody(IDepool.withdrawFromPoolingRound, uint64(value));
            IMultisig(m_wallet).submitTransaction{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_depool, m_info.retOrReinvFee, true, false, payload);
        } else {
            payload = tvm.encodeBody(IDepool.withdrawPart, uint64(value));
            IMultisig(m_wallet).submitTransaction{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_depool, m_info.retOrReinvFee, true, false, payload);
        }
    }

    function onSuccess(uint64 transId) public {
        transId;
        Terminal.print(tvm.functionId(gotoDePoolChecks), "Succeded.");
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        sdkError = sdkError;
        exitCode = exitCode;
        Terminal.print(tvm.functionId(gotoDePoolChecks), format("Operation failed."));
    }

    function setAmount(uint128 value) public {
        m_stake = value;
        ConfirmInput.get(tvm.functionId(sendStake), format("Stake details.\nAmount: {} (with 0.5 fee tokens).\nConfirm?", tokensToStr(m_stake)));
    }

    function sendStake(bool value) public {
        if (!value) {
            _start();
            return;
        }
        optional(uint256) pubkey = 0;

        TvmCell body = tvm.encodeBody(IDepool.addOrdinaryStake, uint64(m_stake - m_info.stakeFee));

        IMultisig(m_wallet).submitTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        }(m_depool, m_stake, true, false, body);
    }

    function _checkActiveStatus(int8 acc_type, string obj) private returns (bool) {
        if (acc_type == -1)  {
            Terminal.print(0, obj + " is inactive");
            return false;
        }
        if (acc_type == 0) {
            Terminal.print(0, obj + " is uninitialized");
            return false;
        }
        if (acc_type == 2) {
            Terminal.print(0, obj + " is frozen");
            return false;
        }
        return true;
    }

    function tokens(uint128 nanotokens) private pure returns (uint64, uint64) {
        uint64 decimal = uint64(nanotokens / 1e9);
        uint64 float = uint64(nanotokens - (decimal * 1e9));
        return (decimal, float);
    }

    function tokensToStr(uint128 nanotokens) private pure returns (string) {
        if (nanotokens == 0) return "0";
        (uint64 dec, uint64 float) = tokens(nanotokens);
        string floatStr = format("{}", float);
        while (floatStr.byteLength() < 9) {
            floatStr = "0" + floatStr;
        }
        string result = format("{}.{}", dec, floatStr);
        return result;
    }

    function _getRounds(uint32 answerId) private view {
        RoundsBase(m_depool).getRounds{
            abiVer: 2,
            extMsg: true,
            sign: false,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function _getDePoolInfo(uint32 answerId) private view {
        IDepool(m_depool).getDePoolInfo{
            abiVer: 2,
            extMsg: true,
            sign: false,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function _getParticipants(uint32 answerId) private view {
        IDepool(m_depool).getParticipants{
            abiVer: 2,
            extMsg: true,
            sign: false,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function _getParticipantInfo(address addr, uint32 answerId) private view {
        IDepool(m_depool).getParticipantInfo{
            abiVer: 2,
            extMsg: true,
            sign: false,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }(addr);
    }

    function setRounds(mapping(uint64 => RoundsBase.TruncatedRound) rounds) public {
        m_rounds = rounds;
    }

    function setDepoolInfo(
        bool poolClosed,
        uint64 minStake,
        uint64 validatorAssurance,
        uint8 participantRewardFraction,
        uint8 validatorRewardFraction,
        uint64 balanceThreshold,

        address validatorWallet,
        address[] proxies,

        uint64 stakeFee,
        uint64 retOrReinvFee,
        uint64 proxyFee
    ) public {
        m_info = DepoolInfo(
         poolClosed,
         minStake,
         validatorAssurance,
         participantRewardFraction,
         validatorRewardFraction,
         balanceThreshold,

         validatorWallet,
         proxies,

         stakeFee,
         retOrReinvFee,
         proxyFee
        );
    }

    function setParticipants(address[] participants) public {
        m_participants = participants;
    }

    function setParticipantInfo(
        uint64 total,
        uint64 withdrawValue,
        bool reinvest,
        uint64 reward,
        mapping (uint64 => uint64) stakes,
        mapping (uint64 => InvestParams) vestings,
        mapping (uint64 => InvestParams) locks,
        address vestingDonor,
        address lockDonor
    ) public {
        m_participantInfo = Participant(total, withdrawValue, reinvest, reward, vestingDonor, lockDonor);
        m_participantInfo.stakes = stakes;
        m_participantInfo.vestings = vestings;
        m_participantInfo.locks = locks;
        string roundsDesc;
        uint8 count = 0;
        string descStr;
        for ((uint64 id, uint64 funds) : m_participantInfo.stakes) {
            if (funds != 0) {
                count += 1;
                roundsDesc.append(format("Round #{}: {} tokens.\n", id, tokensToStr(funds)));
            }
        }
        descStr = format("You staked {} tokens in {} round(s):\n{}Your reward is {} tokens.\nReinvestment enabled: {}.",
            tokensToStr(total), count, roundsDesc, tokensToStr(reward), reinvest ? "yes" : "no");
        Terminal.print(tvm.functionId(showStakeMenu), descStr);
    }


    function totalParticipantFunds() private view returns (uint64) {
        uint64 stakes = 0;
        for ((, RoundsBase.TruncatedRound round): m_rounds) {
            RoundStep step = round.step;
            if (step != RoundStep.Completed) {
                stakes += round.stake;
            }
        }
        return stakes;
    }

    function _findParticipant(address addr) private view returns (bool) {
        uint len = m_participants.length;
        for(uint i = 0; i < len; i++) {
            if (m_participants[i] == addr) {
                return true;
            }
        }
        return false;
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

        //
    // Functions for external or internal invoke.
    //

    function invokeOrdinaryStake(address sender, address depool, uint128 amount) public {
        m_stake = amount;
        m_wallet = sender;
        m_depool = depool;
        m_invoked = true;
        ConfirmInput.get(tvm.functionId(setInvokeConfirm), 
            format("I will stake {} TON to DePool {}. Continue?", tokensToStr(amount), depool));
    }

    function setInvokeConfirm(bool value) public {
        if (!value) {
            _start();
            return;
        }
        
        if (m_wallet == address(0)) {
            this.selectWallet();
        } else {
            this.checkWallet(m_wallet);
        }
    }

    function invoke1() public pure {
        this.gotoDePoolChecks();
    }

    function invoke2() public {
        if (m_stake < m_info.minStake + m_info.stakeFee) {
            Terminal.print(tvm.functionId(Debot.start), "Stake value is less then minimal required stake for this DePool.");
            return;
        }
        this.sendStake(true);
    }
    //
    // Getters
    //

    function getOrdinaryStakeMessage(address sender, address depool, uint128 amount) public pure
        returns(TvmCell message) {
        TvmCell body = tvm.encodeBody(this.invokeOrdinaryStake, sender, depool, amount);
        TvmBuilder message_;
        message_.store(false, true, true, false, address(0), address(this));
        message_.storeTons(0);
        message_.storeUnsigned(0, 1);
        message_.storeTons(0);
        message_.storeTons(0);
        message_.store(uint64(0));
        message_.store(uint32(0));
        message_.storeUnsigned(0, 1); //init: nothing$0
        message_.storeUnsigned(1, 1); //body: right$1
        message_.store(body);
        message = message_.toCell();
    }
}