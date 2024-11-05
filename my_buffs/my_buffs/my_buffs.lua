-- v1.0.0 とりあえず公開
local addonName = "my_buffs"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")
local json = require("json")
local os = require("os")

local folder_path = string.format("../addons/%s", addonNameLower)
os.execute('mkdir "' .. folder_path .. '"')

g.settings_file_path = string.format("../addons/%s/settings.json", addonNameLower)
g.get_buffs_file_path = string.format("../addons/%s/get_buffs.json", addonNameLower)

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName]
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function MY_BUFFS_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    my_buffs_load_settings()

    addon:RegisterMsg("GAME_START", "my_buffs_frame")
    addon:RegisterMsg("BUFF_ADD", "my_buffs_BUFF_ADD")

    g.SetupHook(my_buffs_BUFF_ON_MSG, "BUFF_ON_MSG")

    g.hook = false
    local functionName = "SEPARATEDPCDEBUFF_ON_INIT" -- チェックしたい関数の名前を文字列として指定します
    if type(_G[functionName]) == "function" then

        g.hook = true
    end

end
function my_buffs_BUFF_ON_MSG(frame, msg, argStr, argNum)
    local handle = session.GetMyHandle();
    local map_class = GetClass("Map", session.GetMapName());
    if map_class.MapType ~= 'City' then
        local str_buff_id = tostring(argNum)
        if g.settings.buffs[str_buff_id] == false then

            return
        end
    end

    if BUFF_CHECK_SEPARATELIST(argNum) == true then
        return;
    end

    if not g.hook then
        if msg == "BUFF_ADD" then
            COMMON_BUFF_MSG(frame, "ADD", argNum, handle, s_buff_ui, argStr);
        elseif msg == "BUFF_REMOVE" then
            COMMON_BUFF_MSG(frame, "REMOVE", argNum, handle, s_buff_ui, argStr);
        elseif msg == "BUFF_UPDATE" then
            COMMON_BUFF_MSG(frame, "UPDATE", argNum, handle, s_buff_ui, argStr);
        end
    else
        if msg == "BUFF_ADD" then
            COMMON_BUFF_MSG_OLD(frame, "ADD", argNum, handle, s_buff_ui, argStr);
        elseif msg == "BUFF_REMOVE" then
            COMMON_BUFF_MSG_OLD(frame, "REMOVE", argNum, handle, s_buff_ui, argStr);
        elseif msg == "BUFF_UPDATE" then
            COMMON_BUFF_MSG_OLD(frame, "UPDATE", argNum, handle, s_buff_ui, argStr);
        end
    end

    MY_BUFF_TIME_UPDATE(frame);
    BUFF_RESIZE(frame, s_buff_ui);
end

function my_buffs_SET_BUFF_SLOT(slot, capt, class, buffType, handle, slotlist, buffIndex, isOtherCast)
    local map_class = GetClass("Map", session.GetMapName());
    if map_class.MapType ~= 'City' then
        local str_buff_id = tostring(buffType)
        if g.settings.buffs[str_buff_id] == false then

            return
        end
    end
    base["SET_BUFF_SLOT"](slot, capt, class, buffType, handle, slotlist, buffIndex, isOtherCast)
end

function my_buffs_BUFF_ADD(frame, ctrl, str, num)
    local str_buff_id = tostring(num)
    if g.settings.buffs[str_buff_id] == nil then
        g.settings.buffs[str_buff_id] = true
        my_buffs_save_settings()
    end
end

function my_buffs_load_settings()

    local settings = acutil.loadJSON(g.settings_file_path, g.settings)

    if not settings then
        settings = {
            buffs = {},
            lock = true,
            default_x = 20,
            default_y = 130,
            custom_x = 20,
            custom_y = 130
        }
    end

    g.settings = settings
    my_buffs_save_settings()

end

function my_buffs_save_settings()
    acutil.saveJSON(g.settings_file_path, g.settings)
end

function my_buffs_frame_lock(frame, msg, str, num)

    local frame = ui.GetFrame("buff")
    local lock = GET_CHILD_RECURSIVELY(frame, "lock")
    if g.settings.lock then
        g.settings.lock = false
        lock:SetGrayStyle(1);
        frame:EnableHittestFrame(1)
        frame:EnableMove(1)
    else
        g.settings.lock = true
        lock:SetGrayStyle(0);
        frame:EnableHittestFrame(0)
        frame:EnableMove(0)
    end
    my_buffs_save_settings()
end

function my_buffs_frame()
    local frame = ui.GetFrame("buff")
    frame:SetEventScript(ui.LBUTTONUP, "my_buffs_end_drag")
    local map_class = GetClass("Map", session.GetMapName());
    if map_class.MapType ~= 'City' then
        frame:SetPos(g.settings.custom_x, g.settings.custom_y)
    else
        frame:SetPos(g.settings.default_x, g.settings.default_y)
    end
    frame:SetLayerLevel(61)
    local lock_slot = frame:CreateOrGetControl('slot', "lock_slot", 0, 0, 20, 30);
    AUTO_CAST(lock_slot)
    lock_slot:RemoveAllChild()
    lock_slot:SetTextTooltip(
        "{ol}My Buffs{nl}Left-Click Toggle Lock and Frame Move{nl}Right-Click Settings{/}{/}{nl} {nl}{ol}{#FF0000}※The function to reduce display buffs does not work in city")
    local lock = lock_slot:CreateOrGetControlSet('inv_itemlock', "lock", 0, 0);
    AUTO_CAST(lock)
    lock:SetGravity(ui.LEFT, ui.TOP);
    lock_slot:SetEventScript(ui.LBUTTONUP, "my_buffs_frame_lock")
    lock_slot:SetEventScript(ui.RBUTTONUP, "my_buffs_context_menu")
    if g.settings.lock then
        lock:SetGrayStyle(0);
    else
        lock:SetGrayStyle(1);
    end
