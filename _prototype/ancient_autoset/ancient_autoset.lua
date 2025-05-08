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

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)

    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end
    local origin_func = g.FUNCS[origin_func_name]
    local function hooked_function(...)

        local original_results

        if bool == true then
            original_results = {origin_func(...)}
        end

        g.ARGS = g.ARGS or {}
        g.ARGS[origin_func_name] = {...}
        imcAddOn.BroadMsg(origin_func_name)

        if bool == true and original_results ~= nil then
            return table.unpack(original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function

    if not g.RAGISTER[origin_func_name] then -- g.RAGISTERはON_INIT内で都度初期化
        g.RAGISTER[origin_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
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
        new_settings = {
            presets = {}
        }
    end

    if not new_settings[g.cid] then
        local old_settings = load_json(g.settingsFileLoc)
        if old_settings and old_settings.pctbl and old_settings.pctbl[g.cid] then
            new_settings[g.cid] = old_settings.pctbl[g.cid]
        end
    end

    if not new_settings[g.cid] then
        new_settings[g.cid] = {}
    end

    g.settings = new_settings
    if not g.loaded then
        g.loaded = true
        g.save_settings()
    end
end

function ancient_autoset_frame_init()
    local ancient_card_list = ui.GetFrame("ancient_card_list")
    local topbg = GET_CHILD_RECURSIVELY(ancient_card_list, "topbg")
    local btn_aas = topbg:CreateOrGetControl("button", "btn_aas", 0, 0, 33, 33)
    AUTO_CAST(btn_aas)

    btn_aas:SetGravity(ui.LEFT, ui.BOTTOM)
    btn_aas:SetMargin(470, 0, 0, 0)
    btn_aas:SetSkinName("None")
    btn_aas:SetImage("config_button_normal")
    btn_aas:Resize(33, 33)

    btn_aas:SetEventScript(ui.LBUTTONUP, "ancient_autoset_reg")
    btn_aas:SetEventScript(ui.RBUTTONUP, "ancient_autoset_reg_release")
    btn_aas:SetTextTooltip(g.lang == "Japanese" and "{ol}[AAS]左クリック:設定{nl}右クリック:設定解除" or
                               "{ol}[AAS]Left-click:Setting{nl}Right-click:Setting Release")
end

function ancient_autoset_reg_release(frame, ctrl)
    local ancient_card_list = ui.GetFrame("ancient_card_list")
    local tab = ancient_card_list:GetChild("tab")
    AUTO_CAST(tab)
    tab:SelectTab(0)
    g.settings[g.cid] = {}
    local msg = g.lang == "Japanese" and "[AAS]解除しました" or "[AAS]Canceled"
    ui.SysMsg(msg)
    g.save_settings()
end

function ancient_autoset_reg(frame, ctrl)

    local ancient_card_list = ui.GetFrame("ancient_card_list")
    local tab = ancient_card_list:GetChild("tab")
    AUTO_CAST(tab)
    tab:SelectTab(0)

    for index = 0, 3 do
        local card = session.ancient.GetAncientCardBySlot(index)
        if card then
            local guid = card:GetGuid()
            g.settings[g.cid][tostring(index)] = guid
        else
            g.settings[g.cid][tostring(index)] = nil
        end
    end

    local msg = g.lang == "Japanese" and "[AAS]登録しました" or "AAS]Registered"
    ui.SysMsg(msg)
    g.save_settings()
end

function ancient_autoset_change_set_reserve(frame, msg, str, num)
    frame:ShowWindow(1)
    frame:RunUpdateScript("ancient_autoset_change_set", 0.3);
end

function ancient_autoset_change_set(frame)

    if g.slot_index <= 3 then
        local target_guid = g.settings[g.cid][tostring(g.slot_index)]
        if target_guid then
            g.has_setting = true
            local card = session.ancient.GetAncientCardBySlot(g.slot_index)
            if card then
                local guid = card:GetGuid()
                if target_guid ~= guid then
                    ReqSwapAncientCard(target_guid, g.slot_index)
                end
            else
                ReqSwapAncientCard(target_guid, g.slot_index)
            end
        end
        g.slot_index = g.slot_index + 1
        return 1
    end

    if not g.has_setting then
        local login_name = session.GetMySession():GetPCApc():GetName()
        local text = g.lang == "Japanese" and "{ol}[AAS]{#FFFFFF} " .. login_name .. " {/}アシスター未登録" or
                         "{ol}[APS]{#FFFFFF} " .. login_name .. " {/}is not registered assister"
        ui.SysMsg(text)
    end
    return 0
end

g.loaded = false
function ANCIENT_AUTOSET_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()

    g.RAGISTER = {}

    local cid = session.GetMySession():GetCID()
    if not g.loaded or not g.cid or cid ~= g.cid then
        g.cid = cid
        g.load_settings()
        if g.get_map_type() == "City" then
            addon:RegisterMsg("GAME_START", "ancient_autoset_change_set_reserve")
            g.slot_index = 0
            g.has_setting = false
        end
    end

    ancient_autoset_frame_init()

    g.setup_hook_and_event(addon, "ANCIENT_CARD_LIST_OPEN", "ancient_autoset_ANCIENT_CARD_LIST_OPEN", true)
    g.setup_hook_and_event(addon, "ANCIENT_CARD_LIST_CLOSE", "ancient_autoset_ANCIENT_CARD_LIST_CLOSE", true)
end

function ancient_autoset_ANCIENT_CARD_LIST_CLOSE(frame, msg)
    frame:ShowWindow(0)
end

function ancient_autoset_ANCIENT_CARD_LIST_OPEN(frame, msg)

    local ancient_card_list = ui.GetFrame("ancient_card_list")
    frame:RemoveAllChild()
    frame:SetLayerLevel(92);
    frame:SetSkinName('None');
    frame:SetTitleBarSkin("None")

    frame:SetPos(ancient_card_list:GetX() + 710, ancient_card_list:GetY() + 100);

    frame:Resize(707, 400);
    frame:ShowWindow(1);

    frame:SetAnimation("frameOpenAnim", "chat_balloon_start")
    frame:SetAnimation("frameCloseAnim", "chat_balloon_end");

    local bg = frame:CreateOrGetControl("groupbox", "bg", 705, 360, ui.LEFT, ui.TOP, 0, 40, 0, 0);
    AUTO_CAST(bg)
    bg:SetSkinName("test_frame_low")
    bg:EnableHittestGroupBox(false)

    local title_bg = frame:CreateOrGetControl("groupbox", "title_bg", 705, 61, ui.LEFT, ui.TOP, 0, 0, 0, 0);
    AUTO_CAST(title_bg)
    title_bg:SetSkinName("test_frame_top")
    title_bg:EnableHittestGroupBox(false)

    local title = frame:CreateOrGetControl("richtext", "title", 100, 30, ui.CENTER_HORZ, ui.TOP, 0, 18, 0, 0);
    title:SetText("{@st43}{s22}Assister Preset Setting{/}")
    title:EnableHitTest(false)

    local close = frame:CreateOrGetControl("button", "close", 44, 44, ui.RIGHT, ui.TOP, 0, 20, 17, 0);
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetTextTooltip("{ol}Close the Assister Preset window")
    close:SetEventScript(ui.LBUTTONUP, "ancient_autoset_ANCIENT_CARD_LIST_CLOSE");

    local topbg = frame:CreateOrGetControl("groupbox", "topbg", 665, 315, ui.LEFT, ui.TOP, 20, 100, 0, 0);
    AUTO_CAST(topbg)
    topbg:EnableHittestGroupBox(false)

    local ancient_card_slot_gbox = topbg:CreateOrGetControl("groupbox", "ancient_card_slot_gbox", 665, 275, ui.LEFT,
                                                            ui.TOP, 0, 0, 0, 0);
    AUTO_CAST(ancient_card_slot_gbox)
    ancient_card_slot_gbox:EnableHittestGroupBox(false)
    ancient_card_slot_gbox:SetSkinName("test_frame_midle")

    local tab = frame:CreateOrGetControl("tab", "tab", 664, 40, ui.LEFT, ui.TOP, 22, 65, 0, 0);
    AUTO_CAST(tab)
    tab:SetEventScript(ui.LBUTTONUP, "ancient_autoset_tab_change");
    tab:SetSkinName("tab2")
    for i = 1, 10 do
        tab:AddItem("{@st66b}{s16}Set " .. i, true, "", "", "", "", "", false)
    end
    tab:SetItemsFixWidth(66)
    tab:SetItemsAdjustFontSizeByWidth(66);

    local swap = frame:CreateOrGetControl("button", "swap", 100, 45, ui.RIGHT, ui.TOP, 0, 325, 30, 0);
    swap:SetSkinName("test_pvp_btn")
    swap:SetText("{@st42}{s18}Change")
    swap:SetEventScript(ui.LBUTTONUP, "ancient_autoset_card_change");
    ancient_autoset_tab_change(frame)

end

function ancient_autoset_tab_change(frame)

    local tab = GET_CHILD(frame, "tab")
    AUTO_CAST(tab)
    local tab_index = tab:GetSelectItemIndex()

    ancient_autoset_load_slots(frame, tab_index)
end

function ancient_autoset_load_slots(frame, tab_index)
    local gbox = GET_CHILD_RECURSIVELY(frame, 'ancient_card_slot_gbox')

    gbox:RemoveAllChild()
    local width = 4
    for index = 0, 3 do
        local ctrlSet = gbox:CreateControlSet("ancient_card_item_slot", "SLOT_" .. index, width, 4);
        width = width + ctrlSet:GetWidth() + 2
        local ancient_card_gbox = GET_CHILD(ctrlSet, "ancient_card_gbox")
        ancient_card_gbox:SetVisible(0)
        ctrlSet:SetUserValue("INDEX", index)
        ctrlSet:EnableHitTest(1)
        local slot = GET_CHILD_RECURSIVELY(ctrlSet, "ancient_card_slot")
        AUTO_CAST(slot)
        local icon = CreateIcon(slot);
        slot:EnableHitTest(1)
        ctrlSet:SetEventScript(ui.DROP, 'ancient_autoset_frame_drop');
        ctrlSet:SetEventScript(ui.RBUTTONDOWN, 'ancient_autoset_swap_rbtndown');

        if index == 0 then
            local gold_border = GET_CHILD_RECURSIVELY(ctrlSet, "gold_border")
            AUTO_CAST(gold_border)
            gold_border:SetImage('monster_card_g_frame_02')
        end

        if g.settings and g.settings.presets and g.settings.presets[tostring(tab_index)] then
            local preset_data = g.settings.presets[tostring(tab_index)]
            if preset_data[tostring(index)] then
                local guid = preset_data[tostring(index)]
                if guid then
                    local card = session.ancient.GetAncientCardByGuid(guid)
                    if card then
                        SET_ANCIENT_CARD_SLOT(ctrlSet, card)
                    end
                end
            end
        end
        local default_image = GET_CHILD_RECURSIVELY(ctrlSet, "default_image")
        AUTO_CAST(default_image)
        default_image:SetImage("socket_slot_bg")
    end
end

function ancient_autoset_card_change(frame, ctrl)

    if IS_ANCIENT_ENABLE_MAP() == "YES" then
        addon.BroadMsg("NOTICE_Dm_!", ClMsg("ImpossibleInCurrentMap"), 3);
        return
    end

    local tab = GET_CHILD(frame, "tab")
    AUTO_CAST(tab)
    local tab_index = tab:GetSelectItemIndex()

    if not g.settings.presets[tostring(tab_index)] then
        return
    end
    g.tab_index = tab_index
    g.slot_index = 0
    frame:RunUpdateScript("ancient_autoset_put_card_slot", 0.3);
end

function ancient_autoset_put_card_slot(frame)

    local target_guid = g.settings.presets[tostring(g.tab_index)][tostring(g.slot_index)]

    if g.slot_index <= 3 then
        if target_guid then

            local card = session.ancient.GetAncientCardBySlot(g.slot_index)
            if card then
                local guid = card:GetGuid()
                if target_guid ~= guid then
                    ReqSwapAncientCard(target_guid, g.slot_index)
                end
            else
                ReqSwapAncientCard(target_guid, g.slot_index)
            end

        end
        g.slot_index = g.slot_index + 1
        return 1
    end

    g.tab_index = nil
    g.slot_index = 0
    return 0
end

function ancient_autoset_swap_rbtndown(parent, ctrl, str, num)
    local to_index = ctrl:GetUserIValue("INDEX")
    local frame = parent:GetTopParentFrame();
    local tab = GET_CHILD(frame, "tab")
    AUTO_CAST(tab)
    local tab_index = tab:GetSelectItemIndex()

    if not g.settings.presets[tostring(tab_index)] then
        return
    end
    g.settings.presets[tostring(tab_index)][tostring(to_index)] = nil
    g.save_settings()
    ancient_autoset_tab_change(frame)
end

function ancient_autoset_frame_drop(parent, ctrl, str, num)
    local to_index = ctrl:GetUserIValue("INDEX")

    local ancient_card_list = ui.GetFrame("ancient_card_list")

    local frame = parent:GetTopParentFrame();
    local tab = GET_CHILD(frame, "tab")
    AUTO_CAST(tab)
    local tab_index = tab:GetSelectItemIndex()

    local guid = ancient_card_list:GetUserValue("LIFTED_GUID")
    local card = session.ancient.GetAncientCardByGuid(guid)

    if not g.settings.presets[tostring(tab_index)] then
        g.settings.presets[tostring(tab_index)] = {}
    end

    g.settings.presets[tostring(tab_index)][tostring(to_index)] = guid
    g.save_settings()
    ancient_autoset_tab_change(frame)
    ancient_card_list:SetUserValue("LIFTED_GUID", "None")
end

--[[

function ANCIENT_SETTING_MSG()

    local msg = g.lang == "Japanese" and
                    "このキャラクターに表示中のアシスターセットを登録しますか？" or
                    "Would you like to register the assister set currently displayed on this character?"
    local yes_scp = "ANCIENT_SETTING_REG()"
    ui.MsgBox(msg, yes_scp, "None");
end
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
