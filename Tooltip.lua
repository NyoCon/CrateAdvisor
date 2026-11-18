-- Tooltip lines on a Waylaid Crate: the cost of each package at the auction house, cheapest first.

local _, ns = ...

local T = {}
ns.tooltip = T

local L = ns.L

local GOLD = { 1, 0.82, 0 }
local TEXT = { 0.9, 0.9, 0.9 }
local DIM = { 0.6, 0.6, 0.6 }
local GOOD = { 0.3, 1, 0.3 }
local WARN = { 1, 0.6, 0.2 }

local OLD_DAYS = 3   -- prices from this many days ago on get an age note
local READY = "|TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"

local NameByID = C_Item and C_Item.GetItemNameByID
local IconByID = (C_Item and C_Item.GetItemIconByID) or _G.GetItemIcon
local CountByID = (C_Item and C_Item.GetItemCount) or _G.GetItemCount

T.lastError = nil   -- last error while writing a tooltip, for /cadv

-- Amounts of a gold or more are rounded to whole silver
function T.Money(copper)
    copper = math.floor((copper or 0) + 0.5)
    if copper >= 10000 then copper = math.floor(copper / 100 + 0.5) * 100 end
    if GetMoneyString then return GetMoneyString(copper, true) end
    return string.format("%dg %ds %dc", math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100)
end
local Money = T.Money

local function Name(option)
    return (NameByID and NameByID(option.itemID)) or option.name
end

-- Owned in bags and bank, or nil if the game does not tell
local function Owned(itemID)
    if not CountByID then return nil end
    local ok, count = pcall(CountByID, itemID, true)
    if ok and type(count) == "number" then return count end
    return nil
end

-- The crate's packages with prices, cheapest first (packages without a price last).
-- nil if the item is not a crate.
function T.Evaluate(crateID)
    local packages = ns.crates[crateID]
    if not packages then return nil end
    local options = {}
    for index, p in ipairs(packages) do
        local itemID, amount = p[1], p[2]
        local unit = ns.prices.ByID(itemID)
        options[#options + 1] = {
            index = index,
            itemID = itemID,
            amount = amount,
            name = p[3],
            unit = unit,
            total = unit and unit * amount,
            age = unit and ns.prices.AgeByID(itemID),
            owned = Owned(itemID),
        }
    end
    table.sort(options, function(a, b)
        if (a.total ~= nil) ~= (b.total ~= nil) then return a.total ~= nil end
        if a.total and a.total ~= b.total then return a.total < b.total end
        return a.index < b.index
    end)
    local priced = 0
    for _, o in ipairs(options) do
        if o.total then priced = priced + 1 end
    end
    return { options = options, priced = priced, best = priced > 0 and options[1] or nil }
end

local function Note(o)
    local notes = {}
    if o.unit then
        notes[#notes + 1] = L["each"] .. " " .. Money(o.unit)
        if o.age == nil then
            notes[#notes + 1] = L["over 3 weeks old"]
        elseif o.age >= OLD_DAYS then
            notes[#notes + 1] = string.format(L["%d days old"], o.age)
        end
    end
    if o.owned and o.owned > 0 then notes[#notes + 1] = string.format(L["you have %d"], o.owned) end
    if #notes == 0 then return "" end
    return " |cff999999(" .. table.concat(notes, ", ") .. ")|r"
end

-- "Cheapest: Bolt of Mageweave (1g 90s cheaper than Cured Heavy Hide)"
function T.RecommendationText(e)
    local best = e.best
    local runnerUp = e.priced > 1 and e.options[2] or nil
    local notes = {}
    if runnerUp then
        notes[#notes + 1] = string.format(L["%s cheaper than %s"], Money(runnerUp.total - best.total), Name(runnerUp))
    elseif #e.options > 1 then
        notes[#notes + 1] = L["only option with a price"]
    end
    if e.priced < #e.options and runnerUp then notes[#notes + 1] = L["prices missing"] end
    local text = string.format(L["Cheapest: %s"], Name(best))
    if #notes > 0 then text = text .. " (" .. table.concat(notes, ", ") .. ")" end
    return text
end

-- Adds the lines; returns true if anything was added.
function T.AddLines(tooltip, crateID)
    local e = T.Evaluate(crateID)
    if not e then return false end

    tooltip:AddLine(" ")
    tooltip:AddLine(L["Filling at auction house prices"], GOLD[1], GOLD[2], GOLD[3])
    for _, o in ipairs(e.options) do
        local color = (o == e.best) and GOOD or TEXT
        local icon = IconByID and IconByID(o.itemID)
        local ready = (o.owned and o.owned >= o.amount) and (" " .. READY) or ""
        local left = string.format("  %dx %s%s%s%s", o.amount, icon and ("|T" .. icon .. ":0|t ") or "",
            Name(o), ready, Note(o))
        local right = o.total and Money(o.total) or ("|cff999999" .. L["no price"] .. "|r")
        tooltip:AddDoubleLine(left, right, color[1], color[2], color[3], color[1], color[2], color[3])
    end

    if not ns.prices.Available() then
        tooltip:AddLine(L["Install Auctionator for prices"], DIM[1], DIM[2], DIM[3])
    elseif not e.best then
        tooltip:AddLine(L["No prices for any package"], WARN[1], WARN[2], WARN[3])
    elseif #e.options > 1 then
        local color = e.priced < #e.options and WARN or GOOD
        tooltip:AddLine("» " .. T.RecommendationText(e), color[1], color[2], color[3], true)
    end
    return true
end

-- ---------------------------------------------------------------- hooks

local function Secret(value)
    return issecretvalue and issecretvalue(value)
end

local function ItemID(tooltip, data)
    if data and type(data.id) == "number" and not Secret(data.id) then return data.id end
    local _, link = tooltip:GetItem()
    if not link or Secret(link) then return nil end
    return tonumber(link:match("item:(%d+)"))
end

local function OnItemTooltip(tooltip, data)
    if not ns.db or not ns.db.enabled then return end
    if tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip then return end

    local ok, err = pcall(function()
        local itemID = ItemID(tooltip, data)
        if itemID and ns.crates[itemID] and T.AddLines(tooltip, itemID) then tooltip:Show() end
    end)
    if not ok then T.lastError = err end
end

function T.Hook()
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnItemTooltip)
    else
        for _, tooltip in ipairs({ GameTooltip, ItemRefTooltip }) do
            tooltip:HookScript("OnTooltipSetItem", function(self) OnItemTooltip(self) end)
        end
    end
end
