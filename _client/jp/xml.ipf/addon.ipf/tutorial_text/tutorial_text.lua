function TUTORIAL_TEXT_ON_INIT(addon, frame)
end

function OPEN_TUTORIAL_TEXT(frame)
end

function CLOSE_TUTORIAL_TEXT(frame)
end

local function _TUTORIAL_TEXT_ALIGN(frame)
	local from_frame = ui.GetFrame(frame:GetUserValue('FROM_FRAME'))
	if from_frame == nil then return end

	local ctrl = GET_CHILD_RECURSIVELY(from_frame, frame:GetUserValue('FROM_CTRL'))
	if ctrl == nil then return end

	local vert_horz_ratio = option.GetClientHeight() / option.GetClientWidth()
	local total_width = math.floor(ui.GetSceneWidth() / ui.GetRatioWidth())
	local total_height = math.floor(ui.GetSceneWidth() / ui.GetRatioWidth() * vert_horz_ratio)
	local y_limit = 60

	local width_add = 0
	local height_add = 0
	local init_width = ui.GetClientInitialWidth()
	local init_height = ui.GetClientInitialHeight()
	local init_ratio = init_height / init_width
	if init_ratio < vert_horz_ratio then
		-- 4:3
		height_add = (init_height * (vert_horz_ratio / init_ratio - 1)) / 2
	elseif init_ratio > vert_horz_ratio then
		-- wide
		width_add = (init_width * (init_ratio / vert_horz_ratio - 1)) / 2
	end

	local offsetX = ctrl:GetDrawX() + width_add
	local offsetY = ctrl:GetDrawY() + height_add + math.floor(from_frame:GetDrawY() * (1 - ui.GetRatioHeight()))

	local highlight_pic = GET_CHILD_RECURSIVELY(frame, 'highlight_pic')
	highlight_pic:Resize(ctrl:GetWidth(), ctrl:GetHeight())

	local inner_margin = 10
	local title_text = GET_CHILD_RECURSIVELY(frame, 'title_text')
	local guide_text = GET_CHILD_RECURSIVELY(frame, 'guide_text')
	guide_text:SetMargin(0, title_text:GetHeight() + (inner_margin * 2), 0, 0)
	local skip_btn = GET_CHILD_RECURSIVELY(frame, 'skip_btn')
	local next_btn = GET_CHILD_RECURSIVELY(frame, 'next_btn')
	
	local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
	local bg_width = guide_text:GetWidth() + (inner_margin * 2)
	if bg_width < title_text:GetWidth() + (inner_margin * 2) then
		bg_width = title_text:GetWidth() + (inner_margin * 2)
	end
	local bg_height = title_text:GetHeight() + guide_text:GetHeight() + next_btn:GetHeight() + (inner_margin * 4)
	bg:Resize(bg_width, bg_height)
	bg:SetColorTone('CCFFFFFF')

	local right_force = frame:GetUserValue('RIGHT_FORCE')
	local right_flag = false
	if right_force == "YES" then
		right_flag = false
	else
		local inv_frame = ui.GetFrame('inventory')
		if offsetX + highlight_pic:GetWidth() + bg:GetWidth() > total_width - inv_frame:GetWidth() then
			right_flag = true
		end
	end
	
	local bg_top = highlight_pic:GetHeight()
	local highlight_top = 0
	local height_adjust = offsetY + highlight_pic:GetHeight() + bg:GetHeight() - (total_height - y_limit)
	if height_adjust > 0 then
		bg_top = bg_top - height_adjust
		if bg_top < 0 then
			highlight_top = -bg_top
			bg_top = 0
		end
		offsetY = offsetY - highlight_top
	end

	if right_flag == true then
		highlight_pic:SetGravity(ui.RIGHT, ui.TOP)
		highlight_pic:SetMargin(0, highlight_top, 0, 0)
		bg:SetMargin(0, bg_top, 0, 0)
		offsetX = offsetX - bg:GetWidth()
	else
		highlight_pic:SetGravity(ui.LEFT, ui.TOP)
		highlight_pic:SetMargin(0, highlight_top, 0, 0)
		bg:SetMargin(highlight_pic:GetWidth(), bg_top, 0, 0)
	end
	
	local frame_width = highlight_pic:GetWidth() + bg:GetWidth()
	local frame_height = highlight_pic:GetHeight() + bg:GetHeight() - height_adjust
	if height_adjust > highlight_pic:GetHeight() then
		frame_height = bg:GetHeight()
	end
	frame:Resize(frame_width, frame_height)
	frame:SetOffset(offsetX, offsetY)

	local skip_btn_flag = frame:GetUserValue('SKIP_BTN')
	if skip_btn_flag =="NO" then
		skip_btn:ShowWindow(0)
	else
		skip_btn:ShowWindow(1)
	end

	local next_btn_flag = frame:GetUserValue('NEXT_BTN')
	if next_btn_flag =="NO" then
		next_btn:ShowWindow(0)
	else
		next_btn:ShowWindow(1)
	end
