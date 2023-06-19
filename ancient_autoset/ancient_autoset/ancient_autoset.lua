local addonName = "ANCIENT_AUTOSET"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

if not g.loaded then
    g.settings = {
        pctbl = {
            slot1 = nil,
            slot2 = nil,
            slot3 = nil,
            slot4 = nil
        }
    }
end

function ANCIENT_AUTOSET_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function ANCIENT_AUTOSET_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    local loginCharID = info.GetCID(session.GetMyHandle())
    -- CHAT_SYSTEM(loginCharID)
    local pctbl = g.settings.pctbl[loginCharID]
    -- CHAT_SYSTEM(pctbl)
    if pctbl then
        -- CHAT_SYSTEM("true")
        ANCIENT_AUTOSET_ON_SETTINGS()

    else
        ui.SysMsg("[AAS]This character is not registered as an assister.")

        ui.SysMsg("[AAS]このキャラクターはアシスターセットの登録を行っていません")
    end
end

function ANCIENT_AUTOSET_ON_SETTINGS()
    local loginCharID = info.GetCID(session.GetMyHandle())
    local pctbl = g.settings.pctbl[loginCharID]

    if IS_ANCIENT_ENABLE_MAP() == "YES" then
        addon.BroadMsg("NOTICE_Dm_!", ClMsg("ImpossibleInCurrentMap"), 3);
        return
    end
    -- CHAT_SYSTEM("呼び出し")
    local slot1 = pctbl.slot1
    local guid1 = tonumber(slot1)
    local card1 = session.ancient.GetAncientCardBySlot(0)
    local clsid1 = card1:GetGuid()

    local slot2 = pctbl.slot2
    local guid2 = tonumber(slot2)
    local card2 = session.ancient.GetAncientCardBySlot(1)
    local clsid2 = card2:GetGuid()

    local slot3 = pctbl.slot3
    local guid3 = tonumber(slot3)
    local card3 = session.ancient.GetAncientCardBySlot(2)
    local clsid3 = card3:GetGuid()

    local slot4 = pctbl.slot4
    local guid4 = tonumber(slot4)
    local card4 = session.ancient.GetAncientCardBySlot(3)
    local clsid4 = card4:GetGuid()

    if guid1 ~= tonumber(clsid1) then
        ReqSwapAncientCard(guid1, 0)
        -- CHAT_SYSTEM("違う")

    elseif guid2 ~= tonumber(clsid2) then
        ReqSwapAncientCard(guid2, 1)
        -- CHAT_SYSTEM("違う")

    elseif guid3 ~= tonumber(clsid3) then
        ReqSwapAncientCard(guid3, 2)
        -- CHAT_SYSTEM("違う")

    elseif guid4 ~= tonumber(clsid4) then
        ReqSwapAncientCard(guid4, 3)
        -- CHAT_SYSTEM("違う")
    else
        ANCIENT_AUTOSET_FRAME_INIT(frame)
        -- CHAT_SYSTEM("一緒")
        return
    end
    ReserveScript("ANCIENT_AUTOSET_ON_SETTINGS()", 0.3)

end

function ANCIENT_AUTOSET_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    CHAT_SYSTEM(addonNameLower .. " loaded")
    --[[
    local aasframe = ui.CreateNewFrame("notice_on_pc", "aasframe")
    aasframe:Resize(100, 40)
    aasframe:SetOffset(1300, 930)
    aasframe:ShowWindow(1)
    local btn = aasframe:CreateOrGetControl("button", "testbtn", 0, 0, 100, 40)
    btn:SetText("testbtn")
    -- btn:SetEventScript(ui.LBUTTONUP, "ANCIENT_AUTOSET_FRAME_INIT")
    btn:SetEventScript(ui.LBUTTONUP, "ANCIENT_AUTOSET_LOAD_SETTINGS")
    ]]
    local origframe = ui.GetFrame("ancient_card_list")
    local btn2 = origframe:GetChildRecursively("topbg"):CreateOrGetControl("button", "btn_aas", 0, 0, 90, 33)
    AUTO_CAST(btn2)
    btn2:SetGravity(ui.LEFT, ui.BOTTOM)
    btn2:SetMargin(200, 0, 0, 0)
    btn2:SetSkinName("None")
    btn2:SetImage("config_button_normal")
    btn2:Resize(33, 33)
    -- btn2:SetText("{ol}Setting Reg")
    -- btn2:SetEventScript(ui.LBUTTONUP, "ANCIENT_SETTING_REG")
    btn2:SetEventScript(ui.LBUTTONUP, "ANCIENT_SETTING_MSG")
    -- addon:RegisterMsg("BANDI_CAM", "HIDE_CHATFRAME_ON_BANDI_CAM")
    -- acutil.setupHook(HIDE_CHATFRAME_ON_BANDI_CAM, "ON_BANDI_CAM")

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        addon:RegisterMsg("GAME_START_3SEC", "ANCIENT_AUTOSET_LOAD_SETTINGS")
    else
        -- ui.SysMsg("アシスターオートセットは動きません")
        return;
    end

    -- ANCIENT_AUTOSET_LOAD_SETTINGS()
