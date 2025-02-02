-- v1.0.0 作ってみた
-- v1.0.1 見直した。自動フォルダ作成機能。
-- v1.0.2 回数の色の挙動修正。一般公開。
-- v1.0.3 バフ登録時のバグ修正
-- v1.0.4 エフェクト消えなかったの修正
-- v1.0.5 バフリストから登録するバフ選べる様に
-- v1.0.6 バフリストバグ修正
-- v1.0.7 街では景観を損ねるので非表示に
-- v1.0.8 セッティングフレームの高さ足りなかったの修正
local addonName = "skill_notice_free"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.8"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require("json")
local os = require("os")

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addonNameLower)
    local file_path = string.format("../addons/%s/mkdir.txt", addonNameLower)
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
g.mkdir_new_folder()

g.settings_file_path = string.format("../addons/%s/settings.json", addonNameLower)
g.get_buffs_file_path = string.format("../addons/%s/get_buffs.json", addonNameLower)

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName]
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

local color_tabel = {
    [1] = "C0C0C0", -- シルバー
    [2] = "ADFF2F", -- 黄緑
    [3] = "FFFF00", -- 黄色
    [4] = "FF4500", -- オレンジ
    [5] = "00FF00", -- 緑
    [6] = "1E90FF", -- 青
    [7] = "800080", -- 紫
    [8] = "8B4513", -- 茶色
    [9] = "FF1493", -- ピンク
    [10] = "4682B4" -- 白
}

local sound_list = {
    [1] = "None",
    [2] = "premium_enchantchip",
    [3] = "system_craft_potion_succes",
    [4] = "sys_confirm",
    [5] = "sys_cube_open_normal",
    [6] = "sys_cube_open_jackpot",
    [7] = "sys_tp_box_3",
    [8] = "sys_tp_box_4",
    [9] = "sys_transcend_cast",
    [10] = "sys_card_battle_roulette_turn_end",
    [11] = "sys_card_battle_rival_slot_show",
    [12] = "sys_card_battle_percussion_timpani",
    [13] = "sys_jam_slot_equip",
    [14] = "button_inven_click_item",
    [15] = "sys_secret_alarm",
    [16] = "sys_transcend_success",
    [17] = "sys_quest_item_get",
    [18] = "quest_success_1",
    [19] = "monster_state_1",
    [20] = "button_click_stats_up",
    [21] = "sys_atk_booster_on",
    [22] = "market buy",
    [23] = "statsup"
}

local effect_list = {
    [1] = "None",
    [2] = "F_pattern025_loop",
    [3] = "F_buff_Cleric_Haste_Buff",
    [4] = "F_ground013",
    [5] = "F_archer_SiegeBurst_explosion2",
    [6] = "F_spread_in044_ghost2_fast",
    [7] = "F_spread_in002_violet",
    [8] = "F_fire038_loop",
    [9] = "F_spin008",
    [10] = "F_archere_magicarrow_gruond_loop2"
}

function SKILL_NOTICE_FREE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.buffs = {}

    addon:RegisterMsg("GAME_START", "skill_notice_free_load_settings")
    addon:RegisterMsg("BUFF_UPDATE", "skill_notice_free_buff_update")
    addon:RegisterMsg("BUFF_ADD", "skill_notice_free_buff_add")
    addon:RegisterMsg("BUFF_REMOVE", "skill_notice_free_buff_remove")
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType ~= "City" then
        addon:RegisterMsg("GAME_START", "skill_notice_free_frame_init")
    end
    addon:RegisterMsg("FPS_UPDATE", "skill_notice_free_FPS_UPDATE")
    addon:RegisterMsg("GAME_START", "skill_notice_free_start_frame")
end

function skill_notice_free_start_frame()
    local start_frame = ui.CreateNewFrame("chat_memberlist", addonNameLower .. "start_frame", 0, 0, 0, 0)
    AUTO_CAST(start_frame)

    start_frame:RemoveAllChild()
    start_frame:SetSkinName("None")
    start_frame:SetTitleBarSkin("None")
    start_frame:EnableHitTest(1)
    start_frame:SetPos(1820, 305)
    start_frame:ShowWindow(1)
    start_frame:Resize(30, 30)

    local setting_button = start_frame:CreateOrGetControl('button', 'setting_button', 0, 0, 25, 30)
    setting_button:SetSkinName("None")
    setting_button:SetText("{img sysmenu_skill 30 30}")
    setting_button:SetEventScript(ui.LBUTTONUP, "skill_notice_free_setting")
    local tooltip_text = "{ol}Skill Notice{nl}Left-Click Settings"
    setting_button:SetTextTooltip(tooltip_text)

end

function skill_notice_free_FPS_UPDATE()

    local start_frame = ui.GetFrame(addonNameLower .. "start_frame")

    if start_frame:IsVisible() == 0 then
        local pc = GetMyPCObject();
        local curMap = GetZoneName(pc)
        local mapCls = GetClass("Map", curMap)
        if mapCls.MapType ~= "City" then
            skill_notice_free_frame_init()
        end
        skill_notice_free_start_frame()
    else
        return
    end
end

