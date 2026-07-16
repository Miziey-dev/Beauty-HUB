/// Manual fallback list for Screen 1 (Location permission) when GPS is
/// denied or unavailable. Coordinates match the suburb centers used by
/// scripts/generate_seed.py so the demo data lines up with each choice.
class Suburb {
  final String name;
  final double lat;
  final double lng;

  const Suburb(this.name, this.lat, this.lng);
}

const List<Suburb> seededSuburbs = [
  Suburb('Braamfontein', -26.1929, 28.0305),
  Suburb('Melville', -26.1751, 28.0034),
  Suburb('Parktown', -26.1858, 28.0423),
  Suburb('Rosebank', -26.1467, 28.0436),
  Suburb('Sandton', -26.1076, 28.0567),
  Suburb('Randburg', -26.0939, 27.9769),
  Suburb('Auckland Park', -26.1809, 27.9989),
  Suburb('Yeoville', -26.1834, 28.0578),
  Suburb('Observatory', -26.1697, 28.0716),
  Suburb('Orlando, Soweto', -26.2485, 27.8540),
  Suburb('Kensington', -26.1934, 28.0959),
  Suburb('Norwood', -26.1553, 28.0748),
];
