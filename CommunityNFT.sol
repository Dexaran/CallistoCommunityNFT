// SPDX-License-Identifier: GPL

pragma solidity ^0.8.12;

import "https://github.com/Dexaran/CallistoCommunityNFT/blob/main/ERC721CallistoNFTmodification.sol";

contract CommunityNFT is CallistoNFT {
    constructor(string memory name_, string memory symbol_, uint256 _defaultFee) CallistoNFT(name_, symbol_, _defaultFee) {
    }

    event ClassCreated(string name, uint256 id);

    mapping (uint256 => string[]) public class_properties;
    mapping (uint256 => uint256)  public token_classes;
    mapping (uint256 => address)  public class_owners;
    mapping (uint256 => bool)     public minting_permitted;
    mapping (string => uint256)   public class_names;

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

    function createTokenClass(string memory _name, bool _minting_permitted) public
    {
        if(class_names[_name] != 0)
        {
            // Registering a name that is already taken is not allowed
            revert();
        }
        class_names[_name] = nextClassIndex;
        class_owners[nextClassIndex] = msg.sender;
        minting_permitted[nextClassIndex] = _minting_permitted;
        //class_fee_levels[nextClassIndex] = 0;
        emit ClassCreated(_name, nextClassIndex);

        _addNewTokenClass();

    }

    function createTokenClass(string memory _name, bool _minting_permitted, address _feeReceiver, uint256 _feePercentage) public
    {
        Fee memory _newFee;
        _newFee.feeReceiver = payable(_feeReceiver);
        _newFee.feePercentage = _feePercentage;
        feeLevels[uint32(nextClassIndex)] = _newFee;
        
        createTokenClass(_name, _minting_permitted);
    }

    function getClassID(string memory _name) public view returns (uint256)
    {
        return class_names[_name];
    }

    function modifyClassFee(uint256 _classId, address _feeReceiver, uint256 _feePercentage) public onlyClassOwner(_classId)
    {
        Fee memory _newFee;
        _newFee.feeReceiver = payable(_feeReceiver);
        _newFee.feePercentage = _feePercentage;
        feeLevels[uint32(_classId)] = _newFee;
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
        if(feeLevels[uint32(classId)].feeReceiver != address(0))
        {
            _mint(to, tokenId, uint32(classId));
        }
        _mint(to, tokenId);
        token_classes[tokenId] = classId;
    }

    function appendClassProperty(uint256 _classID, uint256 _propertyID, string memory _content) public onlyClassOwner(_classID) onlyExistingClasses(_classID)
    {
        class_properties[_classID][_propertyID] = string.concat(class_properties[_classID][_propertyID], _content);
    }
}
