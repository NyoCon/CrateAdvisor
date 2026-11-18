-- Settings page under Esc > Options > AddOns (Blizzard's Settings API).
-- Values live in CrateAdvisorDB (ns.db) and are read on every tooltip, so changes apply at once.

local ADDON, ns = ...

local L = ns.L
local O = {}
ns.options = O

-- Called once the saved variables are loaded (ADDON_LOADED).
function O.Register()
    if not (Settings and Settings.RegisterVerticalLayoutCategory and Settings.RegisterAddOnSetting) then return end
    local db = ns.db
    local category, layout = Settings.RegisterVerticalLayoutCategory("CrateAdvisor")

    if layout and CreateSettingsListSectionHeaderInitializer then
        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["Tooltip"]))
    end

    local enabled = Settings.RegisterAddOnSetting(category, "CrateAdvisor_enabled", "enabled", db,
        Settings.VarType.Boolean, L["Show in item tooltips"], true)
    Settings.CreateCheckbox(category, enabled,
        L["The packages of a Waylaid Crate with their auction house prices, the cheapest one and your stock."])

    local detailsKey = Settings.RegisterAddOnSetting(category, "CrateAdvisor_detailsKey", "detailsKey", db,
        Settings.VarType.String, L["Modifier key for details"], "none")
    local function KeyOptions()
        local container = Settings.CreateControlTextContainer()
        for _, key in ipairs(ns.tooltip.KEYS) do
            container:Add(key, L[ns.tooltip.KEY_NAMES[key]])
        end
        return container:GetData()
    end
    Settings.CreateDropdown(category, detailsKey, KeyOptions,
        L["None: the details are always shown. Otherwise unit prices, price age, owned amounts and where they lie only while that key is held; packages, totals and recommendation are always shown."])

    Settings.RegisterAddOnCategory(category)
    O.category = category
end

function O.Open()
    if O.category and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(O.category:GetID())
        return true
    end
    return false
end
