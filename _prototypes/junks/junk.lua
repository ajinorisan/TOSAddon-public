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
end]] --[=[
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
end]=] --[[function another_warehouse_ACCOUNTWAREHOUSE_OPEN(_nexus_addons)
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
end]] --[[local label_slot =
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
                    end]] --[[local accountwarehouse = ui.GetFrame("accountwarehouse")
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
    end]] --[[function another_warehouse_insert_item_to_tree(awh, tree, inv_item, item_cls, baseid_cls, type_str)
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
end]] --[[local tree_group_name = baseid_cls.TreeGroup

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
    end]] --[[function another_warehouse_setting_drop(parent, slot, str, num)
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
end]] --[[local _nexus_addons = ui.GetFrame("_nexus_addons")
        _nexus_addons:ShowWindow(1)
        local another_warehouse_timer = _nexus_addons:CreateOrGetControl("timer", "another_warehouse_timer", 0, 0)
        AUTO_CAST(another_warehouse_timer)
        another_warehouse_timer:SetUpdateScript("another_warehouse_token_Judgment")
        another_warehouse_timer:Start(1.0)]] --[[function another_warehouse_token_Judgment(_nexus_addons, another_warehouse_timer)
    if g.settings.another_warehouse.use == 0 then
        another_warehouse_timer:Stop()
        another_warehouse_frame_close()
        return
    end
    if session.loginInfo.IsPremiumState(ITEM_TOKEN) ~= true then
        g.awh_token = false
        local try = another_warehouse_timer:GetUserIValue("TRY")
        if try == 60 then
            ui.SysMsg(
                g.lang == "Japanese" and "[AWH]トークンが適用されていないため利用できません" or
                    "[AWH]is not available because the token has not been applied")
            g.awh_token = false
            another_warehouse_timer:Stop()
        end
        another_warehouse_timer:SetUserIValue("TRY", try + 1)
    else
        if not g.awh_token then
            ui.SysMsg("[AWH]ready")
            g.awh_token = true
        end
        another_warehouse_timer:Stop()
        another_warehouse_accountwarehouse_init()
    end
end]] --[[function monster_kill_count_ON_GAMEEXIT_TIMER_END(frame)
    local type = frame:GetUserValue("EXIT_TYPE")
    if type == "Exit" or type == "Logout" or type == "Barrack" or type == "Channel" then
        if g.monster_kill_count_map_id and g.monster_kill_count_map_data then
            local map_file_path = string.format("../addons/%s/%s/%s/%s.json", addon_name_lower, g.active_id,
                "monster_kill_count", g.monster_kill_count_map_id)
            if not g.monster_kill_count_diff_ms then
                g.monster_kill_count_diff_ms = imcTime.GetAppTimeMS() - g.monster_kill_count_start_time
            end
            g.monster_kill_count_map_data.stay_time = g.monster_kill_count_map_data.stay_time +
                                                          g.monster_kill_count_diff_ms
            g.save_json(map_file_path, g.monster_kill_count_map_data)
        end
    end
end]] --[[local setting = gbox:CreateOrGetControl("button", "setting", 150, 80, 30, 30)
        AUTO_CAST(setting)
        setting:SetSkinName("None")
        setting:SetText("{img config_button_normal 30 30}")
        setting:SetTextTooltip("{ol}}Left-click delay setting")
        setting:SetEventScript(ui.LBUTTONUP, "continue_reinforce_setting_context")]] --[[function continue_reinforce_setting_context()
    local context = ui.CreateContextMenu("SET_DELAY", "{ol}SET DELAY", 50, -200, 100, 100)
    for i = 1, 5 do
        local delay = i / 10
        local text =
            string.format(g.lang == "Japanese" and "{ol}ディレイ設定 %.1f" or "{ol}Set Delay %.1f", delay)
        ui.AddContextMenuItem(context, text, string.format("continue_reinforce_delay_save(%.1f)", delay))
    end
    ui.OpenContextMenu(context)
end

function continue_reinforce_delay_save(delay)
    local msg = string.format(g.lang == "Japanese" and "{ol}ディレイを %.1f 秒に設定しました" or
                                  "{ol}Delay is set to %.1f sec", delay)
    ui.SysMsg(msg)
    g.continue_reinforce.delay = tonumber(delay)
end]] --[[function characters_item_serch_ON_GAMEEXIT_TIMER_END()
    local gameexitpopup = ui.GetFrame("gameexitpopup")
    local type = gameexitpopup:GetUserValue("EXIT_TYPE")
    if type == "Exit" or type == "Logout" or type == "Barrack" then
        characters_item_serch_inventory_save_list()
    end
end]] --[[if string.sub(string.gsub(msg_body, "^%s*", ""), 1, 1) == "/" then
        native_lang_pass_through_chat(msg, msg)
        return
    end
    local org_msg_return = msg_body
    ts(2, msg)
    local processed_body = native_lang_msg_processing_send(msg_body)
    processed_body = string.gsub(processed_body, "Party#", "")
    if processed_body == "" then
        native_lang_pass_through_chat(msg, msg)
        return
    end
    if msg_type == " " then
        msg_type = ""
    end
    local line_to_send = string.format("%s:::%s:::%s", msg_type, org_msg_return, processed_body)
    local recv_file_handle = io.open(g.my_recv_dat_path, "r")
    if recv_file_handle then
        recv_file_handle:close()
        os.remove(g.my_recv_dat_path)
    end
    local tmp_send_path = g.my_send_dat_path .. ".tmp"
    local send_file, err = io.open(tmp_send_path, "w")
    if send_file then
        send_file:write(line_to_send)
        send_file:close()
        os.rename(tmp_send_path, g.my_send_dat_path)
    else
        print(string.format("Error opening %s for writing: %s", tmp_send_path, tostring(err)))
    end]] --[==[function test_norisan_REQ_PLAYER_CONTENTS_RECORD_()

    local buff = info.GetBuff(session.GetMyHandle(), 40049)
    if not buff then
        return 0
    end

    local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
    for i = 1, 40 do
        local slot = GET_CHILD_RECURSIVELY(quickslotnexpbar, "slot" .. i)
        AUTO_CAST(slot)
        local icon = slot:GetIcon()
        if icon then
            AUTO_CAST(icon)
            local icon_info = icon:GetInfo()
            if icon_info then
                local category = icon_info:GetCategory()
                if category == "Skill" then
                    local buff_id = icon_info.type
                    if buff_id == 100085 then
                        local current_cooldown = ICON_UPDATE_SKILL_COOLDOWN(icon)
                        if current_cooldown == 0 then
                            control.Skill(buff_id)
                        end
                        return 1
                    end
                end
            end
        end
    end

end

function test_norisan_DIALOG_ON_MSG(frame, msg, argstr, num)
    ts(msg, argstr, num)
    local dialog_frame = ui.GetFrame("dialog")
    AUTO_CAST(dialog_frame)
    ts(dialog_frame:GetUserIValue("DialogNewOpen"))
end

function test_norisan_TARGETSPACE_ON_MSG(frame, msg, argStr, argNum)

    local type = tonumber(config.GetXMLConfig("ControlMode"))
    TARGETSPACE_SET(frame, type)
    local handle = session.GetTargetHandle()
    local targetinfo = info.GetTargetInfo(handle)
    if not targetinfo or targetinfo.isDialog == 0 then
        return
    end
    ts(targetinfo.name)
    local frame = ui.GetFrame("targetSpace_" .. handle)
    if not frame then
        ui.CreateTargetSpace(handle)
        frame = ui.GetFrame("targetSpace_" .. handle)
    end
    if frame:IsVisible() == 1 then
        frame:ShowWindow(1)

        ui.UpdateCharBasePos(handle)

        local spaceObj = GET_CHILD(frame, "space", "ui::CAnimPicture");
        local LbtnObj = GET_CHILD(frame, 'mouseLbtn', 'ui::CPicture');
        local RbtnObj = GET_CHILD(frame, 'mouseRbtn', 'ui::CPicture');
        local joyBbtn = GET_CHILD(frame, 'joyBbtn', 'ui::CPicture');

        if type == 0 then
            if IsJoyStickMode() == 1 then
                spaceObj:ShowWindow(0)
                LbtnObj:ShowWindow(0)
                RbtnObj:ShowWindow(0)
                joyBbtn:ShowWindow(1)
            else
                local spaceMarkHeightOffset = 0
                local actor = world.GetActor(handle)
                if actor then
                    local cls = GetClassByType("Monster", actor:GetType())
                    if cls then
                        spaceMarkHeightOffset = TryGet(cls, "SpaceMarkHeightOffset")
                    end
                end
                spaceObj:SetMargin(0, 0, 0, spaceMarkHeightOffset)
                spaceObj:PlayAnimation()
                spaceObj:ShowWindow(1)
                LbtnObj:ShowWindow(0)
                RbtnObj:ShowWindow(0)
                joyBbtn:ShowWindow(0)
            end
        end
        local pc = GetMyPCObject();
        local dlgInfo = info.GetDialogInfo(handle)
        local dialog = dlgInfo:GetDialog()
        local actor = world.GetActor(handle)
        local classId = actor:GetType()
        local text = ""
        local titleName = ""
        if classId == 160065 then

            frame:RunUpdateScript("test_norisan_TARGETSPACE_SET_", 1.0)

        end
    end
end

function test_norisan_TARGETSPACE_SET_(frame)
    local dialog_frame = ui.GetFrame("dialog")
    AUTO_CAST(dialog_frame)
    local dialogselect = ui.GetFrame("dialogselect")
    AUTO_CAST(dialogselect)
    local try = dialog_frame:GetUserIValue("TRY")
    if try == 0 then
        local dialog_frame = ui.GetFrame("dialog")
        AUTO_CAST(dialog_frame)
        dialog_frame:SetUserValue("TRY", 1)
        DIALOG_TEXTVIEW(dialog_frame, 'DIALOG_CHANGE_SELECT', "MGame_EndPortal_Msg")
        dialog_frame:ShowWindow(1)
        dialog_frame:Invalidate()
        DIALOGSELECT_ITEM_ADD(dialogselect, "DIALOG_ADD_SELECT", "!@#$Auto_JongLyo#@!", 1)
        DIALOGSELECT_ITEM_ADD(dialogselect, "DIALOG_ADD_SELECT", "!@#$Event_Steam_YC_2#@!", 2)
        DIALOGSELECT_ITEM_ADD(dialogselect, "DIALOG_ADD_SELECT", "!@#$Event_Steam_YC_3#@!", 3)
        DIALOGSELECT_ITEM_ADD(dialogselect, "DIALOG_ADD_SELECT", "!@#$Event_Steam_YC_4#@!", 4)
        return 1
    else
        dialog_frame:SetUserValue("TRY", 0)
        session.SetSelectDlgList()
        dialogselect:ShowWindow(1)
        control.DialogSelect(1)
        control.DialogOk()
        return 0
    end

    --[[test_norisan_DIALOGSELECT_ITEM_ADD(dialogselect, "DIALOG_ADD_SELECT", "!@#$Auto_JongLyo#@!", 1)
    test_norisan_DIALOGSELECT_ITEM_ADD(dialogselect, "DIALOG_ADD_SELECT", "!@#$Event_Steam_YC_2#@!", 2)
    test_norisan_DIALOGSELECT_ITEM_ADD(dialogselect, "DIALOG_ADD_SELECT", "!@#$Event_Steam_YC_3#@!", 3)
    test_norisan_DIALOGSELECT_ITEM_ADD(dialogselect, "DIALOG_ADD_SELECT", "!@#$Event_Steam_YC_4#@!", 4)
    dialogselect:ShowWindow(1)]]

    --[[DIALOG_ON_SKIP(dialog_frame, "DIALOG_SKIP", "None", 0)
    control.DialogSelect(1)
    control.DialogOk()]]
end

function test_norisan_DIALOGSELECT_ITEM_ADD(frame, msg, argStr, argNum)
    if argNum == 1 then
        ts(0, DIALOGSELECT_QUEST_REWARD_ADD(frame, argStr))
        if DIALOGSELECT_QUEST_REWARD_ADD(frame, argStr) == 1 then
            frame:SetUserValue("FIRSTORDER_MAXHEIGHT", 1);
            return;
        else
            local questRewardBox = frame:GetChild('questreward');
            if questRewardBox ~= nil then
                frame:RemoveChild('questreward');
            end
        end
    end

    local questRewardBox = frame:GetChild('questreward');
    ts(questRewardBox)
    if questRewardBox ~= nil then
        argNum = argNum - 1;
    end

    local controlName = 'item' .. argNum .. 'Btn';
    local ItemBtn = GET_CHILD_RECURSIVELY(frame, controlName)
    local ItemBtnCtrl = tolua.cast(ItemBtn, 'ui::CButton')
    ItemBtnCtrl:SetGravity(ui.CENTER_HORZ, ui.TOP);
    ts(questRewardBox)
    if questRewardBox ~= nil then
        local width = questRewardBox:GetWidth();
        local height = questRewardBox:GetHeight();
        local offset = 10 + ((argNum - 1) * 40);
        local offsetEx = 20 + ((argNum) * 40);
        local y = tonumber(frame:GetUserValue("QUESTFRAME_HEIGHT"));
        local frameHeight = offset + y + 50;
        local maxHeight = ui.GetSceneHeight();

        questRewardBox:SetGravity(ui.CENTER_HORZ, ui.TOP);
        questRewardBox:SetOffset(0, 50);

        if frame:GetUserIValue("FIRSTORDER_MAXHEIGHT") == 1 then
            if (y + (maxHeight - frame:GetY())) > (maxHeight) then
                local frameMaxHeight = maxHeight / 2;
                frameHeight = offset + frameMaxHeight + 50;
                frame:SetUserValue("IsScroll", "YES");
                ItemBtnCtrl:SetOffset(0, questRewardBox:GetY() + questRewardBox:GetHeight() + 10);
            else
                frame:SetUserValue("IsScroll", "NO");
                ItemBtnCtrl:SetOffset(0, height + offset + 10 + ItemBtnCtrl:GetHeight());
            end
            frame:SetUserValue("FIRSTORDER_MAXHEIGHT", 0);
        else
            if frame:GetUserValue("IsScroll") == "NO" then
                height = y + ItemBtnCtrl:GetHeight();
                frameHeight = height + offset + 50;
                ItemBtnCtrl:SetOffset(0, height + offset + 10);
            else
                frameHeight = height + offsetEx + 50;
                ItemBtnCtrl:SetOffset(0, height + offsetEx);
            end
        end
        frame:Resize(frame:GetWidth(), frameHeight + 10);
        frame:ShowWindow(1);
    else
        ItemBtnCtrl:SetOffset(0, (argNum - 1) * 40 + 40);
        frame:Resize(frame:GetWidth(), (argNum + 1) * 40 + 10);
    end

    -- local eventScp = 'control.DialogSelect(' .. argNum .. ')'
    local eventScp = "control.DialogOk()"
    if session.IsMultipleSelect() == true then
        eventScp = 'DIALOGSELECT_MULTIPLE_SELECT_EVENT(' .. argNum .. ')';
    else
        if session.IsShowSelDlgMsgBox() == true then
            eventScp = string.format('DIALOGSELECT_CHECK_MSGBOX(%d)', argNum);
        end
    end
    ts('control.DialogSelect(' .. argNum .. ')')
    -- ItemBtnCtrl:SetEventScript(ui.LBUTTONUP, eventScp, true)
    ItemBtnCtrl:SetEventScript(ui.LBUTTONUP, eventScp)
    ItemBtnCtrl:ShowWindow(1);

    local s = string.find(argStr, "{img")
    local img = nil
    if s ~= nil then
        local e = string.find(argStr, "}")
        img = string.sub(argStr, s, e)
    end

    if img ~= nil then
        argStr = replace(argStr, img, '')
    end

    argStr = dic.getTranslatedStr(argStr)

    if img ~= nil then
        argStr = img .. argStr
    end

    ts('{s18}{b}{#2f1803}' .. argStr .. '{/}{/}{/}')
    ItemBtnCtrl:SetText('{s18}{b}{#2f1803}' .. argStr .. '{/}{/}{/}');

    if ItemBtnCtrl:GetWidth() > tonumber(frame:GetUserConfig("MAX_WIDTH")) then
        DIALOGSELECT_FIX_WIDTH(frame, ItemBtnCtrl:GetWidth());
    end
    ts('LAST')
    frame:Update();
    ts(1, 'LAST')
end

function test_norisan_REQ_PLAYER_CONTENTS_RECORD(frame, type)
    local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
    if not quickslotnexpbar then
        return
    end
    quickslotnexpbar:RunUpdateScript("test_norisan_REQ_PLAYER_CONTENTS_RECORD_", 0.1)
end

function test_norisan_party_marker_set(frame, msg, str, num)

    local party_list = session.party.GetPartyMemberList(PARTY_NORMAL)
    -- local party_list = session.party.GetPartyMemberList(PARTY_GUILD)
    if not party_list then
        return 1
    end
    if party_list:Count() <= 1 then
        return 1
    end

    local current_party = {}
    for i = 0, party_list:Count() - 1 do
        local member = party_list:Element(i)
        if member then
            local handle = member:GetHandle()
            if handle ~= 0 then
                current_party[tostring(handle)] = handle
            end
        end
    end

    local visible_party_members = {}
    local list, count = SelectObject(GetMyPCObject(), 1000, 'ALL')
    for i = 1, count do
        if list[i] then
            local handle = GetHandle(list[i])
            if info.IsPC(handle) == 1 then
                local handle_str = tostring(handle)
                if current_party[handle_str] then
                    visible_party_members[handle_str] = handle
                    local party_marker = ui.GetFrame("party_marker" .. handle_str)
                    if not party_marker then
                        party_marker = ui.CreateNewFrame("notice_on_pc", "party_marker" .. handle_str, 0, 0, 50, 50)
                        party_marker:SetSkinName("None")
                        party_marker:SetLayerLevel(80)
                        local pic = party_marker:CreateOrGetControl('picture', 'marker', 0, 0, 50, 50)
                        AUTO_CAST(pic)
                        pic:SetImage("friend_party")
                        pic:SetEnableStretch(1)
                    end
                    FRAME_AUTO_POS_TO_OBJ(party_marker, handle, -25, -70, 3, 1, 1)
                    party_marker:ShowWindow(1)
                else
                    local party_marker = ui.GetFrame("party_marker" .. handle_str)
                    if party_marker then
                        ui.DestroyFrame(party_marker)
                    end
                end
            end
        end
    end

    for handle_str, _ in pairs(current_party) do
        if not visible_party_members[handle_str] then
            local party_marker = ui.GetFrame("party_marker" .. handle_str)
            if party_marker then
                ui.DestroyFrame(party_marker)
            end
        end
    end
end

--[[function test_norisan_party_marker_set(frame, msg, str, num)

    local party_member_list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local party_count = party_member_list:Count()
    if party_count == 1 then
        return
    end
    local changed = false

    for i = 0, party_count - 1 do
        local party_member = party_member_list:Element(i)
        local member_handle = party_member:GetHandle()
        if not g.party_marker[tostring(member_handle)] then
            g.party_marker[tostring(member_handle)] = member_handle
            changed = true
        end
    end

    if not changed then
        return
    end
    local current_members = {}
    local list, count = SelectObject(GetMyPCObject(), 1000, 'ALL')
    for i = 1, count do
        local handle = GetHandle(list[i])
        if handle and info.IsPC(handle) == 1 then
            if g.party_marker[tostring(handle)] and g.party_marker[tostring(handle)] == handle then
                current_members[tostring(handle)] = true
                local party_marker = ui.GetFrame("party_marker" .. handle)
                if not party_marker then
                    party_marker = ui.CreateNewFrame("notice_on_pc", "party_marker" .. handle, 0, 0, 0, 0)
                    party_marker:SetSkinName("None")
                    party_marker:SetLayerLevel(80)
                    party_marker:Resize(50, 50)
                    local marker = party_marker:CreateOrGetControl('picture', 'marker', 0, 0, 50, 50)
                    AUTO_CAST(marker)
                    marker:SetImage("friend_party")
                    marker:SetEnableStretch(1)
                    FRAME_AUTO_POS_TO_OBJ(party_marker, handle, -party_marker:GetWidth() + 75, ---party_marker:GetWidth() / 2
                        -party_marker:GetHeight() - 20, 3, 1, 1)
                    party_marker:ShowWindow(1)
                end
            end
        end
    end
    for handle_str, _ in pairs(g.party_marker) do
        if not current_members[handle_str] then
            g.party_marker[handle_str] = nil
            local party_marker = ui.GetFrame("party_marker" .. handle_str)
            if party_marker then
                ui.DestroyFrame("party_marker" .. handle_str)
            end
            changed = true
        end
    end

end]]

--[[function test_norisan_party_marker_set(frame, msg, str, num)

    local party_member_list = session.party.GetPartyMemberList(PARTY_NORMAL)
    local party_count = party_member_list:Count()
    if party_count == 1 then
        return
    end
    local changed = false

    for i = 0, party_count - 1 do
        local party_member = party_member_list:Element(i)
        local member_handle = party_member:GetHandle()

        if not g.party_marker[tostring(member_handle)] then
            g.party_marker[tostring(member_handle)] = member_handle
            changed = true
        end
    end

    if not changed then
        return
    end
    local current_members = {}
    local list, count = SelectObject(GetMyPCObject(), 1000, 'ALL')
    for i = 1, count do
        local handle = GetHandle(list[i])
        if handle and info.IsPC(handle) == 1 then
            if g.party_marker[tostring(handle)] and g.party_marker[tostring(handle)] == handle then
                current_members[tostring(handle)] = true
                local party_marker = ui.GetFrame("party_marker" .. handle)
                if not party_marker then
                    party_marker = ui.CreateNewFrame("notice_on_pc", "party_marker" .. handle, 0, 0, 0, 0)
                    party_marker:SetSkinName("None")
                    party_marker:SetLayerLevel(80)
                    party_marker:Resize(50, 50)
                    local marker = party_marker:CreateOrGetControl('picture', 'marker', 0, 0, 50, 50)
                    AUTO_CAST(marker)
                    marker:SetImage("friend_party")
                    marker:SetEnableStretch(1)
                    FRAME_AUTO_POS_TO_OBJ(party_marker, handle, -party_marker:GetWidth() + 75, ---party_marker:GetWidth() / 2
                        -party_marker:GetHeight() - 20, 3, 1, 1)
                    party_marker:ShowWindow(1)
                end
            end
        end
    end
    for handle_str, _ in pairs(g.party_marker) do
        if not current_members[handle_str] then
            g.party_marker[handle_str] = nil
            local party_marker = ui.GetFrame("party_marker" .. handle_str)
            if party_marker then
                ui.DestroyFrame("party_marker" .. handle_str)
            end
            changed = true
        end
    end

end]]

--[[function g.split(input_str, separator)
    local parts = {}
    local start_pos = 1
    while true do
        local sep_start, sep_end = string.find(input_str, separator, start_pos, true)
        if not sep_start then
            table.insert(parts, string.sub(input_str, start_pos))
            break
        end
        table.insert(parts, string.sub(input_str, start_pos, sep_start - 1))
        start_pos = sep_end + 1
    end
    return parts
end

function g.load_dat(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*all")
    file:close()
    if content == "" or content == nil then
        return {}
    end
    local records = {}
    for line in content:gmatch("([^\n]+)") do
        if line ~= "" then
            local parts = g.split(line, ":::")
            if #parts == 7 then
                table.insert(records, parts)
            end
        end
    end
    return records
end

function test_norisan_INDUNINFO_UI_CLOSE()
    local induninfo = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(induninfo, "rankListBox")
    AUTO_CAST(rankListBox)
    if rankListBox:HaveUpdateScript("test_norisan_get_weekly_boss_data") == false then
        return
    end
    rankListBox:StopUpdateScript("test_norisan_get_weekly_boss_data")
    rankListBox:StopUpdateScript("test_norisan_get_weekly_boss_damage")
    local induninfo_class_selector = ui.GetFrame("induninfo_class_selector")
    induninfo_class_selector:SetEnable(1)
    local msg = g.lang == "Japanese" and
                    "データ取得処理を終了します{nl}データは保存出来ていません" or
                    "Data acquisition process terminated{nl}The data could not be saved"
    imcAddOn.BroadMsg("NOTICE_Dm_!", msg, 3.0)
end

function test_norisan_WEEKLYBOSS_PATTERNINFO_UI_UPDATE(frame, msg, str, num)
    local induninfo = ui.GetFrame("induninfo")
    local rank_gb = GET_CHILD_RECURSIVELY(induninfo, "rank_gb")
    local data_btn = rank_gb:CreateOrGetControl('button', 'data_btn', -4, 300, 52, 52)
    AUTO_CAST(data_btn)
    data_btn:SetSkinName("None")
    data_btn:SetText("{img indun_season_tap 52 52}")
    local tooltip = g.lang == "Japanese" and "{ol}データ取得" or "{ol}Data Acquisition"
    data_btn:SetTextTooltip(tooltip)
    local data_btn_text = data_btn:CreateOrGetControl('richtext', 'data_btn_text', 10, 15, 0, 20)
    AUTO_CAST(data_btn_text)
    data_btn_text:SetText("{ol}data")
    data_btn_text:SetTextTooltip(tooltip)
    data_btn_text:SetEventScript(ui.LBUTTONUP, "test_norisan_get_weekly_boss_data_context")
    data_btn:SetEventScript(ui.LBUTTONUP, "test_norisan_get_weekly_boss_data_context")
    local rank_btn = rank_gb:CreateOrGetControl('button', 'rank_btn', -4, 354, 52, 52)
    AUTO_CAST(rank_btn)
    rank_btn:SetSkinName("None")
    rank_btn:SetText("{img indun_season_tap 52 52}") -- tab2
    local tooltip = g.lang == "Japanese" and "{ol}ランキング表示" or "{ol}Show Leaderboard"
    rank_btn:SetTextTooltip(tooltip)
    local rank_btn_text = rank_btn:CreateOrGetControl('richtext', 'rank_btn_text', 10, 15, 0, 20)
    AUTO_CAST(rank_btn_text)
    rank_btn_text:SetText("{ol}rank")
    rank_btn_text:SetTextTooltip(tooltip)
    rank_btn_text:SetEventScript(ui.LBUTTONUP, "test_norisan_create_ranking_data")
    rank_btn:SetEventScript(ui.LBUTTONUP, "test_norisan_create_ranking_data")
end

local base_jobids = {1001, 2001, 3001, 4001, 5001}
local processed_job_ids = {}
local result_tbl = {}
local existing_data_check = {}
local start_time = 0

function test_norisan_create_ranking_data()
    local induninfo = ui.GetFrame("induninfo")
    local file_path = string.format("../addons/%s/log.dat", addon_name_lower)
    local log_data = g.load_dat(file_path)
    if not log_data then
        local msg = g.lang == "Japanese" and
                        "ランキングデータが未取得です{nl}ランキングデータを取得してください" or
                        "Ranking data has not been acquired{nl}Please acquire the ranking data"
        ui.SysMsg(msg)
        return
    end
    local week_num = session.weeklyboss.GetNowWeekNum()
    local season_tab = GET_CHILD_RECURSIVELY(induninfo, "season_tab")
    local season_index = season_tab:GetSelectItemIndex()
    local season = week_num - season_index
    local is_save = true
    local checked_jobs = {}
    local all_derived_jobs = {}
    local function get_base_jobid_local(job_cls_id)
        if not job_cls_id then
            return nil
        end
        return job_cls_id - (job_cls_id % 1000) + 1
    end
    for _, base_id in ipairs(base_jobids) do
        local job_list = GET_JOB_LIST(base_id)
        for _, job_cls in ipairs(job_list) do
            local job_id = TryGetProp(job_cls, "ClassID", 0)
            if job_id ~= 0 and job_id % 100 ~= 1 then
                all_derived_jobs[job_id] = false -- チェックリストをfalseで初期化
            end
        end
    end
    for _, record in ipairs(log_data) do
        local week_num_ = tonumber(record[1])
        if week_num_ == season then
            local job_id = tonumber(record[2])
            local is_confirmed_str = record[7]
            if is_confirmed_str == "false" then
                is_save = false
                break
            end
            if all_derived_jobs[job_id] ~= nil then
                all_derived_jobs[job_id] = true
            end
        end
    end
    if is_save then
        for job_id, checked in pairs(all_derived_jobs) do
            if not checked then
                is_save = false
                break
            end
        end
    end
    local player_data = {}
    for _, record in ipairs(log_data) do
        local week_num_ = tonumber(record[1])
        if week_num_ == season then
            local job_id = tonumber(record[2])
            local name = record[4]
            local damage = tonumber(record[5])
            if not player_data[name] then
                player_data[name] = {
                    all_jobs = {},
                    max_damage = 0
                }
            end
            if #player_data[name].all_jobs < 4 then
                local found = false
                for _, existing_id in ipairs(player_data[name].all_jobs) do
                    if existing_id == job_id then
                        found = true;
                        break
                    end
                end
                if not found then
                    table.insert(player_data[name].all_jobs, job_id)
                end
            end
            if damage > player_data[name].max_damage then
                player_data[name].max_damage = damage
            end
        end
    end
    local ranking_list = {}
    for name, data in pairs(player_data) do
        table.insert(ranking_list, {
            name = name,
            damage = data.max_damage,
            all_jobs = data.all_jobs
        })
    end
    table.sort(ranking_list, function(a, b)
        return a.damage > b.damage
    end)
    local display_data_list = {}
    for i, data in ipairs(ranking_list) do
        if i > 100 then
            break
        end
        local base_job_id = nil
        local derived_jobs = {}
        local base_id_counts = {}
        for _, job_id in ipairs(data.all_jobs) do
            if job_id % 100 == 1 then
                base_job_id = job_id
            else
                table.insert(derived_jobs, job_id)
                local b_id = get_base_jobid_local(job_id)
                if b_id then
                    base_id_counts[b_id] = (base_id_counts[b_id] or 0) + 1
                end
            end
        end
        if not base_job_id and #derived_jobs > 0 then
            local max_count = 0
            for b_id, count in pairs(base_id_counts) do
                if count > max_count then
                    max_count = count
                    base_job_id = b_id
                end
            end
        end
        local build_parts = {}
        if base_job_id then
            table.insert(build_parts, base_job_id)
        end
        for _, job_id in ipairs(derived_jobs) do
            table.insert(build_parts, job_id)
        end
        table.insert(display_data_list, {
            season = season,
            rank = i,
            name = data.name,
            damage = data.damage,
            build = build_parts
        })
        local build_str = table.concat(build_parts, ", ")
    end
    test_norisan_create_ranking_data_frame(display_data_list, is_save)
end

function test_norisan_ranking_close(frame)
    local frame_name = frame:GetName()
    ui.DestroyFrame(frame_name)
end

function test_norisan_create_ranking_data_frame(ranking_data, is_save)
    if not ranking_data or #ranking_data == 0 then
        local msg = g.lang == "Japanese" and
                        "ランキングデータが未取得です{nl}ランキングデータを取得してください" or
                        "Ranking data has not been acquired{nl}Please acquire the ranking data"
        ui.SysMsg(msg)
        -- print("ランキングデータがありません。")
        return
    end
    local induninfo = ui.GetFrame("induninfo")
    local rank_frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "rank_frame", 0, 0, 0, 0)
    AUTO_CAST(rank_frame)
    rank_frame:SetSkinName("test_frame_low")
    rank_frame:SetLayerLevel(102)
    rank_frame:EnableHittestFrame(1)
    rank_frame:ShowTitleBar(0)
    rank_frame:RemoveAllChild()
    local season = ranking_data[1].season
    local status_text = ""
    if is_save == false then
        status_text = " (Unconfirmed)"
    else
        status_text = " (Confirmed)"
    end
    local title = rank_frame:CreateOrGetControl("richtext", "title", 30, 10)
    AUTO_CAST(title)
    title:SetText("{@st66b18}Weekly Ranking [" .. season .. "] week" .. status_text)
    local gbox = rank_frame:CreateOrGetControl("groupbox", "gbox", 10, 30, 0, 0)
    AUTO_CAST(gbox)
    gbox:SetSkinName("bg")
    local close = rank_frame:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetSkinName("None")
    close:SetText("{img testclose_button 30 30}")
    close:SetEventScript(ui.LBUTTONUP, "test_norisan_ranking_close")
    local y = 10
    local max_rank_width = 0
    local max_name_width = 0
    local max_damage_width = 0
    local temp_rank_text = gbox:CreateOrGetControl("richtext", "temp_rank", 0, 0)
    temp_rank_text:SetText("100.")
    max_rank_width = temp_rank_text:GetWidth()
    temp_rank_text:ShowWindow(0)
    for i, data in ipairs(ranking_data) do
        local temp_name_text = gbox:CreateOrGetControl("richtext", "temp_name_" .. i, 0, 0)
        temp_name_text:SetText("{ol}" .. data.name)
        if temp_name_text:GetWidth() > max_name_width then
            max_name_width = temp_name_text:GetWidth()
        end
        temp_name_text:ShowWindow(0)
        local temp_damage_text = gbox:CreateOrGetControl("richtext", "temp_damage_" .. i, 0, 0)
        temp_damage_text:SetText(string.format("Damage: %d", data.damage))
        if temp_damage_text:GetWidth() > max_damage_width then
            max_damage_width = temp_damage_text:GetWidth()
        end
        temp_damage_text:ShowWindow(0)
    end
    local rank_col_x = 10
    local name_col_x = rank_col_x + max_rank_width
    local icon_col_x = name_col_x + max_name_width
    local damage_col_x = icon_col_x + (4 * 25) - 10
    for i, data in ipairs(ranking_data) do
        local rank_text = gbox:CreateOrGetControl("richtext", "rank_" .. i, rank_col_x, y)
        AUTO_CAST(rank_text)
        rank_text:SetText("{ol}" .. string.format("%d.", data.rank))
        local name_text = gbox:CreateOrGetControl("richtext", "name_" .. i, name_col_x, y)
        AUTO_CAST(name_text)
        name_text:SetText("{ol}" .. data.name)
        local icon_x = icon_col_x
        for j, job_id in ipairs(data.build) do
            if j > 4 then
                break
            end
            local job_cls = GetClassByType('Job', job_id)
            if job_cls then
                local job_icon = gbox:CreateOrGetControl('picture', 'job_icon_' .. i .. '_' .. j, icon_x, y - 5, 25, 25)
                AUTO_CAST(job_icon)
                job_icon:SetImage(job_cls.Icon)
                job_icon:SetEnableStretch(1)
                job_icon:EnableHitTest(1)
                job_icon:SetTooltipType('adventure_book_job_info')
                job_icon:SetTooltipArg(job_id, 0, 0)
                icon_x = icon_x + 25
            end
        end
        local damage_text = gbox:CreateOrGetControl("richtext", "damage_" .. i, damage_col_x, y)
        AUTO_CAST(damage_text)
        damage_text:SetText("{ol}" .. GET_COMMAED_STRING(data.damage))
        local text_width = damage_text:GetWidth()
        local centered_x = damage_col_x + (max_damage_width - text_width) / 2
        damage_text:SetPos(centered_x, y)
        y = y + 30
    end
    local max_x = damage_col_x + max_damage_width
    rank_frame:SetPos(induninfo:GetX() + 20, induninfo:GetY() + 20)
    rank_frame:Resize(max_x + 20, 550)
    gbox:Resize(rank_frame:GetWidth() - 20, rank_frame:GetHeight() - 40)
    gbox:EnableScrollBar(1)
    gbox:SetScrollPos(0);
    rank_frame:ShowWindow(1)
end

function test_norisan_get_weekly_boss_data_context(frame, ctrl, str, num)
    local context = ui.CreateContextMenu("weekly_boss_data", "{ol}WEEKLY BOSS DATA", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "four weeks", "None")
    for i = 1, #base_jobids do
        local scp = string.format("test_norisan_get_weekly_boss_data_reserve(%d, 1)", base_jobids[i])
        local job_cls = GetClassByType('Job', base_jobids[i])
        ui.AddContextMenuItem(context, job_cls.Name .. " (Data takes about 120 sec)", scp)
    end
    local scp_all_four = string.format("test_norisan_get_weekly_boss_data_reserve(1, 1)")
    ui.AddContextMenuItem(context, "data for all classes (Data takes about 600 sec)", scp_all_four)
    ui.AddContextMenuItem(context, "This week", "None")
    for i = 1, #base_jobids do
        local scp = string.format("test_norisan_get_weekly_boss_data_reserve(%d, 0)", base_jobids[i])
        local job_cls = GetClassByType('Job', base_jobids[i])
        ui.AddContextMenuItem(context, job_cls.Name .. " (Data takes about 30 sec)", scp)
    end
    local scp_all_this = string.format("test_norisan_get_weekly_boss_data_reserve(0, 0)")
    ui.AddContextMenuItem(context, "data for all classes (Data takes about 150 sec)", scp_all_this)
    ui.OpenContextMenu(context)
end

function test_norisan_save_log()
    local file_path = string.format("../addons/%s/log.dat", addon_name_lower)
    local existing_records = g.load_dat(file_path) or {}
    local new_records_check = {}
    for _, new_record in ipairs(result_tbl) do
        local week_str = tostring(new_record[1])
        local job_id_str = tostring(new_record[2])
        if not new_records_check[week_str] then
            new_records_check[week_str] = {}
        end
        new_records_check[week_str][job_id_str] = true
    end
    local final_records_to_save = {}
    if #existing_records > 0 then
        for _, old_record in ipairs(existing_records) do
            local old_week_str, old_job_id_str = old_record[1], old_record[2]
            if not (new_records_check[old_week_str] and new_records_check[old_week_str][old_job_id_str]) then
                table.insert(final_records_to_save, old_record)
            end
        end
    end
    for _, new_record in ipairs(result_tbl) do
        table.insert(final_records_to_save, new_record)
    end
    local lines_to_write = {}
    for _, record in ipairs(final_records_to_save) do
        table.insert(lines_to_write, table.concat(record, ":::"))
    end
    local content_to_write = table.concat(lines_to_write, "\n")
    local file = io.open(file_path, "w")
    if file then
        file:write(content_to_write)
        file:close()
        -- print("log.datに結果を保存しました。")
    else
        -- print("エラー: log.datを開けませんでした。")
    end
end

function test_norisan_get_weekly_boss_data_reserve(base_job_id, is_four_weeks)
    result_tbl = {}
    processed_job_ids = {}
    local induninfo = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(induninfo, "rankListBox")
    AUTO_CAST(rankListBox)
    rankListBox:SetUserValue("MODE_BASE_ID", base_job_id)
    rankListBox:SetUserValue("MODE_IS_4W", is_four_weeks)
    rankListBox:SetUserValue("B_IDX", 1)
    rankListBox:SetUserValue("C_IDX", 1)
    rankListBox:SetUserValue("W_IDX", 0)
    rankListBox:SetUserValue("SHOULD_SAVE", 0)
    start_time = os.clock()
    local file_path = string.format("../addons/%s/log.dat", addon_name_lower)
    local loaded_data = g.load_dat(file_path)
    if loaded_data then
        for _, record in ipairs(loaded_data) do
            local week_str = record[1]
            local job_id_str = record[2]
            local is_confirmed_str = record[7]
            if is_confirmed_str == "true" then
                processed_job_ids[week_str .. job_id_str] = true
            end
        end
    end
    local induninfo_class_selector = ui.GetFrame("induninfo_class_selector")
    induninfo_class_selector:SetEnable(0)
    local msg = g.lang == "Japanese" and
                    "データ取得を開始します{nl}フレームを閉じずに暫くお待ちください" or
                    "Starting data acquisition{nl}Please wait a moment without closing the frame"
    imcAddOn.BroadMsg("NOTICE_Dm_!", msg, 3.0)
    test_norisan_get_weekly_boss_data(rankListBox)
    rankListBox:RunUpdateScript("test_norisan_get_weekly_boss_data", 1.2)
end

function test_norisan_get_weekly_boss_data(rankListBox)
    local mode_base_id = rankListBox:GetUserIValue("MODE_BASE_ID")
    local mode_is_4w = rankListBox:GetUserIValue("MODE_IS_4W")
    local b_idx = rankListBox:GetUserIValue("B_IDX")
    local c_idx = rankListBox:GetUserIValue("C_IDX")
    local w_idx = rankListBox:GetUserIValue("W_IDX")
    if w_idx == 0 and b_idx == 1 and c_idx == 1 then
        local induninfo = ui.GetFrame("induninfo")
        local season_tab = GET_CHILD_RECURSIVELY(induninfo, "season_tab")
        season_tab:SelectTab(0)
        rankListBox:SetUserValue("CURRENT_WEEK_NUM", WEEKLY_BOSS_RANK_WEEKNUM_NUMBER())
    end
    local current_week_num = rankListBox:GetUserIValue("CURRENT_WEEK_NUM")
    local target_base_jobids
    local is_all_classes_mode = false
    if mode_base_id == 0 or mode_base_id == 1 then
        target_base_jobids = base_jobids
        is_all_classes_mode = true
    else
        target_base_jobids = {mode_base_id}
    end
    local num_weeks = (mode_base_id == 1 or mode_is_4w == 1) and 4 or 1
    if w_idx >= num_weeks then
        local induninfo_class_selector = ui.GetFrame("induninfo_class_selector")
        if induninfo_class_selector:IsVisible() == 1 then
            local classList = GET_CHILD_RECURSIVELY(induninfo_class_selector, "classList")
            if classList then
                AUTO_CAST(classList);
                classList:SetScrollPos(0);
            end
            INDUNINFO_CLASS_SELECTOR_UI_CLOSE(induninfo_class_selector)
        end
        induninfo_class_selector:SetEnable(1)
        local end_time = os.clock()
        local elapsed_time = end_time - start_time
        print(string.format("処理が完了しました。所要時間: %.2f 秒", elapsed_time)) -- !
        return 0
    end
    local current_base_jobid = target_base_jobids[b_idx]
    local job_list = GET_JOB_LIST(current_base_jobid)
    local job_cls = job_list[c_idx]
    local next_b_idx, next_c_idx, next_w_idx = b_idx, c_idx + 1, w_idx
    local should_save_flag = 0
    if next_c_idx > #job_list then
        next_c_idx = 1
        next_b_idx = b_idx + 1
        if is_all_classes_mode then
            should_save_flag = 1
        end
    end
    if next_b_idx > #target_base_jobids then
        next_b_idx = 1
        next_c_idx = 1
        next_w_idx = w_idx + 1
        if not is_all_classes_mode then
            should_save_flag = 1
        end
    end
    if job_cls then
        local job_cls_id = TryGetProp(job_cls, "ClassID", 0)
        local week_offset = (num_weeks == 4) and (3 - w_idx) or 0
        local week_num = current_week_num - week_offset
        local key_to_check = tostring(week_num) .. tostring(job_cls_id)
        if job_cls_id ~= 0 and not processed_job_ids[key_to_check] then
            local induninfo = ui.GetFrame("induninfo")
            local induninfo_class_selector = ui.GetFrame("induninfo_class_selector")
            ui.OpenFrame("induninfo_class_selector")
            local season_tab = GET_CHILD_RECURSIVELY(induninfo, "season_tab")
            season_tab:SelectTab(week_offset)
            local classtype_tab = GET_CHILD_RECURSIVELY(induninfo, "classtype_tab")
            for k = 1, #base_jobids do
                if base_jobids[k] == current_base_jobid then
                    classtype_tab:SelectTab(k - 1)
                    break
                end
            end
            INDUNINFO_CLASS_SELECTOR_FILL_CLASS(current_base_jobid)
            weekly_boss.RequestWeeklyBossRankingInfoList(week_num, job_cls_id)
            local classList = GET_CHILD_RECURSIVELY(induninfo_class_selector, "classList")
            AUTO_CAST(classList)
            local pos = 0
            if c_idx > 18 then
                pos = 180
            elseif c_idx > 12 then
                pos = 120
            elseif c_idx > 6 then
                pos = 60
            end
            classList:SetScrollPos(pos)
            for i = 1, #job_list do
                local list_job = GET_CHILD_RECURSIVELY(induninfo_class_selector, "list_job_" .. i)
                if list_job then
                    local icon = GET_CHILD(list_job, "icon_pic")
                    if icon then
                        AUTO_CAST(icon)
                        if i == c_idx then
                            icon:SetColorTone("FFFFFFFF")
                        else
                            icon:SetColorTone("FF444444")
                        end
                    end
                end
            end
            rankListBox:SetUserValue("JOB_ID", job_cls_id)
            rankListBox:SetUserValue("WEEK_NUM", week_num)
            rankListBox:SetUserValue("SHOULD_SAVE", should_save_flag)
            rankListBox:RunUpdateScript("test_norisan_get_weekly_boss_damage", 0.2)
            processed_job_ids[key_to_check] = true

            rankListBox:SetUserValue("B_IDX", next_b_idx)
            rankListBox:SetUserValue("C_IDX", next_c_idx)
            rankListBox:SetUserValue("W_IDX", next_w_idx)
            rankListBox:StopUpdateScript("test_norisan_get_weekly_boss_data")
            rankListBox:RunUpdateScript("test_norisan_get_weekly_boss_data", 1.2)
            return 0
        end
    end
    rankListBox:SetUserValue("B_IDX", next_b_idx)
    rankListBox:SetUserValue("C_IDX", next_c_idx)
    rankListBox:SetUserValue("W_IDX", next_w_idx)
    rankListBox:StopUpdateScript("test_norisan_get_weekly_boss_data")
    rankListBox:RunUpdateScript("test_norisan_get_weekly_boss_data", 0)
    return 0
end

function test_norisan_get_weekly_boss_damage(rankListBox)

    local induninfo = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(induninfo, "rankListBox")
    AUTO_CAST(rankListBox)
    local job_id = rankListBox:GetUserValue("JOB_ID")
    local week_num = tonumber(rankListBox:GetUserValue("WEEK_NUM"))
    if not job_id or not week_num then
        return 0
    end
    local current_week_num = tonumber(rankListBox:GetUserIValue("CURRENT_WEEK_NUM"))
    local is_confirmed = (week_num < current_week_num) and "true" or "false"
    for i = 1, 20 do
        local ctrlset = GET_CHILD(rankListBox, "CTRLSET_" .. i)
        if ctrlset then
            AUTO_CAST(ctrlset)
            local name_ctrl = GET_CHILD(ctrlset, "attr_name_text", "ui::CRichText")
            local name = name_ctrl:GetTextByKey("value")
            local damage = session.weeklyboss.GetRankInfoDamage(i - 1)
            damage = string.gsub(damage, ",", "")
            damage = tonumber(damage)
            local job_cls = GetClassByType('Job', tonumber(job_id))
            local job_name = dic.getTranslatedStr(job_cls.Name)
            local msg = g.lang == "Japanese" and job_name .. " データを取得しました" or job_name ..
                            " Data obtained"
            imcAddOn.BroadMsg("NOTICE_Dm_quest_complete", msg, 1.2)
            local result_data = {week_num, job_id, i, name, damage, job_name, is_confirmed}
            table.insert(result_tbl, result_data)
        else
            if i == 1 then
                local job_cls = GetClassByType('Job', tonumber(job_id))
                local job_name = dic.getTranslatedStr(job_cls.Name)
                local result_data = {week_num, job_id, i, "None", "0", job_name, is_confirmed}
                table.insert(result_tbl, result_data)
            end
            break
        end
    end
    if rankListBox:GetUserIValue("SHOULD_SAVE") == 1 then
        test_norisan_save_log()
        rankListBox:SetUserValue("SHOULD_SAVE", 0)
    end
    return 0
end

function test_norisan_rebuild_log_file(induninfo)
    local file_path = string.format("../addons/%s/log.dat", addon_name_lower)
    local log_data = g.load_dat(file_path)
    if not log_data then
        return 0
    end
    local classtype_tab = GET_CHILD_RECURSIVELY(induninfo, "classtype_tab")
    AUTO_CAST(classtype_tab)
    local cls_index = classtype_tab:GetSelectItemIndex()
    local base_job = base_jobids[cls_index + 1]
    local week_num = session.weeklyboss.GetNowWeekNum()
    local season_tab = GET_CHILD_RECURSIVELY(induninfo, "season_tab")
    AUTO_CAST(season_tab)
    local season_index = season_tab:GetSelectItemIndex()
    local season = week_num - season_index
    local rebuilt_table = {}
    for _, record in ipairs(log_data) do
        local week_num_ = tonumber(record[1])
        local job_id = tonumber(record[2])
        local name = record[4]
        if week_num_ == season and (job_id > base_job and job_id < base_job + 1000) then
            if not rebuilt_table[name] then
                rebuilt_table[name] = {}
            end
            table.insert(rebuilt_table[name], job_id)
        end
    end
    local rankListBox = GET_CHILD_RECURSIVELY(induninfo, "rankListBox")
    AUTO_CAST(rankListBox)
    for i = 1, 20 do
        local ctrlset = GET_CHILD(rankListBox, "CTRLSET_" .. i)
        if ctrlset then
            AUTO_CAST(ctrlset)
            local attr_name_text = GET_CHILD(ctrlset, "attr_name_text")
            if attr_name_text then
                AUTO_CAST(attr_name_text)
                local raw_name = attr_name_text:GetText()
                local job_ids = rebuilt_table[raw_name]
                for j = 1, 3 do
                    local icon = GET_CHILD(ctrlset, 'job_icon' .. j)
                    if icon then
                        icon:ShowWindow(0)
                    end
                end
                local nodata = GET_CHILD(ctrlset, 'nodata_' .. i)
                if nodata then
                    nodata:ShowWindow(0)
                end
                if job_ids then
                    local rect = attr_name_text:GetMargin()
                    attr_name_text:SetMargin(rect.left, rect.top + 2, rect.right, rect.bottom)
                    for j = 1, 3 do
                        local job_id = job_ids[j]
                        if job_id then
                            local job_cls = GetClassByType('Job', job_id)
                            if job_cls then
                                local job_icon = ctrlset:CreateOrGetControl('picture', 'job_icon' .. j,
                                    (attr_name_text:GetWidth() + ((j - 1) * 30)), 5, 30, 30)
                                AUTO_CAST(job_icon)
                                job_icon:SetImage(job_cls.Icon)
                                job_icon:SetEnableStretch(1)
                                job_icon:EnableHitTest(1)
                                ctrlset:EnableHitTest(1)
                                job_icon:SetTooltipType('adventure_book_job_info')
                                job_icon:SetTooltipArg(job_id, 0, 0)
                                job_icon:ShowWindow(1)
                            end
                        end
                    end
                else
                    local nodata = ctrlset:CreateOrGetControl('richtext', 'nodata_' .. i, attr_name_text:GetWidth(), 10,
                        30, 30)
                    AUTO_CAST(nodata)
                    nodata:SetText("{#000000}No data")
                    nodata:ShowWindow(1)
                end
            end
        end
    end
    return 0
end

function test_norisan_WEEKLY_BOSS_RANK_UPDATE()
    local induninfo = ui.GetFrame("induninfo")
    local rankListBox = GET_CHILD_RECURSIVELY(induninfo, "rankListBox")
    AUTO_CAST(rankListBox)
    if rankListBox:HaveUpdateScript("test_norisan_get_weekly_boss_data") == false then
        test_norisan_rebuild_log_file(induninfo)
    end
end]]

--[[local induninfo = ui.GetFrame("induninfo")
local WeeklyBossbox = GET_CHILD_RECURSIVELY(induninfo, "classtype_tab") -- classtype_tab
ts(WeeklyBossbox:GetSelectItemIndex())
local childNames = {}
local childCount = WeeklyBossbox:GetChildCount()
for i = 0, childCount - 1 do
    local child = WeeklyBossbox:GetChildByIndex(i)
    table.insert(childNames, child:GetName())
end

for i, name in ipairs(childNames) do
    print(name)
end]]

--[[local raid_record = ui.GetFrame("test_norisan")
g.temp = {}
test_norisan_REQ_PLAYER_CONTENTS_RECORD(raid_record, "", "Goddess_Raid_Redania_Solo;00:13.253;00:19.28", "")]]
function test_norisan_GODDESS_AETHER_SOCKET_OPEN_MAT_REG(my_frame, my_msg)
    local parent, slot, inv_item, item_obj, target_obj = g.get_event_args(my_msg)
    if item_goddess_socket.is_aether_socket_material(item_obj, target_obj) == true then
        local lock_pic = GET_CHILD(parent, 'lock_pic')
        lock_pic:ShowWindow(0)
        local aether_open_btn = GET_CHILD(parent, 'aether_open_btn')
        aether_open_btn:SetEnable(1)
        SET_SLOT_ITEM(slot, inv_item)
        slot:SetUserValue('ITEM_GUID', inv_item:GetIESID())
    end
end
-- ui.SysMsg(ClMsg('CantMovablePharmacyMaterial'))
-- ui.SysMsg(ClMsg('CantMovablePharmacyMaterial'))


--[[function test_norisan_hp_use(frame, msg, str, num)
    local stat = info.GetStat(session.GetMyHandle())
    local ratio = stat.HP / stat.maxHP

    if ratio > 0.6 then
        return
    end

    local function test_norisan_INV_ICON_USE(invItem)
        if nil == invItem then
            return
        end

        if true == invItem.isLockState then
            ui.SysMsg(ClMsg("MaterialItemIsLock"))
            return
        end

        if true == RUN_CLIENT_SCP(invItem) then
            return
        end

        local stat = info.GetStat(session.GetMyHandle())
        if stat.HP <= 0 then
            return
        end

        local itemtype = invItem.type
        local curTime = item.GetCoolDown(itemtype)
        if curTime ~= 0 then
            return
        end

        item.UseByGUID(invItem:GetIESID())
    end

    local pot_table = {641906, 640405}
    session.ResetItemList()
    local invItemList = session.GetInvItemList()

    for _, classid in ipairs(pot_table) do
        local use_item = session.GetInvItemByType(classid)
        if use_item then
            test_norisan_INV_ICON_USE(use_item)
        end
    end
end

function test_norisan_sp_use(frame, msg, str, num)
    local stat = info.GetStat(session.GetMyHandle())
    local ratio = stat.SP / stat.maxSP

    if ratio > 0.3 then
        return
    end

    local function test_norisan_INV_ICON_USE(invItem)
        if nil == invItem then
            return
        end

        if true == invItem.isLockState then
            ui.SysMsg(ClMsg("MaterialItemIsLock"))
            return
        end

        if true == RUN_CLIENT_SCP(invItem) then
            return
        end

        local stat = info.GetStat(session.GetMyHandle())
        if stat.HP <= 0 then
            return
        end

        local itemtype = invItem.type
        local curTime = item.GetCoolDown(itemtype)
        if curTime ~= 0 then
            return
        end

        item.UseByGUID(invItem:GetIESID())
    end

    local pot_table = {640448, 640436, 640406}
    session.ResetItemList()
    local invItemList = session.GetInvItemList()

    for _, classid in ipairs(pot_table) do
        local use_item = session.GetInvItemByType(classid)
        if use_item then
            test_norisan_INV_ICON_USE(use_item)
        end
    end
end]]

--[[function test_norisan_PROCESS_MOVE_MAIN_POPUPCHAT_FRAME(frame)
    if mouse.IsLBtnPressed() == 0 then
        MOVE_FRAME_MAIN_POPUP_CHAT_END(frame)
        return 0;
    end
    -- print(frame:GetName())
    local ratio = option.GetClientHeight() / option.GetClientWidth();
    local limitOffset = 10;
    -- local limitMaxWidth = ui.GetSceneWidth() / ui.GetRatioWidth() - limitOffset;
    local limitMaxWidth = ui.GetSceneWidth() - limitOffset;
    local limitMaxHeight = limitMaxWidth * ratio - limitOffset * 12;

    local mx, my = GET_MOUSE_POS();
    mx = mx / ui.GetRatioWidth();
    my = my / ui.GetRatioHeight();

    local bx = frame:GetUserIValue("MOUSE_X");
    local by = frame:GetUserIValue("MOUSE_Y");
    local dx = (mx - bx);
    local dy = (my - by);

    local width = frame:GetUserIValue("BEFORE_W");
    local height = frame:GetUserIValue("BEFORE_H");
    width = width + dx;
    height = height + dy;

    if width < limitOffset then
        width = limitOffset;
    end

    if height < limitOffset then
        height = limitOffset;
    end

    local wndW = frame:GetWidth();
    local wndH = frame:GetHeight()

    if (width + wndW) > limitMaxWidth then
        width = limitMaxWidth - wndW;
    end

    if (height + wndH) > limitMaxHeight then
        height = (limitMaxHeight - wndH);
    end

    frame:SetOffset(width, height);

    return 1;
end

function test_norisan__PROCESS_MOVE_MAIN_POPUPCHAT_FRAME(my_frame, my_msg)

    local frame = g.get_event_args(my_msg)
    frame:RunUpdateScript("test_norisan_PROCESS_MOVE_MAIN_POPUPCHAT_FRAME", 0.1);

end
local ___cursize = -80;
function test_norisan_REQUEST_UPDATE_MINIMAP(my_frame, my_msg)

    local frame, isFirstOpen = g.get_event_args(my_msg)
    local curmapname = session.GetMapName();
    local mapprop = geMapTable.GetMapProp(curmapname);
    local mapname = mapprop:GetClassName();

    if isFirstOpen ~= nil and isFirstOpen == true then
        ___cursize = GET_MINIMAPSIZE();
    end

    RequestUpdateMinimap(mapname, -100);
    SET_MINIMAPSIZE(-100);
    print(tostring(___cursize))
end]]

--[[function test_norisan_get_cooldown(frame)

    local frame = ui.GetFrame('quickslotnexpbar');

    for i = 0, MAX_QUICKSLOT_CNT - 1 do
        local quickSlotInfo = quickslot.GetInfoByIndex(i);

        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot");
        local pain_cool = 0
        local icon = slot:GetIcon()
        if quickSlotInfo.type == 10005 then

            pain_cool = ICON_UPDATE_SKILL_COOLDOWN(icon)
            print(tostring(pain_cool))
            if pain_cool == 0 then
                ICON_USE(icon)
            end
        end

    end

    local summonedPet = GET_SUMMONED_PET();

    if summonedPet ~= nil then

        local pet_guid = summonedPet:GetStrGuid()
        local petInfo = session.pet.GetPetByGUID(pet_guid);
        local obj = GetIES(petInfo:GetObject())

        if obj.IsActivated ~= 1 then
            return
        end
    else
        return 1
    end

    local void_cool = 0
    local dance_enable = 0

    for i = 0, MAX_QUICKSLOT_CNT - 1 do
        local quickSlotInfo = quickslot.GetInfoByIndex(i);

        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot");

        local icon = slot:GetIcon()
        if quickSlotInfo.type == 12329 then
            void_cool = ICON_UPDATE_SKILL_COOLDOWN(icon)
        elseif quickSlotInfo.type == 12332 then
            dance_enable = ICON_UPDATE_SKILL_ENABLE(icon)
        end

    end

    if void_cool == 0 then
        ON_RIDING_VEHICLE(0)
    elseif dance_enable ~= 0 then
        ON_RIDING_VEHICLE(0)
    else
        ON_RIDING_VEHICLE(1)
    end
    return 1
end]]
--[[function test_norisan_REROLL_ITEM_OPTION_LIST(reroll_frame)

    local reroll_item_option = ui.GetFrame("reroll_item_option")
    local reroll_frame = ui.GetFrame('reroll_item')
    if reroll_frame == nil or reroll_frame:IsVisible() ~= 1 then
        ui.CloseFrame('reroll_item_option')
        return 1
    end

    local slot = GET_CHILD_RECURSIVELY(reroll_frame, 'slot')
    local inv_item = GET_SLOT_ITEM(slot)
    if inv_item == nil then
        ui.CloseFrame('reroll_item_option')
        return 1
    end

    if reroll_item_option:IsVisible() == 1 then
        return 1
    end

    local item_obj = GetIES(inv_item:GetObject())
    local cur_index = reroll_frame:GetUserValue('CURRENT_INDEX')

    if cur_index == 'None' then
        cur_index = 1
    end

    if cur_index == nil or cur_index == 'None' then
        return 1
    end

    local reroll_index = TryGetProp(item_obj, 'RerollIndex', 0)

    if reroll_index <= 0 then
        reroll_index = tonumber(cur_index)
    end

    local candidate_option_list = nil

    local group_name = TryGetProp(item_obj, 'GroupName', 'None')
    if group_name == 'BELT' then
        candidate_option_list = shared_item_belt.get_option_list_by_index(item_obj, reroll_index)
    elseif group_name == 'SHOULDER' then
        candidate_option_list = shared_item_shoulder.get_option_list_by_index(item_obj, reroll_index)
    elseif group_name == 'Icor' then
        candidate_option_list = shared_item_goddess_icor.get_random_option_list(item_obj, false)
    end

    if candidate_option_list == nil or #candidate_option_list == 0 then
        return
    end

    local max_random_option_count = 0

    if group_name == 'BELT' then
        max_random_option_count = shared_item_belt.get_max_random_option_count(item_obj)
    elseif group_name == 'SHOULDER' then
        max_random_option_count = shared_item_shoulder.get_max_random_option_count(item_obj)
    elseif group_name == 'Icor' then
        max_random_option_count = shared_item_goddess_icor.get_max_option_count()
    end

    if max_random_option_count == nil then
        return
    end

    local optionGbox = GET_CHILD_RECURSIVELY(reroll_item_option, 'optionGbox')
    optionGbox:RemoveAllChild()
    local op_count = 0

    local function _MAKE_PROPERTY_MIN_MAX_DESC(desc, min, max)
        return string.format(" %s " .. ScpArgMsg("PropUp") .. "%d" .. ' ~ ' .. ScpArgMsg("PropUp") .. "%d", desc,
            math.abs(min), math.abs(max))
    end

    for i = 1, #candidate_option_list do
        local prop_name = candidate_option_list[i]

        if group_name == 'BELT' then
            if shared_item_belt.is_valid_reroll_option(item_obj, reroll_index, prop_name, max_random_option_count) ==
                true then
                op_count = op_count + 1
                local group_name = shared_item_belt.get_option_group_name(prop_name)
                local clmsg = GET_CLMSG_BY_OPTION_GROUP(group_name)
                local min, max = shared_item_belt.get_option_value_range_equip(item_obj, prop_name)
                local op_name = string.format('%s %s', ClMsg(clmsg), ScpArgMsg(prop_name))
                local info_str = _MAKE_PROPERTY_MIN_MAX_DESC(op_name, min, max)
                local option_ctrlset = optionGbox:CreateOrGetControlSet('eachproperty_in_reroll_item',
                    'PROPERTY_CSET_' .. op_count, 0, 0)
                option_ctrlset = AUTO_CAST(option_ctrlset)
                local pos_y = option_ctrlset:GetUserConfig('POS_Y')
                option_ctrlset:Move(0, (op_count - 1) * pos_y)
                -- local bg = GET_CHILD_RECURSIVELY(option_ctrlset, 'bg')
                -- bg:ShowWindow(0)
                local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, 'property_name', 'ui::CRichText')
                property_name:SetEventScript(ui.LBUTTONUP, 'None')
                property_name:SetText(info_str)
                local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, 'help_pic')
                help_pic:ShowWindow(0)
            end
        elseif group_name == 'SHOULDER' then
            if shared_item_shoulder.is_valid_reroll_option(item_obj, reroll_index, prop_name, max_random_option_count) ==
                true then
                op_count = op_count + 1
                local group_name = shared_item_shoulder.get_option_group_name(prop_name)
                local clmsg = GET_CLMSG_BY_OPTION_GROUP(group_name)
                local min, max = shared_item_shoulder.get_option_value_range_equip(item_obj, prop_name)
                local op_name = string.format('%s %s', ClMsg(clmsg), ScpArgMsg(prop_name))
                local info_str = _MAKE_PROPERTY_MIN_MAX_DESC(op_name, min, max)
                local option_ctrlset = optionGbox:CreateOrGetControlSet('eachproperty_in_reroll_item',
                    'PROPERTY_CSET_' .. op_count, 0, 0)
                option_ctrlset = AUTO_CAST(option_ctrlset)
                local pos_y = option_ctrlset:GetUserConfig('POS_Y')
                option_ctrlset:Move(0, (op_count - 1) * pos_y)
                -- local bg = GET_CHILD_RECURSIVELY(option_ctrlset, 'bg')
                -- bg:ShowWindow(0)
                local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, 'property_name', 'ui::CRichText')
                property_name:SetEventScript(ui.LBUTTONUP, 'None')
                property_name:SetText(info_str)
                local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, 'help_pic')
                help_pic:ShowWindow(0)
            end
        elseif group_name == 'Icor' then
            if shared_item_goddess_icor.is_valid_reroll_option(item_obj, reroll_index, prop_name) == true then

                op_count = op_count + 1
                local group_name = shared_item_goddess_icor.get_option_group_name(prop_name)

                local clmsg = GET_CLMSG_BY_OPTION_GROUP(group_name)

                local min, max = shared_item_goddess_icor.get_option_value_range_icor(item_obj, prop_name)

                local op_name = string.format('%s %s', ClMsg(clmsg), ScpArgMsg(prop_name))

                local info_str = _MAKE_PROPERTY_MIN_MAX_DESC(op_name, min, max)

                local option_ctrlset = optionGbox:CreateOrGetControlSet('eachproperty_in_reroll_item',
                    'PROPERTY_CSET_' .. op_count, 0, 0)
                option_ctrlset = AUTO_CAST(option_ctrlset)
                local pos_y = option_ctrlset:GetUserConfig('POS_Y')
                option_ctrlset:Move(0, (op_count - 1) * pos_y)
                local property_name = GET_CHILD_RECURSIVELY(option_ctrlset, 'property_name', 'ui::CRichText')
                property_name:SetEventScript(ui.LBUTTONUP, 'None')
                property_name:SetText(info_str)
                local help_pic = GET_CHILD_RECURSIVELY(option_ctrlset, 'help_pic')
                help_pic:ShowWindow(0)
            end
        end
    end
    reroll_item_option:Resize(500, 970)
    reroll_item_option:SetSkinName("None")
    local bg = GET_CHILD(reroll_item_option, "bg")
    bg:Resize(470, reroll_item_option:GetHeight())
    local optionGbox = GET_CHILD(reroll_item_option, "optionGbox")
    optionGbox:Resize(430, bg:GetHeight() - 100)

    reroll_item_option:ShowWindow(1)
    return 1
