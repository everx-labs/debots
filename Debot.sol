pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

abstract contract Debot {

    uint8 constant DEBOT_ABI = 1;

    uint8 m_options;
    optional(string) m_debotAbi;
    /// @notice Deprecated. For compatibility with old DEngine.
    optional(string) m_targetAbi;
    /// @notice Deprecated. For compatibility with old DEngine.
    optional(address) m_target;

    /*
     * Public debot interface
     */

    /// @notice DeBot entry point.
    function start() public virtual;

    /// @notice DeBot version and title.
    function getVersion() public virtual returns (string name, uint24 semver);

    function getRequiredInterfaces() public view virtual returns (uint256[] interfaces);

    struct DebotInfo {
    /// name String with name of debot, e.g. "DePool".
    /// version Semver version of debot, that will be converted to string like "x.y.z".
    /// publisher String with info about who has deployed debot to blokchain, e.g. "TON Labs".
    /// key (10-20 ch.) String with short description, e.g. "Work with Smthg".
    /// author String with name of author of DeBot, e.g. "Ivan Ivanov".
    /// support Free TON address of author for questions and donations.
    /// hello String with first messsage with DeBot description.
    /// language (ISO-639) String with debot interface language, e.g. "en".
    /// dabi String with debot ABI.
        string name;
        string version;
        string publisher;
        string key;
        string author;
        address support;
        string hello;
        string language;
        string dabi;
    }

    function getDebotInfo() public view virtual returns (DebotInfo info);

    /// @notice Returns DeBot ABI.
    function getDebotOptions() public view returns (uint8 options, string debotAbi, string targetAbi, address targetAddr) {
        debotAbi = m_debotAbi.hasValue() ? m_debotAbi.get() : "";
        targetAbi = m_targetAbi.hasValue() ? m_targetAbi.get() : "";
        targetAddr = m_target.hasValue() ? m_target.get() : address(0);
        options = m_options;
    }

    /// @notice Allow to set debot ABI. Do it before using debot.
    function setABI(string dabi) public {
        require(tvm.pubkey() == msg.pubkey(), 100);
        tvm.accept();
        m_options |= DEBOT_ABI;
        m_debotAbi = dabi;
    }
}