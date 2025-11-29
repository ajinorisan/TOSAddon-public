--[[function indun_panel_autozoom_init()

    local frame = ui.GetFrame("indun_panel")
    frame:SetSkinName('None')
    frame:SetLayerLevel(30)
    frame:Resize(140, 40)
    local rect = frame:GetMargin()
    frame:SetGravity(ui.RIGHT, ui.TOP)
    frame:SetMargin(rect.left, rect.top, rect.right + 140, rect.bottom)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:RemoveAllChild()

    local zoomedit = frame:CreateOrGetControl('edit', 'zoomedit', 80, 0, 60, 30)
    AUTO_CAST(zoomedit)
    zoomedit:SetText("{ol}" .. g.settings.zoom)
    zoomedit:SetFontName("white_16_ol")
    zoomedit:SetTextAlign("center", "center")
    zoomedit:SetEventScript(ui.ENTERKEY, "indun_panel_autozoom_save")
    zoomedit:SetTextTooltip(g.lang == "Japanese" and
                                "{ol}Auto Zoom Setting{nl}1～700の値で入力。標準は336。マップ切り替え時に入力の値までZoomします。0入力で機能無効化。" or
                                "{ol}Auto Zoom Setting{nl}Input a value from 0 to 700. Standard is 336. Zoom to the input value when switching maps.{nl}Disable function by inputting 0.")
    frame:ShowWindow(1)
end

function indun_panel_autozoom()
    if g.settings.zoom ~= 0 then
        camera.CustomZoom(tonumber(g.settings.zoom))
    end
end

function indun_panel_autozoom_save(frame, ctrl)

    local value = tonumber(ctrl:GetText())

    if value == 0 then
        g.settings.zoom = 0
    elseif value < 1 or value > 700 then
        local errorMsg =
            g.lang == "Japanese" and "無効な値です。1から700の間で設定してください。" or
                "Invalid value please set between 1 and 700"
        ui.SysMsg(errorMsg)
        local text = GET_CHILD_RECURSIVELY(frame, "zoomedit")
        text:SetText("336")
        g.settings.zoom = 336
    else
        if value ~= g.settings.zoom then
            ui.SysMsg("Auto Zoom setting set to " .. value)
            g.settings.zoom = value
        end
    end

    g.save_settings()
    ReserveScript("indun_panel_autozoom()", 1.0)
end]] --[[function g.settings_make()
    if next(g.settings) then
        return
    end

    g.settings = {
        checkbox = 0,
        zoom = 336,
        challenge_checkbox = 1,
        singularity_checkbox = 1,
        redania_checkbox = 1,
        neringa_checkbox = 1,
        golem_checkbox = 1,
        merregina_checkbox = 1,
        slogutis_checkbox = 1,
        upinis_checkbox = 1,
        roze_checkbox = 1,
        falouros_checkbox = 1,
        spreader_checkbox = 1,
        jellyzele_checkbox = 1,
        delmore_checkbox = 1,
        telharsha_checkbox = 1,
        velnice_checkbox = 1,
        giltine_checkbox = 1,
        earring_checkbox = 1,
        cemetery_checkbox = 1,
        jsr_checkbox = 1,
        singularity_check = 0,
        en_ver = 0,
        season_checkbox = 1,
        x = 665,
        y = 30,
        move = 0
    }

    g.save_settings()
end]] --[[function indun_panel_time_update(openingameshopbtn)

    local time = os.date("*t")
    local hour = time.hour
    local min = time.min
    local sec = time.sec

    if g.get_map_type() == "City" then
        if g.sing == 1 then
            if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") == 0 then
                local earthtowershop = ui.GetFrame('earthtowershop')
                if earthtowershop then
                    earthtowershop:Resize(0, 0)
                    indun_panel_minimized_pvpmine_shop_init()
                    g.sing = 2
                end
            end
        end
    end
    return 1
end]] --[[function indun_panel_FPS_UPDATE(frame, msg)
    if frame:IsVisible() == 1 then
        return
    else
        indun_panel_frame_init()
    end
end]] --[[function indun_panel_item_use_sin(frame, ctrl, enterance_count, indun_type)

    enterance_count = tonumber(enterance_count)
    if enterance_count > 0 then
        return
    end

    local ticket_priority_list = {}
    if indun_type == 2000 then

        ticket_priority_list = { -- 【優先度1】期限が近い、ヤバいやつ
        {
            classid = 10820018,
            check_lifetime = true,
            is_urgent = true
        }, {
            classid = 11030067,
            check_lifetime = true,
            is_urgent = true
        }, -- 【優先度2】期限があるけど、まだ余裕なやつ
        {
            classid = 10820018,
            check_lifetime = true,
            is_urgent = false
        }, {
            classid = 11030067,
            check_lifetime = true,
            is_urgent = false
        }, -- 【優先度3】期限がない、いつでも使えるやつ
        {
            classid = 10000470,
            check_lifetime = false
        }, {
            classid = 11030021,
            check_lifetime = false
        }, {
            classid = 11030017,
            check_lifetime = false
        }}
    elseif indun_type == 2001 then
        ticket_priority_list = { -- 【優先度1】期限が近い、ヤバいやつ
        {
            classid = 11201303,
            check_lifetime = true,
            is_urgent = true
        }, {
            classid = 11201304,
            check_lifetime = true,
            is_urgent = true
        }, {
            classid = 11201302,
            check_lifetime = false
        }, {
            classid = 11201301,
            check_lifetime = false
        }}
    end
    session.ResetItemList()

    for _, ticket_info in ipairs(ticket_priority_list) do
        local use_item = session.GetInvItemByType(ticket_info.classid)
        if use_item then
            if ticket_info.check_lifetime then
                local life_time = tonumber(GET_REMAIN_ITEM_LIFE_TIME(GetIES(use_item:GetObject())))
                if life_time then
                    if ticket_info.is_urgent and life_time < 86400 then
                        indun_panel_item_use_and_run(use_item, indun_type)
                        return
                    elseif not ticket_info.is_urgent then

                        indun_panel_item_use_and_run(use_item, indun_type)
                        return
                    end
                end
            else

                indun_panel_item_use_and_run(use_item, indun_type)
                return

            end
        end
    end

    if indun_type == 2000 then
        local mcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_314")
        if mcount >= 1 then
            INDUN_PANEL_ITEM_BUY_USE("EVENT_TOS_WHOLE_SHOP_314", indun_type)
            return
        end
    elseif indun_type == 2001 then

        local day_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
        if day_count >= 1 then
            INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_41", indun_type)
            return
        end

        local week_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")
        if week_count >= 1 then
            INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_42", indun_type)
            return
        end
    end
end]] --[[function indun_panel_challenge_item_use(indun_panel, ctrl, str, indun_type)

    if indun_type == 1001 then
        local enterance_count = indun_panel_get_entrance_count(indun_type, 4)

        if enterance_count == 1 then

            local ticket_table = {10820019, 11030080, 641954, 641969, 641955, 10000073}

            session.ResetItemList()
            local candidate_tickets = {}

            for _, classid in ipairs(ticket_table) do
                local use_item = session.GetInvItemByType(classid)
                if use_item ~= nil then
                    local life_time_str = GET_REMAIN_ITEM_LIFE_TIME(GetIES(use_item:GetObject()))
                    local life_time = tonumber(life_time_str)
                    local priority = 0

                    if life_time == nil then
                        priority = 3
                    elseif life_time < 86400 then
                        priority = 1
                    else
                        priority = 2
                    end

                    table.insert(candidate_tickets, {
                        item = use_item,
                        priority = priority
                    })
                end
            end

            if #candidate_tickets > 0 then
                table.sort(candidate_tickets, function(a, b)
                    return a.priority < b.priority
                end)

                local use_ticket = candidate_tickets[1].item
                INV_ICON_USE(use_ticket)
                indun_panel_enter_reserve(1, indun_type)
                return
            end

            local event_trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("EVENT_TOS_WHOLE_SHOP_315")
            if event_trade_count >= 1 then
                INDUN_PANEL_ITEM_BUY_USE("EVENT_TOS_WHOLE_SHOP_315", indun_type)
                indun_panel_enter_reserve(1, indun_type)
                return
            end

        end
    elseif indun_type == 1005 or indun_type == 1004 then

        local enterance_count = indun_panel_get_entrance_count(indun_type, 4)

        if enterance_count == 0 then
            local ticket_table = {11201299, 11201300, 11201298, 11201297}

            session.ResetItemList()
            local candidate_tickets = {}

            for _, classid in ipairs(ticket_table) do
                local use_item = session.GetInvItemByType(classid)
                if use_item ~= nil then
                    local life_time_str = GET_REMAIN_ITEM_LIFE_TIME(GetIES(use_item:GetObject()))
                    local life_time = tonumber(life_time_str)
                    local priority = 0

                    if life_time == nil then
                        priority = 3
                    elseif life_time < 86400 then
                        priority = 1
                    else
                        priority = 2
                    end

                    table.insert(candidate_tickets, {
                        item = use_item,
                        priority = priority
                    })
                end
            end

            if #candidate_tickets > 0 then
                table.sort(candidate_tickets, function(a, b)
                    return a.priority < b.priority
                end)

                local use_ticket = candidate_tickets[1].item
                INV_ICON_USE(use_ticket)
                if str == "SOLO" then
                    indun_panel_enter_reserve(1, indun_type)
                else
                    indun_panel_enter_reserve(2, indun_type)
                end

                return
            end

            local trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")
            if trade_count >= 1 then
                INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_40", indun_type)
                if str == "SOLO" then
                    indun_panel_enter_reserve(1, indun_type)
                else
                    indun_panel_enter_reserve(2, indun_type)
                end
                return
            elseif trade_count <= 0 then
                local account_obj = GetMyAccountObj()
                local recipe_cls = GetClass('ItemTradeShop', "PVP_MINE_40")
                local over_max = TryGetProp(recipe_cls, 'MaxOverBuyCount', 0)
                local over_prop = TryGetProp(recipe_cls, 'OverBuyProperty', 'None')
                local over_count = TryGetProp(account_obj, over_prop, 0)
                local overbuy_count = tonumber(over_max) - tonumber(over_count)

                if overbuy_count > 0 then
                    local msg = g.lang == "Japanese" and "{img pvpmine_shop_btn_total 29 29} " ..
                                    (1100 + over_count * 100) .. " 使用しました" or
                                    "{img pvpmine_shop_btn_total 29 29} " .. (1100 + over_count * 100) .. " Used"
                    ui.SysMsg(msg)
                    INDUN_PANEL_ITEM_BUY_USE("PVP_MINE_40", indun_type)
                    if str == "SOLO" then
                        indun_panel_enter_reserve(1, indun_type)
                    else
                        indun_panel_enter_reserve(2, indun_type)
                    end
                    return
                end
            end

        end
    end
end]] --[[function indun_panel_FIELD_BOSS_TIME_TAB_SETTING(frame)
        local frame = ui.GetFrame("induninfo")
        local field_boss_ranking_control = GET_CHILD_RECURSIVELY(frame, "field_boss_ranking_control")
        local now_time = geTime.GetServerSystemTime()
        local sub_tab = GET_CHILD_RECURSIVELY(field_boss_ranking_control, "sub_tab")

        local currentTime = os.time()
        -- 今日の日付を取得
        local today = os.date("*t", currentTime)
        -- 今日の12時5分
        local time12_5 = os.time({
            year = today.year,
            month = today.month,
            day = today.day,
            hour = 12,
            min = 5,
            sec = 0
        })
        -- 今日の22時5分
        local time22_5 = os.time({
            year = today.year,
            month = today.month,
            day = today.day,
            hour = 22,
            min = 5,
            sec = 0
        })
        if (time12_5 - currentTime) > 0 then
            sub_tab:SelectTab(0)
        else
            sub_tab:SelectTab(1)
        end
    end]] --[[function indun_panel_get_next_reset_timestamp()
    local now = os.time()
    local date_table = os.date("*t", now)

    local today_6am_timestamp = os.time({
        year = date_table.year,
        month = date_table.month,
        day = date_table.day,
        hour = 6,
        min = 0,
        sec = 0
    })

    if now < today_6am_timestamp then

        return today_6am_timestamp
    else

        return today_6am_timestamp + 86400
    end
end

function indun_panel_daily_reset(indun_panel)
    local now = os.time()

    if g.settings.toscoin == nil then
        g.settings.toscoin = 0
    end

    if g.settings.reset_time == nil or g.settings.reset_time < now then
        g.settings.toscoin = 0
        g.recipe_trade = false
        g.settings.reset_time = indun_panel_get_next_reset_timestamp()
        g.save_settings()
    end

    if g.get_map_type() == "City" and not g.recipe_trade then
        if INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41") == 0 then
            local earthtowershop = ui.GetFrame('earthtowershop')
            if earthtowershop then
                earthtowershop:Resize(0, 0)
                indun_panel_minimized_pvpmine_shop_init()
                g.recipe_trade = true
            end
        end
    end

    return 1
end]] --[[local tos_coin_count = GET_CHILD_RECURSIVELY(frame, "tos_coin_count")
    if tos_coin_count ~= nil then
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0"))
        tos_coin_count:SetText(string.format("{ol}{#FFD900}{s18}%s", coin_count))
    end
    local pvpminecount = GET_CHILD_RECURSIVELY(frame, "pvpminecount")
    if pvpminecount ~= nil then
        local coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "MISC_PVP_MINE2", "0"))
        pvpminecount:SetText(string.format("{ol}{#FFD900}{s18}%s", coin_count))
    end]] --[[local x = 135
    if not g.indun_frag then
        local y = 40
        local count = #induntype
        for i = 1, count do
            local entry = induntype[i]
            for key, value in pairs(entry) do
                ts(i, key, value)
                if g.settings[key .. "_checkbox"] == 1 then

                    local text = frame:CreateOrGetControl("richtext", key, x - 125, y + 5)
                    text:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(key))
                    text:AdjustFontSizeByWidth(120)
                    if type(value) == "table" then
                        if key == "slogutis" or key == "upinis" or key == "roze" or key == "falouros" or key ==
                            "spreader" or key == "merregina" or key == "neringa" or key == "golem" or key == "redania" or
                            key == "veliora" or key == "limara" then
                            for subKey, subValue in pairs(value) do
                                indun_panel_create_frame_onsweep(frame, key, subKey, subValue, y, x)
                            end
                        elseif key == "jellyzele" or key == "delmore" or key == "giltine" or key == "earring" then
                            for subKey, subValue in pairs(value) do
                                indun_panel_create_frame(frame, key, subKey, subValue, y)
                            end
                        elseif key == "challenge" then
                            indun_panel_challenge_frame(frame, key, y, value)
                        elseif key == "singularity" then

                            indun_panel_singularity_frame(frame, key, y, value)
                        end
                    else
                        if key == "telharsha" then
                            indun_panel_telharsha_frame(frame, key, value, y)
                        elseif key == "velnice" then
                            indun_panel_velnice_frame(frame, key, value, y)
                        elseif key == "cemetery" then
                            indun_panel_cemetery_frame(frame, key, value, y)
                        elseif key == "demonlair" then
                            indun_panel_demonlair_frame(frame, key, value, y)
                           
                        end
                    end
                    if key ~= "jsr" then
                        y = y + 33
                    end
                end
            end
        end
        g.indun_frag = true
        g.last_y = y
    end]] --[[function indun_panel_frame_save(frame, ctrl, set_name, num)
    local yesScp = string.format("APPS_TRY_LEAVE(frame,ctrl,'%s','')", set_name);
    local msg = g.lang == "Japanese" and "現在のレイド表示情報を保存しますか？" or
                    "Do you want to save the current raid display information?"
    ui.MsgBox(msg, yesScp, "None");
end]] --[==[function indun_list_viewer_save_settings()
    g.save_json(g.settings_path, g.settings)
end

local RAID_KEYS = {"V", "L", "R", "N", "G", "M", "S", "U", "RO", "F", "P", "D"}

function indun_list_viewer_load_settings()

    local settings = g.load_json(g.settings_path) or {}

    local DEFAULTS = {
        reset_time = 1702846800,
        display_mode = "full"
    }
    for key, value in pairs(DEFAULTS) do
        if settings[key] == nil then
            settings[key] = value
        end
    end

    local DEFAULT_CHAR_DATA = {
        layer = 9,
        order = 99,
        hide = false,
        memo = "",
        president_jobid = "",
        jobid = "",
        raid_count = {},
        auto_clear_count = {}
    }

    for _, key in ipairs(RAID_KEYS) do
        DEFAULT_CHAR_DATA.raid_count[key .. "_H"] = "?"
        DEFAULT_CHAR_DATA.raid_count[key .. "_A"] = "?"
        DEFAULT_CHAR_DATA.auto_clear_count[key .. "_S"] = "?"
    end

    local function ensure_defaults(target_table, default_table)
        for key, default_value in pairs(default_table) do
            if target_table[key] == nil then
                target_table[key] = default_value
            elseif type(target_table[key]) == "table" and type(default_value) == "table" then
                ensure_defaults(target_table[key], default_value)
            end
        end
    end

    local acc_info = session.barrack.GetMyAccount()
    if g.load == true then
        local barrack_cnt = acc_info:GetBarrackPCCount()
        for i = 0, barrack_cnt - 1 do
            local pc_info = acc_info:GetBarrackPCByIndex(i)
            local pc_name = pc_info:GetName()
            settings[pc_name] = settings[pc_name] or {}
            settings[pc_name].pc_name = pc_name
            ensure_defaults(settings[pc_name], DEFAULT_CHAR_DATA)
        end
    end
    g.settings = settings
    indun_list_viewer_save_settings()

    if g.load == true then
        indun_list_viewer_sort_characters(acc_info)
        local server_time_str = date_time.get_lua_now_datetime_str()
        if server_time_str then
            local y, m, d, H, M, S = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
            if y then
                local server_now_timestamp = os.time({
                    year = tonumber(y),
                    month = tonumber(m),
                    day = tonumber(d),
                    hour = tonumber(H),
                    min = tonumber(M),
                    sec = tonumber(S)
                })
                if server_now_timestamp > g.settings.reset_time then
                    indun_list_viewer_raid_reset()
                end
            end
        end
    else
        g.sorted_settings = {}
        for _, data in pairs(g.settings) do
            if type(data) == "table" then
                table.insert(g.sorted_settings, data)
            end
        end
        local function sort_layer_order(a, b)
            if a.layer ~= b.layer then
                return a.layer < b.layer
            else
                return a.order < b.order
            end
        end
        table.sort(g.sorted_settings, sort_layer_order)
        g.load = true
    end

    indun_list_viewer_frame_init()
end

function indun_list_viewer_get_reset_time()

    local server_time_str = date_time.get_lua_now_datetime_str()
    if not server_time_str then
        return 0
    end

    local year, month, day, hour, min, sec = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
    if not year then
        return 0
    end

    local now_table = {
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec)
    }

    local now_timestamp = os.time(now_table)

    local current_day_of_week = tonumber(os.date("%w", now_timestamp)) + 1

    local days_to_next_monday
    if current_day_of_week == 2 and now_table.hour < 6 then
        days_to_next_monday = 0
    else

        days_to_next_monday = (9 - current_day_of_week) % 7
        if days_to_next_monday == 0 then
            days_to_next_monday = 7
        end
    end

    local next_monday_timestamp_base = now_timestamp + days_to_next_monday * 86400
    local next_monday_date = os.date("*t", next_monday_timestamp_base)

    local next_monday_6am_timestamp = os.time({
        year = next_monday_date.year,
        month = next_monday_date.month,
        day = next_monday_date.day,
        hour = 6,
        min = 0,
        sec = 0
    })

    return next_monday_6am_timestamp
end

function indun_list_viewer_raid_reset()
    local account_info = session.barrack.GetMyAccount()
    local barrack_pc_count = account_info:GetBarrackPCCount()

    for i = 0, barrack_pc_count - 1 do
        local barrack_pc_info = account_info:GetBarrackPCByIndex(i)
        local barrack_pc_name = barrack_pc_info:GetName()
        local new_raid_count = {}
        for _, key in ipairs(RAID_KEYS) do
            new_raid_count[key .. "_H"] = "?"
            new_raid_count[key .. "_A"] = "?"
        end
        g.settings[barrack_pc_name]["raid_count"] = new_raid_count
    end

    g.settings.reset_time = indun_list_viewer_get_reset_time()
    indun_list_viewer_save_settings()

    --[[for i = 0, barrack_pc_count - 1 do
        local barrack_pc_info = account_info:GetBarrackPCByIndex(i)
        local barrack_pc_name = barrack_pc_info:GetName()

        g.settings[barrack_pc_name]["raid_count"] = {
            V_H = "?",
            V_A = "?",
            L_H = "?",
            L_A = "?",
            R_H = "?",
            R_A = "?",
            N_H = "?",
            N_A = "?",
            G_H = "?",
            G_A = "?",
            M_H = "?",
            M_A = "?",
            S_H = "?",
            S_A = "?",
            U_H = "?",
            U_A = "?",
            RO_H = "?",
            RO_A = "?",
            F_H = "?",
            F_A = "?",
            P_H = "?",
            P_A = "?",
            D_H = "?",
            D_A = "?"
        }
    end
    g.settings.reset_time = indun_list_viewer_get_reset_time()
    indun_list_viewer_save_settings()]]

    if g.lang == "Japanese" then
        ui.SysMsg("[ILV]レイドの回数を初期化しました。")
    else
        ui.SysMsg("[ILV]Raid counts were initialized.")
    end
end

function indun_list_viewer_sort_characters(account_info)

    local layer_pc_count = account_info:GetPCCount()
    for order = 0, layer_pc_count - 1 do
        local pc_info = account_info:GetPCByIndex(order)
        local pc_apc = pc_info:GetApc()
        local pc_name = pc_apc:GetName()
        local pc_cid = pc_info:GetCID()
        g.settings[pc_name].cid = pc_cid
        g.settings[pc_name].order = order
        if g.layer and g.layer ~= g.settings[pc_name].layer then
            g.settings[pc_name].layer = g.layer
        end
    end
    g.layer = nil

    indun_list_viewer_save_settings()

    g.sorted_settings = {}
    for _, data in pairs(g.settings) do
        if type(data) == "table" then
            table.insert(g.sorted_settings, data)
        end
    end

    local function sort_layer_order(a, b)
        if a.layer ~= b.layer then
            return a.layer < b.layer
        else
            return a.order < b.order
        end
    end

    table.sort(g.sorted_settings, sort_layer_order)
end

function INDUN_LIST_VIEWER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    g.REGISTER = {}

    g.cid = session.GetMySession():GetCID();
    g.lang = option.GetCurrentCountry()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    g.layer = 1
    if _G["BARRACK_CHARLIST_ON_INIT"] and _G["current_layer"] then
        g.layer = _G["current_layer"]
    end

    if g.get_map_type() == "City" then
        addon:RegisterMsg('GAME_START', "indun_list_viewer_load_settings")
        addon:RegisterMsg('GAME_START_3SEC', "indun_list_viewer_get_raid_count")

        g.setup_hook_and_event(addon, "APPS_TRY_MOVE_BARRACK", "indun_list_viewer_get_raid_count", true)
        g.setup_hook_and_event(addon, "APPS_TRY_LOGOUT", "indun_list_viewer_get_raid_count", true)
        g.setup_hook_and_event(addon, "APPS_TRY_EXIT", "indun_list_viewer_get_raid_count", true)
        g.setup_hook_and_event(addon, "STATUS_SELET_REPRESENTATION_CLASS",
            "indun_list_viewer_STATUS_SELET_REPRESENTATION_CLASS", true) -- STATUS_OPEN_CLASS_DROPLIST

    end
    if g.load then
        addon:RegisterMsg('GAME_START_3SEC', "indun_list_viewer_delete_character")
    end
end

function indun_list_viewer_delete_character()

    local acc_info = session.barrack.GetMyAccount()
    local barrack_cnt = acc_info:GetBarrackPCCount()

    local barrack_names = {}
    for i = 0, barrack_cnt - 1 do
        local pc_info = acc_info:GetBarrackPCByIndex(i)
        local pc_name = pc_info:GetName()
        table.insert(barrack_names, pc_name)
    end
    local remove_keys = {}
    if g.settings then
        for set_key, data_val in pairs(g.settings) do
            local is_char_data = false
            if type(data_val) == "table" and data_val.pc_name then
                is_char_data = true
            end
            if is_char_data then
                local found_barrack = false
                if barrack_names and #barrack_names > 0 then
                    for _, name_barrack in ipairs(barrack_names) do
                        if set_key == name_barrack then
                            found_barrack = true
                            break
                        end
                    end
                end
                if not found_barrack then
                    table.insert(remove_keys, set_key)
                end
            end
        end
        if #remove_keys > 0 then
            for _, key_del in ipairs(remove_keys) do
                g.settings[key_del] = nil
            end
        end
    end
    indun_list_viewer_save_settings()
end

function indun_list_viewer_get_raid_count()

    --[[local function create_data()
        local data = {
            V_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 727).PlayPerResetType),
            V_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 725).PlayPerResetType),
            L_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 724).PlayPerResetType),
            L_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 722).PlayPerResetType),
            R_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 718).PlayPerResetType),
            R_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 716).PlayPerResetType),
            N_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 709).PlayPerResetType),
            N_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 707).PlayPerResetType),
            G_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 712).PlayPerResetType),
            G_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 710).PlayPerResetType),
            M_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 697).PlayPerResetType),
            M_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 695).PlayPerResetType),
            S_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 690).PlayPerResetType),
            S_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 688).PlayPerResetType),
            U_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 687).PlayPerResetType),
            U_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 685).PlayPerResetType),
            RO_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 681).PlayPerResetType),
            RO_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 679).PlayPerResetType),
            F_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 678).PlayPerResetType),
            F_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 676).PlayPerResetType),
            P_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 675).PlayPerResetType),
            P_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 673).PlayPerResetType),
            D_H = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 665).PlayPerResetType),
            D_A = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 666).PlayPerResetType)
        }

        return data
    end]]

    local RAID_MAP = {
        V_H = 727,
        V_A = 725,
        L_H = 724,
        L_A = 722,
        R_H = 718,
        R_A = 716,
        N_H = 709,
        N_A = 707,
        G_H = 712,
        G_A = 710,
        M_H = 697,
        M_A = 695,
        S_H = 690,
        S_A = 688,
        U_H = 687,
        U_A = 685,
        RO_H = 681,
        RO_A = 679,
        F_H = 678,
        F_A = 676,
        P_H = 675,
        P_A = 673,
        D_H = 665,
        D_A = 666
    }

    local function get_safe_entrance_count(indun_type)
        local indun_cls = GetClassByType("Indun", indun_type)
        if indun_cls and indun_cls.PlayPerResetType then
            local count = GET_CURRENT_ENTERANCE_COUNT(indun_cls.PlayPerResetType)
            return count
        end
        return nil
    end

    local function create_data()
        local data = {}
        for key, indun_type in pairs(RAID_MAP) do
            local count = get_safe_entrance_count(indun_type)
            data[key] = count or "?"
        end
        return data
    end

    local data = create_data()
    g.settings[g.login_name]["raid_count"] = data

    local sweepbuff_table = {
        V_S = 80045,
        L_S = 80043,
        R_S = 80039,
        N_S = 80035,
        G_S = 80037,
        M_S = 80032,
        S_S = 80031,
        U_S = 80030,
        RO_S = 80015,
        F_S = 80017,
        P_S = 80016
    }
    local my_handle = session.GetMyHandle()

    local buff_frame = ui.GetFrame("buff")
    local buff_slotset = GET_CHILD_RECURSIVELY(buff_frame, "buffslot")
    local buff_slotcount = buff_slotset:GetChildCount()

    for key, value in pairs(sweepbuff_table) do
        g.settings[g.login_name]["auto_clear_count"][key] = 0

        for i = 0, buff_slotcount - 1 do
            local child = buff_slotset:GetChildByIndex(i)
            local icon = child:GetIcon()
            local icon_info = icon:GetInfo()
            local buff_id = icon_info.type

            if buff_id == value then
                local buff_class = info.GetBuff(my_handle, buff_id)
                g.settings[g.login_name]["auto_clear_count"][key] = buff_class.over
                break
            end
        end
    end

    indun_list_viewer_save_settings()
end

local check_table = {"Veliora_H", "Limara_H", "Redania_H", "Neringa_H", "Golem_H", "Merregina_H", "Slogutis_H",
                     "Upinis_H", "Roze_H", "Falouros_H", "Spreader_H", "Delmore_H", "Veliora_S", "Limara_S",
                     "Redania_S", "Neringa_S", "Golem_S", "Merregina_S", "Slogutis_S", "Upinis_S", "Roze_S",
                     "Falouros_S", "Spreader_S", "Delmore_S", "Memo"}

function indun_list_viewer_frame_init()

    local frame = ui.GetFrame("indun_list_viewer")
    frame:SetSkinName('None')
    frame:SetTitleBarSkin("None")
    frame:Resize(35, 35)

    local current_frame_w = frame:GetWidth()
    local map_frame = ui.GetFrame("map")
    local map_width = map_frame:GetWidth()
    frame:SetPos((map_width - current_frame_w) / 2, 0)
    -- frame:SetPos(665, 0)

    local open_button = frame:CreateOrGetControl('button', 'open_button', 0, 0, 35, 35)
    open_button:SetSkinName("None")
    open_button:SetText("{img sysmenu_qu 35 35}")
    open_button:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_title_frame_open")

    if g.lang == "Japanese" then
        open_button:SetTextTooltip("{ol}Indun List Viewer{nl}キャラ毎のレイド回数表示{nl}{nl}" ..
                                       "{@st45r14}※掃討はキャラ毎の最終ログイン時の値なので、期限切れなどで実際とは異なる場合があります{nl}" ..
                                       "{@st45r14}※キャラの順番を並べるには一度バラックに戻る必要があります。(instant cc不可)")
    else
        open_button:SetTextTooltip("{ol}Indun List Viewer{nl}Raid count display per character{nl}{nl}" ..
                                       "{@st45r14}※The AutoClear is the value at the last login for each character{nl}" ..
                                       "and may differ from the actual value due to expiration or other reasons.{nl}" ..
                                       "You must return to the barracks once to rearrange the order of the characters.{nl}" ..
                                       "(instant cc not available)")
    end

    for i = 1, #check_table do
        if g.settings[tostring(check_table[i])] == nil then
            g.settings[tostring(check_table[i])] = 1
        end
    end
    indun_list_viewer_save_settings()
end

