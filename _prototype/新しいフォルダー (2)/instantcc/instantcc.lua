-- v1.0.0 キャラ一覧表示
-- v1.0.1 なんやかんや修正
-- v1.0.2 バラック表示諦めた。酔うてるししゃあない。
-- v1.0.3 書き直し。処理を極力シンプルに。
local addonName = "INSTANTCC"
local addonNameLower = string.lower(addonName)

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

    local str = json.encode(tbl)
    file:write(str)
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

function INSTANTCC_SAVE_SETTINGS()
    g.saveJSON(g.settings_file_path, g.settings)
end

function INSTANTCC_LOAD_SETTINGS()

    local settings = g.loadJSON(g.settings_file_path)
    if not settings then
        settings = {
            charactors = {}
        }
    end
    g.settings = settings
    INSTANTCC_SAVE_SETTINGS()
end

function INSTANTCC_SORT_CHAR_DATA()

    local account_info = session.barrack.GetMyAccount()
    local pc_count = account_info:GetPCCount()

    for i = 0, pc_count - 1 do
        local pc_info = account_info:GetPCByIndex(i)
        local pc_apc = pc_info:GetApc()
        local pc_name = pc_apc:GetName()
        local pc_cid = pc_info:GetCID()
        local gender = pc_apc:GetGender()
        local jobid = pc_apc:GetJob()
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

    local function compare_characters(a, b)
        if a.layer == b.layer then
            return a.order < b.order
        else
            return a.layer < b.layer
        end
    end

    table.sort(g.settings.charactors, compare_characters)
    INSTANTCC_SAVE_SETTINGS()
end

function INSTANTCC_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.do_cc = nil
    g.layer = g.layer or 1
    g.try = 0

    INSTANTCC_LOAD_SETTINGS()

    g.SetupHook(INSTANTCC_APPS_TRY_MOVE_BARRACK, "APPS_TRY_MOVE_BARRACK")
    g.SetupHook(INSTANTCC_BARRACK_START_FRAME_OPEN, "BARRACK_START_FRAME_OPEN")
    g.SetupHook(INSTANTCC_BARRACK_TO_GAME, "BARRACK_TO_GAME")

    INSTANTCC_SORT_CHAR_DATA()

end

function INSTANTCC_APPS_TRY_MOVE_BARRACK()
    INSTANTCC_APPS_TRY_MOVE_BARRACK_()
end

function INSTANTCC_APPS_TRY_MOVE_BARRACK_()

    function INSTANTCC_DO_CC(cid, layer)

        if cid ~= nil then
            g.do_cc = {
                cid = cid,
                layer = layer
            }
            base["APPS_TRY_MOVE_BARRACK"]()
            return
        else
            base["APPS_TRY_MOVE_BARRACK"]()
        end
    end

    local context = ui.CreateContextMenu("INSTANTCC_SELECT_CHARACTOR", "Barrack Charactor List", 0, 0, 0, 0)
    ui.AddContextMenuItem(context, "Return To Barrack", "INSTANTCC_DO_CC()")
    for i = 1, #g.settings.charactors do

        local info = g.settings.charactors[i]
        local pc_name = info.name
        local job_cls = GetClassByType("Job", info.jobid)
        local job_name = GET_JOB_NAME(job_cls, info.gender)
        local str = "Lv" .. info.level .. " " .. pc_name .. " (" .. job_name .. ")"
        ui.AddContextMenuItem(context, str, string.format("INSTANTCC_DO_CC('%s',%d)", info.cid, info.layer))
    end
    ui.OpenContextMenu(context)
end

function INSTANTCC_BARRACK_START_FRAME_OPEN(frame)
    INSTANTCC_BARRACK_START_FRAME_OPEN_(frame)
end

function INSTANTCC_BARRACK_START_FRAME_OPEN_(frame)
    if frame == nil then
        return
    end

    local gs_frame = ui.GetFrame("barrack_gamestart")
    local hidelogin = GET_CHILD_RECURSIVELY(gs_frame, "hidelogin", "ui::CCheckBox");
    AUTO_CAST(hidelogin)
    barrack.SetHideLogin(1);
    hidelogin:SetCheck(barrack.IsHideLogin());

    g.try = g.try + 1
    if g.do_cc and g.try <= 1 then
        g.retry = 0
        ReserveScript("INSTANTCC_CHANGE()", 0.1)
    end
end

function INSTANTCC_CHANGE()
    barrack.SelectBarrackLayer(g.do_cc.layer)
    ReserveScript(string.format("barrack.SelectCharacterByCID('%s')", g.do_cc.cid), 0.1)
    ReserveScript("INSTANTCC_TOGAME()", 0.2)
end

function INSTANTCC_BARRACK_TO_GAME()
    INSTANTCC_BARRACK_TO_GAME_()
end

