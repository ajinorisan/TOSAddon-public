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
    addon:RegisterMsg("OPEN_DLG_MARKET", "market_watcher_start");
    frame = ui.GetFrame("market_watcher")
    -- frame:RunUpdateScript("market_watcher_get_itemlist", 10);
end

function market_watcher_start()
    local frame = ui.GetFrame("market")
    local timer = frame:CreateOrGetControl("timer", "addontimer", 10, 10);
    AUTO_CAST(timer);
    timer:Stop();
    timer:SetUpdateScript("market_watcher_search_item");
    timer:Start(10);

    if g.settings.iesid ~= nil then
        print("test2")
        local slot = frame:CreateOrGetControl("slot", "slot", 620, 100, 50, 50);
        AUTO_CAST(slot)
        slot:SetSkinName("invenslot2")
        slot:EnablePop(0)
        slot:EnableDrag(0)
        slot:EnableDrop(0)
        local itemCls = GetClassByType('Item', g.settings.clsid);
        local imageName = GET_ITEM_ICON_IMAGE(itemCls);
        print(imageName)
        SET_SLOT_IMG(slot, imageName);
        SET_SLOT_IESID(slot, g.settings.iesid);
    end
end

function market_watcher_search_item(frame, ctrl, argStr, argNum)

    local market_search = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet');

    if market_search ~= nil and market_search:IsVisible() == 1 then

        local searchEdit = GET_CHILD_RECURSIVELY(market_search, 'searchEdit');
        searchEdit:Focus()
        searchEdit:SetText(g.settings.search)
        MARKET_FIND_PAGE(frame, 0);
        market_watcher_get_itemlist(frame)

    end
end

function market_watcher_get_itemlist(frame)
    local market = {}

    local frame = ui.GetFrame("market")
    local category, _category, _subCategory = GET_CATEGORY_STRING(frame);
    local itemCntPerPage = GET_MARKET_SEARCH_ITEM_COUNT(_category);
    local maxPage = math.ceil(session.market.GetTotalCount() / itemCntPerPage);
    local curPage = session.market.GetCurPage();
    -- print(maxPage)
    local gbox = GET_CHILD_RECURSIVELY(frame, "itemListGbox")
    local count = gbox:GetChildCount()
    -- print(count .. "a")
    -- for j = 0, maxPage - 1 do
    -- MARKET_FIND_PAGE(frame, j);
    -- local count = session.market.GetItemCount()
    if count == 0 then
        market_watcher_get_itemlist(frame)
        return
    end
    for j = 0, maxPage - 1 do
        MARKET_FIND_PAGE(frame, j)
        gbox = GET_CHILD_RECURSIVELY(frame, "itemListGbox")
        count = gbox:GetChildCount()
        -- print(count .. "a")
        for i = 0, count - 1 do
            print("test")
            local marketItem = session.market.GetItemByIndex(i);
            if marketItem ~= nil then

                local market_iesid = marketItem:GetMarketGuid()

                if market_iesid ~= g.settings.iesid then

                    local frame = ui.GetFrame("market")
                    local market_search = GET_CHILD_RECURSIVELY(frame, 'itemSearchSet');
                    local searchEdit = GET_CHILD_RECURSIVELY(market_search, 'searchEdit');
                    searchEdit:Focus()
                    searchEdit:SetText("")
                else
                    imcSound.PlayMusicQueueLocal('colonywar_win')
                    local msg = "買いたい商品出品されてるで！！"
                    market_watcher_NICO_CHAT(string.format("{@st55_a}%s", msg))
                end
            end

        end
    end
end
function market_watcher_NICO_CHAT(msg)

    local x = ui.GetClientInitialWidth();
    local factor;
    if IMCRandom(0, 1) == 1 then
        factor = IMCRandomFloat(0.05, 0.4);
    else
        factor = IMCRandomFloat(0.6, 0.9);
    end

    local y = ui.GetClientInitialHeight() * factor;
    local spd = -IMCRandom(150, 200);

    local frame = ui.GetFrame("nico_chat");
    change_client_size(frame)
    local name = UI_EFFECT_GET_NAME(frame, "NICO_");
    local ctrl = frame:CreateControl("richtext", name, x, y, 200, 20);

    frame:ShowWindow(1);
    frame:SetLayerLevel(999)
    ctrl = tolua.cast(ctrl, "ui::CRichText");
    ctrl:EnableResizeByText(1);
    ctrl:SetText("{@st64}" .. msg);
    ctrl:RunUpdateScript("NICO_MOVING");
    ctrl:SetUserValue("NICO_SPD", spd);
    ctrl:SetUserValue("NICO_START_X", x);
    ctrl:ShowWindow(1);
    frame:RunUpdateScript("INVALIDATE_NICO");
end

--[[ print(tostring(marketItem:GetMarketGuid()))
        local iesid = tostring(marketItem:GetIESID())

        local marketItem = session.market.GetItemByIndex(i);
        -- print(g.settings.iesid)
        local saveobj = GetObjectByGuid(g.settings.iesid);
        -- print(tostring(saveobj.ClassID))
        local itemObj = GetIES(marketItem:GetObject());

        -- local iesid = tostring(marketItem:GetIESID())

        -- print(tostring(GET_FULL_NAME(itemObj)))
        table.insert(market, itemObj)]]

function market_watcher_SLI(frame, msg)
    local props, clsID = acutil.getEventArgs(msg)
    local linkInfo = session.link.CreateOrGetGCLinkObject(clsID, props)
    local newobj = GetIES(linkInfo:GetObject())
    local itemObj = GetIES(linkInfo:GetObject())
    local itemName = GET_FULL_NAME(newobj);
    if TryGetProp(newobj, 'ClassType', 'None') == 'Earring' then
        local rune_grade = shared_item_earring.get_earring_grade(newobj)

        itemName = itemName .. '(' .. rune_grade .. ClMsg('Grade') .. ')'
        print(itemName)
        for i = 1, shared_item_earring.get_max_special_option_count(TryGetProp(itemObj, 'ItemLv', 0)) do
            local ctrl = TryGetProp(itemObj, 'EarringSpecialOption_' .. i, 'None')
            if ctrl ~= 'None' then
                local cls = GetClass('Job', ctrl)
                local ctrl = TryGetProp(cls, 'Name', 'None')
                print(ctrl)
                local rank = TryGetProp(itemObj, 'EarringSpecialOptionRankValue_' .. i, 0)
                local lv = TryGetProp(itemObj, 'EarringSpecialOptionLevelValue_' .. i, 0)
                local text = ScpArgMsg('EarringSpecialOption{ctrl}{rank}{lv}', 'ctrl', ctrl, 'rank', rank, 'lv', lv)
                print(text)
            end
        end
    end

    local fullName = dictionary.ReplaceDicIDInCompStr(itemName)
    print(fullName)
    local truncatedName = string.sub(fullName, 1, 75)

    local iesid = GetIESID(newobj)
    g.settings.iesid = iesid
    g.settings.search = truncatedName
    g.settings.clsid = clsID
    market_watcher_save_settings()

end

function market_watcher_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function market_watcher_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if not settings then

        settings = {}

    end

    g.settings = settings
end
