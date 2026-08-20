import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();

  final urls = <String, String>{
    'minecraft': 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/minecraft.svg',
    'fortnite': 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/fortnite.svg',
    'roblox': 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/roblox.svg',
    'ea': 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/ea.svg',
    'ubisoft': 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/ubisoft.svg',
    'activision': 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/activision.svg',
    'riotgames': 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/riotgames.svg',
    'steam': 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/steam.svg',
  };

  for (final entry in urls.entries) {
    final key = entry.key;
    final url = entry.value;
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set('User-Agent', 'Mozilla/5.0 GamerSalahApp/1.0');
      final res = await req.close();
      if (res.statusCode == 200) {
        final svgContent = await res.transform(utf8.decoder).join();
        await File('assets/icons/$key.svg').writeAsString(svgContent);
        print('-> SimpleIcons CDN -> $key.svg OK (${svgContent.length} bytes)');
      } else {
        print('Error $key HTTP ${res.statusCode}');
      }
    } catch (e) {
      print('Error downloading $key: $e');
    }
  }

  client.close();
}
