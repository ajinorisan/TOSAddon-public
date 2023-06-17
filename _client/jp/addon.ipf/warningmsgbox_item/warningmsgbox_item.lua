-- warningmsgbox_item.lua

function WARNINGMSGBOX_ITEM_ON_INIT(addon, frame)
	
end

-- 장비 착용
function WARNINGMSGBOX_FRAME_OPEN_EQUIP_ITEM(clmsg, yesScp, noScp, itemGuid, type)
	ui.OpenFrame("warningmsgbox_item")
	
	local frame = ui.GetFrame('warningmsgbox_item')
	frame:EnableHide(1);
	
	local warningText = GET_CHILD_RECURSIVELY(frame, "warningtext")
	warningText:SetText(clmsg)

	local showTooltipCheck = GET_CHILD_RECURSIVELY(frame, "cbox_showTooltip")
	if itemGuid ~= nil then
		frame:SetUserValue("ITEM_GUID" , itemGuid)
		WARNINGMSGBOX_ITEM_CREATE_TOOLTIP(frame, itemGuid);
		showTooltipCheck:ShowWindow(1)
		showTooltipCheck:SetCheck(1)
	else
		showTooltipCheck:ShowWindow(0)
	end
    
	local yesBtn = GET_CHILD_RECURSIVELY(frame, "yes")
	tolua.cast(yesBtn, "ui::CButton");

	local item = session.GetInvItemByGuid(itemGuid)
	local item_obj = GetIES(item:GetObject())

	local item_name = GET_CHILD_RECURSIVELY(frame, 'warningtextitem')
	item_name:SetText('{s25}{#33FF33}'.. item_obj.Name)
	item_name:ShowWindow(1)

	local title = GET_CHILD_RECURSIVELY(frame, 'warningtitle')	
	if type == 'char' then		
		title:SetText(ClMsg('WarningCharacterBelonging'))		
	elseif type == 'team' then
		title:SetText(ClMsg('WarningTeamBelonging'))
	end

	yesBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_FRAME_OPEN_EQUIP_ITEM_YES');
	yesBtn:SetEventScriptArgString(ui.LBUTTONUP, yesScp);

	local noBtn = GET_CHILD_RECURSIVELY(frame, "no")
	tolua.cast(noBtn, "ui::CButton");

	noBtn:SetEventScript(ui.LBUTTONUP, 'WARNINGMSGBOX_FRAME_OPEN_EQUIP_ITEM_NO');
	noBtn:SetEventScriptArgString(ui.LBUTTONUP, noScp)

	local buttonMargin = noBtn:GetMargin()
	local warningbox = GET_CHILD_RECURSIVELY(frame, 'warningbox')
	local totalHeight = warningbox:GetY() + warningText:GetY() + warningText:GetHeight() + showTooltipCheck:GetHeight() + noBtn:GetHeight() + 2 * buttonMargin.bottom
	
	yesBtn:ShowWindow(1);
	noBtn:ShowWindow(1);	

	local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
	warningbox:Resize(warningbox:GetWidth(), totalHeight)
	bg:Resize(bg:GetWidth(), totalHeight)
	frame:Resize(frame:GetWidth(), totalHeight)
end

function _WARNINGMSGBOX_FRAME_OPEN_EQUIP_ITEM_YES(parent, ctrl, argStr, argNum)		
    
	RunStringScript(argStr)
	ui.CloseFrame("warningmsgbox_item")
	ui.CloseFrame("item_tooltip")
end

function WARNINGMSGBOX_FRAME_OPEN_EQUIP_ITEM_NO(parent, ctrl, argStr, argNum)	
	ui.CloseFrame("warningmsgbox_item")
	ui.CloseFrame("item_tooltip")
end


function WARNINGMSGBOX_ITEM_CREATE_TOOLTIP(frame, itemGuid)
	local warningboxFrame = ui.GetFrame("warningmsgbox_item")
	if warningboxFrame == nil then
		return
	end

	local invItem = session.GetInvItemByGuid(itemGuid)
	if invItem == nil then
		return
	end

	local tooltipFrame = ui.GetFrame("item_tooltip");
	if tooltipFrame == nil then
		tooltipFrame = ui.GetNewToolTip("wholeitem_link", "item_tooltip")
	end

	tooltipFrame = tolua.cast(tooltipFrame, 'ui::CTooltipFrame');

	local invObj = invItem:GetObject()
	if invObj == nil then
		return
	end
    local obj = GetIES(invObj)

    tooltipFrame:SetTooltipType('wholeitem');
	if obj == nil then
		return
	end

	tooltipFrame:SetTooltipStrArg('inven');
	tooltipFrame:SetTooltipIESID(itemGuid);
	tooltipFrame:RefreshTooltip();

	-- 툴팁 출력위치 조정
	local OffsetRatioM = frame:GetUserConfig("TOOLTIP_OFFSET_M");
	local OffsetRatioS = frame:GetUserConfig("TOOLTIP_OFFSET_S");
	local OffsetX = warningboxFrame:GetX() + warningboxFrame:GetWidth() - ( tooltipFrame:GetWidth() / OffsetRatioM );
	local OffsetY = warningboxFrame:GetY() - ( tooltipFrame:GetHeight() / OffsetRatioS );
	tooltipFrame:SetOffset(OffsetX, OffsetY)

	local isShowTooltip = config.GetXMLConfig("ShowTooltipInWarningBox")
	if isShowTooltip == 1 then
		tooltipFrame:ShowWindow(1)
	else
		tooltipFrame:ShowWindow(0)
	end
end