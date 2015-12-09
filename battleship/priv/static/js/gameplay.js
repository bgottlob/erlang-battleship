$(document).ready(function() {
  var cells = document.getElementsByClassName("opponent-cell");
  var coordinate = document.getElementById("coordinate");

  var myFunction = function() {
  var attribute = this.getAttribute("title");
    coordinate.innerHTML = attribute;
    coordinate.dataset.coordinate = this.getAttribute("id");

  };

  for(var i=0;i<cells.length;i++){
    cells[i].addEventListener('click', myFunction, false);
  }

  $("#attack_btn").on("click", function() {
      var gameId = $("#game_id").val();
      var player = $("#player").val();
      var coord = $("#coordinate").text().toLowerCase();
      var url = "/game/attack/" + gameId + "/" + player + "/" + coord;
      $.ajax(url);
  });

  update_data();
});

function row_to_char(row) {
  var str = "ABCDEFGHIJ";
  return str.charAt(row - 97);
}

function update_data() {
  var gameId = $("#game_id").val();
  var player = $("#player").val();
  var url = "/game/get_data/" + gameId + "/" + player;
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

      //TODO:Check for the winner

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
