// SPDX-License-Identifier: GPL

pragma solidity ^0.8.12;

import "./CallistoNFT.sol";
import "./IClassifiedNFT.sol";
import "./OwnableClass.sol";

contract CommunityNFT is CallistoNFT, IClassifiedNFT, OwnableClass{

    mapping (uint256 => string[]) public class_properties;
    mapping (uint256 => uint256)  public token_classes;

    uint256 private nextClassIndex = 0;
    uint256 public next_mint_id;

    constructor(string memory _name, string memory _symbol, uint256 _defaultFee) 
    CallistoNFT(_name, _symbol, _defaultFee)
    {}

    modifier onlyExistingClasses(uint256 classID)
    {
        require(classID < nextClassIndex, "Queried class does not exist");
        _;
    }

    function setClassForTokenID(uint256 _tokenID, uint256 _classID) public override onlyClassOwner(_classID)
    {
        token_classes[_tokenID] = _classID;
    }

    function addNewTokenClass() public override
    {
        class_properties[nextClassIndex].push("");
        _transferClassOwnership(_msgSender(), nextClassIndex);
        nextClassIndex++;
    }

    function addTokenClassProperties(uint256 _propertiesCount, uint256 _classID) public override onlyClassOwner(_classID)
    {
        for (uint i = 0; i < _propertiesCount; i++)
        {
            class_properties[_classID].push("");
        }
    }

    function modifyClassProperty(uint256 _classID, uint256 _propertyID, string memory _content) public override onlyClassOwner(_classID) onlyExistingClasses(_classID)
    {
        class_properties[_classID][_propertyID] = _content;
    }

    function getClassProperty(uint256 _classID, uint256 _propertyID) public view onlyExistingClasses(_classID) returns (string memory)
    {
        return class_properties[_classID][_propertyID];
    }

    function addClassProperty(uint256 _classID) public override onlyClassOwner(_classID) onlyExistingClasses(_classID)
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
    
    function mintWithClass(address to, uint256 classID)  public override onlyClassOwner(classID) onlyExistingClasses(classID)
    {
        uint256 _tokenID = next_mint_id;
        next_mint_id++;
        _mint(to, _tokenID);
        token_classes[_tokenID] = classID;
    }

    function appendClassProperty(uint256 _classID, uint256 _propertyID, string memory _content) public override onlyClassOwner(_classID) onlyExistingClasses(_classID)
    {
        class_properties[_classID][_propertyID] = string.concat(class_properties[_classID][_propertyID], _content);
    }

}
