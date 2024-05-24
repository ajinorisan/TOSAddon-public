local addonName = "MARKET_WATCHER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local os = require("os")
local json = require("json")

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function MARKET_WATCHER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}
    market_watcher_load_settings()
    acutil.setupEvent(addon, "SLI", "market_watcher_SLI")

    frame = ui.GetFrame("market_watcher")
    frame:RunUpdateScript("market_watcher_get_itemlist", 10);
end

function market_watcher_SLI(frame, msg)
    local props, clsID = acutil.getEventArgs(msg);
    local linkInfo = session.link.CreateOrGetGCLinkObject(clsID, props);
    local newobj = GetIES(linkInfo:GetObject());
    local iesid = GetIESID(newobj)
end

function market_watcher_get_itemlist(frame)
    local market = {}
    local count = session.market.GetItemCount();
    for i = 0, count - 1 do
        local marketItem = session.market.GetItemByIndex(i);
        local iesid = tostring(marketItem:GetIESID())
        table.insert(market, iesid)
    end
end

function market_watcher_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if not settings then

        settings = {}

    end

    g.settings = settings
end
