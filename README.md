# erlang-battleship
## By: Brandon Gottlob, Chris Hranj, Matt Judy, Sean Clark, and Tyler Povanda

### How to Play:
Navigate to our server hosted by AWS:
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
