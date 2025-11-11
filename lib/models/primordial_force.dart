enum PrimordialForce {
  chaos,
  gaia,
  nyx,
  erebus;

  String get displayName {
    switch (this) {
      case PrimordialForce.chaos:
        return 'Chaos';
      case PrimordialForce.gaia:
        return 'Gaia';
      case PrimordialForce.nyx:
        return 'Nyx';
      case PrimordialForce.erebus:
        return 'Erebus';
    }
  }

  String get description {
    switch (this) {
      case PrimordialForce.chaos:
        return 'Active Play - Click Power';
      case PrimordialForce.gaia:
        return 'Building Production & Efficiency';
      case PrimordialForce.nyx:
        return 'Offline Progression & Time';
      case PrimordialForce.erebus:
        return 'Tier 2 Resources & Wealth';
    }
  }

  String get icon {
    switch (this) {
      case PrimordialForce.chaos:
        return '⚡';
      case PrimordialForce.gaia:
        return '🌿';
      case PrimordialForce.nyx:
        return '🌙';
      case PrimordialForce.erebus:
        return '💎';
    }
  }
}
