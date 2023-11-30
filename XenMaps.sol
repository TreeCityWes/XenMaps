//8b        d8                          88b           d88                                      
// Y8,    ,8P                           888b         d888                                      
//  `8b  d8'                            88`8b       d8'88                                      
//    Y88P      ,adPPYba,  8b,dPPYba,   88 `8b     d8' 88  ,adPPYYba,  8b,dPPYba,   ,adPPYba,  
//   d88b     a8P_____88  88P'   `"8a  88  `8b   d8'  88  ""     `Y8  88P'    "8a  I8[    ""  
//  ,8P  Y8,   8PP"""""""  88       88  88   `8b d8'   88  ,adPPPPP88  88       d8   `"Y8ba,   
// d8'    `8b  "8b,   ,aa  88       88  88    `888'    88  88,    ,88  88b,   ,a8"  aa    ]8I  
//8P        Y8  `"Ybbd8"'  88       88  88     `8'     88  `"8bbdP"Y8  88`YbbdP"'   `"YbbdP"'  
//                                                                     88                      
//                                                                     88                      
// Code mined by TreeCityWes.eth
// XenMaps.io // Xen.Network
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 
import "./Base64.sol";
import "./BokkyPooBahsDateTimeLibrary.sol";
import "./XenMaps-Views.sol"; 

