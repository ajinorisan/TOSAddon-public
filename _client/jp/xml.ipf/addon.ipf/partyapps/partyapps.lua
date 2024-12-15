-- partyapps.lua

function PARTYAPPS_ON_INIT(addon, frame)
end

function PARTYAPPS_LOSTFOCUS_SCP(frame, ctrl, argStr, argNum)
	local focusFrame = ui.GetFocusFrame();	
	if focusFrame ~= nil then
		local focusFrameName = focusFrame:GetName();		
		if focusFrameName == "apps" or focusFrameName == "sysmenu" then
			return;
		end
	end
	
	ui.CloseFrame("apps");	
end