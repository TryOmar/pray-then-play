"""
Batch Image Generation Script for GamerSalah App Icons.
Uses the local Samurai AI Studio SDK (ComfyUI / FLUX / SDXL)
to generate high-resolution, centered game icons and catalog them in the Studio Gallery.
"""
import sys
import os
import time

sys.path.insert(0, r"D:\Projects\image-generation")
from sdk.ai_client import ImageStudioClient

GAME_ICONS = [
    {
        "id": "valorant",
        "title": "Valorant App Icon",
        "prompt": "A modern 2D flat vector esport game icon of the Valorant V emblem, glowing crimson red and charcoal black geometric composition, centered square icon, sleek clean vector finish, dark graphite background, no 3D realism, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "league_of_legends",
        "title": "League of Legends App Icon",
        "prompt": "A modern 2D flat vector game icon of the League of Legends golden stylized L crest, glowing hextech gold and dark sapphire blue accents, centered square composition, clean vector badge, solid dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "cs2",
        "title": "Counter-Strike 2 App Icon",
        "prompt": "A modern 2D flat vector tactical game icon of Counter-Strike 2, iconic CT soldier silhouette with amber gold and tactical navy accents, centered square badge, clean vector art, dark slate background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "dota2",
        "title": "Dota 2 App Icon",
        "prompt": "A modern 2D flat vector game icon of the Dota 2 crimson stone crest emblem, glowing magma red and dark stone texture, centered square composition, clean vector icon, solid dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "overwatch2",
        "title": "Overwatch 2 App Icon",
        "prompt": "A modern 2D flat vector game icon of the Overwatch circular metallic emblem, vibrant orange and brushed silver metallic ring, centered square composition, clean vector graphic, solid dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "fortnite",
        "title": "Fortnite App Icon",
        "prompt": "A modern 2D flat vector game icon of Fortnite, bold stylized letter F emblem on a vibrant royal blue and electric purple gradient background, centered square badge, clean vector art, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "apex_legends",
        "title": "Apex Legends App Icon",
        "prompt": "A modern 2D flat vector game icon of the Apex Legends iconic red chevron A crest, intense crimson red and dark titanium accents, centered square composition, clean vector badge, solid dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "rocket_league",
        "title": "Rocket League App Icon",
        "prompt": "A modern 2D flat vector game icon of Rocket League, blue racing shield with soaring rocket car silhouette, electric cyan and royal blue glowing trails, centered square composition, clean vector badge, dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "r6_siege",
        "title": "Rainbow Six Siege App Icon",
        "prompt": "A modern 2D flat vector tactical game icon of Rainbow Six Siege, iconic number 6 with bullet crosshair in deep tactical navy blue and white, centered square composition, clean vector art, solid dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "warzone",
        "title": "Call of Duty Warzone App Icon",
        "prompt": "A modern 2D flat vector tactical game icon of Call of Duty Warzone, tactical skull and military chevron crest in military green and slate grey, centered square composition, clean vector badge, solid dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "fc24",
        "title": "EA SPORTS FC 24 App Icon",
        "prompt": "A modern 2D flat vector game icon of EA SPORTS FC 24, geometric triangle football shield in neon electric green and matte black, centered square composition, clean vector badge, dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "mlbb",
        "title": "Mobile Legends App Icon",
        "prompt": "A modern 2D flat vector moba game icon of Mobile Legends Bang Bang, golden celestial wing crest with glowing star in royal gold and deep navy blue, centered square composition, clean vector badge, dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "pubg_mobile",
        "title": "PUBG Mobile App Icon",
        "prompt": "A modern 2D flat vector battle royale game icon of PUBG, iconic level 3 spetsnaz helmet silhouette with glowing amber visor, centered square composition, clean vector badge, solid dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "minecraft",
        "title": "Minecraft App Icon",
        "prompt": "A modern 2D flat vector game icon of Minecraft, iconic isometric voxel grass and dirt block with pixel texture, centered square composition, clean vector art, solid dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "terraria",
        "title": "Terraria App Icon",
        "prompt": "A modern 2D flat vector adventure game icon of Terraria, lush green grass dirt block with a miniature bonsai tree emblem in forest emerald green and rich soil brown, centered square composition, clean vector badge, dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "stardew_valley",
        "title": "Stardew Valley App Icon",
        "prompt": "A modern 2D flat vector cozy game icon of Stardew Valley, golden starfruit and cheerful white chicken silhouette in warm golden amber and pastoral sunset colors, centered square composition, clean vector badge, dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "roblox",
        "title": "Roblox App Icon",
        "prompt": "A modern 2D flat vector game icon of Roblox, iconic tilted square silver-grey cube with square cutout hole, vibrant crimson red and charcoal dark background, centered square composition, clean vector art, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "steam",
        "title": "Steam App Icon",
        "prompt": "A modern 2D flat vector gaming platform icon of Steam, iconic mechanical piston and crankshaft logo in steam cyan blue and dark navy gradient, centered square composition, clean vector badge, dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "brawlstars",
        "title": "Brawl Stars App Icon",
        "prompt": "A modern 2D flat vector arcade game icon of Brawl Stars, iconic smiling golden skull star badge in vibrant canary yellow and electric purple, centered square composition, clean vector badge, dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    },
    {
        "id": "genshin",
        "title": "Genshin Impact App Icon",
        "prompt": "A modern 2D flat vector anime game icon of Genshin Impact, glowing anemo wind element crest with four-pointed celestial star in celestia cyan and royal gold, centered square composition, clean vector badge, dark background, no text",
        "style": "vector_icon",
        "model": "flux"
    }
]

def main():
    print("=" * 65)
    print("  GAMERSALAH - BATCH GAME ICON GENERATOR")
    print("  Powered by Samurai AI Studio & ComfyUI")
    print("=" * 65)

    client = ImageStudioClient("http://127.0.0.1:8189")
    if not client.is_healthy():
        print("[!] Studio server or ComfyUI is not online at http://127.0.0.1:8189")
        sys.exit(1)

    print(f"[+] Connected to Studio at {client.base_url}")
    print(f"[*] Starting batch generation of {len(GAME_ICONS)} game icons...\n")

    results = []
    for i, item in enumerate(GAME_ICONS, 1):
        print(f"[{i}/{len(GAME_ICONS)}] Generating '{item['title']}' ({item['id']})...")
        t0 = time.time()
        try:
            asset = client.generate(
                prompt=item["prompt"],
                model=item["model"],
                project="GamerSalah",
                category="UI & Icons",
                style=item["style"],
                aspect_ratio="1:1",
                title=item["title"],
                tags=["GamerSalah", "GameIcon", item["id"]]
            )
            dur = time.time() - t0
            print(f"    -> DONE in {dur:.2f}s | ID: {asset.id} | Path: {asset.path}")
            results.append((item['id'], asset))
        except Exception as e:
            print(f"    -> ERROR generating {item['title']}: {e}")

    print("\n" + "=" * 65)
    print(f"[+] Completed {len(results)}/{len(GAME_ICONS)} icons successfully!")
    print("  View and review all generated icons in the Studio Web Gallery:")
    print("  👉 http://127.0.0.1:8189/?project=GamerSalah")
    print("=" * 65)

if __name__ == "__main__":
    main()
