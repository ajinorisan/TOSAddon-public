local addonName = "test_norisan"
local addon_name_lower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local json = require('json')

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

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
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

function g.load_settings()

    local function load_json(path)

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

    local settings = load_json(g.settings_path)

    if not settings then
        settings = {}
    end

    if not settings[g.cid] then
        settings[g.cid] = {
            iesid = "",
            clsid = 0
        }
    end

    g.settings = settings
    g.save_settings()
end

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

        if bool == true and original_results ~= nil then
            return table.unpack(original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function

    if not g.REGISTER[origin_func_name] then -- g.RAGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
end

function test_norisan_PROCESS_MOVE_MAIN_POPUPCHAT_FRAME(frame)
    if mouse.IsLBtnPressed() == 0 then
        MOVE_FRAME_MAIN_POPUP_CHAT_END(frame)
        return 0;
    end
    -- print(frame:GetName())
    local ratio = option.GetClientHeight() / option.GetClientWidth();
    local limitOffset = 10;
    -- local limitMaxWidth = ui.GetSceneWidth() / ui.GetRatioWidth() - limitOffset;
    local limitMaxWidth = ui.GetSceneWidth() - limitOffset;
    local limitMaxHeight = limitMaxWidth * ratio - limitOffset * 12;

    local mx, my = GET_MOUSE_POS();
    mx = mx / ui.GetRatioWidth();
    my = my / ui.GetRatioHeight();

    local bx = frame:GetUserIValue("MOUSE_X");
    local by = frame:GetUserIValue("MOUSE_Y");
    local dx = (mx - bx);
    local dy = (my - by);

    local width = frame:GetUserIValue("BEFORE_W");
    local height = frame:GetUserIValue("BEFORE_H");
    width = width + dx;
    height = height + dy;

    if width < limitOffset then
        width = limitOffset;
    end

    if height < limitOffset then
        height = limitOffset;
    end

    local wndW = frame:GetWidth();
    local wndH = frame:GetHeight()

    if (width + wndW) > limitMaxWidth then
        width = limitMaxWidth - wndW;
    end

    if (height + wndH) > limitMaxHeight then
        height = (limitMaxHeight - wndH);
    end

    frame:SetOffset(width, height);

    return 1;
end

function test_norisan__PROCESS_MOVE_MAIN_POPUPCHAT_FRAME(my_frame, my_msg)

    local frame = g.get_event_args(my_msg)
    frame:RunUpdateScript("test_norisan_PROCESS_MOVE_MAIN_POPUPCHAT_FRAME", 0.1);

end

function TEST_NORISAN_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()

    g.REGISTER = {}
    g.setup_hook_and_event(addon, "_PROCESS_MOVE_MAIN_POPUPCHAT_FRAME",
        "test_norisan__PROCESS_MOVE_MAIN_POPUPCHAT_FRAME", false)

    g.load_settings()
    test_norisan_frame_init(frame)

    addon:RegisterMsg('FPS_UPDATE', 'test_norisan_FPS_UPDATE')
    addon:RegisterMsg('FPS_UPDATE', 'test_norisan_sp_use')
    addon:RegisterMsg('GAME_START_3SEC', 'test_norisan_GAME_START_3SEC')
    if g.get_map_type() ~= "City" then
        frame:RunUpdateScript("test_norisan_get_cooldown", 0.1)
    end
end

function test_norisan_get_cooldown(frame)

    local frame = ui.GetFrame('quickslotnexpbar');

    for i = 0, MAX_QUICKSLOT_CNT - 1 do
        local quickSlotInfo = quickslot.GetInfoByIndex(i);

        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot");
        local pain_cool = 0
        local icon = slot:GetIcon()
        if quickSlotInfo.type == 10005 then

            pain_cool = ICON_UPDATE_SKILL_COOLDOWN(icon)
            print(tostring(pain_cool))
            if pain_cool == 0 then
                ICON_USE(icon)
            end
        end

    end

    local summonedPet = GET_SUMMONED_PET();

    if summonedPet ~= nil then

        local pet_guid = summonedPet:GetStrGuid()
        local petInfo = session.pet.GetPetByGUID(pet_guid);
        local obj = GetIES(petInfo:GetObject())

        if obj.IsActivated ~= 1 then
            return
        end
    else
        return 1
    end

    local void_cool = 0
    local dance_enable = 0

    for i = 0, MAX_QUICKSLOT_CNT - 1 do
        local quickSlotInfo = quickslot.GetInfoByIndex(i);

        local slot = GET_CHILD_RECURSIVELY(frame, "slot" .. i + 1, "ui::CSlot");

        local icon = slot:GetIcon()
        if quickSlotInfo.type == 12329 then
            void_cool = ICON_UPDATE_SKILL_COOLDOWN(icon)
        elseif quickSlotInfo.type == 12332 then
            dance_enable = ICON_UPDATE_SKILL_ENABLE(icon)
        end

    end

    if void_cool == 0 then
        ON_RIDING_VEHICLE(0)
    elseif dance_enable ~= 0 then
        ON_RIDING_VEHICLE(0)
    else
        ON_RIDING_VEHICLE(1)
    end
    return 1
end

function test_norisan_FPS_UPDATE(frame)

    local frame = ui.GetFrame("test_norisan")

    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    end

    local lifticon = ui.GetLiftIcon();
    local iconinfo = lifticon:GetInfo();
    local type = iconinfo.type

end

function g.log_to_file(message)

    local time = os.date("%Y%m%d")
    local file_path = string.format("../addons/%s/log_%s.txt", addon_name_lower, time)
    local file = io.open(file_path, "a")

    if file then
        local timestamp = os.date("[%Y-%m-%d %H:%M:%S] ")
        file:write(timestamp .. tostring(message) .. "\n")
        file:close()
    end
end

function test_norisan_GAME_START_3SEC()
    CHAT_SYSTEM(tostring(_G["norisan"]["MENU"].frame_name))
    CHAT_SYSTEM(tostring(_G["norisan"]["LAST_LAYER"]) .. ":バラックレイヤー :" ..
                    _G["norisan"]["HOOKS"]["BARRACK_TO_GAME"])
    -- g.addon:RegisterMsg('FPS_UPDATE', 'test_norisan_hp_use')
end

function test_norisan_hp_use(frame, msg, str, num)
    local stat = info.GetStat(session.GetMyHandle())
    local ratio = stat.HP / stat.maxHP

    if ratio > 0.6 then
        return
    end

    local function test_norisan_INV_ICON_USE(invItem)
        if nil == invItem then
            return
        end

        if true == invItem.isLockState then
            ui.SysMsg(ClMsg("MaterialItemIsLock"))
            return
        end

        if true == RUN_CLIENT_SCP(invItem) then
            return
        end

        local stat = info.GetStat(session.GetMyHandle())
        if stat.HP <= 0 then
            return
        end

        local itemtype = invItem.type
        local curTime = item.GetCoolDown(itemtype)
        if curTime ~= 0 then
            return
        end

        item.UseByGUID(invItem:GetIESID())
    end

    local pot_table = {641906, 640405}
    session.ResetItemList()
    local invItemList = session.GetInvItemList()

    for _, classid in ipairs(pot_table) do
        local use_item = session.GetInvItemByType(classid)
        if use_item then
            test_norisan_INV_ICON_USE(use_item)
        end
    end
end

function test_norisan_sp_use(frame, msg, str, num)
    local stat = info.GetStat(session.GetMyHandle())
    local ratio = stat.SP / stat.maxSP

    if ratio > 0.3 then
        return
    end

    local function test_norisan_INV_ICON_USE(invItem)
        if nil == invItem then
            return
        end

        if true == invItem.isLockState then
            ui.SysMsg(ClMsg("MaterialItemIsLock"))
            return
        end

        if true == RUN_CLIENT_SCP(invItem) then
            return
        end

        local stat = info.GetStat(session.GetMyHandle())
        if stat.HP <= 0 then
            return
        end

        local itemtype = invItem.type
        local curTime = item.GetCoolDown(itemtype)
        if curTime ~= 0 then
            return
        end

        item.UseByGUID(invItem:GetIESID())
    end

    local pot_table = {640448, 640436, 640406}
    session.ResetItemList()
    local invItemList = session.GetInvItemList()

    for _, classid in ipairs(pot_table) do
        local use_item = session.GetInvItemByType(classid)
        if use_item then
            test_norisan_INV_ICON_USE(use_item)
        end
    end
end

function test_norisan_frame_init(frame)

    frame:SetSkinName('None')
    frame:Resize(40, 40)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHide(0)
    frame:SetPos(1200, 5)
    frame:ShowWindow(1)

    local btn = frame:CreateOrGetControl('button', 'btn', 0, 0, 30, 30)
    AUTO_CAST(btn)
    btn:SetSkinName("None")
    btn:SetText("{img config_button_normal 30 30}")
    btn:SetEventScript(ui.LBUTTONUP, "DEVELOPERCONSOLE_TOGGLE_FRAME")
end
