-- v1.0.3 書き直し
-- v1.0.2 バラック表示諦めた。酔うてるししゃあない。
-- v1.0.1 なんやかんや修正
-- v1.0.0 キャラ一覧表示
local addonName = "INSTANTCC"
local addonNameLower = string.lower(addonName)
-- 作者名
local author = "ebisuke"
local ver = "1.0.3"
local basever = "0.0.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require("json")

local active_id = session.loginInfo.GetAID()
g.settingsFileLoc = string.format('../addons/%s/%s.json', addonNameLower, active_id)

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

function g.saveJSON(path, tbl)
    local file, err = io.open(path, "w")
    if err then
        return _, err
    end

    local s = json.encode(tbl)
    file:write(s)
    file:close()
end

function g.loadJSON(path)

    local file, err = io.open(path, "r")
    local table = nil

    if (err) then
        return _, err
    else
        local content = file:read("*all")
        file:close()
        table = json.decode(content)
        return table
    end

end

function INSTANTCC_BARRACK_TO_GAME()
    local frame = ui.GetFrame("barrack_charlist")
    local layer = tonumber(frame:GetUserValue("SelectBarrackLayer"))
    g.layer = layer

    local gsframe = ui.GetFrame("barrack_gamestart")
    local checkbtn = gsframe:GetChildRecursively("hidelogin")
    AUTO_CAST(checkbtn)
    checkbtn:SetCheck(1)
    barrack.SetHideLogin(1);

    base["BARRACK_TO_GAME"]()
end

function INSTANTCC_APPS_TRY_LOGOUT()
    g.settings.do_cc = nil
    INSTANTCC_SAVE_SETTINGS()
    base["APPS_TRY_LOGOUT"]()
    return
end

function INSTANTCC_CHANGE()
    ReserveScript(string.format("barrack.SelectBarrackLayer(%d)", g.settings.do_cc.layer), 0.1)
    ReserveScript(string.format("barrack.SelectCharacterByCID('%s')", g.settings.do_cc.cid), 0.2)

    -- INSTANTCC_BARRACK_TO_GAME()
    -- ReserveScript("barrack.SelectBarrackLayer(" .. ininfo.layer .. ")", 0.1)
    -- ReserveScript("barrack.SelectCharacterByCID('" .. ininfo.cid .. "')", 0.2)
    ReserveScript("INSTANTCC_TOGAME()", 0.3)
end

function INSTANTCC_RETRY()
    g.retries = g.retries + 1
    if g.retries > 15 then
        app.BarrackToLogin()
        ui.SysMsg("[ICC] Failed to select character, please try manually select.")
        return
    end
    INSTANTCC_CHANGE()
end

function INSTANTCC_TOGAME()
    local bpca = barrack.GetBarrackPCInfoByCID(g.settings.do_cc.cid)
    if bpca == nil then
        INSTANTCC_RETRY()
        return
    end
    local bpc = barrack.GetGameStartAccount()
    if bpc ~= nil then
        if (bpc:GetCID() ~= g.settings.do_cc.cid) then
            INSTANTCC_RETRY()
            return
        end
        local jobName = barrack.GetSelectedCharacterJob();
        local charName = barrack.GetSelectedCharacterName();

        local bpacap = bpca:GetApc();
        if (charName ~= bpacap:GetName()) then
            INSTANTCC_RETRY()
            return
        end
        local apc = bpc:GetApc()
        local jobid = apc:GetJob()
        local level = apc:GetLv()
        local JobCtrlType = GetClassString("Job", jobid, "CtrlType")
        config.SetConfig("LastJobCtrltype", JobCtrlType)
        config.SetConfig("LastPCLevel", level)
        local frame = ui.GetFrame("barrack_gamestart")
        local channels = GET_CHILD(frame, "channels", "ui::CDropList")
        local key = channels:GetSelItemIndex()
        app.BarrackToGame(key)
        return
    end

    INSTANTCC_RETRY()

end

function INSTANTCC_BARRACK_START_FRAME_OPEN(frame)
    INSTANTCC_BARRACK_START_FRAME_OPEN_(frame)
end

