local addonName = "SIMPLE_CC"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.settingsFileLoc_temp = string.format('../addons/%s/settings_temp.json', addonNameLower)
g.settings = {}

local acutil = require("acutil")
local json = require('json')
local os = require("os")

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

function simple_cc_lord_settings()
    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then
        settings = g.settings
    end

    local accountInfo = session.barrack.GetMyAccount();
    local cnt = accountInfo:GetBarrackPCCount()

    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetBarrackPCByIndex(i)
        local pcName = pcInfo:GetName()

        if settings[pcName] == nil then
            settings[pcName] = {
                layer = 9,
                index = 99,
                cid = 0,
                job = 0,
                gender = 9,
                level = 0
            }
        end
    end

    g.settings = settings
    simple_cc_save_settings()
end

function simple_cc_save_settings_temp()

    acutil.saveJSON(g.settingsFileLoc_temp, g.settings_temp)
end

function simple_cc_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)

end

function SIMPLE_CC_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    simple_cc_lord_settings()
    g.SetupHook(simple_cc_BARRACK_TO_GAME, "BARRACK_TO_GAME")
    acutil.setupHook(simple_cc_APPS_TRY_MOVE_BARRACK, "APPS_TRY_MOVE_BARRACK")
    -- addon:RegisterMsg("FPS_UPDATE", "simple_cc_change");
    print(g.layer)
    local accountInfo = session.barrack.GetMyAccount();
    local cnt = accountInfo:GetPCCount();
    for i = 0, cnt - 1 do
        local pcInfo = accountInfo:GetPCByIndex(i);
        local pcApc = pcInfo:GetApc();
        local pcName = pcApc:GetName()
        local pcCid = pcInfo:GetCID();
        local gender = pcApc:GetGender()
        local jobid = pcApc:GetJob();
        local level = pcApc:GetLv()

        g.settings[pcName].index = i
        g.settings[pcName].cid = pcCid
        g.settings[pcName].job = jobid
        g.settings[pcName].gender = gender
        g.settings[pcName].level = level
        g.settings[pcName].layer = g.layer or 9
    end
    simple_cc_save_settings()

end

--[[if simple_cc_login_OLD == nil and barrack.IsHideLogin ~= INSTANTCC_ISHIDELOGIN then
    simple_cc_login_OLD = barrack.IsHideLogin
    barrack.IsHideLogin = simple_cc_login
end

function simple_cc_login(cid, layer)

    ReserveScript(string.format("simple_cc_login_delay('%s',%d)", cid, layer), 0.1)

end

function simple_cc_login_delay(cid, layer)
    -- barrack.IsHideLogin = simple_cc_login
    
    ReserveScript(string.format("simple_cc_change('%s',%d)", cid, layer), 0.1)

end]]

function simple_cc_APPS_TRY_MOVE_BARRACK()
    local function compareCharacters(a, b)
        if a.layer == b.layer then
            return a.index < b.index -- 同じレイヤー内ではインデックス昇順にソート
        else
            return a.layer < b.layer -- レイヤー昇順にソート
        end
    end
    local sortedSettings = {}
    for name, char in pairs(g.settings) do
        char.name = name -- 名前をキャラクターテーブルに追加
        table.insert(sortedSettings, char)
    end
    -- キャラクターテーブルをソートする
    table.sort(sortedSettings, compareCharacters)

    local context = ui.CreateContextMenu("SELECT_CHARACTOR", "Barracks Character List", 0, 0, 250, 200)

    local strScp = string.format("APPS_TRY_LEAVE('%s')", "Barrack");
    ui.AddContextMenuItem(context, "Return To Barrack", strScp)
    ui.AddContextMenuItem(context, "-----Cancel-----", "None")

    -- local accountInfo = session.barrack.GetMyAccount();
    -- local cnt = accountInfo:GetBarrackPCCount()

    for k, char in ipairs(sortedSettings) do
        print(k)
        local jobCls = GetClassByType("Job", char.job)
        local Scp = string.format("simple_cc_change_reserve('%s','%s','%s',%d)", _, _, char.cid, char.layer)
        -- local Scp = string.format("simple_cc_login('%s',%d)", char.cid, char.layer)
        ui.AddContextMenuItem(context,
            "Barrack" .. char.layer .. " Lv" .. char.level .. " {b}" .. char.name .. "{/} (" ..
                GET_JOB_NAME(jobCls, char.gender) .. ")", Scp)
    end
    context:Resize(450, context:GetHeight());
    ui.OpenContextMenu(context)
    g.retries = 0
end

function simple_cc_change_reserve(frame, msg, cid, layer)
    local frame = ui.GetFrame("barrack_charlist")
    if frame == nil then
        APPS_TRY_LEAVE("Barrack")
    end
    ReserveScript(string.format("simple_cc_change('%s',%d)", cid, layer), 1.0)
end

