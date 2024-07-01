local addonName = "TEST_NORISAN"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
-- local json = require('json')
local json = require "json_imc"

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

function TEST_NORISAN_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    -- acutil.setupHook(test_norisan_DRAW_EQUIP_HAIR_ENCHANT, "DRAW_EQUIP_HAIR_ENCHANT")
    -- g.SetupHook(test_norisan_ON_PARTYINFO_UPDATE, "ON_PARTYINFO_UPDATE")
    -- addon:RegisterMsg("ON_USER_DAMAGE_LIST", "test_norisan_ON_USER_DAMAGE_LIST");
    -- g.SetupHook(test_norisan_ON_PARTYINFO_BUFFLIST_UPDATE, "PARTY_BUFFLIST_UPDATE")
    -- acutil.setupHook(TEST_NORISAN_WEEKLYBOSSREWARD_REWARD_LIST_CLICK, "WEEKLYBOSSREWARD_REWARD_LIST_CLICK")
    -- acutil.setupEvent(addon, "ON_USER_DAMAGE_LIST", "test_norisan_ON_USER_DAMAGE_LIST");
    -- acutil.setupHook(TEST_NORISAN_INVENTORY_ON_MSG, "INVENTORY_ON_MSG")
    addon:RegisterMsg('INV_ITEM_ADD', "test_norisan_INV_ICON_USE")
    addon:RegisterMsg("DIALOG_CHANGE_SELECT", "test_norisan_DIALOG_CHANGE_SELECT")
    -- addon:RegisterMsg('FPS_UPDATE', "test_norisan_damege")
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    -- CHAT_SYSTEM(tostring(curMap))
    -- raid_giltine_AutoGuild　ソロ
    -- raid_dcapital_108 ハード
    local mapCls = GetClass("Map", curMap)
    -- CHAT_SYSTEM(tostring(mapCls))
    if mapCls.MapType == "City" then
        addon:RegisterMsg("GAME_START_3SEC", "TEST_NORISAN_NEWFRAME_INIT")
        -- test_norisan_icor_frame_init()
        return;
    end

end

function test_norisan_damege()
    local info = session.dps.Get_alldpsInfoByIndex(0)
    local damage = info:GetStrDamage()
    print(tostring(damage))
    CHAT_SYSTEM(damage)
end

function test_norisan_DIALOG_CHANGE_SELECT(frame, msg, argStr, argNum)
    print(frame:GetName())
    print(tostring(msg))
    print(tostring(argStr))
    print(tostring(argNum))

end

local coin_item = {869001, 11200303, 11200302, 11200301, 11200300, 11200299, 11200298, 11200297, 11200161, 11200160,
                   11200159, 11200158, 11200157, 11200156, 11200155, 11030215, 11030214, 11030213, 11030212, 11030211,
                   11030210, 11030201, 11035673, 11035670, 11035668, 11030394, 11030240, 646076, 11035672, 11035669,
                   11035667, 11035457, 11035426, 11035409}

function test_norisan_INV_ICON_USE()

    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();

    for i = 0, cnt - 1 do
        local guid = guidList:Get(i);
        local invItem = invItemList:GetItemByGuid(guid)

        local itemobj = GetIES(invItem:GetObject())
        --[[local iesid = invItem:GetIESID()]]

        for _, coinID in ipairs(coin_item) do
            if tostring(itemobj.ClassID) == tostring(coinID) then

                --[[local itemType = itemobj.ItemType;
                local groupName = TryGetProp(itemobj, "GroupName");
                local usable = itemobj.Usable;
                local invindex = invItem.invIndex]]

                -- ReserveScript(string.format("item.UseByGUID(%d)", coinID), 1.0)
                ReserveScript(string.format("item.UseByGUID(%d)", invItem:GetIESID()), 1.5)

                break -- 使ったらループを抜ける
            end
        end

    end
end

function test_norisan_DRAW_EQUIP_HAIR_ENCHANT(invitem, property_gbox, inner_yPos)

    local topParent = property_gbox:GetTopParentFrame();
    print(tostring(topParent:GetName()))
    local init_yPos = inner_yPos;

    for i = 1, 3 do
        local propName = "HatPropName_" .. i;
        local propValue = "HatPropValue_" .. i;

        if invitem[propValue] ~= 0 and invitem[propName] ~= "None" then
            local opName = string.format("[%s] %s", ClMsg("EnchantOption"), ScpArgMsg(invitem[propName]));
            local strInfo = ABILITY_DESC_PLUS(opName, invitem[propValue]);

            inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, strInfo, 0, inner_yPos);
        end
    end

    if init_yPos < inner_yPos then
        inner_yPos = ADD_ITEM_PROPERTY_TEXT(property_gbox, " ", 0, inner_yPos);
    end

    return inner_yPos