function INSTANTCC_BARRACK_START_FRAME_OPEN_(frame)
    if frame == nil then
        return;
    end

    local frame = ui.GetFrame("barrack_gamestart")
    local hidelogin = GET_CHILD_RECURSIVELY(frame, "hidelogin", "ui::CCheckBox");
    AUTO_CAST(hidelogin)
    hidelogin:SetCheck(1)
    barrack.SetHideLogin(1);
    hidelogin:SetCheck(barrack.IsHideLogin());

    g.retries = 0
    ReserveScript("INSTANTCC_CHANGE()", 0.1)

    local folder_path = string.format("../addons/%s", addonNameLower)
    local file_path = string.format("../addons/%s/test.txt", addonNameLower)
    local file = io.open(file_path, "w")

    if file then
        file:write(tostring(barrack.IsHideLogin()))
        file:close()
    end
end

-- マップ読み込み時処理（1度だけ）
function INSTANTCC_ON_INIT(addon, frame)

    frame = ui.GetFrame("instantcc")
    g.addon = addon
    g.frame = frame

    if g.layer == nil then
        g.layer = 9
    end

    g.SetupHook(INSTANTCC_APPS_TRY_MOVE_BARRACK, "APPS_TRY_MOVE_BARRACK")
    g.SetupHook(INSTANTCC_APPS_TRY_LOGOUT, "APPS_TRY_LOGOUT")
    g.SetupHook(INSTANTCC_BARRACK_TO_GAME, "BARRACK_TO_GAME")

    g.SetupHook(INSTANTCC_BARRACK_START_FRAME_OPEN, "BARRACK_START_FRAME_OPEN")

    INSTANTCC_LOAD_SETTINGS()

    local accountInfo = session.barrack.GetMyAccount()
    local cnt = accountInfo:GetPCCount()
    g.settings.charactors = g.settings.charactors or {}

    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetPCByIndex(i)
        local pcApc = pcInfo:GetApc()
        local pcName = pcApc:GetName()
        local pcCid = pcInfo:GetCID()
        local gender = pcApc:GetGender()
        local jobid = pcApc:GetJob()
        local level = pcApc:GetLv()

        local info = {
            name = pcName,
            layer = g.layer,
            cid = pcCid,
            job = jobid,
            gender = gender,
            level = level,
            order = i
        }

        local foundIndex = nil
        for index, character in ipairs(g.settings.charactors) do
            if character.cid == info.cid then
                foundIndex = index
                break
            end
        end

        if foundIndex then
            g.settings.charactors[foundIndex] = info
        else
            table.insert(g.settings.charactors, info)
        end
    end
    INSTANTCC_SAVE_SETTINGS()
end

function INSTANTCC_APPS_TRY_MOVE_BARRACK(a, b, c, d, bno)
    return INSTANTCC_APPS_TRY_MOVE_BARRACK2(a, b, c, d, bno)
end

function INSTANTCC_APPS_TRY_MOVE_BARRACK2(a, b, c, d, bno)
    bno = bno or 1
    ReserveScript('INSTANTCC_APPS_TRY_MOVE_BARRACK3(a,b,c,d,' .. bno .. ')', 0.25)
end

function INSTANTCC_DO_MOVE_BARRACK()
    g.settings.do_cc = nil
    INSTANTCC_SAVE_SETTINGS()
    base["APPS_TRY_MOVE_BARRACK"]()
    return
end

function INSTANTCC_APPS_TRY_MOVE_BARRACK3(a, b, c, d, bno)

    local function compareCharacters(a, b)
        if a.layer == b.layer then
            return a.order < b.order
        else
            return a.layer < b.layer
        end
    end

    local sortedSettings = {}
    for _, char in pairs(g.settings.charactors) do
        table.insert(sortedSettings, char)
    end

    table.sort(sortedSettings, compareCharacters)

    -- bno = bno or 1
    local context = ui.CreateContextMenu("INSTANTCC_SELECT_CHARACTOR", "Barrack Charactor List", 0, 0, 380, 0)

    ui.AddContextMenuItem(context, "Return To Barrack", "INSTANTCC_DO_MOVE_BARRACK()")
    -- local aidx = session.loginInfo.GetAID();
    -- local myHandle = session.GetMyHandle();
    -- local myGuildIdx = 0
    -- local myTeamName = info.GetFamilyName(myHandle)

    for i = 1, #g.settings.charactors do

        local char = sortedSettings[i]
        local pcName = char.name
        local jobCls = GetClassByType("Job", char.job)
        local jobName = GET_JOB_NAME(jobCls, char.gender)

        local str = "Lv" .. char.level .. " " .. pcName .. " (" .. jobName .. ")"
        ui.AddContextMenuItem(context, str, string.format("INSTANTCC_DO_CC('%s',%d)", char.cid, char.layer))
        -- ui.AddContextMenuItem(context, str, "INSTANTCC_DO_CC('" .. char.cid .. "'," .. char.layer .. ")")
    end
    -- context:Resize(400, context:GetHeight());
    ui.OpenContextMenu(context)
