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
    local chattype_frame_width = chattype_frame:GetWidth();

	local j = 1;
	for i = 1, 6 do

		local color = frame:GetUserConfig("COLOR_BTN_" .. i);	
		if selected ~= i then	
			
			-- ¼±?μ???: ?Tμ? ¸??­
			local btn_Chattype = GET_CHILD(chattype_frame, "button_type" .. j);
			if btn_Chattype == nil then
				return;
			end			
			
            -- ��ư ũ�⸦ rect�� width height ������ ����
			btn_Chattype:Resize(btn_Chattype:GetOriginalWidth(), btn_Chattype:GetOriginalHeight()); -- SetText ���� ����� ���ĵ�.
			
			local msg = "{@st60}".. ScpArgMsg("ChatType_" .. i)  .. "{/}";
			btn_Chattype:SetText(msg);	
			btn_Chattype:SetTextTooltip( ScpArgMsg("ChatType_" .. i .. "_ToolTip") );
			btn_Chattype:SetPosTooltip(btn_Chattype:GetWidth() + 10 , (btn_Chattype:GetHeight() /2));
			btn_Chattype:SetColorTone( "FF".. color);

			--´?￥ ?·¹S¿¡¼­G ¹???? μ?颯?μμ º????¹?G? °?³·³ º¸L°??±?§? ¼³d
			btn_Chattype:SetIsUpCheckBtn(true);

			--³ª?¿¡ ¸???¿¡¼­ ¼±?μ?颯?¿¡ ?´?¸T; |´???§? ½?¼ ¼³d. 
			btn_Chattype:SetUserValue("CHAT_TYPE_CONFIG_VALUE", i);

			--a?aG ¹?????? ¼­·?´?￥ ?·¹S8·μ­ ?´??? ¼­·?´?® ?¿?μ??
			j = j + 1;
		else

		--¼±?μ??T: a?¹??¹??¸·?
			local btn_type = GET_CHILD(frame, "button_type");
			if btn_type == nil then
				return;
			end			
            
            -- ��ư ũ�⸦ rect�� width height ������ ����
			btn_type:Resize(btn_type:GetOriginalWidth(), btn_type:GetOriginalHeight());
            		
			local msg = "{@st60}".. ScpArgMsg("ChatType_" .. i) .. "{/}";
			btn_type:SetText(msg);	
			btn_type:SetColorTone("FF".. color);
			
		end;
	end;
end;