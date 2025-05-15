-- v1.0.0 レイド毎に憤怒ポーション切替
-- v1.0.1 加護ポーションも対応
-- v1.0.2 クイックスロットがセーブされてなくてレイドで元のポーションに戻る場合があるので、MAPに入った時に動かす様に修正
-- v1.0.3 レイド選んだ時と中でももう1回チェックのハイブリッドに。
-- v1.0.4 加護ポ持ってない時に切り替わらないバグ修正。
-- v1.0.5 メレジナ野獣になってたの悪魔に修正。
-- v1.0.6 コード見直し
-- v1.0.7 クイックスロットにアイコン入ってたら変わる様に設定。今回は失敗しないハズ。
-- v1.0.8 手動入替えスロット付けた。
-- v1.0.9 スロットセットの位置調整
-- v1.1.0 ストレートモード追加、キャラ毎のクイックスロット保存呼出機能追加。
-- v1.1.1 INIT時に余計な読み込みで遅くなってたのを修正。ロードボタン押した時にパースする様に修正。
-- v1.1.2 ロードボタン押した時のバグ修正
-- v1.1.3 520アプデ対応
-- v1.1.4 ネリゴレハード対応。jsonファイルから直接対応増やせる様に変更。これで僕が死んでもある程度使えると思う。
-- v1.1.5 ストレートモードバグってたの修正
-- v1.1.6 ジョイスティックモードにも対応したつもり
-- v1.1.7 レダニア追加
local addonName = "quickslot_operate"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.frame_settingsFileLoc = string.format('../addons/%s/frame_settings.json', addonNameLower)

local acutil = require("acutil")
local os = require("os")
local json = require("json")

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
-- レダニア 716,717,718 11278 Raid_Redania
local raid_list = {
    Paramune = {623, 667, 666, 665, 674, 673, 675, 680, 679, 681, 707, 708, 710, 711, 709, 712},
    Klaida = {686, 685, 687, 716, 717, 718},
    Velnias = {689, 688, 690, 669, 635, 628, 696, 695, 697},
    Forester = {672, 671, 670},
    Widling = {677, 676, 678}
}
-- local raid_list = {}
local zone_id_list = {11261, 11250, 11263, 11266, 11252, 11256, 11230, 11208, 11270, 11276, 11277, 11278}
-- local zone_id_list = {}
-- ies.ipf/indun.ies レイド番号で探せ
local zone_list = {"raid_Rosethemisterable", "raid_castle_ep14_2", "Raid_DreamyForest", "Raid_AbyssalObserver",
                   "raid_Jellyzele", "raId_castle_ep14", "raid_giltine_AutoGuild", "raid_dcapital_108",
                   "raid_kivotos_island", "Raid_DarkNeringa", "Raid_CrystalGolem", "Raid_Redania"}

local potion_list = {
    Velnias = 640504,
    Klaida = 640503,
    Paramune = 640502,
    Widling = 640501,
    Forester = 640500
}

local down_potion_list = {
    Velnias = 640373,
    Klaida = 640375,
    Paramune = 640374,
    Widling = 640377,
    Forester = 640376
}

function quickslot_operate_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)

end

function quickslot_operate_load_settings()

    local frame_settings, err = acutil.loadJSON(g.frame_settingsFileLoc, g.frame_settings)

    if not frame_settings then
        frame_settings = {
            straight = false
        }

    end
    g.frame_settings = frame_settings

    acutil.saveJSON(g.frame_settingsFileLoc, g.frame_settings)

    local function file_exists(filePath)
        local file = io.open(filePath, "r")
        if file then
            file:close()
            return true
        else
            return false
        end
    end

    local function load_json_file(filePath)
        local file = io.open(filePath, "r")
        if file then
            local content = file:read("*a")
            file:close() -- ファイルを閉じる

            return json.decode(content)
        end
        return nil
    end

    local function save_json_file(filePath, data)
        local json_output = json.encode(data)
        local file = io.open(filePath, "w")
        if file then
            file:write(json_output)
            file:close()
            -- print("JSONファイルが保存されました: " .. string.gsub(filePath, "../", "\\"))
        end
    end

    local raid_list_file_location = string.format('../addons/%s/raid_list.json', addonNameLower)
    if file_exists(raid_list_file_location) then

        local file = io.open(raid_list_file_location, "w") -- "w" モードでファイルを開く (上書き)
        if file then
            local json_string = json.encode(raid_list) -- JSON エンコードが必要
            file:write(json_string)
            file:close()
        end
    else
        save_json_file(raid_list_file_location, raid_list)
    end

    local zone_id_list_file_location = string.format('../addons/%s/zone_id_list.json', addonNameLower)
    if file_exists(zone_id_list_file_location) then

        local file = io.open(zone_id_list_file_location, "w") -- "w" モードでファイルを開く (上書き)
        if file then
            local json_string = json.encode(zone_id_list) -- JSON エンコードが必要
            file:write(json_string)
            file:close()
        end

    else
        save_json_file(zone_id_list_file_location, zone_id_list)
    end
