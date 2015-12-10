-module(game, [Id, 
                  Player1Board,
                  Player2Board,
                  Player1Console,
                  Player2Console,
                  Winner,
                  Turn]).
-compile(export_all).

% parse the string of coordinates into a list of tuples in the format required by gameplay_logic.erl
parse(StringCoord) ->
  StringList = string:tokens(StringCoord, ", "),
  formatList(StringList, []).

%formats the list of coordinates recursively, converts char's to atoms
formatList([Head | List], Formatted) ->
  X = string:sub_string(Head, 1, 1),
  Y = string:sub_string(Head, 2, 3),
  FinalX = getChar(X),
  {FinalY,_} = string:to_integer(Y),
  Coords = {FinalX, FinalY},
  NewFormatted = lists:append(Formatted, [Coords]),
  formatList(List, NewFormatted);
formatList([], Formatted) -> Formatted.

%converts chars to atoms
getChar(Char) ->
  case Char of
    "a" -> $a;
    "b" -> $b;
    "c" -> $c;
    "d" -> $d;
    "e" -> $e;
    "f" -> $f;
    "g" -> $g;
    "h" -> $h;
    "i" -> $i;
    "j" -> $j
  end.