function indun_list_viewer_title_frame_open()

    indun_list_viewer_get_raid_count()
    local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "list_frame", 0, 0, 10, 10)
    AUTO_CAST(frame)
    frame:RemoveAllChild()
    frame:SetLayerLevel(99);
    frame:SetSkinName("test_frame_low")

    local title_gb = frame:CreateOrGetControl("groupbox", "title_gb", 0, 0, 10, 10)
    AUTO_CAST(title_gb)

    local texts = {
        japanese = {
            charcter_name = "キャラクター名",
            hard_raid = "ハード",
            auto_raid = "オート ソロ / オート掃討",
            mode_text = "チェックを入れるとスクロールモードに切替",
            display_text = "チェックしたキャラはレイド回数非表示",
            memo = "メモ",
            display = "表示",
            hidden = "チェックを入れると非表示キャラを表示しません"
        },
        etc = {
            charcter_name = "CharacterName",
            hard_raid = "Hard Count",
            auto_raid = "Auto or Solo Count/ AutoClearBuff Count",
            titlegb_text = "Right-click to close",
            mode_text = "Switch to scroll mode when checked",
            display_text = "Checked characters hide raid count",
            memo = "Memo",
            display = "Disp",
            hidden = "If checked, do not show hidden characters"
        }
    }

    local select_texts = g.lang == "Japanese" and texts.japanese or texts.etc

    local icon_table = {{
        icon_name = "icon_item_misc_boss_Veliora",
        hard = 727,
        solo = 726,
        auto = 725
    }, {
        icon_name = "icon_item_misc_boss_Laimara",
        hard = 724,
        solo = 723,
        auto = 722
    }, {
        icon_name = "icon_item_misc_boss_Redania",
        hard = 718,
        solo = 717,
        auto = 716
    }, {
        icon_name = "icon_item_misc_boss_DarkNeringa",
        hard = 709,
        solo = 708,
        auto = 707
    }, {
        icon_name = "icon_item_misc_boss_CrystalGolem",
        hard = 712,
        solo = 711,
        auto = 710
    }, {
        icon_name = "icon_item_misc_merregina_blackpearl",
        hard = 697,
        solo = 696,
        auto = 695
    }, {
        icon_name = "icon_item_misc_boss_Slogutis",
        hard = 690,
        solo = 689,
        auto = 688
    }, {
        icon_name = "icon_item_misc_boss_Upinis",
        hard = 687,
        solo = 686,
        auto = 685
    }, {
        icon_name = "icon_item_misc_boss_Roze",
        hard = 681,
        solo = 680,
        auto = 679
    }, {
        icon_name = "icon_item_misc_high_falouros",
        hard = 678,
        solo = 677,
        auto = 676
    }, {
        icon_name = "icon_item_misc_high_transmutationSpreader",
        hard = 675,
        solo = 674,
        auto = 673
    }, {
        icon_name = "icon_item_misc_RevivalPaulius",
        hard = 628,
        solo = 669,
        auto = 635
    }}

    local x = 185
    for i = 1, #icon_table do

        if g.settings[tostring(check_table[i])] == 1 then
            local title_picture = title_gb:CreateOrGetControl('picture', "title_picture" .. i, x, 5, 30, 30);
            AUTO_CAST(title_picture)
            local icon_name = icon_table[i].icon_name

            title_picture:SetImage(icon_name)
            title_picture:SetEnableStretch(1)
            title_picture:EnableHitTest(1)
            title_picture:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_enter_hard")
            title_picture:SetEventScriptArgNumber(ui.LBUTTONDOWN, icon_table[i].hard)
            title_picture:SetEventScriptArgString(ui.LBUTTONDOWN, "false")
            title_picture:SetTextTooltip(g.lang == "Japanese" and "左クリックでレイド画面表示{nl}" ..
                                             select_texts.hard_raid or "Left click to display raid screen{nl}" ..
                                             select_texts.hard_raid)

            x = x + 30
        end
    end
    x = x + 30
    for i = #icon_table + 1, #icon_table * 2 do

        if g.settings[tostring(check_table[i])] == 1 then
            local title_picture = title_gb:CreateOrGetControl('picture', "title_picture" .. i, x, 5, 30, 30);
            AUTO_CAST(title_picture)
            local icon_name = icon_table[i - #icon_table].icon_name
            if string.find(icon_name, "falouros") then
                icon_name = "icon_item_misc_falouros"
            end

            title_picture:SetImage(icon_name)
            title_picture:SetEnableStretch(1)
            title_picture:EnableHitTest(1)
            title_picture:SetUserValue("SOLO", icon_table[i - #icon_table].solo)
            title_picture:SetUserValue("AUTO", icon_table[i - #icon_table].auto)
            title_picture:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_enter_context")
            title_picture:SetTextTooltip(g.lang == "Japanese" and "左クリックでレイド画面表示{nl}" ..
                                             select_texts.auto_raid or "Left click to display raid screen{nl}" ..
                                             select_texts.auto_raid)

            x = x + 65
        end
    end

    local close_button = title_gb:CreateOrGetControl("button", "close_button", 0, 0, 20, 20)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.LEFT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")

    local cc_button = title_gb:CreateOrGetControl('button', 'cc_button', 40, 5, 30, 30)
    AUTO_CAST(cc_button)
    cc_button:SetSkinName("None")
    cc_button:SetText("{img barrack_button_normal 30 30}")
    cc_button:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")

    function indun_list_viewer_config(frame, ctrl, str, num)

        local frame = ui.GetFrame(addon_name_lower .. "list_frame")
        frame:RemoveAllChild()
        local config_gb = frame:CreateOrGetControl("groupbox", "config_gb", 10, 35, 10, 10)
        AUTO_CAST(config_gb)
        config_gb:SetSkinName("bg")
        config_gb:ShowWindow(1)

        local text = config_gb:CreateOrGetControl("richtext", "text", 10, 10)
        AUTO_CAST(text)
        text:SetText(g.lang == "Japanese" and "チェックすると表示" or "{ol}Check to show")

        local title_gb = frame:CreateOrGetControl("groupbox", "title_gb", 0, 0, 10, 10)
        AUTO_CAST(title_gb)
        local x = text:GetWidth() + 35
        for i = 1, #icon_table do

            local title_picture = title_gb:CreateOrGetControl('picture', "title_picture" .. i, x, 5, 30, 30);
            AUTO_CAST(title_picture)
            local icon_name = icon_table[i].icon_name
            title_picture:SetImage(icon_name)
            title_picture:SetEnableStretch(1)
            title_picture:EnableHitTest(1)
            title_picture:SetTextTooltip("{ol}" .. select_texts.hard_raid)

            x = x + 30
        end

        x = x + 30
        for i = #icon_table + 1, #icon_table * 2 do

            local title_picture = title_gb:CreateOrGetControl('picture', "title_picture" .. i, x, 5, 30, 30);
            AUTO_CAST(title_picture)
            local icon_name = icon_table[i - #icon_table].icon_name
            if string.find(icon_name, "falouros") then
                icon_name = "icon_item_misc_falouros"
            end
            title_picture:SetImage(icon_name)
            title_picture:SetEnableStretch(1)
            title_picture:EnableHitTest(1)
            title_picture:SetTextTooltip("{ol}" .. select_texts.auto_raid)

            x = x + 30
        end
        x = x + 30
        local memo_text = title_gb:CreateOrGetControl("richtext", "memo_text", x, 10)
        AUTO_CAST(memo_text)
        memo_text:SetText("{ol}" .. select_texts.memo or "")

        local close_button = title_gb:CreateOrGetControl("button", "close_button", 0, 0, 20, 20)
        AUTO_CAST(close_button)
        close_button:SetImage("testclose_button")
        close_button:SetGravity(ui.LEFT, ui.TOP)
        close_button:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_close")
        close_button:SetEventScriptArgNumber(ui.LBUTTONUP, 1)

        function indun_list_viewer_display_check(frame, ctrl, str, num)

            local ischeck = ctrl:IsChecked()
            g.settings[str] = ischeck
            indun_list_viewer_save_settings()
        end

        for i = 1, #check_table do

            if g.settings[tostring(check_table[i])] == nil then
                g.settings[tostring(check_table[i])] = 1
            end
        end
        indun_list_viewer_save_settings()

        local x = text:GetWidth() + 30
        for i = 1, #icon_table do

            local check_box = config_gb:CreateOrGetControl('checkbox', "check_box" .. i, x, 5, 30, 30);
            AUTO_CAST(check_box)
            check_box:SetCheck(g.settings[tostring(check_table[i])] or 1)
            check_box:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_display_check")
            check_box:SetEventScriptArgString(ui.LBUTTONDOWN, check_table[i])

            x = x + 30
        end
        x = x + 30
        local loop_end_index = #icon_table * 2 + 1

        for i = #icon_table + 1, loop_end_index do
            local check_box = config_gb:CreateOrGetControl('checkbox', "check_box" .. i, x, 5, 30, 30);
            AUTO_CAST(check_box)
            check_box:SetCheck(g.settings[tostring(check_table[i])] or 1)
            check_box:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_display_check")
            check_box:SetEventScriptArgString(ui.LBUTTONDOWN, check_table[i])

            if i == loop_end_index - 1 then
                x = x + 60
            else
                x = x + 30
            end
        end

        title_gb:Resize(x + 20, 55)
        frame:Resize(x + 40, 85)

        config_gb:Resize(frame:GetWidth() - 20, frame:GetHeight() - 45)
    end

    local config_btn = title_gb:CreateOrGetControl('button', 'config_btn', 75, 5, 30, 30)
    AUTO_CAST(config_btn)
    config_btn:SetSkinName("None")
    config_btn:SetText("{img config_button_normal 30 30}")
    config_btn:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_config")

    local mode_check = title_gb:CreateOrGetControl('checkbox', 'mode_check', 115, 5, 30, 30)
    AUTO_CAST(mode_check)
    if g.settings.display_mode == "full" then
        mode_check:SetCheck(0)
    else
        mode_check:SetCheck(1)
    end
    mode_check:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_modechange")
    mode_check:SetTextTooltip("{ol}" .. select_texts.mode_text)

    local hidden = title_gb:CreateOrGetControl('checkbox', 'hidden', 150, 5, 30, 30)
    AUTO_CAST(hidden)
    if not g.settings.hidden then
        g.settings.hidden = 0
        indun_list_viewer_save_settings()
    end
    hidden:SetCheck(g.settings.hidden)

    hidden:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_modechange")
    hidden:SetTextTooltip("{ol}" .. select_texts.hidden)

    if g.settings[tostring(check_table[#check_table])] == 1 then
        local memo_text = title_gb:CreateOrGetControl("richtext", "memo_text", x, 10)
        AUTO_CAST(memo_text)
        memo_text:SetText("{ol}" .. select_texts.memo)
        x = x + 160
    end

    local display_text = title_gb:CreateOrGetControl("richtext", "display_text", x, 10)
    AUTO_CAST(display_text)
    display_text:SetText("{ol}" .. select_texts.display)
    display_text:SetTextTooltip("{ol}" .. select_texts.display_text)

    local current_frame_w = frame:GetWidth()
    local map_frame = ui.GetFrame("map")
    local map_width = map_frame:GetWidth()

    frame:SetPos((map_width - current_frame_w) / 2, 0)
    -- frame:SetPos(665, 35)
    -- frame:Resize(x + 70, 55)
    frame:ShowWindow(1)

    indun_list_viewer_frame_open(frame)
end

function indun_list_viewer_close(frame, ctrl, str, num)

    local frame = ui.GetFrame(addon_name_lower .. "list_frame")
    frame:ShowWindow(0)

    if num == 1 then
        indun_list_viewer_title_frame_open()
    end
end

function indun_list_viewer_frame_open(frame)

    local title_gb = GET_CHILD_RECURSIVELY(frame, "title_gb")
    AUTO_CAST(title_gb)

    local gb = frame:CreateOrGetControl("groupbox", "gb", 10, 35, 10, 10)
    AUTO_CAST(gb)
    gb:SetSkinName("bg")
    gb:RemoveAllChild()

    local sorted_new_settings = {}
    for _, data in ipairs(g.sorted_settings) do
        if type(data) == "table" then
            if g.settings.hidden == 1 then
                local hidden = data.hide
                if not hidden then
                    table.insert(sorted_new_settings, data)
                end
            else
                table.insert(sorted_new_settings, data)
            end
        end
    end

    local y = 10
    g.x = 0

    for key, data in ipairs(sorted_new_settings) do
        local x = 35
        if type(data) == "table" then
            local pc_name = data.pc_name

            local name = gb:CreateOrGetControl("richtext", pc_name, x, y)
            AUTO_CAST(name)
            if g.login_name == pc_name then
                name:SetText("{ol}{s14}{#FF4500}" .. pc_name)
            else
                name:SetText("{ol}{s14}" .. pc_name)
            end

            indun_list_viewer_job_slot(frame, data, y)
            x = x + 60
            local i = 1
            local index = 0

            if not data.hide then

                local hard_flag = false
                local normal_flag = false

                for _, raid_name in ipairs(check_table) do

                    if g.settings[raid_name] == 1 then
                        if string.find(raid_name, "_H") then

                            if not hard_flag then
                                x = 180
                                hard_flag = true
                            else
                                x = x + 30
                            end

                            local first_char, last_char = string.match(raid_name, "^(.).*_(.)$")
                            if raid_name == "Roze_H" then
                                first_char = "RO"
                            elseif raid_name == "Spreader_H" then
                                first_char = "P"
                            end
                            local key = first_char .. "_" .. last_char

                            local count = data.raid_count[key]

                            if count then
                                local text_ctrl = gb:CreateOrGetControl("richtext", key .. pc_name, x, y)
                                AUTO_CAST(text_ctrl)
                                text_ctrl:SetText("{ol}{s14}( " .. count .. " )")
                                if first_char ~= "P" and first_char ~= "F" then
                                    text_ctrl:SetColorTone(count == 1 and "FF990000" or "FFFFFFFF")
                                else
                                    text_ctrl:SetColorTone(count == 2 and "FF990000" or "FFFFFFFF")
                                end
                            end

                        elseif string.find(raid_name, "_S") then
                            if not hard_flag then
                                x = 140
                                hard_flag = true
                            end

                            if not normal_flag then
                                x = x + 60
                                normal_flag = true
                            else
                                x = x + 40
                            end

                            local base_key = string.match(raid_name, "^(.).*_S$")
                            local key_a, key_s = base_key .. "_A", base_key .. "_S"
                            if raid_name == "Roze_S" then
                                key_a = "RO_A"
                                key_s = "RO_S"
                            elseif raid_name == "Spreader_S" then
                                key_a = "P_A"
                                key_s = "P_S"
                            end

                            local count_a = data.raid_count[key_a]

                            local text_a = gb:CreateOrGetControl("richtext", key_a .. pc_name, x, y)
                            AUTO_CAST(text_a)
                            text_a:SetText("{ol}{s14}( " .. count_a .. " )")

                            if key_a == "P_A" or key_a == "F_A" then
                                text_a:SetColorTone(count_a == 4 and "FF990000" or "FFFFFFFF")
                            else
                                text_a:SetColorTone(count_a == 2 and "FF990000" or "FFFFFFFF")
                            end

                            if raid_name ~= "Delmore_S" then
                                x = x + 25
                                local count_s = data.auto_clear_count[key_s] or 0

                                local text_s = gb:CreateOrGetControl("richtext", key_s .. pc_name, x, y)
                                text_s:SetText("{ol}{s14}/( " .. count_s .. " )")
                            end

                        elseif raid_name == "Memo" then

                            x = x + 40
                            local memo = gb:CreateOrGetControl('edit', 'memo' .. pc_name, x, y - 2, 180, 20)
                            memo:SetFontName("white_14_ol")
                            memo:SetTextAlign("left", "center")
                            memo:SetSkinName("inventory_serch")
                            memo:SetEventScript(ui.ENTERKEY, "indun_list_viewer_memo_save")
                            memo:SetEventScriptArgString(ui.ENTERKEY, pc_name)
                            memo:SetText(data.memo or "")
                            x = x + 140
                        end
                    end
                end

            end
            if not g.x or x > g.x then
                g.x = x
            end
            y = y + 25
        end
    end

    local y = 10
    for _, data in ipairs(sorted_new_settings) do

        if type(data) == "table" then
            local pc_name = data.pc_name

            local line = gb:CreateOrGetControl("labelline", "line" .. pc_name, 25, y + 20, g.x + 10, 1)

            line:SetSkinName("labelline_def_3")

            local display = gb:CreateOrGetControl('checkbox', 'display' .. pc_name, g.x + 50, y - 5, 25, 25) -- 865

            AUTO_CAST(display)
            display:SetEventScript(ui.LBUTTONUP, "indun_list_viewer_display_save")
            display:SetEventScriptArgString(ui.LBUTTONUP, pc_name)
            local check = 1
            if not data.hide then
                check = 0
            end
            display:SetCheck(check)

        end
        y = y + 25
    end

    if g.settings.display_mode == "full" then
        frame:Resize(g.x + 40 + 80, y + 50)
        gb:Resize(frame:GetWidth() - 20, frame:GetHeight() - 45)
        title_gb:Resize(frame:GetWidth() - 20, 55)

    else
        if y < 545 then
            frame:Resize(g.x + 40 + 80, y + 50)
            gb:Resize(frame:GetWidth() - 20, frame:GetHeight() - 45)
        else
            frame:Resize(g.x + 40 + 80, 545)
            gb:Resize(frame:GetWidth() - 20, 500)
        end

        gb:EnableScrollBar(1);
        gb:EnableDrawFrame(1);
        gb:SetScrollPos(0)
        title_gb:Resize(frame:GetWidth() - 20, 55)
    end

    local display_text = GET_CHILD_RECURSIVELY(frame, "display_text")
    AUTO_CAST(display_text)
    local charName = GETMYPCNAME();
    local display = GET_CHILD_RECURSIVELY(frame, 'display' .. charName)
    AUTO_CAST(display)
    local display_x = display:GetX()
    display_text:SetPos(display_x + 10, 10)

    local current_frame_w = frame:GetWidth()
    local map_frame = ui.GetFrame("map")
    local map_width = map_frame:GetWidth()

    frame:SetPos((map_width - current_frame_w) / 2, 0)

    frame:ShowWindow(1)
end

function indun_list_viewer_display_save(frame, ctrl, str, num)

    local ischeck = ctrl:IsChecked()

    for _, data in ipairs(g.sorted_settings) do
        local pc_name = data.pc_name
        if pc_name == str then
            if ischeck == 1 then
                g.settings[pc_name].hide = true
            else
                g.settings[pc_name].hide = false
            end
            indun_list_viewer_save_settings()
            break
        end
    end
    indun_list_viewer_title_frame_open()
end

function indun_list_viewer_memo_save(frame, ctrl, str, num)

    local text = ctrl:GetText()
    for _, data in ipairs(g.sorted_settings) do
        local pc_name = data.pc_name
        if pc_name == str then
            g.settings[pc_name].memo = text
            indun_list_viewer_save_settings()
            break
        end
    end
    if g.lang == "Japanese" then
        ui.SysMsg("メモを登録しました。")
    else
        ui.SysMsg("MEMO registered.")
    end
end

function indun_list_viewer_job_slot(frame, data, y)

    local pc_name = data.pc_name
    local job_id = data.jobid
    local president = data.president_jobid

    local last_job_class
    local job_list, level, last_job_id = GetJobListFromAdventureBookCharData(pc_name)
    if job_id == "" then
        last_job_class = GetClassByType("Job", last_job_id)
    else
        last_job_class = GetClassByType("Job", president)
    end

    local last_job_icon = TryGetProp(last_job_class, "Icon")

    local gb = GET_CHILD_RECURSIVELY(frame, "gb")
    local job_slot = gb:CreateOrGetControl("slot", "jobslot" .. pc_name, 5, y - 4, 25, 25)
    AUTO_CAST(job_slot)
    job_slot:SetSkinName("None")
    job_slot:EnableHitTest(1)
    job_slot:EnablePop(0)
    if g.login_name == pc_name then
        job_slot:SetEventScript(ui.RBUTTONDOWN, "STATUS_OPEN_CLASS_DROPLIST")
    end

    local name_text = GET_CHILD_RECURSIVELY(gb, pc_name)
    if g.login_name == pc_name then
        name_text:SetEventScript(ui.RBUTTONDOWN, "STATUS_OPEN_CLASS_DROPLIST")
    end

    local icon_rbtn_text = ""
    if g.lang == "Japanese" then
        icon_rbtn_text = "右クリック: 表示アイコン選択"
    else
        icon_rbtn_text = "Right-click: Select Display Icon"
    end

    local job_icon = CreateIcon(job_slot)
    job_icon:SetImage(last_job_icon)

    local text = ""
    local id1, id2, id3, id4 = nil, nil, nil, nil
    local job_name1, job_name2, job_name3, job_name4

    if job_id ~= "" then

        local ids = {}

        for part in string.gmatch(job_id, "[^/]+") do
            table.insert(ids, part)
        end

        id1, id2, id3, id4 = ids[1], ids[2], ids[3], ids[4]

        local function get_job_name(id)
            if not id then
                return nil
            end
            local job_class = GetClassByType("Job", tonumber(id))
            if job_class then
                return TryGetProp(job_class, "Name", nil)
            end
            return nil
        end

        job_name1 = get_job_name(id1)
        job_name2 = get_job_name(id2)
        job_name3 = get_job_name(id3)
        job_name4 = get_job_name(id4)

        local highlight_color = "{#FF0000}" -- 一致した場合の色
        local function color_if_match(jobName, jobId)
            if jobId and tonumber(jobId) == tonumber(president) then
                return highlight_color .. jobName .. "{/}"
            else
                return jobName
            end
        end
        local tooltip_text = "{ol}"
        if job_name1 then
            tooltip_text = tooltip_text ..
                               color_if_match(string.gsub(dic.getTranslatedStr(job_name1), "{s18}", ""), id1) .. "{nl}"
        end
        if job_name2 then
            tooltip_text = tooltip_text ..
                               color_if_match(string.gsub(dic.getTranslatedStr(job_name2), "{s18}", ""), id2) .. "{nl}"
        end
        if job_name3 then
            tooltip_text = tooltip_text ..
                               color_if_match(string.gsub(dic.getTranslatedStr(job_name3), "{s18}", ""), id3) .. "{nl}"
        end
        if job_name4 then
            tooltip_text = tooltip_text ..
                               color_if_match(string.gsub(dic.getTranslatedStr(job_name4), "{s18}", ""), id4) .. "{nl}"
        end
        text = tooltip_text
        if g.login_name == pc_name then
            text = tooltip_text .. "{nl} {nl}" .. icon_rbtn_text
        end
    else
        local job_name = TryGetProp(last_job_class, "Name")
        text = "{ol}" .. string.gsub(dic.getTranslatedStr(job_name), "{s18}", "")
        if g.login_name == pc_name then
            text = text .. "{nl} {nl}" .. icon_rbtn_text
        end
    end

    local functionName = "INSTANTCC_ON_INIT"
    if type(_G[functionName]) == "function" then

        local cid = data.cid
        local layer = data.layer

        local cc_text = ""
        if g.lang == "Japanese" then
            cc_text = "左クリック: キャラクターチェンジ"
        else
            cc_text = "Left-click: Character Change"
        end

        job_icon:SetTextTooltip(text .. "{nl} {nl}{#FF4500}" .. cc_text)
        job_slot:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_INSTANTCC_DO_CC")
        job_slot:SetEventScriptArgString(ui.LBUTTONDOWN, cid)
        job_slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, layer)

        -- job_slot:SetEventScriptArgString(ui.LBUTTONDOWN, cid)
        -- job_slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, layer)

        name_text:SetEventScript(ui.LBUTTONDOWN, "indun_list_viewer_INSTANTCC_DO_CC")
        name_text:SetEventScriptArgString(ui.LBUTTONDOWN, cid)
        name_text:SetEventScriptArgNumber(ui.LBUTTONDOWN, layer)
        name_text:SetTextTooltip(text .. "{nl} {nl}{#FF4500}" .. cc_text)
    else
        job_icon:SetTextTooltip(text)
    end
end

function indun_list_viewer_INSTANTCC_DO_CC(frame, ctrl, cid, layer)
    g.layer = nil
    INSTANTCC_DO_CC(cid, layer)
end

function indun_list_viewer_modechange(frame, ctrl, argStr, argNum)
    -- hidden
    local ctrl_name = ctrl:GetName()
    local ischeck = ctrl:IsChecked()
    if ctrl_name == "hidden" then
        if ischeck == 1 then
            g.settings.hidden = 1
        else
            g.settings.hidden = 0
        end
    else
        if ischeck == 1 then
            g.settings.display_mode = "slide"
        else
            g.settings.display_mode = "full"
        end
    end

    indun_list_viewer_save_settings()
    indun_list_viewer_title_frame_open()
end

function indun_list_viewer_STATUS_SELET_REPRESENTATION_CLASS(my_frame, my_msg)
    local select_index, select_key = g.get_event_args(my_msg)

    local main_session = session.GetMainSession();
    local pc_job_info = main_session:GetPCJobInfo();
    local job_count = pc_job_info:GetJobCount();
    g.settings[g.login_name].jobid = ""
    for i = 0, job_count - 1 do
        local job_info = pc_job_info:GetJobInfoByIndex(i);
        g.settings[g.login_name].jobid = g.settings[g.login_name].jobid .. "/" .. job_info.jobID
    end

    g.settings[g.login_name].president_jobid = select_key
    indun_list_viewer_save_settings()
    indun_list_viewer_title_frame_open()
end

function indun_list_viewer_enter_context(frame, ctrl, str, num)
    local solo = g.lang == "Japanese" and "ソロ" or "SOLO"
    local auto = g.lang == "Japanese" and "自動" or "AUTO"
    local context = ui.CreateContextMenu("context", "", 0, 0, 0, 0);

    local strScp = string.format("indun_list_viewer_enter_solo(%d)", ctrl:GetUserIValue("SOLO"))
    ui.AddContextMenuItem(context, solo, strScp)
    strScp = string.format("indun_list_viewer_enter_auto(%d)", ctrl:GetUserIValue("AUTO"))
    ui.AddContextMenuItem(context, auto, strScp)
    ui.OpenContextMenu(context);
end

function indun_list_viewer_enter_solo(induntype)
    local frame = ui.GetFrame(addon_name_lower .. "list_frame")
    frame:ShowWindow(0)

    ReqRaidAutoUIOpen(induntype)
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 1, 0), 0.3)
end

function indun_list_viewer_enter_auto(induntype)
    local frame = ui.GetFrame(addon_name_lower .. "list_frame")
    frame:ShowWindow(0)

    ReqRaidAutoUIOpen(induntype)
    local topFrame = ui.GetFrame("indunenter")
    -- local useCount = tonumber(topFrame:GetUserValue("multipleCount"));
    local indunType = topFrame:GetUserValue('INDUN_TYPE');
    local indunCls = GetClassByType('Indun', indunType);
    local indunMinPCRank = TryGetProp(indunCls, 'PCRank')
    local totaljobcount = session.GetPcTotalJobGrade()

    if indunMinPCRank ~= nil then
        if indunMinPCRank > totaljobcount and indunMinPCRank ~= totaljobcount then
            ui.SysMsg(ScpArgMsg('IndunEnterNeedPCRank', 'NEED_RANK', indunMinPCRank))
            return;
        end
    end
    ReserveScript(string.format("ReqMoveToIndun(%d,%d)", 2, 0), 0.3)
end

function indun_list_viewer_INDUNINFO_SET_BUTTONS(induntype, ctrl)
    local frame = ui.GetFrame(addon_name_lower .. "list_frame")
    local indunCls = GetClassByType('Indun', induntype)
    local dungeonType = TryGetProp(indunCls, "DungeonType", "None")
    local btnInfoCls = GetClassByStrProp("IndunInfoButton", "DungeonType", dungeonType)

    if dungeonType == "Raid" then
        btnInfoCls = INDUNINFO_SET_BUTTONS_FIND_CLASS(indunCls)
    end

    local redButtonScp = TryGetProp(btnInfoCls, "RedButtonScp")
    ctrl:SetUserValue('MOVE_INDUN_CLASSID', indunCls.ClassID)
    ctrl:SetEventScript(ui.LBUTTONUP, redButtonScp)
end

function indun_list_viewer_enter_hard(frame, ctrl, str, induntype)
    local frame = ui.GetFrame(addon_name_lower .. "list_frame")
    local indunCls = GetClassByType("Indun", induntype)
    if str == "false" then
        indun_list_viewer_INDUNINFO_SET_BUTTONS(induntype, ctrl)
        str = "true"
        ReserveScript(string.format("indun_list_viewer_enter_hard('%s','%s','%s',%d)", frame, ctrl, str, induntype), 0.5)
        return
    else
        SHOW_INDUNENTER_DIALOG(induntype)
        frame:ShowWindow(0)
        return
    end
end]==] -- ゴーレムH712 A710 S711 ネリンガH709 A707 S708 
--[[local packageItemCls = GetClass('Item', "misc_leatherFalouros");
local iconName = GET_ITEM_ICON_IMAGE(packageItemCls);
print(tostring(iconName))
local packageItemCls = GetClass('Item', "misc_boss_202509_weapon");
local iconName = GET_ITEM_ICON_IMAGE(packageItemCls);
print(tostring(iconName))
local packageItemCls = GetClass('Item', "misc_boss_202509_armor");
local iconName = GET_ITEM_ICON_IMAGE(packageItemCls);
print(tostring(iconName))]] --[[function indun_list_viewer_get_reset_time()
    local now = os.time()
    local date_table = os.date("*t", now)
    local current_day = date_table.wday
    local next_monday_timestamp

    if current_day == 2 and date_table.hour < 6 then
        next_monday_timestamp = os.time({
            year = date_table.year,
            month = date_table.month,
            day = date_table.day,
            hour = 6,
            min = 0,
            sec = 0
        })
    else
        local days_to_next_monday = (9 - current_day) % 7
        if days_to_next_monday == 0 then
            days_to_next_monday = 7 -- 次週の月曜日に設定
        end

        local next_monday_date = os.date("*t", now + days_to_next_monday * 86400)
        next_monday_timestamp = os.time({
            year = next_monday_date.year,
            month = next_monday_date.month,
            day = next_monday_date.day,
            hour = 6,
            min = 0,
            sec = 0
        })
    end

    return next_monday_timestamp
end]] --[[function indun_list_viewer_BARRACK_TO_GAME(...)

    local bc_frame = ui.GetFrame("barrack_charlist")
    if bc_frame then
        g.layer = tonumber(bc_frame:GetUserValue("SelectBarrackLayer"))
        _G["norisan"] = _G["norisan"] or {}
        _G["norisan"]["LAST_LAYER"] = tonumber(bc_frame:GetUserValue("SelectBarrackLayer"))
    end

    local original_func = g.FUNCS["BARRACK_TO_GAME"]

    local result

    if original_func then
        result = original_func(...)
    end
    return result
end

function indun_list_viewer_BARRACK_TO_GAME_HOOK()
    g.FUNCS = g.FUNCS or {}
    local origin_func_name = "BARRACK_TO_GAME"
    if _G[origin_func_name] then
        if not g.FUNCS[origin_func_name] then
            g.FUNCS[origin_func_name] = _G[origin_func_name]
        end
        _G[origin_func_name] = indun_list_viewer_BARRACK_TO_GAME
    end
end]] --[[_G["norisan"] = _G["norisan"] or {}
    _G["norisan"]["HOOKS"] = _G["norisan"]["HOOKS"] or {}
    if not _G["norisan"]["HOOKS"]["BARRACK_TO_GAME"] then
        _G["norisan"]["HOOKS"]["BARRACK_TO_GAME"] = addon_name
        addon:RegisterMsg("GAME_START", "indun_list_viewer_BARRACK_TO_GAME_HOOK")
    end]] --[[if not settings then
        settings = {
            reset_time = 1702846800,
            display_mode = "full"
        }
    end

    local acc_info = session.barrack.GetMyAccount()
    if g.load == true then
        local barrack_cnt = acc_info:GetBarrackPCCount()

        for i = 0, barrack_cnt - 1 do
            local pc_info = acc_info:GetBarrackPCByIndex(i)
            local pc_name = pc_info:GetName()

            if not settings[pc_name] then
                settings[pc_name] = {
                    pc_name = pc_name,
                    layer = 9,
                    order = 99,
                    hide = false,
                    memo = "",
                    president_jobid = "",
                    jobid = "",
                    raid_count = {
                        V_H = "?",
                        V_A = "?",
                        L_H = "?",
                        L_A = "?",
                        R_H = "?",
                        R_A = "?",
                        N_H = "?",
                        N_A = "?",
                        G_H = "?",
                        G_A = "?",
                        M_H = "?",
                        M_A = "?",
                        S_H = "?",
                        S_A = "?",
                        U_H = "?",
                        U_A = "?",
                        RO_H = "?",
                        RO_A = "?",
                        F_H = "?",
                        F_A = "?",
                        P_H = "?",
                        P_A = "?",
                        D_H = "?",
                        D_A = "?"

                    },
                    auto_clear_count = {
                        V_S = "?",
                        L_S = "?",
                        R_S = "?",
                        N_S = "?",
                        G_S = "?",
                        M_S = "?",
                        S_S = "?",
                        U_S = "?",
                        RO_S = "?",
                        F_S = "?",
                        P_S = "?",
                        D_S = "?"
                    }
                }

            elseif settings[pc_name] and settings[pc_name]["raid_count"] then

                if not settings[pc_name]["raid_count"].V_H then
                    settings[pc_name]["raid_count"].V_H = "?"
                    settings[pc_name]["raid_count"].V_A = "?"

                    if settings[pc_name]["auto_clear_count"] then
                        settings[pc_name]["auto_clear_count"].V_S = "?"
                    end
                end
                if not settings[pc_name]["raid_count"].L_H then
                    settings[pc_name]["raid_count"].L_H = "?"
                    settings[pc_name]["raid_count"].L_A = "?"

                    if settings[pc_name]["auto_clear_count"] then
                        settings[pc_name]["auto_clear_count"].L_S = "?"
                    end
                end
                if not settings[pc_name]["raid_count"].R_H then
                    settings[pc_name]["raid_count"].R_H = "?"
                    settings[pc_name]["raid_count"].R_A = "?"

                    if settings[pc_name]["auto_clear_count"] then
                        settings[pc_name]["auto_clear_count"].R_S = "?"
                    end
                end
                if not settings[pc_name]["raid_count"].RO_H then
                    settings[pc_name]["raid_count"].RO_H = "?"
                    settings[pc_name]["raid_count"].RO_A = "?"

                    if settings[pc_name]["auto_clear_count"] then
                        settings[pc_name]["auto_clear_count"].RO_S = "?"
                    end
                end
                if not settings[pc_name]["raid_count"].F_H then
                    settings[pc_name]["raid_count"].F_H = "?"
                    settings[pc_name]["raid_count"].F_A = "?"

                    if settings[pc_name]["auto_clear_count"] then
                        settings[pc_name]["auto_clear_count"].F_S = "?"
                    end
                end
                if not settings[pc_name]["raid_count"].P_H then
                    settings[pc_name]["raid_count"].P_H = "?"
                    settings[pc_name]["raid_count"].P_A = "?"

                    if settings[pc_name]["auto_clear_count"] then
                        settings[pc_name]["auto_clear_count"].P_S = "?"
                    end
                end
                if not settings[pc_name]["raid_count"].D_H then
                    settings[pc_name]["raid_count"].D_H = "?"
                    settings[pc_name]["raid_count"].D_A = "?"

                    if settings[pc_name]["auto_clear_count"] then
                        settings[pc_name]["auto_clear_count"].D_S = "?"
                    end
                end
            end

        end
    end

    g.settings = settings

    indun_list_viewer_save_settings()]] --[[for i = 0, barrack_pc_count - 1 do
        local barrack_pc_info = account_info:GetBarrackPCByIndex(i)
        local barrack_pc_name = barrack_pc_info:GetName()

        g.settings[barrack_pc_name]["raid_count"] = {
            V_H = "?",
            V_A = "?",
            L_H = "?",
            L_A = "?",
            R_H = "?",
            R_A = "?",
            N_H = "?",
            N_A = "?",
            G_H = "?",
            G_A = "?",
            M_H = "?",
            M_A = "?",
            S_H = "?",
            S_A = "?",
            U_H = "?",
            U_A = "?",
            RO_H = "?",
            RO_A = "?",
            F_H = "?",
            F_A = "?",
            P_H = "?",
            P_A = "?",
            D_H = "?",
            D_A = "?"
        }
    end
    g.settings.reset_time = indun_list_viewer_get_reset_time()
    indun_list_viewer_save_settings()]] --[[if g.load == true then
    indun_list_viewer_sort_characters(acc_info)
    local server_time_str = date_time.get_lua_now_datetime_str()
    if server_time_str then
        local y, m, d, H, M, S = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
        if y then
            local server_now_timestamp = os.time({
                year = tonumber(y),
                month = tonumber(m),
                day = tonumber(d),
                hour = tonumber(H),
                min = tonumber(M),
                sec = tonumber(S)
            })
            if server_now_timestamp > g.settings.reset_time then
                indun_list_viewer_raid_reset()
            end
        end
    end
else
    g.sorted_settings = {}
    for _, data in pairs(g.settings) do
        if type(data) == "table" then
            table.insert(g.sorted_settings, data)
        end
    end
    local function sort_layer_order(a, b)
        if a.layer ~= b.layer then
            return a.layer < b.layer
        else
            return a.order < b.order
        end
    end
    table.sort(g.sorted_settings, sort_layer_order)
    g.load = true
end

indun_list_viewer_frame_init()
local check_table = {"Veliora_H", "Limara_H", "Redania_H", "Neringa_H", "Golem_H", "Merregina_H", "Slogutis_H",
                     "Upinis_H", "Roze_H", "Falouros_H", "Spreader_H", "Delmore_H", "Veliora_S", "Limara_S",
                     "Redania_S", "Neringa_S", "Golem_S", "Merregina_S", "Slogutis_S", "Upinis_S", "Roze_S",
                     "Falouros_S", "Spreader_S", "Delmore_S", "Memo"}
                     function indun_list_viewer_delete_character()

    local acc_info = session.barrack.GetMyAccount()
    local barrack_cnt = acc_info:GetBarrackPCCount()

    local barrack_names = {}
    for i = 0, barrack_cnt - 1 do
        local pc_info = acc_info:GetBarrackPCByIndex(i)
        local pc_name = pc_info:GetName()
        table.insert(barrack_names, pc_name)
    end
    local remove_keys = {}
    if g.settings then
        for set_key, data_val in pairs(g.settings) do
            local is_char_data = false
            if type(data_val) == "table" and data_val.pc_name then
                is_char_data = true
            end
            if is_char_data then
                local found_barrack = false
                if barrack_names and #barrack_names > 0 then
                    for _, name_barrack in ipairs(barrack_names) do
                        if set_key == name_barrack then
                            found_barrack = true
                            break
                        end
                    end
                end
                if not found_barrack then
                    table.insert(remove_keys, set_key)
                end
            end
        end
        if #remove_keys > 0 then
            for _, key_del in ipairs(remove_keys) do
                g.settings[key_del] = nil
            end
        end
    end
    indun_list_viewer_save_settings()
end]] -- ui.SetChatType(5)
--[[local Judgment = room_id == "None" and false or true

    local name = ""

    if is_start == "None" or room_id ~= "None" then

        name = group_data.name
        chat:SetUserValue("IS_START", "not_start")
        chat:SetUserValue("ROOM_ID", room_id_str)

    elseif target_name and chat:GetUserValue("CHAT_TYPE_SELECTED_VALUE") == "5" then
        room_id_str = chat:GetUserValue("ROOM_ID")
        local group_data = g.settings.new_groups[room_id_str]
        if not group_data then
            return
        end -- ガード
        name = group_data.name

    else
        return
    end

    --[[local name = ""
   
    local room_id_str = ""
    ts(9, "selected_chat_str", selected_chat_str)
    ts(9.1, is_start, room_id, target_name)
    if is_start == "None" then
        chat:SetUserValue("IS_START", "not_start")
        chat:SetUserValue("ROOM_ID", tostring(room_id))
        name = g.settings.new_groups[tostring(room_id)].name
        room_id_str = tostring(room_id)
    elseif room_id ~= "None" then
        chat:SetUserValue("ROOM_ID", tostring(room_id))
        name = g.settings.new_groups[tostring(room_id)].name
        room_id_str = tostring(room_id)
    elseif target_name and selected_chat_str == "5" then
        room_id = chat:GetUserValue("ROOM_ID")
        name = g.settings.new_groups[room_id].name
        room_id_str = tostring(room_id)
    else

        return
    end]] --[==[if my_frame then
        if chat:HaveUpdateScript("mini_addons_CHAT_SET_TO_TITLENAME_") == false then

            chat:RunUpdateScript("mini_addons_CHAT_SET_TO_TITLENAME_", 0.1)
            return
        else
            chat:StopUpdateScript("mini_addons_CHAT_SET_TO_TITLENAME_")
        end
    elseif not my_frame and (my_frame:GetName() ~= "chat") then
        chat:SetUserValue("CHAT_TYPE_SELECTED_VALUE", "5")
    end
   

    --[[if Judgment and not g.settings.group_caption then
        local btn_save_text = string.gsub(button_type:GetText(), "{@st60}", "")
        btn_save_text = string.gsub(btn_save_text, "{ol}{s18}", "")
        btn_save_text = string.gsub(btn_save_text, "%{#%x+%}", "")
        btn_save_text = string.gsub(btn_save_text, "%{/%}", "")
        g.settings.group_caption = btn_save_text
        MINI_ADDONS_SAVE_SETTINGS()
    end]]

    

    local group_data = g.settings.new_groups[room_id_str]
    if not group_data then

        return
    end
    ts(room_id_str)
    local btn_text = g.settings.group_caption
    ts(group_data.color)
    local color = "{#" .. group_data.color .. "}"
    ts(color)
    btn_text = color .. btn_text
    ts(btn_text)
    button_type:SetText("{ol}{s18}" .. color .. btn_text)
    local color_tone = "FF" .. group_data.color
    title_to:SetFontName("")
    title_to:SetColorTone(color_tone)
    button_type:SetColorTone(color_tone)
    edit_to_bg:SetSkinName("bg2")
    ts(11)
    if chat and mainchat and edit_to_bg and edit_bg and title_to and button_type then
        edit_to_bg:SetOffset(button_type:GetOriginalWidth(), edit_to_bg:GetOriginalY())
        local offset_x = button_type:GetOriginalWidth()
        local isVisible = selected_chat_str == "5" and 1 or 0
        ts(15.1, "selected_chat_str", selected_chat_str)
        local title_text = name
        if not title_text then
            return
        end
        title_to:SetText(title_text)
        title_to:SetEventScript(ui.LBUTTONUP, "mini_addons_chat_group_context")
        title_to:SetEventScriptArgString(ui.LBUTTONUP, title_text)
        if title_text ~= '' then
            edit_to_bg:Resize(title_to:GetWidth() + 20, edit_to_bg:GetOriginalHeight())
        else
            edit_to_bg:Resize(title_to:GetWidth(), edit_to_bg:GetOriginalHeight())
        end
        ts(15.2, "isVisible", isVisible)
        if isVisible == 1 then
            edit_to_bg:SetVisible(1)
            offset_x = offset_x + edit_to_bg:GetWidth()
        else
            edit_to_bg:SetVisible(0)
        end
        local width = mainchat:GetOriginalWidth() - edit_to_bg:GetWidth() - button_type:GetWidth()
        mainchat:Resize(width, mainchat:GetOriginalHeight())
        mainchat:SetOffset(offset_x, mainchat:GetOriginalY())
        ui.SetGroupChatTargetID(room_id_str)

        -- ui.SetChatType(5)
    end
    
    -- mini_addons_second_frame()
function mini_addons_frames_show_check()
    local frame_name = addon_name_lower .. "second_open"
    local second_open = ui.GetFrame(frame_name)
    if not second_open then
        return
    end
    AUTO_CAST(second_open)

    local util_frame_name = _G["norisan"]["MENU"].frame_name
    -- ts(util_frame_name)
    local util_frame = ui.GetFrame(util_frame_name)
    -- ts(util_frame)
    if util_frame then
        AUTO_CAST(util_frame)
        util_frame:ShowWindow(1)
        second_open:ShowWindow(0)
    else
        if second_open:IsVisible() == 0 then
            second_open:ShowWindow(1)
        end
    end

end]==] --[==[unction indun_panel_config_gb_open(frame, ctrl, argStr, argNum)

    local frame = ui.GetFrame("indun_panel")
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(90)

    frame:EnableHittestFrame(1)
    frame:SetAlpha(100)
    frame:RemoveAllChild()
    frame:ShowWindow(1)

    local closeBtn = frame:CreateOrGetControl('button', 'closeBtn', 0, 0, 30, 30)
    AUTO_CAST(closeBtn)
    closeBtn:SetImage("testclose_button")
    closeBtn:SetGravity(ui.RIGHT, ui.TOP)
    closeBtn:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init");

    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s10}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")

    local position = frame:CreateOrGetControl("button", "position", 90, 5, 60, 30)
    AUTO_CAST(position)
    position:SetText("{ol}{s10}BASE POS")
    position:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_base_position")
    -- indun_panel_INPUT_STRING_BOX
    local tool_text = g.lang == "Japanese" and "{ol}右クリック: セット名変更" or
                          "{ol}Right-click: Rename Set"
    local set_a = frame:CreateOrGetControl("button", "set_a", 200, 5, 80, 30)
    AUTO_CAST(set_a)
    local text = g.settings.set_names["set_a"] or "SET A"
    set_a:Resize(80, 30)
    set_a:SetText("{ol}" .. text)
    set_a:Resize(80, 30)
    set_a:AdjustFontSizeByWidth(80)
    set_a:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_save")
    set_a:SetEventScriptArgString(ui.LBUTTONUP, set_a:GetName())

    set_a:SetEventScript(ui.RBUTTONUP, "indun_panel_INPUT_STRING_BOX")
    set_a:SetEventScriptArgString(ui.RBUTTONUP, set_a:GetName())
    if g.settings.use_set == "set_a" then
        set_a:SetSkinName("test_red_button")
    end
    set_a:SetTextTooltip(tool_text)

    local set_b = frame:CreateOrGetControl("button", "set_b", 285, 5, 80, 30)
    AUTO_CAST(set_b)
    local text = g.settings.set_names["set_b"] or "SET B"
    set_b:Resize(80, 30)
    set_b:SetText("{ol}" .. text)
    set_b:Resize(80, 30)
    set_b:AdjustFontSizeByWidth(80)
    set_b:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_save")
    set_b:SetEventScriptArgString(ui.LBUTTONUP, set_b:GetName())
    set_b:SetEventScript(ui.RBUTTONUP, "indun_panel_INPUT_STRING_BOX")
    set_b:SetEventScriptArgString(ui.RBUTTONUP, set_b:GetName())
    if g.settings.use_set == "set_b" then
        set_b:SetSkinName("test_red_button")
    end
    set_b:SetTextTooltip(tool_text)

    local set_c = frame:CreateOrGetControl("button", "set_c", 370, 5, 80, 30)
    AUTO_CAST(set_c)
    local text = g.settings.set_names["set_c"] or "SET C"
    set_c:SetText("{ol}" .. text)
    set_c:Resize(80, 30)
    set_c:AdjustFontSizeByWidth(80)
    set_c:Resize(80, 30)
    set_c:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_save")
    set_c:SetEventScriptArgString(ui.LBUTTONUP, set_c:GetName())
    set_c:SetEventScript(ui.RBUTTONUP, "indun_panel_INPUT_STRING_BOX")
    set_c:SetEventScriptArgString(ui.RBUTTONUP, set_c:GetName())
    if g.settings.use_set == "set_c" then
        set_c:SetSkinName("test_red_button")
    end
    set_c:SetTextTooltip(tool_text)

    local skin_change = frame:CreateOrGetControl("button", "skin_change", 470, 5, 80, 30)
    AUTO_CAST(skin_change)
    local text = g.lang == "Japanese" and "{ol}フレームスキン選択" or "{ol}Select Frame Skin"
    skin_change:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_skin_select")
    skin_change:SetText("{ol}SKIN SELECT")
    skin_change:SetTextTooltip("{ol}" .. text)

    --[[    local droplist = ui.MakeDropListFrame(frame, 460, 5, 100, 30, 3, ui.CENTER_HORZ, 'indun_panel_frame_skin_select',
        nil, nil); -- 最後2個はマウスオーバーとマウスアウト
    for l = 1, 3 do
        ui.AddDropListItem(dropBoxItem.Name, nil, dropBoxItem.ClassName)
    end]]

    ---ここから

    local config_x = 15
    local tosshop = frame:CreateOrGetControl("checkbox", "tosshop", config_x, 47, 25, 25);
    AUTO_CAST(tosshop)
    tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
    tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    tosshop:SetEventScriptArgString(ui.LBUTTONUP, "config")
    tosshop:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                               "{ol}Always visible when checked")
    tosshop:SetCheck(g.settings.cols.tos)
    config_x = config_x + tosshop:GetWidth() + 5

    local gabija = frame:CreateOrGetControl("checkbox", "gabija", config_x, 47, 29, 29);
    AUTO_CAST(gabija)
    gabija:SetText("{img goddess_shop_btn 29 29}")
    gabija:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    gabija:SetEventScriptArgString(ui.LBUTTONUP, "config")
    gabija:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                              "{ol}Always visible when checked")
    gabija:SetCheck(g.settings.cols.gabija)
    config_x = config_x + gabija:GetWidth() + 5

    local vakarine = frame:CreateOrGetControl("checkbox", "vakarine", config_x, 47, 29, 29);
    AUTO_CAST(vakarine)
    vakarine:SetText("{img goddess2_shop_btn 29 29}")
    vakarine:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    vakarine:SetEventScriptArgString(ui.LBUTTONUP, "config")
    vakarine:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                "{ol}Always visible when checked")
    vakarine:SetCheck(g.settings.cols.vakarine)
    config_x = config_x + vakarine:GetWidth() + 5

    local rada = frame:CreateOrGetControl("checkbox", "rada", config_x, 47, 29, 29);
    AUTO_CAST(rada)
    rada:SetText("{img goddess3_shop_btn 29 29}")
    rada:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    rada:SetEventScriptArgString(ui.LBUTTONUP, "config")
    rada:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                            "{ol}Always visible when checked")
    rada:SetCheck(g.settings.cols.rada)
    config_x = config_x + rada:GetWidth() + 5

    local jurate = frame:CreateOrGetControl("checkbox", "jurate", config_x, 47, 29, 29);
    AUTO_CAST(jurate)
    jurate:SetText("{img goddess4_shop_btn 29 29}")
    jurate:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    jurate:SetEventScriptArgString(ui.LBUTTONUP, "config")
    jurate:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                              "{ol}Always visible when checked")
    jurate:SetCheck(g.settings.cols.jurate)
    config_x = config_x + jurate:GetWidth() + 5

    local austeja = frame:CreateOrGetControl("checkbox", "austeja", config_x, 47, 29, 29);
    AUTO_CAST(austeja)
    austeja:SetText("{img goddess5_shop_btn 29 29}")
    austeja:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    austeja:SetEventScriptArgString(ui.LBUTTONUP, "config")
    austeja:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                               "{ol}Always visible when checked")
    austeja:SetCheck(g.settings.cols.austeja)
    config_x = config_x + austeja:GetWidth() + 5

    local pvp_mine = frame:CreateOrGetControl("checkbox", "pvp_mine", config_x, 47, 29, 29);
    AUTO_CAST(pvp_mine)
    pvp_mine:SetText("{img pvpmine_shop_btn_total 29 29}")
    pvp_mine:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    pvp_mine:SetEventScriptArgString(ui.LBUTTONUP, "config")
    pvp_mine:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                                "{ol}Always visible when checked")
    pvp_mine:SetCheck(g.settings.cols.pvp_mine)
    config_x = config_x + pvp_mine:GetWidth() + 5

    local market = frame:CreateOrGetControl("checkbox", "market", config_x, 47, 29, 29);
    AUTO_CAST(market)
    market:SetText("{img market_shortcut_btn02 29 29}")
    market:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    market:SetEventScriptArgString(ui.LBUTTONUP, "config")
    market:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                              "{ol}Always visible when checked")
    market:SetCheck(g.settings.cols.market)
    config_x = config_x + market:GetWidth() + 5

    local craft = frame:CreateOrGetControl("checkbox", "craft", config_x, 47, 29, 29);
    AUTO_CAST(craft)
    craft:SetText("{img icon_fullscreen_menu_equipment_processing 28 28}")
    craft:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    craft:SetEventScriptArgString(ui.LBUTTONUP, "config")
    craft:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                             "{ol}Always visible when checked")
    craft:SetCheck(g.settings.cols.craft)
    config_x = config_x + craft:GetWidth() + 5

    local leticia = frame:CreateOrGetControl("checkbox", "leticia", config_x, 47, 29, 29);
    AUTO_CAST(leticia)
    leticia:SetText("{img icon_fullscreen_menu_letica 28 28}")
    leticia:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    leticia:SetEventScriptArgString(ui.LBUTTONUP, "config")
    leticia:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常に表示" or
                               "{ol}Always visible when checked")
    leticia:SetCheck(g.settings.cols.leticia)
    config_x = config_x + leticia:GetWidth() + 5

    local label_line2 = frame:CreateControl('labelline', 'label_line2', 10, 77, config_x, 5);
    AUTO_CAST(label_line2)
    label_line2:SetSkinName("labelline2")

    local en_ver = frame:CreateOrGetControl('checkbox', 'en_ver', 25, 85, 25, 25)
    AUTO_CAST(en_ver)
    if g.settings.en_ver == nil then
        g.settings.en_ver = 0
        g.save_settings()
    end
    en_ver:SetCheck(g.settings.en_ver)
    en_ver:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    en_ver:SetText(g.lang == "Japanese" and "{ol}チェックすると英語表示に変更します" or
                       "{ol}Check to display to English")

    local move = frame:CreateOrGetControl('checkbox', 'move', 25, 120, 25, 25)
    AUTO_CAST(move)
    if g.settings.move == nil then
        g.settings.move = 0
        g.save_settings()
    end
    move:SetCheck(g.settings.move)
    move:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    move:SetText(g.lang == "Japanese" and "{ol}チェックするとフレームを動かせます" or
                     "{ol}Check to move the frame")

    local field_mode = frame:CreateOrGetControl('checkbox', 'field_mode', 25, 155, 25, 25)
    AUTO_CAST(field_mode)
    if g.settings.field_mode == nil then
        g.settings.field_mode = 0
        g.save_settings()
    end
    field_mode:SetCheck(g.settings.field_mode)
    field_mode:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    field_mode:SetText(g.lang == "Japanese" and "{ol}チェックするとフィールドで表示" or
                           "{ol}Check to display in field")

    local shading = frame:CreateOrGetControl('checkbox', 'shading', 25, 190, 25, 25)
    AUTO_CAST(shading)
    if g.settings.shading == nil then
        g.settings.shading = 0
        g.save_settings()
    end
    shading:SetCheck(g.settings.shading)
    shading:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    shading:SetText(g.lang == "Japanese" and "{ol}チェックすると網掛け表示" or
                        "{ol}Check to display shading")

    local label_line = frame:CreateControl('labelline', 'label_line', 10, 215, config_x, 5);
    AUTO_CAST(label_line)
    label_line:SetSkinName("labelline2")

    local posY_left = 220 -- 左の列のY座標
    local posY_right = 220 -- 右の列のY座標

    local count = #induntype
    local half_count = math.ceil(count / 2)
    local use_tbl = g.settings[g.settings.use_set] ~= "None" and g.settings[g.settings.use_set] or g.settings
    for i = 1, count do
        local entry = induntype[i]
        for key, value in pairs(entry) do
            local checkbox

            if i <= half_count then

                checkbox = frame:CreateOrGetControl('checkbox', key .. '_checkbox', 15, posY_left, 25, 25)
                AUTO_CAST(checkbox)
                posY_left = posY_left + 35
            else

                checkbox = frame:CreateOrGetControl('checkbox', key .. '_checkbox', 325, posY_right, 25, 25)
                AUTO_CAST(checkbox)
                posY_right = posY_right + 35
            end

            checkbox:SetCheck(use_tbl[key .. '_checkbox'])
            checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
            checkbox:SetText("{ol}{#FFFFFF}" .. INDUN_PANEL_LANG(convert_tbl[key] or key))
            checkbox:SetTextTooltip(g.lang == "Japanese" and "チェックすると表示" or "Check to show")
        end
    end
    local final_height = math.max(posY_left, posY_right)
    frame:Resize(660, final_height + 5)
