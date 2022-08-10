// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PixelTest is ERC1155, Ownable, ERC1155Burnable {
    using Strings for uint256;

    // Membership tiers
    uint8 public constant GOLD = 0;
    uint8 public constant PLATINUM = 1;
    uint8 public constant DIAMOND = 2;
    uint8 public constant TRIPLEA = 3;

    // Ensure 1 mint per wallet
    mapping(address => bool) public _minted;
    bool private _mintEnabled = false;

    // Keep track of mint amount
    uint8 private _goldCount = 0;
    uint8 private _platinumCount = 0;
    uint8 private _diamondCount = 0;
    uint8 private _tripleaCount = 0;

    // Max supply variables
    uint8 public goldMax = 50;
    uint8 public platinumMax = 30;
    uint8 public diamondMax = 20;
    uint8 public tripleaMax = 15;

    /*  Max available to mint

        For example if this is set to 20
        but 8 NFTs have already been minted,
        there are only 12 left (20-8) to be minted
        by the public

    */
    uint8 public goldAvailable = 1;
    uint8 public platinumAvailable = 1;
    uint8 public diamondAvailable = 1;
    uint8 public tripleaAvailable = 1;

    // Pricing for each NFT Tier
    // Prices can be updated in setPrice function
    uint256 public goldPrice = 0.01 ether;
    uint256 public platinumPrice = 0.01 ether;
    uint256 public diamondPrice = 0.01 ether;
    uint256 public tripleaPrice = 0.01 ether;

    event NFTminted (address sender, uint256 tokenId);


    constructor(string memory uri_) ERC1155("") {
        _setURI(uri_);
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(ERC1155.uri(tokenId), tokenId.toString(), ".json"));
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(uint8 tier) public payable onlyOwner
    {
        require(_mintEnabled, "Minting is NOT enabled!");
        require(!_minted[msg.sender], "This wallet has already minted!");
        require(tier <= TRIPLEA, "Invalid membership type");

        _minted[msg.sender] = true;

        if (tier == GOLD)
        {
            require(_goldCount < goldAvailable, "None available to mint");
            require(msg.value >= goldPrice, "Transaction value too low");
            _goldCount++;
            _mint(msg.sender, 0, 1, "");
            return;
        } 
        if (tier == PLATINUM) 
        {
            require(_platinumCount < platinumAvailable, "None available to mint");
            require(msg.value >= platinumPrice, "Transaction value too low");
            _platinumCount++;
            _mint(msg.sender, 2, 1, "");
            return;
        }
        if (tier == DIAMOND)
        {
            require(_diamondCount < diamondAvailable, "None available to mint");
            require(msg.value >= diamondPrice, "Transaction value too low");
            _diamondCount++;
            _mint(msg.sender, 1, 1, "");
            return;
        } 
        if (tier == TRIPLEA) 
        {
            require(_tripleaCount < tripleaAvailable, "None available to mint");
            require(msg.value >= tripleaPrice, "Transaction value too low");
            _tripleaCount++;
            _mint(msg.sender, 3, 1, "");
            return;
        }
    }

    function setPrice(uint8 tier, uint256 newPrice) public onlyOwner {
        require(newPrice > 0, "Value must be greater than ZERO");
        if (tier == GOLD)
        {
            goldPrice = newPrice;
        }
        if (tier <= PLATINUM)
        {
            platinumPrice = newPrice;
        }
        if (tier <= DIAMOND)
        {
            diamondPrice = newPrice;
        }
        if (tier <= TRIPLEA)
        {
            tripleaPrice = newPrice;
        }
    }

    function getPrice(uint8 tier) public view returns(uint256) {
        if (tier == GOLD)
        {
            return goldPrice;
        }
        if (tier == PLATINUM)
        {
            return platinumPrice;
        }
        if (tier == DIAMOND)
        {
            return diamondPrice;
        }
        if (tier == TRIPLEA)
        {
            return tripleaPrice;
        }
        else
        {
            return 0;
        }
    }

    function setAvailable(uint8 tier, uint8 newAvailable) public onlyOwner {
        if (tier == GOLD)
        {
            require(goldAvailable <= goldMax, "Available cannot exceed max supply");
            goldAvailable = newAvailable;
        }
        if (tier <= PLATINUM)
        {
            require(platinumAvailable <= platinumMax, "Available cannot exceed max supply");
            platinumAvailable = newAvailable;
        }
        if (tier <= DIAMOND)
        {
            require(diamondAvailable <= diamondMax, "Available cannot exceed max supply");
            diamondAvailable = newAvailable;
        }
        if (tier <= TRIPLEA)
        {
            require(tripleaAvailable <= tripleaMax, "Available cannot exceed max supply");
            tripleaAvailable = newAvailable;
        }
    }

    // Admin mint function
    // Please note that this function will ignore the 1 mint per wallet rule
    function safeMint(uint8 tier, address recieveAddress) public onlyOwner {
        if (tier == GOLD)
        {
            require(_goldCount < goldAvailable, "None available to mint");
            _goldCount++;
            _mint(recieveAddress, 0, 1, "");
        } 
        if (tier == PLATINUM) 
        {
            require(_platinumCount < platinumAvailable, "None available to mint");
            _platinumCount++;
            _mint(recieveAddress, 2, 1, "");
        }
        if (tier == DIAMOND)
        {
            require(_diamondCount < diamondAvailable, "None available to mint");
            _diamondCount++;
            _mint(recieveAddress, 1, 1, "");
        } 
        if (tier == TRIPLEA) 
        {
            require(_tripleaCount < tripleaAvailable, "None available to mint");
            _tripleaCount++;
            _mint(recieveAddress, 3, 1, "");
        }
    }

    function setMintEnabled(bool value) public onlyOwner {
        _mintEnabled = value;
    }

    // Allow burnable externally for future use
    function burn(uint256 id, uint256 amount) external {
        _burn(msg.sender, id, amount);
    }
}