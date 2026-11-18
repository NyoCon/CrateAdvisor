-- What you already own of a material: from Syndicator across all characters (bags, bank, mail),
-- guild banks and the warband bank; without Syndicator only the current character (bags + bank).

local _, ns = ...

local S = {}
ns.stock = S

local L = ns.L

local CountByID = (C_Item and C_Item.GetItemCount) or _G.GetItemCount

local function API()
    return Syndicator and Syndicator.API
end

function S.Available()
    local api = API()
    return api ~= nil and type(api.GetInventoryInfoByItemID) == "function"
end

local function Own(itemID)
    if not CountByID then return 0 end
    local ok, count = pcall(CountByID, itemID, true)
    if ok and type(count) == "number" then return count end
    return 0
end

-- Total count and the places that hold it: { name, count } sorted by count, or nil without
-- Syndicator. Only the current connected realm and faction: what can be mailed over.
function S.Get(itemID)
    if not S.Available() then return Own(itemID), nil end
    local ok, info = pcall(Syndicator.API.GetInventoryInfoByItemID, itemID, true, true)
    if not ok or type(info) ~= "table" then return Own(itemID), nil end

    local places, total = {}, 0
    local function Add(name, count)
        if count and count > 0 then
            places[#places + 1] = { name = name, count = count }
            total = total + count
        end
    end
    for _, c in ipairs(info.characters or {}) do
        -- equipped, void storage and running auctions cannot go into a crate
        Add(c.character, (c.bags or 0) + (c.bank or 0) + (c.mail or 0))
    end
    for _, g in ipairs(info.guilds or {}) do
        Add("<" .. g.guild .. ">", g.bank)
    end
    Add(L["Warband bank"], info.warband and info.warband[1])
    table.sort(places, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        return a.name < b.name
    end)
    return total, places
end

-- "Banka 30, Ryzer 5, Warband bank 2" (at most `limit` places)
function S.PlacesText(places, limit)
    local parts = {}
    for i, p in ipairs(places) do
        if i > limit then
            parts[#parts + 1] = "…"
            break
        end
        parts[#parts + 1] = p.name .. " " .. p.count
    end
    return table.concat(parts, ", ")
end
