-- v1.0.2 バラック表示諦めた。酔うてるししゃあない。
-- v1.0.1 なんやかんや修正
-- v1.0.0 キャラ一覧表示
-- instantcc
local addonName = "INSTANTCC"
local addonNameLower = string.lower(addonName)
-- 作者名
local author = "ebisuke"
local ver = "1.0.2"
local basever = "0.0.7"

-- アドオン内で使用する領域を作成。以下、ファイル内のスコープではグローバル変数gでアクセス可
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require("acutil")
g.version = 0
g.settings = {
    charactors = {}
}
g.personalsettingsFileLoc = ""
g.framename = "instantcc"
g.debug = false
g.reason = nil
-- ライブラリ読み込み
local acutil = require("acutil")
function EBI_try_catch(what)
    local status, result = pcall(what.try)
    if not status then
        what.catch(result)
    end
    return result
end
function EBI_IsNoneOrNil(val)
    return val == nil or val == "None" or val == "nil"
end

local function DBGOUT(msg)
    EBI_try_catch {
        try = function()
            if (g.debug == true) then
                CHAT_SYSTEM(msg)

                print(msg)
                local fd = io.open(g.logpath, "a")
                fd:write(msg .. "\n")
                fd:flush()
                fd:close()
            end
        end,
        catch = function(error)
        end
    }
end

local function ERROUT(msg)
    EBI_try_catch {
        try = function()
            CHAT_SYSTEM(msg)
            print(msg)
        end,
        catch = function(error)
        end
    }
end

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

function INSTANTCC_BARRACK_TO_GAME()
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