function skill_notice_free_load_settings()

    local settings, err = acutil.loadJSON(g.settings_file_path, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then
        settings = {
            x = 400,
            y = 400,
            icon_x = 500,
            icon_y = 500,
            buffs = {}
        }
    end

    g.cid = session.GetMySession():GetCID()
    if not settings[tostring(g.cid)] then
        settings[tostring(g.cid)] = {}
    end

    g.settings = settings
    skill_notice_free_save_settings()

    local get_buffs, err = acutil.loadJSON(g.get_buffs_file_path, g.get_buffs)
    if not get_buffs then
        get_buffs = {}
    end
    g.get_buffs = get_buffs
    acutil.saveJSON(g.get_buffs_file_path, g.get_buffs)
end

function skill_notice_free_save_settings()
    acutil.saveJSON(g.settings_file_path, g.settings)
end

function skill_notice_free_end_drag(frame, ctrl, str, num)

    if frame:GetName() == "skill_notice_free" then
        g.settings.x = frame:GetX()
        g.settings.y = frame:GetY()
    elseif frame:GetName() == addonNameLower .. "icon_frame" then
        g.settings.icon_x = frame:GetX()
        g.settings.icon_y = frame:GetY()
    end
    skill_notice_free_save_settings()
end

function skill_notice_free_frame_init()

    local frame = ui.GetFrame("skill_notice_free")
    frame:RemoveAllChild()
    frame:SetSkinName("chat_window")
    frame:SetAlpha(20)
    frame:SetTitleBarSkin("None")
    frame:EnableMove(1)
    frame:EnableHitTest(1)
    frame:SetEventScript(ui.LBUTTONUP, "skill_notice_free_end_drag")
    frame:SetEventScript(ui.RBUTTONUP, "skill_notice_free_setting")
    frame:SetPos(g.settings.x or 400, g.settings.y or 400)

    local buffgb = frame:CreateOrGetControl("groupbox", "buffgb", 0, 20, 190, 25)
    buffgb:SetSkinName("None")
    buffgb:RemoveAllChild()

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]
    local icon_count = 1

    local icon_frame = ui.CreateNewFrame("chat_memberlist", addonNameLower .. "icon_frame", 0, 0, 0, 0)
    AUTO_CAST(icon_frame)

    icon_frame:RemoveAllChild()
    icon_frame:SetSkinName("None")
    icon_frame:SetTitleBarSkin("None")
    icon_frame:SetAlpha(30)
    icon_frame:SetLayerLevel(61)
    icon_frame:EnableHitTest(1)
    icon_frame:EnableMove(1)
    icon_frame:SetPos(g.settings.icon_x or 500, g.settings.icon_y or 500)
    icon_frame:SetEventScript(ui.LBUTTONUP, "skill_notice_free_end_drag")
    icon_frame:ShowWindow(1)
    icon_frame:Resize(0, 0)

    local y = 0
    for str_buff_id, _ in pairs(buff_table) do

        if cid_table[str_buff_id] == nil then
            cid_table[str_buff_id] = "YES"
        end

        local buff_id = tonumber(str_buff_id)
        local mode = buff_table[str_buff_id].mode

        if cid_table[str_buff_id] == "YES" then

            local my_handle = session.GetMyHandle()
            local info_buff = info.GetBuff(my_handle, buff_id)
            local buff_class = GetClassByType("Buff", buff_id)

            if mode == "icon" then

                local icon_slot = icon_frame:CreateOrGetControl("slot", "icon_slot" .. buff_id, (icon_count - 1) * 50,
                    10, 50, 50)
                AUTO_CAST(icon_slot)
                icon_slot:EnablePop(0)
                icon_slot:EnableDrop(0)
                icon_slot:EnableDrag(0)
                icon_slot:SetSkinName("invenslot2")
                local image_name = GET_BUFF_ICON_NAME(buff_class)
                SET_SLOT_ICON(icon_slot, image_name)
                icon_slot:EnableHitTest(0)

                local buff_name = buff_class.ClassName
                local icon = CreateIcon(icon_slot)
                AUTO_CAST(icon)
                icon:SetTooltipType("buff")
                icon:SetTooltipArg(buff_name, buff_id, 0)
                icon_slot:Invalidate()

                local buff_count = icon_slot:CreateOrGetControl("richtext", "buff_count" .. buff_id, 0, 0, 40, 40)
                AUTO_CAST(buff_count)
                buff_count:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
                buff_count:SetColorTone("FFFFFFFF")
                if info_buff == nil then
                    buff_count:SetText("{ol}{s35}0")
                else
                    buff_count:SetText("{ol}{s35}" .. info_buff.over)
                end

                icon_frame:Resize(icon_count * 50 + 10, 50 + 10)
                icon_count = icon_count + 1

            else
                local gauge = buffgb:CreateOrGetControl("gauge", "gauge" .. buff_id, 10, y * 25 + 10, 160, 20)
                AUTO_CAST(gauge)
                local max_charge = buff_table[str_buff_id].max_charge
                local color = buff_table[str_buff_id].color

                gauge:SetSkinName("gauge")
                gauge:SetColorTone(color)
                if info_buff ~= nil then
                    gauge:SetPoint(info_buff.over, max_charge)
                    gauge:AddStat("{ol}{s20}%v/%m")
                    gauge:SetStatFont(0, "quickiconfont")
                    gauge:SetStatOffset(0, -10, 0)
                    gauge:SetStatAlign(0, ui.RIGHT, ui.CENTER_VERT)
                else
                    gauge:SetPoint(0, max_charge)
                    gauge:AddStat("{ol}{s20}%v/%m")
                    gauge:SetStatFont(0, "quickiconfont")
                    gauge:SetStatOffset(0, -10, 0)
                    gauge:SetStatAlign(0, ui.RIGHT, ui.CENTER_VERT)
                end

                local buff_text = buffgb:CreateOrGetControl("richtext", "buff_text" .. buff_id, 0, y * 25 + 10, 160, 20)
                AUTO_CAST(buff_text)
                local dic_buff_name = buff_class.Name
                buff_text:SetText("{ol}{s12}" .. dic_buff_name)

                y = y + 1
            end
        end

    end
    skill_notice_free_save_settings()

    buffgb:Resize(180, y * 25 + 30)
    frame:Resize(180, y * 25 + 30)
    frame:ShowWindow(1)
