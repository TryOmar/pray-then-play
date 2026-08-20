import urllib.request
import os
import io
from PIL import Image

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
    'Referer': 'https://www.google.com/'
}

URLS = {
    'valorant': [
        'https://wp.logos-download.com/wp-content/uploads/2021/01/Valorant_Logo.png?dl',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/valorant.png',
        'https://img.icons8.com/color/512/valorant.png'
    ],
    'league': [
        'https://www.rw-designer.com/icon-image/21516-256x256x32.png',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/league-of-legends.png'
    ],
    'cs2': [
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/counter-strike-2.png'
    ],
    'dota': [
        'https://img.icons8.com/color/1200/dota.jpg',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/dota-2.png'
    ],
    'overwatch': [
        'https://img.icons8.com/?size=256&id=63667&format=png',
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRe4avJEZdrC3C21PNhlq0iTZ-ZVbgTQoHyfiFbwsnwBuG-j1qXCDBIi-iB&s=10'
    ],
    'fortnite': [
        'https://upload.wikimedia.org/wikipedia/commons/7/7c/Fortnite_F_lettermark_logo.png'
    ],
    'apex': [
        'https://www.rw-designer.com/icon-image/21509-256x256x32.png',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/apex-legends.png'
    ],
    'rocket': [
        'https://www.pngkey.com/png/full/15-158249_rocket-league-logo.png',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/rocket-league.png'
    ],
    'r6': [
        'https://img.icons8.com/m_rounded/1200/rainbow-six-siege.jpg',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/rainbow-six-siege.png'
    ],
    'warzone': [
        'https://logowik.com/content/uploads/images/call-of-duty-warzone-game2635.jpg',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/call-of-duty-warzone.png'
    ],
    'fc24': [
        'https://cdn2.steamgriddb.com/icon_thumb/687338c1e79c2acc2b2bbf9fe0542e62.png',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/ea-sports-fc-24.png'
    ],
    'mlbb': [
        'https://img.icons8.com/p1em/1200/mobile-legends-bb.jpg',
        'https://img.icons8.com/color/512/mobile-legends.png'
    ],
    'pubg': [
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/pubg.png',
        'https://img.icons8.com/color/512/pubg.png'
    ],
    'minecraft': [
        'https://static.wikia.nocookie.net/logopedia/images/f/f9/Minecraft_Bedrock_icon.svg/revision/latest/scale-to-width-down/250?cb=20230924021517',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/minecraft.png'
    ],
    'terraria': [
        'https://forums.terraria.org/index.php?attachments/icon-png.280655/',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/terraria.png'
    ],
    'stardew': [
        'https://data.tooliphone.net/iskin/themes/35888/19485/preview-256.png',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/stardew-valley.png'
    ],
    'roblox': [
        'https://upload.wikimedia.org/wikipedia/commons/1/1e/Roblox_Logo_2025.png',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/roblox.png'
    ],
    'steam': [
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Steam_icon_logo.svg/960px-Steam_icon_logo.svg.png'
    ],
    'brawlstars': [
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS8GWsNkJc02q_EbZNDqP9qPw97JOQSzJxCh-4UiNcbQg&s=10',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/brawl-stars.png'
    ],
    'clash_royale': [
        'https://i.pinimg.com/736x/f0/44/83/f04483bbad609167bf64d0fd5dd7c0d8.jpg',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/clash-royale.png'
    ],
    'clash_of_clans': [
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwmsxYmyAQMFvmwgu-npkYt0Xpqtz7igPxLB-LAgMqCw&s',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/clash-of-clans.png'
    ],
    'genshin': [
        'https://static.wikia.nocookie.net/logopedia/images/4/48/Genshin_Impact_Android_Launcher_Foreground_Icon%2C_remove_Mihoyo_logo.png/revision/latest/scale-to-width-down/250?cb=20250626205605',
        'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/genshin-impact.png'
    ]
}

def process_and_save(img_bytes, target_png):
    try:
        img = Image.open(io.BytesIO(img_bytes)).convert("RGBA")
        # Crop or fit into a nice 512x512 canvas if needed
        # If it has white or solid black background on a logo from icons8/jpg, we can keep it clean or make it a square
        width, height = img.size
        # Create a transparent square canvas
        max_dim = max(width, height)
        square = Image.new("RGBA", (max_dim, max_dim), (0, 0, 0, 0))
        offset = ((max_dim - width) // 2, (max_dim - height) // 2)
        square.paste(img, offset, img)
        square = square.resize((512, 512), Image.Resampling.LANCZOS)
        square.save(target_png, "PNG")
        print(f"  -> Successfully saved {target_png} (512x512)")
        return True
    except Exception as e:
        # Fallback to direct write if not PIL readable
        print(f"  -> PIL error ({e}), writing raw bytes")
        with open(target_png, "wb") as f:
            f.write(img_bytes)
        return True

def download_game_icon(name, urls):
    target_path = f"assets/icons/{name}.png"
    for url in urls:
        try:
            print(f"Downloading {name} from {url[:70]}...")
            req = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(req, timeout=12) as resp:
                data = resp.read()
                if len(data) > 200:
                    if process_and_save(data, target_path):
                        return True
        except Exception as e:
            print(f"  Failed: {e}")
    return False

def main():
    os.makedirs("assets/icons", exist_ok=True)
    success = 0
    for name, urls in URLS.items():
        if download_game_icon(name, urls):
            success += 1
        else:
            print(f"[!] FAILED to download icon for: {name}")
    print(f"\nCompleted: {success}/{len(URLS)} game icons processed.")

if __name__ == "__main__":
    main()