end --[[function indun_panel_frame_init()

    local frame = ui.GetFrame("indun_panel")

    frame:SetSkinName('None')
    frame:SetLayerLevel(30)

    frame:EnableHittestFrame(1)
    frame:EnableMove(g.settings.move or 0)
    frame:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_drag")
    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

    if not g.settings.x then
        g.settings.x = 665
        g.settings.y = 30
        g.save_settings()
    end

    local x = g.settings.x
    if width <= 1920 and x > 1920 then
        x = g.settings.x / 21 * 16
    end

    frame:SetPos(x, g.settings.y)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:RemoveAllChild()

    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s10}INDUNPANEL")
    button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_open")
    button:SetEventScript(ui.RBUTTONUP, "indun_panel_always_init")
    button:SetEventScriptArgString(ui.RBUTTONUP, "OPEN")
    button:SetTextTooltip(g.lang == "Japanese" and "{ol}右クリック: 常時展開で開く" or
                              "{ol}Right click: Open in Always Expand")

    local ccbtn = frame:CreateOrGetControl('button', 'ccbtn', 85, 5, 30, 30)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 30 30}")

    local lbutton_action = "APPS_TRY_MOVE_BARRACK"
    local rbutton_action = nil
    local tooltip_parts = {}

    local lbutton_tooltip = nil

    if type(_G["INSTANTCC_APPS_TRY_MOVE_BARRACK"]) == "function" then
        lbutton_action = "INSTANTCC_APPS_TRY_MOVE_BARRACK"
        lbutton_tooltip = "[InstantCC] Open"
    end

    if type(_G["indun_list_viewer_title_frame_open"]) == "function" then
        lbutton_action = "indun_list_viewer_title_frame_open"
        lbutton_tooltip = "Left-Click: [ILV] Open"
        local indun_list_viewer = ui.GetFrame("indun_list_viewer")
        if indun_list_viewer:IsVisible() == 1 then
            indun_list_viewer:ShowWindow(0)
        end
    end

    if lbutton_tooltip then
        table.insert(tooltip_parts, lbutton_tooltip)
    end

    if type(_G["other_character_skill_list_frame_open"]) == "function" then
        rbutton_action = "other_character_skill_list_frame_open"
        table.insert(tooltip_parts, "Right-Click: [OCSL] Open")
    end

    ccbtn:SetEventScript(ui.LBUTTONUP, lbutton_action)
    if rbutton_action then
        ccbtn:SetEventScript(ui.RBUTTONUP, rbutton_action)
    end

    if #tooltip_parts > 0 then
        ccbtn:SetTextTooltip("{ol}" .. table.concat(tooltip_parts, "{nl}"))
    else
        ccbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}バラックに戻ります" or "{ol}Return to Barracks")
    end

    local x = 115

    local temp_tbl =
        {"tos", "gabija", "vakarine", "rada", "jurate", "austeja", "pvp_mine", "market", "craft", "leticia"}

    if not g.settings.cols then
        g.settings.cols = {}
        for _, key_name in ipairs(temp_tbl) do

            if key_name == "leticia" then
                g.settings.cols[key_name] = 1
            else
                g.settings.cols[key_name] = 0
            end

        end

        g.save_settings()
    else
        for _, key_name in ipairs(temp_tbl) do
            if not g.settings.cols[key_name] then
                g.settings.cols[key_name] = 0
            end
        end
    end

    local account_obj = GetMyAccountObj()
    local coin_count = 0

    for _, key_name in ipairs(temp_tbl) do
        if g.settings.cols[key_name] == 1 then
            local tooltip_msg = ""
            if key_name == "tos" then
                if g.get_map_type() == "City" then
                    local tosshop = frame:CreateOrGetControl("button", "tosshop", x + 2, 8, 25, 25);
                    AUTO_CAST(tosshop)
                    tosshop:SetSkinName("None")
                    tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0"))
                    tooltip_msg = g.lang == "Japanese" and "{ol}TOSイベントショップ" or "{ol}TOS Event Shop"
                    tosshop:SetTextTooltip(tooltip_msg)
                    tosshop:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_event_tos_whole_shop_open")
                end
            elseif key_name == "gabija" then
                if g.get_map_type() == "City" then
                    local gabija = frame:CreateOrGetControl("button", "gabija", x, 7, 29, 29);
                    AUTO_CAST(gabija)
                    gabija:SetSkinName("None")
                    gabija:SetText("{img goddess_shop_btn 29 29}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "GabijaCertificate", "0"))
                    tooltip_msg =
                        g.lang == "Japanese" and "{ol}ガビヤショップ{nl}" .. "{#FFFF00}" .. coin_count or
                            "{ol}Gabija Shop{nl}" .. "{#FFFF00}" .. coin_count
                    gabija:SetTextTooltip(tooltip_msg)
                    gabija:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    gabija:SetEventScript(ui.LBUTTONUP, "REQ_GabijaCertificate_SHOP_OPEN")
                end
            elseif key_name == "vakarine" then
                if g.get_map_type() == "City" then
                    local vakarine = frame:CreateOrGetControl("button", "vakarine", x, 7, 29, 29);
                    AUTO_CAST(vakarine)
                    vakarine:SetSkinName("None")
                    vakarine:SetText("{img goddess2_shop_btn 29 29}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "VakarineCertificate", "0"))
                    tooltip_msg = g.lang == "Japanese" and "{ol}ヴァカリネショップ{nl}" .. "{#FFFF00}" ..
                                      coin_count or "{ol}Vakarine Shop{nl}" .. "{#FFFF00}" .. coin_count
                    vakarine:SetTextTooltip(tooltip_msg)
                    vakarine:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    vakarine:SetEventScript(ui.LBUTTONUP, "REQ_VakarineCertificate_SHOP_OPEN")
                end
            elseif key_name == "rada" then
                if g.get_map_type() == "City" then
                    local rada = frame:CreateOrGetControl("button", "rada", x, 8, 29, 29);
                    AUTO_CAST(rada)
                    rada:SetSkinName("None")
                    rada:SetText("{img goddess3_shop_btn 29 29}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "RadaCertificate", "0"))
                    tooltip_msg = g.lang == "Japanese" and "{ol}ラダショップ{nl}" .. "{#FFFF00}" .. coin_count or
                                      "{ol}Rada Shop{nl}" .. "{#FFFF00}" .. coin_count
                    rada:SetTextTooltip(tooltip_msg)
                    rada:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    rada:SetEventScript(ui.LBUTTONUP, "REQ_RadaCertificate_SHOP_OPEN")
                end
            elseif key_name == "jurate" then
                if g.get_map_type() == "City" then
                    local jurate = frame:CreateOrGetControl("button", "jurate", x, 7, 29, 29);
                    AUTO_CAST(jurate)

                    jurate:SetSkinName("None")
                    jurate:SetText("{img goddess4_shop_btn 29 29}")
                    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "JurateCertificate", "0"))
                    tooltip_msg =
                        g.lang == "Japanese" and "{ol}ユラテショップ{nl}" .. "{#FFFF00}" .. coin_count or
                            "{ol}Jurate Shop{nl}" .. "{#FFFF00}" .. coin_count
                    jurate:SetTextTooltip(tooltip_msg)
                    jurate:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                    jurate:SetEventScript(ui.LBUTTONUP, "REQ_JurateCertificate_SHOP_OPEN")
                end
            elseif key_name == "austeja" then
                -- if g.get_map_type() == "City" then
                local austeja = frame:CreateOrGetControl("button", "austeja", x, 7, 29, 29);
                AUTO_CAST(austeja)
                if g.get_map_type() ~= "City" then
                    austeja:SetOffset(115, 7)
                end
                austeja:SetSkinName("None")
                austeja:SetText("{img goddess5_shop_btn 29 29}")
                coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "AustejaCertificate", "0"))
                tooltip_msg = g.lang == "Japanese" and "{ol}アウステヤショップ{nl}" .. "{#FFFF00}" ..
                                  coin_count or "{ol}Austeja Shop{nl}" .. "{#FFFF00}" .. coin_count
                austeja:SetTextTooltip(tooltip_msg)
                austeja:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                austeja:SetEventScript(ui.LBUTTONUP, "REQ_AustejaCertificate_SHOP_OPEN")
                -- end
            elseif key_name == "pvp_mine" then
                local pvp_mine = frame:CreateOrGetControl("button", "pvp_mine", x, 7, 29, 29);
                AUTO_CAST(pvp_mine)
                if g.get_map_type() ~= "City" then
                    pvp_mine:SetOffset(145, 7)
                end
                pvp_mine:SetSkinName("None")
                pvp_mine:SetText("{img pvpmine_shop_btn_total 29 29}")
                pvp_mine:SetTextTooltip(g.lang == "Japanese" and "{ol}傭兵団ショップ" or "{ol}Mercenary Shop")
                pvp_mine:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
                -- pvp_mine:SetEventScript(ui.LBUTTONUP, "REQ_PVP_MINE_SHOP_OPEN")
                pvp_mine:SetEventScript(ui.LBUTTONUP, "MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK")
                -- MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK
            elseif key_name == "market" then
                if g.get_map_type() == "City" then
                    local market = frame:CreateOrGetControl("button", "market", x, 6, 29, 29);
                    AUTO_CAST(market)
                    market:SetSkinName("None")
                    market:SetText("{img market_shortcut_btn02 29 29}")
                    market:SetTextTooltip(g.lang == "Japanese" and "{ol}マーケット" or "{ol}Market")
                    market:SetEventScript(ui.LBUTTONUP, "MINIMIZED_MARKET_BUTTON_CLICK")
                end
            elseif key_name == "craft" then
                if g.get_map_type() == "City" then
                    local craft = frame:CreateOrGetControl("button", "craft", x, 5, 29, 29);
                    AUTO_CAST(craft)
                    craft:SetSkinName("None")
                    craft:SetText("{img icon_fullscreen_menu_equipment_processing 28 28}")
                    craft:SetTextTooltip(g.lang == "Japanese" and "{ol}装備加工" or "{ol}Equipment Processing")
                    craft:SetEventScript(ui.LBUTTONUP, "FULLSCREEN_NAVIGATION_MENU_DEATIL_EQUIPMENT_PROCESSING_NPC")
                end
            elseif key_name == "leticia" then
                if g.get_map_type() == "City" then
                    local leticia = frame:CreateOrGetControl("button", "leticia", x, 5, 29, 29);
                    AUTO_CAST(leticia)
                    leticia:SetSkinName("None")
                    leticia:SetText("{img icon_fullscreen_menu_letica 28 28}")
                    leticia:SetTextTooltip(g.lang == "Japanese" and "{ol}レティーシャへ移動" or
                                               "{ol}Leticia Move")
                    leticia:SetEventScript(ui.LBUTTONUP, "indun_panel_FULLSCREEN_NAVIGATION_MENU_DETAIL_MOVE_NPC")
                    leticia:SetEventScriptArgNumber(ui.LBUTTONUP, 309)
                end
            end
            x = x + 30
        end
    end

    frame:Resize(x, 40)
    frame:ShowWindow(1)