end

function skill_notice_free_buff_list_open(frame, ctrl, str, num)
    local buff_list_frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "buff_list_frame", 0, 0, 10, 10)
    AUTO_CAST(buff_list_frame)
    buff_list_frame:SetSkinName("bg")
    buff_list_frame:Resize(500, 1060)
    buff_list_frame:SetPos(1400, 10)
    buff_list_frame:SetLayerLevel(121)
    buff_list_frame:RemoveAllChild()

    local buff_list_gb = buff_list_frame:CreateOrGetControl("groupbox", " buff_list_gb", 5, 35, 490, 1015)
    AUTO_CAST(buff_list_gb)
    buff_list_gb:SetSkinName("bg")

    local close_button = buff_list_frame:CreateOrGetControl('button', 'close_button', 0, 0, 20, 20)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "skill_notice_free_buff_list_close");

    local get_buffs, err = acutil.loadJSON(g.get_buffs_file_path, g.get_buffs)

    local sorted_buffs = {}
    for buff_id, _ in pairs(get_buffs) do
        table.insert(sorted_buffs, tonumber(buff_id))
    end
    table.sort(sorted_buffs)

    local title_text = buff_list_frame:CreateOrGetControl('richtext', 'title_text', 10, 10, 200, 30)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Setting Buff List")

    -- ソートされた順番で表示
    local y = 0
    for _, buff_id in ipairs(sorted_buffs) do

        local buff_slot = buff_list_gb:CreateOrGetControl('slot', 'buffslot' .. buff_id, 10, y + 5, 30, 30)
        AUTO_CAST(buff_slot)
        local buff_class = GetClassByType("Buff", buff_id)

        if buff_class ~= nil then
            local image_name = GET_BUFF_ICON_NAME(buff_class)
            if image_name ~= "icon_None" then
                local buff_name = buff_class.Name
                if buff_name ~= "None" then

                    SET_SLOT_IMG(buff_slot, GET_BUFF_ICON_NAME(buff_class));

                    local icon = CreateIcon(buff_slot)
                    AUTO_CAST(icon)
                    icon:SetTooltipType('buff');

                    icon:SetTooltipArg(buff_name, buff_id, 0);

                    local buff_set = buff_list_gb:CreateOrGetControl('button', 'buff_set' .. buff_id, 45, y + 5, 40, 30)
                    AUTO_CAST(buff_set)
                    buff_set:SetText("{ol}Set")
                    buff_set:SetTextTooltip("{ol}Add to monitoring buffs")
                    buff_set:SetEventScript(ui.LBUTTONUP, "skill_notice_free_add_monitoring_buff")
                    buff_set:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

                    local buff_text = buff_list_gb:CreateOrGetControl('richtext', 'buff_text' .. buff_id, 90, y + 10,
                        200, 30)
                    AUTO_CAST(buff_text)
                    buff_text:SetText("{ol}" .. buff_id .. " : " .. buff_name)
                    buff_text:AdjustFontSizeByWidth(400)
                    y = y + 35
                end
            end
        end

    end

    buff_list_frame:ShowWindow(1)
end

function skill_notice_free_add_monitoring_buff(frame, ctrl, str, buff_id)
    local buff_table = g.settings["buffs"]
    local str_buff_id = tostring(buff_id)
    local buff_class = GetClassByType("Buff", buff_id)
    local buff_name = buff_class.ClassName

    if buff_table[str_buff_id] == nil then

        buff_table[str_buff_id] = {}
        buff_table[str_buff_id].name = buff_name
        buff_table[str_buff_id].color = "FFFFFF00"
        buff_table[str_buff_id].effect = "None"
        buff_table[str_buff_id].sound = "None"
        buff_table[str_buff_id].size = 2
        buff_table[str_buff_id].max_charge = 10
        buff_table[str_buff_id].mode = "gauge"
        skill_notice_free_save_settings()
        skill_notice_free_frame_init()
        skill_notice_free_setting(nil, nil, nil, nil)
    end
