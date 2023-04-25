local addonName = "NOCHECK"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsDirLoc = string.format("../addons/%s", addonNameLower)
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc)

local acutil = require("acutil")

function NOCHECK_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    acutil.setupHook(NOCHECK_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG, "BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG")

end

function NOCHECK_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG(invItem)
    if invItem == nil then
        return;
    end
    
    local invFrame = ui.GetFrame("inventory");    
    local itemobj = GetIES(invItem:GetObject());
    if itemobj == nil then
        return;
    end
    invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
    
    local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg("YESSCP_OPEN_BASIC_MSG"));
    
    -- Replace the MsgBox_NonNested function with a custom function that automatically selects "YES"
    local originalMsgBox_NonNested = ui.MsgBox_NonNested;
    ui.MsgBox_NonNested = function(text, ...)
        return originalMsgBox_NonNested(textmsg, "YES", ...);
    end
    
    ui.MsgBox_NonNested(textmsg, itemobj.Name, 'REQUEST_SUMMON_BOSS_TX', "None");
    
    -- Restore the original MsgBox_NonNested function
    ui.MsgBox_NonNested = originalMsgBox_NonNested;
    
    return;
end


--[[
function BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG(invItem)
	if invItem == nil then
		return;
	end
	
	local invFrame = ui.GetFrame("inventory");	
	local itemobj = GetIES(invItem:GetObject());
	if itemobj == nil then
		return;
	end
	invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
	
	local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg("YESSCP_OPEN_BASIC_MSG"));
	ui.MsgBox_NonNested(textmsg, itemobj.Name, 'REQUEST_SUMMON_BOSS_TX', "None");
	
	return;
end
]]