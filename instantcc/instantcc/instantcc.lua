-- v1.0.0 キャラ一覧表示
-- v1.0.1 なんやかんや修正
-- v1.0.2 バラック表示諦めた。酔うてるししゃあない。
-- v1.0.3 書き直し。処理を極力シンプルに。
-- v1.0.4 他に干渉しない様に
-- v1.0.5 速攻バグ修正
-- v1.0.6 設定ジョブ取れる様に。
-- v1.0.7 コンテキスト表示切替
-- v1.0.8 indun_list_viewerと連携バグってたの修正
-- v1.0.9 ReserveScriptを無くした。色々書き換えた。
-- v1.1.0 キャラ順バグるの修正
-- v1.1.1 レイヤーの取り方修正。バラックでのフックの結果をグローバルに置くように。
-- v1.1.2 リターンバラックで戻った時にゲームに接続できないバグ修正。
-- v1.1.3 バラックレイヤー取れないバグ修正
local addon_name = "INSTANTCC"
local addon_name_lower = string.lower(addon_name)

local author = "ebisuke"
local ver = "1.1.3"
local basever = "0.0.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local json = require("json")

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
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

    local active_id = session.loginInfo.GetAID()
    g.settings_path = string.format('../addons/%s/%s.json', addon_name_lower, active_id)
    g.log_file_path = string.format('../addons/%s/debug_log.txt', addon_name_lower)
end
g.mkdir_new_folder()

function g.log_to_file(message)

    local file, err = io.open(g.log_file_path, "a")

    if file then
        local timestamp = os.date("[%Y-%m-%d %H:%M:%S] ")
        file:write(timestamp .. tostring(message) .. "\n")
        file:close()
    end
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
        local str = json.encode(tbl)
        file:write(str)
        file:close()
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

    local settings = load_json(g.settings_path)

    if not settings then
        settings = {
            characters = {},
            per_barracks = false
        }
    end

    if not settings.characters then
        settings.characters = {}
    end

    if not settings.per_barracks then
        settings.per_barracks = false
    end

    g.settings = settings
    g.save_settings()
end

function INSTANTCC_SORT_CHAR_DATA()
    local account_info = session.barrack.GetMyAccount()
    if not account_info then
        return
    end

    local all_names = {}
    local barrack_max_pc = account_info:GetBarrackPCCount()
    for i = 0, barrack_max_pc - 1 do
        local b_char = account_info:GetBarrackPCByIndex(i)
        if b_char then
            local b_name = b_char:GetName()
            if b_name then
                all_names[b_name] = true
            end
        end
    end

    g.settings.characters = g.settings.characters or {}

    local new_char_list = {}

    for _, char_data in ipairs(g.settings.characters) do
        if char_data and char_data.name and all_names[char_data.name] then
            table.insert(new_char_list, char_data)
        end
    end
    g.settings.characters = new_char_list

    local pc_count = account_info:GetPCCount()
    for i = 0, pc_count - 1 do
        local pc_info = account_info:GetPCByIndex(i)
        local pc_apc = pc_info:GetApc()
        local pc_name = pc_apc:GetName()
        local pc_cid = pc_info:GetCID()
        local gender = pc_apc:GetGender()
        local pc_info_cid = account_info:GetByStrCID(pc_cid);
        local jobid = pc_info_cid:GetRepID() or pc_apc:GetJob()
        local level = pc_apc:GetLv()

        local info = {
            name = pc_name,
            layer = g.layer,
            cid = pc_cid,
            jobid = jobid,
            gender = gender,
            level = level,
            order = i
        }

        local found = false
        for j, character in ipairs(g.settings.characters) do
            if character.cid == pc_cid then
                g.settings.characters[j] = info
                found = true
                break
            end
        end

        if not found then
            table.insert(g.settings.characters, info)
        end

    end

    local function compare_characters(a, b)

        if a.layer == b.layer then
            return a.order < b.order
        else
            return a.layer < b.layer
        end
    end

    table.sort(g.settings.characters, compare_characters)

    g.save_settings()

end

