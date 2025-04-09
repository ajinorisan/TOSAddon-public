-- v1.0.0 キャラ一覧表示
-- v1.0.1 なんやかんや修正
-- v1.0.2 バラック表示諦めた。酔うてるししゃあない。
-- v1.0.3 書き直し。処理を極力シンプルに。
-- v1.0.4 他に干渉しない様に
-- v1.0.5 速攻バグ修正
-- v1.0.6 設定ジョブ取れる様に。
-- v1.0.7 コンテキスト表示切替
-- v1.0.8 indun_list_viewerと連携バグってたの修正
local addonName = "INSTANTCC"
local addonNameLower = string.lower(addonName)

local author = "ebisuke"
local ver = "1.0.8"
local basever = "0.0.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require("json")

local active_id = session.loginInfo.GetAID()
g.settings_file_path = string.format('../addons/%s/%s.json', addonNameLower, active_id)

local base = {}
function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)
    -- bool: true なら元の関数を実行後イベント、false/nil なら元の関数を実行せずイベント発行 (my_func_name はイベントハンドラとして呼ばれる)
    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end

    local origin_func = _G[origin_func_name]

    local function hooked_function(...)
        local original_results
        local original_success = false

        if bool == true then
            original_results = {pcall(origin_func, ...)}
            original_success = original_results[1]

            if not original_success then
                print(string.format("Error in original/previous hook for '%s': %s", origin_func_name,
                                    tostring(original_results[2])))
                return
            end
        end
        g.ARGS = g.ARGS or {}
        imcAddOn.BroadMsg(origin_func_name)

        g.ARGS[origin_func_name] = {...} -- この関数とセット運用：g.get_event_args(origin_func_name)

        if bool == true and original_success then
            return table.unpack(original_results, 2, #original_results)
        else
            return -- nil を返す
        end

    end

    _G[origin_func_name] = hooked_function
    my_addon:RegisterMsg(origin_func_name, my_func_name)

end

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

function INSTANTCC_SAVE_SETTINGS()
    acutil.saveJSON(g.settings_file_path, g.settings)
end

function INSTANTCC_LOAD_SETTINGS()
    local settings = acutil.loadJSON(g.settings_file_path)

    if not settings then
        settings = {
            characters = {},
            per_barracks = false
        }
    elseif not settings.characters then
        settings.characters = {}
    elseif not settings.per_barracks then
        settings.per_barracks = false
    end

    g.settings = settings

    INSTANTCC_SAVE_SETTINGS()
end

function INSTANTCC_SORT_CHAR_DATA()

    local account_info = session.barrack.GetMyAccount()
    local pc_count = account_info:GetPCCount()

    g.settings.characters = g.settings.characters or {}

    for i = 0, pc_count - 1 do
        local pc_info = account_info:GetPCByIndex(i)
        local pc_apc = pc_info:GetApc()
        local pc_name = pc_apc:GetName()
        local pc_cid = pc_info:GetCID()
        local gender = pc_apc:GetGender()
        -- local jobid = pc_apc:GetJob()
        local pc_info = session.barrack.GetMyAccount():GetByStrCID(pc_cid);

        local jobid = pc_info:GetRepID() or pc_apc:GetJob()
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
    INSTANTCC_SAVE_SETTINGS()
end

function INSTANTCC_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    g.lang = option.GetCurrentCountry()

    INSTANTCC_LOAD_SETTINGS()

    g.retry = nil
    g.do_cc = nil
    g.layer = g.layer or (g.settings and g.settings.characters and g.settings.characters.layer) or 1

    g.setup_hook_and_event(addon, "BARRACK_START_FRAME_OPEN", "INSTANTCC_BARRACK_START_FRAME_OPEN", true)
    g.setup_hook_and_event(addon, "APPS_TRY_MOVE_BARRACK", "INSTANTCC_APPS_TRY_MOVE_BARRACK", false)
    -- .SetupHook(INSTANTCC_BARRACK_START_FRAME_OPEN, "BARRACK_START_FRAME_OPEN")
    -- acutil.setupEvent(addon, "BARRACK_START_FRAME_OPEN", "INSTANTCC_BARRACK_START_FRAME_OPEN");
    -- g.SetupHook(INSTANTCC_APPS_TRY_MOVE_BARRACK, "APPS_TRY_MOVE_BARRACK")
    -- g.SetupHook(INSTANTCC_BARRACK_TO_GAME, "BARRACK_TO_GAME")
    INSTANTCC_SORT_CHAR_DATA()

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

function INSTANTCC_BARRACK_START_FRAME_OPEN()

    local bc_frame = ui.GetFrame("barrack_charlist")
    if bc_frame then
        g.layer = tonumber(bc_frame:GetUserValue("SelectBarrackLayer"))
    end

    local barrack_gamestart = ui.GetFrame("barrack_gamestart")

    local hidelogin = GET_CHILD_RECURSIVELY(barrack_gamestart, "hidelogin")
    AUTO_CAST(hidelogin)
    barrack.SetHideLogin(1)
    hidelogin:SetCheck(1)

    local start_game = GET_CHILD_RECURSIVELY(barrack_gamestart, "start_game");
    AUTO_CAST(start_game)
    start_game:SetEventScript(ui.LBUTTONUP, "BARRACK_TO_GAME")

    if g.do_cc and not g.retry then
        g.retry = 0
        INSTANTCC_CHANGE()
    end

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
    tooltip_frame:SetPos(g.go_x - notice:GetWidth() - 10, g.go_y + 250)

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
    INSTANTCC_SAVE_SETTINGS()
end

function INSTANTCC_APPS_TRY_MOVE_BARRACK()
    INSTANTCC_APPS_TRY_MOVE_BARRACK_(1)
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

function INSTANTCC_APPS_TRY_MOVE_BARRACK_(barrack_num)

    local context = ui.CreateContextMenu("INSTANTCC_SELECT_CHARACTOR", "Barrack Charactor List", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "Return To Barrack", "INSTANTCC_DO_CC()")

    if not g.settings.per_barracks then

        for i = 1, #g.settings.characters do
            local info = g.settings.characters[i]
            local pc_name = info.name
            local job_cls = GetClassByType("Job", info.jobid)
            local job_name = GET_JOB_NAME(job_cls, info.gender)
            local str = "Lv" .. info.level .. " " .. pc_name .. " (" .. job_name .. ")"
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
                local str = "Lv" .. info.level .. " " .. pc_name .. " (" .. job_name .. ")"
                ui.AddContextMenuItem(context, str, string.format("INSTANTCC_DO_CC('%s',%d)", info.cid, info.layer))
            end
        end

    end
    ui.OpenContextMenu(context)
end

function INSTANTCC_CHANGE()
    barrack.SelectBarrackLayer(g.do_cc.layer)
    ReserveScript(string.format("barrack.SelectCharacterByCID('%s')", g.do_cc.cid), 0.1)
    ReserveScript("INSTANTCC_TOGAME()", 0.2)
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

function INSTANTCC_TOGAME()

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
    g.layer = tonumber(bc_frame:GetUserValue("SelectBarrackLayer"))
    BARRACK_TO_GAME()
end

