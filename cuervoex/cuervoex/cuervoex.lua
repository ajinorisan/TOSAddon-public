local addonName = "cuervoex"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

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

function CUERVOEX_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    -- CHAT_SYSTEM("cuervoex")
    -- g.SetupHook(cuervoex_WEEKLY_BOSS_TOTAL_DAMAGE_REWARD_CLICK, "WEEKLY_BOSS_TOTAL_DAMAGE_REWARD_CLICK")
    acutil.setupEvent(addon, "WEEKLY_BOSS_TOTAL_DAMAGE_REWARD_CLICK", "cuervoex_WEEKLY_BOSS_TOTAL_DAMAGE_REWARD_CLICK");
end

function cuervoex_WEEKLY_BOSS_TOTAL_DAMAGE_REWARD_CLICK()

    cuervoex_FRAME_INIT()
end

function cuervoex_FRAME_INIT()
    local frame = ui.GetFrame("weeklyboss_reward")

    local btn = frame:CreateOrGetControl("button", "Button", 315, 655, 120, 40)
    AUTO_CAST(btn)
    btn:SetText("{ol}ちょい残し")
    btn:ShowWindow(1)
    btn:SetEventScript(ui.LBUTTONUP, "cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK")
    btn:SetEventScriptArgString(ui.LBUTTONUP, "1750000000");
    frame:RunUpdateScript("cuervoex_FRAME_CLOSE", 0.1);
end

function cuervoex_FRAME_CLOSE(frame)
    local rewardType = frame:GetUserValue("REWARD_TYPE")
    if rewardType == "Damage" then
        return 1
    else
        local btn = GET_CHILD_RECURSIVELY(frame, "Button")
        btn:ShowWindow(0)
        return 0
    end

end

function cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK(frame, ctrl, argStr, argNum)
    -- if argStr == nil then
    -- argStr = "1750000000"
    -- end
    -- CHAT_SYSTEM(tostring(argStr))
    local frame = ui.GetFrame("weeklyboss_reward")
    -- local btn = GET_CHILD_RECURSIVELY(frame, "Button")
    local rewardType = frame:GetUserValue("REWARD_TYPE")
    local week_num = tonumber(frame:GetUserValue("WEEK_NUM"))

    -- -- CHAT_SYSTEM(tostring(rewardType))

    -- -- CHAT_SYSTEM(tostring(week_num))
    if argStr == "1750000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_17")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "1250000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "1250000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_16")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "750000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "750000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_15")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "625000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "625000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_14")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "375000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "375000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_13")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "300000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "300000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_12")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "250000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "250000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_11")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "175000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "175000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_10")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "125000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "125000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_9")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "50000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "50000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_8")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "37500000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "37500000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_7")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "25000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "25000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_6")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "18750000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "18750000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_5")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "10000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "10000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_4")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "5000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "5000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_3")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "2000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    elseif argStr == "2000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_2")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            frame:ShowWindow(0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                argStr, argNum), 1.0)
            return
        end

    end

end
