function MINIMIZED_CHARACTER_CHANGE_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg("CHARACTER_CHANGE_MINIMIZED_BUTTON_OPEN", "MINIMIZED_CHARACTER_CHANGE_BUTTON_OPEN");
	addon:RegisterMsg("CHARACTER_CHANGE_MINIMIZED_BUTTON_CLOSE", "MINIMIZED_CHARACTER_CHANGE_BUTTON_CLOSE");
end

function MINIMIZED_CHARACTER_CHANGE_BUTTON_OPEN(frame)
	if frame == nil then return; end
	ui.OpenFrame("minimized_character_change_button");
end

function MINIMIZED_CHARACTER_CHANGE_BUTTON_CLOSE(frame)
	if frame == nil then return; end
	ui.CloseFrame("minimized_character_change_button");
	ui.CloseFrame("character_change");
end

function MINIMIZED_CHARACTER_CHANGE_BUTTON_LBTN_DOWN_SCP(frame)
	CHARACTER_CHANGE_OPEN();
end