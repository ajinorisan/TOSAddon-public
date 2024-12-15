function RESULT_EFFECT_UI_ON_INIT(addon, frame)
end

function RESULT_EFFECT_UI_OPEN(frame)
end

function RESULT_EFFECT_UI_CLOSE(frame)
end

function RESULT_EFFECT_UI_RUN_SUCCESS(run_scp, icon, left, top, high_grade)
	if high_grade == nil then
		high_grade = 0
	end
	ui.OpenFrame('result_effect_ui')
	local frame = ui.GetFrame('result_effect_ui')
	frame:SetMargin(left, top, 0, 0)
	frame:SetUserValue('RUN_SCP', run_scp)

	local result_effect_bg = GET_CHILD_RECURSIVELY(frame, 'result_effect_bg')
	result_effect_bg:ShowWindow(1)

	local bg_name = 'SUCCESS_gold_bg'
	local text_name = 'card_reinforce_SUCCESS'
	local skin_name = 'BnYellow_skin'
	local success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'success_effect_bg')
	local skin_success = GET_CHILD_RECURSIVELY(frame, 'skin_success')	
	local text_success = GET_CHILD_RECURSIVELY(frame, 'text_success')	
	if high_grade == 1 then
		success_effect_bg:SetImage('SUCCESS_goddess_bg')
		text_success:SetImage('goddess_reinforce_SUCCESS')
		skin_success:SetImage('BnGreen_skin')
	else
		success_effect_bg:SetImage(bg_name)
		text_success:SetImage(text_name)
		skin_success:SetImage(skin_name)
	end

	success_effect_bg:ShowWindow(1)
	skin_success:ShowWindow(1)
	text_success:ShowWindow(1)

	local fail_effect_bg = GET_CHILD_RECURSIVELY(frame, 'fail_effect_bg')
	local skin_fail = GET_CHILD_RECURSIVELY(frame, 'skin_fail')
	local text_fail = GET_CHILD_RECURSIVELY(frame, 'text_fail')
	fail_effect_bg:ShowWindow(0)
	skin_fail:ShowWindow(0)
	text_fail:ShowWindow(0)

	local result_item_img = GET_CHILD_RECURSIVELY(frame, 'result_item_img')
	if icon ~= nil and icon ~= 'None' then
		result_item_img:ShowWindow(1)
		result_item_img:SetImage(icon)
	else
		result_item_img:ShowWindow(0)
	end
				
	RESULT_EFFECT_UI_SUCCESS_EFFECT(frame, high_grade)
end

function RESULT_EFFECT_UI_SUCCESS_EFFECT(frame, high_grade)
	local success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'success_effect_bg')
	if success_effect_bg ~= nil then
		local SUCCESS_EFFECT_NAME = frame:GetUserConfig('DO_SUCCESS_EFFECT')
		if high_grade == 1 then
			SUCCESS_EFFECT_NAME = frame:GetUserConfig('DO_SUCCESS_EFFECT2')
		end
		local SUCCESS_EFFECT_SCALE = tonumber(frame:GetUserConfig('SUCCESS_EFFECT_SCALE'))
		success_effect_bg:PlayUIEffect(SUCCESS_EFFECT_NAME, SUCCESS_EFFECT_SCALE, 'DO_SUCCESS_EFFECT')
	end
	
	local SUCCESS_EFFECT_DURATION = tonumber(frame:GetUserConfig('SUCCESS_EFFECT_DURATION'))
	ReserveScript('_RESULT_EFFECT_UI_SUCCESS_EFFECT()', SUCCESS_EFFECT_DURATION)
end

function _RESULT_EFFECT_UI_SUCCESS_EFFECT()
	local frame = ui.GetFrame('result_effect_ui')
	if frame:IsVisible() == 1 then
		local success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'success_effect_bg')
		if success_effect_bg ~= nil then
			success_effect_bg:StopUIEffect('DO_SUCCESS_EFFECT', true, 0.5)
		end
	end

	ui.SetHoldUI(false)

	local scp_name = frame:GetUserValue('RUN_SCP')
	if scp_name ~= nil and scp_name ~= 'None' then
		local run_scp = _G[scp_name]
		if run_scp ~= nil then
			run_scp()
		end
	end

	ReserveScript('CLOSE_RESULT_EFFECT_UI()', 1)
end

function RESULT_EFFECT_UI_RUN_FAILED(run_scp, left, top)
	ui.OpenFrame('result_effect_ui')
	local frame = ui.GetFrame('result_effect_ui')
	frame:SetMargin(left, top, 0, 0)
	frame:SetUserValue('RUN_SCP', run_scp)

	local result_effect_bg = GET_CHILD_RECURSIVELY(frame, 'result_effect_bg')
	result_effect_bg:ShowWindow(1)
	local success_effect_bg = GET_CHILD_RECURSIVELY(frame, 'success_effect_bg')
	local skin_success = GET_CHILD_RECURSIVELY(frame, 'skin_success')
	local text_success = GET_CHILD_RECURSIVELY(frame, 'text_success')
	success_effect_bg:ShowWindow(0)
	skin_success:ShowWindow(0)
	text_success:ShowWindow(0)

	local skin_fail = GET_CHILD_RECURSIVELY(frame, 'skin_fail')
	local text_fail = GET_CHILD_RECURSIVELY(frame, 'text_fail')
	skin_fail:ShowWindow(1)
	text_fail:ShowWindow(1)

	RESULT_EFFECT_UI_FAIL_EFFECT(frame)	
end

function RESULT_EFFECT_UI_FAIL_EFFECT(frame)
	local fail_effect_bg = GET_CHILD_RECURSIVELY(frame, 'fail_effect_bg')
	if fail_effect_bg ~= nil then
		local result_item_img = GET_CHILD_RECURSIVELY(frame, 'result_item_img')
		result_item_img:ShowWindow(0)
		
		local FAIL_EFFECT_NAME = frame:GetUserConfig('DO_FAIL_EFFECT')
		local FAIL_EFFECT_SCALE = tonumber(frame:GetUserConfig('FAIL_EFFECT_SCALE'))
		fail_effect_bg:PlayUIEffect(FAIL_EFFECT_NAME, FAIL_EFFECT_SCALE, 'DO_FAIL_EFFECT')
	end
	
	local FAIL_EFFECT_DURATION = tonumber(frame:GetUserConfig('FAIL_EFFECT_DURATION'))
	ReserveScript('_RESULT_EFFECT_UI_FAIL_EFFECT()', FAIL_EFFECT_DURATION)
end

function  _RESULT_EFFECT_UI_FAIL_EFFECT()
	local frame = ui.GetFrame('result_effect_ui')
	if frame:IsVisible() == 1 then
		local fail_effect_bg = GET_CHILD_RECURSIVELY(frame, 'fail_effect_bg')
		if fail_effect_bg ~= nil then
			fail_effect_bg:StopUIEffect('DO_FAIL_EFFECT', true, 0.5)
		end
	end

	ui.SetHoldUI(false)
	
	local scp_name = frame:GetUserValue('RUN_SCP')
	if scp_name ~= nil and scp_name ~= 'None' then
		local run_scp = _G[scp_name]
		if run_scp ~= nil then
			run_scp()
		end
	end

	ReserveScript('CLOSE_RESULT_EFFECT_UI()', 1)
end

function CLOSE_RESULT_EFFECT_UI()
	ui.CloseFrame('result_effect_ui')
end