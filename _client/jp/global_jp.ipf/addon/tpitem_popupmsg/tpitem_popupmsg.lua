-- #35918 일감 수정(구매 목록 하단 확률 정보 확인 텍스트)
function TPITEM_POPUPMSG_INIT_BOTTOM_MSG(posy, frame, totalTP)	
	local askText = GET_CHILD_RECURSIVELY(frame, 'askText');
	askText:SetTextByKey('tp', totalTP);

--	local probInfoText = GET_CHILD_RECURSIVELY(frame, 'probInfoText');
--	probInfoText:SetTextByKey('msg', ClMsg('ContainWarningItem'));	

	local bottomBox = GET_CHILD_RECURSIVELY(frame, 'bottomBox');
	local itemBox = GET_CHILD_RECURSIVELY(frame, 'itemBox');
	frame:Resize(frame:GetWidth(), posy + itemBox:GetY() + bottomBox:GetHeight());
end