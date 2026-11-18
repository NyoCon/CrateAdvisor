-- Prices from Auctionator's public API (Auctionator.API.v1).

local _, ns = ...

local P = {}
ns.prices = P

local CALLER = "CrateAdvisor"   -- Auctionator wants to know who is asking

local function API()
    return Auctionator and Auctionator.API and Auctionator.API.v1
end

function P.Available()
    return API() ~= nil
end

-- nil if the function is missing or fails
local function Call(name, ...)
    local api = API()
    local fn = api and api[name]
    if type(fn) ~= "function" then return nil end
    local ok, value = pcall(fn, CALLER, ...)
    if ok then return value end
    return nil
end

-- Auction price of one item, or nil
function P.ByID(itemID)
    local price = Call("GetAuctionPriceByItemID", itemID)
    if type(price) == "number" and price > 0 then return price end
    return nil
end

-- Days since Auctionator last saw the item, or nil if never or over 21 days ago
function P.AgeByID(itemID)
    return Call("GetAuctionAgeByItemID", itemID)
end
