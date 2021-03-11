pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import 'lib/SafeMath.sol';

contract UserRecord{
    using SafeMath for uint256;
    uint256 constant MAX_USERS = 100;
    struct Hoster{
        uint256 hoster_start_timestamp;
        uint256 hoster_end_timestamp;
        bool isIPv4;
        uint256[4] IP_addr;
    }
    struct Claimer{
        address addr;
        uint256 pubkey;
        bool isIPv4;
        uint256[4] IP_addr;
        bool valid;
    }
    struct UserGroup{
        Hoster hoster;
        Claimer[MAX_USERS] claimers;
        uint256 noOfClaimers;
        uint256 amount;
        uint256 register_deadline;
        bool isTxDone;
    }
    mapping(address => UserGroup) public information;
    function initRegister(
        uint256 amount,
        uint256 register_deadline,
        uint256 hoster_start_timestamp,
        uint256 hoster_end_timestamp,
        bool hoster_isIPv4,
        uint256[4] memory hoster_IP_addr,
        uint256 pubkey,
        bool claimer_isIPv4,
        uint256[4] memory claimer_IP_addr
    ) public {
        require(information[msg.sender].hoster.hoster_end_timestamp < block.timestamp, 
        "One user must host only one transfer shuffling service until expiration.");
        require(register_deadline < hoster_start_timestamp, 
        "The register deadline must be ahead of hoster server staring timestamp");
        information[msg.sender].amount=amount;
        information[msg.sender].register_deadline=register_deadline;
        information[msg.sender].isTxDone=false;
        information[msg.sender].hoster.hoster_start_timestamp=hoster_start_timestamp;
        information[msg.sender].hoster.hoster_end_timestamp=hoster_end_timestamp;
        information[msg.sender].hoster.isIPv4=hoster_isIPv4;
        information[msg.sender].hoster.IP_addr=hoster_IP_addr;
        information[msg.sender].noOfClaimers = 1;
        uint256 noOfClaimers = information[msg.sender].noOfClaimers;
        information[msg.sender].claimers[noOfClaimers-1].addr = msg.sender;
        information[msg.sender].claimers[noOfClaimers-1].pubkey = pubkey;
        information[msg.sender].claimers[noOfClaimers-1].isIPv4 = claimer_isIPv4;
        information[msg.sender].claimers[noOfClaimers-1].IP_addr = claimer_IP_addr;
        information[msg.sender].claimers[noOfClaimers-1].valid = true;
    }
    function followRegister(
        address firstClaimer, 
        uint256 amount, 
        uint256 pubkey,         
        bool isIPv4,
        uint256[4] memory IP_addr
    ) public {
        require(information[firstClaimer].hoster.hoster_end_timestamp > block.timestamp, 
        "The first claimer address is not valid right now!");
        require(information[firstClaimer].register_deadline > block.timestamp,
        "Register deadline has passed right now!");
        require(information[firstClaimer].amount == amount,
        "The amount to be transferred does not match");
        require(information[firstClaimer].isTxDone == false,
        "The transfer is already done. Please look up other hosters");
        for(uint256 i = 0; i < information[firstClaimer].noOfClaimers; i++) {
            require(information[firstClaimer].claimers[i].addr!=msg.sender, "You already registered");
        }
        require(information[firstClaimer].noOfClaimers<MAX_USERS, "The number of claimers reaches maximum");
        information[firstClaimer].noOfClaimers = information[firstClaimer].noOfClaimers.add(1);
        uint256 noOfClaimers = information[firstClaimer].noOfClaimers;
        information[firstClaimer].claimers[noOfClaimers-1].addr = msg.sender;
        information[firstClaimer].claimers[noOfClaimers-1].pubkey = pubkey;
        information[firstClaimer].claimers[noOfClaimers-1].isIPv4 = isIPv4;
        information[firstClaimer].claimers[noOfClaimers-1].IP_addr = IP_addr;
        information[firstClaimer].claimers[noOfClaimers-1].valid = true;
    }
    // function lookUpNoOfClaimers(address firstClaimer) public view returns (uint256){
    //     require(information[msg.sender].hoster.hoster_end_timestamp > block.timestamp, 
    //     "The first claimer address is not valid right now!");
    //     return information[msg.sender].noOfClaimers;
    // }
}