end

function quickslot_operate_INDUNINFO_DETAIL_LBTN_CLICK(frame, msg)
    local parent, detailCtrl, clicked = acutil.getEventArgs(msg)

    local frame = parent:GetTopParentFrame();
    local posbox = GET_CHILD_RECURSIVELY(frame, "posBox")
    local childCount = posbox:GetChildCount()
    local map_id = ""
    -- 各子要素の名前を取得して表示
    for i = 0, childCount - 1 do
        local child = posbox:GetChildByIndex(i) -- 子要素をインデックスで取得
        if string.find(child:GetName(), "MAP_CTRL_") then
            map_id = string.gsub(child:GetName(), "MAP_CTRL_", "")
        end
    end
    local indunClassID = detailCtrl:GetUserIValue('INDUN_CLASS_ID');
    local indun = GetClassByType('Indun', indunClassID)
    local dungeonType = TryGetProp(indun, "DungeonType");
    local ctrl = GET_CHILD_RECURSIVELY(parent, detailCtrl:GetName())
    AUTO_CAST(ctrl)
    if dungeonType == "Raid" then
        -- print(tostring(ctrl:GetName()))
        ctrl:SetEventScript(ui.RBUTTONUP, "quickslot_operate_displayid")
        ctrl:SetEventScriptArgNumber(ui.RBUTTONUP, indunClassID)
        ctrl:SetEventScriptArgString(ui.RBUTTONUP, map_id)
    end
end

function quickslot_operate_displayid(frame, ctrl, map_id, indun_id)

    ui.SysMsg("indun id: " .. indun_id .. "{nl}map id: " .. map_id)
end

function quickslot_operate_ON_GUILD_EVENT_RECRUITING_START(frame, msg, argstr, argnum)

    local eventCls = GetClassByType("GuildEvent", argnum);
    if eventCls == nil then
        return;
    end
    local mapCls = GetClass("Map", eventCls.StartMap);
    if mapCls == nil then
        return;
    end

    local isRefused = geClientGuildEvent.IsRefusedGuildEvent(GUILD_EVENT_TABLE.EVENT_ID,
                                                             GUILD_EVENT_TABLE.START_TIME_STR)
    if isRefused == true then
        return;
    end

    local mapName = dic.getTranslatedStr(mapCls.Name);
    local eventName = dic.getTranslatedStr(eventCls.Name);
    print(tostring(mapName) .. ":" .. tostring(eventName))
end

function QUICKSLOT_OPERATE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}
    g.frame_settings = g.frame_settings or {}

    addon:RegisterMsg('GAME_START', 'quickslot_operate_json_settings')
    acutil.setupEvent(addon, "SHOW_INDUNENTER_DIALOG", "quickslot_operate_SHOW_INDUNENTER_DIALOG");
    addon:RegisterMsg('GAME_START_3SEC', 'quickslot_operate_set_script')
    acutil.setupEvent(addon, "INDUNINFO_DETAIL_LBTN_CLICK", "quickslot_operate_INDUNINFO_DETAIL_LBTN_CLICK");

    addon:RegisterMsg("GUILD_EVENT_RECRUITING_START", "quickslot_operate_ON_GUILD_EVENT_RECRUITING_START")

    quickslot_operate_load_settings()

    local currentZone = GetZoneName()
    local mapCls = GetClass('Map', currentZone)
    local map_id = mapCls.ClassID

    for _, zone_id in ipairs(zone_id_list) do
        if zone_id == map_id then
            ReserveScript("quickslot_operate_change_potion()", 3.0) -- !
            -- DebounceScript("quickslot_operate_change_potion", 1.0);
            break
        end
    end

    quickslot_operate_frame_init()

    if g.frame_settings.straight then

        quickslot_operate_start_straight()
    end