end

function test_norisan_reroll_item_option_open()
    local reroll_item = ui.GetFrame("reroll_item")
    if reroll_item and reroll_item:IsVisible() == 1 then
        reroll_item:RunUpdateScript("test_norisan_REROLL_ITEM_OPTION_LIST", 0.2)
        --[[local slot = GET_CHILD(reroll_item, "slot")
        local icon = slot:GetIcon()
        if icon then
            -- print("test_norisan_reroll_item_option")
            local reroll_item_option = ui.GetFrame("reroll_item_option")
            -- test_norisan_REROLL_ITEM_OPTION_LIST(reroll_item_option)

        end]
    else
        return
    end
end

function test_norisan__REROLL_ITEM_SELECT_EXEC()
    local reroll_item = ui.GetFrame("reroll_item")
    reroll_item:ShowWindow(1)
end]]

--[[function test_norisan_get_weekly_boss_data(rankListBox)

    local mode_base_id = rankListBox:GetUserIValue("MODE_BASE_ID")
    local mode_is_4w = rankListBox:GetUserIValue("MODE_IS_4W")

    local b_idx = rankListBox:GetUserIValue("B_IDX")
    local c_idx = rankListBox:GetUserIValue("C_IDX")
    local w_idx = rankListBox:GetUserIValue("W_IDX")

    if w_idx == 0 and b_idx == 1 and c_idx == 1 then
        -- ループの初回実行時に、現在の本当の週番号を保存する
        local induninfo = ui.GetFrame("induninfo")
        local season_tab = GET_CHILD_RECURSIVELY(induninfo, "season_tab")
        season_tab:SelectTab(0) -- 必ず「今週」タブを選択してから週番号を取得
        rankListBox:SetUserValue("CURRENT_WEEK_NUM", WEEKLY_BOSS_RANK_WEEKNUM_NUMBER())
    end
    local current_week_num = rankListBox:GetUserIValue("CURRENT_WEEK_NUM")

    local target_base
    local is_all_classes_mode = false
    if mode_base_id == 0 or mode_base_id == 1 then
        target_base = base_jobids
        is_all_classes_mode = true
    else
        target_base = {mode_base_id}
    end

    local num_weeks = (mode_base_id == 1 or mode_is_4w == 1) and 4 or 1

    local induninfo = ui.GetFrame("induninfo")
    local induninfo_class_selector = ui.GetFrame("induninfo_class_selector")

    while true do
        if w_idx >= num_weeks then
            test_norisan_save_log()
            if induninfo_class_selector:IsVisible() == 1 then
                local classList = GET_CHILD_RECURSIVELY(induninfo_class_selector, "classList")
                if classList then
                    AUTO_CAST(classList);
                    classList:SetScrollPos(0);
                end
                induninfo_class_selector:SetEnable(1)
                INDUNINFO_CLASS_SELECTOR_UI_CLOSE(induninfo_class_selector)
            end
            local end_time = os.clock()
            local elapsed_time = end_time - start_time
            print(string.format("処理が完了しました。所要時間: %.2f 秒", elapsed_time))
            return 0 -- 停止
        end

        local current_base_jobid = target_base[b_idx]
        local job_list = GET_JOB_LIST(current_base_jobid)
        local job_cls = job_list[c_idx]

        -- 4. 処理の実行
        if job_cls then

            local job_cls_id = TryGetProp(job_cls, "ClassID", 0)
            -- 変更: week_offsetの計算方法を修正
            local week_offset
            if num_weeks == 4 then
                -- 4週間モードの場合: 3, 2, 1, 0 と変化させる
                week_offset = 3 - w_idx
            else
                -- 1週間モードの場合: 常に 0
                week_offset = 0
            end
            local week_num = current_week_num - week_offset

            if job_cls_id ~= 0 and not processed_job_ids[week_num .. job_cls_id] then

                ui.OpenFrame("induninfo_class_selector")
                induninfo_class_selector:SetEnable(0)

                local season_tab = GET_CHILD_RECURSIVELY(induninfo, "season_tab")
                season_tab:SelectTab(week_offset) -- UIのタブ選択はw_idxで正しい

                local classtype_tab = GET_CHILD_RECURSIVELY(induninfo, "classtype_tab")
                for k = 1, #base_jobids do
                    if base_jobids[k] == current_base_jobid then
                        classtype_tab:SelectTab(k - 1)
                        break
                    end
                end

                INDUNINFO_CLASS_SELECTOR_FILL_CLASS(current_base_jobid)
                weekly_boss.RequestWeeklyBossRankingInfoList(week_num, job_cls_id)

                local classList = GET_CHILD_RECURSIVELY(induninfo_class_selector, "classList")
                AUTO_CAST(classList)
                local pos = 0
                if c_idx > 18 then
                    pos = 150
                elseif c_idx > 12 then
                    pos = 100
                elseif c_idx > 6 then
                    pos = 50
                end
                classList:SetScrollPos(pos)

                local list_job
                for i = 1, #job_list do
                    list_job = GET_CHILD_RECURSIVELY(induninfo_class_selector, "list_job_" .. i)
                    if list_job then
                        local icon = GET_CHILD(list_job, "icon_pic")
                        if icon then
                            AUTO_CAST(icon)
                            if i == c_idx then
                                icon:SetColorTone("FFFFFFFF")
                            else
                                icon:SetColorTone("FF444444")
                            end
                        end
                    end
                end

                local next_b_idx = b_idx
                local next_c_idx = c_idx + 1
                local next_w_idx = w_idx

                if next_c_idx > #job_list then
                    next_c_idx = 1
                    next_b_idx = b_idx + 1
                    if is_all_classes_mode then
                        test_norisan_save_log()
                    end
                end
                if next_b_idx > #target_base then
                    next_b_idx = 1
                    next_c_idx = 1
                    next_w_idx = w_idx + 1
                    if not is_all_classes_mode then
                        test_norisan_save_log()
                    end
                end

                rankListBox:SetUserValue("B_IDX", next_b_idx)
                rankListBox:SetUserValue("C_IDX", next_c_idx)
                rankListBox:SetUserValue("W_IDX", next_w_idx)

                rankListBox:SetUserValue("JOB_ID", job_cls_id)
                rankListBox:SetUserValue("WEEK_NUM", week_num)
                rankListBox:RunUpdateScript("test_norisan_get_weekly_boss_damage", 0.2)
                processed_job_ids[week_num .. job_cls_id] = true

                return 1
            else
                -- スキップする場合: 次のインデックスを計算
                c_idx = c_idx + 1
                if c_idx > #job_list then
                    c_idx = 1
                    b_idx = b_idx + 1
                    if is_all_classes_mode then
                        test_norisan_save_log()
                    end
                end
                if b_idx > #target_base then
                    b_idx = 1
                    c_idx = 1
                    w_idx = w_idx + 1
                    if not is_all_classes_mode then
                        test_norisan_save_log()
                    end
                end
            end
        end
    end
    return 1 -- 継続
end]==] --[[
function Battle_ritual_load_settings()
    g.Battle_ritual_path = string.format("../addons/%s/%s/battle_ritual.json", addon_name_lower, g.active_id)
    local settings = g.load_json(g.Battle_ritual_path)
    if not settings then
        settings = {
            skills = {},
            etc = {
                x = 0,
                y = 0,
                move = 0,
                use = 0
            }
        }
    end
    g.Battle_ritual_settings = settings
    Battle_ritual_save_settings()
end

function battle_ritual_on_init()
    if not g.Battle_ritual_settings then
        Battle_ritual_load_settings()
    end
    if g.settings.battle_ritual.use == 0 then
        ui.DestroyFrame(addon_name_lower .. "Battle_ritual")
        return
    end
    Battle_ritual_frame_init()
    if g.get_map_type() == "Instance" then
        g.addon:RegisterMsg('REQ_PLAYER_CONTENTS_RECORD', 'Battle_ritual_REQ_PLAYER_CONTENTS_RECORD')
        Battle_ritual_auto_buff_skill_start()
    end
end

function Battle_ritual_auto_buff_skill_start()
    if g.Battle_ritual_settings.etc.use == 0 then
        return
    end
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    local list = session.party.GetPartyMemberList(PARTY_NORMAL)
    if list:Count() > 1 then
        _nexus_addons:StopUpdateScript("Battle_ritual_auto_buff_skill")
        return
    end
    local skills_table = g.Battle_ritual_settings.skills
    if not skills_table then
        return
    end
    local sorted_list = {}
    for s_id, data in pairs(skills_table) do
        table.insert(sorted_list, {
            skill_id = tonumber(s_id),
            buff_id = data.buff_id,
            priority = data.priority
        })
    end
    table.sort(sorted_list, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        else
            return tonumber(a.skill_id) < tonumber(b.skill_id)
        end
    end)
    local skill_map = {}
    for i = 0, 40 - 1 do
        local quick_slot_info = quickslot.GetInfoByIndex(i)
        if quick_slot_info and quick_slot_info.category == 'Skill' then
            skill_map[quick_slot_info.type] = i
        end
    end
    g.Battle_ritual_use_queue = {}
    local my_handle = session.GetMyHandle()
    local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
    for _, data in ipairs(sorted_list) do
        local skill_id = data.skill_id
        local slot_index = skill_map[skill_id]
        if slot_index then
            local slot = GET_CHILD_RECURSIVELY(quickslotnexpbar, "slot" .. (slot_index + 1), "ui::CSlot")
            if slot then
                local icon = slot:GetIcon()
                if icon then
                    local cur_time = ICON_UPDATE_SKILL_COOLDOWN(icon)
                    if cur_time == 0 then
                        local buff_id = data.buff_id
                        local need_buff = true
                        if buff_id > 0 then
                            if info.GetBuff(my_handle, buff_id) then
                                need_buff = false
                            end
                        end
                        if need_buff then
                            table.insert(g.Battle_ritual_use_queue, {
                                buff_id = buff_id,
                                skill_id = skill_id,
                                icon = icon
                            })
                        end
                    end
                end
            end
        end
    end
    if #g.Battle_ritual_use_queue > 0 then
        _nexus_addons:RunUpdateScript("Battle_ritual_auto_buff_skill", 0.1)
    end
end

function Battle_ritual_auto_buff_skill(_nexus_addons)
    if not g.Battle_ritual_use_queue or #g.Battle_ritual_use_queue == 0 then
        return 0
    end
    local next_skill_info = g.Battle_ritual_use_queue[1]
    if not next_skill_info or not next_skill_info.icon then
        table.remove(g.Battle_ritual_use_queue, 1)
        return 1
    end
    local my_handle = session.GetMyHandle()
    local buff_info = nil
    if next_skill_info.buff_id and next_skill_info.buff_id > 0 then
        buff_info = info.GetBuff(my_handle, next_skill_info.buff_id)
    end
    local current_cooldown = ICON_UPDATE_SKILL_COOLDOWN(next_skill_info.icon)
    if current_cooldown == 0 and (next_skill_info.buff_id == 0 or not buff_info) then
        ICON_USE(next_skill_info.icon)
        local changed_image = QUICKSLOT_CHANGE_ICON_LIST[tostring(next_skill_info.skill_id)]
        if changed_image then
            table.remove(g.Battle_ritual_use_queue, 1)
        end
        return 1
    end
    if #g.Battle_ritual_use_queue > 0 then
        table.remove(g.Battle_ritual_use_queue, 1)
        return 1
    else
        return 0
    end
end

function Battle_ritual_frame_init()
    local Battle_ritual = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "Battle_ritual", 0, 0, 0, 0)
    AUTO_CAST(Battle_ritual)
    Battle_ritual:SetSkinName("None")
    Battle_ritual:SetTitleBarSkin("None")
    Battle_ritual:Resize(40, 30)
    Battle_ritual:SetGravity(ui.RIGHT, ui.TOP)
    Battle_ritual:EnableMove(g.Battle_ritual_settings.etc.move == 1 and 0 or 1)
    Battle_ritual:EnableHittestFrame(1)
    local rect = Battle_ritual:GetMargin()
    Battle_ritual:SetMargin(rect.left - rect.left, rect.top - rect.top + 2,
        rect.right == 0 and rect.right + 305 or rect.right, rect.bottom)
    if g.Battle_ritual_settings.etc.x ~= 0 and g.Battle_ritual_settings.etc.y ~= 0 then
        Battle_ritual:SetPos(g.Battle_ritual_settings.etc.x, g.Battle_ritual_settings.etc.y)
    end
    Battle_ritual:SetEventScript(ui.LBUTTONUP, "Battle_ritual_frame_location_save")
    local pic = Battle_ritual:CreateOrGetControl("picture", "pic", 0, 0, 30, 30)
    AUTO_CAST(pic)
    pic:SetImage("emoticon_0015")
    pic:SetColorTone("FFFFFFFF")
    pic:SetEnableStretch(1)
    pic:EnableHitTest(1)
    pic:SetGravity(ui.LEFT, ui.TOP)
    pic:SetTextTooltip(g.lang == "Japanese" and "{ol}Battle Ritual{nl}右クリック ON/OFF" or
                           "{ol}Battle Ritual{nl}Right click ON/OFF")
    if g.Battle_ritual_settings.etc.use == 0 then
        pic:SetColorTone("FF555555")
    else
        pic:SetColorTone("FFFFFFFF")
    end
    pic:SetEventScript(ui.RBUTTONUP, "Battle_ritual_onoff_switch")
    Battle_ritual:ShowWindow(1)
end

function Battle_ritual_onoff_switch(Battle_ritual)
    g.Battle_ritual_settings.etc.use = 1 - g.Battle_ritual_settings.etc.use
    Battle_ritual_save_settings()
    Battle_ritual_frame_init()
end

function Battle_ritual_frame_location_save(Battle_ritual)
    g.Battle_ritual_settings.etc.x = Battle_ritual:GetX()
    g.Battle_ritual_settings.etc.y = Battle_ritual:GetY()
    Battle_ritual_save_settings()
end

function Battle_ritual_settings_frame()
    local list_frame = ui.GetFrame(addon_name_lower .. "list_frame")
    local setting = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "Battle_ritual_setting", 0, 0, 0, 0)
    setting:SetPos(list_frame:GetX() + list_frame:GetWidth(), list_frame:GetY())
    setting:SetSkinName("test_frame_low")
    setting:EnableHittestFrame(1)
    setting:EnableHitTest(1)
    setting:SetLayerLevel(999)
    setting:RemoveAllChild()
    local title_text = setting:CreateOrGetControl('richtext', 'title_text', 20, 15, 50, 30)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Battle ritual Config")
    local close = setting:CreateOrGetControl("button", "close", 0, 0, 20, 20)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "Battle_ritual_frame_close")
    local gbox = setting:CreateOrGetControl("groupbox", "gbox", 10, 40, setting:GetWidth() - 20,
        setting:GetHeight() - 50)
    AUTO_CAST(gbox)
    gbox:SetSkinName("test_frame_midle_light")
    gbox:EnableScrollBar(1)
    Battle_ritual_settings_frame_child(setting, gbox)
