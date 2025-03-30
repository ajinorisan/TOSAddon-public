-- v1.0.7 SetupHookの競合修正。バウバス通知OFF
-- v1.0.8 バウバスのみ
local addonName = "GTSYSMSG"
local addon_name_lower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.8"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local json = require("json")

function g.setup_hook(my_func, origin_func_name)
    g.funcs = g.funcs or {}
    if not g.funcs[origin_func_name] then
        g.funcs[origin_func_name] = _G[origin_func_name]
        local function hooked_function(...)
            my_func(...)
        end
        _G[origin_func_name] = hooked_function
    end
end

function g.setup_event(my_addon, origin_func_name, my_func_name)

    g.ARGS = g.ARGS or {}
    local original_func = _G[origin_func_name]
    local function hooked_function(...)
        local success, results = pcall(original_func, ...)
        if not success then
            return
        end
        g.ARGS[origin_func_name] = {...} -- 元の関数名で引数を保存
        imcAddOn.BroadMsg(origin_func_name)
        return table.unpack(results)
    end
    _G[origin_func_name] = hooked_function
    my_addon:RegisterMsg(origin_func_name, my_func_name)
end

function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
end

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
end
g.mkdir_new_folder()

function g.get_map_type()
    local pc = GetMyPCObject();
    local current_map = GetZoneName(pc)
    local map_cls = GetClass("Map", current_map)
    local map_type = map_cls.MapType
    return map_type
end

function g.save_json(path, tbl)
    local file = io.open(path, "w")
    local str = json.encode(tbl)
    file:write(str)
    file:close()
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

function g.save_settings()
    g.save_json(g.settings_path, g.settings)
end

function g.load_settings()

    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {
            use = 0
        }
    end

    g.settings = settings
    g.save_settings()
end

function GTSYSMSG_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)

    g.load_settings()

    g.setup_hook(GTSYSMSG_NOTICE_ON_MSG, "NOTICE_ON_MSG")
    addon:RegisterMsg("GAME_START_3SEC", "GTSYSMSG_btn_init")

end

function GTSYSMSG_notice_use_switch(frame, ctrl, str, num)
    if g.settings.use == 1 then
        g.settings.use = 0
        ui.SysMsg("[GTS]guild notice off")
    else
        g.settings.use = 1
        ui.SysMsg("[GTS]guild notice on")
    end
    g.save_settings()
    GTSYSMSG_btn_init()
end

function GTSYSMSG_btn_init()

    local chatframe = ui.GetFrame("chatframe")
    local tabgbox = GET_CHILD_RECURSIVELY(chatframe, "tabgbox")
    local switch_btn = tabgbox:CreateOrGetControl("button", "switch_btn", 300, -1, 40, 30)
    AUTO_CAST(switch_btn)
    switch_btn:SetText("{ol}{s14}{#FFFFFF}GTS")
    switch_btn:SetEventScript(ui.LBUTTONUP, "GTSYSMSG_notice_use_switch")
    switch_btn:SetTextTooltip("{ol}GTSYSMSG{nl}guild notice switching")
    if g.settings.use == 0 then
        switch_btn:SetSkinName('test_gray_button')
    elseif g.settings.use == 1 then
        switch_btn:SetSkinName("test_red_button")
    end
end

function GTSYSMSG_NOTICE_ON_MSG(frame, msg, str, num)
    GTSYSMSG_NOTICE_ON_MSG_(frame, msg, str, num)
end

function GTSYSMSG_NOTICE_ON_MSG_(frame, msg, str, num)
    g.call = g.call or 0
    if string.find(str, 'AppearFieldBoss_ep14_2_d_castle_3{name}') then
        g.call = g.call + 1
        print(g.call)
        if g.call == 1 then
            imcSound.PlaySoundEvent('sys_tp_box_4')
            NICO_CHAT(string.format("{@st55_a}%s", str))
            CHAT_SYSTEM(str)
            local guild_notice = "[GTS]Baubas has appeared"
            GTSYSMSG_NOTICE_ON_MSG_GUILD(guild_notice)
        elseif g.call < 3 then
            imcSound.PlaySoundEvent('sys_tp_box_4')
        elseif g.call == 3 then
            imcSound.PlaySoundEvent('sys_tp_box_4')
            g.call = 0
        end
    elseif string.find(str, '{name}DisappearFieldBoss') and string.find(str, '맹화의 바우바') then
        CHAT_SYSTEM(str)
        local guild_notice = "[GTS]Baubas has been defeated"
        GTSYSMSG_NOTICE_ON_MSG_GUILD(guild_notice)
    end
    g.funcs["NOTICE_ON_MSG"](frame, msg, str, num)
end

function GTSYSMSG_NOTICE_ON_MSG_GUILD(str)

    if g.settings.use == 0 then
        return
    end

    local chatframe = ui.GetFrame("chat")
    ui.SetChatType(3) -- 2pt 3guild 4wis 5gurop
    SET_CHAT_TEXT_TO_CHATFRAME(str)
    local edit = chatframe:GetChild('mainchat');
    AUTO_CAST(edit)
    edit:RunEnterKeyScript();
    ui.ProcessReturnKey()
    chatframe:ShowWindow(0)
end

-- testcode
-- _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout', _G.ScpArgMsg('AppearFieldBoss_ep14_2_d_castle_3{name}', 'name', "name"),
--    1)
-- _G.imcAddOn.BroadMsg('NOTICE_Dm_Global_Shout',
--   _G.ScpArgMsg('{name}DisappearFieldBoss', 'name', "맹화의 바우바스"), 1)