end

function indun_panel_frame_open(frame)

    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

    if not g.settings.x then
        g.settings.x = 665
        g.settings.y = 30
        g.save_settings()
    end

    local x = g.settings.x
    if width <= 1920 and x > 1920 then
        x = g.settings.x / 21 * 16
    end

    local frame = ui.GetFrame("indun_panel")

    frame:SetPos(x, g.settings.y)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    if not g.settings.move then
        g.settings.move = 0
    end
    frame:EnableMove(g.settings.move)
    if g.settings.move == 1 then
        frame:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_drag")
    else
        frame:SetEventScript(ui.LBUTTONUP, "None")
    end
    frame:RemoveAllChild()

    local button = frame:CreateOrGetControl("button", "indun_panel_open", 5, 5, 80, 30)
    AUTO_CAST(button)
    button:SetText("{ol}{s10}INDUNPANEL")
    button:SetEventScript(ui.RBUTTONUP, "indun_panel_always_init")
    button:SetTextTooltip(g.lang == "Japanese" and "{ol}右クリック: 常時展開解除で閉じる" or
                              "{ol}Right click: Close with permanent unexpand")

    local ccbtn = frame:CreateOrGetControl('button', 'ccbtn', 85, 5, 30, 30)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{img barrack_button_normal 30 30}")
    local lbutton_action = "APPS_TRY_MOVE_BARRACK"
    local rbutton_action = nil
    local tooltip_parts = {}

    local lbutton_tooltip = nil

    if type(_G["INSTANTCC_APPS_TRY_MOVE_BARRACK"]) == "function" then
        lbutton_action = "INSTANTCC_APPS_TRY_MOVE_BARRACK"
        lbutton_tooltip = "[InstantCC] Open"
    end

    if type(_G["indun_list_viewer_title_frame_open"]) == "function" then
        lbutton_action = "indun_list_viewer_title_frame_open"
        lbutton_tooltip = "Left-Click: [ILV] Open"
        local indun_list_viewer = ui.GetFrame("indun_list_viewer")
        if indun_list_viewer:IsVisible() == 1 then
            indun_list_viewer:ShowWindow(0)
        end
    end

    if lbutton_tooltip then
        table.insert(tooltip_parts, lbutton_tooltip)
    end

    if type(_G["other_character_skill_list_frame_open"]) == "function" then
        rbutton_action = "other_character_skill_list_frame_open"
        table.insert(tooltip_parts, "Right-Click: [OCSL] Open")
    end

    ccbtn:SetEventScript(ui.LBUTTONUP, lbutton_action)
    if rbutton_action then
        ccbtn:SetEventScript(ui.RBUTTONUP, rbutton_action)
    end

    if #tooltip_parts > 0 then
        ccbtn:SetTextTooltip("{ol}" .. table.concat(tooltip_parts, "{nl}"))
    else
        ccbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}バラックに戻ります" or "{ol}Return to Barracks")
    end

    function indun_panel_frame_base_position(frame, ctrl, str, num)
        frame:SetPos(665, 30)
        g.settings.x = 665
        g.settings.y = 30
        g.save_settings()
        indun_panel_frame_init()
    end
    frame:ShowWindow(1)

    local configbtn = frame:CreateOrGetControl('button', 'configbtn', 115, 5, 30, 30)
    AUTO_CAST(configbtn)
    configbtn:SetSkinName("None")
    configbtn:SetText("{img config_button_normal 30 30}")
    configbtn:SetEventScript(ui.LBUTTONUP, "indun_panel_config_gb_open")
    configbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}Indun Panel 設定" or "{ol}Indun Panel Config")

    if configbtn:IsVisible() == 1 then
        button:SetEventScript(ui.LBUTTONUP, "indun_panel_frame_init")
    end

    local account_obj = GetMyAccountObj()
    local tooltip_msg = ""
    local coin_count = 0

    if g.get_map_type() == "City" then

        local market = frame:CreateOrGetControl("button", "market", 360, 6, 29, 29);
        AUTO_CAST(market)
        market:SetSkinName("None")
        market:SetText("{img market_shortcut_btn02 29 29}")
        market:SetTextTooltip(g.lang == "Japanese" and "{ol}マーケット" or "{ol}Market")
        market:SetEventScript(ui.LBUTTONUP, "MINIMIZED_MARKET_BUTTON_CLICK")

        local leticia = frame:CreateOrGetControl("button", "leticia", 420, 5, 29, 29);
        AUTO_CAST(leticia)
        leticia:SetSkinName("None")
        leticia:SetText("{img icon_fullscreen_menu_letica 28 28}")
        leticia:SetTextTooltip(g.lang == "Japanese" and "{ol}レティーシャへ移動" or "{ol}Leticia Move")
        leticia:SetEventScript(ui.LBUTTONUP, "indun_panel_FULLSCREEN_NAVIGATION_MENU_DETAIL_MOVE_NPC")
        leticia:SetEventScriptArgNumber(ui.LBUTTONUP, 309)

        local tosshop = frame:CreateOrGetControl("button", "tosshop", 150, 8, 25, 25);
        AUTO_CAST(tosshop)
        tosshop:SetSkinName("None")
        tosshop:SetText("{img icon_item_Tos_Event_Coin 25 25}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "EVENT_TOS_WHOLE_TOTAL_COIN", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}TOSイベントショップ" or "{ol}TOS Event Shop"
        tosshop:SetTextTooltip(tooltip_msg)
        -- INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART
        tosshop:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        tosshop:SetEventScript(ui.LBUTTONUP, "indun_panel_event_tos_whole_shop_open")

        local gabija = frame:CreateOrGetControl("button", "gabija", 180, 7, 29, 29);
        AUTO_CAST(gabija)
        gabija:SetSkinName("None")
        gabija:SetText("{img goddess_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "GabijaCertificate", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}ガビヤショップ{nl}" .. "{#FFFF00}" .. coin_count or
                          "{ol}Gabija Shop{nl}" .. "{#FFFF00}" .. coin_count
        gabija:SetTextTooltip(tooltip_msg)
        gabija:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        gabija:SetEventScript(ui.LBUTTONUP, "REQ_GabijaCertificate_SHOP_OPEN")

        local vakarine = frame:CreateOrGetControl("button", "vakarine", 210, 7, 29, 29);
        AUTO_CAST(vakarine)
        vakarine:SetSkinName("None")
        vakarine:SetText("{img goddess2_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "VakarineCertificate", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}ヴァカリネショップ{nl}" .. "{#FFFF00}" .. coin_count or
                          "{ol}Vakarine Shop{nl}" .. "{#FFFF00}" .. coin_count
        vakarine:SetTextTooltip(tooltip_msg)
        vakarine:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        vakarine:SetEventScript(ui.LBUTTONUP, "REQ_VakarineCertificate_SHOP_OPEN")

        local rada = frame:CreateOrGetControl("button", "rada", 240, 8, 29, 29);
        AUTO_CAST(rada)
        rada:SetSkinName("None")
        rada:SetText("{img goddess3_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "RadaCertificate", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}ラダショップ{nl}" .. "{#FFFF00}" .. coin_count or
                          "{ol}Rada Shop{nl}" .. "{#FFFF00}" .. coin_count
        rada:SetTextTooltip(tooltip_msg)
        rada:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        rada:SetEventScript(ui.LBUTTONUP, "REQ_RadaCertificate_SHOP_OPEN")

        local jurate = frame:CreateOrGetControl("button", "jurate", 270, 7, 29, 29);
        AUTO_CAST(jurate)

        jurate:SetSkinName("None")
        jurate:SetText("{img goddess4_shop_btn 29 29}")
        coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "JurateCertificate", "0"))
        tooltip_msg = g.lang == "Japanese" and "{ol}ユラテショップ{nl}" .. "{#FFFF00}" .. coin_count or
                          "{ol}Jurate Shop{nl}" .. "{#FFFF00}" .. coin_count
        jurate:SetTextTooltip(tooltip_msg)
        jurate:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
        jurate:SetEventScript(ui.LBUTTONUP, "REQ_JurateCertificate_SHOP_OPEN")
    end

    local austeja = frame:CreateOrGetControl("button", "austeja", 300, 7, 29, 29);
    AUTO_CAST(austeja)
    if g.get_map_type() ~= "City" then
        austeja:SetOffset(150, 7)
    end
    austeja:SetSkinName("None")
    austeja:SetText("{img goddess5_shop_btn 29 29}")
    coin_count = GET_COMMAED_STRING(TryGetProp(account_obj, "AustejaCertificate", "0"))
    tooltip_msg = g.lang == "Japanese" and "{ol}アウステアショップ{nl}" .. "{#FFFF00}" .. coin_count or
                      "{ol}Austeja Shop{nl}" .. "{#FFFF00}" .. coin_count
    austeja:SetTextTooltip(tooltip_msg)
    austeja:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
    austeja:SetEventScript(ui.LBUTTONUP, "REQ_AustejaCertificate_SHOP_OPEN")

    local pvp_mine = frame:CreateOrGetControl("button", "pvp_mine", 330, 7, 29, 29);
    AUTO_CAST(pvp_mine)
    if g.get_map_type() ~= "City" then
        pvp_mine:SetOffset(180, 7)
    end
    pvp_mine:SetSkinName("None")
    pvp_mine:SetText("{img pvpmine_shop_btn_total 29 29}")
    pvp_mine:SetTextTooltip(g.lang == "Japanese" and "{ol}傭兵団ショップ" or "{ol}Mercenary Shop")
    pvp_mine:SetEventScript(ui.LBUTTONDOWN, "INDUN_PANEL_EARTHTOWERSHOP_CLOSE_RESTART")
    -- pvp_mine:SetEventScript(ui.LBUTTONUP, "REQ_PVP_MINE_SHOP_OPEN")
    pvp_mine:SetEventScript(ui.LBUTTONUP, "MINIMIZED_PVPMINE_SHOP_BUTTON_CLICK")
    if g.get_map_type() == "City" then
        local craft = frame:CreateOrGetControl("button", "craft", 390, 5, 29, 29);
        AUTO_CAST(craft)
        craft:SetSkinName("None")
        craft:SetText("{img icon_fullscreen_menu_equipment_processing 28 28}")
        craft:SetTextTooltip(g.lang == "Japanese" and "{ol}装備加工" or "{ol}Equipment Processing")
        craft:SetEventScript(ui.LBUTTONUP, "FULLSCREEN_NAVIGATION_MENU_DEATIL_EQUIPMENT_PROCESSING_NPC")
    end

    local checkbox = frame:CreateOrGetControl('checkbox', 'checkbox', 715, 5, 30, 30)
    AUTO_CAST(checkbox)
    checkbox:SetCheck(g.settings.checkbox)
    checkbox:SetEventScript(ui.LBUTTONUP, "indun_panel_ischecked")
    checkbox:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックすると常時展開" or "{ol}IsCheck AlwaysOpen")

    if g.settings.season_checkbox == nil then
        g.settings.season_checkbox = 1
        g.save_settings()
    end

    function indun_panel_FIELD_BOSS_TIME_TAB_SETTING()
        local frame = ui.GetFrame("induninfo")
        if not frame then
            return
        end

        local field_boss_ranking_control = GET_CHILD_RECURSIVELY(frame, "field_boss_ranking_control")
        if not field_boss_ranking_control then
            return
        end

        local sub_tab = GET_CHILD_RECURSIVELY(field_boss_ranking_control, "sub_tab")
        if not sub_tab then
            return
        end

        local server_time_str = date_time.get_lua_now_datetime_str()
        if not server_time_str then
            return
        end

        local _, _, _, hour_str, min_str, _ = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
        if not hour_str then
            return
        end

        local server_hour = tonumber(hour_str)
        local server_min = tonumber(min_str)

        if (server_hour < 12) or (server_hour == 12 and server_min < 5) then

            sub_tab:SelectTab(0)
        else

            sub_tab:SelectTab(1)
        end

    end

    if g.settings.jsr_checkbox == 1 then
        indun_panel_FIELD_BOSS_TIME_TAB_SETTING()
    end

    local set_a = frame:CreateOrGetControl("button", "set_a", 460, 5, 80, 30)
    AUTO_CAST(set_a)

    if not g.settings.set_names then
        g.settings.set_names = {}
        g.save_settings()
    end

    local text = g.settings.set_names["set_a"] or "SET A"
    set_a:SetText("{ol}" .. text)
    set_a:Resize(80, 30)
    set_a:AdjustFontSizeByWidth(80)
    set_a:Resize(80, 30)
    set_a:SetEventScript(ui.LBUTTONUP, "indun_panel_set_toggle")
    set_a:SetEventScriptArgString(ui.LBUTTONUP, set_a:GetName())
    if g.settings.use_set == "set_a" then

        set_a:SetSkinName("test_red_button")
    end

    local set_b = frame:CreateOrGetControl("button", "set_b", 545, 5, 80, 30)
    AUTO_CAST(set_b)

    local text = g.settings.set_names["set_b"] or "SET B"
    set_b:SetText("{ol}" .. text)
    set_b:Resize(80, 30)
    set_b:AdjustFontSizeByWidth(80)
    set_b:Resize(80, 30)
    set_b:SetEventScript(ui.LBUTTONUP, "indun_panel_set_toggle")
    set_b:SetEventScriptArgString(ui.LBUTTONUP, set_b:GetName())
    if g.settings.use_set == "set_b" then
        set_b:SetSkinName("test_red_button")
    end

    local set_c = frame:CreateOrGetControl("button", "set_c", 630, 5, 80, 30)
    AUTO_CAST(set_c)
    local text = g.settings.set_names["set_c"] or "SET C"
    set_c:SetText("{ol}" .. text)
    set_c:Resize(80, 30)
    set_c:AdjustFontSizeByWidth(80)
    set_c:Resize(80, 30)
    set_c:SetEventScript(ui.LBUTTONUP, "indun_panel_set_toggle")
    set_c:SetEventScriptArgString(ui.LBUTTONUP, set_c:GetName())
    if g.settings.use_set == "set_c" then
        set_c:SetSkinName("test_red_button")
    end

    g.update_try = 0

    g.housing_call_time = nil
    indun_panel_frame_contents(frame)
    configbtn:RunUpdateScript("indun_panel_frame_contents", 1.0)

end]] --[[local convert_tbl = {
    ["veliora"] = "belliora",
    ["limara"] = "laimara",
    ["redania"] = "ledania",
    ["spreader"] = "reservoir",
    ["velnice"] = "bernice",
    ["earring"] = "memory",
    ["cemetery"] = "wailing",
    ["demonlair"] = "ashaq"
}]] --[[function indun_list_viewer_load_settings()

    indun_list_viewer_old_memo()
    local settings = g.load_json(g.settings_path) or {}
    local changed = false

    if indun_list_viewer_ensure_defaults(settings, DEFAULT_SETTINGS) then
        changed = true
    end

    local memos_changed = false

    local acc_info = session.barrack.GetMyAccount()
    if g.load == true then
        local barrack_cnt = acc_info:GetBarrackPCCount()
        local barrack_names = {}

        for i = 0, barrack_cnt - 1 do
            local pc_info = acc_info:GetBarrackPCByIndex(i)
            local pc_name = pc_info:GetName()
            barrack_names[pc_name] = true
            if not settings[pc_name] then
                settings[pc_name] = {
                    pc_name = pc_name
                }
                indun_list_viewer_ensure_defaults(settings[pc_name], DEFAULT_CHAR_DATA)
                changed = true
            end
            if g.memos and g.memos[pc_name] then
                settings[pc_name].memo = g.memos[pc_name]
                g.memos[pc_name] = nil
                memos_changed = true
                changed = true
            end
        end
        local keys_to_delete = {}
        for key, data in pairs(settings) do
            if type(data) == "table" and data.pc_name and not barrack_names[key] then
                table.insert(keys_to_delete, key)
            end
        end
        if #keys_to_delete > 0 then
            for _, key in ipairs(keys_to_delete) do
                settings[key] = nil
            end
            changed = true
        end
        indun_list_viewer_sort_characters(acc_info, settings)

        local server_time_str = date_time.get_lua_now_datetime_str()
        if server_time_str then
            local y, m, d, H, M, S = server_time_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
            if y then
                local server_now_timestamp = os.time({
                    year = tonumber(y),
                    month = tonumber(m),
                    day = tonumber(d),
                    hour = tonumber(H),
                    min = tonumber(M),
                    sec = tonumber(S)
                })
                if server_now_timestamp > settings.default_options.reset_time then
                    indun_list_viewer_raid_reset(settings)
                    changed = true
                end
            end
        end
    else
        if not settings[g.login_name] then
            settings[g.login_name] = {
                pc_name = g.login_name
            }
            indun_list_viewer_ensure_defaults(settings[g.login_name], DEFAULT_CHAR_DATA)
            changed = true
        end
        if g.memos and g.memos[g.login_name] then
            settings[g.login_name].memo = g.memos[g.login_name]
            g.memos[g.login_name] = nil
            memos_changed = true
            changed = true
        end
        indun_list_viewer_sort_characters(nil, settings)
    end

    g.settings = settings
    if changed then
        g.settings_changed = changed
    end

    if memos_changed then
        local new_memo_path = string.format("../addons/%s/%s/memos.json", addon_name_lower, g.active_id)
        g.save_json(new_memo_path, g.memos)
    end
end]] --[[function other_character_skill_list_BARRACK_TO_GAME(...)

    local bc_frame = ui.GetFrame("barrack_charlist")
    if bc_frame then
        g.layer = tonumber(bc_frame:GetUserValue("SelectBarrackLayer"))
        _G["norisan"] = _G["norisan"] or {}
        _G["norisan"]["LAST_LAYER"] = tonumber(bc_frame:GetUserValue("SelectBarrackLayer"))
    end

    local original_func = g.FUNCS["BARRACK_TO_GAME"]
    local result

    if original_func then
        original_func(...)
    end

    return result
end

function other_character_skill_list_BARRACK_TO_GAME_hook()
    g.FUNCS = g.FUNCS or {}
    local origin_func_name = "BARRACK_TO_GAME"
    if _G[origin_func_name] then
        if not g.FUNCS[origin_func_name] then
            g.FUNCS[origin_func_name] = _G[origin_func_name]
        end
        _G[origin_func_name] = other_character_skill_list_BARRACK_TO_GAME
    end
end
 local jatbl = {
    ["Common_Peltasta_HardShield"] = "ハードシールド",
    ["Common_Swordman_PainBarrier"] = "ペインバリア",
    ["Common_Peltasta_Guardian"] = "ガーディアン",
    ["Common_Cataphract_Trot"] = "トロット",
    ["Common_Murmillo_Sprint"] = "スプリント",
    ["Common_BlossomBlader_StartUp"] = "起手式",
    ["Common_Rancer_Commence"] = "コメンス",
    ["Common_Rancer_Prevent"] = "プリベント",
    ["Common_Highlander_Defiance"] = "ディファイアンス",
    ["Common_Barbarian_Frenzy"] = "フレンジー",
    ["Common_Retiarii_DaggerGuard"] = "ダガーガード",
    ["Common_Archer_Jump"] = "後方跳躍",
    ["Common_PiedPiper_Marschierendeslied"] = "マシュレデスリート",
    ["Common_PiedPiper_LiedDerWeltbaum"] = "リートデスベルトバウム",
    ["Common_Arquebusier_DesperateDefense"] = "デスパレートデフェンス",
    ["Common_Appraiser_HighMagnifyingGlass"] = "高倍率拡大鏡",
    ["Common_QuarrelShooter_DeployPavise"] = "デプロイパヴィス",
    ["Common_Wizard_Teleportation"] = "テレポーテーション",
    ["Common_Cryomancer_SubzeroShield"] = "ザブゼロシールド",
    ["Common_Chronomancer_Pass"] = "パス",
    ["Common_Chronomancer_QuickCast"] = "クイックキャスト",
    ["Common_Shadowmancer_ShadowPool"] = "シャドウプール",
    ["Common_Sage_MissileHole"] = "ミサイルホール",
    ["Common_Oracle_Foretell"] = "フォアテル",
    ["Common_PlagueDoctor_Modafinil"] = "モダフィニル",
    ["Common_Appraiser_Devaluation"] = "デバリュエーション",
    ["Common_RuneCaster_Algiz"] = "保護のルーン",
    ["Common_Priest_Aspersion"] = "アスパーション",
    ["Common_Druid_Lycanthropy"] = "ライカンスロピー",
    ["Common_Pardoner_IncreaseMagicDEF"] = "インクリースMDEF",
    ["Common_Paladin_StoneSkin"] = "ストーンスキン",
    ["Common_Inquisitor_Judgment"] = "ジャッジメント",
    ["Common_Kabbalist_Ayin_sof"] = "アインソフ",
    ["Common_Zealot_Invulnerable"] = "インバナーブル",
    ["Common_Zealot_BeadyEyed"] = "ビーディアイズ",
    ["Common_Assassin_Hasisas"] = "ハシサス",
    ["Common_OutLaw_Bully"] = "ブリー",
    ["Common_Thaumaturge_SwellBody"] = "スウェルボディ",
    ["Common_Thaumaturge_SwellHands"] = "スウェルハンズ",
    ["Common_Enchanter_EnchantGlove"] = "エンチャントグローブ",
    ["Common_Enchanter_EnchantEarth"] = "エンチャントアース",
    ["Common_Enchanter_EnchantLightning"] = "エンチャントウェポン",
    ["Common_Linker_Physicallink"] = "フィジカルリンク",
    ["Common_Linker_UmbilicalCord"] = "アンビリカルコード",
    ["Common_Rogue_Evasion"] = "イヴェイジョン",
    ["Common_Schwarzereiter_EvasiveAction"] = "エヴァシブアクション",
    ["Common_Sheriff_Redemption"] = "リデンプション",
    ["Common_Recovery"] = "リカバリー"

}
local entbl = {
    ["Common_Peltasta_HardShield"] = "HardShield",
    ["Common_Swordman_PainBarrier"] = "PainBarrier",
    ["Common_Peltasta_Guardian"] = "Guardian",
    ["Common_Cataphract_Trot"] = "Trot",
    ["Common_Murmillo_Sprint"] = "Sprint",
    ["Common_BlossomBlader_StartUp"] = "StartUp",
    ["Common_Rancer_Commence"] = "Commence",
    ["Common_Rancer_Prevent"] = "Prevent",
    ["Common_Highlander_Defiance"] = "Defiance",
    ["Common_Barbarian_Frenzy"] = "Frenzy",
    ["Common_Retiarii_DaggerGuard"] = "DaggerGuard",
    ["Common_Archer_Jump"] = "Jump",
    ["Common_PiedPiper_Marschierendeslied"] = "Marschierendeslied",
    ["Common_PiedPiper_LiedDerWeltbaum"] = "LiedDerWeltbaum",
    ["Common_Arquebusier_DesperateDefense"] = "DesperateDefense",
    ["Common_Appraiser_HighMagnifyingGlass"] = "HighMagnifyingGlass",
    ["Common_QuarrelShooter_DeployPavise"] = "DeployPavise",
    ["Common_Wizard_Teleportation"] = "Teleportation",
    ["Common_Cryomancer_SubzeroShield"] = "SubzeroShield",
    ["Common_Chronomancer_Pass"] = "Pass",
    ["Common_Chronomancer_QuickCast"] = "QuickCast",
    ["Common_Shadowmancer_ShadowPool"] = "ShadowPool",
    ["Common_Sage_MissileHole"] = "MissileHole",
    ["Common_Oracle_Foretell"] = "Foretell",
    ["Common_PlagueDoctor_Modafinil"] = "Modafinil",
    ["Common_Appraiser_Devaluation"] = "Devaluation",
    ["Common_RuneCaster_Algiz"] = "Algiz",
    ["Common_Priest_Aspersion"] = "Aspersion",
    ["Common_Druid_Lycanthropy"] = "Lycanthropy",
    ["Common_Pardoner_IncreaseMagicDEF"] = "IncreaseMagicDEF",
    ["Common_Paladin_StoneSkin"] = "StoneSkin",
    ["Common_Inquisitor_Judgment"] = "Judgment",
    ["Common_Kabbalist_Ayin_sof"] = "Ayin_sof",
    ["Common_Zealot_Invulnerable"] = "Invulnerable",
    ["Common_Zealot_BeadyEyed"] = "BeadyEyed",
    ["Common_Assassin_Hasisas"] = "Hasisas",
    ["Common_OutLaw_Bully"] = "Bully",
    ["Common_Thaumaturge_SwellBody"] = "SwellBody",
    ["Common_Thaumaturge_SwellHands"] = "SwellHands",
    ["Common_Enchanter_EnchantGlove"] = "EnchantGlove",
    ["Common_Enchanter_EnchantEarth"] = "EnchantEarth",
    ["Common_Enchanter_EnchantLightning"] = "EnchantLightning",
    ["Common_Linker_Physicallink"] = "Physicallink",
    ["Common_Linker_UmbilicalCord"] = "UmbilicalCord",
    ["Common_Rogue_Evasion"] = "Evasion",
    ["Common_Schwarzereiter_EvasiveAction"] = "EvasiveAction",
    ["Common_Sheriff_Redemption"] = "Redemption",
    ["Common_Recovery"] = "Recovery"
}]] --[[function other_character_skill_list_frame_open(frame, ctrl, str, num)
    other_character_skill_list_save_enchant()
    local main_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "new_frame", 0, 0, 70, 30)
    AUTO_CAST(main_frame)
    main_frame:SetSkinName("test_frame_midle_light")
    main_frame:SetLayerLevel(103)
    local title_box = main_frame:CreateOrGetControl("groupbox", "title", 0, 0, 1070, 40)
    AUTO_CAST(title_box)
    title_box:SetSkinName("None")
    local close_btn = title_box:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close_btn)
    close_btn:SetImage("testclose_button")
    close_btn:SetGravity(ui.LEFT, ui.TOP)
    close_btn:SetEventScript(ui.LBUTTONUP, "other_character_skill_list_frame_close")
    local help_btn = title_box:CreateOrGetControl('button', "help", 40, 0, 35, 35)
    AUTO_CAST(help_btn)
    help_btn:SetText("{ol}{img question_mark 20 20}")
    help_btn:SetSkinName("test_pvp_btn")
    local ccbtn = title_box:CreateOrGetControl('button', 'ccbtn', 75, 0, 35, 35)
    AUTO_CAST(ccbtn)
    ccbtn:SetSkinName("None")
    ccbtn:SetText("{ol}{img barrack_button_normal 35 35}")
    ccbtn:SetEventScript(ui.LBUTTONUP, "APPS_TRY_MOVE_BARRACK")
    ccbtn:SetTextTooltip(g.lang == "Japanese" and "{ol}バラックに戻ります" or "{ol}Return to Barracks")
    local hide_check = title_box:CreateOrGetControl('checkbox', 'hide_check', 120, 0, 35, 35)
    AUTO_CAST(hide_check)
    hide_check:SetEventScript(ui.LBUTTONUP, 'other_character_skill_list_display_check')
    hide_check:SetTextTooltip(g.lang == "Japanese" and "{ol}チェックしたキャラを非表示" or
                                  "{ol}Hide Checked Characters")
    hide_check:SetCheck(g.settings.hide or 0)
    local current_lang = option.GetCurrentCountry()
    help_btn:SetTextTooltip(current_lang == "Japanese" and
                                "{ol}順番に並ばない場合は一度バラックに戻ってバラック1､2､3毎にログインしてください。{nl}" ..
                                "InstantCCアドオンを使用している場合は「Return To Barrack」で戻ってください。{nl} {nl}" ..
                                "{ol}名前部分を押すと、ログインキャラと同一バラックの各キャラの装備詳細が見れます。" or
                                "{ol}If you do not line up in order,{nl}" ..
                                "please return to the barracks once and log in for each barracks 1,2,3.{nl}" ..
                                "If you are using the InstantCC add-on, please return with [Return To Barrack].{nl} {nl}" ..
                                "{ol}Press the name section to see the equipment details of each character{nl}in the same barrack as the login character.")
    local weapon_lbl = title_box:CreateOrGetControl("richtext", "weapon", 160, 10, 100, 20)
    weapon_lbl:SetText(current_lang == "Japanese" and "{ol}" .. "武器" or "{ol}" .. "weapons")
    weapon_lbl:AdjustFontSizeByWidth(100)
    local acc_lbl = title_box:CreateOrGetControl("richtext", "Accessory", 290, 10, 100, 20)
    acc_lbl:SetText(current_lang == "Japanese" and "{ol}" .. "アクセ" or "{ol}" .. "Accessory")
    local equip_x = 390
    for i = 0, 4 do
        local equip_lbl = title_box:CreateOrGetControl("richtext", "equip_text" .. i, equip_x, 10, 100, 20) -- equip_text を eq_text_lbl に
        if i == 0 then
            equip_lbl:SetText("{ol}" .. ClMsg("Shirt"))
        elseif i == 1 then
            equip_lbl:SetText("{ol}" .. ClMsg("Pants"))
        elseif i == 2 then
            equip_lbl:SetText("{ol}" .. ClMsg("GLOVES"))
        elseif i == 3 then
            equip_lbl:SetText("{ol}" .. ClMsg("BOOTS"))
        elseif i == 4 then
            equip_lbl:SetText(current_lang == "Japanese" and "{ol}その他" or "{ol}etc.")
        end
        equip_lbl:AdjustFontSizeByWidth(100)
        equip_x = equip_x + 225
    end
    local main_gbox = main_frame:CreateOrGetControl("groupbox", "gbox", 5, 35, 1070, 280)
    AUTO_CAST(main_gbox)
    main_gbox:RemoveAllChild()
    main_gbox:SetSkinName("bg2")
    -- local trans_tbl = current_lang == "Japanese" and jatbl or entbl
    local all_skills = GetClassList("Skill")
    local y_pos = 10
    local equip_grp_x = 385
    local etc_x_offset = 0
    local char_count = 0
    for i, char_info in ipairs(g.characters) do
        local char_settings = g.settings.characters[char_info.name]
        if g.settings.characters[char_info.name].hide ~= 1 or g.settings.hide == 0 then
            local char_equips = char_settings.equips
            local gear_score = char_settings.gear_score
            local job_list, level, last_job_id = GetJobListFromAdventureBookCharData(char_info.name)
            local last_job_class = GetClassByType("Job", last_job_id)
            local last_job_icon = TryGetProp(last_job_class, "Icon")
            local job_slot = main_gbox:CreateOrGetControl("slot", "jobslot" .. i, 0, y_pos - 3, 25, 25)
            AUTO_CAST(job_slot)
            job_slot:SetSkinName("None")
            job_slot:EnableHitTest(1)
            job_slot:EnablePop(0)
            local job_icon = CreateIcon(job_slot)
            job_icon:SetImage(last_job_icon)
            local name_lbl = main_gbox:CreateOrGetControl("richtext", "name_text" .. i, 25, y_pos, 195, 20)
            AUTO_CAST(name_lbl)
            name_lbl:SetText("{ol}" .. char_info.name)
            name_lbl:AdjustFontSizeByWidth(195)
            name_lbl:SetEventScript(ui.RBUTTONUP, "other_character_skill_list_char_report")
            name_lbl:SetEventScriptArgString(ui.RBUTTONUP, char_info.name)
            local gs_str = gear_score ~= 0 and tostring(gear_score) or "NoData" -- tostring 追加
            local functionName = "INSTANTCC_ON_INIT"
            if type(_G[functionName]) == "function" then
                function other_character_skill_list_INSTANTCC_DO_CC(frame, ctrl, cid, layer)
                    INSTANTCC_DO_CC(cid, layer)
                end
                local cid = char_info.cid
                local layer = char_info.layer
                name_lbl:SetEventScript(ui.LBUTTONDOWN, "other_character_skill_list_INSTANTCC_DO_CC")
                name_lbl:SetEventScriptArgString(ui.LBUTTONDOWN, cid)
                name_lbl:SetEventScriptArgNumber(ui.LBUTTONDOWN, layer)
                name_lbl:SetTextTooltip(current_lang == "Japanese" and "{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                            "右クリック: 各キャラ装備詳細{nl}左クリック：キャラクターチェンジ" or
                                            "{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                            "Right click: Details of each character's equipment{nl}Left click: Character change")
            else
                name_lbl:SetTextTooltip(current_lang == "Japanese" and "{ol}GearScore: " .. gs_str .. "{nl} {nl}" ..
                                            "右クリック: 各キャラ装備詳細" or "{ol}GearScore: " .. gs_str ..
                                            "{nl} {nl}" .. "Right-click: Details of each character's equipment")
            end
            for j, equip_type in ipairs(equips) do
                local equip_data_entry = char_equips[equip_type]
                if j <= 4 then
                    local skill_slot = main_gbox:CreateOrGetControl("slot", "slot" .. equip_type .. i,
                        equip_grp_x + (225 * (j - 1)) + 30, y_pos, 25, 24)
                    AUTO_CAST(skill_slot)
                    skill_slot:EnablePop(0);
                    skill_slot:EnableDrop(0);
                    skill_slot:EnableDrag(0);
                    skill_slot:SetSkinName('invenslot2')
                    local item_slot = main_gbox:CreateOrGetControl("slot", "equip" .. equip_type .. i,
                        equip_grp_x + (225 * (j - 1)), y_pos, 25, 24)
                    AUTO_CAST(item_slot)
                    item_slot:EnablePop(0);
                    item_slot:EnableDrop(0);
                    item_slot:EnableDrag(0);
                    item_slot:SetSkinName('invenslot2')
                    local clsid = equip_data_entry.clsid
                    local item_cls = GetClassByType("Item", clsid)
                    if item_cls then
                        local lv = equip_data_entry.lv
                        local image_name = item_cls.Icon
                        SET_SLOT_ICON(item_slot, image_name)
                        SET_SLOT_BG_BY_ITEMGRADE(item_slot, item_cls)
                        item_slot:SetText('{s12}{ol}{#FFFF00}+' .. lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                        local icon = item_slot:GetIcon()
                        if icon then
                            icon:SetTextTooltip("{ol}" .. item_cls.Name)
                        end
                    end
                    local skill = GetClassByNameFromList(all_skills, equip_data_entry.skill_name)
                    if skill then
                        local skill_icon_name = 'icon_' .. skill.Icon
                        SET_SLOT_ICON(skill_slot, skill_icon_name)
                        local skill_name_lbl = main_gbox:CreateOrGetControl("richtext", "skill_name" .. equip_type .. i,
                            equip_grp_x + 60 + (225 * (j - 1)), y_pos, 140, 20) -- skill_name を skill_name_lbl に
                        skill_slot:SetText('{s14}{ol}{#FFFF00}' .. equip_data_entry.skill_lv, 'count', ui.RIGHT,
                            ui.BOTTOM, -2, -2)
                        local icon = skill_slot:GetIcon()
                        if icon then
                            icon:SetTooltipType('skill')
                            icon:SetTooltipArg("Level", skill.ClassID, equip_data_entry.skill_lv)
                        end
                        skill_name_lbl:SetText("{ol}{s16}" .. skill.Name) -- skill.Name
                        skill_name_lbl:AdjustFontSizeByWidth(160)
                    end
                elseif j >= 5 and j <= 11 then

                    local etc_slot = main_gbox:CreateOrGetControl("slot", "etc_slot" .. equip_type .. i,
                        equip_grp_x + 225 * 4 + etc_x_offset, y_pos, 25, 24)
                    AUTO_CAST(etc_slot)
                    etc_slot:EnablePop(0);
                    etc_slot:EnableDrop(0);
                    etc_slot:EnableDrag(0);
                    etc_slot:SetSkinName('invenslot2')
                    local text_prefix = (j >= 5 and j <= 6) and "{s12}{ol}{#FFFF00}{img mon_legendstar 10 10}{nl}" or
                                            "{s12}{ol}{#FFFF00}+"
                    local item_cls = GetClassByType("Item", equip_data_entry.clsid)
                    if item_cls then
                        local image_name = item_cls.Icon
                        SET_SLOT_ICON(etc_slot, image_name)
                        local icon = etc_slot:GetIcon()
                        if icon then
                            if j ~= 11 then
                                if j ~= 10 then
                                    icon:SetTextTooltip("{ol}" .. item_cls.Name)
                                    etc_slot:SetText(text_prefix .. equip_data_entry.lv, 'count', ui.RIGHT, ui.BOTTOM,
                                        0, 0)
                                else
                                    local tooltip = item_cls.Name
                                    local earring_str = other_character_skill_list_split_earring_options(
                                        equip_data_entry.lv)
                                    for i, option_str in ipairs(earring_str) do
                                        tooltip = "{ol}" .. tooltip .. "{nl}" .. option_str
                                    end
                                    icon:SetTextTooltip(tooltip)
                                end
                            else
                                local tooltip = item_cls.Name
                                icon:SetTextTooltip(tooltip)
                            end
                        end
                    end
                    etc_x_offset = etc_x_offset + 30
                elseif j >= 12 then
                    local weapon_slot_x = 155 + 30 * (j - 12)
                    if j >= 16 then
                        weapon_slot_x = 155 + 30 * (j - 12) + 10
                    end
                    local weapon_slot = main_gbox:CreateOrGetControl("slot", "slot" .. equip_type .. i, weapon_slot_x,
                        y_pos, 25, 24)
                    AUTO_CAST(weapon_slot)
                    weapon_slot:EnablePop(0);
                    weapon_slot:EnableDrop(0);
                    weapon_slot:EnableDrag(0);
                    weapon_slot:SetSkinName('invenslot2')
                    local clsid = equip_data_entry.clsid
                    if clsid and clsid ~= 0 then
                        local lv = equip_data_entry.lv
                        local item_cls = GetClassByType("Item", clsid)
                        local image_name = item_cls.Icon
                        SET_SLOT_ICON(weapon_slot, image_name)
                        SET_SLOT_BG_BY_ITEMGRADE(weapon_slot, item_cls)
                        weapon_slot:SetText('{s12}{ol}{#FFFF00}+' .. lv, 'count', ui.RIGHT, ui.BOTTOM, 0, 0)
                        local icon = weapon_slot:GetIcon()
                        if icon then
                            icon:SetTextTooltip("{ol}" .. item_cls.Name)
                        end
                    end
                end
            end
            local hide_check = main_gbox:CreateOrGetControl('checkbox', "hide_check" .. i, 1500, y_pos, 25, 25)
            AUTO_CAST(hide_check)
            hide_check:SetCheck(0)
            hide_check:SetEventScript(ui.LBUTTONDOWN, 'other_character_skill_list_display_check')
            hide_check:SetEventScriptArgString(ui.LBUTTONDOWN, char_info.name)
            local notice = current_lang == "Japanese" and "{ol}チェックすると非表示" or "{ol}Check to hide"
            hide_check:SetTextTooltip(notice)
            hide_check:SetCheck(g.settings.characters[char_info.name].hide or 0)
            etc_x_offset = 0
            y_pos = y_pos + 25
            char_count = char_count + 1
        end
    end
    local frame_height = char_count * 25
    main_frame:Resize(1540, frame_height + 60)
    title_box:Resize(1530, 40)
    main_gbox:Resize(1530, frame_height + 20)
    local current_frame_w = main_frame:GetWidth()
    local map_frame = ui.GetFrame("map")
    local map_width = map_frame:GetWidth()
    main_frame:SetPos((map_width - current_frame_w) / 2, 0)
    main_frame:ShowWindow(1)
end]] 
[=[
function debuff_notice_frame_init(buff_id, handle, buff_index, image_name)
    local targetbuff = ui.GetFrame("targetbuff")
    local debuff_notice = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "debuff_notice" .. handle, 0, 0, 0, 0)
    debuff_notice:SetSkinName("None")
    debuff_notice:SetTitleBarSkin("None")
    debuff_notice:Resize(400, 50)
    debuff_notice:SetPos(targetbuff:GetX() + 100, targetbuff:GetY() + targetbuff:GetHeight() + 50)
    local debuff_slotset = GET_CHILD(debuff_notice, "debuff_slotset")
    if not debuff_slotset then
        debuff_slotset = debuff_notice:CreateOrGetControl("slotset", "debuff_slotset", 0, 0, 415, 50)
        AUTO_CAST(debuff_slotset)
        debuff_slotset:SetColRow(8, 1)
        debuff_slotset:SetSlotSize(50, 50)
        debuff_slotset:SetSpc(0, 0)
        debuff_slotset:EnablePop(0)
        debuff_slotset:EnableDrag(0)
        debuff_slotset:EnableDrop(0)
        debuff_slotset:CreateSlots()
    else
        AUTO_CAST(debuff_slotset)
    end
    debuff_notice:ShowWindow(1)
    debuff_notice:StopUpdateScript("debuff_notice_frame_resize")
    debuff_notice:RunUpdateScript("debuff_notice_frame_resize", 0.1)
end

function debuff_notice_frame_resize(debuff_notice)
    local debuff_slotset = GET_CHILD(debuff_notice, "debuff_slotset")
    AUTO_CAST(debuff_slotset)
    local slot_count = debuff_slotset:GetSlotCount()
    for i = 1, slot_count do
        local slot = GET_CHILD(debuff_slotset, "slot" .. i)
        AUTO_CAST(slot)
        for handle, buffs in pairs(g.debuff_notice.slot_table) do
            for buff_id, buff_data in pairs(buffs) do
                local buff_index = buff_data.buff_index
                local image_name = buff_data.image_name
                local buff = info.GetBuff(handle, buff_id, buff_index)
                if buff then
                    local icon = slot:GetIcon()
                    if not icon then
                        icon = CreateIcon(slot)
                        AUTO_CAST(icon)
                    end
                    icon:Set(image_name, 'BUFF', buff_id, 0)
                    icon:SetTooltipType('buff');
                    icon:SetTooltipArg(handle, buff_id, buff_index)
                    local time_text = slot:CreateOrGetControl('richtext', "time_text", 10, 35, 20, 20);
                    AUTO_CAST(time_text)
                    if buff.time <= 0 then
                        time_text:SetText("")
                    end
                    local count_text = slot:CreateOrGetControl('richtext', "count_text", 5, 0, 40, 35);
                    AUTO_CAST(count_text)
                    if buff.over <= 0 then
                        count_text:SetText("")
                    end
                    break
                end
            end
            break
        end
    end
    return 1
end

function debuff_notice_TARGETBUFF_ON_MSG(frame, msg, arg_str, buff_id)
    ts(3, frame, msg, arg_str, buff_id)
    local debuff_notice = ui.GetFrame(addon_name_lower .. "debuff_notice")
    local handle = session.GetTargetHandle()
    local buff_cls = GetClassByType('Buff', buff_id)
    if not buff_cls then
        return
    end
    if buff_cls and buff_cls.Group1 ~= "Debuff" then
        return
    end
    if buff_cls.ShowIcon == "FALSE" then
        return
    end
    local image_name = GET_BUFF_ICON_NAME(buff_cls)
    if image_name == "icon_None" then
        return
    end
    local buff_index = tonumber(arg_str)
    local buff = info.GetBuff(handle, buff_id, buff_index)
    if not buff then
        buff = info.GetBuff(handle, buff_id)
    end
    local my_handle = session.GetMyHandle()
    if buff then
        local caster_handle = buff:GetHandle()
        if caster_handle ~= my_handle then
            return
        end
    end
    local actor = world.GetActor(handle)
    local mon_cls = GetClassByType("Monster", actor:GetType())
    if TryGetProp(mon_cls, "MonRank", "None") ~= "Boss" and not g.debuff_notice.highlander then
        return
    else
        if not g.debuff_notice.slot_table[handle] then
            g.debuff_notice.slot_table[handle] = {}
        end
    end
    local handle = session.GetTargetHandle();
    local buffIndex = tonumber(argStr)
    if msg == "TARGET_BUFF_ADD" then
        -- if TARGETDEBUFF_SELFAPPLIED_CHECK(handle, argNum, buffIndex) == true then return; end
        if TARGETBUFF_DEBUFF_LIMIT(frame, handle, argNum) == false then
            COMMON_BUFF_MSG(frame, "ADD", argNum, handle, t_buff_ui, argStr);
        end
    elseif msg == "TARGET_BUFF_REMOVE" then
        -- if TARGETDEBUFF_SELFAPPLIED_CHECK(handle, argNum, buffIndex) == true then return; end
        COMMON_BUFF_MSG(frame, "REMOVE", argNum, handle, t_buff_ui, argStr);
    elseif msg == "TARGET_BUFF_UPDATE" then
        -- if TARGETDEBUFF_SELFAPPLIED_CHECK(handle, argNum, buffIndex) == true then return; end
        COMMON_BUFF_MSG(frame, "UPDATE", argNum, handle, t_buff_ui, argStr);
    elseif msg == "TARGET_SET" then
        if s_lsgmsg == msg and s_lasthandle == handle then
            return;
        end
        s_lsgmsg = msg;
        s_lasthandle = handle;
        COMMON_BUFF_MSG(frame, "CLEAR", argNum, handle, t_buff_ui);
        local isLimitDebuff = tonumber(frame:GetUserValue("IS_LIMIT_DEBUFF"));
        if isLimitDebuff == 1 then
            ui.TargetDebuffMinimizeAddonMsg(frame:GetName(), "SET", handle);
        else
            COMMON_BUFF_MSG(frame, "SET", argNum, handle, t_buff_ui);
        end
        TARGETBUFF_VISIBLE(frame, 1);
    elseif msg == "TARGET_CLEAR" then
        if s_lsgmsg == msg then
            return;
        end
        s_lsgmsg = msg;
        COMMON_BUFF_MSG(frame, "CLEAR", argNum, handle, t_buff_ui);
        TARGETBUFF_VISIBLE(frame, 0);
    end
end

--[[function debuff_notice_COMMON_BUFF_MSG(my_frame, my_msg)
    local frame, msg, buffType, handle, buff_ui, buffIndex = g.get_event_args(my_msg)
    local debuff_notice = ui.GetFrame(addon_name_lower .. "debuff_notice")
    if msg == "SET" or msg == 'ADD' or msg == "UPDATE" then
        local buffCount = info.GetBuffCount(handle)
        for i = 0, buffCount - 1 do
            local buff = info.GetBuffIndexed(handle, i)
            if buff then
                -- ts(1, msg, buffIndex, buff.index)
                -- ts(2, msg, buffType, buff.buffID)
                -- debuff_notice_TARGETBUFF_ON_MSG(debuff_notice, "ADD", buff.index, buff.buffID)
            end
        end
        -- elseif msg == 'REMOVE' or msg == "CLEAR" then
        -- debuff_notice_TARGETBUFF_ON_MSG(debuff_notice, "REMOVE", buffIndex, buffType)
    end
end]]

function debuff_notice_common_buff_msg(debuff_notice, msg, buff_id, handle, buff_index)
    local debuff_notice = ui.GetFrame(addon_name_lower .. "debuff_notice")
    if not g.debuff_notice.slot_table[handle] then
        g.debuff_notice.slot_table[handle] = {}
    end
    if "None" == buff_index or not buff_index then
        buff_index = 0
    end
    buff_index = tonumber(buff_index)
    if msg == 'ADD' or msg == "UPDATE" then
        g.debuff_notice.slot_table[handle][buff_id] = buff_index
    elseif msg == 'REMOVE' then
        g.debuff_notice.slot_table[handle][buff_id] = nil
    end
    debuff_notice_frame_redraw(debuff_notice, handle)
end

--[[function debuff_notice_frame_redraw(debuff_notice, handle)
    local debuff_slotset = debuff_notice:GetChild("debuff_slotset")
    if not debuff_slotset then
        return
    end
    AUTO_CAST(debuff_slotset)
    local buffs_to_display = {}
    if handle and g.debuff_notice.slot_table and g.debuff_notice.slot_table[handle] then
        for buff_id, buff_index in pairs(g.debuff_notice.slot_table[handle]) do
            table.insert(buffs_to_display, {
                buff_id = buff_id,
                buff_index = buff_index
            })
        end
    end

    if #buffs_to_display == 0 then
        debuff_notice:Resize(0, 50)
    else
        -- 変更: UIのリサイズは表示するバフの数に基づいて行う
        debuff_notice:Resize(#buffs_to_display * 50, 50)
    end

    local slot_count = debuff_slotset:GetSlotCount()
    for i = 1, slot_count do
        local slot = GET_CHILD(debuff_slotset, "slot" .. i)
        AUTO_CAST(slot)
        local buff_data = buffs_to_display[i]
        if buff_data then
            local target_buff_id = tonumber(buff_data.buff_id)
            local target_buff_index = tonumber(buff_data.buff_index)
            local buff_cls = GetClassByType('Buff', target_buff_id)
            if buff_cls then
                -- 変更: 毎回CreateIconするのではなく、既存のアイコンを取得して更新します
                local icon = slot:GetIcon()
                if not icon then
                    icon = CreateIcon(slot)
                    AUTO_CAST(icon)
                end

                local image_name = GET_BUFF_ICON_NAME(buff_cls)
                icon:Set(image_name, 'BUFF', target_buff_id, 0)
                icon:SetTooltipType('buff');
                icon:SetTooltipArg(handle, target_buff_id, target_buff_index);
                slot:SetUserValue("DEBUFF_HANDLE", tonumber(handle))
                slot:SetUserValue("DEBUFF_ID", target_buff_id)
                slot:SetUserValue("DEBUFF_INDEX", target_buff_index)

                -- 変更: タイマーも毎回作り直すのではなく、存在チェックをします
                local addon_timer = slot:GetTimer("addon_timer")
                if not addon_timer then
                    addon_timer = slot:CreateOrGetControl("timer", "addon_timer", 0, 0);
                    AUTO_CAST(addon_timer)
                    addon_timer:SetUpdateScript("debuff_notice_time_update");
                end
                addon_timer:Start(0.1);
            end
        else
            -- 変更: 不要になったスロットはアイコンを消し、タイマーを止めます
            slot:ClearIcon()
            slot:StopTimer("addon_timer")
        end
    end
    debuff_notice:Invalidate()
end]]

function debuff_notice_frame_redraw(debuff_notice, handle)
    local debuff_slotset = debuff_notice:GetChild("debuff_slotset")
    if not debuff_slotset then
        return
    end
    AUTO_CAST(debuff_slotset)
    local buffs_to_display = {}
    if handle and g.debuff_notice.slot_table and g.debuff_notice.slot_table[handle] then
        for buff_id, buff_index in pairs(g.debuff_notice.slot_table[handle]) do
            table.insert(buffs_to_display, {
                buff_id = buff_id,
                buff_index = buff_index
            })
        end
    end
    if #buffs_to_display == 0 then
        debuff_notice:Resize(0, 50)
        return
    end
    local slot_count = debuff_slotset:GetSlotCount()
    for i = 1, slot_count do
        local slot = GET_CHILD(debuff_slotset, "slot" .. i)
        AUTO_CAST(slot)
        slot:ClearIcon()
        local icon = CreateIcon(slot)
        AUTO_CAST(icon)
        local buff_data = buffs_to_display[i]
        if buff_data then
            local target_buff_id = tonumber(buff_data.buff_id)
            local target_buff_index = tonumber(buff_data.buff_index)
            local buff_cls = GetClassByType('Buff', target_buff_id)
            if buff_cls then
                local image_name = GET_BUFF_ICON_NAME(buff_cls)
                icon:Set(image_name, 'BUFF', target_buff_id, 0)
                icon:SetTooltipType('buff');
                icon:SetTooltipArg(handle, target_buff_id, target_buff_index);
                slot:SetUserValue("DEBUFF_HANDLE", tonumber(handle))
                slot:SetUserValue("DEBUFF_ID", target_buff_id)
                slot:SetUserValue("DEBUFF_INDEX", target_buff_index)
                local addon_timer = slot:CreateOrGetControl("timer", "addon_timer", 0, 0);
                AUTO_CAST(addon_timer)
                addon_timer:SetUpdateScript("debuff_notice_time_update");
                addon_timer:Start(0.1);
                local x = #buffs_to_display * 50
                debuff_notice:Resize(x, 50)
            end
        end
    end
    debuff_notice:Invalidate()
end

function debuff_notice_time_update(slot, timer)
    local handle = slot:GetUserIValue("DEBUFF_HANDLE")
    local buff_id = slot:GetUserIValue("DEBUFF_ID")
    local buff_index = slot:GetUserIValue("DEBUFF_INDEX")
    local debuff_notice = slot:GetTopParentFrame()
    local time_text = GET_CHILD(slot, "time_text")
    local count_text = GET_CHILD(slot, "count_text")
    local buff = info.GetBuff(handle, buff_id, buff_index) or info.GetBuff(handle, buff_id)
    if buff then
        if buff.time > 0 then
            local sec = buff.time / 1000
            sec = math.floor(sec * 10 + 0.5) / 10
            sec = string.format("%.1f", sec)
            time_text:SetText("{ol}{s15}{#FFFF00}" .. sec .. "s")
        end
        if buff.over > 0 then
            count_text:SetText("{ol}{s35}{#FFFFFF}" .. buff.over)
        end
    else
        slot:ClearIcon();
        debuff_notice_common_buff_msg(debuff_notice, "REMOVE", buff_id, handle, buff_index)
    end
end

--[[function debuff_notice_frame_resize(debuff_notice)
    -- 変更: この関数の役割を「無効なバフ/ターゲットのチェック」に限定します
    for handle, buffs in pairs(g.debuff_notice.slot_table) do
        local boss_actor = world.GetActor(handle)
        if not boss_actor then
            -- ターゲットがいなくなったら、そのハンドル情報をクリアして再描画
            g.debuff_notice.slot_table[handle] = nil
            debuff_notice_frame_redraw(debuff_notice, handle)
            return 1
        end

        for buff_id, buff_index in pairs(buffs) do
            local buff = info.GetBuff(handle, buff_id, buff_index) or info.GetBuff(handle, buff_id)
            if not buff then
                -- バフが消えていたら、そのバフ情報をクリアして再描画
                debuff_notice_common_buff_msg(debuff_notice, "REMOVE", buff_id, handle, buff_index)
                return 1 -- 一度に一つの変更を処理
            end
        end
    end
    return 1
end
function g.setup_hook_before(origin_func_name, my_func_name)
    local previous_func = _G[origin_func_name]
    if not previous_func then
        return
    end
    _G[origin_func_name] = function(...)
        if _G[my_func_name] then
            _G[my_func_name](...)
        end
        return previous_func(...)
    end
end

        --[[local my_handle = session.GetMyHandle()
        local buffs_to_remove = {}
        for i = 0, s_buff_ui["slotcount"][1] - 1 do
            local slot = s_buff_ui["slotlist"][1][i]
            if slot:IsVisible() == 1 then
                local icon = slot:GetIcon()
                if icon and g.my_buffs_control_settings.buffs[tostring(icon:GetInfo().type)] == false then
                    table.insert(buffs_to_remove, {
                        id = icon:GetInfo().type,
                        index = tostring(icon:GetUserIValue("BuffIndex"))
                    })
                end
            end
        end
        for i = #buffs_to_remove, 1, -1 do
            local buff_info = buffs_to_remove[i]
            COMMON_BUFF_MSG(buff_frame, "REMOVE", buff_info.id, my_handle, s_buff_ui, buff_info.index)
        end]]
        
function g.setup_hook_before_with_filter(origin_func_name, my_filter_func_name)
    local previous_func = _G[origin_func_name]
    if not previous_func then
        return
    end
    _G[origin_func_name] = function(...)
        if _G[my_filter_func_name] and _G[my_filter_func_name](...) then
            return
        end
        return previous_func(...)
    end
end]==] --[[function another_warehouse_frame_update()

    -- g.tree = {}
    g.processed_slots = {}

    local another_warehouse = ui.GetFrame("another_warehouse")
    local awframe = ui.GetFrame("accountwarehouse")
    local group = GET_CHILD_RECURSIVELY(another_warehouse, 'inventoryGbox', 'ui::CGroupBox')

    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
            if tree_box then
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo],
                    'ui::CTreeControl')
                if tree then
                    tree:Clear()
                    tree:EnableDrawFrame(false)
                    tree:SetFitToChild(true, 60)
                    tree:SetFontName(another_warehouse:GetUserConfig("TREE_GROUP_FONT"))
                    tree:SetTabWidth(another_warehouse:GetUserConfig("TREE_TAB_WIDTH"))
                end
            end
        end
    end

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sortedGuidList = itemList:GetSortedGuidList()
    local invItemList = {}
    for i = 0, sortedGuidList:Count() - 1 do
        local invItem = itemList:GetItemByGuid(sortedGuidList:Get(i))
        if invItem then
            table.insert(invItemList, invItem)
        end
    end
    table.sort(invItemList, INVENTORY_SORT_BY_NAME)

    local categorized_items = {}
    for _, inv_item in ipairs(invItemList) do
        local item_cls = GetIES(inv_item:GetObject())
        local baseidcls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(inv_item:GetIESID())

        if item_cls and baseidcls then
            local titleName = baseidcls.MergedTreeTitle ~= "NO" and baseidcls.MergedTreeTitle or baseidcls.ClassName
            if not categorized_items[titleName] then
                categorized_items[titleName] = {}
            end
            table.insert(categorized_items[titleName], inv_item)
        end
    end

    local baseidclslist, baseidcnt = GetClassList("inven_baseid")
    local invenTitleName = {}
    for i = 1, baseidcnt do
        local baseidcls = GetClassByIndexFromList(baseidclslist, i - 1)
        local tempTitle = baseidcls.MergedTreeTitle ~= "NO" and baseidcls.MergedTreeTitle or baseidcls.ClassName
        if table.find(invenTitleName, tempTitle) == 0 then
            table.insert(invenTitleName, tempTitle)
        end
    end

    local search_edit = GET_CHILD_RECURSIVELY(awframe, "search_edit")
    local search_text = search_edit:GetText()

    for _, category_name in ipairs(invenTitleName) do
        local items_in_category = categorized_items[category_name]
        if items_in_category then
            for _, inv_item in ipairs(items_in_category) do
                local item_cls = GetIES(inv_item:GetObject())
                local baseidcls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(inv_item:GetIESID())

                local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)

                local makeSlot = another_warehouse_check_search_and_filter(inv_item, item_cls, search_text)

                if makeSlot and inv_item.count > 0 and baseidcls.ClassName ~= 'Unused' then
                    -- カテゴリ別タブのtreeに追加
                    local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr, 'ui::CGroupBox')
                    if tree_box then
                        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr, 'ui::CTreeControl')
                        if tree then
                            another_warehouse_insert_item_to_tree(another_warehouse, tree, inv_item, item_cls,
                                baseidcls, typeStr)

                        end
                    end

                    -- 「全て表示」タブのtreeにも追加
                    local tree_box_all = GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                    if tree_box_all then
                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All', 'ui::CTreeControl')
                        if tree_all then
                            another_warehouse_insert_item_to_tree(another_warehouse, tree_all, inv_item, item_cls,
                                baseidcls, "All")
                        end
                    end
                end
            end
        end
    end

    local height = another_warehouse:GetHeight()
    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
            if tree_box then
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo],
                    'ui::CTreeControl')
                if tree then

                    local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
                    for i = 1, slotSetNameListCnt do
                        local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                        local slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
                        if slotset ~= nil then
                            ui.InventoryHideEmptySlotBySlotSet(slotset);
                        end
                    end

                    ADD_GROUP_BOTTOM_MARGIN(another_warehouse, tree)
                    tree:OpenNodeAll();
                    tree:SetEventScript(ui.LBUTTONDOWN, "INVENTORY_TREE_OPENOPTION_CHANGE");
                    INVENTORY_CATEGORY_OPENCHECK(another_warehouse, tree);

                end
            end
        end
    end

    local active_tree_box = another_warehouse_find_activegbox(another_warehouse)
    if active_tree_box then
        AUTO_CAST(active_tree_box)
        local savedPos = active_tree_box:GetUserIValue("INVENTORY_CUR_SCROLL_POS")

        -- ts(active_tree_box:GetName(), savedPos)
        -- active_tree_box:EnableScrollBar(1);
        -- active_tree_box:SetScrollBar(group:GetHeight() + 20)
        active_tree_box:SetScrollPos(savedPos)
        active_tree_box:InvalidateScrollBar();
    end

    local maxcount = another_warehouse_get_maxcount()
    local itemcount = another_warehouse_item_count()

    local count_text = GET_CHILD_RECURSIVELY(awframe, "count_text")
    AUTO_CAST(count_text)

    count_text:SetText("{@st42}" .. itemcount .. "/" .. maxcount .. "{/}")
    count_text:SetFontName("white_16_ol")

