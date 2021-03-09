/*
	This file is part of TON  OS.

	TON OS is free software: you can redistribute it and/or modify
	it under the terms of the Apache License 2.0 (http://www.apache.org/licenses/)

	Copyright 2019-2021 (c) TON LABS
*/
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

// A copy of structure from multisig contract
struct Transaction {
    // Transaction Id.
    uint64 id;
    // Transaction confirmations from custodians.
    uint32 confirmationsMask;
    // Number of required confirmations.
    uint8 signsRequired;
    // Number of confirmations already received.
    uint8 signsReceived;
    // Public key of custodian queued transaction.
    uint256 creator;
    // Index of custodian.
    uint8 index;
    // Destination address of gram transfer.
    address  dest;
    // Amount of nanograms to transfer.
    uint128 value;
    // Flags for sending internal message (see SENDRAWMSG in TVM spec).
    uint16 sendFlags;
    // Payload used as body of outbound internal message.
    TvmCell payload;
    // Bounce flag for header of outbound internal message.
    bool bounce;
}

struct CustodianInfo {
    uint8 index;
    uint256 pubkey;
}

interface IMultisig {
    function submitTransaction(
        address  dest,
        uint128 value,
        bool bounce,
        bool allBalance,
        TvmCell payload)
    external returns (uint64 transId);

    function confirmTransaction(uint64 transactionId) external;

    function getCustodians() external returns (CustodianInfo[] custodians);
    function getTransactions() external returns (Transaction[] transactions);
}

