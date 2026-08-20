import 'dart:io';

Future<void> main() async {
  final client = HttpClient();

  final icons = <String, String>{
    'valorant': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/valorant.png',
    'league': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/league-of-legends.png',
    'cs2': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/counter-strike-2.png',
    'dota': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/dota-2.png',
    'overwatch': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/overwatch-2.png',
    'apex': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/apex-legends.png',
    'rocket': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/rocket-league.png',
    'pubg': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/playerunknowns-battlegrounds.png',
    'r6': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/tom-clancys-rainbow-six-siege.png',
    'fortnite': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/fortnite.png',
    'minecraft': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/minecraft.png',
    'roblox': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/roblox.png',
    'terraria': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/terraria.png',
    'stardew': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/stardew-valley.png',
    'steam': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/steam.png',
    'ea': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/ea.png',
    'ubisoft': 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/ubisoft.png',
  };

  print('Downloading high-res full-color official icons from homarr-labs/dashboard-icons...');
  for (final entry in icons.entries) {
    final name = entry.key;
    final url = entry.value;
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set('User-Agent', 'Mozilla/5.0');
      final res = await req.close();
      if (res.statusCode == 200) {
        final bytes = await res.fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
        await File('assets/icons/$name.png').writeAsBytes(bytes);
        print('-> Full color official icon OK: $name.png (${bytes.length} bytes)');
      } else {
        print('HTTP Error ${res.statusCode} for $name ($url)');
      }
    } catch (e) {
      print('Error downloading $name: $e');
    }
  }

  client.close();
}
