pragma ton-solidity >=0.43.0;
pragma AbiHeader expire;
pragma AbiHeader time;

contract AccBase {

    uint16 static public seqno;

    function upgrade(TvmCell code, bytes signature, TvmCell args) public view {
        require(msg.sender != address(0), 101);
        require(tvm.checkSign(tvm.hash(code), signature.toSlice(), tvm.pubkey()), 102);
        tvm.setcode(code);
        tvm.setCurrentCode(code);
        onCodeUpgrade(args);
    }

    function onCodeUpgrade(TvmCell args) internal pure {
        args;
    }
}