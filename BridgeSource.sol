// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

/**
 * @title BridgeSource
 * @dev Handles locking of assets on the origin chain.
 */
contract BridgeSource {
    address public owner;
    IERC20 public token;

    event TokensLocked(address indexed requester, uint256 amount, uint256 timestamp);
    event TokensUnlocked(address indexed receiver, uint256 amount, uint256 timestamp);

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    function lock(uint256 _amount) external {
        require(_amount > 0, "Amount must be > 0");
        token.transferFrom(msg.sender, address(this), _amount);
        emit TokensLocked(msg.sender, _amount, block.timestamp);
    }

    // Only callable by a verified Relayer/Oracle after verification from Dest chain
    function unlock(address _receiver, uint256 _amount) external {
        require(msg.sender == owner, "Only owner/relayer");
        token.transfer(_receiver, _amount);
        emit TokensUnlocked(_receiver, _amount, block.timestamp);
    }
}
