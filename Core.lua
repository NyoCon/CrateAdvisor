-- Settings, events and the /cadv chat command.

local ADDON, ns = ...

local L = ns.L
local PREFIX = "|cff40c040CrateAdvisor|r: "

local DEFAULTS = {
    enabled = true,
    detailsKey = "none",  -- "none" | "CTRL" | "SHIFT" | "ALT": details always or only with that key held
}

-- /cadv details <arg> -> detailsKey
local DETAILS_ARGS = { none = "none", always = "none", ctrl = "CTRL", shift = "SHIFT", alt = "ALT" }

local function Say(text, ...)
    local message = L[text]
    if select("#", ...) > 0 then message = string.format(message, ...) end
    DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. message)
end

-- Ask the client to load the material names, so the tooltip does not show English fallbacks
local function PreloadMaterials()
    if not (C_Item and C_Item.RequestLoadItemDataByID) then return end
    local seen = {}
    for _, packages in pairs(ns.crates) do
        for _, p in ipairs(packages) do
            if not seen[p[1]] then
                seen[p[1]] = true
                pcall(C_Item.RequestLoadItemDataByID, p[1])
            end
        end
    end
end

local function PrintStatus()
    local key = ns.tooltip.DetailsKey()
    Say("Tooltip: %s, details: %s, prices: %s, stock: %s", ns.db.enabled and L["on"] or L["off"],
        key == "none" and L["always"] or string.format(L["with %s"], L[ns.tooltip.KEY_NAMES[key]]),
        ns.prices.Available() and "Auctionator" or L["none (Auctionator missing)"],
        ns.stock.Available() and L["all characters (Syndicator)"] or L["this character (Syndicator missing)"])
    if ns.tooltip.lastError then
        DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. "|cffff5555" .. tostring(ns.tooltip.lastError) .. "|r")
    end
end

local function PrintHelp()
    Say("Commands:")
    Say("  /cadv - settings (Esc > Options > AddOns)")
    Say("  /cadv status - status and the last tooltip error")
    Say("  /cadv details none|ctrl|shift|alt - details always or only with that key held")
    Say("  /cadv on|off - tooltip lines on or off")
end

SLASH_CRATEADVISOR1 = "/cadv"
SLASH_CRATEADVISOR2 = "/crateadvisor"
SlashCmdList.CRATEADVISOR = function(input)
    local command, rest = (input or ""):match("^%s*(%S*)%s*(.-)%s*$")
    command, rest = (command or ""):lower(), (rest or ""):lower()
    if command == "on" or command == "off" then
        ns.db.enabled = command == "on"
        PrintStatus()
    elseif command == "details" and DETAILS_ARGS[rest] then
        ns.db.detailsKey = DETAILS_ARGS[rest]
        PrintStatus()
    elseif command == "" and ns.options.Open() then
        return
    elseif command == "" or command == "status" then
        PrintStatus()
        PrintHelp()
    else
        PrintHelp()
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("MODIFIER_STATE_CHANGED")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        CrateAdvisorDB = CrateAdvisorDB or {}
        for key, value in pairs(DEFAULTS) do
            if CrateAdvisorDB[key] == nil then CrateAdvisorDB[key] = value end
        end
        ns.db = CrateAdvisorDB
        local ok, err = pcall(ns.options.Register)
        if not ok then ns.tooltip.lastError = err end
    elseif event == "PLAYER_LOGIN" then
        ns.tooltip.Hook()
        PreloadMaterials()
    elseif event == "MODIFIER_STATE_CHANGED" then
        ns.tooltip.OnModifierChanged()
    end
end)
