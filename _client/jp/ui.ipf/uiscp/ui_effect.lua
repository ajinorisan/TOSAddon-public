---- ui_effect.lua --

function NICO_CHAT(msg)

	local x = ui.GetClientInitialWidth();
	local factor;
	if IMCRandom(0, 1) == 1 then
		factor = IMCRandomFloat(0.05, 0.4);
	else
		factor = IMCRandomFloat(0.6, 0.9);
	end

	local y = ui.GetClientInitialHeight() * factor;
	local spd = -IMCRandom(150, 200);

	local frame = ui.GetFrame("uieffect");
	change_client_size(frame)
	local name = UI_EFFECT_GET_NAME(frame, "NICO_");
	local ctrl = frame:CreateControl("richtext", name, x, y, 200, 20);
	
	ctrl:ShowWindow(1);
	ctrl = tolua.cast(ctrl, "ui::CRichText");
	ctrl:EnableResizeByText(1);
	ctrl:SetText("{@st64}" .. msg);
	ctrl:RunUpdateScript("NICO_MOVING");
	ctrl:SetUserValue("NICO_SPD", spd);
	ctrl:SetUserValue("NICO_START_X", x);

	frame:RunUpdateScript("INVALIDATE_NICO");
end

function NICO_MOVING(ctrl, totalTime)
	local spd = ctrl:GetUserIValue("NICO_SPD");
	local startX = ctrl:GetUserIValue("NICO_START_X");
	local curMovePos = totalTime * spd;
	local curPosX = startX + curMovePos;
	ctrl:SetOffset(curPosX, ctrl:GetY());
	if curPosX + ctrl:GetWidth() < 0 then
		return 2;
	end
	
	return 1;
end

function INVALIDATE_NICO(frame)
	
	frame:Invalidate();
	local nico = frame:SearchChild("NICO_");
	if nico == nil then
		return 0;
	end
	
	return 1;
end