end

function skill_notice_free_buff_list_close(frame, ctrl, argStr, argNum)

    frame:ShowWindow(0)
    skill_notice_free_setting(nil, nil, nil, nil)
end

function skill_notice_free_setting(frame, ctrl, str, num)

    skill_notice_free_frame_init()

    local setting_frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "setting_frame", 0, 0, 200, 400)
    AUTO_CAST(setting_frame)
    setting_frame:SetSkinName("test_frame_low")
    setting_frame:SetPos(20, 20)
    setting_frame:SetLayerLevel(80)
    setting_frame:RemoveAllChild()

    local gb = setting_frame:CreateOrGetControl("groupbox", "gb", 10, 40, 615, 0)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")

    local title_text = setting_frame:CreateOrGetControl("richtext", "title_text", 20, 10, 200, 20)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Skill Notice Setting")

    local close = setting_frame:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "skill_notice_free_newframe_close")

    local buff_list = setting_frame:CreateOrGetControl("button", "buff_list", 500, 10, 80, 30)
    AUTO_CAST(buff_list)
    buff_list:SetSkinName("test_red_button")
    buff_list:SetText("{ol}Buff List")
    buff_list:SetEventScript(ui.LBUTTONUP, "skill_notice_free_buff_list_open")

    local y = 30
    local index = 1

    local function create_slot_and_edit(index, y, buff_id)

        local buff_slot = gb:CreateOrGetControl("slot", "buff_slot" .. buff_id, 10, y, 50, 50)
        AUTO_CAST(buff_slot)
        buff_slot:EnablePop(0)
        buff_slot:EnableDrop(0)
        buff_slot:EnableDrag(0)
        buff_slot:SetSkinName("invenslot2")

        local buffid_edit = gb:CreateOrGetControl("edit", "buffid_edit" .. buff_id, 10, y - 20, 70, 20)
        AUTO_CAST(buffid_edit)
        buffid_edit:SetFontName("white_16_ol")
        buffid_edit:SetTextAlign("center", "center")
        buffid_edit:SetEventScript(ui.ENTERKEY, "skill_notice_free_buffid_edit")
        buffid_edit:SetEventScriptArgString(ui.ENTERKEY, buff_id)
        buffid_edit:SetEventScriptArgNumber(ui.ENTERKEY, index)

        local buff_class = GetClassByType("Buff", buff_id)

        if buff_class then

            buffid_edit:SetText(buff_id)

            local buff_name = buff_class.ClassName
            local image_name = GET_BUFF_ICON_NAME(buff_class)
            SET_SLOT_ICON(buff_slot, image_name)

            local icon = CreateIcon(buff_slot)
            AUTO_CAST(icon)
            icon:SetTooltipType("buff")
            icon:SetTooltipArg(buff_name, buff_id, 0)
            buff_slot:Invalidate()

            skill_notice_free_buffid_edit(frame, buffid_edit, buff_id, index)

        end

    end

    local buff_table = g.settings["buffs"]

    if next(buff_table) == nil then
        create_slot_and_edit(index, y, 0)
    else
        for str_buff_id, _ in pairs(buff_table) do
            local buff_id = tonumber(str_buff_id)
            create_slot_and_edit(index, y, buff_id)
            index = index + 1
            y = y + 80
        end
        create_slot_and_edit(index, y, 0)
    end

    setting_frame:Resize(660, y + 60)
    gb:Resize(setting_frame:GetWidth() - 20, setting_frame:GetHeight() - 50)
    setting_frame:ShowWindow(1)
end

function skill_notice_free_newframe_close(frame, ctrl, argStr, argNum)

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType ~= "City" then
        skill_notice_free_frame_init()
    else
        local snf_frame = ui.GetFrame("skill_notice_free")
        snf_frame:ShowWindow(0)
        local snf_icon_frame = ui.GetFrame(addonNameLower .. "icon_frame")
        snf_icon_frame:ShowWindow(0)
    end
    frame:ShowWindow(0)

end

