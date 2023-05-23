local addonName = "FREEFROMLITTLESTRESS"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

g.SettingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

g.Settings = {
    Position = {
        X = 900,
        Y = 100
    },
    Presetethergem = {}
};

function FREEFROMLITTLESTRESS_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    CHAT_SYSTEM(addonNameLower .. " loaded")

    acutil.setupHook(FREEFROMLITTLESTRESS_RAID_RECORD_INIT, "RAID_RECORD_INIT")
    acutil.setupHook(FREEFROMLITTLESTRESS_RESTART_ON_MSG, "RESTART_ON_MSG")
    -- FREEFROMLITTLESTRESS_FRAME_INIT()

end

function FREEFROMLITTLESTRESS_RESTART_ON_MSG(frame, msg, argStr, argNum)
    local minigameover = ui.GetFrame('minigameover');
    if minigameover:IsVisible() == 1 then
        return;
    end

    if msg == 'RESTART_HERE' then
        for i = 1, 5 do
            local btnName = "restart" .. i .. "btn";
            local resButtonObj = GET_CHILD(frame, btnName, 'ui::CButton');
            local isBit = BitGet(argNum, i);
            resButtonObj:ShowWindow(isBit);
        end

        -- 보루타 부활용
        local returnCityBtn = GET_CHILD(frame, "restart9btn", "ui::CButton");
        returnCityBtn:ShowWindow(0);
        if BitGet(argNum, 16) == 1 then
            frame:RunUpdateScript("BORUTA_RVRRAID_RESTART_UPDATE", 1, 0, 0, 1);
            frame:SetUserValue("COUNT", 30);
            returnCityBtn:ShowWindow(1);
        end

        -- 콜로니전 부활용
        -- ここで30秒後に戻るボタンを表示
        local resButtonObj = GET_CHILD(frame, "restart6btn", 'ui::CButton');
        resButtonObj:ShowWindow(0);
        if 1 == BitGet(argNum, 12) then
            frame:SetOffset(ui.GetClientInitialWidth() - frame:GetWidth() - 0, 0)
            frame:SetSkinName("None")
            local btnName = "restart6btn";
            local resButtonObj = GET_CHILD(frame, btnName, 'ui::CButton');

            resButtonObj:ShowWindow(1);
            resButtonObj:SetAlpha(20)
        end

        local resButtonObj = GET_CHILD(frame, "restart8btn", 'ui::CButton');
        resButtonObj:ShowWindow(0);
        if 1 == BitGet(argNum, 14) then
            frame:SetOffset(ui.GetClientInitialWidth() - frame:GetWidth() - 0, 0) -- テスト用
            frame:SetSkinName("None") -- テスト用

            resButtonObj:ShowWindow(1);
            resButtonObj:SetAlpha(20) -- テスト用
            COLONY_WAR_RESTART_BY_MYSTIC_UPDATE(frame);
        end

        -- ここで自動で戻るのを制御している 戦場カメラマンとしてはウズウズ
        if 1 == BitGet(argNum, 12) or 1 == BitGet(argNum, 14) then
            frame:RunUpdateScript("COLONY_WAR_RESTART_UPDATE", 1, 0, 0, 1);
            frame:SetUserValue("COUNT", 30);
        end

        -- 길드 타워
        -- ここでギルドタワーボタンを表示
        local resButtonObj = GET_CHILD(frame, "restart7btn", 'ui::CButton');
        resButtonObj:ShowWindow(0);
        if 1 == BitGet(argNum, 13) then
            frame:SetOffset(ui.GetClientInitialWidth() - frame:GetWidth() - 0, 0)
            frame:SetSkinName("None")
            local btnName = 'restart7btn';
            local resButtonObj = GET_CHILD(frame, btnName, 'ui::CButton');
            if IS_EXIST_GUILD_TOWER() == true then
                resButtonObj:ShowWindow(1);
                resButtonObj:SetAlpha(20)
            end
        end

        -- 레이드 부활
        local map = GetClass('Map', session.GetMapName());
        local keyword = TryGetProp(map, 'Keyword', 'None');
        local keyword_table = StringSplit(keyword, ';');
        if table.find(keyword_table, 'MythicMap') > 0 then
            local restart10btn = GET_CHILD(frame, "restart10btn", "ui::CButton");
            if restart10btn ~= nil then
                restart10btn:ShowWindow(0);
            end
        elseif IsRaidField() == 1 or IsRaidMap() == 1 then
            if argNum == 6 then
                local restart1btn = GET_CHILD(frame, "restart1btn", "ui::CButton");
                if restart1btn ~= nil then
                    restart1btn:ShowWindow(0);
                end

                -- start point restart
                local use_start_point = 1;
                if argStr ~= "" then
                    local restart_class = GetClass("resurrect_return_control", argStr);
                    if restart_class ~= nil then
                        use_start_point = TryGetProp(restart_class, "StartPoint", 1);
                    end
                end

                local restart10btn = GET_CHILD(frame, "restart10btn", "ui::CButton");
                if restart10btn ~= nil then
                    if use_start_point == 1 then
                        restart10btn:ShowWindow(1);
                    else
                        restart10btn:ShowWindow(0);
                    end
                end

                -- return city restart
                local use_save_point = 0;
                if argStr ~= "" then
                    local restart_class = GetClass("resurrect_return_control", argStr);
                    if restart_class ~= nil then
                        use_save_point = TryGetProp(restart_class, "SavePoint", 0);
                    end
                end

                local restart1btn = GET_CHILD(frame, "restart1btn", "ui::CButton");
                if restart1btn ~= nil then
                    if use_save_point == 1 then
                        restart1btn:ShowWindow(1);
                    else
                        restart1btn:ShowWindow(0);
                    end
                end
            end
        else
            local restart10btn = GET_CHILD(frame, "restart10btn", "ui::CButton");
            if restart10btn ~= nil then
                restart10btn:ShowWindow(0);
            end
        end

        AUTORESIZE_RESTART(frame);
        RESTART_WAIT_STOP();
        frame:ShowWindow(1);
    elseif msg == 'RESTARTSELECT_UP' then
        RESTART_MOVE_INDEX(frame, -1);
        RESTARTSELECT_ITEM_SELECT(frame)
    elseif msg == 'RESTARTSELECT_DOWN' then
        RESTART_MOVE_INDEX(frame, 1);
        RESTARTSELECT_ITEM_SELECT(frame)
    elseif msg == 'RESTARTSELECT_SELECT' then
        local list = RESTART_GET_COMMAND_LIST(frame)
        local restartSelect_index = frame:GetValue();
        local ItemBtn = frame:GetChildRecursively(list[restartSelect_index]);
        local scp = ItemBtn:GetEventScript(ui.LBUTTONUP);
        local argString = ItemBtn:GetEventScriptArgString(ui.LBUTTONUP);
        scp = _G[scp];
        scp(frame, ItemBtn, argString);
    elseif msg == 'RESTART_WAIT' then
        for i = 1, 10 do
            local btn = GET_CHILD(frame, "restart" .. i .. "btn", 'ui::CButton');
            btn:ShowWindow(0);
        end
        local text = GET_CHILD(frame, "restart_wait", 'ui::CRichText');
        text:ShowWindow(1);
        text:SetTextByKey("sec", argNum);
        AddUniqueTimerFunccWithLimitCount("RESTART_WAIT_UPDATE", 1000, argNum);
    elseif msg == 'RESTART_WAIT_END' then
        RemoveLuaTimerFunc("RESTART_WAIT_UPDATE")
    end