end

function Battle_ritual_settings_frame_child(setting, gbox) -- gbox:EnableScrollBar(0)
    local move_check = gbox:CreateOrGetControl('checkbox', "move_check", 10, 10, 30, 30)
    AUTO_CAST(move_check)
    move_check:SetCheck(g.Battle_ritual_settings.etc.move)
    move_check:SetText(g.lang == "Japanese" and "{ol}チェックするとフレーム固定" or
                           "{ol}If checked, the frame is fixed")
    move_check:SetEventScript(ui.LBUTTONUP, "Battle_ritual_frame_move")
    local default_btn = gbox:CreateOrGetControl("button", "default_btn", move_check:GetWidth() + 30, 10, 120, 30)
    AUTO_CAST(default_btn)
    default_btn:SetText(g.lang == "Japanese" and "{ol}フレーム初期位置" or "{ol}Init frame pos")
    default_btn:SetEventScript(ui.LBUTTONUP, "Battle_ritual_frame_default")
    local skill_lbl = gbox:CreateOrGetControl('richtext', 'header_skill', 10, 45, 100, 20)
    AUTO_CAST(skill_lbl)
    skill_lbl:SetText(g.lang == "Japanese" and "{ol}スキル" or "{ol}Skill")
    local buff_lbl = gbox:CreateOrGetControl('richtext', 'header_buff', 230, 45, 100, 20)
    AUTO_CAST(buff_lbl)
    buff_lbl:SetText(g.lang == "Japanese" and "{ol}バフ" or "{ol}Buff")
    local priority_lbl = gbox:CreateOrGetControl('richtext', 'header_priority', 450, 45, 100, 20)
    AUTO_CAST(priority_lbl)
    priority_lbl:SetText(g.lang == "Japanese" and "{ol}優先度" or "{ol}Priority")
    local y_pos = 70
    local row_height = 40
    local sorted_skills = {}
    if g.Battle_ritual_settings.skills then
        for s_id, data in pairs(g.Battle_ritual_settings.skills) do
            table.insert(sorted_skills, {
                skill_id = tonumber(s_id),
                buff_id = data.buff_id or 0,
                priority = data.priority or 0
            })
        end
    end
    table.sort(sorted_skills, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        else
            return a.skill_id < b.skill_id
        end
    end)
    for i, entry in ipairs(sorted_skills) do
        Battle_ritual_create_row(gbox, i, entry.skill_id, entry.buff_id, entry.priority, y_pos)
        y_pos = y_pos + row_height
    end
    Battle_ritual_create_row(gbox, #sorted_skills + 1, 0, 0, 0, y_pos)
end

function Battle_ritual_frame_default(parent)
    ui.DestroyFrame(addon_name_lower .. "Battle_ritual")
    g.Battle_ritual_settings.etc.x = 0
    g.Battle_ritual_settings.etc.y = 0
    Battle_ritual_save_settings()
    ReserveScript("Battle_ritual_frame_init()", 0.1)
end

function Battle_ritual_frame_move(Battle_ritual, gbox)
    g.Battle_ritual_settings.etc.move = 1 - g.Battle_ritual_settings.etc.move
    Battle_ritual_save_settings()
    Battle_ritual_frame_init()
end

function Battle_ritual_create_row(gbox, index, skill_id, buff_id, priority, y)
    local skill_add = gbox:CreateOrGetControl("button", "skill_add_" .. index, 10, y, 50, 30)
    AUTO_CAST(skill_add)
    skill_add:SetSkinName("test_cardtext_btn")
    skill_add:SetText("{ol}Add")
    skill_add:SetTextTooltip(g.lang == "Japanese" and "{ol}スキルリスト表示" or "{ol}Display the skill list")
    skill_add:SetEventScript(ui.LBUTTONUP, "Battle_ritual_skill_list_open")
    skill_add:SetEventScriptArgNumber(ui.LBUTTONUP, index)
    local skill_pic = gbox:CreateOrGetControl('picture', "skill_pic_" .. index, 65, y, 30, 30)
    AUTO_CAST(skill_pic)
    local skill_img = ""
    if skill_id > 0 then
        local cls = GetClassByType("Skill", skill_id)
        if cls then
            skill_img = "icon_" .. cls.Icon
        end
    end
    skill_pic:SetImage(skill_img)
    skill_pic:SetEnableStretch(1)
    skill_pic:EnableHitTest(1)
    if skill_id > 0 then
        SET_SKILL_TOOLTIP_BY_TYPE(skill_pic, skill_id)
    end
    local skill_edit = gbox:CreateOrGetControl('edit', 'skill_edit_' .. index, 100, y, 80, 30)
    AUTO_CAST(skill_edit)
    skill_edit:SetNumberMode(1)
    skill_edit:SetFontName("white_16_ol")
    skill_edit:SetText(skill_id == 0 and "" or skill_id)
    skill_edit:SetTextAlign("center", "center")
    skill_edit:SetTextTooltip(g.lang == "Japanese" and "{ol}スキルID入力{nl}錬成スキルは141001～" or
                                  "{ol}Enter the Skill ID.{nl}Alchemic skills start from 141001")
    if skill_edit:GetText() ~= "" then
        skill_edit:SetUserValue("ORIG_SKILL_ID", skill_id)
    end
    skill_edit:SetTypingScp("Battle_ritual_add_skill")
    local skill_remove = gbox:CreateOrGetControl("button", "skill_remove_" .. index, 185, y, 30, 30)
    AUTO_CAST(skill_remove)
    skill_remove:SetSkinName("test_cardtext_btn")
    skill_remove:SetText("{ol}×")
    skill_remove:SetTextTooltip(g.lang == "Japanese" and "{ol}登録解除" or "{ol}unregister")
    skill_remove:SetEventScript(ui.LBUTTONUP, "Battle_ritual_remove")
    skill_remove:SetEventScriptArgString(ui.LBUTTONUP, tostring(skill_id))
    if skill_id > 0 then
        local buff_add = gbox:CreateOrGetControl("button", "buff_add_" .. index, 230, y, 50, 30)
        AUTO_CAST(buff_add)
        buff_add:SetSkinName("test_cardtext_btn")
        buff_add:SetText("{ol}Add")
        buff_add:SetTextTooltip(g.lang == "Japanese" and "{ol}バフリスト表示" or "{ol}Display the buff list")
        buff_add:SetEventScript(ui.LBUTTONUP, "Battle_ritual_buff_list_open")
        buff_add:SetEventScriptArgNumber(ui.LBUTTONUP, skill_id)
        gbox:SetUserValue("INDEX", index)
        local buff_pic = gbox:CreateOrGetControl('picture', "buff_pic_" .. index, 285, y, 30, 30)
        AUTO_CAST(buff_pic)
        local buff_img = ""
        if buff_id > 0 then
            local cls = GetClassByType("Buff", buff_id)
            if cls then
                buff_img = "icon_" .. cls.Icon
            end
        end
        buff_pic:SetImage(buff_img)
        buff_pic:SetEnableStretch(1)
        buff_pic:EnableHitTest(1)
        local buff_edit = gbox:CreateOrGetControl('edit', 'buff_edit_' .. index, 320, y, 80, 30)
        AUTO_CAST(buff_edit)
        buff_edit:SetNumberMode(1)
        buff_edit:SetFontName("white_16_ol")
        buff_edit:SetText(buff_id == 0 and "" or buff_id)
        buff_edit:SetTextAlign("center", "center")
        buff_edit:SetTextTooltip(g.lang == "Japanese" and
                                     "{ol}バフID入力{nl}対応バフが無い場合は 空白{nl}(例)テンペストショットは 空白{nl}ダブルアタックは 322など{nl}※入力無しは毎回掛け直し" or
                                     "{ol}Enter the Buff ID{nl}Leave blank if there is no corresponding buff{nl}(e.g.)Tempest Shot is blank{nl}Double Attack is 322, etc.{nl}※If no input is provided,will be recast every time")
        buff_edit:SetUserValue("SKILL_ID", skill_id)

        buff_edit:SetTypingScp("Battle_ritual_add_buff")
        local buff_remove = gbox:CreateOrGetControl("button", "buff_remove" .. index, 405, y, 30, 30)
        AUTO_CAST(buff_remove)
        buff_remove:SetSkinName("test_cardtext_btn")
        buff_remove:SetText("{ol}×")
        buff_remove:SetTextTooltip(g.lang == "Japanese" and "{ol}登録解除" or "{ol}unregister")
        buff_remove:SetEventScript(ui.LBUTTONUP, "Battle_ritual_remove")
        buff_remove:SetEventScriptArgString(ui.LBUTTONUP, tostring(skill_id))
        local priority_edit = gbox:CreateOrGetControl('edit', 'priority_edit_' .. index, 450, y, 50, 30)
        AUTO_CAST(priority_edit)
        priority_edit:SetNumberMode(1)
        priority_edit:SetFontName("white_16_ol")
        priority_edit:SetText(priority)
        priority_edit:SetTextAlign("center", "center")
        priority_edit:SetTextTooltip(g.lang == "Japanese" and "{ol}優先度入力" or "{ol}Enter Priority")
        priority_edit:SetUserValue("SKILL_ID", skill_id)
        priority_edit:SetTypingScp("Battle_ritual_priority")
    end
    local setting = gbox:GetParent()
    setting:Resize(550, y + 100)
    gbox:Resize(setting:GetWidth() - 20, setting:GetHeight() - 50)
    setting:ShowWindow(1)
end

function Battle_ritual_priority_change(ctrl)
    local new_priority = tonumber(ctrl:GetText())
    local skill_id_str = ctrl:GetUserValue("SKILL_ID")
    local skills = g.Battle_ritual_settings.skills
    if skills and skills[skill_id_str] then
        for s_id, data in pairs(skills) do
            if s_id ~= skill_id_str and data.priority >= new_priority then
                data.priority = data.priority + 1
            end
        end
        skills[skill_id_str].priority = new_priority
    end
    Battle_ritual_save_settings()
    Battle_ritual_settings_frame()
    return 0
end

function Battle_ritual_priority(parent, ctrl)
    local priority = tonumber(ctrl:GetText())
    if priority > 0 then
        ctrl:RunUpdateScript("Battle_ritual_priority_change", 0.5)
    end
end

function Battle_ritual_remove(parent, ctrl, skill_id_str)
    local ctrl_name = ctrl:GetName()
    if string.find(ctrl_name, "skill") then
        g.Battle_ritual_settings.skills[skill_id_str] = nil
    else
        g.Battle_ritual_settings.skills[skill_id_str].buff_id = 0
    end
    Battle_ritual_save_settings()
    Battle_ritual_settings_frame()
end

function Battle_ritual_skill_list_open(frame, add, ctrl_text, index)
    local skill_list = ui.GetFrame(addon_name_lower .. "Battle_ritual_skill_list")
    if not skill_list then
        skill_list = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "Battle_ritual_skill_list", 0, 0, 10, 10)
        AUTO_CAST(skill_list)
        skill_list:SetSkinName("test_frame_low")
        skill_list:Resize(500, 1005)
        skill_list:SetPos(720, 30)
        skill_list:SetLayerLevel(999)
        local title_text = skill_list:CreateOrGetControl('richtext', 'title_text', 15, 15, 10, 30)
        AUTO_CAST(title_text)
        title_text:SetText("{#000000}{s20}Skill List")
        local search_edit =
            skill_list:CreateOrGetControl("edit", "search_edit", title_text:GetWidth() + 30, 10, 305, 38)
        AUTO_CAST(search_edit)
        search_edit:SetFontName("white_18_ol")
        search_edit:SetTextAlign("left", "center")
        search_edit:SetSkinName("inventory_serch")
        search_edit:SetEventScript(ui.ENTERKEY, "Battle_ritual_skill_list_search")
        search_edit:SetEventScriptArgNumber(ui.ENTERKEY, index)
        local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 40, 38)
        AUTO_CAST(search_btn)
        search_btn:SetImage("inven_s")
        search_btn:SetGravity(ui.RIGHT, ui.TOP)
        search_btn:SetEventScript(ui.LBUTTONUP, "Battle_ritual_skill_list_search")
        local close_button = skill_list:CreateOrGetControl('button', 'close_button', 0, 0, 20, 20)
        AUTO_CAST(close_button)
        close_button:SetImage("testclose_button")
        close_button:SetGravity(ui.RIGHT, ui.TOP)
        close_button:SetEventScript(ui.LBUTTONUP, "Battle_ritual_frame_close")
    end
    local skill_gb = skill_list:CreateOrGetControl("groupbox", "skill_gb", 10, 50, 480, skill_list:GetHeight() - 60)
    AUTO_CAST(skill_gb)
    skill_gb:SetSkinName("bg")
    skill_gb:RemoveAllChild()
    local cls_list, count = GetClassList("Skill")
    local y = 0
    for i = 0, count - 1 do
        local skill_cls = GetClassByIndexFromList(cls_list, i)
        if skill_cls then
            local skill_id = skill_cls.ClassID
            local skill_cls_name = skill_cls.ClassName
            local skill_engname = skill_cls.EngName
            local skill_caption = skill_cls.Caption
            local skill_name = dictionary.ReplaceDicIDInCompStr(skill_cls.Name)
            if ctrl_text == "" or (ctrl_text ~= "" and string.find(skill_name, ctrl_text)) then
                local skill_slot = skill_gb:CreateOrGetControl('slot', 'skill_slot' .. i, 10, y + 5, 30, 30)
                AUTO_CAST(skill_slot)
                local image_name = "icon_" .. skill_cls.Icon
                if skill_id > 10000 then
                    if not string.find(skill_cls_name, "^Mon_") and not string.find(skill_engname, "plzInputEngName") and
                        not string.find(skill_name, "_") and not string.find(skill_name, "TEST") then
                        if ctrl_text == "" or (ctrl_text ~= "" and string.find(skill_name, ctrl_text)) then
                            SET_SLOT_IMG(skill_slot, image_name)
                            local icon = CreateIcon(skill_slot)
                            AUTO_CAST(icon)
                            SET_SKILL_TOOLTIP_BY_TYPE(icon, skill_id)
                            local skill_set = skill_gb:CreateOrGetControl('button', 'skill_set' .. skill_id, 45, y + 5,
                                40, 30)
                            AUTO_CAST(skill_set)
                            skill_set:SetText("{ol}Add")
                            skill_set:SetSkinName("test_cardtext_btn")
                            skill_set:SetTextTooltip(g.lang == "Japanese" and "{ol}スキル追加" or "{ol}Add Skill")
                            skill_set:SetEventScript(ui.LBUTTONUP, "Battle_ritual_add_skill")
                            skill_set:SetEventScriptArgString(ui.LBUTTONUP, skill_id)
                            skill_set:SetEventScriptArgNumber(ui.LBUTTONUP, index)
                            local skill_text = skill_gb:CreateOrGetControl('richtext', 'skill_text' .. skill_id, 90,
                                y + 10, 200, 30)
                            AUTO_CAST(skill_text)
                            skill_text:SetText("{ol}" .. skill_id .. " : " .. skill_name)
                            skill_text:AdjustFontSizeByWidth(380)
                            y = y + 35
                        end
                    end
                end
            end
        end

    end
    skill_list:ShowWindow(1)
