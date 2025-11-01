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

end]==] 
