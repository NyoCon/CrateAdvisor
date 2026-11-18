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
        ["you have %d"] = "du hast %d",
        ["Cheapest: %s"] = "Am günstigsten: %s",
        ["%s cheaper than %s"] = "%s günstiger als %s",
        ["only option with a price"] = "einzige Option mit Preis",
        ["prices missing"] = "Preise fehlen",
        ["No prices for any package"] = "Für kein Paket gibt es Preise",
        -- chat
        ["Tooltip: %s, prices: %s"] = "Tooltip: %s, Preise: %s",
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