/// @notice Multisig Debot v1 (with debot interfaces).
contract MsigDebot is Debot, Upgradable, Transferable {

    address m_wallet;
    uint128 m_balance;
    CustodianInfo[] m_custodians;
    Transaction[] m_transactions;

    bool m_bounce;
    uint128 m_tons;
    address m_dest;

    // Default constructor

    /*
    * Debot Basic API
    */

    function start() public override {
        Terminal.print(0, "Hi, I will help you work with multisig wallets that can have multiple custodians.");
        _start();
    }

    function _start() private {
        AddressInput.get(tvm.functionId(startChecks), "Which wallet do you want to work with?");
    }

    function _version(uint24 major, uint24 minor, uint24 fix) private pure inline returns (uint24) {
        return (major << 16) | (minor << 8) | (fix);
    }

    function getVersion() public override returns (string name, uint24 semver) {
        (name, semver) = ("Multisig DeBot from TON Labs", _version(1,0,0));
    }

    /*
    * Public
    */

    function startChecks(address value) public {
        Sdk.getAccountType(tvm.functionId(checkStatus), value);
        m_wallet = value;
	}

    function checkStatus(int8 acc_type) public {
        if (!_checkActiveStatus(acc_type, "Wallet")) return;

        // TODO: check that it is a multisig wallet

        preMain();
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

    function preMain() public  {
        _getTransactions(tvm.functionId(setTransactions));
        _getCustodians(tvm.functionId(setCustodians));
        Sdk.getBalance(tvm.functionId(initWallet), m_wallet);
    }

    function setTransactions(Transaction[] transactions) public {
        m_transactions = transactions;
    }

    function setCustodians(CustodianInfo[] custodians) public {
        m_custodians = custodians;
    }

    function initWallet(uint128 nanotokens) public {
        m_balance = nanotokens;
        mainMenu();
    }

    function mainMenu() public {
        (uint64 dec, uint64 float) = tokens(m_balance);
        string floatStr = format("{}", float);
        while (floatStr.byteLength() < 9) {
            floatStr = "0" + floatStr;
        }
        string str = format("This wallet has {}.{} tokens on the balance. It has {} custodian(s) and {} unconfirmed transactions.",
            dec, floatStr, m_custodians.length, m_transactions.length);
        Terminal.print(0, str);

        _gotoMainMenu();
    }

    function startSubmit(uint32 index) public {
        index = index;
        AddressInput.get(tvm.functionId(setDest), "What is the recipient address?");
    }

    function setDest(address value) public {
        m_dest = value;
        Sdk.getAccountType(tvm.functionId(checkRecipient), value);
    }

    function checkRecipient(int8 acc_type) public {
        if (!_checkActiveStatus(acc_type, "Recipient")) return;

        m_bounce = true;
        AmountInput.get(tvm.functionId(setTons), "How many tokens to send?", 9, 1e7, m_balance);
    }

    function setTons(uint128 value) public {
        m_tons = value;
        (uint64 integer, uint64 float) = tokens(m_tons);
        string floatStr = format("{}", float);
        while (floatStr.byteLength() < 9) {
            floatStr = "0" + floatStr;
        }
        string fmt = format("Check transaction details.\nRecipient: {}.\nAmount: {}.{} tokens.\nConfirm?", m_dest, integer, floatStr);
        ConfirmInput.get(tvm.functionId(submit), fmt);
    }

    function submit(bool value) public {
        if (!value) {
            Terminal.print(0, "Ok, maybe next time.");
            _start();
            return;
        }
        TvmCell empty;
        optional(uint256) pubkey = 0;
        IMultisig(m_wallet).submitTransaction{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now),
                expire: 0,
                callbackId: 0, //tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(m_dest, m_tons, m_bounce, false, empty);

        Terminal.print(0, "OK. I'm ready to new things.");
        _start();
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        sdkError = sdkError;
        exitCode = exitCode;
        Terminal.print(0, format("Operation failed."));
    }

    function onSuccess() public {
        if (m_custodians.length == 1) {
            Terminal.print(0, "Transaction succeeded.");
        } else {
            Terminal.print(0, "Transaction submitted.");
        }
    }

    function showCustodians(uint32 index) public {
        index = index;
        Terminal.print(0, "Wallet custodian public key(s):");
        for (uint i = 0; i < m_custodians.length; i++) {
            Terminal.print(0, format("{:x}", m_custodians[i].pubkey));
        }
        _gotoMainMenu();
    }

    function showTransactions(uint32 index) public {
        index = index;
        Terminal.print(0, "Unconfirmed transactions:");
        for (uint i = 0; i < m_transactions.length; i++) {
            Transaction txn = m_transactions[i];
            (uint64 integer, uint64 float) = tokens(uint64(txn.value));
            string floatStr = format("{}", float);
            while (floatStr.byteLength() < 9) {
                floatStr = "0" + floatStr;
            }
            Terminal.print(0, format("ID {:x}\nRecipient: {}\nAmount: {}.{}\nConfirmations received: {}\nConfirmations required: {}\nCreator custodian public key: {:x}",
                txn.id, txn.dest, integer, floatStr,
                txn.signsReceived, txn.signsRequired, txn.creator));
        }
        _gotoMainMenu();
    }

    function printMenu(uint32 index) public view {
        index = index;
        _gotoMainMenu();
    }

    function confirmMenu(uint32 index) public view {
        index = index;
        _getTransactions(tvm.functionId(printConfirmMenu));
    }

    function printConfirmMenu(Transaction[] transactions) public {
        m_transactions = transactions;
        if (m_transactions.length == 0) {
            _gotoMainMenu();
            return;
        }

        MenuItem[] items;
        for (uint i = 0; i < m_transactions.length; i++) {
            Transaction txn = m_transactions[i];
            items.push( MenuItem(format("ID {:x}", txn.id), "", tvm.functionId(confirmTxn)) );
        }
        items.push( MenuItem("Back", "", tvm.functionId(printMenu)) );
        Menu.select("Choose transaction:", "", items);
    }

    function confirmTxn(uint32 index) public view {
        uint64 id = m_transactions[index].id;

        optional(uint256) pubkey = 0;
        IMultisig(m_wallet).confirmTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: 0, //tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        }(id);

        confirmMenu(0);
    }

    function _gotoMainMenu() private view {
        _getTransactions(tvm.functionId(printMainMenu));
    }

    function printMainMenu(Transaction[] transactions) public {
        m_transactions = transactions;
        MenuItem[] items;
        items.push( MenuItem("Submit transaction", "", tvm.functionId(startSubmit)) );
        items.push( MenuItem("Show custodians", "", tvm.functionId(showCustodians)) );
        if (m_transactions.length != 0) {
            items.push( MenuItem("Show transactions", "", tvm.functionId(showTransactions)) );
            items.push( MenuItem("Confirm transaction", "", tvm.functionId(confirmMenu)) );
        }
        Menu.select("What's next?", "", items);
    }

    function tokens(uint128 nanotokens) private pure returns (uint64, uint64) {
        uint64 decimal = uint64(nanotokens / 1e9);
        uint64 float = uint64(nanotokens - (decimal * 1e9));
        return (decimal, float);
    }

    function _getTransactions(uint32 answerId) private view {
        optional(uint256) none;
        IMultisig(m_wallet).getTransactions{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function _getCustodians(uint32 answerId) private view {
        optional(uint256) none;
        IMultisig(m_wallet).getCustodians{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }
}