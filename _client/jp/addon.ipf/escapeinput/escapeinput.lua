local key_list = {"MoveLeft", "MoveRight"};
function ESCAPEINPUT_ON_INIT(addon, frame)
	addon:RegisterMsg('ESCAPEINPUT_START', 'ON_ESCAPEINPUT_START')
	addon:RegisterMsg('ESCAPEINPUT_END', 'ON_ESCAPEINPUT_END')
end

function ESCAPEINPUT_OPEN(frame)
	frame:SetUserValue("next_time", 0)
	frame:SetUserValue("next_key", 1);
end

function ESCAPEINPUT_CLOSE(frame)
	local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
	bg:StopUpdateScript('ESCAPEINPUT_TIME_UPDATE')
end

local function get_key_image_name(key_id)
	config.InitHotKeyByCurrentUIMode('Battle')


	local img_name = nil;
	if key_id == 'MoveLeft' then
		img_name = 'gimmick_left'
	elseif key_id == 'MoveRight' then
		img_name = 'gimmick_right'
	end

	if ui.IsImageExist(img_name) == false then
		img_name = 'key_empty'
		custom_txt = hotkey_str
	end

	return img_name, custom_txt
end

function ON_ESCAPEINPUT_START(frame, msg, arg_num)
	if frame == nil then return end;

	local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
	bg:RemoveAllChild()
	for i = 1, #key_list do

		local key_id = key_list[i]
		local img_name, custom_txt = get_key_image_name(key_id)
		local ctrl = bg:CreateOrGetControlSet('escapeinput_key', 'KEY_' .. i, 40, 0)
		if ctrl ~= nil then
			local keycap = GET_CHILD_RECURSIVELY(ctrl, 'keycap')
			keycap:SetImage(img_name)

			if custom_txt ~= nil then
				local txt = ctrl:CreateControl('richtext', 'key_name', 50, 30, ui.CENTER_HORZ, ui.CENTER_VERT, 0, -8, 0, 0)
				txt:AdjustFontSizeByWidth(50)
				txt:SetText('{@st45}{s16}' .. custom_txt .. '{/}{/}')
			end
		end
	end

	bg:StopUpdateScript('ESCAPEINPUT_TIME_UPDATE')
	bg:RunUpdateScript('ESCAPEINPUT_TIME_UPDATE')

	bg:Resize(#key_list * 128 + (#key_list - 1) * 32, 128)
	ui.OpenFrame('escapeinput')
end

function ESCAPEINPUT_TIME_UPDATE(bg)
	local frame = bg:GetTopParentFrame()
	if frame == nil then return end

	local cur_time = imcTime.GetAppTimeMS()
	local next_time = tonumber(frame:GetUserValue("next_time"));
	if cur_time < next_time then
		return 1;
	end
	frame:SetUserValue("next_time", cur_time + 200);
	local next_key = tonumber(frame:GetUserValue("next_key"));
	frame:SetUserValue("next_key", (next_key % #key_list) + 1)

	for i = 1, #key_list do 
		local ctrl = GET_CHILD_RECURSIVELY(frame, 'KEY_' .. i)
		if ctrl == nil then return end
		local keycap = GET_CHILD_RECURSIVELY(ctrl, 'keycap')
		if keycap ~= nil then
			if i == next_key then
				keycap:SetAlpha(0)
			else
				keycap:SetAlpha(100)
			end
		end
	end
	return 1
end

function ON_ESCAPEINPUT_END(frame, msg, arg_str, arg_num)
	ui.CloseFrame('escapeinput')
end
