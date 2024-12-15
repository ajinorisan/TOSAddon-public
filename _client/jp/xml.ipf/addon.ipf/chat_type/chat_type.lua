function CHAT_TYPE_INIT(addon, frame)
end

function CHAT_TYPE_CLOSE(frame)
	local chattype_frame = ui.GetFrame('chattypelist');
	chattype_frame:ShowWindow(0);
end

function CHAT_TYPE_SELECTION(frame, ctrl)
	local typeIvalue = ctrl:GetUserIValue("CHAT_TYPE_CONFIG_VALUE");
	if (nil == typeIvalue) or (0 == typeIvalue) or (typeIvalue > 7) then
		return;
	end;

	ui.SetChatType(typeIvalue-1);
	CHAT_TYPE_CLOSE(frame);
end

function CHAT_TYPE_LISTSET(selected)
	if selected == 0 then
		return;
	end;

	if ui.GetWhisperTargetName() == nil and selected == 5 then
		return;
	end

	if (ui.GetGroupChatTargetID() == nil or ui.GetGroupChatTargetID() == "") and selected == 6 then
		return;
	end


	local frame = ui.GetFrame('chat');		
	frame:SetUserValue("CHAT_TYPE_SELECTED_VALUE", selected);
	local chattype_frame = ui.GetFrame('chattypelist');
	local j = 1;
	for i = 1, 7 do
		index = i;
		if i == 7 then
			index = 9;
		end

		local color = frame:GetUserConfig("COLOR_BTN_" .. index);	
		if selected ~= i then	
			local btn_Chattype = GET_CHILD(chattype_frame, "button_type" .. j);
			if btn_Chattype == nil then
				return;
			end			
			
			local msg = "{@st60}".. ScpArgMsg("ChatType_" .. index)  .. "{/}";
			btn_Chattype:Resize(110, 36);
			btn_Chattype:SetText(msg);	
			btn_Chattype:SetTextTooltip( ScpArgMsg("ChatType_" .. index .. "_ToolTip") );
			btn_Chattype:SetPosTooltip(btn_Chattype:GetWidth() + 10 , (btn_Chattype:GetHeight() /2));
			btn_Chattype:SetColorTone( "FF".. color);
			btn_Chattype:SetIsUpCheckBtn(true);
			btn_Chattype:SetUserValue("CHAT_TYPE_CONFIG_VALUE", i);

			j = j + 1;
		else
			local btn_type = GET_CHILD(frame, "button_type");
			if btn_type == nil then
				return;
			end			
			local msg = "{@st60}".. ScpArgMsg("ChatType_" .. index) .. "{/}";
			btn_type:Resize(100, 36);
			btn_type:SetText(msg);	
			btn_type:SetColorTone("FF".. color);
		end
	end
end