end]] --[===[
--[[local card_ssets = {}
            for i = 0, tree:GetChildCount() - 1 do
                local child = tree:GetChildByIndex(i)
                if child and string.find(child:GetName(), "^sset_Card") and not string.find(child:GetName(), "Summon") and
                    not string.find(child:GetName(), "CardAddExp") then

                    table.insert(card_ssets, child)
                end
            end

            for _, card_slot_set in ipairs(card_ssets) do
                local child_count = card_slot_set:GetChildCount()
                for i = 0, child_count - 1 do
                    local slot = card_slot_set:GetChildByIndex(i)
                    if slot then
                        AUTO_CAST(slot)
                        local icon = slot:GetIcon()
                        if icon then
                            local info = icon:GetInfo() -- session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iconInfo:GetIESID());
                            local inv_item = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, info:GetIESID());

                            if inv_item then
                                local item_obj = GetIES(inv_item:GetObject())
                                local item_cls = GetClassByType("Item", item_obj.ClassID)
                                local image = nil

                                image = TryGetProp(item_obj, "TooltipImage", "None")

                                if item_cls then
                                    icon:Set(image, 'Item', inv_item.type, inv_item.invIndex, inv_item:GetIESID(),
                                        inv_item.count);

                                end
                            end
                        end
                    end
                end
            end

            local gem_skill_slotset = GET_CHILD_RECURSIVELY(tree, "sset_Gem_GemSkill", 'ui::CSlotSet')

            if gem_skill_slotset then
                -- ts(tab_index, icor_slot_set:GetName())
                local child_count = gem_skill_slotset:GetChildCount()
                for i = 0, child_count - 1 do
                    local slot = gem_skill_slotset:GetChildByIndex(i)
                    if slot then
                        AUTO_CAST(slot)
                        local icon = slot:GetIcon()
                        if icon then
                            local info = icon:GetInfo()
                            local inv_item = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, info:GetIESID());
                            if inv_item then
                                local item_obj = GetIES(inv_item:GetObject())
                                local gem_type = GET_EQUIP_GEM_TYPE(item_obj)

                                local item_cls = GetClassByType("Item", item_obj.ClassID)

                                if item_cls then

                                    for i = 1, 4 do
                                        local option_prop_name = 'RandomOption_' .. i
                                        local option_prop_value = 'RandomOptionValue_' .. i
                                        if TryGetProp(item_obj, option_prop_name, 'None') ~= 'None' and
                                            TryGetProp(item_obj, option_prop_value, 0) > 0 then
                                            local star_pic =
                                                slot:CreateOrGetControl('picture', 'star_pic' .. i, 0, 0, 18, 18)
                                            AUTO_CAST(star_pic)
                                            star_pic:SetEnableStretch(1)
                                            star_pic:SetGravity(ui.RIGHT, ui.TOP)
                                            star_pic:SetImage("star_mark")
                                        end
                                    end
                                    local cls_name = item_cls.ClassName

                                    local image = GET_ITEM_ICON_IMAGE(item_cls)
                                    local skill_name = TryGetProp(item_cls, 'SkillName', 'None')
                                    local skill_cls = GetClass("Skill", skill_name);
                                    local skill_pic = slot:CreateOrGetControl('picture', 'skill_pic' .. i, 0, 0, 35, 35)
                                    AUTO_CAST(skill_pic)
                                    skill_pic:SetEnableStretch(1)
                                    skill_pic:SetGravity(ui.LEFT, ui.TOP)
                                    skill_pic:SetImage(image)
                                    SET_ITEM_TOOLTIP_TYPE(skill_pic, item_cls.ClassID, item_cls, "accountwarehouse")
                                    image = "icon_" .. GET_ITEM_ICON_IMAGE(skill_cls)

                                    if item_cls then
                                        icon:Set(image, 'Item', inv_item.type, inv_item.invIndex, inv_item:GetIESID(),
                                            inv_item.count);

                                    end
                                end
                            end
                        end
                    end
                end
            end

            local Gem_High_Color_slotset = GET_CHILD_RECURSIVELY(tree, "sset_Gem_High_Color", 'ui::CSlotSet')

            if Gem_High_Color_slotset then
                local child_count = Gem_High_Color_slotset:GetChildCount()
                for i = 0, child_count - 1 do
                    local slot = Gem_High_Color_slotset:GetChildByIndex(i)
                    if slot then
                        AUTO_CAST(slot)
                        local icon = slot:GetIcon()
                        if icon then
                            local info = icon:GetInfo()
                            local inv_item = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, info:GetIESID());
                            if inv_item then
                                local item_obj = GetIES(inv_item:GetObject())
                                local item_cls = GetClassByType("Item", item_obj.ClassID)

                                if item_cls then

                                    local cls_name = item_cls.ClassName
                                    if string.find(cls_name, 540) then
                                        slot:SetSkinName("invenslot_pic_goddess")
                                    elseif string.find(cls_name, 520) then
                                        slot:SetSkinName("invenslot_legend")
                                    elseif string.find(cls_name, 500) then
                                        slot:SetSkinName("invenslot_unique")
                                    elseif string.find(cls_name, 480) then
                                        slot:SetSkinName("invenslot_rare")
                                    else
                                        slot:SetSkinName("invenslot_nomal")
                                    end

                                end
                            end
                        end
                    end
                end
            end

            local icor_slot_set = GET_CHILD_RECURSIVELY(tree, "sset_Icor", 'ui::CSlotSet')

            if icor_slot_set then
                -- ts(tab_index, icor_slot_set:GetName())
                local child_count = icor_slot_set:GetChildCount()
                for i = 0, child_count - 1 do
                    local slot = icor_slot_set:GetChildByIndex(i)
                    if slot then
                        AUTO_CAST(slot)
                        local icon = slot:GetIcon()
                        if icon then
                            local info = icon:GetInfo()
                            local target_item = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, info:GetIESID());
                            if target_item then
                                local item_obj = GetIES(target_item:GetObject())
                                local item_cls = GetClassByType("Item", item_obj.ClassID)
                                if item_cls then
                                    local cls_name = item_cls.ClassName

                                    local is_special_item = string.find(cls_name, "EP17") or
                                                                string.find(cls_name, "Weapon2") or
                                                                string.find(cls_name, "Armor2")

                                    if not is_special_item then
                                        slot:SetSkinName("invenslot_rare")
                                    end

                                    local market_trade = TryGetProp(item_cls, "MarketTrade")
                                    if market_trade == "NO" then
                                        local trade = slot:CreateOrGetControl('richtext', 'trade' .. i, 5, 40, 30, 10)
                                        AUTO_CAST(trade)
                                        trade:SetText("{ol}{s10}NoTrade")
                                    end

                                end
                            end
                        end
                    end
                end
            end

            local armor_slot_set = GET_CHILD_RECURSIVELY(tree, "sset_Armor", 'ui::CSlotSet')

            if armor_slot_set then
                -- ts(tab_index, armor_slot_set:GetName())
                local child_count = armor_slot_set:GetChildCount()
                for i = 0, child_count - 1 do
                    local slot = armor_slot_set:GetChildByIndex(i)
                    if slot then
                        AUTO_CAST(slot)
                        local icon = slot:GetIcon()
                        if icon then
                            local info = icon:GetInfo()
                            local target_item = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, info:GetIESID());
                            if target_item then
                                local item_obj = GetIES(target_item:GetObject())
                                local item_cls = GetClassByType("Item", item_obj.ClassID)

                                if item_cls then

                                    local cls_name = item_cls.ClassName

                                    local is_special_item = string.find(cls_name, "EP17") or
                                                                (string.find(cls_name, "EP16") and
                                                                    string.find(cls_name, "high")) or
                                                                (string.find(cls_name, "EP13") and
                                                                    string.find(cls_name, "high2"))

                                    if not is_special_item and
                                        (string.find(cls_name, "belt") or string.find(cls_name, "shoulder")) then
                                        slot:SetSkinName("invenslot_rare")
                                    end

                                end
                            end
                        end
                    end
                end
            end]]
