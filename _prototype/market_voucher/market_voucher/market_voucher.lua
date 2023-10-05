local addonName = "MARKET_VOUCHER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.logpath = string.format('../addons/%s/log.txt', addonNameLower)

local acutil = require("acutil")
local os = require("os")

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

if not g.settings then
    g.settings = {} -- もしg.settingsが存在しない場合、新しいテーブルを作成
end

function MARKET_SELLLIST_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    market_voucher_load_settings()

    addon:RegisterMsg("GAME_START", "market_voucher_init_frame")
    -- acutil.setupHook(market_voucher_CABINET_GET_ITEM, "CABINET_GET_ITEM")
    acutil.setupEvent(addon, "CABINET_GET_ITEM", "market_voucher_CABINET_GET_ITEM");
    acutil.setupHook(market_voucher_CABINET_GET_ALL_LIST, "CABINET_GET_ALL_LIST");
end

function market_voucher_CABINET_GET_ALL_LIST(frame, control, strarg, now)

    local frame = ui.GetFrame("market_cabinet")
    local itemGbox = GET_CHILD(frame, "itemGbox");
    local cnt = session.market.GetCabinetItemCount();
    for i = 0, cnt - 1 do
        local cabinetItem = session.market.GetCabinetItemByIndex(0);
        local itemID = cabinetItem:GetItemID();
        local itemObj = GetIES(cabinetItem:GetObject());
        -- local itemName = itemObj.ClassName
        local itemName = GET_FULL_NAME(itemObj)
        local registerTime = cabinetItem:GetRegSysTime();
        local timeString = GET_TIME_TXT(registerTime);
        local whereFrom = cabinetItem:GetWhereFrom();
        if whereFrom == "market_sell" then
            local count = 0;
            local amount = 0;
            local charName = nil;
            amount = cabinetItem.sellItemAmount;
            count = tonumber(cabinetItem:GetCount());
            charName = GETMYPCNAME();
            CHAT_SYSTEM(registerTime .. ":" .. charName .. ":" .. count .. ":" .. amount .. ":" .. count *
                            tonumber(amount))
            print(registerTime .. ":" .. charName .. ":" .. count .. ":" .. amount .. ":" .. count * tonumber(amount))
            local result = "registerTime .. " / " .. charName .. " / " .. count .. " / " .. amount .. " / "" .. count *
                               tonumber(amount)
            table.insert(g.settings, result)
            market_voucher_save_settings()
        end
    end
    CABINET_GET_ALL_LIST_OLD(frame, control, strarg, now)

end

function market_voucher_CABINET_GET_ITEM()
    local frame = ui.GetFrame("market_cabinet")
    local itemGbox = GET_CHILD(frame, "itemGbox");
    local cnt = session.market.GetCabinetItemCount();
    -- for i = 0, cnt - 1 do
    local cabinetItem = session.market.GetCabinetItemByIndex(0);
    local itemID = cabinetItem:GetItemID();
    local itemObj = GetIES(cabinetItem:GetObject());
    -- local itemName = itemObj.ClassName
    local itemName = GET_FULL_NAME(itemObj)
    local registerTime = cabinetItem:GetRegSysTime();
    local timeString = GET_TIME_TXT(registerTime);
    local whereFrom = cabinetItem:GetWhereFrom();
    if whereFrom == "market_sell" then
        local count = 0;
        local amount = 0;
        local charName = nil;
        amount = cabinetItem.sellItemAmount;
        count = tonumber(cabinetItem:GetCount());
        charName = GETMYPCNAME();
        CHAT_SYSTEM(registerTime .. ":" .. charName .. ":" .. count .. ":" .. amount .. ":" .. count * tonumber(amount))
        print(registerTime .. ":" .. charName .. ":" .. count .. ":" .. amount .. ":" .. count * tonumber(amount))
        local result = "registerTime .. " / " .. charName .. " / " .. count .. " / " .. amount .. " / "" .. count *
                           tonumber(amount)
        table.insert(g.settings, result)
        market_voucher_save_settings()
    end

    -- end

end
function market_voucher_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function market_voucher_init_frame()
    local frame = ui.GetFrame("market_cabinet")
    local logbtn = frame:CreateOrGetControl("button", "log", 810, 105, 200, 45)
    logbtn:SetSkinName("tab2_btn_2")
    logbtn:SetText("SELL LOG")
    logbtn:SetEventScript(ui.LBUTTONUP, "market_voucher_print")
end

function market_voucher_print(frame, ctrl, argStr, argNum)
    local textview = frame:CreateOrGetControl("richtext", "textview", 10, 10, 820, 940)
    AUTO_CAST(textview)
    textview:SetText("")
    textview:SetEventScript(ui.LBUTTONUP, "market_voucher_print_close")
    -- print(tostring(g.settings))
    for _, value in pairs(g.settings) do
        textview:SetText(tostring(value))
        -- print(tostring(value))
    end

    textview:SetFontName("white_16_ol")
    textview:ShowWindow(1)
end

function market_voucher_print_close(frame, ctrl, argStr, argNum)
    ctrl:RemoveChild()
    return
end

function market_voucher_load_settings()
    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if settings then

        g.settings = settings

    end

end