end

function ANCIENT_SETTING_MSG()

    local msg = "Would you like to register the assister set currently displayed on this character?" ..
                    "このキャラクターに表示中のアシスターセットを登録しますか？"
    local yes_scp = "ANCIENT_SETTING_REG()"
    local no_scp = "ANCIENT_SETTING_CANCEL()"
    ui.MsgBox(msg, yes_scp, no_scp);
end

function ANCIENT_SETTING_CANCEL()
    -- ui.SysMsg("Your registration has been cancelled.")
    -- ui.SysMsg("登録をキャンセルしました。")
    return
end
function ANCIENT_SETTING_REG()
    ui.SysMsg("[AAS]登録しました。")
    ui.SysMsg("[AAS]Registered.")
    local frame = ui.GetFrame("ancient_card_list")
    local tab = frame:GetChild("tab")
    AUTO_CAST(tab)
    tab:SelectTab(0)

    if g.settings == nil then
        g.settings = {
            pctbl = {
                slot1 = nil,
                slot2 = nil,
                slot3 = nil,
                slot4 = nil
            }
        }
    end

    local loginCharID = info.GetCID(session.GetMyHandle())
    -- CHAT_SYSTEM(loginCharID)

    local settings = {}

    for index = 0, 3 do
        local card = session.ancient.GetAncientCardBySlot(index)
        local clsid = card:GetGuid()
        -- CHAT_SYSTEM(clsid)

        local slotName = "slot" .. (index + 1)
        settings[slotName] = clsid
    end

    g.settings.pctbl[loginCharID] = settings
    ANCIENT_AUTOSET_SAVE_SETTINGS()
    -- ANCIENT_AUTOSET_LOAD_SETTINGS()
end

function ANCIENT_AUTOSET_FRAME_INIT(frame)
    --[[
    local frame = ui.GetFrame("ancient_card_list")
    local tab = frame:GetChild("tab")
    AUTO_CAST(tab)
    frame:SetSkinName("None")
    frame:ShowTitleBar(0)
    tab:SelectTab(0)
    local ancient_card_list_Gbox = GET_CHILD_RECURSIVELY(frame, 'ancient_card_list_Gbox')
    ancient_card_list_Gbox:ShowWindow(1)
    -- ui.ToggleFrame('ancient_card_list')
]]
    -- btn:SetEventScript(ui.LBUTTONUP, "ANCIENTMONSTERBOOKSHELF_TOGGLE")

    local frame = ui.GetFrame("ancient_autoset")
    frame:Resize(320, 80)
    frame:SetSkinName("None")
    -- frame:SetImage("pcbang_timer_bg")
    frame:SetLayerLevel(31)
    frame:ShowTitleBar(0)
    frame:EnableHitTest(1)
    local screenWidth = ui.GetClientInitialWidth()
    -- local offsetX = screenWidth - 1000
    local offsetX = 450
    local screenHeight = ui.GetClientInitialHeight()
    local frameHeight = frame:GetHeight()
    -- local offsetY = screenHeight - frameHeight - 600
    local offsetY = 20
    frame:SetOffset(offsetX, offsetY)
    frame:RemoveAllChild();
    frame:ShowWindow(1)

    local ancient_card_slot_Gbox = frame:CreateOrGetControl("groupbox", "ancient_card_slot_Gbox", 320, 80, ui.LEFT,
        ui.TOP, 0, 0, 0, 0);
    AUTO_CAST(ancient_card_slot_Gbox)
    ancient_card_slot_Gbox:EnableHittestGroupBox(false)
    ancient_card_slot_Gbox:SetSkinName("test_frame_midle")

    local slotset = ancient_card_slot_Gbox:CreateOrGetControl("slotset", "slotset", 0, 0, 0, 0)
    -- local slotset = frame:CreateOrGetControl("slotset", "slotset", 0, 0, 220, 92)
    tolua.cast(slotset, "ui::CSlotSet")
    slotset:RemoveAllChild();
    slotset:SetColRow(4, 1)
    slotset:SetMaxSelectionCount(1)
    -- slotset:SetSlotSize(33, 43)
    slotset:SetSlotSize(80, 80)
    -- slotset:SetSlotSpace(5, 0)
    slotset:SetSkinName("slot");
    slotset:CreateSlots()

    slotset:ShowWindow(1)

    ANCIENT_AUTOSET_CTRL_INIT(frame, slotset)