end

function INSTANTCC_DO_CC(cid, layer)
    -- CHAT_SYSTEM("[ICC]Attempt to CC.")
    if layer == 9 then
        layer = 1
    end
    g.layer = layer
    g.settings.do_cc = {
        cid = cid,
        layer = layer
    }
    INSTANTCC_SAVE_SETTINGS()
    base["APPS_TRY_MOVE_BARRACK"]()
    return
end

function INSTANTCC_SAVE_SETTINGS()
    g.saveJSON(g.settingsFileLoc, g.settings)
end

function INSTANTCC_LOAD_SETTINGS()
    local settings, err = g.loadJSON(g.settingsFileLoc)
    if not settings then
        settings = {
            charactors = {}
        }
    end
    g.settings = settings
    INSTANTCC_SAVE_SETTINGS()
end

--[[INSTANTCC_LOAD_SETTINGS()
if INSTANTCC_GetBarrackSystem_OLD == nil and GetBarrackSystem ~= INSTANTCC_GetBarrackSystem then
    INSTANTCC_GetBarrackSystem_OLD = GetBarrackSystem
    GetBarrackSystem = INSTANTCC_GetBarrackSystem
end

function INSTANTCC_GetBarrackSystem(actor)

    local brk = INSTANTCC_GetBarrackSystem_OLD(actor)
    local key = brk:GetCIDStr()
    local bpc = barrack.GetBarrackPCInfoByCID(key)

    if bpc == nil then
        return;
    end

    local bcframe = ui.GetFrame("barrack_charlist")
    local scrollBox = bcframe:GetChild("scrollBox")
    local order = scrollBox:GetChildCount()
    for i = 0, scrollBox:GetChildCount() - 1 do
        local child = scrollBox:GetChildByIndex(i);
        if string.find(child:GetName(), 'char_') ~= nil then
            local guid = child:GetUserValue("CID");
            if guid == key then
                order = i
                break
            end
        end
    end
    local pcInfo = session.barrack.GetMyAccount():GetByStrCID(key);
    local apc = bpc:GetApc()
    local gender = apc:GetGender()
    local jobid = pcInfo:GetRepID()

    local info = {
        name = actor:GetName(),
        layer = INSTANTCC_GetCurrentLayer(),
        cid = key,
        job = jobid,
        gender = gender,
        level = actor:GetLv(),
        order = order,
        server = GetServerGroupID(),
        aid = aidx
    }
    local found = false
    for i = 1, #g.settings.charactors do
        if g.settings.charactors[i].cid == key then
            found = i
            break
        end
    end
    if found == false then
        table.insert(g.settings.charactors, info)
    else
        g.settings.charactors[found] = info
    end

    -- cleanup
    local continue = false
    repeat
        continue = false
        for i = 1, #g.settings.charactors do

            if g.settings.charactors[i].layer == INSTANTCC_GetCurrentLayer() and g.settings.charactors[i].aid == aidx and
                g.settings.charactors[i].server == GetServerGroupID() then
                local bpc = barrack.GetBarrackPCInfoByCID(g.settings.charactors[i].cid)
                if bpc == nil then
                    table.remove(g.settings.charactors, i)
                    continue = true
                    break
                end
            end
        end

    until continue == false

    -- sort

    table.sort(g.settings.charactors, function(a, b)
        if a.layer ~= b.layer then
            return a.layer > b.layer
        end
        if a.order ~= b.order then
            return a.order < b.order
        end
    end)

    INSTANTCC_SAVE_SETTINGS()

    return INSTANTCC_GetBarrackSystem_OLD(actor)
end

--[[function INSTANTCC_DEFAULT_SETTINGS()
    g.settings = {
        charactors = {}

    }

end

function INSTANTCC_PROCESS_COMMAND(command)
    local cmd = "";

    if #command > 0 then
        cmd = table.remove(command, 1);
    else
        local msg = L_("character name needed");
        return ui.MsgBox(msg, "", "Nope")
    end

    for i = 1, #g.settings.charactors do

        if g.settings.charactors[i].name == cmd then
            local char = g.settings.charactors[i]

            INSTANTCC_DO_CC(char.cid, char.layer)
            return
        else

            -- g.settings.charactors[i]=nil
        end
    end

    CHAT_SYSTEM("[ICC]Charactor Not Found.")
end]]
