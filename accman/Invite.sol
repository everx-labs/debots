pragma ton-solidity >=0.43.0;
pragma AbiHeader expire;
pragma AbiHeader time;

contract Invite {

    address static account;

    constructor() public {
        TvmCell code = tvm.code();
        optional(TvmCell) salt = tvm.codeSalt(code);
        require(salt.hasValue(), 101);
        (, address rootAddr) = salt.get().toSlice().decode(uint8, address);
        require(msg.sender == rootAddr, 102);
    }
}