end

function Battle_ritual_skill_list_search(frame, ctrl, str, index)
    local search_edit = GET_CHILD_RECURSIVELY(frame, "search_edit")
    local ctrl_text = search_edit:GetText()
    if ctrl_text ~= "" then
        Battle_ritual_skill_list_open(frame, ctrl, ctrl_text, index)
    else
        Battle_ritual_skill_list_open(frame, ctrl, "", index)
    end
end

function Battle_ritual_add_skill(parent, ctrl, skill_id_str, index)
    local ctrl_name = ctrl:GetName()
    if string.find(ctrl_name, "skill_edit_") then
        ctrl:RunUpdateScript("Battle_ritual_setting_change_skill_edit", 0.5)
    else
        local setting = ui.GetFrame(addon_name_lower .. "Battle_ritual_setting")
        local skill_edit = GET_CHILD_RECURSIVELY(setting, "skill_edit_" .. index)
        skill_edit:SetText(skill_id_str)
        ctrl:SetUserValue("SKILL_ID", skill_id_str)
        Battle_ritual_setting_change_skill_edit(ctrl)
    end
end

function Battle_ritual_setting_change_skill_edit(ctrl)
    local user_val = ctrl:GetUserValue("SKILL_ID")
    local new_id_str = (user_val == "None" or user_val == "") and ctrl:GetText() or user_val
    local orig_id_str = ctrl:GetUserValue("ORIG_SKILL_ID")
    local skills = g.Battle_ritual_settings.skills
    local new_skill_cls = GetClassByType("Skill", tonumber(new_id_str))
    if not new_skill_cls then
        if skills[orig_id_str] then
            skills[orig_id_str] = nil
            Battle_ritual_save_settings()
        end
        Battle_ritual_settings_frame()
        return 0
    end
    if not skills[new_id_str] then
        local new_data = {
            priority = 0,
            buff_id = 0
        }
        local old_data = skills[orig_id_str]
        if old_data then
            new_data.priority = old_data.priority
            skills[orig_id_str] = nil
        else
            local max_priority = 0
            for _, data in pairs(skills) do
                if data.priority and data.priority > max_priority then
                    max_priority = data.priority
                end
            end
            new_data.priority = max_priority + 1
        end
        skills[new_id_str] = new_data
        Battle_ritual_save_settings()
        Battle_ritual_settings_frame()
    end
    return 0