function simple_cc_change(cid, layer)
    local frame = ui.GetFrame("barrack_charlist")
    -- ui.SysMsg(tostring(frame))
    if frame == nil and g.retries <= 10 then
        g.retries = g.retries + 1
        ReserveScript(string.format("simple_cc_change_reserve('%s','%s','%s',%d)", _, _, cid, layer), 1.0)
    end

    g.settings_temp = {}
    g.settings_temp.cid = cid
    g.settings_temp.layer = layer
    simple_cc_save_settings_temp()

    -- local scrollBox = frame:GetChild("scrollBox");
    -- scrollBox:RemoveAllChild();
    simple_cc_change_layer(frame, cid, layer)

    -- ReserveScript(string.format("simple_cc_change_char('%s')", frame), 2.0)
    return

end

function simple_cc_change_layer(frame, cid, layer)

    ReserveScript("barrack.SelectBarrackLayer(" .. g.settings_temp.layer .. ")", 0.1)

    -- ReserveScript("barrack.SelectCharacterByCID('" .. g.settings_temp.cid .. "')", 1.0)
    ReserveScript(string.format("simple_cc_change_char('%s','%s')", frame, cid), 1.0)
    return
end

function simple_cc_change_char(frame, cid)
    g.settings_temp.info = cid
    simple_cc_save_settings_temp()
    local frame = ui.GetFrame("barrack_charlist")
    -- ui.DestroyFrame("barrack_charlist")
    -- frame:RemoveAllChild()
    ReserveScript("barrack.SelectCharacterByCID('" .. g.settings_temp.cid .. "')", 1.0)
    --[[local charCtrl = GET_CHILD_RECURSIVELY(frame, 'char_' .. cid, "ui::CControlSet")
    ui.SysMsg(tostring(charCtrl))
    if charCtrl == nil and g.retries <= 16 then
        g.retries = g.retries + 1
        -- ReserveScript(string.format("simple_cc_change_layer('%s','%s',%d)", frame, cid, g.settings_temp.layer), 1.0)
        return
    end
    barrack.SelectCharacterByCID(cid);
    -- g.retries = 0
    g.settings_temp.info = cid
    simple_cc_save_settings_temp()]]
end

function simple_cc_retry()
    g.retries = g.retries + 1
    if g.retries > 15 then
        app.BarrackToLogin()
        ui.SysMsg("[ICC] Failed to select character, please try manually select.")
        return
    end

    simple_cc_change(g.settings_temp.cid, g.settings_temp.layer)
end

function simple_cc_togame()
    local bpca = barrack.GetBarrackPCInfoByCID(g.settings_temp.cid)
    if bpca == nil then
        -- fail
        simple_cc_retry()
        return
    end
    local bpc = barrack.GetGameStartAccount()
    if bpc ~= nil then
        if (bpc:GetCID() ~= g.settings_temp.cid) then
            -- fail
            simple_cc_retry()
            return
        end
        local jobName = barrack.GetSelectedCharacterJob();
        local charName = barrack.GetSelectedCharacterName();

        local bpacap = bpca:GetApc();
        if (charName ~= bpacap:GetName()) then
            -- fail
            simple_cc_retry()
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
        g.retries = 0
        app.BarrackToGame(key)
        return
    end
    -- fail
    simple_cc_retry()

end

--[[function simple_cc_change_layer(cid, layer)
    local frame = ui.GetFrame("barrack_charlist")
    local getlayer = tonumber(frame:GetUserValue("SelectBarrackLayer"))

    if getlayer ~= layer then
        ui.SysMsg(getlayer .. "layer")
        ReserveScript(string.format("simple_cc_change('%s', %d)", cid, layer), 0.5)
        return
    else
        ui.SysMsg("test")
        -- ReserveScript(string.format("simple_cc_change_cid('%s', %d)", cid, layer), 0.2)
    end
end]]
function simple_cc_change_cid(cid, layer)
    ui.SysMsg("test")
    local frame = ui.GetFrame("barrack_charlist")
    local scrollBox = bcframe:GetChild("scrollBox")
    local order = scrollBox:GetChildCount()
    for i = 0, scrollBox:GetChildCount() - 1 do
        local child = scrollBox:GetChildByIndex(i);
        if string.find(child:GetName(), 'char_') ~= nil then
            local guid = child:GetUserValue("CID");
            if guid == cid then
                local gsframe = ui.GetFrame("barrack_gamestart")
                local channels = GET_CHILD(gsframe, "channels", "ui::CDropList")
                local key = channels:GetSelItemIndex()

                app.BarrackToGame(key)
            end
        end
    end
end
local retries = 0

function simple_cc_BARRACK_TO_GAME()
    local frame = ui.GetFrame("barrack_charlist")
    local layer = tonumber(frame:GetUserValue("SelectBarrackLayer"))
    g.layer = layer

    local gsframe = ui.GetFrame("barrack_gamestart")
    local checkbtn = gsframe:GetChildRecursively("hidelogin")
    AUTO_CAST(checkbtn)
    checkbtn:SetCheck(1)
    barrack.SetHideLogin(1);

    -- BARRACK_TO_GAME_OLD()
    base["BARRACK_TO_GAME"]()
end

