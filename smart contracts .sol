// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EducationDAO {
    struct Proposal {
        uint256 id;
        string title;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 deadline;
        address proposer;
        bool executed;
    }

    address public owner;
    uint256 public proposalCount;
    uint256 public votingPeriod = 7 days;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public members;
    mapping(address => mapping(uint256 => bool)) public voted;

    event MemberAdded(address member);
    event ProposalCreated(uint256 id, string title, address proposer);
    event Voted(uint256 proposalId, address voter, bool vote);
    event ProposalExecuted(uint256 proposalId, bool approved);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyMember() {
        require(members[msg.sender], "Only DAO members can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addMember(address _member) external onlyOwner {
        members[_member] = true;
        emit MemberAdded(_member);
    }

    function createProposal(string calldata _title, string calldata _description) external onlyMember {
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            title: _title,
            description: _description,
            votesFor: 0,
            votesAgainst: 0,
            deadline: block.timestamp + votingPeriod,
            proposer: msg.sender,
            executed: false
        });

        emit ProposalCreated(proposalCount, _title, msg.sender);
        proposalCount++;
    }

    function vote(uint256 _proposalId, bool _vote) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp <= proposal.deadline, "Voting period has ended");
        require(!voted[msg.sender][_proposalId], "Already voted");

        voted[msg.sender][_proposalId] = true;

        if (_vote) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit Voted(_proposalId, msg.sender, _vote);
    }

    function executeProposal(uint256 _proposalId) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.deadline, "Voting period is not over");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;

        bool approved = proposal.votesFor > proposal.votesAgainst;
        emit ProposalExecuted(_proposalId, approved);
    }
}