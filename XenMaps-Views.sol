// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./XenMaps.sol";
import "./BokkyPooBahsDateTimeLibrary.sol"; // Ensure this library is correctly imported

interface XenMapsViewsInterface {
    function checkTokenIdByBlockNumber(string memory blockNumber) external view returns (uint256);
    function listAllTokensByOwner(address owner) external view returns (uint256[] memory);
    function mintDateToString(uint256 mintDate) external pure returns (string memory);
    function uintToString(uint256 value) external pure returns (string memory);
    function toLower(string memory str) external pure returns (string memory);
    function validateBlockNumber(string memory blockNumber) external pure returns (bool);
}

contract XenMapsViews is XenMapsViewsInterface {
    XenMaps public xenMapsContract;
    address public owner;

    constructor(address _xenMapsAddress) {
        xenMapsContract = XenMaps(_xenMapsAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Error: Check Input, Token Existence, or Permission");
        _; // Correct placement of the semicolon
    }

    function checkTokenIdByBlockNumber(string memory blockNumber) external view override returns (uint256) {
        string memory lowercaseBlockNumber = toLower(blockNumber);
        uint256 tokenId = xenMapsContract.getTokenIdByBlockNumber(lowercaseBlockNumber);
        require(tokenId != 0, "Error: Check Input, Token Existence, or Permission");
        return tokenId;
    }

    function listAllTokensByOwner(address ownerAddress) external view override returns (uint256[] memory) {
        uint256 balance = xenMapsContract.balanceOf(ownerAddress);
        uint256[] memory tokens = new uint256[](balance);
        for (uint256 i = 0; i < balance; i++) {
            tokens[i] = xenMapsContract.tokenOfOwnerByIndex(ownerAddress, i);
        }
        return tokens;
    }

    function mintDateToString(uint256 mintDate) external pure override returns (string memory) {
        (uint year, uint month, uint day,,,) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(mintDate);
        return string(abi.encodePacked(uintToString(day), "/", uintToString(month), "/", uintToString(year)));
    }

    function setXenMapsContractAddress(address _xenMapsAddress) external onlyOwner {
        xenMapsContract = XenMaps(_xenMapsAddress);
    }

    function getXenMapsContractAddress() external view returns (address) {
        return address(xenMapsContract);
    }

    function uintToString(uint256 value) public pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 tempValue = value;
        uint256 digits;
        while (tempValue != 0) {
            digits++;
            tempValue /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + value % 10));
            value /= 10;
        }
        return string(buffer);
    }

    function toLower(string memory str) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        for (uint256 i = 0; i < strBytes.length; i++) {
            if ((uint8(strBytes[i]) >= 65) && (uint8(strBytes[i]) <= 90)) {
                strBytes[i] = bytes1(uint8(strBytes[i]) + 32);
            }
        }
        return string(strBytes);
    }

    function readBlockData(string memory blockNumber) public view returns (string memory) {
        string memory lowercaseBlockNumber = toLower(blockNumber);
        uint256 tokenId = xenMapsContract.getTokenIdByBlockNumber(lowercaseBlockNumber);
        require(tokenId != 0, "Error: Check Input, Token Existence, or Permission");

        XenMaps.XenMapsMetadata memory metadata = xenMapsContract.getXenMapsMetadata(tokenId);
        return metadata.message;
    }

    function validateBlockNumber(string memory blockNumber) external pure override returns (bool) {
        bytes memory blockNumberBytes = bytes(blockNumber);
        bytes memory suffixBytes = bytes(".xenmap");
        uint256 suffixLength = suffixBytes.length;
        if (blockNumberBytes.length < suffixLength) {
            return false;
        }
        for (uint256 i = 0; i < suffixLength; i++) {
            if (blockNumberBytes[blockNumberBytes.length - suffixLength + i] != suffixBytes[i]) {
                return false;
            }
        }
        return true;
    }
}
