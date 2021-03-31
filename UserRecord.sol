pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import 'lib/SafeMath.sol';

contract UserRecord{
    using SafeMath for uint256;
    uint256 constant MAX_USERS = 100;
    struct Hoster{
        uint256 hoster_start_timestamp;
        uint256 hoster_end_timestamp;
        uint32 IP_addr;
        uint16 port;
    }
    struct Claimer{
        address addr;
        bool valid;
        uint256 balance;
        uint256 ek;
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
        uint128 register_deadline,
        uint128 hoster_start_timestamp,
        uint128 hoster_end_timestamp,
        uint32 hoster_IP_addr,
        uint16 port
    ) public payable {
        require(information[msg.sender].hoster.hoster_end_timestamp < block.timestamp, 
        "One user must host only one transfer shuffling service until expiration.");
        require(register_deadline < hoster_start_timestamp, 
        "The register deadline must be ahead of hoster server staring timestamp");
        information[msg.sender].amount=msg.value;
        information[msg.sender].register_deadline=register_deadline;
        information[msg.sender].isTxDone=false;
        information[msg.sender].hoster.hoster_start_timestamp=hoster_start_timestamp;
        information[msg.sender].hoster.hoster_end_timestamp=hoster_end_timestamp;
        information[msg.sender].hoster.IP_addr=hoster_IP_addr;
        information[msg.sender].hoster.port=port;
        information[msg.sender].noOfClaimers = 1;
        uint256 noOfClaimers = information[msg.sender].noOfClaimers;
        information[msg.sender].claimers[noOfClaimers-1].addr = msg.sender;
        information[msg.sender].claimers[noOfClaimers-1].valid = true;
        information[msg.sender].claimers[noOfClaimers-1].balance = msg.value;
    }

    function followRegister(
        address firstClaimer
    ) public payable {
        require(information[firstClaimer].hoster.hoster_end_timestamp > block.timestamp, 
        "The first claimer address is not valid right now!");
        require(information[firstClaimer].register_deadline > block.timestamp,
        "Register deadline has passed right now!");
        require(information[firstClaimer].amount == msg.value,
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
        information[firstClaimer].claimers[noOfClaimers-1].balance = msg.value;
    }
    function withdraw(
        address firstClaimer,
        uint128 i,
        uint256 amount
    )public payable{
        require(information[firstClaimer].claimers[i].addr == msg.sender, "Index is wrong");
        require(information[firstClaimer].claimers[i].balance >= amount,"balance is not enough");
        information[firstClaimer].claimers[i].balance = information[firstClaimer].claimers[i].balance.sub(amount);
        msg.sender.transfer(amount);
    }
    function updateEk(
        address firstClaimer,
        uint128 i,
        uint256 ek
    )public {
        require(information[firstClaimer].claimers[i].addr == msg.sender, "Index is wrong");
        information[firstClaimer].claimers[i].ek = ek;
    }
    function lookUpNoOfClaimers(address firstClaimer) public view returns (uint256){
        require(information[firstClaimer].hoster.hoster_end_timestamp > block.timestamp, 
        "The first claimer address is not valid right now!");
        return information[firstClaimer].noOfClaimers;
    }
    function lookUpBalance(address firstClaimer, uint128 i) public view returns (uint256){
        require(information[firstClaimer].hoster.hoster_end_timestamp > block.timestamp, 
        "The first claimer address is not valid right now!");
        return information[firstClaimer].claimers[i].balance;
    }
    function lookUpBalanceByAddr(address firstClaimer, address addr) public view returns (uint256){
        require(information[firstClaimer].hoster.hoster_end_timestamp > block.timestamp, 
        "The first claimer address is not valid right now!");
        for(uint128 i = 0; i < information[firstClaimer].noOfClaimers; i++) {         
            if(information[firstClaimer].claimers[i].addr == addr){
                return information[firstClaimer].claimers[i].balance;
            }
        }
        require(false, "The address provided is invalid!");
        return 0;
    }
    function lookUpEkByAddr(address firstClaimer, address addr) public view returns (uint256){
        require(information[firstClaimer].hoster.hoster_end_timestamp > block.timestamp, 
        "The first claimer address is not valid right now!");
        for(uint128 i = 0; i < information[firstClaimer].noOfClaimers; i++) {         
            if(information[firstClaimer].claimers[i].addr == addr){
                return information[firstClaimer].claimers[i].ek;
            }
        }
        require(false, "The address provided is invalid!");
        return 0;
    }
}