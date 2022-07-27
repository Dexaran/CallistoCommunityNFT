// SPDX-License-Identifier: GPL

pragma solidity ^0.8.12;

interface IClassifiedNFT {
    function setClassForTokenID(uint256 _tokenID, uint256 _tokenClass) external;
    function addNewTokenClass() external;
    function addTokenClassProperties(uint256 _propertiesCount, uint256 _classID) external;
    function modifyClassProperty(uint256 _classID, uint256 _propertyID, string memory _content) external;
    function getClassProperty(uint256 _classID, uint256 _propertyID) external view returns (string memory);
    function addClassProperty(uint256 _classID) external;
    function getClassProperties(uint256 _classID) external view returns (string[] memory);
    function getClassForTokenID(uint256 _tokenID) external view returns (uint256);
    function getClassPropertiesForTokenID(uint256 _tokenID) external view returns (string[] memory);
    function getClassPropertyForTokenID(uint256 _tokenID, uint256 _propertyID) external view returns (string memory);
    function mintWithClass(address to, uint256 classId)  external;
    function appendClassProperty(uint256 _classID, uint256 _propertyID, string memory _content) external;
}