-- マップ読み込み時処理（1度だけ）
function INSTANTCC_ON_INIT(addon, frame)
    EBI_try_catch {
        try = function()
            frame = ui.GetFrame(g.framename)
            g.addon = addon
            g.frame = frame
            if g.layer == nil then
                g.layer = 1
            end
            g.SetupHook(INSTANTCC_APPS_TRY_MOVE_BARRACK, "APPS_TRY_MOVE_BARRACK")
            g.SetupHook(INSTANTCC_APPS_TRY_LOGOUT, "APPS_TRY_LOGOUT")
            acutil.slashCommand("/icc", INSTANTCC_PROCESS_COMMAND);
            acutil.slashCommand("/instantcc", INSTANTCC_PROCESS_COMMAND);
            g.SetupHook(INSTANTCC_BARRACK_TO_GAME, "BARRACK_TO_GAME")

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
                    -- Remove existing entry
                    table.remove(g.settings.charactors, foundIndex)
                end

                -- Insert new entry
                table.insert(g.settings.charactors, info)
            end

            INSTANTCC_SAVE_SETTINGS()
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function INSTANTCC_APPS_TRY_MOVE_BARRACK(a, b, c, d, bno)
    return INSTANTCC_APPS_TRY_MOVE_BARRACK2(a, b, c, d, bno)
end
function INSTANTCC_APPS_TRY_MOVE_BARRACK2(a, b, c, d, bno)
    bno = bno or 1

    ReserveScript('INSTANTCC_APPS_TRY_MOVE_BARRACK3(a,b,c,d,' .. bno .. ')', 0.25)
end
function INSTANTCC_APPS_TRY_MOVE_BARRACK3(a, b, c, d, bno)
    EBI_try_catch {
        try = function()

            local function compareCharacters(a, b)
                if a.layer == b.layer then
                    return a.order < b.order -- 同じレイヤー内ではインデックス昇順にソート
                else
                    return a.layer < b.layer -- レイヤー昇順にソート
                end
            end
            local sortedSettings = {}
            for _, char in pairs(g.settings.charactors) do

                table.insert(sortedSettings, char)
            end
            -- キャラクターテーブルをソートする
            table.sort(sortedSettings, compareCharacters)

            bno = bno or 1
            local context = ui.CreateContextMenu("INSTANTCC_SELECT_CHARACTOR", "Barrack Charactor List", 0, 0, 380, 0)

            ui.AddContextMenuItem(context, "Return To Barrack", "INSTANTCC_DO_MOVE_BARRACK()")
            -- ui.AddContextMenuItem(context, "Barrack1", "INSTANTCC_APPS_TRY_MOVE_BARRACK(nil,nil,nil,nil,1)")
            -- ui.AddContextMenuItem(context, "Barrack2", "INSTANTCC_APPS_TRY_MOVE_BARRACK(nil,nil,nil,nil,2)")
            -- ui.AddContextMenuItem(context, "Barrack3", "INSTANTCC_APPS_TRY_MOVE_BARRACK(nil,nil,nil,nil,3)")
            -- ui.AddContextMenuItem(context, "Cancel", "None")
            local aidx = session.loginInfo.GetAID();
            local myHandle = session.GetMyHandle();
            local myGuildIdx = 0
            local myTeamName = info.GetFamilyName(myHandle)

            for i = 1, #g.settings.charactors do

                -- if g.settings.charactors[i].layer == bno then

                local char = sortedSettings[i]
                local pcName = char.name
                local jobCls = GetClassByType("Job", char.job)
                local jobName = GET_JOB_NAME(jobCls, char.gender)

                local str = "Lv" .. char.level .. " " .. pcName .. " (" .. jobName .. ")"
                --[[if char.layer == 2 then
                    str = "{#FAFAFA}Lv" .. char.level .. " " .. pcName .. " (" .. jobName .. ")"
                elseif char.layer == 3 then
                    str = "{#F5F5F5}Lv" .. char.level .. " " .. pcName .. " (" .. jobName .. ")"
                end]]
                --[[if char.order == 0 then
                    -- ui.AddContextMenuItem(context, "----------Barrack " .. char.layer .. "----------", "None")
                    ui.AddContextMenuItem(context, "B" .. char.layer .. " " .. str,
                        "INSTANTCC_DO_CC('" .. char.cid .. "'," .. char.layer .. ")")
                else

                end]]
                ui.AddContextMenuItem(context, str, "INSTANTCC_DO_CC('" .. char.cid .. "'," .. char.layer .. ")")
                -- ui.AddContextMenuItem(context, str, "INSTANTCC_DO_CC('" .. char.cid .. "'," .. char.layer .. ")")

                -- end
            end

            context:Resize(400, context:GetHeight());
            ui.OpenContextMenu(context)
        end,
        catch = function(error)
            ERROUT(error)
        end
    }
end
function INSTANTCC_APPS_TRY_LOGOUT()
    g.settings.do_cc = nil
    INSTANTCC_SAVE_SETTINGS()
    base["APPS_TRY_LOGOUT"]()
    return
end
function INSTANTCC_DO_MOVE_BARRACK()
    g.settings.do_cc = nil
    -- INSTANTCC_LOAD_SETTINGS()
    INSTANTCC_SAVE_SETTINGS()
    base["APPS_TRY_MOVE_BARRACK"]()
    return
end

function INSTANTCC_SAVE_SETTINGS()
    local aidx = session.loginInfo.GetAID();
    local myHandle = session.GetMyHandle();
    local myGuildIdx = 0
    local myTeamName = info.GetFamilyName(myHandle)
    g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
    -- CAMPCHEF_SAVETOSTRUCTURE()
    acutil.saveJSON(g.settingsFileLoc, g.settings)
end
function INSTANTCC_DO_CC(cid, layer)
    CHAT_SYSTEM("[ICC]Attempt to CC.")
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
function INSTANTCC_DEFAULT_SETTINGS()
    g.settings = {
        charactors = {}

    }

end
function INSTANTCC_LOAD_SETTINGS()
    local aidx = session.loginInfo.GetAID();
    local myHandle = session.GetMyHandle();
    local myGuildIdx = 0
    local myTeamName = info.GetFamilyName(myHandle)
    g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower)
    EBI_try_catch {
        try = function()
            g.settings = {}
            local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
            if err then
                -- 設定ファイル読み込み失敗時処理

                INSTANTCC_DEFAULT_SETTINGS()
            else
                -- 設定ファイル読み込み成功時処理
                g.settings = t
                if (not g.settings.version) then
                    g.settings.version = 0

                end
            end

            INSTANTCC_SAVE_SETTINGS()

        end,
        catch = function(error)
            ERROUT(error)
        end
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
end