function skill_notice_free_buffid_edit(frame, buffid_edit, buff_id, index)

    local topframe = ui.GetFrame(addonNameLower .. "setting_frame")
    local frame = GET_CHILD_RECURSIVELY(topframe, "gb")

    local buff_id = tonumber(buffid_edit:GetText())
    if buff_id == nil or buff_id == 0 then
        buffid_edit:SetText("")
        return
    end

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]
    local str_buff_id = tostring(buff_id)
    local buff_class = GetClassByType("Buff", buff_id)

    if buff_class ~= nil then

        local buff_name = buff_class.ClassName

        if buff_table[str_buff_id] == nil then

            buff_table[str_buff_id] = {}
            buff_table[str_buff_id].name = buff_name
            buff_table[str_buff_id].color = "FFFFFF00"
            buff_table[str_buff_id].effect = "None"
            buff_table[str_buff_id].sound = "None"
            buff_table[str_buff_id].size = 2
            buff_table[str_buff_id].max_charge = 10
            buff_table[str_buff_id].mode = "gauge"
            skill_notice_free_save_settings()
            skill_notice_free_frame_init()
            skill_notice_free_setting(nil, nil, nil, nil)
        end

        local buff_slot = GET_CHILD_RECURSIVELY(frame, "buff_slot" .. buff_id)
        local image_name = GET_BUFF_ICON_NAME(buff_class)
        SET_SLOT_ICON(buff_slot, image_name)

        local icon = CreateIcon(buff_slot)
        AUTO_CAST(icon)
        icon:SetTooltipType("buff")
        icon:SetTooltipArg(buff_name, buff_id, 0)
        buff_slot:Invalidate()

        local y = index == 1 and 30 or (index - 1) * 80 + 30
        local buff_text = frame:CreateOrGetControl("richtext", "buff_text" .. buff_id, 115, y - 20, 200, 20)
        AUTO_CAST(buff_text)
        local dic_buff_name = buff_class.Name
        buff_text:SetText("{ol}" .. dic_buff_name)

        local sound_text = frame:CreateOrGetControl("richtext", "sound_text" .. buff_id, 70, y, 200, 20)
        AUTO_CAST(sound_text)
        sound_text:SetText("{ol}Sound Config")

        local sound_config = frame:CreateOrGetControl("button", "sound_config" .. buff_id, 180, y, 25, 25)
        AUTO_CAST(sound_config)
        sound_config:SetSkinName("None")
        sound_config:SetText("{img config_button_normal 25 25}")
        sound_config:SetEventScript(ui.LBUTTONUP, "skill_notice_free_sound_select")
        sound_config:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

        local color_text = frame:CreateOrGetControl("richtext", "color_text" .. buff_id, 215, y, 200, 20)
        AUTO_CAST(color_text)
        color_text:SetText("{ol}Gauge Color")

        local color_box = frame:CreateOrGetControl("groupbox", "color_box" .. buff_id, 315, y, 220, 20)
        AUTO_CAST(color_box)
        for i = 0, 9 do
            local color_class = color_tabel[i + 1]

            if color_class ~= nil then
                local color = color_box:CreateOrGetControl("picture", "color" .. buff_id .. "_" .. i, 20 * i, 0, 20, 20)
                AUTO_CAST(color)
                color:SetImage("chat_color")
                color:SetColorTone("FF" .. color_class)
                color:SetEventScript(ui.LBUTTONUP, "skill_notice_free_color_select")
                color:SetEventScriptArgString(ui.LBUTTONUP, buff_name .. "/" .. "FF" .. color_class)
                color:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

            end
        end

        local effect_text = frame:CreateOrGetControl("richtext", "effect_text" .. buff_id, 70, y + 30, 200, 20)
        AUTO_CAST(effect_text)
        effect_text:SetText("{ol}Effect Config")

        local effect_config = frame:CreateOrGetControl("button", "effect_config" .. buff_id, 180, y + 30, 25, 25)
        AUTO_CAST(effect_config)
        effect_config:SetSkinName("None")
        effect_config:SetText("{img config_button_normal 25 25}")
        effect_config:SetEventScript(ui.LBUTTONUP, "skill_notice_free_effect_select")
        effect_config:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

        local size_text = frame:CreateOrGetControl("richtext", "size_text" .. buff_id, 215, y + 30, 200, 20)
        AUTO_CAST(size_text)
        size_text:SetText("{ol}Effect Size")

        local size_edit = frame:CreateOrGetControl("edit", "size_edit" .. buff_id, 310, y + 30, 40, 20)
        AUTO_CAST(size_edit)
        size_edit:SetFontName("white_16_ol")
        size_edit:SetTextAlign("center", "center")
        local size = buff_table[str_buff_id].size
        size_edit:SetText("{ol}" .. size)
        size_edit:SetEventScript(ui.ENTERKEY, "skill_notice_free_size_edit")
        size_edit:SetEventScriptArgNumber(ui.ENTERKEY, buff_id)

        local charge_text = frame:CreateOrGetControl("richtext", "charge_text" .. buff_id, 355, y + 30, 200, 20)
        AUTO_CAST(charge_text)
        charge_text:SetText("{ol}Max Charge")

        local charge_edit = frame:CreateOrGetControl("edit", "charge_edit" .. buff_id, 455, y + 30, 40, 20)
        AUTO_CAST(charge_edit)
        charge_edit:SetFontName("white_16_ol")
        charge_edit:SetTextAlign("center", "center")
        local charge = buff_table[str_buff_id].max_charge
        charge_edit:SetText("{ol}" .. charge)
        charge_edit:SetEventScript(ui.ENTERKEY, "skill_notice_free_charge_edit")
        charge_edit:SetEventScriptArgNumber(ui.ENTERKEY, buff_id)

        local display_text = frame:CreateOrGetControl("richtext", "display_text" .. buff_id, 520, y, 200, 20)
        AUTO_CAST(display_text)
        display_text:SetText("{ol}Display")

        local display_check = frame:CreateOrGetControl("checkbox", "display_check" .. buff_id, 585, y - 5, 20, 20)
        AUTO_CAST(display_check)
        display_check:SetTextTooltip("Displayed when checked{nl}Set by character")

        display_check:SetCheck(cid_table[str_buff_id] == "YES" and 1 or 0)
        display_check:SetEventScript(ui.LBUTTONUP, "skill_notice_free_setting_check")
        display_check:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

        local mode_text = frame:CreateOrGetControl("richtext", "mode_text" .. buff_id, 520, y + 30, 200, 20)
        AUTO_CAST(mode_text)
        mode_text:SetText("{ol}Mode")

        local mode_check = frame:CreateOrGetControl("checkbox", "mode_check" .. buff_id, 585, y + 25, 20, 20)
        AUTO_CAST(mode_check)
        mode_check:SetTextTooltip("Icon mode when checked")
        local mode_set = 0
        if buff_table[str_buff_id].mode ~= "gauge" then
            mode_set = 1
        end
        mode_check:SetCheck(mode_set)
        mode_check:SetEventScript(ui.LBUTTONUP, "skill_notice_free_setting_check")
        mode_check:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

        local delete_btn = frame:CreateOrGetControl("button", "delete_btn" .. buff_id, 85, y - 25, 30, 30)
        AUTO_CAST(delete_btn)
        delete_btn:SetSkinName("test_red_button")
        delete_btn:SetText("{ol}×")
        delete_btn:SetEventScript(ui.LBUTTONUP, "skill_notice_free_setting_delete")
        delete_btn:SetEventScriptArgNumber(ui.LBUTTONUP, buff_id)

    end
