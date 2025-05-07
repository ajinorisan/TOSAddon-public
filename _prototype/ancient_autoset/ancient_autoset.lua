-- v1.0.3 セット解除機能
-- v1.0.4 セット解除機能の挙動がおかしいのを修正
-- v1.0.5 カードスロットの1番目が入ってない場合、バグってたのを修正。お知らせを少し派手に。
-- v1.0.6 アドマネから入れたらバグってたの修正
-- v1.0.7 お知らせをチャットのみに
local addonName = "ANCIENT_AUTOSET"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}

local g = _G["ADDONS"][author][addonName]
local json = require("json")

function g.mkdir_new_folder()
    local function create_folder(folder_path, file_path)
        local file = io.open(file_path, "r")
        if not file then
            os.execute('mkdir "' .. folder_path .. '"')
            file = io.open(file_path, "w")
            if file then
                file:write("A new file has been created")
                file:close()
            end
        else
            file:close()
        end
    end

    local folder = string.format("../addons/%s", addonNameLower)
    local file_path = string.format("../addons/%s/mkdir.txt", addonNameLower)
    create_folder(folder, file_path)

    g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

    g.active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addonNameLower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addonNameLower, g.active_id)
    create_folder(user_folder, user_file_path)

    g.settings_path = string.format("../addons/%s/%s/settings.json", addonNameLower, g.active_id)
end
g.mkdir_new_folder()

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

function g.save_settings()

    local function save_json(path, tbl)
        local file = io.open(path, "w")
        if file then
            local str = json.encode(tbl)
            file:write(str)
            file:close()
        end
    end

    save_json(g.settings_path, g.settings)
end

function g.load_settings()

    local function load_json(path)

        local file = io.open(path, "r")

        if file then
            local content = file:read("*all")
            file:close()
            local table = json.decode(content)
            return table
        else
            return nil
        end
    end

    local new_settings = load_json(g.settings_path)
    if not new_settings then
        new_settings = {}
    end

    if not new_settings[g.cid] then
        local old_settings = load_json(g.settingsFileLoc)
        if old_settings and old_settings.pctbl and old_settings.pctbl[g.cid] then
            new_settings[g.cid] = old_settings.pctbl[g.cid]
        end
    end

    if not new_settings[g.cid] then

        new_settings[g.cid] = {
            slot1 = nil,
            slot2 = nil,
            slot3 = nil,
            slot4 = nil
        }
    end
    g.settings = new_settings
    g.save_settings()

end

function ANCIENT_AUTOSET_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()

    if g.get_map_type() == "City" then
        local cid = session.GetMySession():GetCID()
        if not g.cid or cid ~= g.cid then
            g.cid = cid
            g.load_settings()
            addon:RegisterMsg("GAME_START", "ancient_autoset_setting")
        end
    end

    ancient_autoset_frame_init()
end

function ancient_autoset_frame_init()
    local frame = ui.GetFrame("ancient_card_list")
    local btn_aas = frame:GetChildRecursively("topbg"):CreateOrGetControl("button", "btn_aas", 0, 0, 33, 33)
    AUTO_CAST(btn_aas)
    btn_aas:SetGravity(ui.LEFT, ui.BOTTOM)
    btn_aas:SetMargin(470, 0, 0, 0)
    btn_aas:SetSkinName("None")
    btn_aas:SetImage("config_button_normal")
    btn_aas:Resize(33, 33)

    btn_aas:SetEventScript(ui.LBUTTONUP, "ANCIENT_SETTING_MSG")
    btn_aas:SetEventScript(ui.RBUTTONUP, "ANCIENT_SETTING_MSG_RELEASE")
    btn_aas:SetTextTooltip(g.lang == "Japanese" and "{ol}[AAS]左クリック:設定 右クリック:設定解除" or
                               "{ol}[AAS]Left-click:Setting Right-click:ReSetting")
end

function ancient_autoset_setting(frame, msg, str, num)

    local tbl = g.settings[g.cid]

    local target_guids = {
        [0] = tbl.slot1,
        [1] = tbl.slot2,
        [2] = tbl.slot3,
        [3] = tbl.slot4
    }

    local has_settings = false

    for slot_index = 0, 3 do
        local target_guid = tonumber(target_guids[slot_index])
        if target_guid ~= nil then
            has_settings = true
            local current_card = session.ancient.GetAncientCardBySlot(slot_index)
            local iesid = card:GetGuid()
            if current_card == nil then
                ReqSwapAncientCard(target_guid, slot_index)
            else
                local current_guid = tonumber(current_card:GetGuid())
                if target_guid ~= current_guid then
                    ReqSwapAncientCard(target_guid, slot_index)
                end
            end
        end
    end

    if not has_settings then
        local login_name = session.GetMySession():GetPCApc():GetName()
        local text = g.lang == "Japanese" and "{ol}[AAS]{#FFFFFF} " .. login_name .. " {/}アシスター未登録" or
                         "{ol}[APS]{#FFFFFF} " .. login_name .. " {/}is not registered assister"
        ui.SysMsg(text)
        return
    end
end

function ANCIENT_SETTING_MSG_RELEASE()
    local msg = g.lang == "Japanese" and
                    "このキャラクターに設定したアシスターセットを解除しますか？" or
                    "Do you want to remove the assister set for this character?"
    local yes_scp = "ANCIENT_SETTING_RELEASE()"

    ui.MsgBox(msg, yes_scp, "None");
end

function ANCIENT_SETTING_RELEASE()
    local frame = ui.GetFrame("ancient_card_list")
    local tab = frame:GetChild("tab")
    AUTO_CAST(tab)
    tab:SelectTab(0)

    for index = 0, 3 do
        local slotName = "slot" .. (index + 1)
        g.settings[g.cid][slotName] = nil
    end
    local msg = g.lang == "Japanese" and "[AAS]解除しました" or "[AAS]Canceled"
    ui.SysMsg(msg)
    g.save_settings()
end

function ANCIENT_SETTING_MSG()

    local msg = g.lang == "Japanese" and
                    "このキャラクターに表示中のアシスターセットを登録しますか？" or
                    "Would you like to register the assister set currently displayed on this character?"
    local yes_scp = "ANCIENT_SETTING_REG()"
    ui.MsgBox(msg, yes_scp, "None");
end

function ANCIENT_SETTING_REG()

    local frame = ui.GetFrame("ancient_card_list")
    local tab = frame:GetChild("tab")
    AUTO_CAST(tab)
    tab:SelectTab(0)

    for index = 0, 3 do
        local card = session.ancient.GetAncientCardBySlot(index)
        if card ~= nil then
            local iesid = card:GetGuid()
            local slotName = "slot" .. (index + 1)
            g.settings[g.cid][slotName] = iesid
        end
    end

    local msg = g.lang == "Japanese" and "[AAS]登録しました" or "AAS]Registered"
    ui.SysMsg(msg)
    g.save_settings()
end

--[[
local acutil = require("acutil")

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

function ANCIENT_AUTOSET_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function ANCIENT_AUTOSET_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if not settings then
        settings = {
            pctbl = {}
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
end]]