end

function TEST_NORISAN_NEWFRAME_INIT()

    local newframe = ui.CreateNewFrame("notice_on_pc", "my_frame", 0, 0, 50, 50)
    AUTO_CAST(newframe)
    newframe:Resize(50, 50)
    newframe:SetPos(1370, 20)
    -- newframe:SetOffset(1375, 15)
    newframe:ShowWindow(1)
    newframe:SetSkinName("None")
    local btn = newframe:CreateOrGetControl("button", "myButton", 0, 0, 50, 50)
    AUTO_CAST(btn)
    btn:SetImage("config_button_normal")
    btn:SetEventScript(ui.LBUTTONDOWN, "test_norisan_console_init")
    btn:SetTextTooltip("{@st59}open console{/}")
    -- btn:RunUpdateScript("test_norisan", 1);
    --[[local btn2 = newframe:CreateOrGetControl("button", "btn2", 60, 0, 50, 50)
    AUTO_CAST(btn2)
    btn2:SetEventScript(ui.LBUTTONDOWN, "test_norisan_btnon")
    -- CHAT_NOTICE("test")
    -- local chat = ui.GetFrame("chat")
    -- chat:SetLayerLevel(100)
end]]
    --[[local frame = ui.GetFrame("inventory")
    frame:RunUpdateScript("test_norisan", 1);]]
end

-- local msg = ClMsg("CantUseDiffenentDefaultEquipSlot")
-- CHAT_SYSTEM(tostring(msg))
function test_norisan()

    local frame = ui.GetFrame("inventory")
    if frame:IsVisible() == 1 then
        local liftIcon = ui.GetLiftIcon()
        local iconInfo = liftIcon:GetInfo();
        local guid = iconInfo:GetIESID();
        local invItem = GET_ITEM_BY_GUID(guid);
        local obj = GetIES(invItem:GetObject());
        -- CHAT_SYSTEM("test")
        print(tostring(GET_REQ_TOOLTIP(obj)))
        if tostring(GET_REQ_TOOLTIP(obj)) == "@dicID_^*$ITEM_20151223_008653$*^" then
            print("souyade")
        else
            print("tigaude")
        end
        child_name()
        -- local itemName = dictionary.ReplaceDicIDInCompStr(GET_REQ_TOOLTIP(obj))
        -- print(tostring(itemName))
        --[[local invitem = session.GetInvItemByGuid(guid);
        print(tostring(obj))
        for i = 1, 3 do
            local propName = "HatPropName_" .. i;
            local propValue = "HatPropValue_" .. i;
            print(tostring(obj[propName]))
            print(tostring(obj[propValue]))
        end
        local itemCls = GetClassByType("Item", invitem.type);
        local classtype = TryGetProp(obj, "ClassType");
        local type = obj.ClassType
        local itemCls = GetClassByType("Item", invItem.type);
        CHAT_SYSTEM(tostring(type))

        local equipItemList = session.GetEquipItemList();
        local cnt = equipItemList:Count();]]

        CHAT_SYSTEM("1")

        return 1
    else
        CHAT_SYSTEM("0")
        return 0
    end

end

function child_name()
    g.equipInfoTable = {}
    local equipItemList = session.GetEquipItemList();
    local cnt = equipItemList:Count();
    local count = 0

    for i = 0, cnt - 1 do
        local equipItem = equipItemList:GetEquipItemByIndex(i);
        local spotName = item.GetEquipSpotName(equipItem.equipSpot);
        local iesid = tostring(equipItem:GetIESID())
        local itemtype = equipItem.type;
        local iteminfo = session.GetEquipItemByType(itemtype);
        print(tostring(spotName) .. ":" .. i)
    end
end

function test_norisan_btnon()
    local frame = ui.GetFrame("indunenter");
    if frame:IsVisible() == 1 then
        local induntype = frame:GetUserValue("INDUN_TYPE");
        print(tostring(induntype))
        --[[
        local PAGE_Drug = GET_CHILD_RECURSIVELY(frame, "PAGE_Drug")
        -- local childCount = BTN_Drug:GetChildCount();
        local childCount = PAGE_Drug:GetChildCount();
        print("test")
        for i = 0, childCount - 1 do
            local child = PAGE_Drug:GetChildByIndex(i);
            print("test1")
            -- childに子要素が格納されます
            local childName = child:GetName(); -- 子要素の名前を取得できます
            print(tostring(childName))
        end
        ]]
    end

end

function test_norisan_console_init()

    local console = ui.GetFrame("developerconsole")
    if console:IsVisible() == 0 then
        console:ShowWindow(1)

    else
        console:ShowWindow(0)
    end
end
