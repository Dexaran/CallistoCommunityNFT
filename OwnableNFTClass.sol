// SPDX-License-Identifier: MIT
// Based on OpenZeppelin Contract Ownable.sol

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions for classes of Callisto NFT standard.
 *
 * By default, the owner account will be the one that creates the class. This
 * can later be changed with {transferClassOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyClassOwner`, which can be applied to your functions to restrict their use to
 * the class owner.
 */
abstract contract OwnableClass is Context {
    //Class => Owner
    mapping (uint => address) private _classOwners;

    event ClassOwnershipTransferred(address indexed previousClassOwner, address indexed newClassOwner);

    /**
     * @dev Throws if called by any account other than the class owner.
     */
    modifier onlyClassOwner(uint256 classID) {
        _checkClassOwner(classID);
        _;
    }

    /**
     * @dev Returns the address of the slected class owner.
     */
    function classOwner(uint256 classID) public view virtual returns (address) {
        return _classOwners[classID];
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkClassOwner(uint256 classID) internal view virtual {
        require(classOwner(classID) == _msgSender(), "Ownable: caller is not the owner of the Class");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceClassOwnership(uint256 classID) public virtual onlyClassOwner(classID) {
        _transferClassOwnership(address(0), classID);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferClassOwnership(address newOwner, uint256 classID) public virtual onlyClassOwner(classID) {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferClassOwnership(newOwner, classID);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferClassOwnership(address newClassOwner, uint256 classID) internal virtual {
        address oldClassOwner = _classOwners[classID];
        _classOwners[classID] = newClassOwner;
        emit ClassOwnershipTransferred(oldClassOwner, newClassOwner);
    }
}
