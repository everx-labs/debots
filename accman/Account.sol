pragma ton-solidity >=0.43.0;
pragma AbiHeader expire;
pragma AbiHeader time;

contract Account {

    uint32 public m_number;

    function transfer(address dest, uint128 amount, bool bounce, uint16 flags) public view {
        require(tvm.pubkey() == msg.pubkey(), 100);
        tvm.accept();
        dest.transfer(amount, bounce, flags);
    }

    function onCodeUpgrade(TvmCell args) internal {
        tvm.resetStorage();
        m_number = args.toSlice().decode(uint32);
    }
}