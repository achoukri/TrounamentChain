// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract SportTournament {

    // Structs
    struct Tournament {
        uint256 tournamentId;
        uint256 startDateTime;
        uint256 endDateTime;
        uint256 entryFee;
        uint256 prizeAmount;
        address payable winner;
        address payable organizer;
        address[] players;
        bool winnerPaid; // added variable to keep track of whether the winner has been paid or not
        bool organizerPaid; // added variable to keep track of whether the organizer has been paid or not
    }

    struct Match {
        address player1; // or team1;
        address player2; // or team2;
        uint256 matchDate;
        uint256 tournamentId;
        uint256 matchId;
        uint256 player1Score;
        uint256 player2Score;
        uint256 winner;
        bool isFinished;
    }

    address public owner;
    // Mappings
    mapping(uint256 => Tournament) public tournaments;
    mapping(address => bool) public organizers;
    mapping(uint256 => Match[]) public matchesByTournamentId;

    // Events
    event TournamentCreated(uint256 indexed tournamentId, address indexed organizer);
    event MatchAdded(uint256 indexed tournamentId, address indexed player1, address indexed player2);
    event LogMessage(uint256 message);

    // Modifiers

    modifier onlyOrganizer() {
        require(organizers[msg.sender], "Only organizers can perform this action");
        _;
    }
    
    modifier onlyOwner() {
    require(msg.sender == owner, "Only the contract owner can call this function.");
    _;
    }

    modifier tournamentExists(uint256 _tournamentId) {
        require(tournaments[_tournamentId].tournamentId != 0, "Tournament does not exist");
        _;
    }

    modifier tournamentNotStarted(uint256 _tournamentId) {
        emit LogMessage(block.timestamp);
        require(tournaments[_tournamentId].startDateTime > block.timestamp, "Tournament has already started");
        _;
    }

    modifier matchDateInFuture(uint256 _matchDate) {
        require(_matchDate > block.timestamp, "Match date must be in the future");
        _;
    }

      constructor() {
        owner = msg.sender;
        organizers[owner] = true;
    }



    // Functions:

    /**
    * @dev Creates a new tournament with the given start and end dates, entry fee, prize amount,
    * and list of players. Only the organizer can create a tournament.
    * @param _startDateTime The start date and time of the tournament as a Unix timestamp
    * @param _endDateTime The end date and time of the tournament as a Unix timestamp
    * @param _entryFee The entry fee for the tournament in wei
    * @param _prizeAmount The total prize amount for the tournament in wei
    * @param _players The list of players who have joined the tournament
    */
    function createTournament(uint256 _startDateTime, uint256 _endDateTime, uint256 _entryFee, uint256 _prizeAmount, address[] memory _players) public onlyOrganizer {
        // Generate tournament ID
        uint256 tournamentId = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));

        // Create tournament
        Tournament memory newTournament = Tournament({
            tournamentId: tournamentId,
            startDateTime: _startDateTime,
            endDateTime: _endDateTime,
            entryFee: _entryFee,
            prizeAmount: _prizeAmount,
            winner: payable(address(0)),
            organizer: payable(msg.sender),
            players: _players,
            winnerPaid: false,
            organizerPaid: false
        });
        tournaments[tournamentId] = newTournament;

        // Emit event
        emit TournamentCreated(tournamentId, msg.sender);
    }


    function addMatch(uint256 _matchId, uint256 _tournamentId, address _player1, address _player2, uint256 _matchDate) public onlyOrganizer tournamentExists(_tournamentId) matchDateInFuture(_matchDate) {
        // Create match
        Match memory newMatch = Match({
            player1: _player1,
            player2: _player2,
            matchDate: _matchDate,
            tournamentId: _tournamentId,
            matchId: _matchId,
            player1Score: 0,
            player2Score: 0,
            winner: 0,
            isFinished: false
        });

        // Add match to tournament
        matchesByTournamentId[_tournamentId].push(newMatch);

        // Emit event
        emit MatchAdded(_tournamentId, _player1, _player2);
    }

    //TODO: 
    // 1. modify a match result
    // 2. add new attribute match canceled
    //

        /**
    * @dev Updates the prize amount of an existing tournament. Only the organizer can update the prize.
    * @param _tournamentId The ID of the tournament to update
    * @param _prizeAmount The new prize amount for the tournament in wei
    */
    function updatePrize(uint256 _tournamentId, uint256 _prizeAmount) public onlyOrganizer tournamentExists(_tournamentId) tournamentNotStarted(_tournamentId) {
        tournaments[_tournamentId].prizeAmount = _prizeAmount;
    }

        /**
    * @dev Sets the winner of an existing tournament. Only the organizer can set the winner.
    * @param _tournamentId The ID of the tournament to update
    * @param _winner The address of the winner of the tournament
    */
    function setWinner(uint256 _tournamentId, address payable _winner) public onlyOrganizer tournamentExists(_tournamentId) tournamentNotStarted(_tournamentId) {
        tournaments[_tournamentId].winner = _winner;
    }

    function payWinner(uint256 _tournamentId) public payable  {
        // we use the call directly to the value of winner and prizeAmount, because by declaring variables fees will be expansive
    require(tournaments[_tournamentId].winner != address(0), "Invalid address");
    require(address(this).balance >= tournaments[_tournamentId].prizeAmount, "Insufficient balance");

    tournaments[_tournamentId].winner.transfer(tournaments[_tournamentId].prizeAmount);
    tournaments[_tournamentId].winnerPaid = true;
    //emit PrizePaid(tournaments[_tournamentId].winner, tournaments[_tournamentId].prizeAmount);
    }


    function payOrganizer(uint256 _tournamentId) public payable  {
        // we use the call directly to the value of winner and prizeAmount, because by declaring variables fees will be expansive
    require(tournaments[_tournamentId].organizer != address(0), "Invalid address");
    require(address(this).balance >= tournaments[_tournamentId].prizeAmount, "Insufficient balance");
 
    tournaments[_tournamentId].organizer.transfer(tournaments[_tournamentId].prizeAmount);
    tournaments[_tournamentId].organizerPaid = true;
    //emit OrganizerPaid(organizer, organizerFee);
    }



}