end

function quickslot_operate_save_icon()
    local frame = ui.GetFrame("quickslotnexpbar")

    local LoginName = session.GetMySession():GetPCApc():GetName()

    if g.settings[LoginName] == nil then
        g.settings[LoginName] = {}
    end
    local mainSession = session.GetMainSession();
    local pcJobInfo = mainSession:GetPCJobInfo();
    local jobCount = pcJobInfo:GetJobCount();
    for i = 0, jobCount - 1 do
        local jobInfo = pcJobInfo:GetJobInfoByIndex(i);
        local jobid = "jobid" .. i + 1
        g.settings[LoginName][jobid] = tonumber(jobInfo.jobID)
    end
    for i = 1, 40 do
        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i)
        local icon = slot:GetIcon()
        if icon ~= nil then

            local iconinfo = icon:GetInfo();

            local category = iconinfo:GetCategory()
            local type = iconinfo.type
            local iesid = iconinfo:GetIESID()
            g.settings[LoginName][tostring(i)] = {
                ["category"] = category,
                ["type"] = type,
                ["iesid"] = iesid
            }
        end
    end
    ui.SysMsg("Slot contents saved.")
    quickslot_operate_save_settings()
end

function quickslot_operate_context_delete(frame, ctr, str, num)
    local context = ui.CreateContextMenu("DELETE_CONTEXT", "set delete", 0, -500, 0, 0);
    ui.AddContextMenuItem(context, " ", "")
    for key, value in pairs(g.settings) do
        if key ~= "straight" then
            local jobidStr = "" -- jobid を格納する変数
            for key2, value2 in pairs(value) do
                if key2:match("^jobid%d+$") then
                    local jobClass = GetClassByType("Job", tonumber(value2))
                    local jobname = TryGetProp(jobClass, "Name", "None")
                    local start_index, end_index = string.find(jobname, '@dicID')
                    if start_index == 1 then
                        jobname = dic.getTranslatedStr(TryGetProp(jobClass, "Name", "None"))
                    end

                    if jobidStr == "" then

                        jobidStr = tostring(jobname)
                    else
                        jobidStr = jobidStr .. ", " .. tostring(jobname)
                    end
                end

            end
            local displayText = key
            if jobidStr ~= "" then
                displayText = key .. " (" .. jobidStr .. ")"
            end
            local scp = ui.AddContextMenuItem(context, displayText,
                                              string.format("quickslot_operate_reverse_set('%s')", key))
        end
    end

    ui.OpenContextMenu(context);
end

function quickslot_operate_reverse_set(characterName)
    local yesScp = string.format("quickslot_operate_delete_set('%s')", characterName)
    ui.MsgBox("delete the set registration for the{nl}selected character?", yesScp, "None");

end

function quickslot_operate_delete_set(characterName)
    g.settings[characterName] = nil
    quickslot_operate_save_settings()
end
-- quickslot_operate_context
function quickslot_operate_context(frame, ctr, str, num)
    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if settings then
        g.settings = settings
    else
        return
    end
    local context = ui.CreateContextMenu("CONTEXT", "set load", 0, -500, 0, 0);
    ui.AddContextMenuItem(context, " ", "")
    for key, value in pairs(g.settings) do
        if key ~= "straight" then
            local jobidStr = "" -- jobid を格納する変数
            for key2, value2 in pairs(value) do
                if key2:match("^jobid%d+$") then
                    local jobClass = GetClassByType("Job", tonumber(value2))
                    local jobname = TryGetProp(jobClass, "Name", "None")
                    local start_index, end_index = string.find(jobname, '@dicID')
                    if start_index == 1 then
                        jobname = dic.getTranslatedStr(TryGetProp(jobClass, "Name", "None"))
                    end

                    if jobidStr == "" then

                        jobidStr = tostring(jobname)
                    else
                        jobidStr = jobidStr .. ", " .. tostring(jobname)
                    end
                end

            end
            local displayText = key
            if jobidStr ~= "" then
                displayText = key .. " (" .. jobidStr .. ")"
            end
            local scp = ui.AddContextMenuItem(context, displayText,
                                              string.format("quickslot_operate_load_icon('%s')", key))
        end
    end

    ui.OpenContextMenu(context);