function INSTANTCC_BARRACK_START_FRAME_OPEN(...)

    local barrack_gamestart = ui.GetFrame("barrack_gamestart")
    if barrack_gamestart == nil then
        ReserveScript("INSTANTCC_BARRACK_START_FRAME_OPEN()", 0.1)
        return
    end

    local original_func = g.FUNCS["BARRACK_START_FRAME_OPEN"]
    local result

    if original_func then
        result = original_func(...)
    end

    local hidelogin = GET_CHILD_RECURSIVELY(barrack_gamestart, "hidelogin")

    hidelogin:SetCheck(1)
    barrack.SetHideLogin(1)

    local start_game = GET_CHILD(barrack_gamestart, "start_game")
    AUTO_CAST(start_game)
    start_game:SetEventScript(ui.LBUTTONUP, "BARRACK_TO_GAME")

    if g.do_cc and not g.retry then
        g.retry = 0
        INSTANTCC_CHANGE()
    end
    return result
end

function INSTANTCC_BARRACK_START_FRAME_OPEN_HOOK()
    g.FUNCS = g.FUNCS or {}
    local origin_func_name = "BARRACK_START_FRAME_OPEN"
    if _G[origin_func_name] then
        if not g.FUNCS[origin_func_name] then
            g.FUNCS[origin_func_name] = _G[origin_func_name]

        end
        _G[origin_func_name] = INSTANTCC_BARRACK_START_FRAME_OPEN
    end
end

function INSTANTCC_BARRACK_TO_GAME(...)

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

function INSTANTCC_BARRACK_TO_GAME_HOOK()
    g.FUNCS = g.FUNCS or {}
    local origin_func_name = "BARRACK_TO_GAME"
    if _G[origin_func_name] then
        if not g.FUNCS[origin_func_name] then
            g.FUNCS[origin_func_name] = _G[origin_func_name]
        end
        _G[origin_func_name] = INSTANTCC_BARRACK_TO_GAME
    end
end

g.first = true
function INSTANTCC_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.RAGISTER = {}
    g.lang = option.GetCurrentCountry()

    g.load_settings()

    g.retry = nil
    g.do_cc = nil
    g.layer = g.layer or (g.settings and g.settings.characters and g.settings.characters.layer) or 1
    g.setup_hook_and_event(addon, "APPS_TRY_MOVE_BARRACK", "INSTANTCC_APPS_TRY_MOVE_BARRACK", false)

    _G["norisan"] = _G["norisan"] or {}
    _G["norisan"]["HOOKS"] = _G["norisan"]["HOOKS"] or {}
    if not _G["norisan"]["HOOKS"]["BARRACK_START_FRAME_OPEN"] then
        _G["norisan"]["HOOKS"]["BARRACK_START_FRAME_OPEN"] = addon_name
        addon:RegisterMsg("GAME_START", "INSTANTCC_BARRACK_START_FRAME_OPEN_HOOK")
    end
    if not _G["norisan"]["HOOKS"]["BARRACK_TO_GAME"] then
        _G["norisan"]["HOOKS"]["BARRACK_TO_GAME"] = addon_name
        addon:RegisterMsg("GAME_START", "INSTANTCC_BARRACK_TO_GAME_HOOK")
    end
    if not g.first then
        addon:RegisterMsg("GAME_START_3SEC", "INSTANTCC_SORT_CHAR_DATA")
    else
        g.first = false
    end

    local apps = ui.GetFrame("apps")
    local go_barrackmode = GET_CHILD_RECURSIVELY(apps, "GO_BARRACKMODE")
    AUTO_CAST(go_barrackmode)
    go_barrackmode:SetEventScript(ui.RBUTTONUP, "INSTANTCC_DISPLAY_TOGGLE")
    go_barrackmode:SetEventScript(ui.MOUSEON, "INSTANTCC_TEXT_TOOLTIP")
    go_barrackmode:SetEventScriptArgString(ui.MOUSEON, "ON")
    go_barrackmode:SetEventScript(ui.MOUSEOFF, "INSTANTCC_TEXT_TOOLTIP")
    go_barrackmode:SetEventScriptArgString(ui.MOUSEOFF, "OFF")
    g.go_x = apps:GetX()
    g.go_y = apps:GetY()
end