function another_warehouse_insert_item_to_tree(frame, tree, invItem, itemCls, baseidcls, typeStr)

    local unique_id = tree:GetName() .. "_" .. invItem:GetIESID()
    if g.processed_slots[unique_id] then
        return -- 
    end
    g.processed_slots[unique_id] = true

    local treegroupname = baseidcls.TreeGroup

    local treegroup = tree:FindByValue(treegroupname);
    if tree:IsExist(treegroup) == 0 then
        treegroup = tree:Add(baseidcls.TreeGroupCaption, baseidcls.TreeGroup);
        local treeNode = tree:GetNodeByTreeItem(treegroup);
        treeNode:SetUserValue("BASE_CAPTION", baseidcls.TreeGroupCaption);
    end

    local slotsetname = another_warehouse_get_slotset_name(baseidcls)

    local slotsetnode = tree:FindByValue(treegroup, slotsetname);
    -- ts(tree:IsExist(slotsetnode))
    if tree:IsExist(slotsetnode) == 0 then
        local slotsettitle = 'ssettitle_' .. baseidcls.ClassName;
        if baseidcls.MergedTreeTitle ~= "NO" then
            slotsettitle = 'ssettitle_' .. baseidcls.MergedTreeTitle
        end

        local newSlotsname = MAKE_INVEN_SLOTSET_NAME(tree, slotsettitle, baseidcls.TreeSSetTitle)

        --[[g.tree[typeStr] = g.tree[typeStr] or {}
        g.tree[typeStr][#g.tree[typeStr] + 1] = {
            treegroup = treegroupname,
            treegroupcaption = newSlotsname:GetText():gsub("%(.*%)", ""),
            slotsetname = slotsetname
        }]]

        another_warehouse_inven_slotset_and_title(tree, treegroup, slotsetname, baseidcls);

        -- INVENTORY_CATEGORY_OPENOPTION_CHECK(tree:GetName(), baseidcls.ClassName);
    end
    local slotset = GET_CHILD_RECURSIVELY(tree, slotsetname, 'ui::CSlotSet');
    local slotCount = slotset:GetSlotCount();

    local slot = nil;

    local cnt = GET_SLOTSET_COUNT(tree, baseidcls)

    while slotCount <= cnt do
        slotset:ExpandRow()
        slotCount = slotset:GetSlotCount();
    end

    slot = slotset:GetSlotByIndex(cnt);
    --[[cnt = cnt + 1;
    slotset:SetUserValue("SLOT_ITEM_COUNT", cnt)

    slot:ShowWindow(1);]]
    UPDATE_INVENTORY_SLOT(slot, invItem, itemCls);

    local function _DRAW_ITEM(invItem, slot)
        -- local obj = GetIES(invItem:GetObject());

        slot:SetSkinName('invenslot2')
        local itemCls = GetIES(invItem:GetObject());
        local iconImg = GET_ITEM_ICON_IMAGE(itemCls);

        slot:SetHeaderImage('None')

        local new_sset = GET_CHILD_RECURSIVELY(frame, slotsetname)

        SET_SLOT_IMG(slot, iconImg)
        SET_SLOT_COUNT(slot, invItem.count)

        SET_SLOT_STYLESET(slot, itemCls)
        SET_SLOT_IESID(slot, invItem:GetIESID())
        SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, invItem, itemCls, nil)
        slot:SetMaxSelectCount(invItem.count);
        local icon = slot:GetIcon();
        icon:SetTooltipArg("accountwarehouse", invItem.type, invItem:GetIESID());
        SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID, itemCls, "accountwarehouse");
        SET_SLOT_ICOR_CATEGORY(slot, itemCls);

        if g.settings.display_change == 1 then

            if baseidcls.TreeGroup == "Recipe" then

                local recipeCls = GetClass('Recipe', itemCls.ClassName);
                if recipeCls ~= nil then

                    local taget_item = GetClass("Item", recipeCls.TargetItem);

                    if taget_item then
                        local image = GET_ITEM_ICON_IMAGE(taget_item)

                        local recipe_pic = slot:CreateOrGetControl('picture', 'recipe_pic' .. image, 0, 0, 25, 25)
                        AUTO_CAST(recipe_pic)
                        recipe_pic:SetEnableStretch(1)
                        recipe_pic:SetGravity(ui.LEFT, ui.TOP)
                        recipe_pic:SetImage(image)
                        recipe_pic:SetTooltipArg("accountwarehouse", invItem.type, invItem:GetIESID());
                        SET_ITEM_TOOLTIP_TYPE(recipe_pic, taget_item.ClassID, taget_item, "accountwarehouse");
                    end
                end

            end

            if string.find(baseidcls.ClassName, "Card") and not string.find(baseidcls.ClassName, "Summon") and
                not string.find(baseidcls.ClassName, "CardAddExp") then
                local image = TryGetProp(itemCls, "TooltipImage", "None")
                if image ~= "None" then
                    icon:Set(image, 'Item', invItem.type, invItem.invIndex, invItem:GetIESID(), invItem.count);
                end
            end

            if baseidcls.ClassName == "Gem_GemSkill" then

                for i = 1, 4 do
                    if TryGetProp(itemCls, 'RandomOption_' .. i, 'None') ~= 'None' and
                        TryGetProp(itemCls, 'RandomOptionValue_' .. i, 0) > 0 then
                        local star_pic = slot:CreateOrGetControl('picture', 'star_pic' .. i, 0, 0, 18, 18)
                        star_pic:SetEnableStretch(1);
                        star_pic:SetGravity(ui.RIGHT, ui.TOP);
                        star_pic:SetImage("star_mark")
                    end
                end

                local skill_cls = GetClass("Skill", TryGetProp(itemCls, 'SkillName', 'None'))
                if skill_cls then

                    local image = "icon_" .. GET_ITEM_ICON_IMAGE(skill_cls)

                    icon:Set(image, 'Item', invItem.type, invItem.invIndex, invItem:GetIESID(), invItem.count);
                    local skill_pic =
                        slot:CreateOrGetControl('picture', 'skill_pic' .. invItem:GetIESID(), 0, 0, 35, 35)
                    AUTO_CAST(skill_pic)

                    local image = GET_ITEM_ICON_IMAGE(itemCls)
                    skill_pic:SetEnableStretch(1)
                    skill_pic:SetGravity(ui.LEFT, ui.TOP)
                    skill_pic:SetImage(image)
                end
            elseif baseidcls.ClassName == "Gem_High_Color" then

                local cls_name = itemCls.ClassName
                if string.find(cls_name, "540") then
                    slot:SetSkinName("invenslot_pic_goddess")
                elseif string.find(cls_name, "520") then
                    slot:SetSkinName("invenslot_legend")
                elseif string.find(cls_name, "500") then
                    slot:SetSkinName("invenslot_unique")
                elseif string.find(cls_name, "480") then
                    slot:SetSkinName("invenslot_rare")
                else
                    slot:SetSkinName("invenslot_nomal")
                end
            end
            -- ts(baseidcls.ClassName)
            if string.find(baseidcls.ClassName, "OPTMisc_GoddessIcor") then
                local cls_name = itemCls.ClassName

                local is_special = string.find(cls_name, "EP17") or string.find(cls_name, "Weapon2") or
                                       string.find(cls_name, "Armor2")
                if not is_special then
                    slot:SetSkinName("invenslot_rare")
                end
            elseif string.find(baseidcls.ClassName, "Armor") then
                local cls_name = itemCls.ClassName
                local is_special = string.find(cls_name, "EP17") or
                                       (string.find(cls_name, "EP16") and string.find(cls_name, "high")) or
                                       (string.find(cls_name, "EP13") and string.find(cls_name, "high2"))
                if not is_special and (string.find(cls_name, "belt") or string.find(cls_name, "shoulder")) then
                    slot:SetSkinName("invenslot_rare")
                end
            end

        end

        if invItem.hasLifeTime == true or TryGetProp(itemCls, 'ExpireDateTime', 'None') ~= 'None' then
            ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE);
            slot:SetFrontImage('clock_inven');
        else
            CLEAR_ICON_REMAIN_LIFETIME(slot, icon);
        end
        -- 아이커 종류 표시
        -- 

    end

    _DRAW_ITEM(invItem, slot, nil)

    SET_SLOTSETTITLE_COUNT(tree, baseidcls, 1)
    if (g.settings.enabledrag) then
        slot:EnableDrag(1)
    else
        slot:EnableDrag(0)
    end
    slot:SetEventScript(ui.LBUTTONUP, "another_warehouse_on_lbutton")
    slot:SetEventScript(ui.RBUTTONUP, "another_warehouse_on_rbutton")
    slotset:MakeSelectionList();
    -- slotset:EnableSelection(1)
end

function another_warehouse_check_search_and_filter(inv_item, item_cls, search_text)
    -- 検索テキストがなければ、常に表示(true)
    if search_text == "" then
        return true
    end

    -- 検索テキストがある場合は、一致するかどうかで判定
    local temp_cap = string.lower(search_text)

    -- 1. アイテム名で検索
    local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(item_cls.Name))
    if string.find(item_name, temp_cap) then
        return true -- 見つかった時点でtrueを返して終了
    end

    -- 2. 凡例装備のセット名で検索
    local prefix_class_name = TryGetProp(item_cls, "LegendPrefix")
    if prefix_class_name and prefix_class_name ~= "None" then
        local prefix_cls = GetClass('LegendSetItem', prefix_class_name)
        if prefix_cls then
            local prefix_name = string.lower(dictionary.ReplaceDicIDInCompStr(prefix_cls.Name))
            if string.find(prefix_name .. " " .. item_name, temp_cap) then
                return true -- 見つかった時点でtrueを返して終了
            end
        end
    end

    -- 3. イヤリングの特殊オプション名で検索
    if TryGetProp(item_cls, 'GroupName', 'None') == 'Earring' then
        local max_option_count = shared_item_earring.get_max_special_option_count(TryGetProp(item_cls, 'UseLv', 1))
        for i = 1, max_option_count do
            local option_name = 'EarringSpecialOption_' .. i
            local job_id = TryGetProp(item_cls, option_name, 'None')
            if job_id ~= 'None' then
                local job_cls = GetClass('Job', job_id)
                if job_cls and string.find(string.lower(dictionary.ReplaceDicIDInCompStr(job_cls.Name)), temp_cap) then
                    return true -- 見つかった時点でtrueを返して終了
                end
            end
        end
    end

    -- 4. アイカーのランダムオプション名で検索
    if TryGetProp(item_cls, 'GroupName', 'None') == 'Icor' then
        local item = GetIES(inv_item:GetObject())
        for i = 1, 5 do
            local option = TryGetProp(item, 'RandomOption_' .. i, 'None')
            if option and option ~= "None" and
                string.find(string.lower(dictionary.ReplaceDicIDInCompStr(ClMsg(option))), temp_cap) then
                return true -- 見つかった時点でtrueを返して終了
            end
        end
    end

    -- 全ての検索に一致しなかった場合
    return false
end

function another_warehouse_frame_update()

    -- g.tree = {}
    g.processed_slots = {}

    local frame = ui.GetFrame("another_warehouse")
    local awframe = ui.GetFrame("accountwarehouse")
    local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')

    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
            if tree_box then
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo],
                    'ui::CTreeControl')
                if tree then
                    tree:Clear()
                    tree:EnableDrawFrame(false)
                    tree:SetFitToChild(true, 60)
                    tree:SetFontName(frame:GetUserConfig("TREE_GROUP_FONT"))
                    tree:SetTabWidth(frame:GetUserConfig("TREE_TAB_WIDTH"))
                end
            end
        end
    end

    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sortedGuidList = itemList:GetSortedGuidList()
    local invItemList = {}
    for i = 0, sortedGuidList:Count() - 1 do
        local invItem = itemList:GetItemByGuid(sortedGuidList:Get(i))
        if invItem then
            table.insert(invItemList, invItem)
        end
    end
    table.sort(invItemList, INVENTORY_SORT_BY_NAME)

    local categorized_items = {}
    for _, inv_item in ipairs(invItemList) do
        local item_cls = GetIES(inv_item:GetObject())
        local baseidcls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(inv_item:GetIESID())

        if item_cls and baseidcls then
            local titleName = baseidcls.MergedTreeTitle ~= "NO" and baseidcls.MergedTreeTitle or baseidcls.ClassName
            if not categorized_items[titleName] then
                categorized_items[titleName] = {}
            end
            table.insert(categorized_items[titleName], inv_item)
        end
    end

    local baseidclslist, baseidcnt = GetClassList("inven_baseid")
    local invenTitleName = {}
    for i = 1, baseidcnt do
        local baseidcls = GetClassByIndexFromList(baseidclslist, i - 1)
        local tempTitle = baseidcls.MergedTreeTitle ~= "NO" and baseidcls.MergedTreeTitle or baseidcls.ClassName
        if table.find(invenTitleName, tempTitle) == 0 then
            table.insert(invenTitleName, tempTitle)
        end
    end

    local search_edit = GET_CHILD_RECURSIVELY(awframe, "search_edit")
    local search_text = search_edit:GetText()

    for _, category_name in ipairs(invenTitleName) do
        local items_in_category = categorized_items[category_name]
        if items_in_category then
            for _, inv_item in ipairs(items_in_category) do
                local item_cls = GetIES(inv_item:GetObject())
                local baseidcls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(inv_item:GetIESID())

                local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)

                local makeSlot = another_warehouse_check_search_and_filter(inv_item, item_cls, search_text)

                if makeSlot and inv_item.count > 0 and baseidcls.ClassName ~= 'Unused' then
                    -- カテゴリ別タブのtreeに追加
                    local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr, 'ui::CGroupBox')
                    if tree_box then
                        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr, 'ui::CTreeControl')
                        if tree then
                            another_warehouse_insert_item_to_tree(frame, tree, inv_item, item_cls, baseidcls, typeStr)

                        end
                    end

                    -- 「全て表示」タブのtreeにも追加
                    local tree_box_all = GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                    if tree_box_all then
                        local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All', 'ui::CTreeControl')
                        if tree_all then
                            another_warehouse_insert_item_to_tree(frame, tree_all, inv_item, item_cls, baseidcls, "All")
                        end
                    end
                end
            end
        end
    end

    local height = frame:GetHeight()
    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
            if tree_box then
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo],
                    'ui::CTreeControl')
                if tree then

                    local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
                    for i = 1, slotSetNameListCnt do
                        local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                        local slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
                        if slotset ~= nil then
                            ui.InventoryHideEmptySlotBySlotSet(slotset);
                        end
                    end

                    ADD_GROUP_BOTTOM_MARGIN(frame, tree)
                    tree:OpenNodeAll();
                    tree:SetEventScript(ui.LBUTTONDOWN, "INVENTORY_TREE_OPENOPTION_CHANGE");
                    INVENTORY_CATEGORY_OPENCHECK(frame, tree);

                end
            end
        end
    end

    local active_tree_box = another_warehouse_find_activegbox(frame)
    if active_tree_box then
        AUTO_CAST(active_tree_box)
        local savedPos = active_tree_box:GetUserIValue("INVENTORY_CUR_SCROLL_POS")

        -- ts(active_tree_box:GetName(), savedPos)
        -- active_tree_box:EnableScrollBar(1);
        -- active_tree_box:SetScrollBar(group:GetHeight() + 20)
        active_tree_box:SetScrollPos(savedPos)
        active_tree_box:InvalidateScrollBar();
    end

    local maxcount = another_warehouse_get_maxcount()
    local itemcount = another_warehouse_item_count()

    local count_text = GET_CHILD_RECURSIVELY(awframe, "count_text")
    AUTO_CAST(count_text)

    count_text:SetText("{@st42}" .. itemcount .. "/" .. maxcount .. "{/}")
    count_text:SetFontName("white_16_ol")

end
for _, category_name in ipairs(invenTitleName) do

        for _, inv_item in ipairs(invItemList) do
            local item_cls = GetIES(inv_item:GetObject())
            local baseidcls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(inv_item:GetIESID())

            if item_cls and baseidcls then
                local titleName = baseidcls.MergedTreeTitle ~= "NO" and baseidcls.MergedTreeTitle or baseidcls.ClassName

                if category_name == titleName then
                    local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)

                    local makeSlot = another_warehouse_check_search_and_filter(inv_item, item_cls, search_text)

                    if makeSlot and inv_item.count > 0 and baseidcls.ClassName ~= 'Unused' then

                        local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr, 'ui::CGroupBox')
                        if tree_box then
                            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr, 'ui::CTreeControl')
                            if tree then
                                another_warehouse_insert_item_to_tree(frame, tree, inv_item, item_cls, baseidcls,
                                    typeStr)
                            end
                        end

                        local tree_box_all = GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                        if tree_box_all then
                            local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All', 'ui::CTreeControl')
                            if tree_all then
                                another_warehouse_insert_item_to_tree(frame, tree_all, inv_item, item_cls, baseidcls,
                                    "All")
                            end
                        end
                    end
                end
            end
        end
    end]]
