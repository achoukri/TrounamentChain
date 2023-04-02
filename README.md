# TrounamentChain

----------------------------------------
|              <<User>>               |
|--------------------------------------|
| -firstName: string                   |
| -lastName: string                    |
| -email: string                       |
| -address: string                     |
| -username: string                    |
| -password: string                    |
| +login()                             |
| +logout()                            |
| +updateProfile()                     |
|                                      |
|--------------------------------------|
        /           |            \
       /            |             \
      /             |              \
 --------------------------------------------
|             <<Organizer>>                |
|-------------------------------------------|
| -organizerID: uint256                    |
| +createTournament()                      |
| +scheduleMatches()                       |
| +payoutPrizes()                          |
| +withdrawFees()                          |
| +disputeResolution()                     |
|-------------------------------------------|
            |
            |
 ----------------------------------------
|               <<Player>>             |
|--------------------------------------|
| -playerID: uint256                   |
| -score: uint256                      |
| -registeredTournaments: uint256[]    |
| +registerForTournament()             |
| +submitScore()                       |
| +getScore()                          |
|--------------------------------------|
             |
             |
 ----------------------------------------
|                <<Team>>              |
|--------------------------------------|
| -teamID: uint256                     |
| -teamName: string                    |
| -teamResponsible: <<User>>           |
| -players: <<Player>>[]               |
| +addPlayer()                         |
| +removePlayer()                      |
| +updateTeamName()                    |
|--------------------------------------|