end

function my_buffs_end_drag(frame, ctrl, str, num)

    g.settings.custom_x = frame:GetX()
    g.settings.custom_y = frame:GetY()

    my_buffs_save_settings()
end

function my_buffs_context_menu(frame, ctrl, str, num)
    local context = ui.CreateContextMenu("MY_BUFFS", "Setting", 0, 0, 100, 100)
    ui.AddContextMenuItem(context, "-----", "None")
    ui.AddContextMenuItem(context, "Buff list Open", string.format("my_buffs_buff_list_open()"))
    ui.AddContextMenuItem(context, "Original Position", string.format("my_buffs_original_position()"))
    ui.AddContextMenuItem(context, "----- ", "None")
    ui.AddContextMenuItem(context, "Exit", "None")
    ui.OpenContextMenu(context)
end

function my_buffs_original_position(frame, ctrl, str, num)
    local frame = ui.GetFrame("buff")
    frame:SetPos(g.settings.default_x, g.settings.default_y)
    g.settings.custom_x = g.settings.default_x
    g.settings.custom_y = g.settings.default_y
    my_buffs_save_settings()
end

function my_buffs_buff_list_close(frame, ctrl, str, num)
    frame:ShowWindow(0)
end

function my_buffs_buff_list_open(frame, ctrl, str, num)
    local buff_list_frame = ui.CreateNewFrame("notice_on_pc", addonNameLower .. "buff_list_frame", 0, 0, 10, 10)
    AUTO_CAST(buff_list_frame)
    buff_list_frame:SetSkinName("bg")
    buff_list_frame:Resize(500, 1060)
    buff_list_frame:SetPos(1400, 10)
    buff_list_frame:SetLayerLevel(121)
    buff_list_frame:RemoveAllChild()

    local buff_list_gb = buff_list_frame:CreateOrGetControl("groupbox", " buff_list_gb", 5, 35, 490, 1015)
    AUTO_CAST(buff_list_gb)
    buff_list_gb:SetSkinName("bg")

    local close_button = buff_list_frame:CreateOrGetControl('button', 'close_button', 0, 0, 20, 20)
    AUTO_CAST(close_button)
    close_button:SetImage("testclose_button")
    close_button:SetGravity(ui.RIGHT, ui.TOP)
    close_button:SetEventScript(ui.LBUTTONUP, "my_buffs_buff_list_close");

    local get_buffs, err = acutil.loadJSON(g.get_buffs_file_path, g.get_buffs)

    local sorted_buffs = {}
    for buff_id, _ in pairs(g.settings.buffs) do
        table.insert(sorted_buffs, tonumber(buff_id))
    end
    table.sort(sorted_buffs)

    local title_text = buff_list_frame:CreateOrGetControl('richtext', 'title_text', 10, 10, 200, 30)
    AUTO_CAST(title_text)
    title_text:SetText("{ol}Setting Buff List")

    -- ソートされた順番で表示
    local y = 0
    for _, buff_id in ipairs(sorted_buffs) do

        local buff_slot = buff_list_gb:CreateOrGetControl('slot', 'buffslot' .. buff_id, 10, y + 5, 30, 30)
        AUTO_CAST(buff_slot)
        local buff_class = GetClassByType("Buff", buff_id)

        if buff_class ~= nil then
            local image_name = GET_BUFF_ICON_NAME(buff_class)
            if image_name ~= "icon_None" then
                local buff_name = buff_class.Name
                if buff_name ~= "None" then

                    SET_SLOT_IMG(buff_slot, GET_BUFF_ICON_NAME(buff_class));

                    local icon = CreateIcon(buff_slot)
                    AUTO_CAST(icon)
                    icon:SetTooltipType('buff');
                    icon:SetTooltipArg(buff_name, buff_id, 0);

                    local str_buff_id = tostring(buff_id)
                    local buff_check = buff_list_gb:CreateOrGetControl('checkbox', 'buff_check' .. buff_id, 45, y + 5,
                        200, 30)
                    AUTO_CAST(buff_check)
                    buff_check:SetText("{ol}" .. buff_id .. " : " .. buff_name)
                    buff_check:SetTextTooltip("Unchecked to hide")
                    buff_check:AdjustFontSizeByWidth(430)
                    buff_check:SetCheck(g.settings.buffs[str_buff_id] and 1 or 0)
                    buff_check:SetEventScript(ui.LBUTTONUP, "my_buffs_buff_toggle")
                    buff_check:SetEventScriptArgString(ui.LBUTTONUP, str_buff_id)
                    y = y + 35
                end
            end
        end

    end

    buff_list_frame:ShowWindow(1)
end

function my_buffs_buff_toggle(frame, ctrl, str, num)
    local str_buff_id = str
    local is_check = ctrl:IsChecked()
    if is_check == 1 then
        g.settings.buffs[str_buff_id] = true
    else
        g.settings.buffs[str_buff_id] = false
    end
    my_buffs_save_settings()
end
