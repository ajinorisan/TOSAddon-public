function CUSTOMKEY_EMPHASIZE_ON_INIT(addon, frame)
	addon:RegisterMsg('START_CUSTOMKEY_EMPHASIZE', 'ON_START_CUSTOMKEY_EMPHASIZE')
end

function ON_START_CUSTOMKEY_EMPHASIZE(frame, msg, iconName, time)
	local key_img = GET_CHILD_RECURSIVELY(frame, 'icon_img')
	tolua.cast(key_img, 'ui::CPicture')
	key_img:SetImage(iconName)
	ui.CloseFrame('hotkey_emphasize')
	frame:ShowWindow(1)
	ReserveScript('END_CUSTOMKEY_EMPHASIZE()', time * 0.001)
end

function UPDATE_CUSTOMKEY_EMPHASIZE(frame, key, str, cnt)
	local key_img = GET_CHILD_RECURSIVELY(frame, 'icon_img')
	local x = key_img:GetOffsetX()
	local y = key_img:GetOffsetY()
	if cnt == 1 then
		key_img:SetOffset(x, y - 5)	
	else
		key_img:SetOffset(x, y + 5)
	end
end

function END_CUSTOMKEY_EMPHASIZE()
	ui.CloseFrame('customkey_emphasize')
end