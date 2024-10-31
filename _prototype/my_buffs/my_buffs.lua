local addonName = "my_buffs"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

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
    addon:RegisterMsg("BUFF_ADD", "my_buffs_buff_add")
    g.SetupHook(my_buffs_BUFF_ON_MSG, 'BUFF_ON_MSG')
end

function my_buffs_buff_add(frame, msg, str, buff_id)
    local buff_table = g.settings["buffs"]
    local str_buff_id = tostring(buff_id)
    local buff_class = GetClassByType("Buff", buff_id)
    if buff_class ~= nil then
        if not g.settings.buffs[str_buff_id] then
            g.settings.buffs[str_buff_id] = true
            my_buffs_save_settings()
        end
    end

end

function my_buffs_BUFF_ON_MSG(frame, msg, argStr, argNum)

    _my_buffs_BUFF_ON_MSG(frame, msg, argStr, argNum)
end

function _my_buffs_BUFF_ON_MSG(frame, msg, argStr, argNum)

    --[[if hide_buffs[argNum] then
        return
    end]]
    base["BUFF_ON_MSG"](frame, msg, argStr, argNum)
end

function my_buffs_load_settings()

    local settings = acutil.loadJSON(g.settings_file_path)

    if not settings then
        settings = {
            buffs = {},
            lock = true
        }
    end

    g.settings = settings
    my_buffs_save_settings()
    my_buffs_frame()
end

function my_buffs_save_settings()
    acutil.saveJSON(g.settings_file_path, g.settings)
end

function my_buffs_frame_lock(frame, msg, str, num)
    print("test")
    local frame = ui.GetFrame("buff")
    local lock = GET_CHILD_RECURSIVELY(frame, "lock")
    if g.settings.lock then
        g.settings.lock = false
        lock:SetGrayStyle(1);
        -- frame:EnableHitTest(1)
        frame:EnableHittestFrame(1)
        frame:EnableMove(1)
    else
        g.settings.lock = true
        lock:SetGrayStyle(0);
    end
    my_buffs_save_settings()
end

function my_buffs_frame()
    local frame = ui.GetFrame("buff")
    frame:SetLayerLevel(61)
    local lock = frame:CreateOrGetControlSet('inv_itemlock', "lock", 0, 0);
    AUTO_CAST(lock)
    lock:SetGravity(ui.LEFT, ui.TOP);
    lock:SetEventScript(ui.LBUTTONUP, "my_buffs_frame_lock")
    lock:SetEventScript(ui.RBUTTONUP, "my_buffs_buffs_choice")
    if g.settings.lock then
        lock:SetGrayStyle(0);
    else
        lock:SetGrayStyle(1);
    end
end

