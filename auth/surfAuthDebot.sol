pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "include.sol";

contract AuthDebot is Debot, Upgradable {
    string m_id;
    string m_pin;
    string m_otp;
    string m_callbackUrl;
    uint32 m_sigingBoxHandle;
    uint256 m_userPK;

    bytes m_icon;

    function start() public override {
        Terminal.print(0, "I don't have default interaction flow. Invoke me.");
     }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Auth";
        version = "0.2.1";
        publisher = "TON Labs";
        key = "User authentication";
        author = "TON Labs";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, I can authenticate you in any external service";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID, 
            Network.ID, Base64.ID, UserInfo.ID, SigningBoxInput.ID  ];
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    function auth(string id, string otp, bool pinRequired, string callbackUrl) public {
        m_id =  id;
        m_otp = otp;
        m_callbackUrl = callbackUrl;

        if  (pinRequired) {
            Terminal.input(tvm.functionId(getPublicKey),"Enter PIN code:",false);
        } else {
            getPublicKey(''); 
        }
    }

    function getPublicKey(string value) public {
        m_pin = value;
        UserInfo.getPublicKey(tvm.functionId(setPk));
    }

    function setPk(uint256 value) public {
        uint256[] pubkeys;
        m_userPK = value;
   		SigningBoxInput.get(tvm.functionId(setSigningBoxHandle), "Please, sign authentication data with your key.", pubkeys);
    }

    function setSigningBoxHandle(uint32 handle) public {
        uint256 hash = sha256(m_otp + m_pin);
        Sdk.signHash(tvm.functionId(setSignature), handle, hash);
    }

    function setSignature(bytes signature) public {
         Base64.encode(tvm.functionId(setEncode), signature);
    }
 
    function setEncode(string  base64) public {
        string[] headers;
        headers.push("Content-Type: application/x-www-form-urlencoded");
        string body = "id=" + m_id + "&signature=" + base64 + "&pk=" + format("{:064x}",  m_userPK );
        Network.post(tvm.functionId(setResponse), m_callbackUrl, headers, body);
    }

   function setResponse(int32 statusCode, string[] retHeaders, string content) public {
        retHeaders;
        content;
        if (statusCode == 200) {
            Terminal.print(0,'Congratulations, authentication passed.');
        } else {
            Terminal.print(0,'Authentication FAILED.');
        }
        noop("");
    }


    function getInvokeMessage(string id, string otp, bool pinRequired, string callbackUrl) public pure returns(TvmCell message) {
        message = tvm.buildIntMsg({
            dest: address(this),
            value: 0,
            bounce: true,
            call: { AuthDebot.auth, id, otp, pinRequired, callbackUrl }
        });
    }
    
    function noop(string value) public  {
        value;
        Terminal.input(tvm.functionId(noop), "", false);
    }


}