function INSTANTCC_BARRACK_TO_GAME_()

    local bc_frame = ui.GetFrame("barrack_charlist")
    g.layer = tonumber(bc_frame:GetUserValue("SelectBarrackLayer"))

    local myaccount = session.barrack.GetMyAccount();
    if nil == myaccount then
        return;
    end
    local myCharCount = myaccount:GetTotalSlotCount();
    local buySlot = myaccount:GetBuySlotCount();
    local barrackCls = GetClass("BarrackMap", myaccount:GetThemaName());
    local maxCharCount = barrackCls.BaseSlot + buySlot;

    if 0 == PostponeCharCount() and myCharCount > maxCharCount then
        ui.SysMsg(ScpArgMsg("Many{CharCount}Than{CharSlot}CantStartGame", "CharCount", myCharCount, "CharSlot",
            maxCharCount));
    else
        local bpc = barrack.GetGameStartAccount();
        if bpc ~= nil then
            local apc = bpc:GetApc();

            local jobid = apc:GetJob();
            local level = apc:GetLv();

            local JobCtrlType = GetClassString('Job', jobid, 'CtrlType');

            config.SetConfig("LastJobCtrltype", JobCtrlType);
            config.SetConfig("LastPCLevel", level);
        end
        local frame = ui.GetFrame("barrack_gamestart")
        local channels = GET_CHILD(frame, "channels", "ui::CDropList");
        local key = channels:GetSelItemIndex();
        app.BarrackToGame(key);
    end
end

function INSTANTCC_RETRY()
    g.retry = g.retry + 1
    if g.retry > #g.settings.charactors then
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

    INSTANTCC_BARRACK_TO_GAME()

end

--[[local bc_frame = ui.GetFrame("barrack_charlist")
    local layer = tonumber(bc_frame:GetUserValue("SelectBarrackLayer"))

    local apc = bpc:GetApc()
    local jobid = apc:GetJob()
    local level = apc:GetLv()
    local JobCtrlType = GetClassString("Job", jobid, "CtrlType")

    config.SetConfig("LastJobCtrltype", JobCtrlType)
    config.SetConfig("LastPCLevel", level)

    local frame = ui.GetFrame("barrack_gamestart")
    local channels = GET_CHILD(frame, "channels", "ui::CDropList")
    local key = channels:GetSelItemIndex()

    app.BarrackToGame(key)]]

--[[if INSTANTCC_BARRACK_START_FRAME_OPEN_OLD == nil then
    INSTANTCC_BARRACK_START_FRAME_OPEN_OLD = BARRACK_START_FRAME_OPEN
    BARRACK_START_FRAME_OPEN = INSTANTCC_BARRACK_START_FRAME_OPEN
end]]

--[[function INSTANTCC_TOGAME()
    local bpca = barrack.GetBarrackPCInfoByCID(g.do_cc.cid)
    if bpca == nil then
        INSTANTCC_RETRY()
        return
    end
    local bpc = barrack.GetGameStartAccount()
    if bpc ~= nil then
        if (bpc:GetCID() ~= g.do_cc.cid) then
            INSTANTCC_RETRY()
            return
        end
        -- local jobName = barrack.GetSelectedCharacterJob();
        local charName = barrack.GetSelectedCharacterName();

        local bpacap = bpca:GetApc();
        if (charName ~= bpacap:GetName()) then
            INSTANTCC_RETRY()
            return
        end

        local bc_frame = ui.GetFrame("barrack_charlist")
        local layer = tonumber(bc_frame:GetUserValue("SelectBarrackLayer"))
        g.layer = layer

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

end]]

--[[function INSTANTCC_BARRACK_TO_GAME()

    local frame = ui.GetFrame("barrack_charlist")
    local layer = tonumber(frame:GetUserValue("SelectBarrackLayer"))
    g.layer = layer

    local gs_frame = ui.GetFrame("barrack_gamestart")
    local hidelogin = gs_frame:GetChildRecursively("hidelogin")
    AUTO_CAST(hidelogin)
    hidelogin:SetCheck(1)
    barrack.SetHideLogin(1);

    base["BARRACK_TO_GAME"]()
end]]

--[[function INSTANTCC_APPS_TRY_MOVE_BARRACK(a, b, c, d, bno)
    return INSTANTCC_APPS_TRY_MOVE_BARRACK2(a, b, c, d, bno)
end

function INSTANTCC_APPS_TRY_MOVE_BARRACK2(a, b, c, d, bno)
    bno = bno or 1
    ReserveScript('INSTANTCC_APPS_TRY_MOVE_BARRACK3(a,b,c,d,' .. bno .. ')', 0.25)
end]]

--[[function INSTANTCC_APPS_TRY_LOGOUT()
    g.settings.do_cc = nil
    INSTANTCC_SAVE_SETTINGS()
    base["APPS_TRY_LOGOUT"]()
    return
end]]

--[[function INSTANTCC_DO_MOVE_BARRACK()
    g.settings.do_cc = nil
    INSTANTCC_SAVE_SETTINGS()
    base["APPS_TRY_MOVE_BARRACK"]()
    return
end]]

--[[local folder_path = string.format("../addons/%s", addonNameLower)
    local file_path = string.format("../addons/%s/test.txt", addonNameLower)
    local file = io.open(file_path, "w")

    if file then
        file:write(tostring(barrack.IsHideLogin()))
        file:close()
    end]]

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
