#README
##Introduction
This is a smart contract written in Solidity that implements a sport tournament. The contract allows organizers to create tournaments with specified start and end dates, entry fees, and prize amounts, and players can join these tournaments. The contract also allows organizers to add matches between players and update the prize amount of an existing tournament. Additionally, the contract provides functionality for setting the winner of a tournament.

##Requirements
Solidity version ^0.8.0
Getting Started
Compile the SportTournament smart contract using a Solidity compiler.
Deploy the compiled smart contract to a blockchain of your choice.
Interact with the smart contract using a web3 provider, such as Web3.js.
##Functionality
Create Tournament
This function creates a new tournament with the given start and end dates, entry fee, prize amount, and list of players. Only the organizer can create a tournament.

###Parameters

'_startDateTime: The start date and time of the tournament as a Unix timestamp.
'_endDateTime: The end date and time of the tournament as a Unix timestamp.
'_entryFee: The entry fee for the tournament in wei.
'_prizeAmount: The total prize amount for the tournament in wei.
'_players: The list of players who have joined the tournament.

function createTournament(uint256 _startDateTime, uint256 _endDateTime, uint256 _entryFee, uint256 _prizeAmount, address[] memory _players) public onlyOrganizer

```function createTournament(uint256 _startDateTime, uint256 _endDateTime, uint256 _entryFee, uint256 _prizeAmount, address[] memory _players) public onlyOrganizer
```
##Add Match
This function adds a match between two players to a tournament. Only the organizer can add a match.

###Parameters
_matchId: The ID of the match.
_tournamentId: The ID of the tournament.
_player1: The address of the first player.
_player2: The address of the second player.
_matchDate: The date and time of the match as a Unix timestam

```
function addMatch(uint256 _matchId, uint256 _tournamentId, address _player1, address _player2, uint256 _matchDate) public onlyOrganizer tournamentExists(_tournamentId) matchDateInFuture(_matchDate)```
