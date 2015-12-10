# erlang-battleship
## By: Brandon Gottlob, Chris Hranj, Matt Judy, Sean Clark, and Tyler Povanda

### How to Build the Project and Run
- Ensure that the latest build of Erlang is installed
- Install Chicago Boss
`git clone https://github.com/ChicagoBoss/ChicagoBoss.git`
`cd ChicagoBoss`
`make`
- Create a new Chicago Boss called "battleship"
`make app PROJECT=battleship`
- Clone or download our repo (our repo does not contain all of the auto-generated Chicago Boss files, only the ones we edited)
- Within the `battleship` directory of our repo, you will find the files that we have edited
 - Move these files into their respective places in the auto-generated battleship project that was created with `make app PROJECT=battleship` (our directory structure matches that of the auto-generated Chicago Boss project) - overwrite any files of the same name with the file from our repo
- Navigate to the `battleship` directory that Chicago Boss created for you (not in our repo) and then run `./init-dev.sh`
- Go to a web browser and go to the url: `http://localhost:8001/game/list`
 - Now you should be able to play the game!

### The Easy Way to Run It
- Download [this zip file](https://s3.amazonaws.com/proglang/battleship.zip)
- Unzip the zip file
- Navigate to the battleship directory via the command line then run `./init-dev.sh`
- Go to a web browser and go to the url: `http://localhost:8001/game/list`
 - Now you should be able to play the game!

### How to Play:
On this page you can either create a new game or you can join an existing game.
If you create a new game you will be taken to our 'Create' page where you can create a new game by clicking the 'Create' button.
If you opt to join a new game, ensure that the game has already been created, then select the game id from the drop down (When
a game is created the game ID will be in the URL of the next page) and click join.

At this point, either of the above processes (Create or Join) will have taken you to the Setup page. You may now enter the coordinates
that you would like to place your ships. Coordinates are to be entered in the format a1,a2,a3... etc. Failure to do so will return an error message
prompting you to try entering your coordinates again.

Once you have entered valid coordinates, the Play view will appear. The view on the board on the left is your 'Console' (the area that your attacks are displayed)
and the area on the right is your board. The console will show the cells that you have attacked by either turning them red or blue.
A red cell denotes a hit and a blue cell denotes a miss. Your board will display the locations of your ships (in green) and ship cells
that have been hit (in red). The area below the boards will display which player's turn it is, the currently selected coordinate and
an 'Attack' button. It is impossible to send an attack when it is not your turn.

##### There is one caveat to the play view: Attacks do not check if both boards have been set so player 1 could accidentally attack before player 2 has set their board. As a result, it is best to ensure both players have created their boards before proceeding to attack

When it is your turn, you may click on any cell on the 'Console' or 'Opponent Board' in order to populate a div below the box displaying
which player's turn it is. The cell coordinate in that div is the coordinate that is submitted when 'Attack' is clicked. The player turn
box along with the cells on both boards will update in real time based on your actions and your opponent actions. This means that as soon as you
submit an attack it will display on your board, your opponents board and update the player turn in both views as well.

### How to Test:
In order to test if our game works, you can simply open the home page in two different browsers and play yourself. Just make sure the 2nd player joins the
correct game!