end

function Battle_ritual_buff_list_open(frame, ctrl, ctrl_text, skill_id)
    local buff_list = ui.GetFrame(addon_name_lower .. "Battle_ritual_buff_list")
    if not buff_list then
        buff_list = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "Battle_ritual_buff_list", 0, 0, 10, 10)
        AUTO_CAST(buff_list)
        buff_list:SetSkinName("test_frame_low")
        buff_list:Resize(500, 1005)
        buff_list:SetPos(720, 30)
        buff_list:SetLayerLevel(999)
        local title_text = buff_list:CreateOrGetControl('richtext', 'title_text', 15, 15, 10, 30)
        AUTO_CAST(title_text)
        title_text:SetText("{#000000}{s20}Buff List")
        local search_edit = buff_list:CreateOrGetControl("edit", "search_edit", title_text:GetWidth() + 30, 10, 305, 38)
        AUTO_CAST(search_edit)
        search_edit:SetFontName("white_18_ol")
        search_edit:SetTextAlign("left", "center")
        search_edit:SetSkinName("inventory_serch")
        search_edit:SetEventScript(ui.ENTERKEY, "Battle_ritual_buff_list_search")
        search_edit:SetEventScriptArgNumber(ui.ENTERKEY, skill_id)
        local search_btn = search_edit:CreateOrGetControl("button", "search_btn", 0, 0, 40, 38)
        AUTO_CAST(search_btn)
        search_btn:SetImage("inven_s")
        search_btn:SetGravity(ui.RIGHT, ui.TOP)
        search_btn:SetEventScript(ui.LBUTTONUP, "Battle_ritual_buff_list_search")
        search_btn:SetEventScriptArgNumber(ui.LBUTTONUP, skill_id)
        local close_button = buff_list:CreateOrGetControl('button', 'close_button', 0, 0, 20, 20)
        AUTO_CAST(close_button)
        close_button:SetImage("testclose_button")
        close_button:SetGravity(ui.RIGHT, ui.TOP)
        close_button:SetEventScript(ui.LBUTTONUP, "Battle_ritual_frame_close")
    end
    local buff_list_gb = buff_list:CreateOrGetControl("groupbox", "buff_list_gb", 10, 50, 480,
        buff_list:GetHeight() - 60)
    AUTO_CAST(buff_list_gb)
    buff_list_gb:SetSkinName("bg")
    buff_list_gb:RemoveAllChild()
    local cls_list, count = GetClassList("Buff")
    local y = 0
    for i = 0, count - 1 do
        local buff_cls = GetClassByIndexFromList(cls_list, i)
        if buff_cls then
            local buff_id = buff_cls.ClassID
            local buff_name = dictionary.ReplaceDicIDInCompStr(buff_cls.Name)
            if ctrl_text == "" or (ctrl_text ~= "" and string.find(buff_name, ctrl_text)) then
                local buff_slot = buff_list_gb:CreateOrGetControl('slot', 'buffslot' .. i, 10, y + 5, 30, 30)
                AUTO_CAST(buff_slot)
                local image_name = GET_BUFF_ICON_NAME(buff_cls)
                if image_name == "icon_None" then
                    image_name = "icon_item_nothing"
                end
                if buff_name ~= "None" then
                    SET_SLOT_IMG(buff_slot, image_name)
                    local icon = CreateIcon(buff_slot)
                    AUTO_CAST(icon)
                    icon:SetTooltipType('buff')
                    icon:SetTooltipArg(buff_name, buff_id, 0)
                    local buff_set = buff_list_gb:CreateOrGetControl('button', 'buff_set' .. buff_id, 45, y + 5, 40, 30)
                    AUTO_CAST(buff_set)
                    buff_set:SetText("{ol}Add")
                    buff_set:SetSkinName("test_cardtext_btn")
                    buff_set:SetTextTooltip(g.lang == "Japanese" and "{ol}バフ追加" or "{ol}Add Buff")
                    buff_set:SetEventScript(ui.LBUTTONUP, "Battle_ritual_add_buff")
                    buff_set:SetEventScriptArgString(ui.LBUTTONUP, buff_id)
                    buff_set:SetEventScriptArgNumber(ui.LBUTTONUP, skill_id)
                    local buff_text = buff_list_gb:CreateOrGetControl('richtext', 'buff_text' .. buff_id, 90, y + 10,
                        200, 30)
                    AUTO_CAST(buff_text)
                    buff_text:SetText("{ol}" .. buff_id .. " : " .. buff_name)
                    buff_text:AdjustFontSizeByWidth(380)
                    y = y + 35
                end
            end
        end
    end
    buff_list:ShowWindow(1)