function INSTANTCC_TEXT_TOOLTIP(frame, ctrl, str, num)
    local tooltip_frame = ui.CreateNewFrame("notice_on_pc", "tooltip_frame", 0, 0, 0, 0)
    AUTO_CAST(tooltip_frame)
    tooltip_frame:SetSkinName('bg')

    local notice = tooltip_frame:CreateOrGetControl("richtext", "notice", 5, 5)
    local text = g.lang == "Japanese" and "{ol}Instant CC{nl}右クリック: 表示方法を切替えます" or
                     "{ol}Instant CC{nl}Right click: Switch display"
    notice:SetText(text)
    tooltip_frame:Resize(notice:GetWidth() + 10, notice:GetHeight() + 10)

    local scene_width = 0
    if ui.GetSceneWidth() > 1920 then
        scene_width = ui.GetSceneWidth()
    else
        scene_width = 1920
    end
    tooltip_frame:SetPos(scene_width - notice:GetWidth() - 50, g.go_y + 250)
    tooltip_frame:SetLayerLevel(999)
    if str == "ON" then
        tooltip_frame:ShowWindow(1)
    else
        tooltip_frame:ShowWindow(0)
    end

end

function INSTANTCC_DISPLAY_TOGGLE(frame, ctrl, str, num)
    if not g.settings.per_barracks then
        g.settings.per_barracks = true
        ui.SysMsg(g.lang == "Japanese" and "バラック毎表示に切替えました" or
                      "Switched to per-barrack display")
    else
        g.settings.per_barracks = false
        ui.SysMsg(g.lang == "Japanese" and "一覧表示に切替えました" or "Switched to all list display")
    end
    g.save_settings()
end

function INSTANTCC_DO_CC(cid, layer)

    if cid then
        g.do_cc = {
            cid = cid,
            layer = layer
        }
        RUN_GAMEEXIT_TIMER("Barrack")
    else
        RUN_GAMEEXIT_TIMER("Barrack")
    end
end

function INSTANTCC_APPS_TRY_MOVE_BARRACK(received_addon, eventName)
    INSTANTCC_APPS_TRY_MOVE_BARRACK_(1)
end

function INSTANTCC_APPS_TRY_MOVE_BARRACK_(barrack_num)

    local context = ui.CreateContextMenu("INSTANTCC_SELECT_CHARACTOR", "{ol}Barrack Charactor List", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "Return To Barrack", "INSTANTCC_DO_CC()")

    if not g.settings.per_barracks then

        for i = 1, #g.settings.characters do
            local info = g.settings.characters[i]
            local pc_name = info.name
            local job_cls = GetClassByType("Job", info.jobid)
            local job_name = GET_JOB_NAME(job_cls, info.gender)
            job_name = string.gsub(dic.getTranslatedStr(job_name), "{s18}", "")

            local str = "Lv" .. info.level .. " " .. pc_name .. " (" .. job_name .. ")          "
            ui.AddContextMenuItem(context, str, string.format("INSTANTCC_DO_CC('%s',%d)", info.cid, info.layer))
        end

    else

        ui.AddContextMenuItem(context, "Barrack 1", string.format("INSTANTCC_APPS_TRY_MOVE_BARRACK_(%d)", 1))
        ui.AddContextMenuItem(context, "Barrack 2", string.format("INSTANTCC_APPS_TRY_MOVE_BARRACK_(%d)", 2))
        ui.AddContextMenuItem(context, "Barrack 3", string.format("INSTANTCC_APPS_TRY_MOVE_BARRACK_(%d)", 3))
        ui.AddContextMenuItem(context, "----------", "None")

        for i = 1, #g.settings.characters do

            local info = g.settings.characters[i]
            local layer = info.layer
            if barrack_num == layer then
                local pc_name = info.name
                local job_cls = GetClassByType("Job", info.jobid)
                local job_name = GET_JOB_NAME(job_cls, info.gender)
                job_name = string.gsub(dic.getTranslatedStr(job_name), "{s18}", "")
                local str = "Lv" .. info.level .. " " .. pc_name .. " (" .. job_name .. ")          "
                ui.AddContextMenuItem(context, str, string.format("INSTANTCC_DO_CC('%s',%d)", info.cid, info.layer))
            end
        end

    end
    ui.OpenContextMenu(context)
