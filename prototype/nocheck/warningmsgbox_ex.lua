-- warningmsgbox_ex.lua
function WARNINGMSGBOX_EX_ON_INIT(addon, frame)
	addon:RegisterMsg("DO_OPEN_WARNINGMSGBOX_EX_UI", "WARNINGMSGBOX_EX_FRAME_OPEN");
	addon:RegisterMsg("DO_UNKNOWN_SANTUARTY_GATE_BUFF_MSG_BOX", "WARNINGMSGBOX_EX_UNKNOWN_SANTUARTY_GATE_BUFF_MSG_BOX");
end

function WARNINGMSGBOX_EX_FRAME_OPEN(frame, msg, argStr, argNum, option)
	local arg_list = SCR_STRING_CUT(argStr, ';')
	if arg_list == nil or #arg_list <= 0 then
		return
	end

	local clmsg = ClMsg(arg_list[1])
	local yes_arg = ""
	if #arg_list > 1 then
		yes_arg = arg_list[2]
	end

	ui.OpenFrame("warningmsgbox_ex")
	
	local frame = ui.GetFrame('warningmsgbox_ex')
	
	-- 커스터마이징 옵션.
	local compare_msg_color = nil;
	local compare_msg_desc = nil;
	if option ~= nil then
		if option.ChangeTitle ~= nil then
			local warningTitle = GET_CHILD_RECURSIVELY(frame, "warningtitle")
			warningTitle:SetText(ClMsg(option.ChangeTitle));
		end
		if option.CompareTextColor ~= nil then
			compare_msg_color = option.CompareTextColor;
		end
		if option.CompareTextDesc ~= nil then
			compare_msg_desc = option.CompareTextDesc;
		end
	end

	local warningText = GET_CHILD_RECURSIVELY(frame, "warningtext")
	warningText:SetText(clmsg)

	local compareText = GET_CHILD_RECURSIVELY(frame, "comparetext")
	local compareHeight = 0

	local input_frame = GET_CHILD_RECURSIVELY(frame, "input")
	local input_height = 0

	local yes_list = SCR_STRING_CUT(yes_arg, '/')
	local compare_msg = ''
	if #yes_list > 0 then
		compare_msg = ClMsg(yes_list[1])
	end

	if compare_msg ~= '' then
		compareText:ShowWindow(1)

		if compare_msg_desc ~= nil then
			compareText:SetTextByKey('desc', compare_msg_desc)
		end

		if compare_msg_color ~= nil then
			compareText:SetTextByKey('value', compare_msg_color..compare_msg..'{/}')
		else
			compareText:SetTextByKey('value', compare_msg)
		end


		compareHeight = compareText:GetHeight()
		-- compareText:SetMargin(0, 0, 0, 170)

		input_frame:ShowWindow(1)
		input_frame:SetText('')
		input_frame:Focus()
		input_height = input_frame:GetHeight()
	else
		compareText:ShowWindow(0)
		input_frame:ShowWindow(0)
	end
	
    
	local yesBtn = GET_CHILD_RECURSIVELY(frame, "yes")
	tolua.cast(yesBtn, "ui::CButton")
	yesBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_YES')
	yesBtn:SetEventScriptArgString(ui.LBUTTONUP, yes_arg)

	local noBtn = GET_CHILD_RECURSIVELY(frame, "no")
	tolua.cast(noBtn, "ui::CButton")
	noBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_NO')

	local okBtn = GET_CHILD_RECURSIVELY(frame, "ok")
	tolua.cast(okBtn, "ui::CButton")
	if argNum == 0 then
		yesBtn:ShowWindow(1)
		noBtn:ShowWindow(1)
		okBtn:ShowWindow(0)
	elseif argNum == 1 then
		okBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_YES')
		okBtn:SetEventScriptArgString(ui.LBUTTONUP, yes_arg)

		yesBtn:ShowWindow(0)
		noBtn:ShowWindow(0)
		okBtn:ShowWindow(1)
	end

	local buttonMargin = noBtn:GetMargin()
	local warningbox = GET_CHILD_RECURSIVELY(frame, 'warningbox')
	local totalHeight = warningbox:GetY() + warningText:GetY() + warningText:GetHeight() + compareHeight + input_height + noBtn:GetHeight() + 2 * buttonMargin.bottom

	local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
	warningbox:Resize(warningbox:GetWidth(), totalHeight)
	bg:Resize(bg:GetWidth(), totalHeight)
	frame:Resize(frame:GetWidth(), totalHeight)
