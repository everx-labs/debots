pragma ton-solidity >=0.43.0;
pragma AbiHeader expire;
pragma AbiHeader time;
import "Invite.sol";

contract InviteRoot {

    TvmCell m_inviteImage;
    mapping(uint256 => bool) m_hashPool;

    modifier onlyOwner() {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        _;
    }

    constructor(TvmCell image) public onlyOwner {
        m_inviteImage = image;
    }

    function addInvites(uint256[] hashes) public view onlyOwner {
        for(uint i = 0; i < hashes.length; i++) {
            if (!m_hashPool.exists(hashes[i]) ) {
                m_hashPool[hashes[i]];
            }
        }
    }

    function deleteInvite(uint256 hash) public onlyOwner {
        delete m_hashPool[hash];
    }

    function createPrivateInvite(string nonce, address account) public {
        require(msg.sender != address(0));
        uint256 hash = tvm.hash(nonce);
        require(m_hashPool.exists(hash), 101);
        deployInvite(account, 1, false);
        delete m_hashPool[hash];
    }

    function createOwnerInvite(address account) public onlyOwner {
        deployInvite(account, 1, true);
    }

    function createPublicInvite(address account) public {
        require(msg.sender != address(0));
        deployInvite(account, 0, false);
    }

    function deployInvite(address account, uint8 inviteType, bool isExternal) private returns (address) {
        TvmBuilder saltBuilder;
        // uint8 (invite type) + address (invite root addr).
        // types: 0 - public invite, 1 - private invite
        saltBuilder.store(inviteType, address(this));
        TvmCell code = tvm.setCodeSalt(
            m_inviteImage.toSlice().loadRef(),
            saltBuilder.toCell()
        );
        (uint128 value, uint16 flag) = isExternal ? (1 ton, 3) : (0, 64);
        address newInvite = new Invite {
            value: value,
            flag: flag,
            bounce: true,
            code: code,
            pubkey: tvm.pubkey(),
            varInit: { account: account } 
        }();

        return newInvite;
    }
}