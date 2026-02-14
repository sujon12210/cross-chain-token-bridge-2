// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

/**
 * @title WrappedToken
 * @dev The minted asset representing the locked token on the source chain.
 */
contract WrappedToken is ERC20 {
    address public bridge;

    constructor() ERC20("Wrapped Asset", "W-AST") {
        bridge = msg.sender;
    }

    function mint(address _to, uint256 _amount) external {
        require(msg.sender == bridge, "Only bridge can mint");
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external {
        require(msg.sender == bridge, "Only bridge can burn");
        _burn(_from, _amount);
    }
}

/**
 * @title BridgeDestination
 * @dev Handles minting and burning on the target chain.
 */
contract BridgeDestination {
    address public owner;
    WrappedToken public wrappedToken;

    event TokensMinted(address indexed receiver, uint256 amount);
    event TokensBurned(address indexed requester, uint256 amount);

    constructor() {
        owner = msg.sender;
        wrappedToken = new WrappedToken();
    }

    // Triggered by Relayer after seeing "TokensLocked" on Source
    function mintFromBridge(address _receiver, uint256 _amount) external {
        require(msg.sender == owner, "Only relayer");
        wrappedToken.mint(_receiver, _amount);
        emit TokensMinted(_receiver, _amount);
    }

    function burnToBridge(uint256 _amount) external {
        wrappedToken.burn(msg.sender, _amount);
        emit TokensBurned(msg.sender, _amount);
    }
}
