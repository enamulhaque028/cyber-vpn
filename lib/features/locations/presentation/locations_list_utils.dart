import 'package:cyber_vpn/features/locations/domain/entities/vpn_location.dart';

/// Sort by ping ascending; unprobed / failed last, then by place name.
List<VpnLocation> sortByPing(
  List<VpnLocation> items,
  Map<int, int?> rttMs,
) {
  final copy = List<VpnLocation>.from(items);
  copy.sort((a, b) {
    final pa = rttMs[a.id];
    final pb = rttMs[b.id];
    if (pa != null && pb != null) return pa.compareTo(pb);
    if (pa != null) return -1;
    if (pb != null) return 1;
    return a.placeName.toLowerCase().compareTo(b.placeName.toLowerCase());
  });
  return copy;
}

/// Group locations by country; keys sorted alphabetically.
Map<String, List<VpnLocation>> groupByCountry(
  List<VpnLocation> items,
  Map<int, int?> rttMs,
) {
  final map = <String, List<VpnLocation>>{};
  for (final loc in items) {
    map.putIfAbsent(loc.country, () => []).add(loc);
  }
  for (final list in map.values) {
    list.sort((a, b) {
      final pa = rttMs[a.id];
      final pb = rttMs[b.id];
      if (pa != null && pb != null) return pa.compareTo(pb);
      if (pa != null) return -1;
      if (pb != null) return 1;
      return a.placeName.toLowerCase().compareTo(b.placeName.toLowerCase());
    });
  }
  final keys = map.keys.toList()..sort((a, b) => a.compareTo(b));
  return {for (final k in keys) k: map[k]!};
}

int countCountries(List<VpnLocation> items) {
  return items.map((l) => l.country).toSet().length;
}

/// Client-side filter for Favorites / Recent tabs.
List<VpnLocation> filterLocations(List<VpnLocation> items, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return items;
  return items.where((l) {
    return l.country.toLowerCase().contains(q) ||
        l.region.toLowerCase().contains(q) ||
        l.city.toLowerCase().contains(q) ||
        l.title.toLowerCase().contains(q) ||
        l.placeName.toLowerCase().contains(q);
  }).toList();
}

String? flagUrlForCountry(List<VpnLocation> items, String country) {
  for (final loc in items) {
    if (loc.country == country && loc.flagUrl.isNotEmpty) {
      return loc.flagUrl;
    }
  }
  return null;
}