end

function ANCIENT_AUTOSET_CTRL_INIT(frame, slotset)
    for i = 0, 3 do
        local toslot = slotset:GetSlotByIndex(i)
        toslot:SetUserValue("SLOT_NAME", "toslot_" .. i)
        AUTO_CAST(toslot)
        -- local frame = ui.GetFrame("ancient_card_list")
        -- local gbox = GET_CHILD_RECURSIVELY(frame, 'ancient_card_slot_Gbox')

        -- local ctrlSet = gbox:CreateControlSet("ancient_card_item_slot", "SLOT_" .. i, 4, 4);
        -- local slot = GET_CHILD_RECURSIVELY(ctrlSet, "ancient_card_slot")
        -- AUTO_CAST(slot)

        -- local icon = CreateIcon(slot);

        local card = session.ancient.GetAncientCardBySlot(i)

        local monCls = GetClass("Monster", card:GetClassName());
        -- local monClsID = GetClassByType("Monster", card:GetIESID());

        local iconName = TryGetProp(monCls, "Icon");
        -- CHAT_SYSTEM(iconName)
        -- CHAT_SYSTEM(monClsID)
        -- icon:SetImage(iconName)

        local toicon = CreateIcon(toslot);
        toicon:SetImage(iconName)
    end
    ReserveScript("ANCIENT_AUTOSET_CLOSE()", 3.0)
end

function ANCIENT_AUTOSET_CLOSE()
    local frame = ui.CloseFrame("ancient_autoset")
end
--[[とりあえず動いたやつ
function ANCIENT_SETTING_REG()
    local frame = ui.GetFrame("ancient_card_list")
    local tab = frame:GetChild("tab")
    AUTO_CAST(tab)
    tab:SelectTab(0)
    local gbox = GET_CHILD_RECURSIVELY(frame, 'ancient_card_slot_Gbox')
    CHAT_SYSTEM("1")
    for index = 0, 3 do
        CHAT_SYSTEM("1")
        local card = session.ancient.GetAncientCardBySlot(index)
        CHAT_SYSTEM("2")
        local clsid = card:GetGuid()
        
        CHAT_SYSTEM(clsid)

    end
end

function ANCIENT_AUTOSET_CTRL_INIT(frame, slotset)
    for i = 0, 3 do
        local toslot = slotset:GetSlotByIndex(i)
        toslot:SetUserValue("SLOT_NAME", "toslot_" .. i)
        AUTO_CAST(toslot)
        local frame = ui.GetFrame("ancient_card_list")
        local gbox = GET_CHILD_RECURSIVELY(frame, 'ancient_card_slot_Gbox')

        local ctrlSet = gbox:CreateControlSet("ancient_card_item_slot", "SLOT_" .. i, 4, 4);
        local slot = GET_CHILD_RECURSIVELY(ctrlSet, "ancient_card_slot")
        AUTO_CAST(slot)

        local icon = CreateIcon(slot);

        local card = session.ancient.GetAncientCardBySlot(i)

        local monCls = GetClass("Monster", card:GetClassName());

        local iconName = TryGetProp(monCls, "Icon");
        CHAT_SYSTEM(iconName)
        icon:SetImage(iconName)

        local toicon = CreateIcon(toslot);
        toicon:SetImage(iconName)
    end
end
]]