--[[function another_warehouse_frame_update()

    g.tree = {}
    local frame = ui.GetFrame("another_warehouse")

    local invenTypeStr = nil
    local invframe = ui.GetFrame("inventory")
    local awframe = ui.GetFrame("accountwarehouse")
    -- local blinkcolor = frame:GetUserConfig("TREE_SEARCH_BLINK_COLOR");
    local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')

    local etree_box = another_warehouse_find_activegbox(frame)
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
    local guidList = itemList:GetGuidList();
    local sortedGuidList = itemList:GetSortedGuidList();
    -- local isShowMap = {};
    local sortedCnt = sortedGuidList:Count();

    local invItemCount = sortedCnt;

    local invItemList = {}
    local index_count = 1
    local cls_inv_index = {}
    local i_cnt = 0

    local curpos = etree_box:GetScrollCurPos();
    frame:SetUserValue("INVENTORY_CUR_SCROLL_POS", curpos);

    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            if (invenTypeStr == nil or invenTypeStr == g_invenTypeStrList[typeNo] or typeNo == 1) then
                local tree_box =
                    GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
                local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo],
                    'ui::CTreeControl')

                local groupfontname = frame:GetUserConfig("TREE_GROUP_FONT");
                local tabwidth = frame:GetUserConfig("TREE_TAB_WIDTH");

                tree:Clear();
                tree:EnableDrawFrame(false)
                tree:SetFitToChild(true, 60)
                tree:SetFontName(groupfontname);
                tree:SetTabWidth(tabwidth);

            end
        end
    end

    local baseidclslist, baseidcnt = GetClassList("inven_baseid");
    local invenTitleName = nil
    if invenTitleName == nil then
        invenTitleName = {}
        for i = 1, baseidcnt do

            local baseidcls = GetClassByIndexFromList(baseidclslist, i - 1)
            local tempTitle = baseidcls.ClassName
            if baseidcls.MergedTreeTitle ~= "NO" then
                tempTitle = baseidcls.MergedTreeTitle
            end

            if table.find(invenTitleName, tempTitle) == 0 then
                invenTitleName[#invenTitleName + 1] = tempTitle
            end
        end
    end

    for i = 0, invItemCount - 1 do
        local invItem = itemList:GetItemByGuid(sortedGuidList:Get(i));
        if invItem ~= nil then
            local pass = true
            -- local obj = GetIES(invItem:GetObject())
            -- local class = GetClassByType("Item", obj.ClassID)
            -- local realname = dictionary.ReplaceDicIDInCompStr(class.Name)

            if pass then
                invItem.index = index_count
                invItemList[index_count] = invItem
                index_count = index_count + 1
            end
        end
    end

    local sortType = 3

    if sortType == 1 then
        table.sort(invItemList, INVENTORY_SORT_BY_GRADE)
    elseif sortType == 2 then
        table.sort(invItemList, INVENTORY_SORT_BY_WEIGHT)
    elseif sortType == 3 then
        table.sort(invItemList, INVENTORY_SORT_BY_NAME)
    elseif sortType == 4 then
        table.sort(invItemList, INVENTORY_SORT_BY_COUNT)
    else
        table.sort(invItemList, INVENTORY_SORT_BY_NAME)
    end

    local search_edit = GET_CHILD_RECURSIVELY(awframe, "search_edit")
    local search_text = search_edit:GetText()

    for i = 1, #invenTitleName do
        local category = invenTitleName[i]
        local lim = 30

        for j = 1, #invItemList do
            lim = lim - 1
            if (lim == 0) then

                lim = 30
            end
            local invItem = invItemList[j];
            if invItem ~= nil then
                local itemCls = GetIES(invItem:GetObject())
                if itemCls.MarketCategory ~= "None" then
                    local baseidcls = nil
                    baseidcls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(invItem:GetIESID())
                    cls_inv_index[invItem.invIndex] = baseidcls

                    local titleName = baseidcls.ClassName
                    if baseidcls.MergedTreeTitle ~= "NO" then
                        titleName = baseidcls.MergedTreeTitle
                    end

                    if category == titleName then
                        local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                        if itemCls ~= nil then
                            local makeSlot = true;

                            if search_text ~= "" then
                                local itemname = string.lower(dictionary.ReplaceDicIDInCompStr(itemCls.Name));
                                local prefixClassName = TryGetProp(itemCls, "LegendPrefix")
                                if prefixClassName ~= nil and prefixClassName ~= "None" then
                                    local prefixCls = GetClass('LegendSetItem', prefixClassName)
                                    local prefixName = string.lower(dictionary.ReplaceDicIDInCompStr(prefixCls.Name));
                                    itemname = prefixName .. " " .. itemname;
                                end
                                local tempcap = string.lower(search_text);
                                local a = string.find(itemname, tempcap);
                                if a == nil then
                                    makeSlot = false
                                    if TryGetProp(itemCls, 'GroupName', 'None') == 'Earring' then
                                        local max_option_count =
                                            shared_item_earring.get_max_special_option_count(TryGetProp(itemCls,
                                                'UseLv', 1))
                                        for ii = 1, max_option_count do
                                            local option_name = 'EarringSpecialOption_' .. ii
                                            local job = TryGetProp(itemCls, option_name, 'None')
                                            if job ~= 'None' then
                                                local job_cls = GetClass('Job', job)
                                                if job_cls ~= nil then
                                                    itemname = string.lower(
                                                        dictionary.ReplaceDicIDInCompStr(job_cls.Name));
                                                    a = string.find(itemname, tempcap);
                                                    if a ~= nil then
                                                        makeSlot = true
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    elseif TryGetProp(itemCls, 'GroupName', 'None') == 'Icor' then

                                        local max_option = 5
                                        for iii = 1, max_option do
                                            local item = GetIES(invItem:GetObject())
                                            local option_name = 'RandomOption_' .. iii
                                            local option = TryGetProp(item, option_name, 'None')
                                            if option ~= "None" or option ~= nil then
                                                itemname = string.lower(dictionary.ReplaceDicIDInCompStr(ClMsg(option)))
                                            end
                                            a = string.find(itemname, tempcap);
                                            if a ~= nil then
                                                makeSlot = true
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                            local viewOptionCheck = 1
                            if typeStr == "Equip" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_EQUIP(itemCls)
                            elseif typeStr == "Card" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_CARD(itemCls)
                            elseif typeStr == "Etc" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_ETC(itemCls)
                            elseif typeStr == "Gem" then
                                viewOptionCheck = CHECK_INVENTORY_OPTION_GEM(itemCls)
                            end
                            if makeSlot == true and viewOptionCheck == 1 then
                                if invItem.count > 0 and baseidcls.ClassName ~= 'Unused' then -- Unused로 설정된 것은 안보임
                                    g.tree[typeStr] = g.tree[typeStr] or {}
                                    if invenTypeStr == nil or invenTypeStr == typeStr then
                                        local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr,
                                            'ui::CGroupBox')
                                        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr,
                                            'ui::CTreeControl')
                                        another_warehouse_insert_item_to_tree(frame, tree, invItem, itemCls, baseidcls,
                                            typeStr);

                                    end

                                    local tree_box_all = GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                                    local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All',
                                        'ui::CTreeControl')
                                    another_warehouse_insert_item_to_tree(frame, tree_all, invItem, itemCls, baseidcls,
                                        typeStr);

                                end
                            end
                        end
                    end
                end
            end

        end

    end
    local height = frame:GetHeight()

    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then

            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
            AUTO_CAST(tree_box)

            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');
            AUTO_CAST(tree)

            local tab = GET_CHILD_RECURSIVELY(group, "inventype_Tab")
            AUTO_CAST(tab)

            local tab_JP = GET_CHILD_RECURSIVELY(group, "inventype_Tab_JP")
            AUTO_CAST(tab_JP)
            if g.lang == "Japanese" then
                tab_JP:ShowWindow(1)
                tab:ShowWindow(0)
            else
                tab_JP:ShowWindow(0)
                tab:ShowWindow(1)
            end

            if tree_box:GetWidth() ~= (650 - 38) then
                tree_box:Resize(650 - 38, height - 5)
            end
            if tree:GetWidth() ~= (650 - 38) then
                tree:Resize(650 - 38, height - 5)
            end
            -- 
        end
    end

    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox');
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl');
            local slotset

            -- 아이템 없는 빈 슬롯은 숨겨라
            local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();
            for i = 1, slotSetNameListCnt do
                local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');
                if slotset ~= nil then
                    ui.InventoryHideEmptySlotBySlotSet(slotset);
                end
            end

            ADD_GROUP_BOTTOM_MARGIN(frame, tree)
            tree:OpenNodeAll();
            tree:SetEventScript(ui.LBUTTONDOWN, "INVENTORY_TREE_OPENOPTION_CHANGE");
            INVENTORY_CATEGORY_OPENCHECK(frame, tree);

            -- 검색결과 스크롤 세팅은 여기서 하자. 트리 업데이트 후에 위치가 고정된 다음에.
            for i = 1, slotSetNameListCnt do
                local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
                slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet');

                local slotsetnode = tree:FindByValue(getSlotSetName);
                local savedPos = frame:GetUserValue("INVENTORY_CUR_SCROLL_POS");
                if savedPos == 'None' then
                    savedPos = 0
                end
                tree_box:SetScrollPos(tonumber(savedPos))

            end
        end

    end

    local gbox = frame:GetChild("inventoryGbox")
    AUTO_CAST(gbox)
    gbox:Resize(650, height - 15)
    gbox:SetOffset(10, 5)
    gbox:SetSkinName("test_frame_low")

    local gbox2 = frame:GetChildRecursively("inventoryitemGbox")
    AUTO_CAST(gbox2)
    gbox2:Resize(650 - 32, height - 15)
    gbox2:SetOffset(35, 0)

    local maxcount = another_warehouse_get_maxcount()
    local itemcount = another_warehouse_item_count()

    local count_text = GET_CHILD_RECURSIVELY(awframe, "count_text")
    AUTO_CAST(count_text)

    count_text:SetText("{@st42}" .. itemcount .. "/" .. maxcount .. "{/}")
    count_text:SetFontName("white_16_ol")

end]]

--[===[
function another_warehouse_frame_update()
    g.tree = {}
    local frame = ui.GetFrame("another_warehouse")
    local invframe = ui.GetFrame("inventory")
    local awframe = ui.GetFrame("accountwarehouse")

    -- ★★★ マジックナンバーを変数に置き換える ★★★
    local GBOX_WIDTH = 650
    local SCROLLBAR_WIDTH = 38
    local CONTENT_WIDTH = GBOX_WIDTH - SCROLLBAR_WIDTH

    -- 必要なコントロールを先に取得
    local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')
    local etree_box = another_warehouse_find_activegbox(frame)
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sortedGuidList = itemList:GetSortedGuidList()
    local invItemCount = sortedGuidList:Count()

    -- スクロール位置を保存
    local curpos = etree_box:GetScrollCurPos()
    frame:SetUserValue("INVENTORY_CUR_SCROLL_POS", curpos)

    -- アイテムリストの準備とソート
    local invItemList = {}
    for i = 0, invItemCount - 1 do
        local invItem = itemList:GetItemByGuid(sortedGuidList:Get(i))
        if invItem then
            invItemList[#invItemList + 1] = invItem
        end
    end
    table.sort(invItemList, INVENTORY_SORT_BY_NAME) -- 現在は名前ソート固定

    -- カテゴリリストの準備
    local baseidclslist, baseidcnt = GetClassList("inven_baseid")
    local invenTitleName = {}
    for i = 1, baseidcnt do
        local baseidcls = GetClassByIndexFromList(baseidclslist, i - 1)
        local tempTitle = baseidcls.MergedTreeTitle ~= "NO" and baseidcls.MergedTreeTitle or baseidcls.ClassName
        if table.find(invenTitleName, tempTitle) == 0 then
            invenTitleName[#invenTitleName + 1] = tempTitle
        end
    end

    -- 検索テキストの取得
    local search_edit = GET_CHILD_RECURSIVELY(awframe, "search_edit")
    local search_text = search_edit:GetText()

    -- アイテムをTreeControlに追加するメインロジック
    -- TreeControlの初期化もこの中で行う
    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl')
            tree:Clear()
            tree:EnableDrawFrame(false)
            tree:SetFitToChild(true, 60)
            tree:SetFontName(frame:GetUserConfig("TREE_GROUP_FONT"))
            tree:SetTabWidth(frame:GetUserConfig("TREE_TAB_WIDTH"))
        end
    end

    for _, category in ipairs(invenTitleName) do
        for _, invItem in ipairs(invItemList) do
            local itemCls = GetIES(invItem:GetObject())
            local baseidcls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(invItem:GetIESID())
            local titleName = baseidcls.MergedTreeTitle ~= "NO" and baseidcls.MergedTreeTitle or baseidcls.ClassName

            if category == titleName then
                local typeStr = GET_INVENTORY_TREEGROUP(baseidcls)
                local makeSlot = another_warehouse_check_search_and_filter(invItem, itemCls, search_text, typeStr)

                if makeSlot and invItem.count > 0 and baseidcls.ClassName ~= 'Unused' then
                    g.tree[typeStr] = g.tree[typeStr] or {}

                    -- カテゴリ別タブのTreeControlにアイテムを追加
                    local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. typeStr, 'ui::CGroupBox')
                    local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. typeStr, 'ui::CTreeControl')
                    another_warehouse_insert_item_to_tree(frame, tree, invItem, itemCls, baseidcls, typeStr)

                    -- 「全て表示」タブのTreeControlにアイテムを追加
                    local tree_box_all = GET_CHILD_RECURSIVELY(group, 'treeGbox_All', 'ui::CGroupBox')
                    local tree_all = GET_CHILD_RECURSIVELY(tree_box_all, 'inventree_All', 'ui::CTreeControl')
                    another_warehouse_insert_item_to_tree(frame, tree_all, invItem, itemCls, baseidcls, typeStr)
                end
            end
        end
    end

    -- ★★★ 変更点: 3つのループを、この1つのループに統合 ★★★
    for typeNo = 1, #g_invenTypeStrList do
        if not IsBlackListedTabName(g_invenTypeStrList[typeNo]) then
            local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_' .. g_invenTypeStrList[typeNo], 'ui::CGroupBox')
            local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_' .. g_invenTypeStrList[typeNo], 'ui::CTreeControl')

            -- リサイズ処理
            local height = frame:GetHeight()
            tree_box:Resize(CONTENT_WIDTH, height - 5)
            tree:Resize(CONTENT_WIDTH, height - 5)

            -- 最終設定
            local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount()
            for i = 1, slotSetNameListCnt do
                local getSlotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1)
                local slotset = GET_CHILD_RECURSIVELY(tree, getSlotSetName, 'ui::CSlotSet')
                if slotset then
                    ui.InventoryHideEmptySlotBySlotSet(slotset)
                end
            end

            ADD_GROUP_BOTTOM_MARGIN(frame, tree)
            tree:OpenNodeAll()
            tree:SetEventScript(ui.LBUTTONDOWN, "INVENTORY_TREE_OPENOPTION_CHANGE")
            INVENTORY_CATEGORY_OPENCHECK(frame, tree)
        end
    end

    -- スクロール位置の設定
    local active_tree_box = another_warehouse_find_activegbox(frame)
    if active_tree_box then
        local savedPos = frame:GetUserValue("INVENTORY_CUR_SCROLL_POS")
        if savedPos == 'None' then
            savedPos = 0
        end
        active_tree_box:SetScrollPos(tonumber(savedPos))
    end

    -- タブの表示/非表示切り替え
    local tab = GET_CHILD_RECURSIVELY(group, "inventype_Tab")
    local tab_JP = GET_CHILD_RECURSIVELY(group, "inventype_Tab_JP")
    if tab and tab_JP then
        if g.lang == "Japanese" then
            tab_JP:ShowWindow(1)
            tab:ShowWindow(0)
        else
            tab_JP:ShowWindow(0)
            tab:ShowWindow(1)
        end
    end

    -- gboxのリサイズと位置調整
    local gbox = frame:GetChild("inventoryGbox")
    local height = frame:GetHeight()
    gbox:Resize(GBOX_WIDTH, height - 15)
    gbox:SetOffset(10, 5)
    gbox:SetSkinName("test_frame_low")

    local gbox2 = frame:GetChildRecursively("inventoryitemGbox")
    gbox2:Resize(GBOX_WIDTH - 32, height - 15)
    gbox2:SetOffset(35, 0)

    -- アイテムカウントの表示
    local maxcount = another_warehouse_get_maxcount()
    local itemcount = another_warehouse_item_count()
    local count_text = GET_CHILD_RECURSIVELY(awframe, "count_text")
    count_text:SetText("{@st42}" .. itemcount .. "/" .. maxcount .. "{/}")
    count_text:SetFontName("white_16_ol")
end

function another_warehouse_check_search_and_filter(invItem, itemCls, search_text, typeStr)
    local makeSlot = true

    -- 検索テキストがある場合のみ、表示するかどうかを判定
    if search_text ~= "" then
        makeSlot = false -- デフォルトは非表示（一致するものだけを表示）
        local tempcap = string.lower(search_text)

        -- 1. アイテム名で検索
        local itemname = string.lower(dictionary.ReplaceDicIDInCompStr(itemCls.Name))
        if string.find(itemname, tempcap) then
            makeSlot = true
        end

        -- 2. アイテム名で見つからなかった場合、追加の検索ロジックを実行
        if not makeSlot then
            -- 2-a. 凡例装備のセット名で検索
            local prefixClassName = TryGetProp(itemCls, "LegendPrefix")
            if prefixClassName and prefixClassName ~= "None" then
                local prefixCls = GetClass('LegendSetItem', prefixClassName)
                if prefixCls then
                    local prefixName = string.lower(dictionary.ReplaceDicIDInCompStr(prefixCls.Name))
                    if string.find(prefixName .. " " .. itemname, tempcap) then
                        makeSlot = true
                    end
                end
            end
        end

        if not makeSlot then
            -- 2-b. イヤリングの特殊オプション名で検索
            if TryGetProp(itemCls, 'GroupName', 'None') == 'Earring' then
                local max_option_count = shared_item_earring.get_max_special_option_count(
                    TryGetProp(itemCls, 'UseLv', 1))
                for i = 1, max_option_count do
                    local option_name = 'EarringSpecialOption_' .. i
                    local job_id = TryGetProp(itemCls, option_name, 'None')
                    if job_id ~= 'None' then
                        local job_cls = GetClass('Job', job_id)
                        if job_cls and
                            string.find(string.lower(dictionary.ReplaceDicIDInCompStr(job_cls.Name)), tempcap) then
                            makeSlot = true
                            break
                        end
                    end
                end

                -- 2-c. アイカーのランダムオプション名で検索
            elseif TryGetProp(itemCls, 'GroupName', 'None') == 'Icor' then
                local item = GetIES(invItem:GetObject())
                for i = 1, 5 do
                    local option = TryGetProp(item, 'RandomOption_' .. i, 'None')
                    if option and option ~= "None" and
                        string.find(string.lower(dictionary.ReplaceDicIDInCompStr(ClMsg(option))), tempcap) then
                        makeSlot = true
                        break
                    end
                end
            end
        end
    end

    -- 検索で見つからなかった場合は、ここで終了
    if not makeSlot then
        return false
    end

    -- 最後に、インベントリの表示フィルタ（装備のみ表示など）をチェック
    local viewOptionCheck = 1
    if typeStr == "Equip" then
        viewOptionCheck = CHECK_INVENTORY_OPTION_EQUIP(itemCls)
    elseif typeStr == "Card" then
        viewOptionCheck = CHECK_INVENTORY_OPTION_CARD(itemCls)
    elseif typeStr == "Etc" then
        viewOptionCheck = CHECK_INVENTORY_OPTION_ETC(itemCls)
    elseif typeStr == "Gem" then
        viewOptionCheck = CHECK_INVENTORY_OPTION_GEM(itemCls)
    end

    return viewOptionCheck == 1
end
]===] --[[local function process_item_list(item_list, inv_item, inv_count)
    if not item_list then
        return
    end

    for _, item_data in pairs(item_list) do
        local cls_id = item_data.clsid
        local count = item_data.count

        if not g.putitemtbl[cls_id] and cls_id ~= 900011 then
            g.putitemtbl[cls_id] = {
                iesid = "",
                count = count
            }
        end

        if inv_item.type == cls_id and inv_count > 0 and cls_id ~= 900011 then
            if not g.takeitemtbl[cls_id] then
                g.takeitemtbl[cls_id] = {
                    iesid = inv_item:GetIESID(),
                    count = count
                }
                -- ここでループを抜けるのは、同じアイテムを重複してtakeリストに入れないためなので正しい
                break
            end
        end
    end
    -- この関数は何も返さない
end

function another_warehouse_item()
    g.takeitemtbl = {}
    g.putitemtbl = {}

    local login_cid = info.GetCID(session.GetMyHandle())
    local warehouse_frame = ui.GetFrame('accountwarehouse')
    local handle = warehouse_frame:GetUserIValue('HANDLE')
    local leave_one = (g.settings.leave == 1)

   
    local char_rules = {}
    if g.settings[login_cid] and g.settings[login_cid].setitems then
       
        for set_index, item_set in pairs(g.settings[login_cid].setitems) do
            for slot_index, cls_id in pairs(item_set) do
                -- ここでは個数(count)の情報がないため、デフォルト値(例: 1)を設定
                char_rules[tostring(cls_id)] = 1
            end
        end
    end

    -- 1-b: グローバルルール (itemsから)
    local global_rules = {}
    if g.settings.items then
        for _, item_data in ipairs(g.settings.items) do
            if item_data.clsid then
                global_rules[tostring(item_data.clsid)] = item_data.count or 1
            end
        end
    end

    -- 1-c: ルールを統合（キャラクター固有設定を優先）
    local rules = {}
    for cls_id, count in pairs(global_rules) do
        rules[cls_id] = count
    end
    for cls_id, count in pairs(char_rules) do
        rules[cls_id] = count
    end

    -- ★★★ ステップ2: 倉庫をスキャンし、「takeすべきアイテム」リストを作成 ★★★
    local warehouse_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sorted_guid_list = warehouse_list:GetSortedGuidList()
    for i = 0, sorted_guid_list:Count() - 1 do
        local guid = sorted_guid_list:Get(i)
        local warehouse_item = warehouse_list:GetItemByGuid(guid)
        local cls_id = tostring(warehouse_item.type)

        if rules[cls_id] then
            local take_count = leave_one and (warehouse_item.count - 1) or warehouse_item.count
            if take_count > 0 then
                g.takeitemtbl[cls_id] = {
                    iesid = guid,
                    count = rules[cls_id]
                }
            end
        end
    end

    -- ★★★ ステップ3: インベントリをスキャンし、「putすべきアイテム」と「takeの調整」を行う ★★★
    local inv_item_list = session.GetInvItemList()
    for i = 0, inv_item_list:GetGuidList():Count() - 1 do
        local guid = inv_item_list:GetGuidList():Get(i)
        local inv_item = inv_item_list:GetItemByGuid(guid)
        local inv_obj = GetIES(inv_item:GetObject())
        local inv_clsid = tostring(inv_obj.ClassID)

        if inv_obj.ClassName ~= MONEY_NAME then
            -- takeリストの調整
            if g.takeitemtbl[inv_clsid] then
                local needed_count = g.takeitemtbl[inv_clsid].count - inv_item.count
                if needed_count > 0 then
                    g.takeitemtbl[inv_clsid].count = needed_count
                else
                    g.takeitemtbl[inv_clsid] = nil
                end
            end

            -- putリストの作成
            if rules[inv_clsid] then
                local put_count = inv_item.count - rules[inv_clsid]
                if put_count > 0 then
                    g.putitemtbl[inv_clsid] = {
                        iesid = guid,
                        count = put_count,
                        invcount = inv_item.count
                    }
                end
            end
        end
    end

    -- ★★★ ステップ4: 同数のアイテムを除外 ★★★
    for cls_id, take_data in pairs(g.takeitemtbl) do
        if g.putitemtbl[cls_id] and take_data.count == g.putitemtbl[cls_id].count then
            g.putitemtbl[cls_id] = nil
        end
    end

    -- ★★★ ここからが確認用コード ★★★
    print("--- g.putitemtbl の内容 (除外処理後) ---")

    -- テーブルが空かどうかを先にチェック
    if not next(g.putitemtbl) then
        print("  (テーブルは空です)")
    else
        -- pairsでテーブルをループ
        for cls_id, item_data in pairs(g.putitemtbl) do
            -- まず、キーであるクラスIDを表示
            print(string.format("Key (cls_id): %s", tostring(cls_id)))

            -- 次に、値であるテーブルの中身を、インデントを付けて表示
            if type(item_data) == "table" then
                print(string.format("  - iesid: %s", tostring(item_data.iesid)))
                print(string.format("  - count: %s", tostring(item_data.count)))
                print(string.format("  - invcount: %s", tostring(item_data.invcount)))
            else
                -- 予期せぬデータ形式の場合
                print(string.format("  - Value: %s (予期せぬ形式)", tostring(item_data)))
            end
        end
    end

    print("--- 表示完了 ---")
    -- ★★★ 確認用コードはここまで ★★★

    another_warehouse_item_take()
end]] --[[function another_warehouse_base_item_list_create()

    g.item_list = {}
    local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local guidList = itemList:GetGuidList()
    local sortedGuidList = itemList:GetSortedGuidList()
    local sortedCnt = sortedGuidList:Count()
    local vis = false
    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local obj = GetIES(invItem:GetObject())
        local type = obj.ClassID
        if type == 900011 then
            g.item_list[0] = {
                count = invItem.count,
                guid = guid,
                type = type,
                name = obj.ClassName
            }
            vis = true
            break
        end
    end
    if vis == false then
        g.item_list[0] = {
            count = 0,
            guid = "0",
            type = 900011
        }
        vis = true
    end

    local item_index = 1
    for i = 0, sortedCnt - 1 do
        local guid = sortedGuidList:Get(i)
        local invItem = itemList:GetItemByGuid(guid)
        local obj = GetIES(invItem:GetObject())
        local type = obj.ClassID

        if type ~= 900011 then
            g.item_list[item_index] = {
                count = invItem.count,
                guid = guid,
                type = type,
                name = obj.ClassName
            }

            item_index = item_index + 1
        end
    end

end

function another_warehouse_base_accountwarehouse_open(frame, msg, str, num)
   

    ReserveScript("another_warehouse_base_item_list_create()", 0.5)

    local awframe = ui.GetFrame("accountwarehouse")
    local accountwarehouse_tab = GET_CHILD_RECURSIVELY(awframe, "accountwarehouse_tab")
    if accountwarehouse_tab ~= nil then
        awframe:RemoveChild("accountwarehouse_tab")
    end
    local slotgbox = GET_CHILD_RECURSIVELY(awframe, "slotgbox")
    if slotgbox ~= nil then
        awframe:RemoveChild("slotgbox")
    end

    local gbox = GET_CHILD_RECURSIVELY(awframe, "gbox")

    local slot_gbox = gbox:CreateOrGetControl("groupbox", "slot_gbox", 10, 110, 640, 428)
    AUTO_CAST(slot_gbox)
    slot_gbox:SetSkinName("test_frame_low")
    slot_gbox:EnableHitTest(1);
    slot_gbox:EnableDrawFrame(0);
    slot_gbox:SetGravity(ui.LEFT, ui.TOP)

    local accountObj = GetMyAccountObj();
    local max_count = accountObj.BasicAccountWarehouseSlotCount + accountObj.MaxAccountWarehouseCount +
                          accountObj.AccountWareHouseExtend + accountObj.AccountWareHouseExtendByItem +
                          ADDITIONAL_SLOT_COUNT_BY_TOKEN + 280
    local row = math.ceil(max_count / 10)
    local slot_set = slot_gbox:CreateOrGetControl('slotset', 'slot_set', 5, 0, 630, 240)
    AUTO_CAST(slot_set)

    slot_set:SetSlotSize(60, 60)
    slot_set:EnablePop(0)
    slot_set:EnableDrag(0)
    slot_set:EnableDrop(1)
    slot_set:SetMaxSelectionCount(999)
    slot_set:EnableSelection(1)

    slot_set:SetColRow(10, row)
    slot_set:SetSpc(1, 1)
    slot_set:SetSkinName('accountwarehouse_slot')
    slot_set:CreateSlots()

    local slot_count = slot_set:GetSlotCount()
end]] 

--[=[
function another_warehouse_setting_drop(parent, slot, str, num)
    --[[local lift_icon = ui.GetLiftIcon()
    local fromframe = lift_icon:GetTopParentFrame()]]
    local items = {}
    if parent:GetName() == "char_slotset" then
        items = g.awh_settings.items
    else
        items = g.awh_settings.chars[g.cid].items
    end
    local cls_id = tonumber(items[string.gsub(slot:GetName(), "slot", "")].clsid)
    local item_cls = GetClassByType("Item", cls_id)
    local index_str = string.gsub(slot:GetName(), "slot", "")
    if not index_str then
        return
    end
    for key, value in pairs(items) do
        if value.clsid == cls_id then
            ui.SysMsg(g.lang == "Japanese" and "既に登録済です" or "Already registered")
            return
        end
    end
    if item_cls.MaxStack > 1 then
        local awh_setting = ui.GetFrame(addon_name_lower .. "awh_setting")
        local msg = g.lang == "Japanese" and "インベントリに残す数を入力" or
                        "Enter the number to be left in the inventory"
        INPUT_NUMBER_BOX(awh_setting, msg, "another_warehouse_setting_item_count", 0, 0, tonumber(item_cls.MaxStack),
            cls_id, index_str, nil)
    else
        if not items[index_str] then
            items[index_str] = {
                clsid = cls_id,
                count = 0
            }
        end
        SET_SLOT_ITEM_CLS(slot, item_cls)
        another_warehouse_save_settings()
    end
end
function another_warehouse_auto_item_start(awh)
    local accountwarehouse = ui.GetFrame('accountwarehouse')
    local item_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sorted_guid_list = item_list:GetSortedGuidList()
    local sorted_cnt = sorted_guid_list:Count()
    g.awh_take_items = {}
    g.awh_put_items = {}
    for i = 0, sorted_cnt - 1 do
        local guid = sorted_guid_list:Get(i)
        local inv_item = item_list:GetItemByGuid(guid)
        local cls_id = inv_item.type
        local item_obj = GetIES(inv_item:GetObject()) -- leave_item
        local inv_count = g.awh_settings.etc.leave_item == 1 and inv_item.count - 1 or inv_item.count
        local is_match = false
        local char_items = g.awh_settings.chars[g.cid].items
        for str_index, item in pairs(char_items) do
            local char_clsid = item.clsid
            local char_clsid_str = tostring(char_clsid)
            local char_count = item.count
            if cls_id == char_clsid and cls_id ~= 900011 then
                -- Put初期化
                if not g.awh_put_items[char_clsid_str] then
                    g.awh_put_items[char_clsid_str] = {
                        iesid = "",
                        count = char_count
                    }
                end
                -- Take登録
                if inv_count > 0 then
                    g.awh_take_items[char_clsid_str] = {
                        iesid = guid,
                        count = char_count
                    }
                end
                is_match = true -- ■ マッチした
                break
            end

            --[[if cls_id == char_clsid and inv_count > 0 and cls_id ~= 900011 then
                g.awh_take_items[char_clsid_str] = {
                    iesid = guid,
                    count = char_count
                }
                break
            end]]
            if not is_match then
                local common_items = g.awh_settings.items
                for str_index, item in pairs(common_items) do
                    local common_clsid = item.clsid
                    local common_clsid_str = tostring(common_clsid)
                    local common_count = item.count

                    if cls_id == common_clsid and cls_id ~= 900011 then
                        -- Put初期化
                        if not g.awh_put_items[common_clsid_str] then
                            g.awh_put_items[common_clsid_str] = {
                                iesid = "",
                                count = common_count
                            }
                        end
                        -- Take登録
                        if inv_count > 0 then
                            g.awh_take_items[common_clsid_str] = {
                                iesid = guid,
                                count = common_count
                            }
                        end
                        break
                    end
                end

            end
        end
        local common_items = g.awh_settings.items
        for str_index, item in pairs(common_items) do
            local common_clsid = item.clsid
            local common_clsid_str = tostring(common_clsid)
            local common_count = item.count
            if cls_id == common_clsid and inv_count > 0 and cls_id ~= 900011 then
                g.awh_take_items[common_clsid_str] = {
                    iesid = guid,
                    count = common_count
                }
                break
            end
        end
    end
    local inv_item_list = session.GetInvItemList()
    local inv_guid_list = inv_item_list:GetGuidList()
    local inv_cnt = inv_guid_list:Count()
    for i = 0, inv_cnt - 1 do
        local guid = inv_guid_list:Get(i)
        local inv_item = inv_item_list:GetItemByGuid(guid)
        local inv_obj = GetIES(inv_item:GetObject())
        local inv_clsid = inv_obj.ClassID
        local inv_clsid_str = tostring(inv_clsid)
        if inv_clsid ~= 900011 then
            if g.awh_take_items[inv_clsid_str] then
                local take_data = g.awh_take_items[inv_clsid_str]
                local take_count = take_data.count - inv_item.count
                if take_count <= 0 then
                    g.awh_take_items[inv_clsid_str] = nil
                else
                    take_data.count = take_count
                end
            end
            local target_count = 0
            local is_target = false
            for _, item in pairs(g.awh_settings.chars[g.cid].items) do
                if item.clsid == inv_clsid then
                    target_count = item.count
                    is_target = true
                    break
                end
            end
            if not is_target then
                for _, item in pairs(g.awh_settings.items) do
                    if item.clsid == inv_clsid then
                        target_count = item.count
                        is_target = true
                        break
                    end
                end
            end
            if is_target then
                local put_count = inv_item.count - target_count
                if put_count > 0 then
                    g.awh_put_items[inv_clsid_str] = {
                        iesid = guid,
                        count = put_count,
                        invcount = inv_item.count
                    }
                end
            end
        end
    end
    for cls_id, _ in pairs(g.awh_take_items) do -- !
        if g.awh_put_items[cls_id] then
            g.awh_put_items[cls_id] = nil
        end
    end
    another_warehouse_item_take(awh)
end]=]

