// SPDX-License-Identifier: GPL

pragma solidity ^0.8.12;

import "https://github.com/Dexaran/CallistoNFT/blob/main/ERC721Compatible/ERC721CallistoNFTHybrid.sol";

contract CommunityNFT is CallistoNFT {
    constructor(string memory name_, string memory symbol_, uint256 _defaultFee) CallistoNFT(name_, symbol_, _defaultFee) {
    }

mapping (uint256 => string[]) public class_properties;
    mapping (uint256 => uint256)  public token_classes;
    mapping (uint256 => address)  public class_owners;
    mapping (uint256 => bool)     public minting_permitted;

    uint256 private nextClassIndex = 0;
    uint256 public  nftsCount = 0; // Analogue of totalSupply but for NFT contract

    modifier onlyExistingClasses(uint256 classId)
    {
        require(classId < nextClassIndex, "Queried class does not exist");
        _;
    }

    modifier onlyClassOwner(uint256 classId)
    {
        require(msg.sender == class_owners[classId], "Only owner of the token class can perform this action");
        _;
    }

    function setClassForTokenID(uint256 _tokenID, uint256 _tokenClass) public /* onlyOwner */
    {
        token_classes[_tokenID] = _tokenClass;
    }

    function _addNewTokenClass() internal
    {
        class_properties[nextClassIndex].push("");
        nextClassIndex++;
    }

    function createTokenClass() public
    {
        class_owners[nextClassIndex] = msg.sender;
        _addNewTokenClass();
    }

    function mintNFT(uint256 _classID) public
    {
        if (!minting_permitted[_classID])
        {
            require(msg.sender == class_owners[_classID], "NFT: Only owner of the NFT is permitted to mint new tokens");
        }
        mintWithClass(msg.sender, nftsCount, _classID);
        nftsCount++;
    }

    function addTokenClassProperties(uint256 _classID, uint256 _propertiesCount) public onlyClassOwner(_classID)
    {
        for (uint i = 0; i < _propertiesCount; i++)
        {
            class_properties[_classID].push("");
        }
    }

    function modifyClassProperty(uint256 _classID, uint256 _propertyID, string memory _content) public onlyClassOwner(_classID) onlyExistingClasses(_classID)
    {
        class_properties[_classID][_propertyID] = _content;
    }

    function getClassProperty(uint256 _classID, uint256 _propertyID) public view onlyExistingClasses(_classID) returns (string memory)
    {
        return class_properties[_classID][_propertyID];
    }

    function addClassProperty(uint256 _classID) public onlyClassOwner(_classID) onlyExistingClasses(_classID)
    {
        class_properties[_classID].push("");
    }

    function getClassProperties(uint256 _classID) public view onlyExistingClasses(_classID) returns (string[] memory)
    {
        return class_properties[_classID];
    }

    function getClassForTokenID(uint256 _tokenID) public view onlyExistingClasses(token_classes[_tokenID]) returns (uint256)
    {
        return token_classes[_tokenID];
    }

    function getClassPropertiesForTokenID(uint256 _tokenID) public view onlyExistingClasses(token_classes[_tokenID]) returns (string[] memory)
    {
        return class_properties[token_classes[_tokenID]];
    }

    function getClassPropertyForTokenID(uint256 _tokenID, uint256 _propertyID) public view onlyExistingClasses(token_classes[_tokenID]) returns (string memory)
    {
        return class_properties[token_classes[_tokenID]][_propertyID];
    }
    
    function mintWithClass(address to, uint256 tokenId, uint256 classId)  internal onlyExistingClasses(classId)
    {
        _mint(to, tokenId);
        token_classes[tokenId] = classId;
    }

    function appendClassProperty(uint256 _classID, uint256 _propertyID, string memory _content) public onlyClassOwner(_classID) onlyExistingClasses(_classID)
    {
        class_properties[_classID][_propertyID] = string.concat(class_properties[_classID][_propertyID], _content);
    }
}