end

function TUTORIAL_TEXT_OPEN(ctrl, title, text, acc_prop, right_force, skip_btn, next_btn, skipFuncName)
	local frame = ui.GetFrame('tutorial_text')
	local from_frame = ctrl:GetTopParentFrame()

	if acc_prop == nil or acc_prop == 'None' then return end
	if GetUITutoProg(acc_prop) == nil then return end

	from_frame:EnableHittestFrame(0)

	frame:SetLayerLevel(from_frame:GetLayerLevel() + 1)
	frame:SetUserValue('FROM_FRAME', from_frame:GetName())
	frame:SetUserValue('FROM_CTRL', ctrl:GetName())
	frame:SetUserValue('ACC_PROP', acc_prop)
	frame:SetUserValue('RIGHT_FORCE', right_force)
	frame:SetUserValue('SKIP_BTN', skip_btn)
	frame:SetUserValue('NEXT_BTN', next_btn)
	frame:SetUserValue('SKIP_FUNC_NAME', skipFuncName)

	local title_text = GET_CHILD_RECURSIVELY(frame, 'title_text')
	title_text:SetTextByKey('value', title)

	local guide_text = GET_CHILD_RECURSIVELY(frame, 'guide_text')
	guide_text:SetTextByKey('value', text)

	_TUTORIAL_TEXT_ALIGN(frame)

	ui.OpenFrame('tutorial_text')
end

function TUTORIAL_TEXT_NEXT_STEP(parent, ctrl)
	local frame = parent:GetTopParentFrame()
	local acc_prop = frame:GetUserValue('ACC_PROP')
	if acc_prop == 'None' then return end

	pc.ReqExecuteTx('SCR_UI_TUTORIAL_NEXT_STEP', acc_prop)
end

function TUTORIAL_TEXT_SKIP_TUTO(parent, ctrl, func)
	local frame = parent:GetTopParentFrame()
	local acc_prop = frame:GetUserValue('ACC_PROP')
	if acc_prop == 'None' then return end

	local clmsg = ScpArgMsg('ReallySkip{Name}Tutorial', 'Name', ClMsg(acc_prop))
	local msgbox = ui.MsgBox(clmsg, '_TUTORIAL_TEXT_SKIP_TUTO()', 'None')
end

function _TUTORIAL_TEXT_SKIP_TUTO()
	local frame = ui.GetFrame('tutorial_text')
	local acc_prop = frame:GetUserValue('ACC_PROP')
	if acc_prop == 'None' then return end
	local skip_func_name = frame:GetUserValue('SKIP_FUNC_NAME')
	local skip_func = _G[skip_func_name]
	if skip_func ~= nil then
		skip_func()
	end

	pc.ReqExecuteTx('SCR_UI_TUTORIAL_SKIP', acc_prop)
end

function TUTORIAL_TEXT_CLOSE(from_frame)
	if from_frame ~= nil then
		from_frame:SetUserValue('TUTO_PROP', 'None')
		from_frame:EnableHittestFrame(1)
	end
	
	local frame = ui.GetFrame('tutorial_text')
	if frame ~= nil and frame:IsVisible() == 1 then
		ui.CloseFrame('tutorial_text')
	end
end