end

function quickslot_operate_load_icon(characterName)

    local qsframe = ui.GetFrame("quickslotnexpbar")
    local slotCount = 40
    for i = 0, slotCount - 1 do
        local slot = tolua.cast(qsframe:GetChildRecursively("slot" .. i + 1), "ui::CSlot")
        local quickSlotInfo = quickslot.GetInfoByIndex(i);

        local icon = slot:GetIcon()
        if icon ~= nil then
            local iconinfo = icon:GetInfo()
            local classid = iconinfo.type
            for _, id in pairs(potion_list) do
                if id == classid then
                    slot:StopUpdateScript("quickslot_operate_frame_close")

                    break

                end
            end

        end
    end
    local slot = GET_CHILD_RECURSIVELY(qsframe, "slot1")

    local frame = ui.GetFrame("quickslot_operate")
    frame:RemoveAllChild()

    frame:Resize(500, 200)
    frame:SetPos(slot:GetDrawX(), slot:GetDrawY() - 240)
    frame:SetTitleBarSkin("None")
    frame:ShowWindow(1)
    frame:SetSkinName("chat_window")
    frame:SetLayerLevel(91);

    local y = 0
    local row = 30
    for num = 1, 4 do
        local slotset = frame:CreateOrGetControl('slotset', 'slotset' .. num, 0, y, 0, 0)
        AUTO_CAST(slotset);
        slotset:SetSlotSize(48, 48) -- スロットの大きさ
        slotset:EnablePop(0)
        slotset:EnableDrag(0)
        slotset:EnableDrop(0)
        slotset:SetColRow(10, 1)
        slotset:SetSpc(2, 2)
        slotset:SetSkinName('quickslot')
        slotset:CreateSlots()
        local slotcount = slotset:GetSlotCount()

        -- local LoginName = session.GetMySession():GetPCApc():GetName()

        for i = 1, slotcount do
            local slot = GET_CHILD(slotset, "slot" .. i)
            if g.settings[characterName][tostring(row + i)] ~= nil then
                local category = g.settings[characterName][tostring(row + i)].category
                local clsid = g.settings[characterName][tostring(row + i)].type

                if category == "Item" then
                    local ItemCls = GetClassByType("Item", clsid);

                    SET_SLOT_ITEM_CLS(slot, ItemCls);
                elseif category == "Skill" then
                    local sklCls = GetClassByType("Skill", clsid);
                    SET_SLOT_SKILL(slot, sklCls);
                elseif category == "Ability" then
                    local abilClass = GetClassByType("Ability", clsid);
                    local imageName = abilClass.Icon;
                    -- 
                    SET_SLOT_IMG(slot, imageName);
                    local icon = CreateIcon(slot);
                    icon:SetTooltipType("ability");
                    icon:SetTooltipOverlap(1);
                    icon:SetTooltipStrArg(abilClass.Name);
                    icon:SetTooltipNumArg(abilClass.ClassID);

                end
            end
        end
        row = row - 10
        y = y + 50
    end
    local yesScp = string.format("quickslot_operate_update_all_slot('%s')", characterName)
    local noScp = string.format("quickslot_operate_frame_close()")
    ui.MsgBox("swap quick slots?", yesScp, noScp);
end