end

function Battle_ritual_buff_list_search(frame, ctrl, str, skill_id)
    local search_edit = GET_CHILD_RECURSIVELY(frame, "search_edit")
    local ctrl_text = search_edit:GetText()
    if ctrl_text ~= "" then
        Battle_ritual_buff_list_open(frame, ctrl, ctrl_text, skill_id)
    else
        Battle_ritual_buff_list_open(frame, ctrl, "", skill_id)
    end
end

function Battle_ritual_add_buff(parent, ctrl, buff_id_str, skill_id)
    local ctrl_name = ctrl:GetName()
    if string.find(ctrl_name, "buff_edit") then
        ctrl:SetUserValue("BUFF_ID", tonumber(ctrl:GetText()))
        ctrl:RunUpdateScript("Battle_ritual_setting_change_buff_edit", 0.5)
    else
        local buff_cls = GetClassByType("Buff", tonumber(buff_id_str))
        local s_id_str = tostring(skill_id)
        if g.Battle_ritual_settings.skills[s_id_str] then
            if buff_cls then
                g.Battle_ritual_settings.skills[s_id_str].buff_id = tonumber(buff_id_str)
            else
                g.Battle_ritual_settings.skills[s_id_str].buff_id = 0
            end
            Battle_ritual_save_settings()
            Battle_ritual_settings_frame()
        end
    end
