// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Super Farmer';

  @override
  String get collectAnimalsSubtitle =>
      'Collect one of each animal to win!\nWatch out for the fox and wolf!';

  @override
  String get collectAnimalsShort => 'Collect one of each animal to win!';

  @override
  String get collectYourAnimals => 'Collect your animals!';

  @override
  String get newGame => 'New Game';

  @override
  String get animals => 'Animals';

  @override
  String get settings => 'Settings';

  @override
  String get numberOfPlayers => 'Number of Players';

  @override
  String get startGame => 'Start Game';

  @override
  String playerN(int index) {
    return 'Player $index';
  }

  @override
  String aiPlayerN(int index) {
    return 'AI Player $index';
  }

  @override
  String aiDefaultName(int index, String difficulty) {
    return 'AI $index ($difficulty)';
  }

  @override
  String get nameOptional => 'Name (optional)';

  @override
  String get color => 'Color';

  @override
  String get rollDice => 'Roll Dice';

  @override
  String get endTurn => 'End Turn';

  @override
  String get tapToRoll => 'Tap to roll the dice!';

  @override
  String get result => 'Result:';

  @override
  String playerTurn(String name) {
    return '$name\'s Turn';
  }

  @override
  String get foxAttack => 'Fox attack!';

  @override
  String get foxDogSaved => 'Fox! Dog saved you';

  @override
  String get wolfAttack => 'Wolf attack!';

  @override
  String get wolfDogSaved => 'Wolf! Dog saved you';

  @override
  String get noMatch => 'No match — nothing bred';

  @override
  String get winner => 'Winner!';

  @override
  String winnerMessage(String name) {
    return '$name has collected one of each animal and wins the game!';
  }

  @override
  String get achievementUnlocked => 'Achievement Unlocked!';

  @override
  String get thinking => 'Thinking';

  @override
  String get greenDie => 'Green';

  @override
  String get redDie => 'Red';

  @override
  String get rules => 'Rules';

  @override
  String get interactiveTutorial => 'Interactive Tutorial';

  @override
  String get stepByStepGuide => 'Step-by-step guide with animations';

  @override
  String get startTutorial => 'Start Tutorial';

  @override
  String get quickReference => 'Quick Reference';

  @override
  String get rulesText =>
      'Super Farmer is a classic Polish board game where players compete to collect animals by rolling dice.\n\nGoal: Be the first player to collect at least one of each animal type: rabbit, lamb, pig, cow, and horse.\n\nOn each turn, roll two dice. The animals shown on the dice are added to your herd (paired with animals you already have).\n\nBeware! A fox will steal all your rabbits, and a wolf will steal everything except horses. Use a small dog to guard against the fox and a big dog to guard against the wolf.';

  @override
  String get animalValues => 'Animal Values';

  @override
  String nInGame(int count) {
    return '$count in game';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get overview => 'Overview';

  @override
  String get history => 'History';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get achievements => 'Achievements';

  @override
  String get clearAllStats => 'Clear all stats';

  @override
  String get noGamesYet => 'No games played yet';

  @override
  String get noGamesYetSubtitle =>
      'Complete a game to see your statistics here.';

  @override
  String get gamesSummary => 'Games Summary';

  @override
  String get played => 'Played';

  @override
  String get won => 'Won';

  @override
  String get lost => 'Lost';

  @override
  String get winRateByPlayerCount => 'Win Rate by Player Count';

  @override
  String nPlayers(int count) {
    return '$count players';
  }

  @override
  String get gameLength => 'Game Length';

  @override
  String get avgTurns => 'Avg. Turns';

  @override
  String get fastestWin => 'Fastest Win';

  @override
  String nTurns(int count) {
    return '$count turns';
  }

  @override
  String get winningStrategy => 'Winning Strategy';

  @override
  String get mostCommonFinalAnimal => 'Most common final animal';

  @override
  String get clearStatistics => 'Clear Statistics';

  @override
  String get clearStatisticsConfirm =>
      'This will permanently delete all game history. Continue?';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String nPlayersBadge(int count) {
    return '${count}P';
  }

  @override
  String historySubtitle(String names, int turns) {
    return '$names • $turns turns';
  }

  @override
  String get leaderboardMinPlayers =>
      'Play with at least 2 named players to see leaderboard rankings.';

  @override
  String nGamesPlayed(int count) {
    return '$count games played';
  }

  @override
  String nWins(int count) {
    return '$count wins';
  }

  @override
  String get progress => 'Progress';

  @override
  String nOfTotalUnlocked(int unlocked, int total) {
    return '$unlocked of $total unlocked';
  }

  @override
  String nSlashTotal(int unlocked, int total) {
    return '$unlocked / $total';
  }

  @override
  String percentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get sound => 'Sound';

  @override
  String get soundOn => 'On';

  @override
  String get soundOff => 'Off';

  @override
  String get animationSpeed => 'Animation Speed';

  @override
  String get speedSlow => 'Slow';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Fast';

  @override
  String get confirmEndTurn => 'Confirm End Turn';

  @override
  String get askBeforeEnding => 'Ask before ending turn';

  @override
  String get endTurnImmediately => 'End turn immediately';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get interactiveTutorialShort => 'Interactive tutorial';

  @override
  String get open => 'Open';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languagePolish => 'Polski';

  @override
  String get languageEnglish => 'English';

  @override
  String get tutorialWelcomeTitle => 'Welcome to Super Farmer!';

  @override
  String get tutorialWelcomeDesc =>
      'A classic Polish board game where you build a farm by collecting animals. Be the first to gather one of each animal type!';

  @override
  String get tutorialDiceTitle => 'Roll the Dice';

  @override
  String get tutorialDiceDesc =>
      'Each turn you roll two dice — one green and one red. Each die shows animals (and one predator). Tap below to try it!';

  @override
  String get tryRolling => 'Try Rolling';

  @override
  String get tutorialBreedingTitle => 'Animal Breeding';

  @override
  String get tutorialBreedingDesc =>
      'When you roll an animal you already own, they breed! New animals = (owned + rolled) ÷ 2, rounded down. Tap to see an example.';

  @override
  String get youHave => 'You have:';

  @override
  String get rolled => 'Rolled:';

  @override
  String get breedingResult => '(3 + 2) ÷ 2 = 2 new rabbits!';

  @override
  String get showResult => 'Show Result';

  @override
  String get reset => 'Reset';

  @override
  String get tutorialTradingTitle => 'Trading Animals';

  @override
  String get tutorialTradingDesc =>
      'Between rolls you can trade animals with the bank. Exchange smaller animals for bigger ones at these rates:';

  @override
  String get trade6Rabbits => '6 Rabbits';

  @override
  String get trade1Lamb => '1 Lamb';

  @override
  String get trade2Lambs => '2 Lambs';

  @override
  String get trade1Pig => '1 Pig';

  @override
  String get trade3Pigs => '3 Pigs';

  @override
  String get trade1Cow => '1 Cow';

  @override
  String get trade2Cows => '2 Cows';

  @override
  String get trade1Horse => '1 Horse';

  @override
  String get tutorialDogsTitle => 'Guard Dogs';

  @override
  String get tutorialDogsDesc =>
      'Dogs protect your farm from predators. Buy them by trading animals with the bank.';

  @override
  String get blocksFox => 'Blocks Fox';

  @override
  String get blocksWolf => 'Blocks Wolf';

  @override
  String costLabel(String cost) {
    return 'Cost: $cost';
  }

  @override
  String get tutorialAttacksTitle => 'Predator Attacks';

  @override
  String get tutorialAttacksDesc =>
      'Watch out! Rolling a predator can devastate your farm.';

  @override
  String get foxAttackTitle => 'Fox Attack';

  @override
  String get wolfAttackTitle => 'Wolf Attack';

  @override
  String get foxEffect => 'Steals ALL your rabbits';

  @override
  String get wolfEffect => 'Steals everything except horses';

  @override
  String get smallDogSavesRabbits => 'Small Dog saves your rabbits';

  @override
  String get bigDogSavesHerd => 'Big Dog saves your herd';

  @override
  String get simulateAttack => 'Simulate Attack!';

  @override
  String get tutorialWinTitle => 'How to Win';

  @override
  String get tutorialWinDesc =>
      'Be the first player to collect at least one of EACH farm animal. Dogs don\'t count toward winning.';

  @override
  String get collectOneOfEach => 'Collect one of each:';

  @override
  String get firstToWin => 'First to complete the set wins!';

  @override
  String get next => 'Next';

  @override
  String get gotIt => 'Got it!';

  @override
  String get skip => 'Skip';

  @override
  String get close => 'Close';

  @override
  String get exchangeRabbitsForSheep => '6 Rabbits = 1 Sheep';

  @override
  String get exchangeSheepForPig => '2 Sheep = 1 Pig';

  @override
  String get exchangePigsForCow => '3 Pigs = 1 Cow';

  @override
  String get exchangeCowsForHorse => '2 Cows = 1 Horse';

  @override
  String get buyWithLamb => 'Buy with 1 Lamb';

  @override
  String get buyWithCow => 'Buy with 1 Cow';

  @override
  String get notEnoughAnimals => 'Not enough animals';

  @override
  String get animalRabbit => 'Rabbit';

  @override
  String get animalLamb => 'Lamb';

  @override
  String get animalPig => 'Pig';

  @override
  String get animalCow => 'Cow';

  @override
  String get animalHorse => 'Horse';

  @override
  String get animalSmallDog => 'Small Dog';

  @override
  String get animalBigDog => 'Big Dog';

  @override
  String get animalFox => 'Fox';

  @override
  String get animalWolf => 'Wolf';

  @override
  String get achievementFirstFarm => 'First Farm';

  @override
  String get achievementFirstFarmDesc => 'Win your first game';

  @override
  String get achievementSpeedFarmer => 'Speed Farmer';

  @override
  String get achievementSpeedFarmerDesc => 'Win in under 15 turns';

  @override
  String get achievementHorseWhisperer => 'Horse Whisperer';

  @override
  String get achievementHorseWhispererDesc => 'Win with 3+ horses';

  @override
  String get achievementDogLover => 'Dog Lover';

  @override
  String get achievementDogLoverDesc => 'Own both dogs simultaneously';

  @override
  String get achievementSurvivor => 'Survivor';

  @override
  String get achievementSurvivorDesc => 'Survive 3 wolf attacks in one game';

  @override
  String get achievementFoxOutsmarted => 'Fox Outsmarted';

  @override
  String get achievementFoxOutsmartedDesc =>
      'Block 5 fox attacks total (across games)';

  @override
  String get achievementFullBarn => 'Full Barn';

  @override
  String get achievementFullBarnDesc => 'Have 10+ of every animal at once';

  @override
  String get achievementUnderdog => 'Underdog';

  @override
  String get achievementUnderdogDesc =>
      'Win from behind (lowest % at turn 20+)';

  @override
  String get achievementFarmerPro => 'Farmer Pro';

  @override
  String get achievementFarmerProDesc => 'Win 50 games';

  @override
  String get achievementLuckyRoller => 'Lucky Roller';

  @override
  String get achievementLuckyRollerDesc => 'Roll double horse';

  @override
  String get aiEasy => 'Easy';

  @override
  String get aiEasyDesc => 'Random moves';

  @override
  String get aiMedium => 'Medium';

  @override
  String get aiMediumDesc => 'Smart trades & dogs';

  @override
  String get aiHard => 'Hard';

  @override
  String get aiHardDesc => 'Optimal strategy';

  @override
  String nNewAnimals(int count, String animal) {
    return '$count $animal';
  }

  @override
  String get replays => 'Replays';

  @override
  String get importReplay => 'Import Replay';

  @override
  String get pasteReplayJson => 'Paste replay JSON here...';

  @override
  String get replayImported => 'Replay imported successfully';

  @override
  String get replayImportError => 'Invalid replay data';

  @override
  String get import_ => 'Import';

  @override
  String get noReplaysYet => 'No replays yet';

  @override
  String get noReplaysYetSubtitle => 'Complete a game to record a replay.';

  @override
  String get watchReplay => 'Watch Replay';

  @override
  String get exportReplay => 'Export Replay';

  @override
  String get deleteReplay => 'Delete Replay';

  @override
  String get replayCopied => 'Replay copied to clipboard';

  @override
  String get deleteReplayConfirm =>
      'This will permanently delete this replay. Continue?';

  @override
  String get delete => 'Delete';

  @override
  String get replayViewer => 'Replay Viewer';

  @override
  String turnOfTotal(int current, int total) {
    return 'Turn $current of $total';
  }

  @override
  String turnN(int n) {
    return 'Turn $n';
  }

  @override
  String get bred => 'Bred';

  @override
  String get lostLabel => 'Lost';

  @override
  String get traded => 'Traded';

  @override
  String get speed => 'Speed';

  @override
  String get navHome => 'Home';

  @override
  String get navGame => 'Game';

  @override
  String get navRules => 'Rules';

  @override
  String get navStats => 'Stats';
}
