# CrateAdvisor

Tooltip addon for World of Warcraft Forever (Interface 16001). On every **Waylaid Crate**
(*Abgefangene Kiste*) it lists the material packages that fill the crate with what each one costs
at the auction house, cheapest first, names the cheapest package and shows which materials you
already own on any of your characters.

```
Füllung zu Auktionshauspreisen
  2x  Geschmeidiger schwerer Balg ✓ (à 95s, 6 Tage alt, vorhanden 3)   1g 90s
      Banka 2, Ryzer 1
  8x  Magiestoffballen ✓ (à 24s, vorhanden 51)                          1g 92s
      Banka 30, Ryzer 12, Twink 5, …
» Am günstigsten: Geschmeidiger schwerer Balg (2s günstiger als Magiestoffballen)
✓ Vorrätig: Geschmeidiger schwerer Balg (Banka 2, Ryzer 1)
```

- price per unit and total per package (Auctionator's latest scan, no auction house cut since you buy)
- age note when the price is 3 or more days old (or over 3 weeks)
- how many you already own, ✓ when that is enough for the package, and where (up to 3 places);
  with [Syndicator](https://www.curseforge.com/wow/addons/syndicator) across all characters of the
  connected realm and faction (bags, bank, mail), guild banks and the warband bank — without it
  only the current character's bags and bank
- `Vorrätig`: the cheapest package you could fill from stock
- packages without a price come last; the recommendation then says `prices missing`

Prices come from [Auctionator](https://www.curseforge.com/wow/addons/auctionator), stock from
Syndicator (both optional). Equipped items and running auctions do not count as stock.

## Usage

Install, `/reload`, hover over a crate.

- `/cadv on|off` – tooltip lines on or off
- `/cadv status` – status and the last tooltip error

## How it works

The client does not know the packages as item IDs: a crate's use spell has one dummy effect per
package whose base points are the amount, and its description names the material
(`- $M3 Bolt of Mageweave`). `tools/update_data.py` reads the Forever client tables (Spell,
SpellEffect, ItemEffect, ItemXItemEffect, ItemSparse) from wago.tools, resolves the English names
to item IDs and writes `Data/Crates.lua`. Rerun it when Forever adds or changes crates:

    python3 tools/update_data.py [build]

Test without the game: `luajit dev/run.lua` (`LOCALE=enUS`, `NO_AUCTIONATOR=1`, `NO_SYNDICATOR=1` for variants).
