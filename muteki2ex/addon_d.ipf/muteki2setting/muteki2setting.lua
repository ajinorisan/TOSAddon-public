local addon_name = "Muteki2ex_rebuild"
local addon_name_upper = string.upper(addon_name)
local addon_name_lower = string.lower(addon_name)

local author = "WRIT"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name_upper] = _G["ADDONS"][author][addon_name_upper] or {}
local g = _G["ADDONS"][author][addon_name_upper]

function MUTEKI2SETTING_ON_INIT(addon, frame)

    g.setting_frame = frame
    muteki2_rebuild_INIT_SETTING_UI()
end

