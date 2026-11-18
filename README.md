# CrateAdvisor

Tooltip addon for World of Warcraft Forever (Interface 16001). On every **Waylaid Crate**
(*Abgefangene Kiste*) it lists the material packages that fill the crate with what each one costs
at the auction house, cheapest first, and names the cheapest package.

```
Füllung zu Auktionshauspreisen
  2x  Geschmeidiger schwerer Balg (à 95s, 6 Tage alt)      1g 90s
  8x  Magiestoffballen ✓ (à 24s, du hast 12)               1g 92s
» Am günstigsten: Geschmeidiger schwerer Balg (2s günstiger als Magiestoffballen)
```

- price per unit and total per package (Auctionator's latest scan, no auction house cut since you buy)
- age note when the price is 3 or more days old (or over 3 weeks)
- how many you already own (bags + bank), ✓ when that is enough for the package
- packages without a price come last; the recommendation then says `prices missing`

Prices come from [Auctionator](https://www.curseforge.com/wow/addons/auctionator) (optional).

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

Test without the game: `luajit dev/run.lua` (`LOCALE=enUS`, `NO_AUCTIONATOR=1` for variants).
