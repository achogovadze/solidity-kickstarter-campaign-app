pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] deployedCampaigns;

    function CampaignFactory() public {}

    function createCampaign(uint256 min) public {
        address newCamp = new Campaign(min, msg.sender);
        deployedCampaigns.push(newCamp);
    }

    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint256 value;
        address recipient;
        bool complete;
        mapping(address => bool) approvals;
        uint256 approvalCount;
    }

    address public manager;
    uint256 public minimumContribution;
    mapping(address => bool) public approvers;
    uint256 public approversCount;
    Request[] public requests;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function Campaign(uint256 min, address _manager) public {
        manager = _manager;
        minimumContribution = min;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);
        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(
        string description,
        uint256 value,
        address recipient
    ) public restricted {
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });

        requests.push(newRequest);
    }

    function approveRequest(uint256 idx) public {
        Request storage request = requests[idx];

        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint256 idx) public restricted {
        Request storage request = requests[idx];

        require(request.approvalCount > approversCount / 2);
        require(!request.complete);

        request.recipient.transfer(request.value);
        request.complete = true;
    }
}
