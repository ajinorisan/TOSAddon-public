-- v1.0.3 セット解除機能
-- v1.0.4 セット解除機能の挙動がおかしいのを修正
-- v1.0.5 カードスロットの1番目が入ってない場合、バグってたのを修正。お知らせを少し派手に。
-- v1.0.6 アドマネから入れたらバグってたの修正
local addonName = "ANCIENT_AUTOSET"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
-- g.loaded = true
--[[if not g.loaded then
    g.settings = {
        pctbl = {
            slot1 = nil,
            slot2 = nil,
            slot3 = nil,
            slot4 = nil
        }
    }
end]]

function ANCIENT_AUTOSET_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function ANCIENT_AUTOSET_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        settings = {
            pctbl = {
                slot1 = nil,
                slot2 = nil,
                slot3 = nil,
                slot4 = nil
            }
        }

    end
    g.settings = settings

    ANCIENT_AUTOSET_SAVE_SETTINGS()

    local loginCharID = info.GetCID(session.GetMyHandle())

    if g.settings.pctbl[loginCharID] == nil then
        g.settings.pctbl[loginCharID] = {}
        ANCIENT_AUTOSET_ON_SETTINGS()
    else
        ANCIENT_AUTOSET_ON_SETTINGS()
    end
end

function ANCIENT_AUTOSET_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    --[[if not g.loaded then
        g.loaded = true
    end]]

    local origframe = ui.GetFrame("ancient_card_list")
    local btn2 = origframe:GetChildRecursively("topbg"):CreateOrGetControl("button", "btn_aas", 0, 0, 90, 33)
    AUTO_CAST(btn2)
    btn2:SetGravity(ui.LEFT, ui.BOTTOM)
    btn2:SetMargin(470, 0, 0, 0)
    btn2:SetSkinName("None")
    btn2:SetImage("config_button_normal")
    btn2:Resize(33, 33)

    btn2:SetEventScript(ui.LBUTTONUP, "ANCIENT_SETTING_MSG")
    btn2:SetEventScript(ui.RBUTTONUP, "ANCIENT_SETTING_MSG_RELEASE")
    btn2:SetTextTooltip(
        "Ancient Aoto Set{nl}LeftButton:Setting RightButton:ReSetting{nl}左クリック:設定 右クリック:設定解除")

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        addon:RegisterMsg("GAME_START_3SEC", "ANCIENT_AUTOSET_LOAD_SETTINGS")
    else

        return;
    end

end

function ANCIENT_AUTOSET_ON_SETTINGS()
    local loginCharID = info.GetCID(session.GetMyHandle())
    local pctbl = g.settings.pctbl[loginCharID]

    local slot1 = tonumber(pctbl.slot1)
    local slot2 = tonumber(pctbl.slot2)
    local slot3 = tonumber(pctbl.slot3)
    local slot4 = tonumber(pctbl.slot4)

    local card1 = session.ancient.GetAncientCardBySlot(0)
    local card2 = session.ancient.GetAncientCardBySlot(1)
    local card3 = session.ancient.GetAncientCardBySlot(2)
    local card4 = session.ancient.GetAncientCardBySlot(3)

    if slot1 ~= nil and card1 == nil then
        ReqSwapAncientCard(slot1, 0)
        ReserveScript("ANCIENT_AUTOSET_ON_SETTINGS()", 0.3)
        return
    elseif slot1 ~= nil and card1 ~= nil then
        local clsid1 = card1:GetGuid()
        if slot1 ~= tonumber(clsid1) then
            ReqSwapAncientCard(slot1, 0)
            ReserveScript("ANCIENT_AUTOSET_ON_SETTINGS()", 0.3)
            return
        end
    end

    if slot2 ~= nil and card2 == nil then
        ReqSwapAncientCard(slot2, 1)
        ReserveScript("ANCIENT_AUTOSET_ON_SETTINGS()", 0.3)
        return
    elseif slot2 ~= nil and card2 ~= nil then
        local clsid2 = card2:GetGuid()
        if slot2 ~= tonumber(clsid2) then
            ReqSwapAncientCard(slot2, 1)
            ReserveScript("ANCIENT_AUTOSET_ON_SETTINGS()", 0.3)
            return
        end
    end

    if slot3 ~= nil and card3 == nil then
        ReqSwapAncientCard(slot3, 2)
        ReserveScript("ANCIENT_AUTOSET_ON_SETTINGS()", 0.3)
        return
    elseif slot3 ~= nil and card3 ~= nil then
        local clsid3 = card3:GetGuid()
        if slot3 ~= tonumber(clsid3) then
            ReqSwapAncientCard(slot3, 2)
            ReserveScript("ANCIENT_AUTOSET_ON_SETTINGS()", 0.3)
            return
        end
    end

    if slot4 ~= nil and card4 == nil then
        ReqSwapAncientCard(slot4, 3)
        ReserveScript("ANCIENT_AUTOSET_ON_SETTINGS()", 0.3)
        return
    elseif slot4 ~= nil and card4 ~= nil then
        local clsid4 = card4:GetGuid()
        if slot4 ~= tonumber(clsid4) then
            ReqSwapAncientCard(slot4, 3)
            ReserveScript("ANCIENT_AUTOSET_ON_SETTINGS()", 0.3)
            return
        end
    end

    if (slot1 == nil and slot2 == nil and slot3 == nil and slot4 == nil) then
        CHAT_SYSTEM("[AAS]このキャラクターはアシスターセットの登録を行っていません")
        CHAT_SYSTEM("AAS]This character is not registered as an assister.")
        return
    end

    ANCIENT_AUTOSET_FRAME_INIT()

