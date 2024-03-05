local addonName = "OTHER_CHARACTER_ITEMLIST"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local json = require('json')

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

g.first = 0 -- バラックを選ぶために一度0から始める。

-- hidelogin
local frame = ui.GetFrame("barrack_charlist")
if frame ~= nil then
    local hidelogin = GET_CHILD_RECURSIVELY(frame, "hidelogin", "ui::CCheckBox");
    hidelogin:SetCheck(1);

end

function OTHER_CHARACTER_ITEMLIST_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}
    g.CID = info.GetCID(session.GetMyHandle())

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        addon:RegisterMsg("GAME_START", "other_character_itemlist_2sec")
        acutil.setupEvent(addon, "INVENTORY_OPEN", "other_character_INVENTORY_OPEN")
        acutil.setupEvent(addon, "INVENTORY_CLOSE", "other_character_INVENTORY_CLOSE")
        return;
    end

end
-- other_character_itemlist_save_enchant()

function other_character_INVENTORY_OPEN()
    other_character_itemlist_save_enchant()
end

function other_character_INVENTORY_CLOSE()
    other_character_itemlist_save_enchant()
end

function other_character_itemlist_2sec()

    ReserveScript("other_character_itemlist_frame_init()", 2.0)
    ReserveScript("other_character_itemlist_lord_settings()", 2.0)

end

function other_character_itemlist_lord_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then

        settings = g.settings
    end

    local LoginName = session.GetMySession():GetPCApc():GetName()
    local cid_settings = {
        layer = 9,
        index = 99,
        name = LoginName,
        SHIRT = {
            iesid = "",
            skillName = "",
            skillLv = 0,
            cnt = 0
        },
        PANTS = {
            iesid = "",
            skillName = "",
            skillLv = 0,
            cnt = 0
        },
        GLOVES = {
            iesid = "",
            skillName = "",
            skillLv = 0,
            cnt = 0
        },
        BOOTS = {
            iesid = "",
            skillName = "",
            skillLv = 0,
            cnt = 0
        },
        LEGCARD = "",
        GODCARD = ""

    }

    if g.settings[g.CID] == nil then
        g.settings[g.CID] = {}
        g.settings[g.CID] = cid_settings

    else

        g.settings[g.CID] = settings[g.CID]

    end

    other_character_itemlist_save_settings()
end

function other_character_itemlist_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function other_character_itemlist_frame_open(frame, ctrl, argStr, argNum)
    frame:SetSkinName("None")
    frame:Resize(600, 800)
    frame:SetLayerLevel(65)
    ctrl:ShowWindow(0)

    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 40, 5, 550, 790)
    AUTO_CAST(gbox)
    gbox:SetSkinName("test_frame_low")
    local close = gbox:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "other_character_itemlist_frame_close")
end

function other_character_itemlist_enchant_preview(frame, ctrl, argStr, argNum)

end

function other_character_itemlist_frame_close(frame, ctrl, argStr, argNum)
    local frame = ui.GetFrame(addonNameLower)
    print(tostring(frame:GetName()))
    -- local gbox = GET_CHILD_RECURSIVELY(frame, "gbox")
    -- gbox:ShowWindow(0)
    print("test")
    local btn = GET_CHILD_RECURSIVELY(frame, "btn")
    btn:ShowWindow(1)
    frame:Resize(35, 35)
    btn:ShowWindow(1)
end

function other_character_itemlist_frame_init()
    local frame = ui.GetFrame(addonNameLower)
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(35, 35)
    frame:SetPos(715, 0)

    frame:ShowWindow(1)

    local btn = frame:CreateOrGetControl('button', 'btn', 0, 0, 35, 35)
    AUTO_CAST(btn)
    btn:SetSkinName("None")
    btn:SetText("{img sysmenu_friend 35 35}")
    btn:SetEventScript(ui.LBUTTONDOWN, "other_character_itemlist_frame_open")

end

function other_character_itemlist_save_enchant()
    local equipItemList = session.GetEquipItemList();
    local count = equipItemList:Count();

    for i = 0, count - 1 do
        local equipItem = equipItemList:GetEquipItemByIndex(i);
        local spotName = item.GetEquipSpotName(equipItem.equipSpot);
        local iesid = tostring(equipItem:GetIESID())

        if spotName == "SHIRT" or spotName == "PANTS" or spotName == "GLOVES" or spotName == "BOOTS" then
            local Item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spotName));
            local obj = GetIES(Item:GetObject());
            local cnt = TryGetProp(obj, 'EnchantSkillSlotCount', 0)
            local Name, Level = shared_skill_enchant.get_enchanted_skill(obj, 1)

            g.settings[g.CID][spotName].iesid = iesid
            g.settings[g.CID][spotName].skillName = Name
            g.settings[g.CID][spotName].skillLv = Level
            g.settings[g.CID][spotName].cnt = cnt
            other_character_itemlist_save_settings()
        end
    end

end