end

function skill_notice_free_sound_select(frame, ctrl, str, buff_id)

    local context = ui.CreateContextMenu("SOUND_SETTING", "Sound Setting", 300, 0, 100, 100)
    for i, sound in ipairs(sound_list) do
        local script = string.format("skill_notice_free_sound_setting(%d,'%s')", buff_id, sound)
        ui.AddContextMenuItem(context, sound, script)
    end
    ui.OpenContextMenu(context)
end

function skill_notice_free_sound_setting(buff_id, sound)

    imcSound.PlaySoundEvent(sound)
    local buff_table = g.settings["buffs"]
    local str_buff_id = tostring(buff_id)
    if buff_table[str_buff_id] then
        buff_table[str_buff_id].sound = sound
        skill_notice_free_save_settings()
    end
end

function skill_notice_free_color_select(frame, ctrl, connect_str, buff_id)

    local split = SCR_STRING_CUT(connect_str, "/")
    local buff_name = split[1]
    local color_name = split[2]
    local str_buff_id = tostring(buff_id)

    local buff_table = g.settings["buffs"]
    if buff_table[str_buff_id] then
        buff_table[str_buff_id].color = color_name
        skill_notice_free_save_settings()
    end

    skill_notice_free_color_test_gauge(buff_name, color_name, buff_id)
    skill_notice_free_frame_init()
end

function skill_notice_free_color_test_gauge(buff_name, color_name, buff_id)
    local frame = ui.GetFrame(addonNameLower .. "setting_frame")

    local gauge_box = frame:CreateOrGetControl("groupbox", "gauge_box", 100, 10, 200, 30)
    AUTO_CAST(gauge_box)
    gauge_box:RemoveAllChild()

    local gauge = gauge_box:CreateOrGetControl("gauge", "gauge", 5, 5, 180, 20)
    AUTO_CAST(gauge)
    imcSound.PlaySoundEvent("sys_tp_box_3")
    ui.SysMsg(buff_name .. ":Gauge Color Setting")
    gauge:SetSkinName("gauge")
    gauge:SetColorTone(color_name)
    gauge:SetPoint(5, 10)
    gauge:AddStat("{ol}{s20}%v/%m")
    gauge:SetStatFont(0, "quickiconfont")
    gauge:SetStatOffset(0, -10, 0)
    gauge:SetStatAlign(0, ui.RIGHT, ui.CENTER_VERT)

    frame:ShowWindow(1)
    gauge_box:ShowWindow(1)
    ReserveScript("skill_notice_free_color_test_close()", 3.0)
end

function skill_notice_free_color_test_close()
    local frame = ui.GetFrame(addonNameLower .. "setting_frame")
    local gauge_box = GET_CHILD_RECURSIVELY(frame, "gauge_box")
    gauge_box:ShowWindow(0)
end

function skill_notice_free_effect_select(frame, ctrl, str, buff_id)

    local context = ui.CreateContextMenu("SOUND_SETTING", "Effect Setting", 300, 0, 100, 100)
    for i, effect_name in ipairs(effect_list) do
        local script = string.format("skill_notice_free_effect_setting(%d,'%s')", buff_id, effect_name)
        ui.AddContextMenuItem(context, effect_name, script)
    end
    ui.OpenContextMenu(context)
end

function skill_notice_free_effect_setting(buff_id, effect_name)

    local buff_table = g.settings["buffs"]
    local str_buff_id = tostring(buff_id)

    if buff_table[str_buff_id] then
        buff_table[str_buff_id].effect = effect_name
        local size = buff_table[str_buff_id].size
        local sound = buff_table[str_buff_id].sound

        skill_notice_free_save_settings()
        ReserveScript(string.format("skill_notice_free_effect_test('%s','%s',%d)", effect_name, sound, size), 0.1)
    end

end