end

function ANCIENT_SETTING_MSG_RELEASE()
    local msg =
        "Do you want to remove the assister set for this character?{nl}このキャラクターに設定したアシスターセットを解除しますか？"
    local yes_scp = "ANCIENT_SETTING_RELEASE()"

    ui.MsgBox(msg, yes_scp, "None");
end

function ANCIENT_SETTING_RELEASE()
    local frame = ui.GetFrame("ancient_card_list")
    local tab = frame:GetChild("tab")
    AUTO_CAST(tab)
    tab:SelectTab(0)

    local loginCharID = info.GetCID(session.GetMyHandle())

    for index = 0, 3 do
        local slotName = "slot" .. (index + 1)
        g.settings.pctbl[loginCharID][slotName] = nil
    end

    ui.SysMsg("[AAS]解除しました。")
    ui.SysMsg("[AAS]Canceled.")

    ANCIENT_AUTOSET_SAVE_SETTINGS()

end

function ANCIENT_SETTING_MSG()

    local msg =
        "Would you like to register the assister set currently displayed on this character?{nl}このキャラクターに表示中のアシスターセットを登録しますか？"
    local yes_scp = "ANCIENT_SETTING_REG()"

    ui.MsgBox(msg, yes_scp, "None");
end

function ANCIENT_SETTING_REG()

    local frame = ui.GetFrame("ancient_card_list")
    local tab = frame:GetChild("tab")
    AUTO_CAST(tab)
    tab:SelectTab(0)

    local loginCharID = info.GetCID(session.GetMyHandle())

    for index = 0, 3 do
        local card = session.ancient.GetAncientCardBySlot(index)
        if card ~= nil then
            local clsid = card:GetGuid()
            local slotName = "slot" .. (index + 1)
            g.settings.pctbl[loginCharID][slotName] = clsid
        end
    end
    ui.SysMsg("[AAS]登録しました。")
    ui.SysMsg("[AAS]Registered.")
    ANCIENT_AUTOSET_SAVE_SETTINGS()

end

function ANCIENT_AUTOSET_FRAME_INIT()

    local frame = ui.GetFrame("ancient_autoset")
    frame:Resize(240, 60)
    frame:SetSkinName("None")
    frame:SetLayerLevel(31)
    frame:ShowTitleBar(0)
    frame:EnableHitTest(1)

    local offsetX = 1100

    local offsetY = 30
    frame:SetOffset(offsetX, offsetY)
    frame:RemoveAllChild();
    frame:ShowWindow(1)

    local ancient_card_slot_Gbox = frame:CreateOrGetControl("groupbox", "ancient_card_slot_Gbox", 240, 60, ui.LEFT,
        ui.TOP, 0, 0, 0, 0);
    AUTO_CAST(ancient_card_slot_Gbox)
    ancient_card_slot_Gbox:EnableHittestGroupBox(false)
    ancient_card_slot_Gbox:SetSkinName("None")

    local slotset = ancient_card_slot_Gbox:CreateOrGetControl("slotset", "slotset", 0, 0, 0, 0)
    AUTO_CAST(slotset)

    slotset:RemoveAllChild();
    slotset:SetColRow(4, 1)
    slotset:SetMaxSelectionCount(1)
    slotset:SetSlotSize(60, 60)
    slotset:SetSkinName("slot");
    slotset:CreateSlots()

    slotset:ShowWindow(1)
    for i = 0, 3 do
        local card = session.ancient.GetAncientCardBySlot(i)

        if card ~= nil then
            ANCIENT_AUTOSET_SET_ANCIENT_CARD_SLOT(slotset, card, i)
        end
    end

    ReserveScript("ANCIENT_AUTOSET_CLOSE()", 3.0)
    -- ANCIENT_AUTOSET_CTRL_INIT(frame, slotset)

end

function ANCIENT_AUTOSET_SET_ANCIENT_CARD_SLOT(ctrlSet, card, index)
    local font = "{@st42b}{s14}"

    local slot = ctrlSet:GetSlotByIndex(index);
    AUTO_CAST(slot)
    -- print(tostring(slot))
    local icon = CreateIcon(slot);
    local monCls = GetClass("Monster", card:GetClassName());
    -- print(tostring(monCls.Icon))
    local iconName = monCls.Icon
    icon:SetImage(iconName)
    -- star drawing
    local starText = slot:CreateOrGetControl("richtext", "starText", 10, 40, 15, 15)
    local starStr = ""
    for i = 1, card.starrank do
        starStr = starStr .. string.format("{img monster_card_starmark %d %d}", 15, 15)
    end

    starText:SetText(starStr)
    -- set lv
    local exp = card:GetStrExp();
    local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
    local level = xpInfo.level
    local lvText = slot:CreateOrGetControl("richtext", "lvText", 3, 0, 40, 10)
    lvText:SetText(font .. "Lv. " .. level .. "{/}")

end

function ANCIENT_AUTOSET_CLOSE()
    local frame = ui.CloseFrame("ancient_autoset")
end