end

-- エーテルジェム自動着脱作りかけ
function FREEFROMLITTLESTRESS_FRAME_INIT()
    local invframe = ui.GetFrame('inventory')
    local inventoryGbox = invframe:GetChild("inventoryGbox")

    -- ボタンの配置位置
    local buttonX = inventoryGbox:GetWidth() - 240
    local buttonY = inventoryGbox:GetHeight() - 610

    local eqbutton = inventoryGbox:CreateOrGetControl("button", "eqbutton", buttonX, buttonY, 50, 30)
    eqbutton:SetText("equip")

    local rmbuttonX = inventoryGbox:GetWidth() - 105
    local rmbuttonY = inventoryGbox:GetHeight() - 610

    local rmeqbutton = inventoryGbox:CreateOrGetControl("button", "rmeqbutton", rmbuttonX, rmbuttonY, 60, 30)
    rmeqbutton:SetText("rmequip")

    eqbutton:SetEventScript(ui.LBUTTONUP, "ON_EQUIP_BUTTON_CLICK")
    rmeqbutton:SetEventScript(ui.LBUTTONUP, "ON_RMEQUIP_BUTTON_CLICK")

end

function ON_EQUIP_BUTTON_CLICK(invframe)
    print("equipボタンがクリックされました")

    local goddessframe = ui.GetFrame('goddess_equip_manager')
    local socket_bg = GET_CHILD_RECURSIVELY(goddessframe, "socket_bg")

