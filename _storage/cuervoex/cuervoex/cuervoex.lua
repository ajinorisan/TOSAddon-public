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

-- !
local addonName = "cuervoex"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

-- local base = {} -- base テーブルは g.SetupHook が使われへんのなら不要

-- g.SetupHook はコメントアウトされてるので、今回はそのまま触らないでおく
-- function g.SetupHook(func, baseFuncName)
--     local addonUpper = string.upper(addonName)
--     local replacementName = addonUpper .. "_BASE_" .. baseFuncName
--     if (_G[replacementName] == nil) then
--         _G[replacementName] = _G[baseFuncName];
--         _G[baseFuncName] = func
--     end
--     base[baseFuncName] = _G[replacementName]
-- end

function CUERVOEX_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame -- g.frame は使われてへんみたいやけど、元のまま残しとく
    acutil.setupEvent(addon, "WEEKLY_BOSS_TOTAL_DAMAGE_REWARD_CLICK",
                      "cuervoex_WEEKLY_BOSS_TOTAL_DAMAGE_REWARD_CLICK_EVENT"); -- 関数名を変更して役割を明確に
end

-- WEEKLY_BOSS_TOTAL_DAMAGE_REWARD_CLICK イベントのハンドラ
function cuervoex_WEEKLY_BOSS_TOTAL_DAMAGE_REWARD_CLICK_EVENT() -- 元の cuervoex_WEEKLY_BOSS_TOTAL_DAMAGE_REWARD_CLICK
    cuervoex_FRAME_INIT()
end

function cuervoex_FRAME_INIT()
    local frame = ui.GetFrame("weeklyboss_reward")
    if not frame then
        return
    end -- フレームがなかったら何もしない

    local btn = frame:CreateOrGetControl("button", "Button", 315, 655, 120, 40)
    AUTO_CAST(btn)
    btn:SetText("{ol}ちょい残し")
    btn:ShowWindow(1)
    -- 初期値として最上位の報酬を設定（元のコードの挙動を維持）
    btn:SetEventScript(ui.LBUTTONUP, "cuervoex_START_REWARD_PROCESS") -- 関数名を変更
    btn:SetEventScriptArgString(ui.LBUTTONUP, "1750000000")
    btn:SetEventScriptArgNumber(ui.LBUTTONUP, 17)

    frame:RunUpdateScript("cuervoex_FRAME_UPDATE_CHECK", 0.1) -- 関数名を変更
end

-- フレームの状態を監視し、ボタンの表示/非表示を切り替える
function cuervoex_FRAME_UPDATE_CHECK(frame)
    local rewardType = frame:GetUserValue("REWARD_TYPE")
    local btn = GET_CHILD_RECURSIVELY(frame, "Button") -- ボタンを再取得

    if not btn then
        return 0
    end -- ボタンがなければスクリプト停止

    if rewardType == "Damage" then
        -- "Damage" の時はボタンを表示し続けるので、スクリプトは継続
        -- (ただし、ボタンの表示状態をここで制御してもええかも)
        -- btn:ShowWindow(1) -- 既に表示されてるはずやけど念のため
        return 1 -- スクリプト継続
    else
        -- それ以外の時はボタンを非表示にしてスクリプト停止
        btn:ShowWindow(0)
        return 0 -- スクリプト停止
    end
end

-- 報酬データを定義 (変更なし)
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

-- 報酬受け取り処理のメインループ（RunUpdateScriptで呼ばれる）
function cuervoex_PROCESS_NEXT_REWARD(frame) -- 元の cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK_
    if not g.current_reward_idx or g.current_reward_idx < 2 then -- g.index を g.current_reward_idx に変更し、終了条件を明確化
        return 0 -- 処理終了
    end

    local reward_ui = GET_CHILD_RECURSIVELY(frame, "REWARD_" .. g.current_reward_idx)

    if reward_ui and reward_ui:IsEnable() == 1 then
        -- reward_map から現在のインデックスに合う報酬を探す
        local found_reward_data = nil
        for i = 1, #reward_map do
            if reward_map[i].index == g.current_reward_idx then
                found_reward_data = reward_map[i]
                break
            end
        end

        if found_reward_data then
            weekly_boss.RequestAcceptAbsoluteReward(g.current_week_num, found_reward_data.amount) -- g.week_num を g.current_week_num に
            g.current_reward_idx = g.current_reward_idx - 1
            return 1 -- 次のフレームで再度この関数を呼ぶ (RunUpdateScriptが継続)
        else
            -- 報酬マップに該当なし。予期せぬ状態なので止める
            print("cuervoex: reward_mapに該当する報酬が見つかりませんでした。index: " ..
                      g.current_reward_idx)
            return 0
        end
    elseif reward_ui and reward_ui:IsEnable() == 0 then
        -- 既に受け取り済みか、受け取れない状態なら次のインデックスへ
        -- (元のコードではここで return 1 して無限ループの可能性があったので修正)
        -- print("cuervoex: REWARD_" .. g.current_reward_idx .. " は無効です。スキップします。")
        g.current_reward_idx = g.current_reward_idx - 1 -- 次のインデックスに進む
        return 1 -- 次のフレームで再度この関数を呼ぶ
    else
        -- reward_ui が見つからない場合も予期せぬ状態
        -- print("cuervoex: REWARD_" .. g.current_reward_idx .. " が見つかりません。")
        -- この場合、安全のため処理を止めるか、インデックスを減らして継続するか。今回は止める。
        return 0
    end
end

-- 「ちょい残し」ボタンがクリックされた時の初期処理
function cuervoex_START_REWARD_PROCESS(frame_ref_from_event, ctrl, amount_str, index_num) -- 元の cuervoex_WEEKLYBOSSREWARD_REWARD_LIST_CLICK
    -- frame はイベントから渡される参照を使う
    local reward_frame = ui.GetFrame("weeklyboss_reward") -- 念のためフレームを再取得
    if not reward_frame then
        return
    end

    -- local rewardType = reward_frame:GetUserValue("REWARD_TYPE") -- この変数は使われてへんな

    g.current_week_num = tonumber(reward_frame:GetUserValue("WEEK_NUM")) -- g.week_num を g.current_week_num に
    g.current_reward_idx = index_num -- g.index を g.current_reward_idx に

    -- 最初の報酬を直接受け取る (元のコードの挙動を踏襲)
    -- ただし、その報酬が受け取り可能かどうかのチェックはPROCESS_NEXT_REWARDに任せる方が一貫性があるかも
    local initial_reward_ui = GET_CHILD_RECURSIVELY(reward_frame, "REWARD_" .. index_num)
    if initial_reward_ui and initial_reward_ui:IsEnable() == 1 then -- IsEnableチェックを追加
        weekly_boss.RequestAcceptAbsoluteReward(g.current_week_num, amount_str)
        g.current_reward_idx = g.current_reward_idx - 1 -- 最初のものを受け取ったので、次のターゲットインデックスを一つ減らす
        reward_frame:RunUpdateScript("cuervoex_PROCESS_NEXT_REWARD", 0.3)
    elseif initial_reward_ui and initial_reward_ui:IsEnable() == 0 then
        -- 最初の報酬が既に受け取れない場合は、次のインデックスから処理を開始
        g.current_reward_idx = g.current_reward_idx - 1
        reward_frame:RunUpdateScript("cuervoex_PROCESS_NEXT_REWARD", 0.3)
    else
        -- 最初の報酬UIが見つからないなど、予期せぬ場合は何もしない
        print("cuervoex: 初期報酬 " .. index_num .. " が見つからないか無効です。")
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
