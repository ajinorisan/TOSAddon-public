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
local addon_name = "quickslot_operate"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.1.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local json = require("json")

function g.mkdir_new_folder()
    local function create_folder(folder_path, file_path)
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

    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(folder, file_path)

    g.active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    create_folder(user_folder, user_file_path)

    g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
end
g.mkdir_new_folder()

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)

    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end

    local origin_func = g.FUNCS[origin_func_name]

    local function hooked_function(...)

        local original_results

        if bool == true then
            original_results = {origin_func(...)}
        end

        g.ARGS = g.ARGS or {}
        g.ARGS[origin_func_name] = {...}
        imcAddOn.BroadMsg(origin_func_name)

        if original_results then
            return table.unpack(original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function

    if not g.REGISTER[origin_func_name .. my_func_name] then -- g.REGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name .. my_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function g.save_settings()
    local function save_json(path, tbl)
        local file = io.open(path, "w")
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
    save_json(g.settings_path, g.settings)
end

function g.load_json(path)

    local file = io.open(path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        local table = json.decode(content)
        return table
    else
        return nil
    end
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
--[[local zone_list = {"raid_Rosethemisterable", "raid_castle_ep14_2", "Raid_DreamyForest", "Raid_AbyssalObserver",
                   "raid_Jellyzele", "raId_castle_ep14", "raid_giltine_AutoGuild", "raid_dcapital_108",
                   "raid_kivotos_island", "Raid_DarkNeringa", "Raid_CrystalGolem", "Raid_Redania"}]]

local atk_list = {
    Velnias = 640504,
    Klaida = 640503,
    Paramune = 640502,
    Widling = 640501,
    Forester = 640500
}

local def_list = {
    Velnias = 640373,
    Klaida = 640375,
    Paramune = 640374,
    Widling = 640377,
    Forester = 640376
}

function quickslot_operate_load_settings()

    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {
            slotset = {},
            straight = false
        }
        g.settings = settings
        g.save_settings()
    else
        g.settings = settings
    end
end

function QUICKSLOT_OPERATE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    g.REGISTER = {}

    g.lang = option.GetCurrentCountry()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    if not g.settings then
        quickslot_operate_load_settings()
    end

    g.setup_hook_and_event(addon, "SHOW_INDUNENTER_DIALOG", "quickslot_operate_SHOW_INDUNENTER_DIALOG", true)
    addon:RegisterMsg("GAME_START", "quickslot_operate_straight")
    addon:RegisterMsg("GAME_START_3SEC", "quickslot_operate_GAME_START_3SEC")

end

function quickslot_operate_frame_init()
    local frame = ui.GetFrame("quickslotnexpbar")

    local settings = frame:CreateOrGetControl("button", "settings", 0, 0, 20, 20)
    AUTO_CAST(settings)
    settings:SetGravity(ui.LEFT, ui.BOTTOM)
    -- settings:SetMargin(-265, 0, 0, 55)
    settings:SetText("{ol}{s11}QSO")
    settings:SetTextTooltip(g.lang == "Japanese" and
                                "{ol}左クリック: ストレートモード切替{nl}右クリック: スロットセット保存/読込" or
                                "{ol}Left click: Switch straight mode {nl}Right click: Save/load slot set")
    settings:SetEventScript(ui.LBUTTONUP, "quickslot_operate_straight")
    settings:SetEventScript(ui.RBUTTONUP, "quickslot_operate_context")

end

function quickslot_operate_context(frame, ctr, str, num)

    local context = ui.CreateContextMenu("CONTEXT", "slotset context", 0, -500, 0, 0)
    ui.AddContextMenuItem(context, "-----", "None")
    ui.AddContextMenuItem(context,
                          g.lang == "Japanese" and "{ol}スロットレイアウト保存" or "{ol}Save Slot layout",
                          "quickslot_operate_save_slotset()")
    ui.AddContextMenuItem(context,
                          g.lang == "Japanese" and "{ol}スロットレイアウト読込" or "{ol}Load Slot layout",
                          "quickslot_operate_load_slotset_context()")
    if g.settings.slotset[g.login_name] then
        ui.AddContextMenuItem(context, g.lang == "Japanese" and "{ol}スロットレイアウト削除" or
                                  "{ol}Delete Slot layout", "quickslot_operate_delete_slotset()")
    end
    ui.OpenContextMenu(context)
end

function quickslot_operate_delete_slotset()
    g.settings.slotset[g.login_name] = nil
    g.save_settings()
end

function quickslot_operate_load_slotset_context()
    local context = ui.CreateContextMenu("CONTEXT", "Load Slotset", 0, 0, 0, 0)
    for name, data in pairs(g.settings.slotset) do

        local display = ""
        for i = 0, 3 do
            local job_key = "jobid_" .. i
            local saved_job_id = data[job_key]

            if saved_job_id then
                local job_cls = GetClassByType("Job", tonumber(saved_job_id))
                local job_name = TryGetProp(job_cls, "Name", "None")
                if string.find(job_name, '@dicID') then
                    job_name = dic.getTranslatedStr(job_name)
                end
                if display == "" then
                    display = job_name
                else
                    display = display .. ", " .. job_name
                end
            end
        end
        display = name .. "(" .. display .. ")"
        ui.AddContextMenuItem(context, display, string.format("quickslot_operate_load_all_slot('%s')", name))
    end
    ui.OpenContextMenu(context)
end

function quickslot_operate_load_all_slot(name)

    local frame = ui.GetFrame('quickslotnexpbar')
    local slot_count = 20
    if GET_CHILD_RECURSIVELY(frame, "slot" .. 31):IsVisible() == 1 then
        slot_count = 40
    elseif GET_CHILD_RECURSIVELY(frame, "slot" .. 31):IsVisible() == 0 and
        GET_CHILD_RECURSIVELY(frame, "slot" .. 21):IsVisible() == 1 then
        slot_count = 30
    end

    for i = 0, slot_count - 1 do
        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot")
        slot:ReleaseBlink()
        slot:ClearIcon()
        quickslot.SetInfo(slot:GetSlotIndex(), 'None', 0, '0')
        QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0)
    end

    for i = 0, slot_count - 1 do
        local str_index = tostring(i + 1)
        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. str_index, "ui::CSlot")
        if g.settings.slotset[name][str_index] then
            local category = g.settings.slotset[name][str_index].category
            local clsid = g.settings.slotset[name][str_index].type
            local iesid = g.settings.slotset[name][str_index].iesid
            SET_QUICK_SLOT(frame, slot, category, clsid, iesid, 0, true, true)
        end
    end
    DebounceScript("QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT", 0.1)
