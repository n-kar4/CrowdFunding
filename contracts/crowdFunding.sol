// SPDX-License-Identifier:GPL-3.0

pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding{
    mapping(address => uint) public contributors;
    address  maneger;
    uint public minCont;
    uint public target;
    uint public deadline;
    uint public noOfContributors;
    uint public raisedAmount;
    
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>Request) public RequestsList;
    uint public numOfRequests;

    constructor(uint _target, uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline;
        minCont = 10 wei;
        maneger = msg.sender;
    }

    function sendEth() public payable{
        require(block.timestamp < deadline);
        require(msg.value >= minCont);
        if(contributors[msg.sender] == 0){
            noOfContributors++;
        }
        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }
    // function getBal() public view returns(uint){
    //     return address(this).balance;
    // }
    function refund() public{
        require(block.timestamp < deadline && raisedAmount < target);
        require(contributors[msg.sender] > 0);

        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;
    }
    modifier onlyManeger(){
        require(msg.sender==maneger, "not the maneger");
        _;
    }
    function makeRequest(string memory _description, address payable _recipient, uint _value) public onlyManeger{
        Request storage newReq = RequestsList[numOfRequests];
        numOfRequests++;
        newReq.description = _description;
        newReq.recipient = _recipient;
        newReq.value = _value;
        newReq.completed = false;
        newReq.noOfVoters = 0;
    }
    function voteRequest(uint _ReqNo) public {
        require(contributors[msg.sender] > 0);
        Request storage newVote = RequestsList[_ReqNo];
        require(newVote.voters[msg.sender] == false, "you have already voted");
        newVote.noOfVoters++;
        newVote.voters[msg.sender] = true;
    }
    function makePayment(uint _ReqNo) public {
        require(msg.sender == maneger);
        Request storage temp = RequestsList[_ReqNo];
        require(temp.completed == false);
        require(temp.noOfVoters > noOfContributors/2);
        temp.recipient.transfer(temp.value);
        temp.completed = true;
    }
}