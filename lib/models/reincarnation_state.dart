import 'primordial_force.dart';

class ReincarnationState {
  final int totalPrimordialEssence;
  final int availablePrimordialEssence;
  final Set<String> ownedUpgradeIds;
  final PrimordialForce? activePatron;
  final int totalReincarnations;
  final int lifetimeCatsEarned;
  final int thisRunCatsEarned;

  const ReincarnationState({
    this.totalPrimordialEssence = 0,
    this.availablePrimordialEssence = 0,
    this.ownedUpgradeIds = const {},
    this.activePatron,
    this.totalReincarnations = 0,
    this.lifetimeCatsEarned = 0,
    this.thisRunCatsEarned = 0,
  });

  ReincarnationState copyWith({
    int? totalPrimordialEssence,
    int? availablePrimordialEssence,
    Set<String>? ownedUpgradeIds,
    PrimordialForce? activePatron,
    int? totalReincarnations,
    int? lifetimeCatsEarned,
    int? thisRunCatsEarned,
  }) {
    return ReincarnationState(
      totalPrimordialEssence:
          totalPrimordialEssence ?? this.totalPrimordialEssence,
      availablePrimordialEssence:
          availablePrimordialEssence ?? this.availablePrimordialEssence,
      ownedUpgradeIds: ownedUpgradeIds ?? this.ownedUpgradeIds,
      activePatron: activePatron ?? this.activePatron,
      totalReincarnations: totalReincarnations ?? this.totalReincarnations,
      lifetimeCatsEarned: lifetimeCatsEarned ?? this.lifetimeCatsEarned,
      thisRunCatsEarned: thisRunCatsEarned ?? this.thisRunCatsEarned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPrimordialEssence': totalPrimordialEssence,
      'availablePrimordialEssence': availablePrimordialEssence,
      'ownedUpgradeIds': ownedUpgradeIds.toList(),
      'activePatron': activePatron?.name,
      'totalReincarnations': totalReincarnations,
      'lifetimeCatsEarned': lifetimeCatsEarned,
      'thisRunCatsEarned': thisRunCatsEarned,
    };
  }

  factory ReincarnationState.fromJson(Map<String, dynamic> json) {
    return ReincarnationState(
      totalPrimordialEssence: json['totalPrimordialEssence'] as int? ?? 0,
      availablePrimordialEssence:
          json['availablePrimordialEssence'] as int? ?? 0,
      ownedUpgradeIds: (json['ownedUpgradeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      activePatron: json['activePatron'] != null
          ? PrimordialForce.values.firstWhere(
              (force) => force.name == json['activePatron'],
            )
          : null,
      totalReincarnations: json['totalReincarnations'] as int? ?? 0,
      lifetimeCatsEarned: json['lifetimeCatsEarned'] as int? ?? 0,
      thisRunCatsEarned: json['thisRunCatsEarned'] as int? ?? 0,
    );
  }
}
