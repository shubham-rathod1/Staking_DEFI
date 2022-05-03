//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./DaiToken.sol";
import "./StakerToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenFarm is Ownable {
    bytes32 public name = "Stake Token Farm";
    DaiToken public daiToken;
    StakerToken public stakerToken;
    // token address => owner => balance
    mapping(address => uint256) public stakingBalance;
    mapping(address => bool) hasStaked;
    mapping(address => bool) public isStaking;

    address[] public stakers;
    address[] public allowedTokens;

    constructor(StakerToken _stakerToken, DaiToken _daiToken) {
        // assigning addresses of dai and stake
        daiToken = _daiToken;
        stakerToken = _stakerToken;
    }

    function addAllowedTokens(address _token) public onlyOwner {
        allowedTokens.push(_token);
    }

    function tokenIsAllowed(address _token) public view returns (bool) {
        for (
            uint256 allowedTokensIndex = 0;
            allowedTokensIndex < allowedTokens.length;
            allowedTokensIndex++
        ) {
            if (allowedTokens[allowedTokensIndex] == _token) {
                return true;
            }
        }
        return false;
    }

    function stakeToken(uint256 _amount, address _token) public payable {
        require(_amount > 0, "amount cannot be zero");
        require(tokenIsAllowed(_token), "token is not allowed yet!");

        // using interface to call function of external contract.
        // IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        daiToken.transferFrom(msg.sender, address(this), _amount);
        stakingBalance[msg.sender] += _amount;

        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }
        hasStaked[msg.sender] = true;
        isStaking[msg.sender] = true;
    }

    function issueTokens() public onlyOwner {
        // Issue tokens to all stakers
        for (
            uint256 stakersIndex = 0;
            stakersIndex < stakers.length;
            stakersIndex++
        ) {
            address recipient = stakers[stakersIndex];
            uint256 balance = stakingBalance[recipient];
            if (balance > 0) {
                stakerToken.transfer(recipient, balance);
            }
        }
    }

    function unstakeTokens() public payable {
        // Fetch staking balance
        uint256 balance = stakingBalance[msg.sender];

        // Require amount greater than 0
        require(balance > 0, "staking balance cannot be 0");

        // Transfer Mock Dai tokens to this contract for staking
        daiToken.transfer(msg.sender, balance);

        // Reset staking balance
        stakingBalance[msg.sender] = 0;

        // Update staking status
        isStaking[msg.sender] = false;
    }
}