function skill_notice_free_effect_test(effect_name, sound, size)

    local my_handle = session.GetMyHandle()
    local actor = world.GetActor(my_handle)
    effect.AddActorEffectByOffset(actor, effect_name, size, "MID", true, true)
    effect.DetachActorEffect(actor, effect_name, 5.0)
    if sound ~= "None" then
        imcSound.PlaySoundEvent(sound)
    end
end

function skill_notice_free_size_edit(frame, ctrl, str, buff_id)

    local size_text = tonumber(ctrl:GetText())
    if size_text <= 10 then
        local buff_table = g.settings["buffs"]
        local str_buff_id = tostring(buff_id)

        buff_table[str_buff_id].size = size_text
        skill_notice_free_save_settings()

        local effect_name = buff_table[str_buff_id].effect
        if effect_name ~= "None" then
            local size = buff_table[str_buff_id].size
            local sound = buff_table[str_buff_id].sound
            ReserveScript(string.format("skill_notice_free_effect_test('%s','%s',%d)", effect_name, sound, size), 0.1)
        end
    else
        ui.SysMsg("Set at less than 10")
    end
end

function skill_notice_free_charge_edit(frame, ctrl, str, buff_id)

    local charge_text = tonumber(ctrl:GetText())
    local buff_table = g.settings["buffs"]
    local str_buff_id = tostring(buff_id)

    buff_table[str_buff_id].max_charge = charge_text
    skill_notice_free_save_settings()
    ui.SysMsg("Charge set")
    skill_notice_free_frame_init()
end

function skill_notice_free_setting_check(frame, ctrl, str, buff_id)
    local ischeck = ctrl:IsChecked()
    local ctrl_name = ctrl:GetName()
    local cid_table = g.settings[tostring(g.cid)]
    local buff_table = g.settings["buffs"]
    local str_buff_id = tostring(buff_id)

    if string.find(ctrl_name, "display_check") ~= nil and ischeck == 1 then
        cid_table[str_buff_id] = "YES"
    elseif string.find(ctrl_name, "display_check") ~= nil and ischeck == 0 then
        cid_table[str_buff_id] = "NO"
    elseif string.find(ctrl_name, "mode_check") ~= nil and ischeck == 1 then
        buff_table[str_buff_id].mode = "icon"
    elseif string.find(ctrl_name, "mode_check") ~= nil and ischeck == 0 then
        buff_table[str_buff_id].mode = "gauge"
    end
    skill_notice_free_save_settings()
    skill_notice_free_frame_init()
end

function skill_notice_free_setting_delete(frame, ctrl, str, buff_id)
    local buff_table = g.settings["buffs"]
    local str_buff_id = tostring(buff_id)
    buff_table[str_buff_id] = nil
    skill_notice_free_save_settings()
    skill_notice_free_setting(frame, ctrl, str, nil)
    skill_notice_free_frame_init()
end

function skill_notice_free_buff_remove(frame, msg, str, buff_id)
    local frame = ui.GetFrame("skill_notice_free")
    if frame:IsVisible() == 0 then
        return
    end
    local my_handle = session.GetMyHandle()
    local actor = world.GetActor(my_handle)

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]
    local str_buff_id = tostring(buff_id)

    if cid_table[str_buff_id] ~= "YES" or not buff_table[str_buff_id] then
        return
    end

    local buff_data = buff_table[str_buff_id]

    if buff_data.mode == "icon" then
        local icon_frame = ui.GetFrame(addonNameLower .. "icon_frame")
        local icon_slot = GET_CHILD_RECURSIVELY(icon_frame, "icon_slot" .. buff_id)
        AUTO_CAST(icon_slot)
        local buff_count = GET_CHILD_RECURSIVELY(icon_slot, "buff_count" .. buff_id)
        AUTO_CAST(buff_count)
        buff_count:SetText("{ol}{s35}0")
        buff_count:SetColorTone("FFFFFFFF")
        local effect_name = buff_data.effect
        if effect_name ~= "None" then
            effect.DetachActorEffect(actor, effect_name, 0)
        end
        g.buffs[str_buff_id] = nil
        -- icon_slot:ShowWindow(0)
    else
        local gauge = GET_CHILD_RECURSIVELY(frame, "gauge" .. buff_id)
        if gauge then
            AUTO_CAST(gauge)
            gauge:RemoveAllChild()
            gauge:SetPoint(0, buff_data.max_charge)
            gauge:SetStatFont(0, "quickiconfont")
            gauge:SetStatOffset(0, -10, 0)
            gauge:SetStatAlign(0, ui.RIGHT, ui.CENTER_VERT)
            gauge:EnableHitTest(0)
            local color = buff_table[str_buff_id].color
            gauge:SetColorTone(color)

        end

        local effect_name = buff_data.effect
        if effect_name ~= "None" then
            effect.DetachActorEffect(actor, effect_name, 0)
        end
        g.buffs[str_buff_id] = nil
        -- gauge:ShowWindow(0)
    end
end