function quickslot_operate_update_all_slot(characterName)
    local frame = ui.GetFrame('quickslotnexpbar');
    local sklCnt = frame:GetUserIValue('SKL_MAX_CNT');
    local slot_count = 20
    if GET_CHILD_RECURSIVELY(frame, "slot" .. 31):IsVisible() == 1 then
        slot_count = 40
    elseif GET_CHILD_RECURSIVELY(frame, "slot" .. 31):IsVisible() == 0 and
        GET_CHILD_RECURSIVELY(frame, "slot" .. 21):IsVisible() == 1 then
        slot_count = 30
    end
    -- local LoginName = session.GetMySession():GetPCApc():GetName()
    for i = 0, slot_count - 1 do
        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot");
        slot:ReleaseBlink();
        slot:ClearIcon();
        quickslot.SetInfo(slot:GetSlotIndex(), 'None', 0, '0');
        QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0);
        -- quickslot.RequestRefresh()
    end
    for i = 0, slot_count - 1 do
        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot");
        if g.settings[characterName][tostring(i + 1)] ~= nil then
            local category = g.settings[characterName][tostring(i + 1)].category
            local clsid = g.settings[characterName][tostring(i + 1)].type
            local iesid = g.settings[characterName][tostring(i + 1)].iesid

            SET_QUICK_SLOT(frame, slot, category, clsid, iesid, 0, true, true);
        end
    end

    quickslot_operate_frame_close()
    DebounceScript("QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT", 0.1);
    -- frame:Invalidate();
    -- ReserveScript("quickslot.RequestRefresh()", 2.0)

end

function quickslot_operate_frame_init()
    local frame = ui.GetFrame("quickslotnexpbar")
    local setting = frame:CreateOrGetControl("button", "setting", 0, 0, 20, 20)
    AUTO_CAST(setting)
    setting:SetMargin(-265, 0, 0, 131)
    setting:SetText("{ol}{s11}M")
    setting:SetGravity(ui.CENTER_HORZ, ui.BOTTOM);
    setting:SetTextTooltip("{ol}Change to straight mode.")
    setting:SetEventScript(ui.LBUTTONUP, "quickslot_operate_straight")

    local save = frame:CreateOrGetControl("button", "save", 0, 0, 20, 20)
    AUTO_CAST(save)
    save:SetMargin(-265, 0, 0, 55)
    save:SetText("{ol}{s11}S")
    save:SetTextTooltip("{ol}Save the contents of the quick slot.")
    save:SetGravity(ui.CENTER_HORZ, ui.BOTTOM);
    save:SetEventScript(ui.LBUTTONUP, "quickslot_operate_save_icon")

    local load = frame:CreateOrGetControl("button", "load", 0, 0, 20, 20)
    AUTO_CAST(load)
    load:SetMargin(-240, 0, 0, 55)
    load:SetText("{ol}{s11}L")
    load:SetTextTooltip("{ol}LeftClick:Load the contents of the quick slot.{nl}" ..
                            "RightClick:Delete set registration.")
    load:SetGravity(ui.CENTER_HORZ, ui.BOTTOM);
    load:SetEventScript(ui.LBUTTONUP, "quickslot_operate_context")
    load:SetEventScript(ui.RBUTTONUP, "quickslot_operate_context_delete")
end

function quickslot_operate_start_straight()
    local frame = ui.GetFrame("quickslotnexpbar")
    local margin = -200
    for i = 11, 20 do
        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i)
        AUTO_CAST(slot)
        slot:SetMargin(margin, 230, 0, 0)
        margin = margin + 50
    end

    margin = -200
    for i = 21, 30 do
        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i)
        AUTO_CAST(slot)
        if slot:IsVisible() == 1 then
            slot:SetMargin(margin, 180, 0, 0)
            margin = margin + 50
        end
    end

    margin = -200
    for i = 31, 40 do
        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i)
        AUTO_CAST(slot)
        if slot:IsVisible() == 1 then
            slot:SetMargin(margin, 130, 0, 0)
            margin = margin + 50
        end
    end
    QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT()
    frame:Invalidate();
end

