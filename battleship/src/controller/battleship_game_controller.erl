-module(battleship_game_controller, [Req]).
-compile(export_all).

-record(game, {player1Board=[],
               player2Board=[],
               player1Console=[],
               player2Console=[],
               winner=no_one,
               turn=player1}).

-record(ship, {name,
               coord_list=[]}).

-record(coord, {row,
                column}).

-record(coord_rec, {hit_status=none,
                    coord}).

-import(game_logic,[place/4,attack_target/3]).

%Serves as our home screen, you can either go to the create screen or you can join an existing game
list('GET', []) ->
    Games = boss_db:find(game, []),
    Timestamp = boss_mq:now("new-games"),
    {ok, [{games, Games}, {timestamp, Timestamp}]}.

%Accepts a GameId, the player doing the attack and the coordinate they are attacking
attack('GET', [GameId, Player, Coord]) ->
    Curr = boss_db:find_first(game, [{id, 'equals', GameId}]),
    %Finds the game, parses the coordinate into a format that game_logic.erl will accept
    [AttackCoord|_] = Curr:parse(Coord),
    %push the attack to the news queue so that game sessions are alerted to it's presence and will update appropriately
    boss_mq:push("new-moves", AttackCoord), %%%% ADDED BY CHRIS
    Player = list_to_atom(PlayerStr),
    %Convert the current game into a record format that game_logic.erl will accept
    GameRec = #game{player1Board=Curr:player1_board(),
                    player2Board=Curr:player2_board(),
                    player1Console=Curr:player1_console(),
                    player2Console=Curr:player2_console(),
                    winner=Curr:winner(),
                    turn=Curr:turn()},
    %execute the attack in game_logic.erl
    {Status, NewRec} = game_logic:attack_target(AttackCoord, Player, GameRec),
    %checks if the attack was successful and responds appropriately
    case Status of
      did_not_attack ->
        {ok, [{error, "It's not your turn, your attack didn't go through"}]};
      _ ->
        NewGame = Curr:set([{player1_board, NewRec#game.player1Board},
                            {player2_board, NewRec#game.player2Board},
                            {player1_console, NewRec#game.player1Console},
                            {player2_console, NewRec#game.player2Console},
                            {winner, NewRec#game.winner},
                            {turn, NewRec#game.turn}]),
        boss_db:save_record(NewGame),
        {redirect, [{action, "play/" ++ GameId ++ "/" ++ PlayerStr}]}
    end.

create('GET', []) ->
  ok;
create('POST', []) ->
  %create a new game
  NewGame = game:new(id, [], [], [], [], no_one, player1),
  %saves the new game if it is valid and redirects to the setup screen, otherwise returns an error
  case NewGame:save() of
    {ok, SavedGame} ->
    {redirect, [{action, "setup"}, {game_id,SavedGame:id()}, {player, "player1"}]};
    {error, ErrorList} ->
    {ok, [{errors, ErrorList}, {new_msg, NewGame}]}
  end.

%routes the user to the setup page for the specified game as player 2
join('POST', []) ->
  GameId = Req:post_param("id"),
  {redirect, [{action, "setup"}, {game_id, GameId}, {player, "player2"}]}.

%navigate to the setup page, pass the page the gameId and the player number
setup('GET', [GameId, Player]) ->
  Game = boss_db:find(GameId),
  {ok, [{gameid, GameId}, {player, Player}]};
%post the form from the set up page
setup('POST', [GameId, PlayerStr]) ->
  %%GameId = Req:post_param("game_id"),
  PlayerStrr = Req:post_param("player"),
  Player = list_to_atom(PlayerStrr),
  
  %Retrieve the form data coords that were submitted
  AircraftPlacement = Req:post_param("carrier"),
  BattleshipPlacement = Req:post_param("battleship"),
  DestroyerPlacement = Req:post_param("destroyer"),
  SubmarinePlacement = Req:post_param("submarine"),
  PatrolPlacement = Req:post_param("patrol_boat"),

  %find the current game and create a record instance of it
  Curr = boss_db:find_first(game, [{id, 'equals', GameId}]),
  OrigRec = #game{player1Board=Curr:player1_board(),
                    player2Board=Curr:player2_board(),
                    player1Console=Curr:player1_console(),
                    player2Console=Curr:player2_console(),
                    winner=Curr:winner(),
                    turn=Curr:turn()},

  %Pass the coordinates into game_logic to check if they are valid placements
  {AircraftStatus, AircraftRec} = game_logic:place(carrier, Curr:parse(AircraftPlacement), Player, OrigRec),
  {BattleshipStatus, BattleshipRec} = game_logic:place(battleship, Curr:parse(BattleshipPlacement), Player, AircraftRec),
  {DestroyerStatus, DestroyerRec} = game_logic:place(destroyer, Curr:parse(DestroyerPlacement), Player, BattleshipRec),
  {SubmarineStatus, SubmarineRec} = game_logic:place(submarine, Curr:parse(SubmarinePlacement), Player, DestroyerRec),
  {PatrolStatus, PatrolRec} = game_logic:place(patrol_boat, Curr:parse(PatrolPlacement), Player, SubmarineRec),

  %create list of all the statuses from each placement
  StatusList = [AircraftStatus, BattleshipStatus, DestroyerStatus, SubmarineStatus, PatrolStatus],
  %If all of the ships were successfully placed, then save the game with the placed ships, redirect to play screen unless unsuccessful. If the user entered invalid coordinates, return error and ask them to place new valid coordinates
  case lists:all(fun(Status) -> Status =:= placed end, StatusList) of
      true ->
        NewGame = Curr:set([{player1_board, PatrolRec#game.player1Board},
                        {player2_board, PatrolRec#game.player2Board},
                        {player1_console, PatrolRec#game.player1Console},
                        {player2_console, PatrolRec#game.player2Console},
                        {winner, PatrolRec#game.winner},
                        {turn, PatrolRec#game.turn}]),
        boss_db:save_record(NewGame),
        {redirect, [{action, "play/" ++ GameId ++ "/" ++ PlayerStrr}]};
      false ->
        {redirect, [{action, "setup"}, {game_id, GameId}, {player, PlayerStrr}]}
        % {ok, [{error, "Invalid placement of ships, please try again"}]}
  end.

%Pass gameplay data into the view like the player turn, the player id, and a timestamp for moves
play('GET', [GameId,Player]) ->
  Game = boss_db:find_first(game, [{id, 'equals', GameId}]),
  Turn = Game:turn(),
  Timestamp = boss_mq:now("new-moves"),
  TurnString = atom_to_list(Turn),
  if
    TurnString == Player ->
      PlayerTurn = "your";
    true ->
      PlayerTurn = "your opponent's"
  end,
  {ok, [{game_id, GameId}, {player, Player}, {turn, PlayerTurn}, {timestamp, Timestamp}]}.

%currently unused, may be useful in future version
winner('GET', [GameId, Winner]) ->

  {ok, [{winner, Winner}]}.

%return the gameplay data, parse it into a json format for consumption by the browser in order to handle gui actions.
get_data('GET', [GameId,Player]) ->
    Game = boss_db:find_first(game, [{id, 'equals', GameId}]),
    Timestamp = boss_mq:now("new-moves"), %%%% ADDED BY CHRIS
    PlayerAtom = list_to_atom(Player),
    PropList = [{turn, Game:turn()},{winner, Game:winner()}],
    %converts newly parsed data to json and passes it back
    case PlayerAtom of
      player1 ->
        {json, PropList ++ [{board, board_to_proplist(Game:player1_board())}, {console, coord_recs_to_proplist(Game:player1_console())}, {timestamp, Timestamp}]};
      player2 ->
        {json, PropList ++ [{board, board_to_proplist(Game:player2_board())}, {console, coord_recs_to_proplist(Game:player2_console())}, {timestamp, Timestamp}]};
      _ ->
        {json, [{error, "error"}]}
    end.

%parse game data into json format
board_to_proplist([]) -> [];
board_to_proplist([Curr=#ship{}|Rest]) ->
  [[{ship_name,Curr#ship.name},
   {coord_list,coord_recs_to_proplist(Curr#ship.coord_list)}] | board_to_proplist(Rest)].

%parse data into json format
coord_recs_to_proplist([]) -> [];
coord_recs_to_proplist([Curr=#coord_rec{}|Rest]) ->
  [[{hit_status, Curr#coord_rec.hit_status},
   {coord, coord_to_proplist(Curr#coord_rec.coord)}] | coord_recs_to_proplist(Rest)].

%parse data into json format
coord_to_proplist(Coord=#coord{}) ->
  [{row, Coord#coord.row}, {column, Coord#coord.column}].

%pull updates from queue, used for live updating player views for attacks
pull('GET', [LastTimestamp]) ->
  {ok, Timestamp, Games} = boss_mq:pull("new-games",
  list_to_integer(LastTimestamp)),
  {json, [{timestamp, Timestamp}, {games, Games}]}.

%%%% ADDED BY CHRIS
new_moves('GET', [LastTimestamp]) ->
  {ok, Timestamp, Moves} = boss_mq:pull("new-moves",
  list_to_integer(LastTimestamp)),
  {json, [{timestamp, Timestamp}, {moves, Moves}]}.