end

function ON_RMEQUIP_BUTTON_CLICK(invframe)
    print("rmequipボタンがクリックされました")
    local enable_slot_list = {'RH', 'LH', 'RH_SUB', 'LH_SUB'}
    for i = 1, #enable_slot_list do
        local slot_name = enable_slot_list[i]
        local ctrl_slot = GET_CHILD_RECURSIVELY(invframe, slot_name)
        if ctrl_slot ~= nil then
            local item = GET_SLOT_ITEM(ctrl_slot)
            if item ~= nil then
                local itemName = item:GetName()
                local itemID = item:GetIESID()
                print("スロット名: " .. slot_name)
                print("アイテム名: " .. itemName)
                print("アイテムID: " .. itemID)
            else
                print("スロット名 " .. slot_name .. " にはアイテムが入っていません")
            end
        else
            print("スロット名 " .. slot_name .. " は見つかりませんでした")
        end
    end
end

function FREEFROMLITTLESTRESS_RAID_RECORD_INIT(frame)
    frame:SetOffset(ui.GetClientInitialWidth() - frame:GetWidth() - 100, 100)
    frame:SetSkinName("shadow_box")
    local myInfo = GET_CHILD_RECURSIVELY(frame, "myInfo")
    local myInfo_name = GET_CHILD_RECURSIVELY(myInfo, "name")
    local myInfo_time = GET_CHILD_RECURSIVELY(myInfo, "time")
    myInfo_name:SetFontName("white_16_ol")
    myInfo_time:SetFontName("white_16_ol")
    local friendInfo1 = GET_CHILD_RECURSIVELY(frame, "friendInfo1")
    local friendInfo1_name = GET_CHILD_RECURSIVELY(friendInfo1, "name")
    local friendInfo1_time = GET_CHILD_RECURSIVELY(friendInfo1, "time")
    friendInfo1_name:SetFontName("white_16_ol")
    friendInfo1_time:SetFontName("white_16_ol")
    local friendInfo2 = GET_CHILD_RECURSIVELY(frame, "friendInfo2")
    local friendInfo2_name = GET_CHILD_RECURSIVELY(friendInfo2, "name")
    local friendInfo2_time = GET_CHILD_RECURSIVELY(friendInfo2, "time")
    friendInfo2_name:SetFontName("white_16_ol")
    friendInfo2_time:SetFontName("white_16_ol")
    local friendInfo3 = GET_CHILD_RECURSIVELY(frame, "friendInfo3")
    local friendInfo3_name = GET_CHILD_RECURSIVELY(friendInfo3, "name")
    local friendInfo3_time = GET_CHILD_RECURSIVELY(friendInfo3, "time")
    friendInfo3_name:SetFontName("white_16_ol")
    friendInfo3_time:SetFontName("white_16_ol")
    GET_CHILD_RECURSIVELY(frame, 'bgIndunClear'):ShowWindow(1)
    GET_CHILD_RECURSIVELY(frame, 'textNewRecord'):ShowWindow(0);

end