function quickslot_operate_straight()
    local frame = ui.GetFrame("quickslotnexpbar")

    if g.frame_settings.straight == false then
        local margin = -200
        for i = 11, 20 do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i)
            AUTO_CAST(slot)
            slot:SetMargin(margin, 230, 0, 0)
            margin = margin + 50
        end

        margin = -200
        for i = 21, 30 do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i)
            AUTO_CAST(slot)
            if slot:IsVisible() == 1 then
                slot:SetMargin(margin, 180, 0, 0)
                margin = margin + 50
            end
        end

        margin = -200
        for i = 31, 40 do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i)
            AUTO_CAST(slot)
            if slot:IsVisible() == 1 then
                slot:SetMargin(margin, 130, 0, 0)
                margin = margin + 50
            end
        end
        QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT()
        frame:Invalidate();
        g.frame_settings.straight = true
        acutil.saveJSON(g.frame_settingsFileLoc, g.frame_settings)
    else
        local margin = -225
        for i = 11, 20 do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i)
            AUTO_CAST(slot)
            slot:SetMargin(margin, 230, 0, 0)
            margin = margin + 50
        end

        margin = -250
        for i = 21, 30 do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i)
            AUTO_CAST(slot)
            if slot:IsVisible() == 1 then
                slot:SetMargin(margin, 180, 0, 0)
                margin = margin + 50
            end
        end

        margin = -225
        for i = 31, 40 do
            local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i)
            AUTO_CAST(slot)
            if slot:IsVisible() == 1 then
                slot:SetMargin(margin, 130, 0, 0)
                margin = margin + 50
            end
        end
        QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT()
        frame:Invalidate();
        g.frame_settings.straight = false
        acutil.saveJSON(g.frame_settingsFileLoc, g.frame_settings)
    end

end

function quickslot_operate_change_potion()

    local group_name = quickslot_operate_GetGroupName(tonumber(g.induntype))
    g.induntype = 0

    local potion_id = potion_list[group_name]
    local down_potion_id = down_potion_list[group_name]

    quickslot_operate_get_potion(potion_id, down_potion_id)
end

function quickslot_operate_set_script()
    local frame = ui.GetFrame("quickslotnexpbar")
    if not frame then
        return
    end

    local slotCount = 40

    for i = 0, slotCount - 1 do
        local slot = tolua.cast(frame:GetChildRecursively("slot" .. i + 1), "ui::CSlot")
        -- AUTO_CAST(slot)
        local quickSlotInfo = quickslot.GetInfoByIndex(i);

        local icon = slot:GetIcon()
        if icon ~= nil then
            local iconinfo = icon:GetInfo()
            local classid = iconinfo.type
            for _, id in pairs(potion_list) do
                if id == classid then
                    slot:SetEventScript(ui.MOUSEON, "quickslot_operate_choice_potion");

                    break

                end
            end

        end
    end
end

function quickslot_operate_frame_close()
    local frame = ui.GetFrame("quickslot_operate")
    frame:ShowWindow(0)
    return 0
end

function quickslot_operate_SHOW_INDUNENTER_DIALOG()

    local frame = ui.GetFrame('indunenter')
    local induntype = tonumber(frame:GetUserValue("INDUN_TYPE")) -- Ensure it's a number

    local group_name = quickslot_operate_GetGroupName(induntype)

    local potion_id = potion_list[group_name]
    local down_potion_id = down_potion_list[group_name]
    if potion_id ~= nil or down_potion_id ~= nil then

        -- ReserveScript(string.format("quickslot_operate_get_potion(%d, %d)", potion_id, down_potion_id), 0.5)
        quickslot_operate_get_potion(potion_id, down_potion_id)
    end
end

function quickslot_operate_GetGroupName(induntype)
    for group, indun_list in pairs(raid_list) do
        for _, indun_id in ipairs(indun_list) do
            if indun_id == induntype then
                -- print(indun_id .. ":" .. type(indun_id))
                g.induntype = indun_id
                return group
            end
        end
    end
    return
end

function quickslot_operate_get_potion(potion_id, down_potion_id)
    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList()
    local cnt = guidList:Count()

    local found_potion_id = nil
    local found_down_potion_id = nil

    for i = 0, cnt - 1 do
        local guid = guidList:Get(i)
        local invItem = invItemList:GetItemByGuid(guid)
        local itemobj = GetIES(invItem:GetObject())
        local class_id = itemobj.ClassID

        if class_id == potion_id then
            found_potion_id = potion_id
        elseif class_id == down_potion_id then
            found_down_potion_id = down_potion_id
        end

        if found_potion_id and found_down_potion_id then
            break
        end
    end

    if found_potion_id and found_down_potion_id then
        quickslot_operate_check_all_slots(found_potion_id, found_down_potion_id)
    elseif found_potion_id then
        quickslot_operate_check_all_slots(found_potion_id, nil) -- down_potion_idはnil
    elseif found_down_potion_id then
        quickslot_operate_check_all_slots(nil, found_down_potion_id) -- potion_idはnil
    end