contract XenMaps is ERC721Enumerable, Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint256 public tokenIdCounter;
    event Minted(uint256 indexed tokenId, address indexed owner);
    event BlockDataWritten(uint256 indexed tokenId, string message);

    struct XenMapsMetadata {
        string title;
        string message;
        uint256 mintDate;
    }

    mapping(uint256 => XenMapsMetadata) private xenMapsMetadata;
    mapping(string => uint256) internal blockNumberToTokenId;

    XenMapsViewsInterface public xenMapsViews; 

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
        Ownable(msg.sender)
    {
        tokenIdCounter = 1;
    }

    function setXenMapsViewsAddress(address _xenMapsViewsAddress) public onlyOwner {
        xenMapsViews = XenMapsViewsInterface(_xenMapsViewsAddress);

    }
    function mint(string memory blockNumber) public nonReentrant {
        string memory lowercaseBlockNumber = xenMapsViews.toLower(blockNumber);
        require(blockNumberToTokenId[lowercaseBlockNumber] == 0, "Error: Check Input, Token Existance, or Permission");
        uint256 tokenId = tokenIdCounter;
        tokenIdCounter++;
        blockNumberToTokenId[lowercaseBlockNumber] = tokenId;
        xenMapsMetadata[tokenId] = XenMapsMetadata({
            title: blockNumber,
            message: "#StayXen",
            mintDate: block.timestamp
        });
        _mint(msg.sender, tokenId);
        emit Minted(tokenId, msg.sender);
    }

    function writeBlockData(string memory blockNumber, string memory message) public nonReentrant {
        uint256 tokenId = blockNumberToTokenId[xenMapsViews.toLower(blockNumber)];
        require(tokenId != 0, "Error: Check Input, Token Existance, or Permission");
        require(ownerOf(tokenId) == msg.sender, "Error: Check Input, Token Existance, or Permission");
        require(bytes(message).length <= 140, "Error: Check Input, Token Existance, or Permission");
        message = escapeHTML(message);
        XenMapsMetadata storage metadata = xenMapsMetadata[tokenId];
        metadata.message = message;
        emit BlockDataWritten(tokenId, message);
    }

    function getBlockNumberByTokenId(uint256 tokenId) public view returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Error: Check Input, Token Existance, or Permission");
        return xenMapsMetadata[tokenId].title;
    }

    function getTokenIdByBlockNumber(string memory blockNumber) public view returns (uint256) {
        return blockNumberToTokenId[blockNumber];
    }

    function mintDateToString(uint256 mintDate) internal view returns (string memory) {
        return xenMapsViews.mintDateToString(mintDate);
    }

    function uintToString(uint256 value) internal view returns (string memory) {
        return xenMapsViews.uintToString(value);
    }


    function generateSVG(uint256 tokenId) internal view returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Error: Check Input, Token Existance, or Permission");
        XenMapsMetadata memory metadata = xenMapsMetadata[tokenId];
        string memory contractAddress = Strings.toHexString(uint160(address(this)), 20); // Get the contract address
        string memory blockNumber = metadata.title;
        string memory message = metadata.message;
        string memory mintDateString = mintDateToString(metadata.mintDate);

        string memory svg = string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 566">',
            '<defs>',
            '<radialGradient id="gradient" cx="50%" cy="50%" r="75%" fx="50%" fy="50%">',
            '<stop offset="0%" stop-color="black" />',
            '<stop offset="80%" stop-color="#00FF00" />',
            '<stop offset="100%" stop-color="#00FF00" />',
            '</radialGradient>',
            '<style>',
            '.title { fill: white; font-size: 12px; text-shadow: 1px 1px 2px black; }',
            '.content { font-family: Calibri; font-size: 12px; font-weight: 400; color: white; }',
            '.black-text { font-family: Calibri; font-size: 12px; font-weight: 400; fill: black; }',
            '.bigger-text { font-family: Calibri; font-size: 14px; font-weight: 400; fill: black; }',
            '</style>',
            '</defs>',
            '<rect width="100%" height="100%" fill="url(#gradient)" rx="10px" ry="10px" stroke-linejoin="round" />',
            '<rect width="92%" height="94%" fill="transparent" rx="10px" ry="10px" stroke="#008000" stroke-width="3" stroke-dasharray="5,5" x="4%" y="3%" />',
            '<rect width="94%" height="96%" fill="transparent" rx="10px" ry="10px" stroke-linejoin="round" stroke-dasharray="5,5" x="3%" y="2%" />',
            '<text x="50%" y="5%" class="contract-text" dominant-baseline="middle" text-anchor="middle" font-family="Calibri" font-size="12px" font-weight="400" fill="black">',
            string(abi.encodePacked("$XMAP: ", contractAddress)), '</text>',
            '<path fill="white" d="M122.7,227.1 l-4.8,0l55.8,-74l0,3.2l-51.8,-69.2l5,0l48.8,65.4l-1.2,0l48.8,-65.4l4.8,0l-51.2,68.4l0,-1.6l55.2,73.2l-5,0l-52.8,-70.2l1.2,0l-52.8,70.2z" vector-effect="non-scaling-stroke" />',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle" font-family="Calibri" font-size="44px" font-weight="400" fill="white" text-shadow="2px 2px 4px rgba(0, 0, 0, 0.5)">XenMaps</text>',
            '<text x="50%" y="63%" class="base" dominant-baseline="middle" text-anchor="middle" font-family="Calibri" font-size="36px" font-weight="400" fill="white" text-shadow="2px 2px 4px rgba(0, 0, 0, 0.5)">', blockNumber, '</text>',
            '<rect x="10%" y="72%" width="80%" height="20%" fill="rgba(0,0,0,0.8)" rx="10px" ry="10px" />',
            '<foreignObject x="10%" y="72%" width="80%" height="20%">',
            '<div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; justify-content: center; align-items: center; height: 100%; white-space: normal; word-wrap: break-word;">',
            '<span style="text-align: center; width: 100%; color: white;">', message, '</span>',
            '</div>',
            '</foreignObject>',
            '<text x="50%" y="95%" class="base" dominant-baseline="middle" text-anchor="middle" font-family="Calibri" font-size="14px" font-weight="400" fill="black">',
            'Date Minted: ', mintDateString,
            '</text>',
            '</svg>'
        ));

        return svg;
    }

    function getXenMapsMetadata(uint256 tokenId) public view returns (XenMapsMetadata memory) {
        require(ownerOf(tokenId) != address(0), "Error: Check Input, Token Existance, or Permission");
        return xenMapsMetadata[tokenId];
    }


    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Error: Invalid input or token does not exist."); // Updated check
        XenMapsMetadata memory metadata = xenMapsMetadata[tokenId];
        string memory imageSVG = generateSVG(tokenId);
        string memory imageURI = string(abi.encodePacked('data:image/svg+xml;base64,', Base64.encode(bytes(imageSVG))));
        string memory json = string(
            abi.encodePacked(
                '{"name":"',
                metadata.title,
                '", "image":"',
                imageURI,
                '", "attributes": [',
                '{"trait_type": "Message", "value": "', metadata.message, '"},',
                '{"trait_type": "Minted On Date", "value": "', mintDateToString(metadata.mintDate), '"},',
                '{"trait_type": "TokenID", "value": "', tokenId.toString(), '"}',
                ']}'
            )
        );
        return json;
    }

    function substring(string memory str, uint256 startIndex, uint256 endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function escapeHTML(string memory str) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        string memory escapedStr = "";
        for (uint256 i = 0; i < strBytes.length; i++) {
            if (strBytes[i] == "<" || strBytes[i] == ">" || strBytes[i] == "&" || strBytes[i] == "\"" || strBytes[i] == "'") {
                escapedStr = string(abi.encodePacked(escapedStr, " "));
            } else {
                escapedStr = string(abi.encodePacked(escapedStr, strBytes[i]));
            }
        }
        return escapedStr;
    }
}
