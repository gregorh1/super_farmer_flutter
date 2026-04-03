// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Superfarmer';

  @override
  String get collectAnimalsSubtitle =>
      'Zbierz po jednym z każdego zwierzęcia, aby wygrać!\nUważaj na lisa i wilka!';

  @override
  String get collectAnimalsShort =>
      'Zbierz po jednym z każdego zwierzęcia, aby wygrać!';

  @override
  String get collectYourAnimals => 'Zbierz swoje zwierzęta!';

  @override
  String get newGame => 'Nowa Gra';

  @override
  String get animals => 'Zwierzęta';

  @override
  String get settings => 'Ustawienia';

  @override
  String get numberOfPlayers => 'Liczba Graczy';

  @override
  String get startGame => 'Rozpocznij Grę';

  @override
  String playerN(int index) {
    return 'Gracz $index';
  }

  @override
  String aiPlayerN(int index) {
    return 'Gracz AI $index';
  }

  @override
  String aiDefaultName(int index, String difficulty) {
    return 'AI $index ($difficulty)';
  }

  @override
  String get nameOptional => 'Imię (opcjonalnie)';

  @override
  String get color => 'Kolor';

  @override
  String get rollDice => 'Rzuć Kośćmi';

  @override
  String get endTurn => 'Zakończ Turę';

  @override
  String get tapToRoll => 'Dotknij, aby rzucić kośćmi!';

  @override
  String get result => 'Wynik:';

  @override
  String playerTurn(String name) {
    return 'Tura gracza $name';
  }

  @override
  String get foxAttack => 'Atak lisa!';

  @override
  String get foxDogSaved => 'Lis! Pies cię uratował';

  @override
  String get wolfAttack => 'Atak wilka!';

  @override
  String get wolfDogSaved => 'Wilk! Pies cię uratował';

  @override
  String get noMatch => 'Brak pary — nic nie wyhodowano';

  @override
  String get winner => 'Zwycięzca!';

  @override
  String winnerMessage(String name) {
    return '$name zebrał po jednym z każdego zwierzęcia i wygrywa grę!';
  }

  @override
  String get achievementUnlocked => 'Osiągnięcie odblokowane!';

  @override
  String get thinking => 'Myślę';

  @override
  String get greenDie => 'Zielona';

  @override
  String get redDie => 'Czerwona';

  @override
  String get rules => 'Zasady';

  @override
  String get interactiveTutorial => 'Interaktywny Samouczek';

  @override
  String get stepByStepGuide => 'Przewodnik krok po kroku z animacjami';

  @override
  String get startTutorial => 'Rozpocznij Samouczek';

  @override
  String get quickReference => 'Krótki Przewodnik';

  @override
  String get rulesText =>
      'Superfarmer to klasyczna polska gra planszowa, w której gracze rywalizują o zbieranie zwierząt rzucając kośćmi.\n\nCel: Bądź pierwszym graczem, który zbierze po jednym zwierzęciu każdego rodzaju: królika, owcę, świnię, krowę i konia.\n\nW każdej turze rzucasz dwiema kośćmi. Zwierzęta pokazane na kościach dołączają do twojego stada (w parze ze zwierzętami, które już posiadasz).\n\nUwaga! Lis ukradnie wszystkie twoje króliki, a wilk zabierze wszystko oprócz koni. Użyj małego psa do ochrony przed lisem i dużego psa do ochrony przed wilkiem.';

  @override
  String get animalValues => 'Wartości Zwierząt';

  @override
  String nInGame(int count) {
    return '$count w grze';
  }

  @override
  String get statistics => 'Statystyki';

  @override
  String get overview => 'Przegląd';

  @override
  String get history => 'Historia';

  @override
  String get leaderboard => 'Ranking';

  @override
  String get achievements => 'Osiągnięcia';

  @override
  String get clearAllStats => 'Wyczyść statystyki';

  @override
  String get noGamesYet => 'Brak rozegranych gier';

  @override
  String get noGamesYetSubtitle =>
      'Rozegraj grę, aby zobaczyć tutaj statystyki.';

  @override
  String get gamesSummary => 'Podsumowanie Gier';

  @override
  String get played => 'Rozegrane';

  @override
  String get won => 'Wygrane';

  @override
  String get lost => 'Przegrane';

  @override
  String get winRateByPlayerCount => 'Procent wygranych wg liczby graczy';

  @override
  String nPlayers(int count) {
    return '$count graczy';
  }

  @override
  String get gameLength => 'Długość Gry';

  @override
  String get avgTurns => 'Śr. Tur';

  @override
  String get fastestWin => 'Najszybsza Wygrana';

  @override
  String nTurns(int count) {
    return '$count tur';
  }

  @override
  String get winningStrategy => 'Strategia Wygrywania';

  @override
  String get mostCommonFinalAnimal => 'Najczęstsze ostatnie zwierzę';

  @override
  String get clearStatistics => 'Wyczyść Statystyki';

  @override
  String get clearStatisticsConfirm =>
      'Spowoduje to trwałe usunięcie całej historii gier. Kontynuować?';

  @override
  String get cancel => 'Anuluj';

  @override
  String get clear => 'Wyczyść';

  @override
  String nPlayersBadge(int count) {
    return '${count}G';
  }

  @override
  String historySubtitle(String names, int turns) {
    return '$names • $turns tur';
  }

  @override
  String get leaderboardMinPlayers =>
      'Zagraj z co najmniej 2 nazwanymi graczami, aby zobaczyć ranking.';

  @override
  String nGamesPlayed(int count) {
    return '$count rozegranych gier';
  }

  @override
  String nWins(int count) {
    return '$count wygranych';
  }

  @override
  String get progress => 'Postęp';

  @override
  String nOfTotalUnlocked(int unlocked, int total) {
    return '$unlocked z $total odblokowanych';
  }

  @override
  String nSlashTotal(int unlocked, int total) {
    return '$unlocked / $total';
  }

  @override
  String percentComplete(int percent) {
    return '$percent% ukończono';
  }

  @override
  String get theme => 'Motyw';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get sound => 'Dźwięk';

  @override
  String get soundOn => 'Wł.';

  @override
  String get soundOff => 'Wył.';

  @override
  String get animationSpeed => 'Prędkość Animacji';

  @override
  String get speedSlow => 'Wolno';

  @override
  String get speedNormal => 'Normalnie';

  @override
  String get speedFast => 'Szybko';

  @override
  String get confirmEndTurn => 'Potwierdź koniec tury';

  @override
  String get askBeforeEnding => 'Pytaj przed zakończeniem tury';

  @override
  String get endTurnImmediately => 'Zakończ turę natychmiast';

  @override
  String get howToPlay => 'Jak Grać';

  @override
  String get interactiveTutorialShort => 'Interaktywny samouczek';

  @override
  String get open => 'Otwórz';

  @override
  String get language => 'Język';

  @override
  String get languageSystem => 'Systemowy';

  @override
  String get languagePolish => 'Polski';

  @override
  String get languageEnglish => 'English';

  @override
  String get tutorialWelcomeTitle => 'Witaj w Superfarmerze!';

  @override
  String get tutorialWelcomeDesc =>
      'Klasyczna polska gra planszowa, w której budujesz farmę zbierając zwierzęta. Bądź pierwszy, który zbierze po jednym z każdego rodzaju!';

  @override
  String get tutorialDiceTitle => 'Rzuć Kośćmi';

  @override
  String get tutorialDiceDesc =>
      'W każdej turze rzucasz dwiema kośćmi — jedną zieloną i jedną czerwoną. Każda kość pokazuje zwierzęta (i jednego drapieżnika). Dotknij poniżej, aby spróbować!';

  @override
  String get tryRolling => 'Spróbuj Rzucić';

  @override
  String get tutorialBreedingTitle => 'Hodowla Zwierząt';

  @override
  String get tutorialBreedingDesc =>
      'Gdy wyrzucisz zwierzę, które już posiadasz, rozmnażają się! Nowe zwierzęta = (posiadane + wyrzucone) ÷ 2, zaokrąglone w dół. Dotknij, aby zobaczyć przykład.';

  @override
  String get youHave => 'Masz:';

  @override
  String get rolled => 'Wyrzucono:';

  @override
  String get breedingResult => '(3 + 2) ÷ 2 = 2 nowe króliki!';

  @override
  String get showResult => 'Pokaż Wynik';

  @override
  String get reset => 'Resetuj';

  @override
  String get tutorialTradingTitle => 'Wymiana Zwierząt';

  @override
  String get tutorialTradingDesc =>
      'Między rzutami możesz wymieniać zwierzęta z bankiem. Wymieniaj mniejsze zwierzęta na większe według tych kursów:';

  @override
  String get trade6Rabbits => '6 Królików';

  @override
  String get trade1Lamb => '1 Owca';

  @override
  String get trade2Lambs => '2 Owce';

  @override
  String get trade1Pig => '1 Świnia';

  @override
  String get trade3Pigs => '3 Świnie';

  @override
  String get trade1Cow => '1 Krowa';

  @override
  String get trade2Cows => '2 Krowy';

  @override
  String get trade1Horse => '1 Koń';

  @override
  String get tutorialDogsTitle => 'Psy Stróżujące';

  @override
  String get tutorialDogsDesc =>
      'Psy chronią twoją farmę przed drapieżnikami. Kup je wymieniając zwierzęta z bankiem.';

  @override
  String get blocksFox => 'Blokuje Lisa';

  @override
  String get blocksWolf => 'Blokuje Wilka';

  @override
  String costLabel(String cost) {
    return 'Koszt: $cost';
  }

  @override
  String get tutorialAttacksTitle => 'Ataki Drapieżników';

  @override
  String get tutorialAttacksDesc =>
      'Uważaj! Wyrzucenie drapieżnika może zrujnować twoją farmę.';

  @override
  String get foxAttackTitle => 'Atak Lisa';

  @override
  String get wolfAttackTitle => 'Atak Wilka';

  @override
  String get foxEffect => 'Kradnie WSZYSTKIE twoje króliki';

  @override
  String get wolfEffect => 'Kradnie wszystko oprócz koni';

  @override
  String get smallDogSavesRabbits => 'Mały Pies ratuje twoje króliki';

  @override
  String get bigDogSavesHerd => 'Duży Pies ratuje twoje stado';

  @override
  String get simulateAttack => 'Symuluj Atak!';

  @override
  String get tutorialWinTitle => 'Jak Wygrać';

  @override
  String get tutorialWinDesc =>
      'Bądź pierwszym graczem, który zbierze po jednym z KAŻDEGO zwierzęcia hodowlanego. Psy nie liczą się do wygranej.';

  @override
  String get collectOneOfEach => 'Zbierz po jednym z każdego:';

  @override
  String get firstToWin => 'Pierwszy, który skompletuje zestaw, wygrywa!';

  @override
  String get next => 'Dalej';

  @override
  String get gotIt => 'Rozumiem!';

  @override
  String get skip => 'Pomiń';

  @override
  String get close => 'Zamknij';

  @override
  String get exchangeRabbitsForSheep => '6 Królików = 1 Owca';

  @override
  String get exchangeSheepForPig => '2 Owce = 1 Świnia';

  @override
  String get exchangePigsForCow => '3 Świnie = 1 Krowa';

  @override
  String get exchangeCowsForHorse => '2 Krowy = 1 Koń';

  @override
  String get buyWithLamb => 'Kup za 1 Owcę';

  @override
  String get buyWithCow => 'Kup za 1 Krowę';

  @override
  String get notEnoughAnimals => 'Za mało zwierząt';

  @override
  String get animalRabbit => 'Królik';

  @override
  String get animalLamb => 'Owca';

  @override
  String get animalPig => 'Świnia';

  @override
  String get animalCow => 'Krowa';

  @override
  String get animalHorse => 'Koń';

  @override
  String get animalSmallDog => 'Mały Pies';

  @override
  String get animalBigDog => 'Duży Pies';

  @override
  String get animalFox => 'Lis';

  @override
  String get animalWolf => 'Wilk';

  @override
  String get achievementFirstFarm => 'Pierwsza Farma';

  @override
  String get achievementFirstFarmDesc => 'Wygraj swoją pierwszą grę';

  @override
  String get achievementSpeedFarmer => 'Szybki Farmer';

  @override
  String get achievementSpeedFarmerDesc => 'Wygraj w mniej niż 15 tur';

  @override
  String get achievementHorseWhisperer => 'Zaklinacz Koni';

  @override
  String get achievementHorseWhispererDesc => 'Wygraj z 3+ końmi';

  @override
  String get achievementDogLover => 'Miłośnik Psów';

  @override
  String get achievementDogLoverDesc => 'Posiadaj oba psy jednocześnie';

  @override
  String get achievementSurvivor => 'Ocalały';

  @override
  String get achievementSurvivorDesc => 'Przetrwaj 3 ataki wilka w jednej grze';

  @override
  String get achievementFoxOutsmarted => 'Przechytrzony Lis';

  @override
  String get achievementFoxOutsmartedDesc =>
      'Zablokuj 5 ataków lisa łącznie (we wszystkich grach)';

  @override
  String get achievementFullBarn => 'Pełna Stodoła';

  @override
  String get achievementFullBarnDesc => 'Posiadaj 10+ każdego zwierzęcia naraz';

  @override
  String get achievementUnderdog => 'Faworyt z Cienia';

  @override
  String get achievementUnderdogDesc =>
      'Wygraj będąc ostatnim (najniższy % w turze 20+)';

  @override
  String get achievementFarmerPro => 'Farmer Pro';

  @override
  String get achievementFarmerProDesc => 'Wygraj 50 gier';

  @override
  String get achievementLuckyRoller => 'Szczęściarz';

  @override
  String get achievementLuckyRollerDesc => 'Wyrzuć podwójnego konia';

  @override
  String get aiEasy => 'Łatwy';

  @override
  String get aiEasyDesc => 'Losowe ruchy';

  @override
  String get aiMedium => 'Średni';

  @override
  String get aiMediumDesc => 'Sprytne wymiany i psy';

  @override
  String get aiHard => 'Trudny';

  @override
  String get aiHardDesc => 'Optymalna strategia';

  @override
  String nNewAnimals(int count, String animal) {
    return '$count $animal';
  }

  @override
  String get replays => 'Powtórki';

  @override
  String get importReplay => 'Importuj Powtórkę';

  @override
  String get pasteReplayJson => 'Wklej JSON powtórki tutaj...';

  @override
  String get replayImported => 'Powtórka zaimportowana pomyślnie';

  @override
  String get replayImportError => 'Nieprawidłowe dane powtórki';

  @override
  String get import_ => 'Importuj';

  @override
  String get noReplaysYet => 'Brak powtórek';

  @override
  String get noReplaysYetSubtitle => 'Rozegraj grę, aby nagrać powtórkę.';

  @override
  String get watchReplay => 'Obejrzyj Powtórkę';

  @override
  String get exportReplay => 'Eksportuj Powtórkę';

  @override
  String get deleteReplay => 'Usuń Powtórkę';

  @override
  String get replayCopied => 'Powtórka skopiowana do schowka';

  @override
  String get deleteReplayConfirm =>
      'Spowoduje to trwałe usunięcie tej powtórki. Kontynuować?';

  @override
  String get delete => 'Usuń';

  @override
  String get replayViewer => 'Przeglądarka Powtórek';

  @override
  String turnOfTotal(int current, int total) {
    return 'Tura $current z $total';
  }

  @override
  String turnN(int n) {
    return 'Tura $n';
  }

  @override
  String get bred => 'Wyhodowane';

  @override
  String get lostLabel => 'Stracone';

  @override
  String get traded => 'Wymienione';

  @override
  String get speed => 'Prędkość';

  @override
  String get navHome => 'Start';

  @override
  String get navGame => 'Gra';

  @override
  String get navRules => 'Zasady';

  @override
  String get navStats => 'Statystyki';
}