end

function INSTANTCC_CHANGE()
    barrack.SelectBarrackLayer(g.do_cc.layer)
    barrack.SelectCharacterByCID(g.do_cc.cid)
    local barrack_gamestart = ui.GetFrame("barrack_gamestart")
    barrack_gamestart:StopUpdateScript("INSTANTCC_TOGAME")
    barrack_gamestart:RunUpdateScript("INSTANTCC_TOGAME", 0.2)

end

function INSTANTCC_RETRY()
    g.retry = g.retry + 1

    if g.retry > #g.settings.characters then
        g.do_cc = nil
        app.BarrackToLogin()
        ui.SysMsg("[ICC] Failed to select character, please try manually select.")
        return
    end
    INSTANTCC_CHANGE()
end

function INSTANTCC_TOGAME(frame)

    local bpca = barrack.GetBarrackPCInfoByCID(g.do_cc.cid)
    if bpca == nil then

        INSTANTCC_RETRY()
        return
    end

    local bpc = barrack.GetGameStartAccount()
    if bpc == nil then
        INSTANTCC_RETRY()
        return
    end

    if bpc:GetCID() ~= g.do_cc.cid then
        INSTANTCC_RETRY()
        return
    end

    local charName = barrack.GetSelectedCharacterName()
    local bpacap = bpca:GetApc()
    if charName ~= bpacap:GetName() then
        INSTANTCC_RETRY()
        return
    end

    local bc_frame = ui.GetFrame("barrack_charlist")
    if bc_frame then
        g.layer = tonumber(bc_frame:GetUserValue("SelectBarrackLayer"))
    end

    _G["BARRACK_TO_GAME"]()

end

--[[function INSTANTCC_BARRACK_START_FRAME_OPEN(...)

    local barrack_gamestart = ui.GetFrame("barrack_gamestart")
    if barrack_gamestart == nil then
        ReserveScript("INSTANTCC_BARRACK_START_FRAME_OPEN()", 0.1)
        return
    end

    local original_func = g.FUNCS["BARRACK_START_FRAME_OPEN"]
    local result

    if original_func then
        result = original_func(...)
    end

    if barrack_gamestart then
        local hidelogin = GET_CHILD_RECURSIVELY(barrack_gamestart, "hidelogin")
        if hidelogin then
            hidelogin:SetCheck(1)
            barrack.SetHideLogin(1)
        end
    end

    if g.do_cc and not g.retry then
        g.retry = 0
        INSTANTCC_CHANGE()
    end

    return result
end]]
-- ■■■ INSTANTCC_BARRACK_TO_GAME のログ強化版 ■■■
--[[function INSTANTCC_BARRACK_TO_GAME(...)
    g.log_to_file(string.format("[ICC] BARRACK_TO_GAME called. Args count: %d", select("#", ...)))

    local bc_frame = ui.GetFrame("barrack_charlist")
    if bc_frame then
        g.layer = tonumber(bc_frame:GetUserValue("SelectBarrackLayer")) -- tonumber(nil) に注意
        g.log_to_file(string.format("[ICC] g.layer set to: %s", tostring(g.layer)))
    else
        g.log_to_file("[ICC] barrack_charlist frame not found.")
    end

    local original_func = g.FUNCS["BARRACK_TO_GAME"] -- g は INSTANTCC の g よ
    local result

    if original_func then
        g.log_to_file("[ICC] Calling original BARRACK_TO_GAME...")
        local success, res_or_err = pcall(original_func, ...)
        if success then
            result = res_or_err
            g.log_to_file(string.format("[ICC] Original BARRACK_TO_GAME returned: %s", tostring(result)))
        else
            g.log_to_file(string.format("[ICC] ERROR calling original BARRACK_TO_GAME: %s", tostring(res_or_err)))
        end
    else
        g.log_to_file("[ICC] Original BARRACK_TO_GAME not found in g.FUNCS!")
    end

    g.log_to_file(string.format("[ICC] BARRACK_TO_GAME returning: %s", tostring(result)))
    return result
end]]
