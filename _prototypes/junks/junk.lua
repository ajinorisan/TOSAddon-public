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
end]==] --[[function indun_panel_frame_init()

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
