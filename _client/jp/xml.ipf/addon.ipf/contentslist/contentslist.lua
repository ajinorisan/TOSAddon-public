-- contentslist.lua

function CONTENSLIST_ON_INIT(addon, frame)

	
end

function CONTENTSLIST_OPEN(squad_frame)
	local frame = ui.GetFrame("contentslist");	
	squad_frame = squad_frame:GetTopParentFrame()
	local x = squad_frame:GetGlobalX() - frame:GetWidth();
	local y = squad_frame:GetGlobalY() + 50;
	frame:SetGravity(ui.LEFT, ui.TOP);
	frame:SetOffset(x,y);
	frame:ShowWindow(1);
	SQUAD_MANAGER_SHOW_CONTENTS(frame)
end