end

function quickslot_operate_save_slotset()
    local quickslot_bar = ui.GetFrame("quickslotnexpbar")

    if not g.settings.slotset[g.login_name] then
        g.settings.slotset[g.login_name] = {}
    end

    local main_session = session.GetMainSession()
    local pc_job_data = main_session:GetPCJobInfo()
    local job_count = pc_job_data:GetJobCount()

    for i = 0, job_count - 1 do

        local current_job_info = pc_job_data:GetJobInfoByIndex(i)
        if current_job_info then
            local job_key = "jobid_" .. i
            g.settings.slotset[g.login_name][job_key] = tonumber(current_job_info.jobID)
        end
    end

    for i = 1, 40 do
        local slot = GET_CHILD_RECURSIVELY(quickslot_bar, "slot" .. i)
        if slot then
            local icon = slot:GetIcon()
            if icon then
                local icon_info = icon:GetInfo()

                local category = icon_info:GetCategory()
                local item_type = icon_info.type
                local iesid = icon_info:GetIESID()
                g.settings.slotset[g.login_name][tostring(i)] = {
                    ["category"] = category,
                    ["type"] = item_type,
                    ["iesid"] = iesid
                }
            end
        end
    end

    ui.SysMsg(g.lang == "Japanese" and "{ol}スロットレイアウト保存" or "{ol}Save Slot layout")
    g.save_settings()
end

function quickslot_operate_GAME_START_3SEC(frame, msg)

    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_id = map_cls.ClassID

    for _, zone_id in ipairs(zone_id_list) do
        if zone_id == map_id then
            local potion_type = quickslot_operate_get_potion_type(g.indun_type)
            if potion_type then
                quickslot_operate_get_potion(potion_type)
            end
            break
        end
    end
end

function quickslot_operate_SHOW_INDUNENTER_DIALOG()

    local indunenter = ui.GetFrame('indunenter')
    local indun_type = tonumber(indunenter:GetUserValue("INDUN_TYPE"))

    local potion_type = quickslot_operate_get_potion_type(indun_type)
    if potion_type then
        quickslot_operate_get_potion(potion_type)
    end
end

