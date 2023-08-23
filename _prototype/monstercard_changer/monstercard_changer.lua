local addonName = "monstercard_changer"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

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

g.SettingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

g.cardgroup = {
    ['ATK'] = {
        startIndex = 0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE
    },
    ['DEF'] = {
        startIndex = 1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE
    },
    ['UTIL'] = {
        startIndex = 2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE
    },
    ['STAT'] = {
        startIndex = 3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE
    },
    ['LEG'] = {
        startIndex = 4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE
    }
}

function MONSTERCARD_CHANGER_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    -- g.SetupHook(MONSTERCARD_CHANGER_CARD_PRESET_SAVE_PRESET, "CARD_PRESET_SAVE_PRESET")
    -- acutil.setupHook(monstercard_changer_CARD_PRESET_SELECT_PRESET, "CARD_PRESET_SELECT_PRESET")
    addon:RegisterMsg('GAME_START_3SEC', 'monstercard_changer_inventory_frame_init');

end

function MONSTERCARD_CHANGER_CARD_PRESET_SETTING_PRESET(frame, self)

    local parent = ui.GetFrame("monstercardpreset")
    local msg = "現在装備中のモンスターカードを登録しますか？" ..
                    "Do you want to register a monster card that is currently equipped?"
    local yesscp = string.format("MONSTERCARD_CHANGER_CARD_PRESET_SAVE_PRESET(\"parent\",'%s')", self)
    ui.MsgBox(msg, yesscp, "None");
    return

end

function MONSTERCARD_CHANGER_CARD_PRESET_SAVE_PRESET(parent, self)

    local cardList, expList = MONSTERCARD_CHANGER_CARD_PRESET_GET_CARD_EXP_LIST(parent)
    -- CHAT_SYSTEM("test1")
    local droplist = GET_CHILD_RECURSIVELY(parent, "preset_list")
    local page = tonumber(droplist:GetSelItemKey())
    CHAT_SYSTEM("test1")
    SetCardPreset(page, cardList, expList)
    _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
end

function MONSTERCARD_CHANGER_CARD_PRESET_GET_CARD_EXP_LIST(frame)
    -- CHAT_SYSTEM(tostring("test"))
    local frame = ui.GetFrame("monstercardslot")
    local cardList = {}
    local expList = {}
    for i = 0, 11 do
        local cardClsID, cardLv, cardExp = GETMYCARD_INFO(i)
        -- CHAT_SYSTEM(tostring(cardClsID))
        -- CHAT_SYSTEM(tostring(cardLv))
        -- CHAT_SYSTEM(tostring(cardExp))
        if cardClsID ~= 0 then
            table.insert(cardList, cardClsID);
            table.insert(expList, cardExp);
        else
            table.insert(cardList, 0);
            table.insert(expList, 0);
        end
    end

    return cardList, expList
end

function MONSTERCARD_CHANGER_CARD_SLOT_RBTNUP_ITEM_INFO(frame, slot, argStr, argNum)
    CHAT_SYSTEM(tostring(frame:GetName()))
    CHAT_SYSTEM(tostring(slot:GetName()))
    CHAT_SYSTEM(tostring(argStr))
    CHAT_SYSTEM(tostring(argNum))
    return
end

function MONSTERCARD_CHANGER_CARD_SLOT_DROP(frame, slot, argStr, argNum)
    CHAT_SYSTEM(tostring(frame:GetName()))
    CHAT_SYSTEM(tostring(slot:GetName()))
    CHAT_SYSTEM(tostring(argStr))
    CHAT_SYSTEM(tostring(argNum))
    return
end

function monstercard_changer_inventory_frame_init()

    local frame = ui.GetFrame("monstercardpreset")
    local saveBtn = GET_CHILD_RECURSIVELY(frame, 'saveBtn')
    saveBtn:ShowWindow(0)
    local savebtn = frame:CreateOrGetControl("button", "cancelbtn", 0, 0, 170, 70)
    savebtn:Resize(95, 38)
    savebtn:SetOffset(350, 57, 0, 0)
    savebtn:SetSkinName("test_pvp_btn")
    -- {#000000}黒
    savebtn:SetText("{ol}SAVE")
    savebtn:SetEventScript(ui.LBUTTONUP, "MONSTERCARD_CHANGER_CARD_PRESET_SETTING_PRESET")

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local invframe = ui.GetFrame('inventory')
        local inventoryGbox = invframe:GetChild("inventoryGbox")
        local btnX = inventoryGbox:GetWidth() - 492
        local btnY = inventoryGbox:GetHeight() - 290 -- 290
        local mccbtn = invframe:CreateOrGetControl("button", "mcc", btnX, btnY, 30, 32)
        AUTO_CAST(mccbtn)
        mccbtn:SetSkinName("test_red_button")
        mccbtn:SetTextAlign("right", "center")
        mccbtn:SetText("{img monsterbtn_image 28 23}{/}")
        -- mccqbtn:SetEventScript(ui.LBUTTONUP, "MONSTERCARDPRESET_FRAME_OPEN")
        mccbtn:SetEventScript(ui.RBUTTONUP, "monstercard_changer_frame_init")
        -- print("ok")
    end
end

function monstercard_changer_frame_close(frame)
    ui.CloseFrame(addonName)
end

function monstercard_changer_frame_init()

    local frame = ui.GetFrame(addonName)
    if frame:IsVisible() == 1 then
        monstercard_changer_frame_close(frame)
        return
    end

    local closebtn = GET_CHILD_RECURSIVELY(frame, 'close')
    closebtn:SetEventScript(ui.LBUTTONUP, "monstercard_changer_frame_close")
    -- ATKcardGbox:RemoveAllChild()

    local ATKcardGbox = GET_CHILD_RECURSIVELY(frame, 'ATKcardGbox')
    CARD_SLOT_CREATE(frame, "ATK", 0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    CARD_SLOT_CREATE(frame, 'DEF', 1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    CARD_SLOT_CREATE(frame, 'UTIL', 2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    CARD_SLOT_CREATE(frame, 'STAT', 3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    CARD_SLOT_CREATE(frame, 'LEG', 4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)

    frame:ShowWindow(1)

end