--[[function another_warehouse_ACCOUNTWAREHOUSE_OPEN(_nexus_addons)
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local accountwarehousefilter = GET_CHILD_RECURSIVELY(accountwarehouse, "accountwarehousefilter")
    accountwarehousefilter:SetMargin(490, 705)
    if accountwarehouse:IsVisible() == 1 then
        local inventory = ui.GetFrame("inventory")
        INVENTORY_SET_CUSTOM_RBTNDOWN("another_warehouse_inv_rbtn")
        SET_INV_LBTN_FUNC(inventory, "another_warehouse_inv_lbtn")
    end
    local delay = g.awh_settings.delay
    if g.awh_settings[g.cid].item_check == 1 then
        _nexus_addons:RunUpdateScript("another_warehouse_item", delay)
    end
    if g.awh_settings[g.cid].money_check == 1 then
        _nexus_addons:RunUpdateScript("another_warehouse_silver", delay * 2)
    end
end
function another_warehouse_find_activegbox(frame)

    for type_no = 1, #g_invenTypeStrList do
        local type_str = g_invenTypeStrList[type_no]
        if type_str ~= 'Quest' then
            local tree_box = GET_CHILD_RECURSIVELY(frame, 'inventree_' .. g_invenTypeStrList[type_no], 'ui::CGroupBox');
            if (tree_box:IsVisible() == 1) then

                return tree_box
            end
        end

    end

    return nil

end
function another_warehouse_get_slotset_name(baseidcls)

    local cls = baseidcls
    if cls == nil then
        return 'error'
    else
        local className = cls.ClassName
        if cls.MergedTreeTitle ~= "NO" then
            className = cls.MergedTreeTitle
        end
        return 'sset_' .. className
    end
endfunction another_warehouse_frame_update(awh, gb)
    gb:RemoveAllChild()
    local tree = gb:CreateOrGetControl("tree", "inventory_tree", 5, 10, 0, 0)
    AUTO_CAST(tree)
    tree:Clear()
    tree:InvalidateTree()
    tree:EnableDrawFrame(false)
    tree:EnableDrawTreeLine(false)
    tree:SetFitToChild(true, 20) -- 下の余白
    tree:SetFontName("white_20_ol")
    tree:SetTabWidth("20")
    tree:Resize(600, 0)
    local accountwarehouse = ui.GetFrame("accountwarehouse")
    local search_edit = GET_CHILD_RECURSIVELY(accountwarehouse, "search_edit")
    local search_text = search_edit:GetText()
    local group_counts = {}
    local slotset_counts = {}
    local item_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sorted_guid_list = item_list:GetSortedGuidList()
    local warehouse_item_list = {}
    for i = 0, sorted_guid_list:Count() - 1 do
        local warehouse_item = item_list:GetItemByGuid(sorted_guid_list:Get(i))
        if warehouse_item then
            table.insert(warehouse_item_list, warehouse_item)
            local item_cls = GetIES(warehouse_item:GetObject())
            local baseid_cls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(warehouse_item:GetIESID())
            if baseid_cls then
                local make_slot = another_warehouse_check_search_and_filter(warehouse_item, item_cls, search_text)
                if make_slot and warehouse_item.count > 0 and baseid_cls.ClassName ~= 'Unused' then
                    local group_name = baseid_cls.TreeGroup
                    group_counts[group_name] = (group_counts[group_name] or 0) + 1
                    local className = baseid_cls.ClassName
                    if baseid_cls.MergedTreeTitle ~= "NO" then
                        className = baseid_cls.MergedTreeTitle
                    end
                    local slotset_name = 'sset_' .. className
                    slotset_counts[slotset_name] = (slotset_counts[slotset_name] or 0) + 1
                end
            end
        end
    end
    table.sort(warehouse_item_list, INVENTORY_SORT_BY_NAME)
    local created_groups = {}
    local created_slotsets = {}
    local group_order = {"Premium", "EquipGroup", "NonEquipGroup", "Cube", "Gem", "Card", "Recipe", "Material",
                         "HiiddenAbility", "Ancient"}
    local group_caption_map = {}
    local baseid_list, cnt = GetClassList("inven_baseid")
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(baseid_list, i)
        if cls.TreeGroup ~= "None" then
            group_caption_map[cls.TreeGroup] = cls.TreeGroupCaption
        end
    end
    for _, group_name in ipairs(group_order) do
        local count = group_counts[group_name]
        if count and count > 0 then
            local caption = group_caption_map[group_name]
            if caption then
                local title_with_count = string.format("%s (%d)", caption, count)
                local tree_group = tree:Add(title_with_count, group_name)
                created_groups[group_name] = tree_group
            end
        end
    end
    for i = 0, cnt - 1 do
        local baseid_cls = GetClassByIndexFromList(baseid_list, i)
        local class_name = baseid_cls.ClassName
        if baseid_cls.MergedTreeTitle ~= "NO" then
            class_name = baseid_cls.MergedTreeTitle
        end
        local slotset_name = 'sset_' .. class_name
        local count = slotset_counts[slotset_name]
        if count and count > 0 and not created_slotsets[slotset_name] then
            local tree_group_name = baseid_cls.TreeGroup
            local tree_group = created_groups[tree_group_name]
            if not tree_group then
                local group_count = group_counts[tree_group_name] or 0
                local caption = baseid_cls.TreeGroupCaption
                local title_with_count = string.format("%s (%d)", caption, group_count)
                tree_group = tree:Add(title_with_count, tree_group_name)
                created_groups[tree_group_name] = tree_group
            end
            local margin_height = 5
            local margin_name = "margin_top_" .. slotset_name
            local margin = tree:CreateOrGetControl('richtext', margin_name, 0, 0, 400, margin_height)
            AUTO_CAST(margin)
            margin:EnableResizeByText(0)
            margin:SetText("")
            tree:Add(tree_group, margin, margin_name)
            local slotset_title_value = slotset_name .. "_title"
            local title_with_count = string.format("{s18}%s (%d)", baseid_cls.TreeSSetTitle, count)
            local slotset_node = tree:Add(tree_group, title_with_count, slotset_title_value)
            local new_slot_set = another_warehouse_make_inven_slotset(tree, slotset_name)
            tree:Add(tree_group, new_slot_set, slotset_name)
            created_slotsets[slotset_name] = new_slot_set
        end
    end
    for _, inv_item in ipairs(warehouse_item_list) do
        local item_cls = GetIES(inv_item:GetObject())
        local baseid_cls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(inv_item:GetIESID())
        if baseid_cls then
            local type_str = GET_INVENTORY_TREEGROUP(baseid_cls)
            if type_str ~= 'Quest' then
                local make_slot = another_warehouse_check_search_and_filter(inv_item, item_cls, search_text)
                if make_slot and inv_item.count > 0 and baseid_cls.ClassName ~= 'Unused' then
                    local class_name = baseid_cls.ClassName
                    if baseid_cls.MergedTreeTitle ~= "NO" then
                        class_name = baseid_cls.MergedTreeTitle
                    end
                    local slotset_name = 'sset_' .. class_name
                    local new_slot_set = created_slotsets[slotset_name]
                    if new_slot_set then
                        AUTO_CAST(new_slot_set)
                        local slot_count = new_slot_set:GetSlotCount()
                        local count = new_slot_set:GetUserIValue("SLOT_ITEM_COUNT")
                        while slot_count <= count do
                            new_slot_set:ExpandRow()
                            slot_count = new_slot_set:GetSlotCount()
                        end
                        local slot = new_slot_set:GetSlotByIndex(count)
                        new_slot_set:SetUserValue("SLOT_ITEM_COUNT", count + 1)
                        slot:ShowWindow(1)
                        slot:SetSkinName('invenslot2')
                        another_warehouse_insert_item_to_tree(gb, tree, slot, inv_item, item_cls, slotset_name,
                            baseid_cls)
                       
                    end
                end
            end
        end
    end
    for _, slotset in pairs(created_slotsets) do
        local row = math.ceil(slotset:GetSlotCount() / slotset:GetCol())
        local height = row * 54
        slotset:Resize(slotset:GetWidth(), height)
    end
    local bottom_margin = 10 -- 隙間の高
    for _, group_name in ipairs(group_order) do
        local tree_group = created_groups[group_name]
        if tree_group and tree:GetChildCount(tree_group) > 0 then
            local margin_name = 'margin_' .. group_name
            local margin = tree:CreateOrGetControl('richtext', margin_name, 0, 0, 400, bottom_margin)
            AUTO_CAST(margin)
            margin:EnableResizeByText(0)
            margin:SetText("")
            tree:Add(tree_group, margin, margin_name)
        end
    end
    tree:OpenNodeAll()
    local max_count = another_warehouse_get_maxcount()
    local item_count = another_warehouse_item_count()
    local count_text = GET_CHILD_RECURSIVELY(accountwarehouse, "count_text")
    AUTO_CAST(count_text)
    count_text:SetText("{@st42}" .. item_count .. "/" .. max_count .. "{/}")
    count_text:SetFontName("white_16_ol")
end]]

--[[local label_slot =
                        slot:CreateOrGetControl('slot', 'label_slot' .. inv_item:GetIESID(), 0, 0, 60, 63)
                    AUTO_CAST(label_slot)
                    local margin = label_slot:GetMargin();
                    label_slot:SetMargin(margin.left - 3, margin.top - 4, margin.right, margin.bottom)
                    local icon_label = CreateIcon(label_slot)
                    if baseid_cls.ClassName == 'Card_CardRed' then
                        icon_label:SetImage('red_cardslot1')
                    elseif baseid_cls.ClassName == 'Card_CardBlue' then
                        icon_label:SetImage('blue_cardslot1')
                    elseif baseid_cls.ClassName == 'Card_CardPurple' then
                        icon_label:SetImage('purple_cardslot1')
                    elseif baseid_cls.ClassName == 'Card_CardGreen' then
                        icon_label:SetImage('green_cardslot1')
                    elseif baseid_cls.ClassName == 'Card_CardLeg' then
                        icon_label:SetImage('legendopen_cardslot')
                    elseif baseid_cls.ClassName == 'Card_CardGoddess' then
                        icon_label:SetImage('legendopen_cardslot')
                    end]]
--[[local accountwarehouse = ui.GetFrame("accountwarehouse")
    for type_no = 1, #g_invenTypeStrList do
        if g_invenTypeStrList[type_no] ~= 'Quest' then
            local tree = gb:CreateOrGetControl("tree", g_invenTypeStrList[type_no], 50, 5, 0, 0) -- 50, 5, 605, 560)
            AUTO_CAST(tree)
            tree:Clear()
            tree:EnableDrawFrame(false)
            tree:SetFitToChild(true, 60)
            tree:SetFontName("white_20_ol")
            tree:SetTabWidth("30")
            tree:Resize(612, 565)
        end
    end
    local item_list = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE)
    local sorted_guid_list = item_list:GetSortedGuidList()
    local warehouse_item_list = {}
    for i = 0, sorted_guid_list:Count() - 1 do
        local warehouse_item = item_list:GetItemByGuid(sorted_guid_list:Get(i))
        if warehouse_item then
            table.insert(warehouse_item_list, warehouse_item)
        end
    end
    table.sort(warehouse_item_list, INVENTORY_SORT_BY_NAME)
    local categorized_items = {}
    for _, inv_item in ipairs(warehouse_item_list) do
        local item_cls = GetIES(inv_item:GetObject())
        local baseid_cls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(inv_item:GetIESID())
        if item_cls and baseid_cls then
            local title_name = baseid_cls.MergedTreeTitle ~= "NO" and baseid_cls.MergedTreeTitle or baseid_cls.ClassName
            if not categorized_items[title_name] then
                categorized_items[title_name] = {}
            end
            table.insert(categorized_items[title_name], inv_item)
        end
    end
    local baseid_cls_list, baseid_count = GetClassList("inven_baseid")
    local inven_title_name = {}
    for i = 0, baseid_count - 1 do
        local baseidcls = GetClassByIndexFromList(baseid_cls_list, i)
        local temp_title = baseidcls.MergedTreeTitle ~= "NO" and baseidcls.MergedTreeTitle or baseidcls.ClassName
        if table.find(inven_title_name, temp_title) == 0 then
            table.insert(inven_title_name, temp_title)
        end
    end
    local search_edit = GET_CHILD_RECURSIVELY(accountwarehouse, "search_edit")
    local search_text = search_edit:GetText()
    for _, category_name in ipairs(inven_title_name) do
        local items_in_category = categorized_items[category_name]
        if items_in_category then
            ts(category_name, items_in_category)
            for _, inv_item in ipairs(items_in_category) do
                local item_cls = GetIES(inv_item:GetObject())
                local baseid_cls = INV_GET_INVEN_BASEIDCLS_BY_ITEMGUID(inv_item:GetIESID())
                local type_str = GET_INVENTORY_TREEGROUP(baseid_cls)
                ts(type_str)
                local make_slot = another_warehouse_check_search_and_filter(inv_item, item_cls, search_text)
                if make_slot and inv_item.count > 0 and baseid_cls.ClassName ~= 'Unused' then
                    local tree = GET_CHILD(gb, type_str)
                    AUTO_CAST(tree)
                    another_warehouse_insert_item_to_tree(awh, tree, inv_item, item_cls, baseid_cls, type_str)
                end
            end
        end
    end
    for type_no = 1, #g_invenTypeStrList do
        if g_invenTypeStrList[type_no] ~= 'Quest' then
            local tree = GET_CHILD(gb, g_invenTypeStrList[type_no])
            AUTO_CAST(tree)
            local slot_set_name_list_count = ui.inventory.GetInvenSlotSetNameCount()
            for i = 1, slot_set_name_list_count do
                local get_slot_set_name = ui.inventory.GetInvenSlotSetNameByIndex(i - 1)
                local slotset = GET_CHILD_RECURSIVELY(tree, get_slot_set_name, 'ui::CSlotSet')
                if slotset ~= nil then
                    ui.InventoryHideEmptySlotBySlotSet(slotset)
                end
            end
            ADD_GROUP_BOTTOM_MARGIN(awh, tree)
            tree:OpenNodeAll();
            tree:SetEventScript(ui.LBUTTONDOWN, "INVENTORY_TREE_OPENOPTION_CHANGE")
            INVENTORY_CATEGORY_OPENCHECK(awh, tree)
        end
    end
    ts(1)

    --[[local active_tree_box = another_warehouse_find_activegbox(awh)
    ts(2)
    if active_tree_box then
        AUTO_CAST(active_tree_box)
        local savedPos = active_tree_box:GetUserIValue("INVENTORY_CUR_SCROLL_POS")
        active_tree_box:SetScrollPos(savedPos)
        active_tree_box:InvalidateScrollBar()
    end]]
--[[function another_warehouse_insert_item_to_tree(awh, tree, inv_item, item_cls, baseid_cls, type_str)
    local tree_group_name = baseid_cls.TreeGroup
    local tree_group = tree:FindByValue(tree_group_name)
    if tree:IsExist(tree_group) == 0 then
        tree_group = tree:Add(baseid_cls.TreeGroupCaption, baseid_cls.TreeGroup)
        local tree_node = tree:GetNodeByTreeItem(tree_group)
        tree_node:SetUserValue("BASE_CAPTION", baseid_cls.TreeGroupCaption)
    end
    local class_name = baseid_cls.ClassName
    if baseid_cls.MergedTreeTitle ~= "NO" then
        class_name = baseid_cls.MergedTreeTitle
    end
    local slotset_name = 'sset_' .. class_name
    local slotset_node = tree:FindByValue(tree_group, slotset_name)
    if tree:IsExist(slotset_node) == 0 then
        local slotsettitle = 'ssettitle_' .. baseid_cls.ClassName
        if baseid_cls.MergedTreeTitle ~= "NO" then
            slotsettitle = 'ssettitle_' .. baseid_cls.MergedTreeTitle
        end
        local new_slotset_name = MAKE_INVEN_SLOTSET_NAME(tree, slotsettitle, baseid_cls.TreeSSetTitle)
        local new_slots = another_warehouse_make_inven_slotset(tree, slotset_name)
        tree:Add(tree_group, new_slotset_name, slotsettitle)
        -- local slot_handle = tree:Add(tree_group, new_slotset_name, slotset_name)
        -- local slot_node = tree:GetNodeByTreeItem(slot_handle)
        -- ts(slot_node)
        -- slot_node:SetUserValue("IS_ITEM_SLOTSET", 1)
    end
    local slot_set = GET_CHILD_RECURSIVELY(tree, slotset_name, 'ui::CSlotSet')
    AUTO_CAST(slot_set)
    local slot_count = slot_set:GetSlotCount()
    local slot = nil
    local count = GET_SLOTSET_COUNT(tree, baseid_cls)
    while slot_count <= count do
        slot_set:ExpandRow()
        slot_count = slot_set:GetSlotCount()
    end
    slot = slot_set:GetSlotByIndex(count)
    UPDATE_INVENTORY_SLOT(slot, inv_item, item_cls)
    another_warehouse_DRAW_ITEM(awh, slotset_name, inv_item, slot, baseid_cls)
    SET_SLOTSETTITLE_COUNT(tree, baseid_cls, 1)
    slot:EnableDrag(0)
    slot:SetEventScript(ui.LBUTTONUP, "another_warehouse_on_lbutton")
    slot:SetEventScript(ui.RBUTTONUP, "another_warehouse_on_rbutton")
    slot_set:MakeSelectionList()
end

function another_warehouse_is_stack_new_item(class_id)
    for k, v in pairs(g.awh_new_stack_add_item) do
        if v == class_id then
            return true
        end
    end
    return false
end

function another_warehouse_DRAW_ITEM(awh, slotset_name, inv_item, slot, baseid_cls)
    slot:SetSkinName('invenslot2')
    local item_cls = GetIES(inv_item:GetObject())
    local icon_img = GET_ITEM_ICON_IMAGE(item_cls)
    if geItemTable.IsStack(item_cls.ClassID) == 1 and another_warehouse_is_stack_new_item(item_cls.ClassID) then
        slot:SetHeaderImage('new_inventory_icon')
    elseif geItemTable.IsStack(item_cls.ClassID) == 0 and
        another_warehouse_is_stack_new_item(item_cls.ClassID .. "_" .. inv_item:GetIESID()) then
        slot:SetHeaderImage('new_inventory_icon')
    else
        slot:SetHeaderImage('None')
    end
    local new_sset = GET_CHILD_RECURSIVELY(awh, slotset_name)
    SET_SLOT_IMG(slot, icon_img)
    SET_SLOT_COUNT(slot, inv_item.count)
    SET_SLOT_STYLESET(slot, item_cls)
    SET_SLOT_IESID(slot, inv_item:GetIESID())
    SET_SLOT_ITEM_TEXT_USE_INVCOUNT(slot, inv_item, item_cls, nil)
    slot:SetMaxSelectCount(inv_item.count)
    local icon = slot:GetIcon()
    icon:SetTooltipArg("accountwarehouse", inv_item.type, inv_item:GetIESID())
    SET_ITEM_TOOLTIP_TYPE(icon, item_cls.ClassID, item_cls, "accountwarehouse")
    SET_SLOT_ICOR_CATEGORY(slot, item_cls)
    if g.awh_settings.display_change == 1 then
        if baseid_cls.TreeGroup == "Recipe" then
            local recipe_cls = GetClass('Recipe', item_cls.ClassName)
            if recipe_cls ~= nil then
                local taget_item = GetClass("Item", recipe_cls.TargetItem)
                if taget_item then
                    local image = GET_ITEM_ICON_IMAGE(taget_item)
                    local recipe_pic = slot:CreateOrGetControl('picture', 'recipe_pic' .. inv_item:GetIESID(), 0, 0, 25,
                        25)
                    AUTO_CAST(recipe_pic)
                    recipe_pic:SetEnableStretch(1)
                    recipe_pic:SetGravity(ui.LEFT, ui.TOP)
                    recipe_pic:SetImage(image)
                    recipe_pic:SetTooltipArg("accountwarehouse", inv_item.type, inv_item:GetIESID())
                    SET_ITEM_TOOLTIP_TYPE(recipe_pic, taget_item.ClassID, taget_item, "accountwarehouse")
                end
            end
        end
        if string.find(baseid_cls.ClassName, "Card") and not string.find(baseid_cls.ClassName, "Summon") and
            not string.find(baseid_cls.ClassName, "CardAddExp") then
            local image = TryGetProp(item_cls, "TooltipImage", "None")
            if image ~= "None" then
                icon:Set(image, 'Item', inv_item.type, inv_item.invIndex, inv_item:GetIESID(), inv_item.count)
            end
        end
        if baseid_cls.ClassName == "Gem_GemSkill" then
            for i = 1, 4 do
                if TryGetProp(item_cls, 'RandomOption_' .. i, 'None') ~= 'None' and
                    TryGetProp(item_cls, 'RandomOptionValue_' .. i, 0) > 0 then
                    local star_pic =
                        slot:CreateOrGetControl('richtext', 'star_pic' .. inv_item:GetIESID(), 0, 0, 18, 18)
                    star_pic:SetText("{img star_mark 18 18}")
                    star_pic:SetGravity(ui.RIGHT, ui.TOP);
                end
            end
            local skill_cls = GetClass("Skill", TryGetProp(item_cls, 'SkillName', 'None'))
            if skill_cls then
                local image = "icon_" .. GET_ITEM_ICON_IMAGE(skill_cls)
                icon:Set(image, 'Item', inv_item.type, inv_item.invIndex, inv_item:GetIESID(), inv_item.count)
                local skill_pic = slot:CreateOrGetControl('picture', 'skill_pic' .. inv_item:GetIESID(), 0, 0, 35, 35)
                AUTO_CAST(skill_pic)
                local image = GET_ITEM_ICON_IMAGE(item_cls)
                skill_pic:SetEnableStretch(1)
                skill_pic:SetGravity(ui.LEFT, ui.TOP)
                skill_pic:SetImage(image)
            end
        elseif baseid_cls.ClassName == "Gem_High_Color" then
            local cls_name = item_cls.ClassName
            if string.find(cls_name, "540") then
                slot:SetSkinName("invenslot_pic_goddess")
            elseif string.find(cls_name, "520") then
                slot:SetSkinName("invenslot_legend")
            elseif string.find(cls_name, "500") then
                slot:SetSkinName("invenslot_unique")
            elseif string.find(cls_name, "480") then
                slot:SetSkinName("invenslot_rare")
            else
                slot:SetSkinName("invenslot_nomal")
            end
        end
        if string.find(baseid_cls.ClassName, "OPTMisc_GoddessIcor") then
            local cls_name = item_cls.ClassName
            local is_special = string.find(cls_name, "EP17") or string.find(cls_name, "Weapon2") or
                                   string.find(cls_name, "Armor2")
            if not is_special then
                slot:SetSkinName("invenslot_rare")
            end
        elseif string.find(baseid_cls.ClassName, "Armor") then
            local cls_name = item_cls.ClassName
            local is_special = string.find(cls_name, "EP17") or
                                   (string.find(cls_name, "EP16") and string.find(cls_name, "high")) or
                                   (string.find(cls_name, "EP13") and string.find(cls_name, "high2"))
            if not is_special and (string.find(cls_name, "belt") or string.find(cls_name, "shoulder")) then
                slot:SetSkinName("invenslot_rare")
            end
        end
    end
    if inv_item.hasLifeTime == true or TryGetProp(item_cls, 'ExpireDateTime', 'None') ~= 'None' then
        ICON_SET_ITEM_REMAIN_LIFETIME(icon, IT_ACCOUNT_WAREHOUSE)
        slot:SetFrontImage('clock_inven')
    else
        CLEAR_ICON_REMAIN_LIFETIME(slot, icon)
    end
end

function another_warehouse_check_search_and_filter(inv_item, item_cls, search_text)
    if search_text == "" then
        return true
    end
    local temp_cap = string.lower(search_text)
    local item_name = string.lower(dictionary.ReplaceDicIDInCompStr(item_cls.Name))
    if string.find(item_name, temp_cap) then
        return true
    end
    local prefix_class_name = TryGetProp(item_cls, "LegendPrefix")
    if prefix_class_name and prefix_class_name ~= "None" then
        local prefix_cls = GetClass('LegendSetItem', prefix_class_name)
        if prefix_cls then
            local prefix_name = string.lower(dictionary.ReplaceDicIDInCompStr(prefix_cls.Name))
            if string.find(prefix_name .. " " .. item_name, temp_cap) then
                return true
            end
        end
    end
    if TryGetProp(item_cls, 'GroupName', 'None') == 'Earring' then
        local max_option_count = shared_item_earring.get_max_special_option_count(TryGetProp(item_cls, 'UseLv', 1))
        for i = 1, max_option_count do
            local option_name = 'EarringSpecialOption_' .. i
            local job_id = TryGetProp(item_cls, option_name, 'None')
            if job_id ~= 'None' then
                local job_cls = GetClass('Job', job_id)
                if job_cls and string.find(string.lower(dictionary.ReplaceDicIDInCompStr(job_cls.Name)), temp_cap) then
                    return true
                end
            end
        end
    end
    if TryGetProp(item_cls, 'GroupName', 'None') == 'Icor' then
        local item = GetIES(inv_item:GetObject())
        for i = 1, 5 do
            local option = TryGetProp(item, 'RandomOption_' .. i, 'None')
            if option and option ~= "None" and
                string.find(string.lower(dictionary.ReplaceDicIDInCompStr(ClMsg(option))), temp_cap) then
                return true
            end
        end
    end
    return false
end

function characters_item_serch_get_sorted_sub_categories(items)
    local subcategories = {}
    local subcategory_list = {}
    local subcategory_order = {
        ["false"] = 1,
        ["equips"] = 2,
        ["warehouse"] = 3,
        ["Weapon"] = 4,
        ["Armor"] = 5,
        ["HairAcc"] = 6,
        ["Accessory"] = 7,
        ["nil"] = 8,
        ["Premium"] = 9,
        ["Look"] = 10,
        ["ChangeEquip"] = 11,
        ["Misc"] = 12,
        ["Consume"] = 13,
        ["Recipe"] = 14,
        ["Card"] = 15,
        ["Gem"] = 16,
        ["Ancient"] = 17,
        ["OPTMisc"] = 18,
        ["PHousing"] = 19
    }

    local function get_order(name)
        local order = subcategory_order[name]
        if order == nil then
            return 100 -- デフォルト値を設定
        else
            return order
        end
    end

    for i = 1, #items do
        local item = items[i]
        local category = item[5]
        local sub_category = item[6]

        if category == "warehouse" or category == "equips" then
            if not subcategories[category] then
                subcategories[category] = true
                table.insert(subcategory_list, category)
            end
        elseif category == "inventory" then
            if not subcategories[sub_category] then
                subcategories[sub_category] = true
                table.insert(subcategory_list, sub_category)
            end
        end
    end

    local function sort_subcategories(a, b)
        return get_order(a) < get_order(b)
    end

    table.sort(subcategory_list, sort_subcategories)
    return subcategory_list
end

--[[function another_warehouse_insert_item_to_tree(new_slots, clsid, item_count)
    local slot_count = new_slots:GetSlotCount()
    local count = new_slots:GetUserIValue("SLOT_ITEM_COUNT")
    while slot_count <= count do
        new_slots:ExpandRow()
        slot_count = new_slots:GetSlotCount()
    end
    local slot = new_slots:GetSlotByIndex(count)
    new_slots:SetUserValue("SLOT_ITEM_COUNT", count + 1)
    slot:ShowWindow(1)
    local item_cls = GetClassByType('Item', clsid)
    if item_cls then
        slot:SetSkinName('invenslot2')
        SET_SLOT_ITEM_CLS(slot, item_cls)
        SET_SLOT_BG_BY_ITEMGRADE(slot, item_cls)
        if item_count > 1 then
            SET_SLOT_COUNT_TEXT(slot, item_count, "{ol}{s14}")
        end
    end
end

function another_warehouse_make_inven_slotset(tree, name)
    local slotset = tree:CreateOrGetControl('slotset', name, 0, 0, 0, 0)
    AUTO_CAST(slotset)
    slotset:EnablePop(1)
    slotset:EnableDrag(1)
    slotset:EnableDrop(1)
    slotset:SetMaxSelectionCount(999)
    slotset:SetSlotSize(54, 54)
    slotset:SetColRow(10, 1)
    slotset:SetSpc(0, 0)
    slotset:SetSkinName('invenslot')
    slotset:EnableSelection(0)
    slotset:CreateSlots()
    ui.inventory.AddInvenSlotSetName(name)
    return slotset
end]]
--[[local tree_group_name = baseid_cls.TreeGroup

    local tree_group = tree:FindByValue(tree_group_name);

    if tree:IsExist(tree_group) == 0 then
        ts(tree_group_name, tree:IsExist(tree_group))
        -- another_warehouse_inven_slotset_and_title(tree, tree_group, tree_group_name, baseid_cls);
        tree_group = tree:Add(baseid_cls.TreeGroupCaption, baseid_cls.TreeGroup);
        local treeNode = tree:GetNodeByTreeItem(tree_group);
        treeNode:SetUserValue("BASE_CAPTION", baseid_cls.TreeGroupCaption)
    end

    local slotset_name = another_warehouse_get_slotset_name(baseid_cls)

    local slotset_node = tree:FindByValue(tree_group, slotset_name)

    if tree:IsExist(slotset_node) == 0 then
        ts(slotset_name, slotset_node, tree:IsExist(slotset_node))
       

        -- local newSlotsname = MAKE_INVEN_SLOTSET_NAME(tree, slotset_title, baseid_cls.TreeSSetTitle)

        another_warehouse_inven_slotset_and_title(tree, tree_group, slotset_name, baseid_cls);
    end]]

--[[function another_warehouse_setting_drop(parent, slot, str, num)
    local lift_icon = ui.GetLiftIcon()
    local fromframe = lift_icon:GetTopParentFrame()
    local fromslot = lift_icon:GetParent()
    local icon_info = lift_icon:GetInfo()
    local cls_id = icon_info.type
    local item_cls = GetClassByType("Item", cls_id)
    local slot_icon = slot:GetIcon()
    local guid = icon_info:GetIESID()
    local item = GET_ITEM_BY_GUID(guid)
    local obj = GetIES(item:GetObject())
    local index = tonumber(string.gsub(slot:GetName(), "slot", ""))
    if not index then
        return
    end
    if fromframe:GetName() == "inventory" then
        if item.isLockState == true then
            ui.SysMsg(ClMsg("MaterialItemIsLock"))
            return
        end
        if itemcls.ItemType == 'Quest' then
            ui.MsgBox(ScpArgMsg("IT_ISNT_REINFORCEABLE_ITEM"));
            return
        end
        local enable_team_trade = TryGetProp(item_cls, "TeamTrade")
        if enable_team_trade and enable_team_trade == "NO" then
            ui.SysMsg(ClMsg("ItemIsNotTradable"))
            return
        end
        local belonging_count = TryGetProp(obj, 'BelongingCount', 0)
        if belonging_count > 0 and belonging_count >= item.count then
            ui.SysMsg(ClMsg("ItemIsNotTradable"))
            return
        end
        if TryGetProp(obj, 'CharacterBelonging', 0) == 1 then
            ui.SysMsg(ClMsg("ItemIsNotTradable"))
            return
        end
    end
    local awh_setting = ui.GetFrame(addon_name_lower .. "awh_setting")
    if not slot_icon then
        local items = {}
        if slot:GetParent():GetName() == "char_slotset" then
            items = g.awh_settings.chars[g.cid].items
        else
            items = g.awh_settings.items
        end
        for key, value in pairs(items) do
            local clsid = value.clsid
            if cls_id == clsid then
                ui.SysMsg(g.lang == "Japanese" and "既に登録済です" or "Already registered")
                return
            end
        end
        slot:SetEventScript(ui.LBUTTONUP, "another_warehouse_setting_drop")
        if item_cls.MaxStack > 1 then
            awh_setting:SetUserValue("SLOT_NAME", slot:GetParent():GetName())
            local msg = g.lang == "Japanese" and "インベントリに残す数を入力" or
                            "Enter the number to be left in the inventory"
            INPUT_NUMBER_BOX(awh_setting, msg, "another_warehouse_setting_item_count", 0, 0,
                tonumber(item_cls.MaxStack), cls_id, tostring(index), nil)
        else
            if not items then
                items[tostring(index)] = {
                    clsid = cls_id,
                    count = 0
                }
            end
            SET_SLOT_ITEM_CLS(slot, item_cls)
            another_warehouse_save_settings()
        end
    end
end]]
