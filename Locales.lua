-- Texts. The key is the English text; a missing translation shows the key.

local _, ns = ...

local L = setmetatable({}, { __index = function(_, key) return key end })
ns.L = L

local translations = {
    deDE = {
        ["Filling at auction house prices"] = "Füllung zu Auktionshauspreisen",
        ["Install Auctionator for prices"] = "Für Preise Auctionator installieren",
        ["no price"] = "kein Preis",
        ["%d days old"] = "%d Tage alt",
        ["over 3 weeks old"] = "über 3 Wochen alt",
        ["each"] = "à",
        ["you have %d"] = "vorhanden %d",
        ["In stock: %s"] = "Vorrätig: %s",
        ["Warband bank"] = "Kriegsmeute",
        ["Cheapest: %s"] = "Am günstigsten: %s",
        ["%s cheaper than %s"] = "%s günstiger als %s",
        ["only option with a price"] = "einzige Option mit Preis",
        ["prices missing"] = "Preise fehlen",
        ["No prices for any package"] = "Für kein Paket gibt es Preise",
        ["Hold %s for details"] = "%s für Details",
        -- settings page
        ["Tooltip"] = "Tooltip",
        ["Show in item tooltips"] = "Im Gegenstands-Tooltip anzeigen",
        ["The packages of a Waylaid Crate with their auction house prices, the cheapest one and your stock."] =
            "Die Pakete einer Abgefangenen Kiste mit Auktionshauspreisen, das günstigste und dein Bestand.",
        ["Modifier key for details"] = "Taste für Details",
        ["None: the details are always shown. Otherwise unit prices, price age, owned amounts and where they lie only while that key is held; packages, totals and recommendation are always shown."] =
            "Nichts: Details stehen immer da. Sonst Stückpreis, Preisalter, Bestand und wo er liegt nur bei gedrückter Taste; Pakete, Gesamtpreise und Empfehlung stehen immer da.",
        ["None"] = "Nichts",
        ["Ctrl"] = "Strg",
        -- chat
        ["Tooltip: %s, details: %s, prices: %s, stock: %s"] = "Tooltip: %s, Details: %s, Preise: %s, Bestand: %s",
        ["always"] = "immer",
        ["with %s"] = "mit %s",
        ["  /cadv - settings (Esc > Options > AddOns)"] = "  /cadv - Einstellungen (Esc > Optionen > AddOns)",
        ["  /cadv details none|ctrl|shift|alt - details always or only with that key held"] =
            "  /cadv details none|ctrl|shift|alt - Details immer oder nur bei gedrückter Taste",
        ["this character (Syndicator missing)"] = "dieser Charakter (Syndicator fehlt)",
        ["all characters (Syndicator)"] = "alle Charaktere (Syndicator)",
        ["on"] = "an",
        ["off"] = "aus",
        ["none (Auctionator missing)"] = "keine (Auctionator fehlt)",
        ["Commands:"] = "Befehle:",
        ["  /cadv on|off - tooltip lines on or off"] = "  /cadv on|off - Tooltip-Zeilen an oder aus",
        ["  /cadv status - status and the last tooltip error"] = "  /cadv status - Status und letzter Tooltip-Fehler",
    },
}

for key, value in pairs(translations[GetLocale and GetLocale() or "enUS"] or {}) do
    rawset(L, key, value)
end
