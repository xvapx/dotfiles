{ default, channels }:
with default; with channels;[
  crawlTiles              # Dungeon Crawl Stone Soup, free and open source roguelike
  innoextract             # Tool to unpack installers created by Inno Setup (GOG.com)
  rogue                   # Original Rogue Game
  (steam.override {       # Digital distribution platform
    newStdcpp = true;
    withJava = true;
  })
  (steam.override {       # FHS-compatible chroot to run games
    nativeOnly = true;
    newStdcpp = true;
    withJava = true;
  }).run
]