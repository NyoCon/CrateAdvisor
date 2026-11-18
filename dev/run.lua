-- Dev harness: loads the addon with a small mock of the WoW API and prints the tooltip lines for a
-- few crates. Catches Lua errors and shows the layout as text.
--
--     luajit dev/run.lua            (from the addon folder; LOCALE=enUS for English)
--
-- WoW only loads the files listed in the TOC, so this folder is ignored in game.

local ADDON = "CrateAdvisor"
local ns = {}

local auction = {
    [4339] = 2400, [4236] = 9500,                          -- Bolt of Mageweave, Cured Heavy Hide
    [3820] = 60, [2453] = 45, [3355] = 80, [3369] = 30,     -- journeyman herbs, Kingsblood missing
    [11137] = 1200, [11135] = 5500, [11177] = 4000, [11178] = 15000,
}
local ages = { [4339] = 1, [4236] = 6, [3820] = 0, [2453] = 0, [3355] = 2, [11137] = 1, [11135] = 1, [11177] = 1 }
local owned = { [4339] = 12, [3369] = 3 }
local withAuctionator = os.getenv("NO_AUCTIONATOR") == nil
local withSyndicator = os.getenv("NO_SYNDICATOR") == nil
local elsewhere = {   -- Syndicator: itemID -> characters, guild bank, warband bank
    [4236] = { chars = { { "Banka", 0, 2, 0 }, { "Ryzer", 1, 0, 0 } } },
    [4339] = { chars = { { "Ryzer", 12, 0, 0 }, { "Banka", 0, 30, 0 }, { "Twink", 0, 0, 5 }, { "Alt", 1, 0, 0 } }, warband = 3 },
    [3369] = { chars = { { "Ryzer", 3, 0, 0 } }, guild = 40 },
}

function GetLocale() return os.getenv("LOCALE") or "deDE" end
issecretvalue = function() return false end
C_Item = {
    GetItemNameByID = function() return nil end,
    GetItemIconByID = function() return 134400 end,
    GetItemCount = function(id) return owned[id] or 0 end,
    RequestLoadItemDataByID = function() end,
}
GetMoneyString = function(c)
    local g, s, k = math.floor(c / 10000), math.floor(c / 100) % 100, c % 100
    local out = {}
    if g > 0 then out[#out + 1] = g .. "g" end
    if s > 0 then out[#out + 1] = s .. "s" end
    if k > 0 or #out == 0 then out[#out + 1] = k .. "c" end
    return table.concat(out, " ")
end
if withAuctionator then
    Auctionator = { API = { v1 = {
        GetAuctionPriceByItemID = function(_, id) return auction[id] end,
        GetAuctionAgeByItemID = function(_, id) return ages[id] end,
    } } }
end
if withSyndicator then
    Syndicator = { API = { GetInventoryInfoByItemID = function(id, sameRealm, sameFaction)
        assert(sameRealm == true and sameFaction == true)
        local e = elsewhere[id] or { chars = {} }
        local r = { characters = {}, guilds = {}, warband = { e.warband or 0 } }
        for _, c in ipairs(e.chars) do
            r.characters[#r.characters + 1] = { character = c[1], bags = c[2], bank = c[3], mail = c[4], equipped = 0, auctions = 7 }
        end
        if e.guild then r.guilds[1] = { guild = "Gilde", bank = e.guild } end
        return r
    end } }
end
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) print("[chat] " .. m) end }
SlashCmdList = {}
local handlers = {}
function CreateFrame()
    return {
        RegisterEvent = function() end,
        SetScript = function(_, _, fn) handlers[#handlers + 1] = fn end,
    }
end

local Tooltip = {}
Tooltip.__index = Tooltip
function Tooltip.new(id) return setmetatable({ lines = {}, id = id }, Tooltip) end
function Tooltip:AddLine(t) self.lines[#self.lines + 1] = t end
function Tooltip:AddDoubleLine(l, r) self.lines[#self.lines + 1] = string.format("%-80s %s", l, r) end
function Tooltip:GetItem() return "Crate", "|Hitem:" .. self.id .. "|h" end
function Tooltip:Show() end
local hook
TooltipDataProcessor = { AddTooltipPostCall = function(_, fn) hook = fn end }
Enum = { TooltipDataType = { Item = 0 } }

-- ------------------------------------------------------------------ load

local toc = assert(io.open(ADDON .. ".toc")):read("*a")
for file in toc:gmatch("\n([^#\n][^\n]*%.lua)") do
    local chunk = assert(loadfile((file:gsub("\\", "/"))))
    chunk(ADDON, ns)
end
for _, h in ipairs(handlers) do h(nil, "ADDON_LOADED", ADDON) end
for _, h in ipairs(handlers) do h(nil, "PLAYER_LOGIN") end

local function Strip(s)
    return (s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T[^|]*|t", "[i]"))
end

for _, id in ipairs({ 248708, 248686, 248694, 248712, 1234 }) do
    GameTooltip = Tooltip.new(id)
    hook(GameTooltip, { id = id })
    print(("== %d (%d lines)"):format(id, #GameTooltip.lines))
    for _, line in ipairs(GameTooltip.lines) do print(Strip(line)) end
end
if ns.tooltip.lastError then error(ns.tooltip.lastError) end

SlashCmdList.CRATEADVISOR("status")
