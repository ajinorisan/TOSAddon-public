function ACTIVATION_EMPHASIZE_ON_INIT(addon, frame)
	addon:RegisterMsg('ACTIVATION_EMPHASIZE', 'ON_ACTIVATION_EMPHASIZE')
end

function ON_ACTIVATION_EMPHASIZE(frame, msg, argStr, argNum)
	frame:StopUpdateScript('ACTIVATION_EMPHASIZE_UPDATE')
	ACTIVATION_EMPHASIZE_UI_RESET()

	local cls = GetClassByType(argStr, argNum)
	if cls == nil then return end

	local icon_name = TryGetProp(cls, 'Icon', 'None')
	if icon_name == 'None' then return end
	
	icon_name = 'icon_' .. icon_name
	
	local emphasize_icon = GET_CHILD_RECURSIVELY(frame, 'emphasize_icon')
	emphasize_icon:SetImage(icon_name)

	local sound_name = frame:GetUserConfig('PLAY_SOUND_NAME')
	local sound_scp = string.format('ACTIVATION_EMPHASIZE_PLAY_SOUND(\'%s\')', sound_name)
	ReserveScript(sound_scp, 0.01)

	frame:ShowWindow(1)
	frame:RunUpdateScript('ACTIVATION_EMPHASIZE_UPDATE', 0, 0, 0, 1)
end

function ACTIVATION_EMPHASIZE_UI_RESET()
	local frame = ui.GetFrame('activation_emphasize')
	local def_size = tonumber(frame:GetUserConfig('ICON_DEF_SIZE'))
	local emphasize_icon = GET_CHILD_RECURSIVELY(frame, 'emphasize_icon')
	emphasize_icon:SetImage('None')
	emphasize_icon:Resize(def_size, def_size)
	emphasize_icon:SetAlpha(0)
end

function ACTIVATION_EMPHASIZE_UPDATE(frame, elapsedTime)
	tolua.cast(frame, 'ui::CFrame')
	local def_size = tonumber(frame:GetUserConfig('ICON_DEF_SIZE'))
	local max_size = tonumber(frame:GetUserConfig('ICON_MAX_SIZE'))
	local size_diff = max_size - def_size
	local max_alpha = tonumber(frame:GetUserConfig('ICON_MAX_ALPHA'))
	local fadein_time = tonumber(frame:GetUserConfig('FADEIN_TIME_MS')) / 1000
	local fadeout_time = tonumber(frame:GetUserConfig('FADEOUT_TIME_MS')) / 1000
	local total_time = fadein_time + fadeout_time

	local emphasize_icon = GET_CHILD_RECURSIVELY(frame, 'emphasize_icon')
	if elapsedTime <= fadein_time then
		local rate = elapsedTime / fadein_time
		emphasize_icon:Resize(def_size + (size_diff * rate), def_size + (size_diff * rate))
		emphasize_icon:SetAlpha(max_alpha * rate)
	elseif elapsedTime <= total_time then
		local rate = (total_time - elapsedTime) / fadein_time
		emphasize_icon:Resize(def_size + (size_diff * rate), def_size + (size_diff * rate))
		emphasize_icon:SetAlpha(max_alpha * rate)
	else
		emphasize_icon:Resize(def_size, def_size)
		emphasize_icon:SetAlpha(0)
		frame:ShowWindow(0)
		return 0
	end

	return 1
end

function ACTIVATION_EMPHASIZE_PLAY_SOUND(sound_name)
	imcSound.PlaySoundEvent(sound_name)
end