end

function quickslot_operate_check_all_slots(potion_id, down_potion_id)

    local frame = ui.GetFrame("quickslotnexpbar")
    local joyframe = ui.GetFrame('joystickquickslot')
    if IsJoyStickMode() == 1 then
        g.stick_mode = 1
        frame:ShowWindow(1)
        joyframe:ShowWindow(0)
    end

    --[[if not frame then
        return
    end]]

    local slotCount = 40

    for i = 0, slotCount - 1 do
        local slot = tolua.cast(frame:GetChildRecursively("slot" .. i + 1), "ui::CSlot")
        -- AUTO_CAST(slot)
        local quickSlotInfo = quickslot.GetInfoByIndex(i);

        local icon = slot:GetIcon()
        if icon ~= nil then
            local iconinfo = icon:GetInfo()
            local classid = iconinfo.type
            if potion_id ~= nil then
                for group, id in pairs(potion_list) do
                    if id == classid then

                        SET_QUICK_SLOT(frame, slot, quickSlotInfo.category, potion_id, _, 0, true, true)
                        icon:SetDumpArgNum(i);
                        break
                    end
                end
            end
            if down_potion_id ~= nil then
                for group, id in pairs(down_potion_list) do
                    if id == classid then

                        SET_QUICK_SLOT(frame, slot, quickSlotInfo.category, down_potion_id, _, 0, true, true)
                        icon:SetDumpArgNum(i);
                        break
                    end
                end
            end
        end
    end

    if g.stick_mode == 1 then

        frame:ShowWindow(0)
        joyframe:ShowWindow(1)
        DebounceScript("JOYSTICK_QUICKSLOT_UPDATE_ALL_SLOT", 0.1);
        -- g.stick_mode = 0
    else
        DebounceScript("QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT", 0.1);
    end
end

function quickslot_operate_choice_potion(frame, ctrl, str, num)
    local slot = ctrl
    slot:RunUpdateScript("quickslot_operate_frame_close", 5);

    local frame = ui.GetFrame("quickslot_operate")
    frame:RemoveAllChild()
    frame:Resize(150, 30)
    frame:SetPos(720 + 140, 810)
    frame:SetTitleBarSkin("None")
    frame:SetSkinName("chat_window")
    frame:SetLayerLevel(150);

    local slotset = frame:CreateOrGetControl('slotset', 'slotset', 0, 0, 0, 0)
    AUTO_CAST(slotset);
    slotset:SetSlotSize(30, 30) -- スロットの大きさ
    slotset:EnablePop(0)
    slotset:EnableDrag(0)
    slotset:EnableDrop(0)
    slotset:SetColRow(5, 1)
    slotset:SetSpc(0, 0)
    slotset:SetSkinName('slot')
    slotset:CreateSlots()
    local slotcount = slotset:GetSlotCount()

    local index = 1
    for _, id in pairs(potion_list) do
        if index <= slotcount then
            local slot = slotset:GetSlotByIndex(index - 1)
            slot:SetEventScript(ui.LBUTTONDOWN, "quickslot_operate_set_potion")
            slot:SetEventScriptArgNumber(ui.LBUTTONDOWN, id)
            local class = GetClassByType('Item', id)
            SET_SLOT_ITEM_CLS(slot, class)
            index = index + 1
        end
    end
    frame:ShowWindow(1)

end

function quickslot_operate_set_potion(frame, ctrl, str, clasid)
    local matched_key = nil
    for key, value in pairs(potion_list) do
        if value == clasid then
            matched_key = key
            break
        end
    end

    if matched_key then
        local down_potion_id = down_potion_list[matched_key]
        if down_potion_id then
            quickslot_operate_check_all_slots(clasid, down_potion_id)
            local frame = ui.GetFrame("quickslot_operate")
            frame:ShowWindow(0)
        end

    end
end

