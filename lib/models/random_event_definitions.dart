import 'package:mythical_cats/models/random_event.dart';
import 'package:mythical_cats/models/resource_type.dart';

class RandomEventDefinitions {
  static const divineCatAppears = RandomEvent(
    id: 'divine_cat',
    title: 'Divine Cat Appears!',
    description: 'A wild divine cat wanders into your domain',
    type: RandomEventType.bonus,
    bonusResources: {ResourceType.cats: 50},
  );

  static const offeringFromMortals = RandomEvent(
    id: 'mortal_offering',
    title: 'Offering from Mortals',
    description: 'Devout mortals leave offerings at your shrine',
    type: RandomEventType.bonus,
    bonusResources: {ResourceType.offerings: 100},
  );

  static const divineFavor = RandomEvent(
    id: 'divine_favor',
    title: 'Divine Favor',
    description: 'The gods smile upon you',
    type: RandomEventType.multiplier,
    multiplier: 2.0,
    duration: Duration(seconds: 30),
  );

  static const prayerCircle = RandomEvent(
    id: 'prayer_circle',
    title: 'Prayer Circle',
    description: 'Mortals gather to pray in your honor',
    type: RandomEventType.bonus,
    bonusResources: {ResourceType.prayers: 50},
  );

  static const catBlessing = RandomEvent(
    id: 'cat_blessing',
    title: 'Feline Blessing',
    description: 'A sacred cat blesses your domain with abundance',
    type: RandomEventType.bonus,
    bonusResources: {
      ResourceType.cats: 100,
      ResourceType.offerings: 50,
    },
  );

  /// All possible events
  static List<RandomEvent> get all => [
    divineCatAppears,
    offeringFromMortals,
    divineFavor,
    prayerCircle,
    catBlessing,
  ];

  /// Get random event
  static RandomEvent getRandom(DateTime seed) {
    final index = seed.millisecondsSinceEpoch % all.length;
    return all[index];
  }
}