end

function Battle_ritual_setting_change_buff_edit(ctrl)
    local buff_id = ctrl:GetUserIValue("BUFF_ID")
    local skill_id_str = ctrl:GetUserValue("SKILL_ID")
    if g.Battle_ritual_settings.skills[skill_id_str] then
        local buff_cls = GetClassByType("Buff", buff_id)
        if not buff_cls then
            g.Battle_ritual_settings.skills[skill_id_str].buff_id = 0
        else
            g.Battle_ritual_settings.skills[skill_id_str].buff_id = buff_id
        end
    end
    Battle_ritual_save_settings()
    Battle_ritual_settings_frame()
end

function Battle_ritual_frame_close(frame)
    ui.DestroyFrame(frame:GetName())
    if frame:GetName() == addon_name_lower .. "Battle_ritual_setting" then
        ui.DestroyFrame(addon_name_lower .. "Battle_ritual_skill_list")
        ui.DestroyFrame(addon_name_lower .. "Battle_ritual_buff_list")
    end
end

function Battle_ritual_REQ_PLAYER_CONTENTS_RECORD(frame, type)
    local _nexus_addons = ui.GetFrame("_nexus_addons")
    _nexus_addons:RunUpdateScript("Battle_ritual_overlord_off", 0.1)
end

function Battle_ritual_overlord_off(_nexus_addons)
    local buff = info.GetBuff(session.GetMyHandle(), 40049)
    if not buff then
        return 0
    end
    local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
    for i = 1, 40 do
        local slot = GET_CHILD_RECURSIVELY(quickslotnexpbar, "slot" .. i)
        AUTO_CAST(slot)
        local icon = slot:GetIcon()
        if icon then
            AUTO_CAST(icon)
            local icon_info = icon:GetInfo()
            if icon_info then
                local category = icon_info:GetCategory()
                if category == "Skill" then
                    local buff_id = icon_info.type
                    if buff_id == 100085 then
                        local current_cooldown = ICON_UPDATE_SKILL_COOLDOWN(icon)
                        if current_cooldown == 0 then
                            control.Skill(buff_id)
                        end
                        return 1
                    end
                end
            end
        end
    end
