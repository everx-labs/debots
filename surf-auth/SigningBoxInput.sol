pragma ton-solidity >=0.40.0;

interface ISigningBoxInput {

	function get(uint32 answerId, string prompt, uint256[] possiblePublicKeys) external returns (uint32 handle);

}

library SigningBoxInput {

	uint256 constant ID = 0xc13024e101c95e71afb1f5fa6d72f633d51e721de0320d73dfd6121a54e4d40a;
	int8 constant DEBOT_WC = -31;

	function get(uint32 answerId, string prompt, uint256[] possiblePublicKeys) public pure {
		address addr = address.makeAddrStd(DEBOT_WC, ID);
		ISigningBoxInput(addr).get(answerId, prompt, possiblePublicKeys);
	}
}

contract SigningBoxInputABI is ISigningBoxInput {

	function get(uint32 answerId, string prompt, uint256[] possiblePublicKeys) external override returns (uint32 handle) {}

}
