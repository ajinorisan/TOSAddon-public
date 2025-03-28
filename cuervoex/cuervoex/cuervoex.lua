local addonName = "cuervoex"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.3"

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
    btn:SetEventScriptArgNumber(ui.LBUTTONUP, 17);
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

local reward_map = {{
    amount = "1750000000",
    index = 17
}, {
    amount = "1250000000",
    index = 16
}, {
    amount = "750000000",
    index = 15
}, {
    amount = "625000000",
    index = 14
}, {
    amount = "375000000",
    index = 13
}, {
    amount = "300000000",
    index = 12
}, {
    amount = "250000000",
    index = 11
}, {
    amount = "175000000",
    index = 10
}, {
    amount = "125000000",
    index = 9
}, {
    amount = "50000000",
    index = 8
}, {
    amount = "37500000",
    index = 7
}, {
    amount = "25000000",
    index = 6
}, {
    amount = "18750000",
    index = 5
}, {
    amount = "10000000",
    index = 4
}, {
    amount = "5000000",
    index = 3
}, {
    amount = "2000000",
    index = 2
}}

function cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK_(frame)

    if g.index == 1 then
        return 0
    end
    local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_" .. g.index)
    if reward and reward:IsEnable() == 1 then
        for i = 1, #reward_map do
            if reward_map[i].index == g.index then
                local amount = reward_map[i].amount
                weekly_boss.RequestAcceptAbsoluteReward(g.week_num, amount)
                g.index = g.index - 1
                break
            end
        end
        return 1
    elseif reward and reward:IsEnable() == 0 then
        return 1
    end

end

function cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK(frame, ctrl, str, num)

    local frame = ui.GetFrame("weeklyboss_reward")
    local rewardType = frame:GetUserValue("REWARD_TYPE")
    g.week_num = tonumber(frame:GetUserValue("WEEK_NUM"))
    g.index = num
    local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_" .. num)
    if reward then
        g.index = g.index - 1
        weekly_boss.RequestAcceptAbsoluteReward(g.week_num, str)
        frame:RunUpdateScript("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK_", 0.3);
    end

end

--[[function cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK(frame, ctrl, argStr, argNum)

    local frame = ui.GetFrame("weeklyboss_reward")
    local rewardType = frame:GetUserValue("REWARD_TYPE")
    local week_num = tonumber(frame:GetUserValue("WEEK_NUM"))

    if argStr == "1750000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_17")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "1250000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "1250000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_16")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "750000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "750000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_15")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "625000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "625000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_14")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "375000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "375000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_13")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "300000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "300000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_12")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "250000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "250000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_11")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "175000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "175000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_10")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "125000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "125000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_9")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "50000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "50000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_8")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "37500000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "37500000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_7")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "25000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "25000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_6")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "18750000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "18750000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_5")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "10000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "10000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_4")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "5000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        end

    elseif argStr == "5000000" then
        local reward = GET_CHILD_RECURSIVELY(frame, "REWARD_3")
        if reward:IsEnable() == 1 then
            weekly_boss.RequestAcceptAbsoluteReward(week_num, argStr);
            argStr = "2000000"
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
            return
        else
            ReserveScript(string.format("cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK('%s','%s','%s',%d)", frame, ctrl,
                                        argStr, argNum), 2.0)
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
                                        argStr, argNum), 2.0)
            return
        end

    end

end]]
