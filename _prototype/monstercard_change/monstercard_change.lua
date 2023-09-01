local addonName = "monstercard_change"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

local base = {}
local curPreset = 0

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

function MONSTERCARD_CHANGE_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    addon:RegisterMsg('GAME_START_3SEC', 'monstercard_change_inventory_frame_init');
    addon:RegisterMsg('GAME_START_3SEC', 'monstercard_change_preset_frame_init');
    -- g.SetupHook(monstercard_change_CARD_PRESET_SAVE_PRESET, "CARD_PRESET_SAVE_PRESET")

end

function monstercard_change_CARD_PRESET_SAVE_PRESET(parent, self)
    local parent = ui.GetFrame("monstercardslot")
    local cardList, expList = CARD_PRESET_GET_CARD_EXP_LIST(parent)
    local frame = ui.GetFrame("monstercardpreset")
    local droplist = GET_CHILD_RECURSIVELY(frame, "preset_list")
    local page = tonumber(droplist:GetSelItemKey())
    -- CHAT_SYSTEM(page)
    SetCardPreset(page, cardList, expList)
    _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()

end

function monstercard_change_inventory_frame_init()

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
        mccbtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_MONSTERCARDPRESET_FRAME_OPEN")
    end
end

function monstercard_change_MONSTERCARDPRESET_FRAME_OPEN()
    local frame = ui.GetFrame('monstercardpreset')
    -- local mcframe = ui.GetFrame("monstercardslotset")

    if frame:IsVisible() == 1 then
        MONSTERCARDSLOT_CLOSE()
        return
    end

    frame:RemoveChild("saveBtn")
    local saveBtn = frame:CreateOrGetControl("button", "saveBtn", 352, 57, 95, 38)
    AUTO_CAST(saveBtn)
    saveBtn:SetText("{@st66b}SAVE")
    saveBtn:SetSkinName("test_pvp_btn")
    saveBtn:SetTextTooltip("{@st59}Calls up the information of the currently equipped card to the current preset{nl}" ..
                               "{@st59}現在装備中のカード情報を、現在のプリセットに呼び出します{/}")
    saveBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_msgbox")

    frame:RemoveChild("applyBtn")
    local applyBtn = frame:CreateOrGetControl("button", "applyBtn", 451, 57, 95, 38)
    AUTO_CAST(applyBtn)
    applyBtn:SetText("{@st66b}EQUIP")
    applyBtn:SetSkinName("test_pvp_btn")
    local awframe = ui.GetFrame("accountwarehouse")
    if awframe:IsVisible() == 1 then
        applyBtn:SetTextTooltip("{@st59}Change the installed card with the current preset{nl}" ..
                                    "{@st59}{#FFFF00}※Does not apply to cards not held in inventory or team warehouse{nl}" ..
                                    "{@st59}現在のプリセットで、装着カードを変更します{nl}" ..
                                    "{@st59}{#FFFF00}※インベントリかチーム倉庫に所持していないカードは適用されません")
        applyBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_CARD_PRESET_APPLY_PRESET")

    else
        applyBtn:SetTextTooltip("{@st59}Change the installed card with the current preset{nl}" ..
                                    "{@st59}{#FFFF00}※Does not apply to cards you do not have in your inventory{nl}" ..
                                    "{@st59}現在のプリセットで、装着カードを変更します{nl}" ..
                                    "{@st59}{#FFFF00}※インベントリに所持していないカードは適用されません")
        -- applyBtn:SetEventScript(ui.LBUTTONUP, "CARD_PRESET_APPLY_PRESET")
        applyBtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_CARD_PRESET_APPLY_PRESET")
    end

    local etcObj = GetMyEtcObject()
    local droplist = GET_CHILD_RECURSIVELY(frame, "preset_list")
    droplist:SelectItemByKey(0)
    MONSTERCARDPRESET_FRAME_INIT()
    RequestCardPreset(0)

    ReserveScript(string.format("monstercard_change_MONSTERCARDSLOT_FRAME_OPEN()"), 0.1)
end

function monstercard_change_CARD_PRESET_APPLY_PRESET(parent, self)

    local fromframe = ui.GetFrame("accountwarehouse")
    local cardList, expList = monstercard_change_CARD_PRESET_GET_CARD_EXP_LIST(parent)
    local droplist = GET_CHILD_RECURSIVELY(parent, "preset_list")
    local page = tonumber(droplist:GetSelItemKey())

    if fromframe:IsVisible() == 0 then

        if page ~= nil then
            pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", page)
            _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
        end

    else
        local invItemList = session.GetInvItemList()
        local guidList = invItemList:GetGuidList();
        local cnt = guidList:Count();

        for i = 1, math.min(#cardList, 12) do
            for j = 0, cnt - 1 do
                local guid = guidList:Get(j);
                local invItem = invItemList:GetItemByGuid(guid)
                local itemobj = GetIES(invItem:GetObject())
                local iesid = invItem:GetIESID()

                local obj = GetIES(invItem:GetObject());
                if obj.ClassName ~= MONEY_NAME then
                    -- if tostring(itemobj.ClassID) == tostring(cardList[i]) then
                    local cardexp = GET_ITEM_LEVEL_EXP(invItem);
                    if tostring(itemobj.ClassID) == tostring(cardList[i]) and tostring(cardexp) == tostring(expList[i]) then
                        print(tostring(cardexp))
                        session.ResetItemList()
                        session.AddItemID(tonumber(iesid), 1)
                        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                                                        fromframe:GetUserIValue("HANDLE"))
                        if i < math.min(#cardList, 12) then
                            ReserveScript(string.format("monstercard_change_CARD_PRESET_APPLY_PRESET('%s','%s')",
                                                        parent, self), 0.1)
                            return
                        elseif i == math.min(#cardList, 12) then
                            if page ~= nil then
                                pc.ReqExecuteTx_NumArgs("SCR_TX_APPLY_CARD_PRESET", page)
                                _DISABLE_CARD_PRESET_APPLY_SAVE_BTN()
                            end
                        end
                    end
                end
            end

            -- print("Card at index " .. i .. ": " .. tostring(cardList[i]))
            -- print("Card at index " .. i .. ": " .. tostring(expList[i]))
        end
        -- CHAT_SYSTEM("monstercard_change_CARD_PRESET_APPLY_PRESET")
    end

end

function monstercard_change_CARD_PRESET_GET_CARD_EXP_LIST(frame)
    local frame = frame:GetTopParentFrame()
    local cardList = {}
    local expList = {}
    for i = 0, 11 do
        local cardClsID, cardLv, cardExp = GETMYCARD_INFO(i)

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

function monstercard_change_MONSTERCARDSLOT_FRAME_OPEN()
    local frame = ui.GetFrame('monstercardslot')
    local applyBtn = GET_CHILD_RECURSIVELY(frame, "applyBtn")
    frame:RemoveChild("applyBtn")
    local etcObj = GetMyEtcObject()
    MONSTERCARDSLOT_FRAME_INIT()
end

function monstercard_change_msgbox(frame, ctrl)

    frame = ui.GetFrame("monstercardpreset")
    local msg = "Do you want to register the information of the card currently equipped to the current preset?{nl}" ..
                    "現在装備中のカード情報を、現在のプリセットに登録しますか？"
    local yesscp = string.format("monstercard_change_CARD_PRESET_SAVE_PRESET('%s', '%s')", frame, ctrl)
    ui.MsgBox(msg, yesscp, "None")

end
