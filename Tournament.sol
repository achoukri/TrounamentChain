// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TournamentChain {
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
        address[] teams;
        bool winnerPaid; // added variable to keep track of whether the winner has been paid or not
        bool organizerPaid; // added variable to keep track of whether the organizer has been paid or not
    }

    // in the case of teams matchs, the backend will put the address of team responsible

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
        bool isCanceled;
    }

    address public owner;
    // Mappings
    mapping(uint256 => Tournament) public tournaments;
    mapping(address => bool) public organizers;
    mapping(uint256 => Match[]) public matchesByTournamentId;
    // this mapping will help us to find easily a match. if we don't use a mapping we will need to use For to find the match
    // using a matchId or a TrournamentId to find matchs is a more efficient approach
    mapping(uint256 => Match) public matchesByMatchId;

    // Events

    // we use indexed because it allows the Ethereum node to perform a more efficient
    // filtering and search on the blockchain for events that match the indexed parameter value.
    event TournamentCreated(
        uint256 indexed tournamentId,
        address indexed organizer
    );
    event MatchAdded(
        uint256 indexed tournamentId,
        address indexed player1, // or team1 in the case of teams
        address indexed player2 // or team2 in the case of teams
    );

    event OrganizerAdded(address indexed organizer);

    event MatchUpdated(
        uint256 indexed matchId,
        uint256 indexed tournamentId,
        uint256 player1Score, // or team1Score in the case of teams
        uint256 player2Score, // or team2Score in the case of teams
        uint256 winner,
        bool isFinished
    );
    event LogMessage(uint256 message);

    event MatchCanceled(uint256 _matchId);

    event FeesPaid(
        address indexed payer,
        uint256 amount,
        address indexed feesAddress
    );

    event OrganizerPaid(
        uint256 indexed tournamentId,
        address organizer,
        uint256 amount
    );

    event PrizePaid(
        uint256 indexed _tournamentId,
        address indexed _winner,
        uint256 _prizeAmount
    );

    event TournamentDetailsDisplayed(
    uint256 tournamentId,
    uint256 startDateTime,
    uint256 endDateTime,
    uint256 entryFee,
    uint256 prizeAmount,
    address winner,
    address organizer,
    address[] players,
    address[] teams,
    bool winnerPaid,
    bool organizerPaid
    );


    // Modifiers

    modifier onlyOrganizer() {
        require(
            organizers[msg.sender],
            "Only organizers can perform this action"
        );
        _;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function."
        );
        _;
    }

    modifier tournamentExists(uint256 _tournamentId) {
        require(
            tournaments[_tournamentId].tournamentId != 0,
            "Tournament does not exist"
        );
        _;
    }


    modifier matchDateInFuture(uint256 _matchDate) {
        require(
            _matchDate > block.timestamp,
            "Match date must be in the future"
        );
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
    function createTournament(
        uint256 _startDateTime,
        uint256 _endDateTime,
        uint256 _entryFee,
        uint256 _prizeAmount,
        address[] memory _players,
        address[] memory _teams
    ) public onlyOrganizer {
        // Generate tournament ID
        uint256 tournamentId = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender))
        );

        // we use memeory to indecate that some variables/arrays are just held in memory for the duration of the function call (to reduce gaz fees).
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
            teams: _teams,
            winnerPaid: false,
            organizerPaid: false
        });
        tournaments[tournamentId] = newTournament;

        // Emit event
        emit TournamentCreated(tournamentId, msg.sender);
    }

    function addMatch(
        uint256 _matchId,
        uint256 _tournamentId,
        address _player1,
        address _player2,
        uint256 _matchDate
    )
        public
        onlyOrganizer
        tournamentExists(_tournamentId)
        matchDateInFuture(_matchDate)
    {
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
            isFinished: false,
            isCanceled: false
        });

        // Add match to tournament and mapping
        matchesByTournamentId[_tournamentId].push(newMatch);
        matchesByMatchId[_matchId] = newMatch;

        // Emit event
        emit MatchAdded(_tournamentId, _player1, _player2);
    }

    function updateMatch(
        uint256 _matchId,
        uint256 _tournamentId,
        uint256 _player1Score,
        uint256 _player2Score,
        uint256 _winner,
        bool _isFinished
    ) public onlyOrganizer tournamentExists(_tournamentId) {
        // Find the match using the mapping
        Match storage matchToUpdate = matchesByMatchId[_matchId];

        // Verify that the match belongs to the specified tournament
        require(
            matchToUpdate.tournamentId == _tournamentId,
            "Match does not belong to this tournament"
        );

        // Update the match information
        matchToUpdate.player1Score = _player1Score;
        matchToUpdate.player2Score = _player2Score;
        matchToUpdate.winner = _winner;
        matchToUpdate.isFinished = _isFinished;

        // Emit event
        emit MatchUpdated(
            _matchId,
            _tournamentId,
            _player1Score,
            _player2Score,
            _winner,
            _isFinished
        );
    }

    function displayTournamentDetails(uint256 _tournamentId) public tournamentExists(_tournamentId) {
    Tournament storage tournament = tournaments[_tournamentId];
    emit TournamentDetailsDisplayed(
        tournament.tournamentId,
        tournament.startDateTime,
        tournament.endDateTime,
        tournament.entryFee,
        tournament.prizeAmount,
        tournament.winner,
        tournament.organizer,
        tournament.players,
        tournament.teams,
        tournament.winnerPaid,
        tournament.organizerPaid
    );
    }

    // Function to update if a match is canceled
    function cancelMatch(uint256 _matchId) public {
        Match storage matchToUpdate = matchesByMatchId[_matchId];
        require(matchToUpdate.matchId == _matchId, "Match does not exist");
        require(!matchToUpdate.isCanceled, "Match has been canceled");

        matchToUpdate.isCanceled = true;
        emit MatchCanceled(_matchId);
    }

    /**
     * @dev Updates the prize amount of an existing tournament. Only the organizer can update the prize.
     * @param _tournamentId The ID of the tournament to update
     * @param _prizeAmount The new prize amount for the tournament in wei
     */
    function updatePrize(
        uint256 _tournamentId,
        uint256 _prizeAmount
    )
        public
        onlyOrganizer
        tournamentExists(_tournamentId)
    {
        tournaments[_tournamentId].prizeAmount = _prizeAmount;
    }

    /**
     * @dev Sets the winner of an existing tournament. Only the organizer can set the winner.
     * @param _tournamentId The ID of the tournament to update
     * @param _winner The address of the winner of the tournament
     */
    function setWinner(
        uint256 _tournamentId,
        address payable _winner
    )
        public
        onlyOrganizer
        tournamentExists(_tournamentId)
    {
        tournaments[_tournamentId].winner = _winner;
    }

    function payWinner(uint256 _tournamentId) public payable {
        // we use the call directly to the value of winner and prizeAmount, because by declaring variables fees will be expansive

        require(
            tournaments[_tournamentId].winner != address(0),
            "Invalid address"
        );
        require(
            address(this).balance >= tournaments[_tournamentId].prizeAmount,
            "Insufficient balance"
        );
        require(
            tournaments[_tournamentId].winnerPaid != true,
            "Winner is paid"
        );
        require(
            msg.value == tournaments[_tournamentId].prizeAmount,
            "Inccorrect transfer amount"
        );

        tournaments[_tournamentId].winner.transfer(
            tournaments[_tournamentId].prizeAmount
        );
        tournaments[_tournamentId].winnerPaid = true;

        emit PrizePaid(
            _tournamentId,
            tournaments[_tournamentId].winner,
            tournaments[_tournamentId].prizeAmount
        );
    }

    function payOrganizer(uint256 _tournamentId) public payable {
        // we use the call directly to the value of winner and prizeAmount, because by declaring variables fees will be expansive
        require(
            tournaments[_tournamentId].organizer != address(0),
            "Invalid address"
        );
        require(
            address(this).balance >= tournaments[_tournamentId].prizeAmount,
            "Insufficient balance"
        );

        tournaments[_tournamentId].organizer.transfer(
            tournaments[_tournamentId].prizeAmount
        );
        tournaments[_tournamentId].organizerPaid = true;
        emit OrganizerPaid(
            _tournamentId,
            tournaments[_tournamentId].organizer,
            tournaments[_tournamentId].prizeAmount
        );
    }

    /**
     * PayFees is designed to be a generic function and is not specific to paying the tournament organizer.
     * We want to handle business cases through the backend, and therefore leave it to the backend to decide which address to send fees.
     * Normally, only the owner of the smart contract (the smart contract deployer) can use this function.
     * This function can also be used to pay other fees in the case of a new business case.
     */
    function payFees(
        uint256 _tournamentId,
        address payable _feesAddress
    ) public payable {
        Tournament storage tournament = tournaments[_tournamentId];
        require(msg.value == tournament.entryFee, "Fee amount is not correct");

        // Transfer fees to the specified address
        _feesAddress.transfer(msg.value);

        emit FeesPaid(msg.sender, msg.value, _feesAddress);
    }

    //The addOrganizer function adds a new organizer to the list of registered organizers.
    function addOrganizer(address organizer) public onlyOwner {
        organizers[organizer] = true;
        emit OrganizerAdded(organizer);
    }

    //The addPlayer function adds a new player to the list of players for a given tournament.
    function addPlayer(
        uint256 tournamentId,
        address player
    ) public onlyOwner tournamentExists(tournamentId) {
        tournaments[tournamentId].players.push(player);
        // emit PlayerAdded(tournamentId, player);
    }

    //The addTeam function adds a new team to the list of teams for a given tournament.
    function addTeam(
        uint256 tournamentId,
        address team
    ) public onlyOwner tournamentExists(tournamentId) {
        tournaments[tournamentId].teams.push(team);
        // emit TeamAdded(tournamentId, team);
    }
}