end

function _WARNINGMSGBOX_EX_FRAME_OPEN_YES(parent, ctrl, argStr, argNum)
	local input_frame = GET_CHILD_RECURSIVELY(parent, "input")
	local arg_list = SCR_STRING_CUT(argStr, '/')
	local compare_msg = ''
	local yesScp = ''
	if arg_list ~= nil then
		if #arg_list > 0 then
			compare_msg = ClMsg(arg_list[1])
		end

		if #arg_list > 1 then
			yesScp = arg_list[2]
		end
	end
	compare_msg = dic.getTranslatedStr(compare_msg);
    if input_frame:GetText() ~= compare_msg then
        -- 확인메시지 불일치
		ui.SysMsg(ClMsg('miss_match_confirm_text'))
        return
    end

	IMC_LOG("INFO_NORMAL", "_WARNINGMSGBOX_EX_FRAME_OPEN_YES" .. yesScp)

	local scp = _G[yesScp]
	if scp ~= nil then
		scp()
	end

	local warningbox = GET_CHILD_RECURSIVELY(parent, 'warningbox')
	warningbox:RemoveChild('option_compare')

	ui.CloseFrame("warningmsgbox_ex")
	ui.CloseFrame("item_tooltip")
end

function _WARNINGMSGBOX_EX_FRAME_OPEN_NO(parent, ctrl, argStr, argNum)
	IMC_LOG("INFO_NORMAL", "_WARNINGMSGBOX_EX_FRAME_OPEN_NO")

	local warningbox = GET_CHILD_RECURSIVELY(parent, 'warningbox')
	warningbox:RemoveChild('option_compare')

	ui.CloseFrame("warningmsgbox_ex")
	ui.CloseFrame("item_tooltip")
end

function WARNINGMSGBOX_EX_FRAME_CLOSE(frame)
	local yesBtn = GET_CHILD_RECURSIVELY(frame, "yes")
	yesBtn:SetLBtnUpScp("")
end

function UPDATE_TYPING_SCRIPT_WARNINGMSGBOX_EX(frame, ctrl)

end

function WARNINGMSGBOX_EX_REINFORCE_OPEN(moruFrame)
	if moruFrame == nil then
		return
	end

	local fromItem, fromMoru = REINFORCE_131014_GET_ITEM(moruFrame)
	if fromItem == nil or fromMoru == nil then
		return
	end

	local moruObj = GetIES(fromMoru:GetObject())
	if moruObj == nil then
		return
	end

	ui.OpenFrame('warningmsgbox_ex')

	local frame = ui.GetFrame('warningmsgbox_ex')
	if frame == nil then
		return
	end

	local warningText = GET_CHILD_RECURSIVELY(frame, "warningtext")
	warningText:SetText(ScpArgMsg('ProcessDangerReinforceBy{Name}Moru', 'Name', moruObj.Name))

	local compareText = GET_CHILD_RECURSIVELY(frame, "comparetext")
	local compareHeight = 0

	local input_frame = GET_CHILD_RECURSIVELY(frame, "input")
	local input_height = 0

	local compare_msg = ClMsg('ItemDecomposeWarningProp_Reinforce')
	compareText:ShowWindow(1)
	compareText:SetTextByKey('value', compare_msg)
	compareHeight = compareText:GetHeight()
	compareText:SetMargin(0, 0, 0, 130 + compareHeight)

	input_frame:ShowWindow(1)
	input_frame:SetText('')
	input_frame:Focus()
	input_height = input_frame:GetHeight()
    
	local yesBtn = GET_CHILD_RECURSIVELY(frame, "yes")
	local yes_arg = 'ItemDecomposeWarningProp_Reinforce/REINFORCE_131014_EXEC'
	tolua.cast(yesBtn, "ui::CButton")
	yesBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_YES')
	yesBtn:SetEventScriptArgString(ui.LBUTTONUP, yes_arg)

	local noBtn = GET_CHILD_RECURSIVELY(frame, "no")
	tolua.cast(noBtn, "ui::CButton")
	noBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_NO')

	local okBtn = GET_CHILD_RECURSIVELY(frame, "ok")
	tolua.cast(okBtn, "ui::CButton")
	yesBtn:ShowWindow(1)
	noBtn:ShowWindow(1)
	okBtn:ShowWindow(0)

	local buttonMargin = noBtn:GetMargin()
	local warningbox = GET_CHILD_RECURSIVELY(frame, 'warningbox')
	local totalHeight = warningbox:GetY() + warningText:GetY() + warningText:GetHeight() + compareHeight + input_height + noBtn:GetHeight() + 2 * buttonMargin.bottom

	local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
	warningbox:Resize(warningbox:GetWidth(), totalHeight)
	bg:Resize(bg:GetWidth(), totalHeight)
	frame:Resize(frame:GetWidth(), totalHeight)