end]] --[[local text_needs_trans = native_lang_is_translation_msg(proc_msg)
    local name_needs_trans = native_lang_is_translation(original_name)
    local has_item_link = (g.chat_ids[tostring(chat_id)].separate_msg ~= "None")
    if text_needs_trans or name_needs_trans or has_item_link then
        local should_translate = true

        if g.lang == "ja" then
            if WITH_JAPANESE(org_msg) and not WITH_HANGLE(org_msg) then
                if WITH_JAPANESE(original_name) and not WITH_HANGLE(original_name) then
                    should_translate = false
                end
            end
        elseif g.lang == "ko" then
            if WITH_HANGLE(org_msg) and not WITH_JAPANESE(org_msg) then
                if WITH_HANGLE(original_name) and not WITH_JAPANESE(original_name) then
                    should_translate = false
                end
            end
        end
        if should_translate or has_item_link then

        end
    end]] --[[function Always_status_load_settings()
    g.always_status_path = string.format("../addons/%s/%s/always_status.json", addon_name_lower, g.active_id)
    g.always_status_old_path = string.format("../addons/%s/settings.json", "always_status")
    local settings = g.load_json(g.always_status_path)
    if not settings then
        settings = g.load_json(g.always_status_old_path)
    end
    local ver = 1.1
    if not settings or not settings.ver or settings.ver < ver then
        settings = {
            ver = ver,
            base = {
                frame_X = 0,
                frame_Y = 0,
                enable = 1,
                color = {}
            },
            chars = {}
        }
        for _, status_info in ipairs(always_status_master_list) do
            settings.base.color[status_info.key] = always_status_group_colors[status_info.group] or "{#FFFFFF}"
        end
        for i = 1, 10 do
            local set_num = tostring(i)
            settings[set_num] = {
                memo = "free memo " .. i
            }
            for _, status_info in ipairs(always_status_master_list) do
                settings[set_num][status_info.key] = status_info.on or 0
            end
        end
    elseif not settings.base then
        local new_settings = {
            base = {
                frame_X = 0,
                frame_Y = 0,
                enable = settings.enable or 0,
                color = settings.color or {}
            },
            chars = {}
        }
        for k, v in pairs(settings) do
            local num = tonumber(k)
            if num then
                if num >= 1 and num <= 10 then
                    local set_key = tostring(k)
                    new_settings[set_key] = v
                    for _, status_info in ipairs(always_status_master_list) do
                        if new_settings[set_key][status_info.key] == nil then
                            new_settings[set_key][status_info.key] = status_info.on or 0
                        end
                    end
                elseif num > 100 then
                    new_settings.chars[tostring(k)] = {
                        on = v.use or 1,
                        use_set = v.key or 1
                    }
                end
            end
        end
        settings = new_settings
    end
    if not settings.base.color then
        settings.base.color = {}
    end
    for _, status_info in ipairs(always_status_master_list) do
        if not settings.base.color[status_info.key] then
            settings.base.color[status_info.key] = always_status_group_colors[status_info.group] or "{#FFFFFF}"
        end
    end
    for i = 1, 10 do
        local set_num = tostring(i)
        if not settings[set_num] then
            settings[set_num] = {
                memo = "free memo " .. i
            }
        end
        for _, status_info in ipairs(always_status_master_list) do
            if settings[set_num][status_info.key] == nil then
                settings[set_num][status_info.key] = status_info.on or 0
            end
        end
    end
    g.always_status_settings = settings
    local cid_str = tostring(g.cid)
    if not g.always_status_settings.chars[cid_str] then
        g.always_status_settings.chars[cid_str] = {
            use_set = 1,
            on = 1
        }
    end
    Always_status_save_settings()
end]] --[[function Sub_map_update_monster(sub_map) -- 雑魚は画面に映ってる分しか取れない。仕様っぽい。チャレンジでは取れる
    local gbox = GET_CHILD(sub_map, "gbox")
    local icon_size = sub_map:GetUserIValue("ICON_SIZE")
    g.sub_map_handles = g.sub_map_handles or {}
    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 5000, 'ENEMY')
    for i = 1, selected_objects_count do
        local handle = GetHandle(selected_objects[i])
        if handle and info.IsMonster(handle) == 1 then
            local actor = world.GetActor(handle)
            if actor then
                local cls_name = info.GetMonsterClassName(handle)
                local mon_cls = GetClass("Monster", cls_name)
                if mon_cls and TryGetProp(mon_cls, "MonRank", "None") ~= "Boss" and
                    not g.sub_map_handles[tostring(handle)] then
                    g.sub_map_handles[tostring(handle)] = true
                    local mon_pic = GET_CHILD_RECURSIVELY(gbox, "_MONPOS_" .. handle)
                    if not mon_pic then
                        mon_pic = gbox:CreateOrGetControl("picture", "_MONPOS_" .. handle, 0, 0, icon_size / 2,
                            icon_size / 2)
                        AUTO_CAST(mon_pic)
                        mon_pic:SetUserValue("HANDLE", handle)
                        local img_name = "colonymonster"
                        mon_pic:SetImage(img_name)
                        mon_pic:SetEnableStretch(1)
                        local map_prop = session.GetCurrentMapProp()
                        local map_pic = GET_CHILD_RECURSIVELY(sub_map, "map_pic")
                        AUTO_CAST(map_pic)
                        if map_pic then
                            local world_pos = actor:GetPos()
                            local pos =
                                map_prop:WorldPosToMinimapPos(world_pos, map_pic:GetWidth(), map_pic:GetHeight())
                            local init_x = pos.x - mon_pic:GetWidth() / 2
                            local init_y = pos.y - mon_pic:GetHeight() / 2
                            mon_pic:SetOffset(init_x, init_y)
                        end
                        mon_pic:ShowWindow(1)
                        if not mon_pic:HaveUpdateScript("Sub_map_monpic_auto_update") then
                            mon_pic:RunUpdateScript("sub_map_monpic_auto_update", 0.5)
                        end
                    end
                end
            end
        end
    end
end]] --[[
function g.setup_hook_and_event_before_after(my_addon, origin_func_name, my_func_name, bool, before_after)
    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end
    local origin_func = g.FUNCS[origin_func_name]
    if bool == nil then
        bool = true
    end
    local function hooked_function(...)
        if bool == true then
            if before_after == "before" then
                _G[my_func_name](...)
            end
            local results = {origin_func(...)}
            if before_after == "after" then
                _G[my_func_name](...)
            end
            return table.unpack(results)
        else
            imcAddOn.BroadMsg(origin_func_name, ...)
            return
        end
    end
    _G[origin_func_name] = hooked_function
    if not bool then
        g.REGISTER = g.REGISTER or {}
        if not g.REGISTER[origin_func_name .. my_func_name] then
            g.REGISTER[origin_func_name .. my_func_name] = true
            my_addon:RegisterMsg(origin_func_name, my_func_name)
        end
    end
end]] 
