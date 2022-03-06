// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// Importing OpenZeppelin's template
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./MerkleTree.sol";
import "./Base64.sol"; // Loopring's implementation

contract ZkNFT is ERC721 {

    using Base64 for bytes;

    mapping (uint256 => string) tokenName;
    mapping (uint256 => string) tokenDescription;

    mapping (uint256 => bytes32) leaves;

    MerkleTree merkleTree;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        merkleTree = new MerkleTree();
    }

    function mint(address receiver, uint256 id, string memory _name, string memory _description) public {
        _mint(receiver, id);
        tokenName[id] = _name;
        tokenDescription[id] = _description;

        // Merkle Tree Update
        merkleTree.insert(
            keccak256(abi.encode(msg.sender, receiver, id, tokenURI(id)))
        );
    }


    // Code snippet from
    // https://medium.com/quick-programming/how-to-implement-fully-on-chain-nft-contracts-8c409acc98b7
    function formatTokenURI(string memory _name, string memory _description) public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"', _name,
                            '", "description": "', _description, '"}'
                        )
                    )
                )
            )
        );
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return formatTokenURI(tokenName[tokenId], tokenDescription[tokenId]);
    }

}