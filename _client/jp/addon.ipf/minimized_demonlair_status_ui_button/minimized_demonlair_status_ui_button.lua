function MINIMIZED_DEMONLAIR_STATUS_UI_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg("DEMONLAIR_UI_BUTTON_ACTIVE", "ON_MINIMIZED_DEMONLAIR_STATUS_UI_BUTTON_OPEN")
	frame:ShowWindow(0)
end

function ON_MINIMIZED_DEMONLAIR_STATUS_UI_BUTTON_OPEN(frame, msg)
	frame:ShowWindow(1)
end

function MINIMIZED_DEMONLAIR_STATUS_UI_BUTTON_OPEN(parent, ctrl)
	local frame = ui.GetFrame("demonlair_status_ui")
	if frame ~= nil then
		ui.OpenFrame("demonlair_status_ui")
	end
end