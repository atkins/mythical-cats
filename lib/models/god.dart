/// The 12 Olympian gods, unlocked in sequence
enum God {
  hermes,
  hestia,
  demeter,
  dionysus,
  athena,
  apollo,
  artemis,
  ares,
  hephaestus,
  aphrodite,
  poseidon,
  zeus;

  /// Display name
  String get displayName {
    switch (this) {
      case God.hermes:
        return 'Hermes';
      case God.hestia:
        return 'Hestia';
      case God.demeter:
        return 'Demeter';
      case God.dionysus:
        return 'Dionysus';
      case God.athena:
        return 'Athena';
      case God.apollo:
        return 'Apollo';
      case God.artemis:
        return 'Artemis';
      case God.ares:
        return 'Ares';
      case God.hephaestus:
        return 'Hephaestus';
      case God.aphrodite:
        return 'Aphrodite';
      case God.poseidon:
        return 'Poseidon';
      case God.zeus:
        return 'Zeus';
    }
  }

  /// Description of the god's domain
  String get description {
    switch (this) {
      case God.hermes:
        return 'God of travelers and messengers';
      case God.hestia:
        return 'Goddess of hearth and home';
      case God.demeter:
        return 'Goddess of harvest';
      case God.dionysus:
        return 'God of celebration';
      case God.athena:
        return 'Goddess of wisdom';
      case God.apollo:
        return 'God of light and prophecy';
      case God.artemis:
        return 'Goddess of the hunt';
      case God.ares:
        return 'God of war';
      case God.hephaestus:
        return 'God of the forge';
      case God.aphrodite:
        return 'Goddess of love';
      case God.poseidon:
        return 'God of the sea';
      case God.zeus:
        return 'King of the gods';
    }
  }

  /// Cats required to unlock this god (null for starting god)
  double? get unlockRequirement {
    switch (this) {
      case God.hermes:
        return null; // Starting god
      case God.hestia:
        return 1000;
      case God.demeter:
        return 10000;
      case God.dionysus:
        return 100000;
      case God.athena:
        return 1000000;
      case God.apollo:
        return 10000000;
      case God.artemis:
        return 100000000;
      case God.ares:
        return 1000000000;
      case God.hephaestus:
        return 10000000000;
      case God.aphrodite:
        return 100000000000;
      case God.poseidon:
        return 1000000000000;
      case God.zeus:
        return 10000000000000;
    }
  }
}