function quickslot_operate_check_all_slots(atk_pid, def_pid)

    local quickslotnexpbar = ui.GetFrame("quickslotnexpbar")
    local joystickquickslot = ui.GetFrame('joystickquickslot')
    if IsJoyStickMode() == 1 then
        quickslotnexpbar:ShowWindow(1)
        joystickquickslot:ShowWindow(0)
    end

    local slotCount = 40

    for i = 0, slotCount - 1 do
        local slot = GET_CHILD_RECURSIVELY(quickslotnexpbar, "slot" .. i + 1)
        AUTO_CAST(slot)
        local quick_slot_info = quickslot.GetInfoByIndex(i)

        local icon = slot:GetIcon()
        if icon then
            local icon_info = icon:GetInfo()
            local clsid = icon_info.type
            if atk_pid then
                for group, id in pairs(atk_list) do
                    if id == clsid then
                        SET_QUICK_SLOT(quickslotnexpbar, slot, quick_slot_info.category, atk_pid, _, 0, true, true)
                        break
                    end
                end
            end
            if def_pid then
                for group, id in pairs(def_list) do
                    if id == clsid then
                        SET_QUICK_SLOT(quickslotnexpbar, slot, quick_slot_info.category, def_pid, _, 0, true, true)
                        break
                    end
                end
            end
        end
    end

    if IsJoyStickMode() == 1 then
        DebounceScript("JOYSTICK_QUICKSLOT_UPDATE_ALL_SLOT", 0.1)
        quickslotnexpbar:ShowWindow(0)
        joystickquickslot:ShowWindow(1)
    else
        DebounceScript("QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT", 0.1)
    end
end

function quickslot_operate_get_potion(potion_type)

    local atk_pid = atk_list[potion_type][1] or atk_list[potion_type][2]
    local def_pid = def_list[potion_type][1] or def_list[potion_type][2]

    session.ResetItemList()
    local inv_list = session.GetInvItemList()
    local item_guids = inv_list:GetGuidList()
    local item_count = item_guids:Count()

    local found_atk_id = nil
    local found_def_id = nil

    for i = 0, item_count - 1 do
        local current_guid = item_guids:Get(i)
        local inv_item = inv_list:GetItemByGuid(current_guid)
        local item_data = GetIES(inv_item:GetObject())
        local item_cid = item_data.ClassID

        if item_cid == atk_pid then
            found_atk_id = atk_pid
        elseif item_cid == def_pid then
            found_def_id = def_pid
        end
    end

    if found_atk_id or found_def_id then
        quickslot_operate_check_all_slots(atk_pid, def_pid)
    end
end

function quickslot_operate_get_potion_type(indun_type)
    for potion_type, indun_list in pairs(raid_list) do
        for _, indun_id in ipairs(indun_list) do
            if indun_id == indun_type then
                g.indun_type = indun_type
                return potion_type
            end
        end
    end
    return
end

function quickslot_operate_straight(frame, msg)

    local frame = ui.GetFrame("quickslotnexpbar")

    if not g.settings.straight then
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

        if msg ~= "GAME_START" then
            g.settings.straight = true
            g.save_settings()
        end

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

        if msg ~= "GAME_START" then
            g.settings.straight = false
            g.save_settings()
        end
    end
    QUICKSLOTNEXTBAR_UPDATE_ALL_SLOT()
    frame:Invalidate()

end

---

function quickslot_operate_set_script()
    local frame = ui.GetFrame("quickslotnexpbar")
    if not frame then
        return
    end

    local slotCount = 40

    for i = 0, slotCount - 1 do
        local slot = tolua.cast(frame:GetChildRecursively("slot" .. i + 1), "ui::CSlot")
        -- AUTO_CAST(slot)
        local quickSlotInfo = quickslot.GetInfoByIndex(i)

        local icon = slot:GetIcon()
        if icon ~= nil then
            local iconinfo = icon:GetInfo()
            local classid = iconinfo.type
            for _, id in pairs(potion_list) do
                if id == classid then
                    slot:SetEventScript(ui.MOUSEON, "quickslot_operate_choice_potion")

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

function quickslot_operate_ON_GUILD_EVENT_RECRUITING_START(frame, msg, argstr, argnum)

    local eventCls = GetClassByType("GuildEvent", argnum)
    if eventCls == nil then
        return
    end
    local mapCls = GetClass("Map", eventCls.StartMap)
    if mapCls == nil then
        return
    end

    local isRefused = geClientGuildEvent.IsRefusedGuildEvent(GUILD_EVENT_TABLE.EVENT_ID,
                                                             GUILD_EVENT_TABLE.START_TIME_STR)
    if isRefused == true then
        return
    end

    local mapName = dic.getTranslatedStr(mapCls.Name)
    local eventName = dic.getTranslatedStr(eventCls.Name)
    print(tostring(mapName) .. ":" .. tostring(eventName))