function skill_notice_free_buff_add(frame, msg, str, buff_id)

    local frame = ui.GetFrame("skill_notice_free")
    if frame:IsVisible() == 0 then
        return
    end
    local my_handle = session.GetMyHandle()
    local info_buff = info.GetBuff(my_handle, buff_id)

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]
    local str_buff_id = tostring(buff_id)

    local buff_class = GetClassByType("Buff", buff_id)
    if buff_class ~= nil then
        if not g.get_buffs[str_buff_id] then
            local buff_name = buff_class.ClassName
            g.get_buffs[str_buff_id] = buff_name
            acutil.saveJSON(g.get_buffs_file_path, g.get_buffs)
        end
    end

    if cid_table[str_buff_id] ~= "YES" or not buff_table[str_buff_id] then
        return
    end

    local buff_data = buff_table[str_buff_id]

    if info_buff == nil then
        return
    end

    if buff_data.mode == "icon" then

        local icon_frame = ui.GetFrame(addonNameLower .. "icon_frame")
        local icon_slot = GET_CHILD_RECURSIVELY(icon_frame, "icon_slot" .. str_buff_id)
        AUTO_CAST(icon_slot)
        local buff_count = GET_CHILD_RECURSIVELY(icon_slot, "buff_count" .. str_buff_id)
        AUTO_CAST(buff_count)

        buff_count:SetText("{ol}{s35}" .. info_buff.over)
        -- icon_slot:ShowWindow(1)
    else
        local gauge = GET_CHILD_RECURSIVELY(frame, "gauge" .. str_buff_id)
        if gauge then
            AUTO_CAST(gauge)
            gauge:RemoveAllChild()
            gauge:SetPoint(info_buff.over, buff_data.max_charge)
            gauge:SetStatFont(0, "quickiconfont")
            gauge:SetStatOffset(0, -10, 0)
            gauge:SetStatAlign(0, ui.RIGHT, ui.CENTER_VERT)
            gauge:EnableHitTest(0)
            local color = buff_table[str_buff_id].color
            gauge:SetColorTone(color)
        end
        -- gauge:ShowWindow(1)
    end
    g.buffs[str_buff_id] = false

end

function skill_notice_free_buff_update(frame, msg, str, buff_id)

    local frame = ui.GetFrame("skill_notice_free")
    if frame:IsVisible() == 0 then
        return
    end
    local my_handle = session.GetMyHandle()
    local actor = world.GetActor(my_handle)

    local buff_table = g.settings["buffs"]
    local cid_table = g.settings[tostring(g.cid)]
    local str_buff_id = tostring(buff_id)

    if cid_table[str_buff_id] ~= "YES" or not buff_table[str_buff_id] then
        return
    end

    local buff_data = buff_table[str_buff_id]
    local info_buff = info.GetBuff(my_handle, buff_id)

    if info_buff == nil then
        return
    end

    if buff_data.mode == "icon" then

        local icon_frame = ui.GetFrame(addonNameLower .. "icon_frame")
        local icon_slot = GET_CHILD_RECURSIVELY(icon_frame, "icon_slot" .. str_buff_id)
        AUTO_CAST(icon_slot)

        local buff_count = GET_CHILD_RECURSIVELY(icon_slot, "buff_count" .. str_buff_id)
        AUTO_CAST(buff_count)
        buff_count:SetText("{ol}{s35}" .. info_buff.over)

        if info_buff.over == buff_data.max_charge and not g.buffs[str_buff_id] then
            buff_count:SetColorTone("FFFF0000")
            skill_notice_free_apply_buff_effects(buff_data)
            g.buffs[str_buff_id] = true
        elseif info_buff.over ~= buff_data.max_charge then
            buff_count:SetColorTone("FFFFFFFF")
            local effect_name = buff_data.effect
            if effect_name ~= "None" then
                effect.DetachActorEffect(actor, effect_name, 0)
            end
        end
    else
        local gauge = GET_CHILD_RECURSIVELY(frame, "gauge" .. str_buff_id)
        if gauge then
            AUTO_CAST(gauge)
            gauge:RemoveAllChild()
            gauge:SetPoint(info_buff.over, buff_data.max_charge)
            gauge:SetStatFont(0, "quickiconfont")
            gauge:SetStatOffset(0, -10, 0)
            gauge:SetStatAlign(0, ui.RIGHT, ui.CENTER_VERT)
            gauge:EnableHitTest(0)

            if info_buff.over == buff_data.max_charge and not g.buffs[str_buff_id] then

                gauge:SetColorTone("FFFF0000")
                skill_notice_free_apply_buff_effects(buff_data)
                g.buffs[str_buff_id] = true
            elseif info_buff.over ~= buff_data.max_charge then
                local color = buff_table[str_buff_id].color
                gauge:SetColorTone(color)
            end
        end
    end
end

function skill_notice_free_apply_buff_effects(buff_data)
    local effect_name = buff_data.effect
    local my_handle = session.GetMyHandle()
    local actor = world.GetActor(my_handle)
    if effect_name and effect_name ~= "None" then
        local size = buff_data.size
        effect.AddActorEffectByOffset(actor, effect_name, size, "MID", true, true)
    end

    local sound = buff_data.sound
    if sound and sound ~= "None" then
        imcSound.PlaySoundEvent(sound)
    end
end
