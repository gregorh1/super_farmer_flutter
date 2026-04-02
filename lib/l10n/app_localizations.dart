import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Super Farmer'**
  String get appTitle;

  /// No description provided for @collectAnimalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Collect one of each animal to win!\nWatch out for the fox and wolf!'**
  String get collectAnimalsSubtitle;

  /// No description provided for @collectAnimalsShort.
  ///
  /// In en, this message translates to:
  /// **'Collect one of each animal to win!'**
  String get collectAnimalsShort;

  /// No description provided for @collectYourAnimals.
  ///
  /// In en, this message translates to:
  /// **'Collect your animals!'**
  String get collectYourAnimals;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @animals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animals;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @numberOfPlayers.
  ///
  /// In en, this message translates to:
  /// **'Number of Players'**
  String get numberOfPlayers;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  /// No description provided for @playerN.
  ///
  /// In en, this message translates to:
  /// **'Player {index}'**
  String playerN(int index);

  /// No description provided for @aiPlayerN.
  ///
  /// In en, this message translates to:
  /// **'AI Player {index}'**
  String aiPlayerN(int index);

  /// No description provided for @aiDefaultName.
  ///
  /// In en, this message translates to:
  /// **'AI {index} ({difficulty})'**
  String aiDefaultName(int index, String difficulty);

  /// No description provided for @nameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get nameOptional;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @rollDice.
  ///
  /// In en, this message translates to:
  /// **'Roll Dice'**
  String get rollDice;

  /// No description provided for @endTurn.
  ///
  /// In en, this message translates to:
  /// **'End Turn'**
  String get endTurn;

  /// No description provided for @tapToRoll.
  ///
  /// In en, this message translates to:
  /// **'Tap to roll the dice!'**
  String get tapToRoll;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result:'**
  String get result;

  /// No description provided for @playerTurn.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Turn'**
  String playerTurn(String name);

  /// No description provided for @foxAttack.
  ///
  /// In en, this message translates to:
  /// **'Fox attack!'**
  String get foxAttack;

  /// No description provided for @foxDogSaved.
  ///
  /// In en, this message translates to:
  /// **'Fox! Dog saved you'**
  String get foxDogSaved;

  /// No description provided for @wolfAttack.
  ///
  /// In en, this message translates to:
  /// **'Wolf attack!'**
  String get wolfAttack;

  /// No description provided for @wolfDogSaved.
  ///
  /// In en, this message translates to:
  /// **'Wolf! Dog saved you'**
  String get wolfDogSaved;

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'No match — nothing bred'**
  String get noMatch;

  /// No description provided for @winner.
  ///
  /// In en, this message translates to:
  /// **'Winner!'**
  String get winner;

  /// No description provided for @winnerMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} has collected one of each animal and wins the game!'**
  String winnerMessage(String name);

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get thinking;

  /// No description provided for @greenDie.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get greenDie;

  /// No description provided for @redDie.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get redDie;

  /// No description provided for @rules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rules;

  /// No description provided for @interactiveTutorial.
  ///
  /// In en, this message translates to:
  /// **'Interactive Tutorial'**
  String get interactiveTutorial;

  /// No description provided for @stepByStepGuide.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step guide with animations'**
  String get stepByStepGuide;

  /// No description provided for @startTutorial.
  ///
  /// In en, this message translates to:
  /// **'Start Tutorial'**
  String get startTutorial;

  /// No description provided for @quickReference.
  ///
  /// In en, this message translates to:
  /// **'Quick Reference'**
  String get quickReference;

  /// No description provided for @rulesText.
  ///
  /// In en, this message translates to:
  /// **'Super Farmer is a classic Polish board game where players compete to collect animals by rolling dice.\n\nGoal: Be the first player to collect at least one of each animal type: rabbit, lamb, pig, cow, and horse.\n\nOn each turn, roll two dice. The animals shown on the dice are added to your herd (paired with animals you already have).\n\nBeware! A fox will steal all your rabbits, and a wolf will steal everything except horses. Use a small dog to guard against the fox and a big dog to guard against the wolf.'**
  String get rulesText;

  /// No description provided for @animalValues.
  ///
  /// In en, this message translates to:
  /// **'Animal Values'**
  String get animalValues;

  /// No description provided for @nInGame.
  ///
  /// In en, this message translates to:
  /// **'{count} in game'**
  String nInGame(int count);

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @clearAllStats.
  ///
  /// In en, this message translates to:
  /// **'Clear all stats'**
  String get clearAllStats;

  /// No description provided for @noGamesYet.
  ///
  /// In en, this message translates to:
  /// **'No games played yet'**
  String get noGamesYet;

  /// No description provided for @noGamesYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete a game to see your statistics here.'**
  String get noGamesYetSubtitle;

  /// No description provided for @gamesSummary.
  ///
  /// In en, this message translates to:
  /// **'Games Summary'**
  String get gamesSummary;

  /// No description provided for @played.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get played;

  /// No description provided for @won.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get won;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lost;

  /// No description provided for @winRateByPlayerCount.
  ///
  /// In en, this message translates to:
  /// **'Win Rate by Player Count'**
  String get winRateByPlayerCount;

  /// No description provided for @nPlayers.
  ///
  /// In en, this message translates to:
  /// **'{count} players'**
  String nPlayers(int count);

  /// No description provided for @gameLength.
  ///
  /// In en, this message translates to:
  /// **'Game Length'**
  String get gameLength;

  /// No description provided for @avgTurns.
  ///
  /// In en, this message translates to:
  /// **'Avg. Turns'**
  String get avgTurns;

  /// No description provided for @fastestWin.
  ///
  /// In en, this message translates to:
  /// **'Fastest Win'**
  String get fastestWin;

  /// No description provided for @nTurns.
  ///
  /// In en, this message translates to:
  /// **'{count} turns'**
  String nTurns(int count);

  /// No description provided for @winningStrategy.
  ///
  /// In en, this message translates to:
  /// **'Winning Strategy'**
  String get winningStrategy;

  /// No description provided for @mostCommonFinalAnimal.
  ///
  /// In en, this message translates to:
  /// **'Most common final animal'**
  String get mostCommonFinalAnimal;

  /// No description provided for @clearStatistics.
  ///
  /// In en, this message translates to:
  /// **'Clear Statistics'**
  String get clearStatistics;

  /// No description provided for @clearStatisticsConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all game history. Continue?'**
  String get clearStatisticsConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @nPlayersBadge.
  ///
  /// In en, this message translates to:
  /// **'{count}P'**
  String nPlayersBadge(int count);

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{names} • {turns} turns'**
  String historySubtitle(String names, int turns);

  /// No description provided for @leaderboardMinPlayers.
  ///
  /// In en, this message translates to:
  /// **'Play with at least 2 named players to see leaderboard rankings.'**
  String get leaderboardMinPlayers;

  /// No description provided for @nGamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'{count} games played'**
  String nGamesPlayed(int count);

  /// No description provided for @nWins.
  ///
  /// In en, this message translates to:
  /// **'{count} wins'**
  String nWins(int count);

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @nOfTotalUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} of {total} unlocked'**
  String nOfTotalUnlocked(int unlocked, int total);

  /// No description provided for @nSlashTotal.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} / {total}'**
  String nSlashTotal(int unlocked, int total);

  /// No description provided for @percentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String percentComplete(int percent);

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @soundOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get soundOn;

  /// No description provided for @soundOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get soundOff;

  /// No description provided for @animationSpeed.
  ///
  /// In en, this message translates to:
  /// **'Animation Speed'**
  String get animationSpeed;

  /// No description provided for @speedSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get speedSlow;

  /// No description provided for @speedNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get speedNormal;

  /// No description provided for @speedFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get speedFast;

  /// No description provided for @confirmEndTurn.
  ///
  /// In en, this message translates to:
  /// **'Confirm End Turn'**
  String get confirmEndTurn;

  /// No description provided for @askBeforeEnding.
  ///
  /// In en, this message translates to:
  /// **'Ask before ending turn'**
  String get askBeforeEnding;

  /// No description provided for @endTurnImmediately.
  ///
  /// In en, this message translates to:
  /// **'End turn immediately'**
  String get endTurnImmediately;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// No description provided for @interactiveTutorialShort.
  ///
  /// In en, this message translates to:
  /// **'Interactive tutorial'**
  String get interactiveTutorialShort;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languagePolish.
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get languagePolish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @tutorialWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Super Farmer!'**
  String get tutorialWelcomeTitle;

  /// No description provided for @tutorialWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'A classic Polish board game where you build a farm by collecting animals. Be the first to gather one of each animal type!'**
  String get tutorialWelcomeDesc;

  /// No description provided for @tutorialDiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Roll the Dice'**
  String get tutorialDiceTitle;

  /// No description provided for @tutorialDiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Each turn you roll two dice — one green and one red. Each die shows animals (and one predator). Tap below to try it!'**
  String get tutorialDiceDesc;

  /// No description provided for @tryRolling.
  ///
  /// In en, this message translates to:
  /// **'Try Rolling'**
  String get tryRolling;

  /// No description provided for @tutorialBreedingTitle.
  ///
  /// In en, this message translates to:
  /// **'Animal Breeding'**
  String get tutorialBreedingTitle;

  /// No description provided for @tutorialBreedingDesc.
  ///
  /// In en, this message translates to:
  /// **'When you roll an animal you already own, they breed! New animals = (owned + rolled) ÷ 2, rounded down. Tap to see an example.'**
  String get tutorialBreedingDesc;

  /// No description provided for @youHave.
  ///
  /// In en, this message translates to:
  /// **'You have:'**
  String get youHave;

  /// No description provided for @rolled.
  ///
  /// In en, this message translates to:
  /// **'Rolled:'**
  String get rolled;

  /// No description provided for @breedingResult.
  ///
  /// In en, this message translates to:
  /// **'(3 + 2) ÷ 2 = 2 new rabbits!'**
  String get breedingResult;

  /// No description provided for @showResult.
  ///
  /// In en, this message translates to:
  /// **'Show Result'**
  String get showResult;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @tutorialTradingTitle.
  ///
  /// In en, this message translates to:
  /// **'Trading Animals'**
  String get tutorialTradingTitle;

  /// No description provided for @tutorialTradingDesc.
  ///
  /// In en, this message translates to:
  /// **'Between rolls you can trade animals with the bank. Exchange smaller animals for bigger ones at these rates:'**
  String get tutorialTradingDesc;

  /// No description provided for @trade6Rabbits.
  ///
  /// In en, this message translates to:
  /// **'6 Rabbits'**
  String get trade6Rabbits;

  /// No description provided for @trade1Lamb.
  ///
  /// In en, this message translates to:
  /// **'1 Lamb'**
  String get trade1Lamb;

  /// No description provided for @trade2Lambs.
  ///
  /// In en, this message translates to:
  /// **'2 Lambs'**
  String get trade2Lambs;

  /// No description provided for @trade1Pig.
  ///
  /// In en, this message translates to:
  /// **'1 Pig'**
  String get trade1Pig;

  /// No description provided for @trade3Pigs.
  ///
  /// In en, this message translates to:
  /// **'3 Pigs'**
  String get trade3Pigs;

  /// No description provided for @trade1Cow.
  ///
  /// In en, this message translates to:
  /// **'1 Cow'**
  String get trade1Cow;

  /// No description provided for @trade2Cows.
  ///
  /// In en, this message translates to:
  /// **'2 Cows'**
  String get trade2Cows;

  /// No description provided for @trade1Horse.
  ///
  /// In en, this message translates to:
  /// **'1 Horse'**
  String get trade1Horse;

  /// No description provided for @tutorialDogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Guard Dogs'**
  String get tutorialDogsTitle;

  /// No description provided for @tutorialDogsDesc.
  ///
  /// In en, this message translates to:
  /// **'Dogs protect your farm from predators. Buy them by trading animals with the bank.'**
  String get tutorialDogsDesc;

  /// No description provided for @blocksFox.
  ///
  /// In en, this message translates to:
  /// **'Blocks Fox'**
  String get blocksFox;

  /// No description provided for @blocksWolf.
  ///
  /// In en, this message translates to:
  /// **'Blocks Wolf'**
  String get blocksWolf;

  /// No description provided for @costLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost: {cost}'**
  String costLabel(String cost);

  /// No description provided for @tutorialAttacksTitle.
  ///
  /// In en, this message translates to:
  /// **'Predator Attacks'**
  String get tutorialAttacksTitle;

  /// No description provided for @tutorialAttacksDesc.
  ///
  /// In en, this message translates to:
  /// **'Watch out! Rolling a predator can devastate your farm.'**
  String get tutorialAttacksDesc;

  /// No description provided for @foxAttackTitle.
  ///
  /// In en, this message translates to:
  /// **'Fox Attack'**
  String get foxAttackTitle;

  /// No description provided for @wolfAttackTitle.
  ///
  /// In en, this message translates to:
  /// **'Wolf Attack'**
  String get wolfAttackTitle;

  /// No description provided for @foxEffect.
  ///
  /// In en, this message translates to:
  /// **'Steals ALL your rabbits'**
  String get foxEffect;

  /// No description provided for @wolfEffect.
  ///
  /// In en, this message translates to:
  /// **'Steals everything except horses'**
  String get wolfEffect;

  /// No description provided for @smallDogSavesRabbits.
  ///
  /// In en, this message translates to:
  /// **'Small Dog saves your rabbits'**
  String get smallDogSavesRabbits;

  /// No description provided for @bigDogSavesHerd.
  ///
  /// In en, this message translates to:
  /// **'Big Dog saves your herd'**
  String get bigDogSavesHerd;

  /// No description provided for @simulateAttack.
  ///
  /// In en, this message translates to:
  /// **'Simulate Attack!'**
  String get simulateAttack;

  /// No description provided for @tutorialWinTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Win'**
  String get tutorialWinTitle;

  /// No description provided for @tutorialWinDesc.
  ///
  /// In en, this message translates to:
  /// **'Be the first player to collect at least one of EACH farm animal. Dogs don\'t count toward winning.'**
  String get tutorialWinDesc;

  /// No description provided for @collectOneOfEach.
  ///
  /// In en, this message translates to:
  /// **'Collect one of each:'**
  String get collectOneOfEach;

  /// No description provided for @firstToWin.
  ///
  /// In en, this message translates to:
  /// **'First to complete the set wins!'**
  String get firstToWin;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get gotIt;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @exchangeRabbitsForSheep.
  ///
  /// In en, this message translates to:
  /// **'6 Rabbits = 1 Sheep'**
  String get exchangeRabbitsForSheep;

  /// No description provided for @exchangeSheepForPig.
  ///
  /// In en, this message translates to:
  /// **'2 Sheep = 1 Pig'**
  String get exchangeSheepForPig;

  /// No description provided for @exchangePigsForCow.
  ///
  /// In en, this message translates to:
  /// **'3 Pigs = 1 Cow'**
  String get exchangePigsForCow;

  /// No description provided for @exchangeCowsForHorse.
  ///
  /// In en, this message translates to:
  /// **'2 Cows = 1 Horse'**
  String get exchangeCowsForHorse;

  /// No description provided for @buyWithLamb.
  ///
  /// In en, this message translates to:
  /// **'Buy with 1 Lamb'**
  String get buyWithLamb;

  /// No description provided for @buyWithCow.
  ///
  /// In en, this message translates to:
  /// **'Buy with 1 Cow'**
  String get buyWithCow;

  /// No description provided for @notEnoughAnimals.
  ///
  /// In en, this message translates to:
  /// **'Not enough animals'**
  String get notEnoughAnimals;

  /// No description provided for @animalRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get animalRabbit;

  /// No description provided for @animalLamb.
  ///
  /// In en, this message translates to:
  /// **'Lamb'**
  String get animalLamb;

  /// No description provided for @animalPig.
  ///
  /// In en, this message translates to:
  /// **'Pig'**
  String get animalPig;

  /// No description provided for @animalCow.
  ///
  /// In en, this message translates to:
  /// **'Cow'**
  String get animalCow;

  /// No description provided for @animalHorse.
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get animalHorse;

  /// No description provided for @animalSmallDog.
  ///
  /// In en, this message translates to:
  /// **'Small Dog'**
  String get animalSmallDog;

  /// No description provided for @animalBigDog.
  ///
  /// In en, this message translates to:
  /// **'Big Dog'**
  String get animalBigDog;

  /// No description provided for @animalFox.
  ///
  /// In en, this message translates to:
  /// **'Fox'**
  String get animalFox;

  /// No description provided for @animalWolf.
  ///
  /// In en, this message translates to:
  /// **'Wolf'**
  String get animalWolf;

  /// No description provided for @achievementFirstFarm.
  ///
  /// In en, this message translates to:
  /// **'First Farm'**
  String get achievementFirstFarm;

  /// No description provided for @achievementFirstFarmDesc.
  ///
  /// In en, this message translates to:
  /// **'Win your first game'**
  String get achievementFirstFarmDesc;

  /// No description provided for @achievementSpeedFarmer.
  ///
  /// In en, this message translates to:
  /// **'Speed Farmer'**
  String get achievementSpeedFarmer;

  /// No description provided for @achievementSpeedFarmerDesc.
  ///
  /// In en, this message translates to:
  /// **'Win in under 15 turns'**
  String get achievementSpeedFarmerDesc;

  /// No description provided for @achievementHorseWhisperer.
  ///
  /// In en, this message translates to:
  /// **'Horse Whisperer'**
  String get achievementHorseWhisperer;

  /// No description provided for @achievementHorseWhispererDesc.
  ///
  /// In en, this message translates to:
  /// **'Win with 3+ horses'**
  String get achievementHorseWhispererDesc;

  /// No description provided for @achievementDogLover.
  ///
  /// In en, this message translates to:
  /// **'Dog Lover'**
  String get achievementDogLover;

  /// No description provided for @achievementDogLoverDesc.
  ///
  /// In en, this message translates to:
  /// **'Own both dogs simultaneously'**
  String get achievementDogLoverDesc;

  /// No description provided for @achievementSurvivor.
  ///
  /// In en, this message translates to:
  /// **'Survivor'**
  String get achievementSurvivor;

  /// No description provided for @achievementSurvivorDesc.
  ///
  /// In en, this message translates to:
  /// **'Survive 3 wolf attacks in one game'**
  String get achievementSurvivorDesc;

  /// No description provided for @achievementFoxOutsmarted.
  ///
  /// In en, this message translates to:
  /// **'Fox Outsmarted'**
  String get achievementFoxOutsmarted;

  /// No description provided for @achievementFoxOutsmartedDesc.
  ///
  /// In en, this message translates to:
  /// **'Block 5 fox attacks total (across games)'**
  String get achievementFoxOutsmartedDesc;

  /// No description provided for @achievementFullBarn.
  ///
  /// In en, this message translates to:
  /// **'Full Barn'**
  String get achievementFullBarn;

  /// No description provided for @achievementFullBarnDesc.
  ///
  /// In en, this message translates to:
  /// **'Have 10+ of every animal at once'**
  String get achievementFullBarnDesc;

  /// No description provided for @achievementUnderdog.
  ///
  /// In en, this message translates to:
  /// **'Underdog'**
  String get achievementUnderdog;

  /// No description provided for @achievementUnderdogDesc.
  ///
  /// In en, this message translates to:
  /// **'Win from behind (lowest % at turn 20+)'**
  String get achievementUnderdogDesc;

  /// No description provided for @achievementFarmerPro.
  ///
  /// In en, this message translates to:
  /// **'Farmer Pro'**
  String get achievementFarmerPro;

  /// No description provided for @achievementFarmerProDesc.
  ///
  /// In en, this message translates to:
  /// **'Win 50 games'**
  String get achievementFarmerProDesc;

  /// No description provided for @achievementLuckyRoller.
  ///
  /// In en, this message translates to:
  /// **'Lucky Roller'**
  String get achievementLuckyRoller;

  /// No description provided for @achievementLuckyRollerDesc.
  ///
  /// In en, this message translates to:
  /// **'Roll double horse'**
  String get achievementLuckyRollerDesc;

  /// No description provided for @aiEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get aiEasy;

  /// No description provided for @aiEasyDesc.
  ///
  /// In en, this message translates to:
  /// **'Random moves'**
  String get aiEasyDesc;

  /// No description provided for @aiMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get aiMedium;

  /// No description provided for @aiMediumDesc.
  ///
  /// In en, this message translates to:
  /// **'Smart trades & dogs'**
  String get aiMediumDesc;

  /// No description provided for @aiHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get aiHard;

  /// No description provided for @aiHardDesc.
  ///
  /// In en, this message translates to:
  /// **'Optimal strategy'**
  String get aiHardDesc;

  /// No description provided for @nNewAnimals.
  ///
  /// In en, this message translates to:
  /// **'{count} {animal}'**
  String nNewAnimals(int count, String animal);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get navGame;

  /// No description provided for @navRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get navRules;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  // --- Replay feature ---

  /// No description provided for @replays.
  ///
  /// In en, this message translates to:
  /// **'Replays'**
  String get replays;

  /// No description provided for @noReplaysYet.
  ///
  /// In en, this message translates to:
  /// **'No replays yet'**
  String get noReplaysYet;

  /// No description provided for @noReplaysYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete a game to see replays here.'**
  String get noReplaysYetSubtitle;

  /// No description provided for @replayViewer.
  ///
  /// In en, this message translates to:
  /// **'Replay Viewer'**
  String get replayViewer;

  /// No description provided for @turnN.
  ///
  /// In en, this message translates to:
  /// **'Turn {number}'**
  String turnN(int number);

  /// No description provided for @turnOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Turn {current} of {total}'**
  String turnOfTotal(int current, int total);

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @exportReplay.
  ///
  /// In en, this message translates to:
  /// **'Export Replay'**
  String get exportReplay;

  /// No description provided for @importReplay.
  ///
  /// In en, this message translates to:
  /// **'Import Replay'**
  String get importReplay;

  /// No description provided for @replayCopied.
  ///
  /// In en, this message translates to:
  /// **'Replay JSON copied to clipboard'**
  String get replayCopied;

  /// No description provided for @replayImported.
  ///
  /// In en, this message translates to:
  /// **'Replay imported successfully'**
  String get replayImported;

  /// No description provided for @replayImportError.
  ///
  /// In en, this message translates to:
  /// **'Invalid replay data'**
  String get replayImportError;

  /// No description provided for @deleteReplay.
  ///
  /// In en, this message translates to:
  /// **'Delete Replay'**
  String get deleteReplay;

  /// No description provided for @deleteReplayConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this replay?'**
  String get deleteReplayConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @bred.
  ///
  /// In en, this message translates to:
  /// **'Bred'**
  String get bred;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lostLabel;

  /// No description provided for @traded.
  ///
  /// In en, this message translates to:
  /// **'Traded'**
  String get traded;

  /// No description provided for @pasteReplayJson.
  ///
  /// In en, this message translates to:
  /// **'Paste replay JSON'**
  String get pasteReplayJson;

  /// No description provided for @import_.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import_;

  /// No description provided for @watchReplay.
  ///
  /// In en, this message translates to:
  /// **'Watch Replay'**
  String get watchReplay;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
