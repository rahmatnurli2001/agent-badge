// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Agent Badge
/// @notice A free soulbound (non-transferable) NFT badge for Agent ID holders.
/// @dev Minimal ERC-721. Only addresses holding an Agent ID (SPACE ID, BNB Chain)
/// can claim a badge or register a profile. One badge per address. The badge is
/// soulbound: every transfer / approval reverts. This contract has NO owner and
/// NO privileged functions — nobody can mint, pause, freeze, tax, or withdraw.
/// The Agent ID contract address is set once in the constructor and can never
/// be changed. tokenURI is intentionally omitted (gas): badge metadata is
/// served by the project website at https://agentbadge.pages.dev/badge/<id>.json
interface IAgentID {
    function balanceOf(address owner) external view returns (uint256);
}

contract AgentBadge {
    // ---- ERC-721 metadata ----
    string public constant name = "Agent Badge";
    string public constant symbol = "ABADGE";

    // ---- Agent ID gating (set once, immutable) ----
    IAgentID public immutable agentId;

    // ---- ERC-721 minimal storage ----
    uint256 public totalSupply;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;

    // ---- Badge + profile storage ----
    mapping(address => bool) public hasClaimed;
    mapping(address => string) public profileName;
    mapping(address => string) public profileEndpoint;

    // ---- Events ----
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Claimed(address indexed holder, uint256 indexed tokenId);
    event ProfileRegistered(address indexed holder, string name, string endpoint);

    /// @notice Deploy with the Agent ID contract address (set once, immutable).
    constructor(address agentIdContract) {
        require(agentIdContract != address(0), "zero agent id contract");
        agentId = IAgentID(agentIdContract);
    }

    modifier onlyAgentIdHolder() {
        require(agentId.balanceOf(msg.sender) > 0, "not an Agent ID holder");
        _;
    }

    // ---- Claim ----

    /// @notice Claim the one free soulbound badge for the caller.
    /// @dev Only an Agent ID holder, only once. Free — the caller pays gas only.
    /// @return tokenId The newly minted badge id (starts at 1, increments).
    function claim() external onlyAgentIdHolder returns (uint256 tokenId) {
        require(!hasClaimed[msg.sender], "already claimed");
        hasClaimed[msg.sender] = true;
        tokenId = ++totalSupply;
        _owners[tokenId] = msg.sender;
        _balances[msg.sender] = 1;
        emit Transfer(address(0), msg.sender, tokenId);
        emit Claimed(msg.sender, tokenId);
    }

    // ---- Profile ----

    /// @notice Register (or update) the caller's agent profile.
    /// @dev Only an Agent ID holder. Name max 64 bytes, endpoint max 200 bytes.
    /// profileName / profileEndpoint are public mappings (auto getters); use
    /// them to read a holder's profile.
    function registerProfile(string calldata name_, string calldata endpoint_) external onlyAgentIdHolder {
        require(bytes(name_).length > 0, "empty name");
        require(bytes(name_).length <= 64, "name too long");
        require(bytes(endpoint_).length <= 200, "endpoint too long");
        profileName[msg.sender] = name_;
        profileEndpoint[msg.sender] = endpoint_;
        emit ProfileRegistered(msg.sender, name_, endpoint_);
    }

    // ---- ERC-721 minimal views ----

    function balanceOf(address owner_) external view returns (uint256) {
        require(owner_ != address(0), "zero address");
        return _balances[owner_];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        address owner_ = _owners[tokenId];
        require(owner_ != address(0), "nonexistent token");
        return owner_;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        // 0x01ffc9a7 = ERC165, 0x80ac58cd = ERC721
        return interfaceId == 0x01ffc9a7 || interfaceId == 0x80ac58cd;
    }

    // ---- Soulbound: every transfer / approval reverts ----

    function transferFrom(address, address, uint256) external pure {
        revert("soulbound: transfer blocked");
    }

    function safeTransferFrom(address, address, uint256) external pure {
        revert("soulbound: transfer blocked");
    }

    function safeTransferFrom(address, address, uint256, bytes calldata) external pure {
        revert("soulbound: transfer blocked");
    }

    function approve(address, uint256) external pure {
        revert("soulbound: approve blocked");
    }

    function setApprovalForAll(address, bool) external pure {
        revert("soulbound: approve blocked");
    }

    function getApproved(uint256) external pure returns (address) {
        return address(0);
    }

    function isApprovedForAll(address, address) external pure returns (bool) {
        return false;
    }
}
