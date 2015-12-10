$(document).ready(function() {
  var cells = document.getElementsByClassName("opponent-cell");
  var coordinate = document.getElementById("coordinate");

  //Retrieve the title of the last clicked oppenent cell, then update the coordinate element with it's value. This value is used in the attack function
  var getCellCoord = function() {
    var attribute = this.getAttribute("title");
    coordinate.innerHTML = attribute;
    coordinate.dataset.coordinate = this.getAttribute("id");

  };

  //Add an on click event listener to each oppenent cell
  for(var i=0;i<cells.length;i++){
    cells[i].addEventListener('click', getCellCoord, false);
  }

  //When the attack button is clicked, retrieve the current player, gameId, and attack coordinate then pass it to the attack action
  $("#attack_btn").on("click", function() {
      var gameId = $("#game_id").val();
      var player = $("#player").val();
      var coord = $("#coordinate").text().toLowerCase();
      var url = "/game/attack/" + gameId + "/" + player + "/" + coord;
      $.ajax(url);
  });
  
  //update the page data when the document is ready
  update_data();
});

//convert a row id to a character
function row_to_char(row) {
  var str = "ABCDEFGHIJ";
  return str.charAt(row - 97);
}

//update the display data based on the current game state
function update_data() {
  var gameId = $("#game_id").val();
  var player = $("#player").val();
  var url = "/game/get_data/" + gameId + "/" + player;
  //calls the get_data action to retrieve the current game state in json format
  $.ajax(url, {
    success: function(data, code, xhr) {

      console.log(data);

      //Update the turn label
      var turnText;
      if (data.turn === player)
        turnText = "It is your turn";
      else
        turnText = "It is your opponent's turn";
      $(".player_turn").find("b").text(turnText);

      // Check if there is a winner, if there is, then hide the game boards and show a div displaying the winner and a link to the home page
      if (data.winner !== "no_one"){
          console.log("Winner found");
          winner = data.winner;
          $("#winnerDiv").removeClass("hidden").addClass("gameKey");
          $("#gameBoards").removeClass("container").addClass("hidden");
          $("#winner").text("The Winner is: " + winner);
      }
      
      //parse the player's board and update the css classes of there cells to show where their ships are placed and which ships have been hit
      for (var i = 0; i < data.board.length; i++) {
        ship = data.board[i];
        for (var j = 0; j < ship.coord_list.length; j++) {
          var coord_rec = ship.coord_list[j];
          var cellId = row_to_char(coord_rec.coord.row) + coord_rec.coord.column;
          if (coord_rec.hit_status === "hit")
            $("#player-board").find("#"+cellId).removeClass("ship").addClass("hit");
          else if (coord_rec.hit_status === "none")
            $("#player-board").find("#"+cellId).removeClass("hit").addClass("ship");
        }
      }

      //parse throught the player's console (opponent view) and see where they have hit the opponents ships and where they have missed the opponents ships
      for (var i = 0; i < data.console.length; i++) {
          coord_rec = data.console[i];
          var cellId = row_to_char(coord_rec.coord.row) + coord_rec.coord.column;
          if (coord_rec.hit_status === "hit")
            $("#opponent-board").find("#"+cellId).addClass("hit");
          else if (coord_rec.hit_status === "miss")
            $("#opponent-board").find("#"+cellId).addClass("miss");
      }

    }});
}
