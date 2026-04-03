import 'package:flutter/material.dart';
import '../models/animal.dart';
import '../models/dice.dart';
import 'app_localizations.dart';

/// Returns the localized name for an [Animal].
String localizedAnimalName(BuildContext context, Animal animal) {
  final l10n = AppLocalizations.of(context)!;
  switch (animal) {
    case Animal.rabbit:
      return l10n.animalRabbit;
    case Animal.lamb:
      return l10n.animalLamb;
    case Animal.pig:
      return l10n.animalPig;
    case Animal.cow:
      return l10n.animalCow;
    case Animal.horse:
      return l10n.animalHorse;
    case Animal.smallDog:
      return l10n.animalSmallDog;
    case Animal.bigDog:
      return l10n.animalBigDog;
  }
}

/// Returns the localized name for a [DiceFace].
String localizedDiceFaceName(BuildContext context, DiceFace face) {
  final l10n = AppLocalizations.of(context)!;
  switch (face) {
    case DiceFace.rabbit:
      return l10n.animalRabbit;
    case DiceFace.lamb:
      return l10n.animalLamb;
    case DiceFace.pig:
      return l10n.animalPig;
    case DiceFace.cow:
      return l10n.animalCow;
    case DiceFace.horse:
      return l10n.animalHorse;
    case DiceFace.fox:
      return l10n.animalFox;
    case DiceFace.wolf:
      return l10n.animalWolf;
  }
}

/// Returns localized achievement name by id.
String localizedAchievementName(BuildContext context, String achievementId) {
  final l10n = AppLocalizations.of(context)!;
  switch (achievementId) {
    case 'firstFarm':
      return l10n.achievementFirstFarm;
    case 'speedFarmer':
      return l10n.achievementSpeedFarmer;
    case 'horseWhisperer':
      return l10n.achievementHorseWhisperer;
    case 'dogLover':
      return l10n.achievementDogLover;
    case 'survivor':
      return l10n.achievementSurvivor;
    case 'foxOutsmarted':
      return l10n.achievementFoxOutsmarted;
    case 'fullBarn':
      return l10n.achievementFullBarn;
    case 'underdog':
      return l10n.achievementUnderdog;
    case 'farmerPro':
      return l10n.achievementFarmerPro;
    case 'luckyRoller':
      return l10n.achievementLuckyRoller;
    default:
      return achievementId;
  }
}

/// Returns localized achievement description by id.
String localizedAchievementDesc(BuildContext context, String achievementId) {
  final l10n = AppLocalizations.of(context)!;
  switch (achievementId) {
    case 'firstFarm':
      return l10n.achievementFirstFarmDesc;
    case 'speedFarmer':
      return l10n.achievementSpeedFarmerDesc;
    case 'horseWhisperer':
      return l10n.achievementHorseWhispererDesc;
    case 'dogLover':
      return l10n.achievementDogLoverDesc;
    case 'survivor':
      return l10n.achievementSurvivorDesc;
    case 'foxOutsmarted':
      return l10n.achievementFoxOutsmartedDesc;
    case 'fullBarn':
      return l10n.achievementFullBarnDesc;
    case 'underdog':
      return l10n.achievementUnderdogDesc;
    case 'farmerPro':
      return l10n.achievementFarmerProDesc;
    case 'luckyRoller':
      return l10n.achievementLuckyRollerDesc;
    default:
      return achievementId;
  }
}
