class GameModes {
  String gameMode;
  String description;
  String imgPath;

  GameModes(this.imgPath, this.gameMode, this.description);
}

List<GameModes> gameModeList = [
  GameModes("images/coins.svg", "Play with friends",
      "Invite friends and win coins upto 12000!"),
  GameModes("images/cash.svg", "Online with cash",
      "Play online (1v1) and get to win upto Rs 133 balance!"),
  GameModes("images/coins.svg", "Online with coins",
      "Play online (1v1) and get to win coins upto 12000!"),
];

List<int> cashList = [
  10,
  15,
  20,
  25,
  30,
  35,
  40,
  45,
  50,
  55,
  60,
  65,
  70,
  75,
  80,
  85,
  90,
  95,
  100,
  120,
  150,
  200,
];

List<int> coinsList = [
  5,
  10,
  20,
  50,
  200,
  500,
  1000,
  2000,
  5000,
  10000,
  12000,
  13000,
  14000,
  15000,
];
