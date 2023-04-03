// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// import "hardhat/console.sol";

contract Paypal {

    // Define the owner of the smart contract
    address public owner;

    constructor () {
        owner = msg.sender;
    }


    // Create Struct & Mapping for request, transaction & name
    // - Structs show what consist inside the transaction i.e. address of requestor, name of requestor, amount requested & message
    // - Mappings allow you to see from which address the Struct is from - map addresses to structs
    struct request {
        address requestor;
        uint amount;
        string message;
        string name;
    }

    struct sendReceive {
        string action;
        uint256 amount;
        string message;
        address otherPartyAddress;
        string otherPartyName;
    }

    struct userName {
        string name;
        bool hasName;
    }

    mapping(address => userName) names; // map address to userName struct, name of mapping: names
    mapping(address => request[]) requests; // request[] so when calling requests[address] an array of request structs will be returned
    mapping(address => sendReceive[]) history; // sendReceive[] so when calling history[address] an array of sendReceive structs will be returned


    // Add name to wallet address i.e. give wallet a name
    function addName(string memory _name) public {

        // Create "userName" struct and "storage" to store data inside this contract
        // Create temporary name "newUserName" which is used to update storage values of struct
        // note that address mapping is set by names[msg.sender]
        userName storage newUserName = names[msg.sender];
        newUserName.name = _name;
        newUserName.hasName = true;

    }


    // Create a request
    function createRequest(address user, uint256 _amount, string memory _message) public {

        // Create request struct, temporarily store in memory
        request memory newRequest;
        newRequest.requestor = msg.sender;
        newRequest.amount = _amount;
        newRequest.message = _message;
        if (names[msg.sender].hasName) {
            newRequest.name = names[msg.sender].name;
        }

        requests[user].push(newRequest); // this pushes the newRequest struct INTO the requests[] array of user

    }


    // Pay the request
    // _request is an int becuase its targetting the request inside requests[] array
    function payRequest(uint256 _request) public payable {

        require(_request < requests[msg.sender].length, "No such request");
        request[] storage myRequests = requests[msg.sender]; // Temp var's: request[], myRequests to get requests array of msg.sender
        request storage payableRequest = myRequests[_request]; // Target the specific request thats passed into this function

        uint256 toPay = payableRequest.amount *  1000000000000000000; // Convert to wei, 18 decimals
        require(msg.value == (toPay), "Pay correct amount"); // Checks to see if number of wei sent with the message matches "toPay"

        payable(payableRequest.requestor).transfer(msg.value); // Takes requestor and transfers msg.value to the requestor

        addHistory(msg.sender, payableRequest.requestor, payableRequest.amount, payableRequest.message);

        myRequests[_request] = myRequests[myRequests.length - 1]; // Swap last request in myRequests & swap with current _request we just paid
        myRequests.pop(); // Now we remove the last request (one we just paid) from the myRequests array

    }

    function addHistory(address sender, address receiver, uint256 _amount, string memory _message) private {

        sendReceive memory newSend;
        newSend.action = "-";
        newSend.amount = _amount;
        newSend.message = _message;
        newSend.otherPartyAddress = receiver;
        if (names[receiver].hasName = true) {
            newSend.otherPartyName = names[receiver].name;
        }
        history[sender].push(newSend);

        sendReceive memory newReceive;
        newReceive.action = "+";
        newReceive.amount = _amount;
        newReceive.message = _message;
        newReceive.otherPartyAddress = sender;
        if (names[sender].hasName = true) {
            newReceive.otherPartyName = names[sender].name;
        }
        history[receiver].push(newReceive);
    }


    // Get all requests sent to a User
    function getMyRequests(address _user) public view returns (address[] memory, uint256[] memory, string[] memory, string[] memory) {

        address[] memory addrs = new address[](requests[_user].length);
        uint256[] memory amnt = new uint256[](requests[_user].length);
        string[] memory msge = new string[](requests[_user].length);
        string[] memory nme = new string[](requests[_user].length);

        for (uint i=0; i < requests[_user].length; i++) {
            request storage myRequests = requests[_user][i];
            addrs[i] = myRequests.requestor;
            amnt[i] = myRequests.amount;
            msge[i] = myRequests.message;
            nme[i] = myRequests.name;
        }

        return (addrs, amnt, msge, nme);
    }
    

    // Get all historic transactions a user has been a part of
    function getMyHistory(address _user) public view returns(sendReceive[] memory) {
        return history[_user];
    }

    function getMyName(address _user) public view returns(userName memory) {
        return names[_user];
    }

}

