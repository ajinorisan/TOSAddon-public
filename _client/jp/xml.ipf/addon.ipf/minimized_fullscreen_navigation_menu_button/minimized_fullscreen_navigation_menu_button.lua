function MINIMIZED_FULLSCREEN_NAVIGATION_MENU_BUTTON_ON_INIT(addon, frame)
	frame:ShowWindow(1);
end

function MINIMIZED_FULLSCREEN_NAVIGATION_MENU_OPEN(parent, ctrl)
	local frame = ui.GetFrame("fullscreen_navigation_menu");
	if frame ~= nil then
		ui.OpenFrame("fullscreen_navigation_menu");
	end
end