end

function WARNINGMSGBOX_EX_TRANSCEND_OPEN(transcendFrame)
	if transcendFrame == nil then
		return
	end

	local slot = GET_CHILD(transcendFrame, "slot")
	local invItem = GET_SLOT_ITEM(slot)
	local slot_material = GET_CHILD(transcendFrame, "slot_material")
	local materialItem = GET_SLOT_ITEM(slot_material)
	if invItem == nil or materialItem == nil then
		return
	end

	local itemObj = GetIES(invItem:GetObject())
	local potential = TryGetProp(itemObj, "PR")
	if potential == nil then
		return
	end

	local transcend = itemObj.Transcend
	local transcendCls = GetClass("ItemTranscend", transcend + 1)
	if transcendCls == nil then
		return
	end

	local materialCount = slot_material:GetIcon():GetInfo().count
	local materialObj = GetIES(materialItem:GetObject())
	local successRatio = GET_TRANSCEND_SUCCESS_RATIO(itemObj, transcendCls, materialCount)

	ui.OpenFrame('warningmsgbox_ex')

	local frame = ui.GetFrame('warningmsgbox_ex')
	if frame == nil then
		return
	end

	local warningText = GET_CHILD_RECURSIVELY(frame, "warningtext")
	warningText:SetText(ScpArgMsg('ProcessDangerTranscendBy{P}Percent', 'P', successRatio))

	local compareText = GET_CHILD_RECURSIVELY(frame, "comparetext")
	local compareHeight = 0

	local input_frame = GET_CHILD_RECURSIVELY(frame, "input")
	local input_height = 0

	local compare_msg = ClMsg('ItemDecomposeWarningProp_Transcend')
	compareText:ShowWindow(1)
	compareText:SetTextByKey('value', compare_msg)
	compareHeight = compareText:GetHeight()
	compareText:SetMargin(0, 0, 0, 130 + compareHeight)

	input_frame:ShowWindow(1)
	input_frame:SetText('')
	input_frame:Focus()
	input_height = input_frame:GetHeight()
    
	local yesBtn = GET_CHILD_RECURSIVELY(frame, "yes")
	local yes_arg = 'ItemDecomposeWarningProp_Transcend/_ITEMTRANSCEND_EXEC'
	tolua.cast(yesBtn, "ui::CButton")
	yesBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_YES')
	yesBtn:SetEventScriptArgString(ui.LBUTTONUP, yes_arg)

	local noBtn = GET_CHILD_RECURSIVELY(frame, "no")
	tolua.cast(noBtn, "ui::CButton")
	noBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_NO')

	local okBtn = GET_CHILD_RECURSIVELY(frame, "ok")
	tolua.cast(okBtn, "ui::CButton")
	yesBtn:ShowWindow(1)
	noBtn:ShowWindow(1)
	okBtn:ShowWindow(0)

	local buttonMargin = noBtn:GetMargin()
	local warningbox = GET_CHILD_RECURSIVELY(frame, 'warningbox')
	local totalHeight = warningbox:GetY() + warningText:GetY() + warningText:GetHeight() + compareHeight + input_height + noBtn:GetHeight() + 2 * buttonMargin.bottom

	local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
	warningbox:Resize(warningbox:GetWidth(), totalHeight)
	bg:Resize(bg:GetWidth(), totalHeight)
	frame:Resize(frame:GetWidth(), totalHeight)
end

function WARNINGMSGBOX_EX_UNKNOWN_SANTUARTY_GATE_BUFF_MSG_BOX(frame, msg, argStr, argNum)
	if argNum ~= 0 then
		local msg = ScpArgMsg("UNKNOWN_SANTUARY_GATE_CLMSG_PAY_WARNING_6", "Cost", argNum);
		local yes_scp = string.format("ON_UNKNOWN_SANTUARTY_GET_BUFF(\"%s\")", argStr);
		ui.MsgBox(msg, yes_scp, "None");
	end
end