end

function quickslot_operate_save_icon()
    local frame = ui.GetFrame("quickslotnexpbar")

    local LoginName = session.GetMySession():GetPCApc():GetName()

    if g.settings[LoginName] == nil then
        g.settings[LoginName] = {}
    end
    local mainSession = session.GetMainSession()
    local pcJobInfo = mainSession:GetPCJobInfo()
    local jobCount = pcJobInfo:GetJobCount()
    for i = 0, jobCount - 1 do
        local jobInfo = pcJobInfo:GetJobInfoByIndex(i)
        local jobid = "jobid" .. i + 1
        g.settings[LoginName][jobid] = tonumber(jobInfo.jobID)
    end
    for i = 1, 40 do
        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i)
        local icon = slot:GetIcon()
        if icon ~= nil then

            local iconinfo = icon:GetInfo()

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
    local context = ui.CreateContextMenu("DELETE_CONTEXT", "set delete", 0, -500, 0, 0)
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

    ui.OpenContextMenu(context)
end

function quickslot_operate_reverse_set(characterName)
    local yesScp = string.format("quickslot_operate_delete_set('%s')", characterName)
    ui.MsgBox("delete the set registration for the{nl}selected character?", yesScp, "None")

end

function quickslot_operate_delete_set(characterName)
    g.settings[characterName] = nil
    quickslot_operate_save_settings()
end
-- quickslot_operate_context

function quickslot_operate_load_icon(characterName)

    local qsframe = ui.GetFrame("quickslotnexpbar")
    local slotCount = 40
    for i = 0, slotCount - 1 do
        local slot = tolua.cast(qsframe:GetChildRecursively("slot" .. i + 1), "ui::CSlot")
        local quickSlotInfo = quickslot.GetInfoByIndex(i)

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
    frame:SetLayerLevel(91)

    local y = 0
    local row = 30
    for num = 1, 4 do
        local slotset = frame:CreateOrGetControl('slotset', 'slotset' .. num, 0, y, 0, 0)
        AUTO_CAST(slotset)
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
                    local ItemCls = GetClassByType("Item", clsid)

                    SET_SLOT_ITEM_CLS(slot, ItemCls)
                elseif category == "Skill" then
                    local sklCls = GetClassByType("Skill", clsid)
                    SET_SLOT_SKILL(slot, sklCls)
                elseif category == "Ability" then
                    local abilClass = GetClassByType("Ability", clsid)
                    local imageName = abilClass.Icon
                    -- 
                    SET_SLOT_IMG(slot, imageName)
                    local icon = CreateIcon(slot)
                    icon:SetTooltipType("ability")
                    icon:SetTooltipOverlap(1)
                    icon:SetTooltipStrArg(abilClass.Name)
                    icon:SetTooltipNumArg(abilClass.ClassID)

                end
            end
        end
        row = row - 10
        y = y + 50
    end
    local yesScp = string.format("quickslot_operate_update_all_slot('%s')", characterName)
    local noScp = string.format("quickslot_operate_frame_close()")
    ui.MsgBox("swap quick slots?", yesScp, noScp)
end

function quickslot_operate_choice_potion(frame, ctrl, str, num)
    local slot = ctrl
    slot:RunUpdateScript("quickslot_operate_frame_close", 5)

    local frame = ui.GetFrame("quickslot_operate")
    frame:RemoveAllChild()
    frame:Resize(150, 30)
    frame:SetPos(720 + 140, 810)
    frame:SetTitleBarSkin("None")
    frame:SetSkinName("chat_window")
    frame:SetLayerLevel(150)

    local slotset = frame:CreateOrGetControl('slotset', 'slotset', 0, 0, 0, 0)
    AUTO_CAST(slotset)
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

function quickslot_operate_INDUNINFO_DETAIL_LBTN_CLICK(frame, msg)
    local parent, detailCtrl, clicked = acutil.getEventArgs(msg)

    local frame = parent:GetTopParentFrame()
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
    local indunClassID = detailCtrl:GetUserIValue('INDUN_CLASS_ID')
    local indun = GetClassByType('Indun', indunClassID)
    local dungeonType = TryGetProp(indun, "DungeonType")
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
