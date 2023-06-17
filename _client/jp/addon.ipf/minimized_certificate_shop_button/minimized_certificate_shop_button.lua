function MINIMIZED_CERTIFICATE_SHOP_BUTTON_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'MINIMIZED_CERTIFICATE_SHOP_BUTTON_OPEN_CHECK');
end

function MINIMIZED_CERTIFICATE_SHOP_BUTTON_OPEN_CHECK(frame, msg, argStr, argNum)

end



function MINIMIZED_CERTIFICATE_SHOP_BUTTON_CLICK(parent, ctrl)
	local frame = ui.GetFrame('earthtowershop')
	if frame:IsVisible() == 1 then
		ui.CloseFrame('earthtowershop')
	end

	REQ_VakarineCertificate_SHOP_OPEN()
end