function ON_UNKNOWN_SANTUARTY_GET_BUFF(argStr)
	if argStr == nil or argStr == "" then argStr = "None"; end
	local arg_str_list = StringSplit(argStr, '/');
	if arg_str_list ~= nil and #arg_str_list > 1 then
		local first = arg_str_list[1];
		local second = arg_str_list[2];
		print("ON_UNKNOWN_SANTUARTY_GET_BUFF", first, second);
		ReqUnknownSantuartyBuff(first, second);
	end
end

function WARNINGMSGBOX_EX_ENGRAVE_OPEN()
	ui.OpenFrame("warningmsgbox_ex")
	local frame = ui.GetFrame('warningmsgbox_ex')
	
	local warningTitle = GET_CHILD_RECURSIVELY(frame, "warningtitle")
	warningTitle:SetText(ClMsg('EngravedOptionExist'))

	local warningText = GET_CHILD_RECURSIVELY(frame, "warningtext")
	warningText:SetText(ClMsg('ReallyEngraveOption'))

	local compareText = GET_CHILD_RECURSIVELY(frame, "comparetext")
	compareText:ShowWindow(0)

	local input = GET_CHILD_RECURSIVELY(frame, "input")
	input:SetText(dic.getTranslatedStr(ClMsg('None')))
	input:ShowWindow(0)
    
	local warningbox = GET_CHILD_RECURSIVELY(frame, 'warningbox')
	warningbox:RemoveChild('option_compare')
	local compare_top = 20
	local compare_ctrl = warningbox:CreateOrGetControlSet('engrave_warning_compare', 'option_compare', 90, warningText:GetY() + warningText:GetHeight() + compare_top)

	if compare_ctrl ~= nil then
		local etc = GetMyEtcObject()
		if etc == nil then
			ui.CloseFrame('warningmsgbox_ex')
			return
		end

		local from_frame = ui.GetFrame('goddess_equip_manager')
		local randomoption_bg = GET_CHILD_RECURSIVELY(from_frame, 'randomoption_bg')
		local index = randomoption_bg:GetUserValue('PRESET_INDEX')

		local rand_equip_list = GET_CHILD_RECURSIVELY(from_frame, 'rand_equip_list')
		local spot = rand_equip_list:GetSelItemKey()

		local slot = GET_CHILD_RECURSIVELY(from_frame, 'rand_engrave_slot')
		local guid = slot:GetUserValue('ITEM_GUID')
		local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(spot))
		if inv_item == nil then
			ui.CloseFrame('warningmsgbox_ex')
			return
		end

		local item_obj = GetIES(inv_item:GetObject())

		local current_inner = GET_CHILD_RECURSIVELY(frame, 'current_inner')
		current_inner:RemoveChild('tooltip_equip_property_narrow')
		_GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(current_inner, item_obj)
	
		local before_option = GET_ENGRAVED_OPTION_BY_INDEX_SPOT(etc, index, spot)
		if before_option == nil then
			ui.CloseFrame('warningmsgbox_ex')
			return
		end

		local before_inner = GET_CHILD_RECURSIVELY(frame, 'before_inner')
		before_inner:RemoveChild('tooltip_equip_property_narrow')
		_GODDESS_MGR_MAKE_RANDOM_OPTION_TEXT(before_inner, nil, before_option)
	end
	
	local yes_arg = 'None/_GODDESS_MGR_RANDOMOPTION_ENGRAVE_EXEC'
	local yesBtn = GET_CHILD_RECURSIVELY(frame, "yes")
	tolua.cast(yesBtn, "ui::CButton")
	yesBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_YES')
	yesBtn:SetEventScriptArgString(ui.LBUTTONUP, yes_arg)
	
	local noBtn = GET_CHILD_RECURSIVELY(frame, "no")
	tolua.cast(noBtn, "ui::CButton")
	noBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_NO')
	
	local okBtn = GET_CHILD_RECURSIVELY(frame, "ok")
	tolua.cast(okBtn, "ui::CButton")
	
	yesBtn:ShowWindow(1)
	noBtn:ShowWindow(1)
	okBtn:ShowWindow(0)
	
	local buttonMargin = noBtn:GetMargin()
	local totalHeight = warningbox:GetY() + warningText:GetY() + warningText:GetHeight() + compare_ctrl:GetHeight() + noBtn:GetHeight() + 2 * buttonMargin.bottom + compare_top
	warningbox:Resize(warningbox:GetWidth(), totalHeight)
	
	local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
	bg:Resize(bg:GetWidth(), totalHeight)
	frame:Resize(frame:GetWidth(), totalHeight)
end