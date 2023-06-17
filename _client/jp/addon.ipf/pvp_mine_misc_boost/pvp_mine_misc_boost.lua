-- 용병단 증표 부스트
function PVP_MINE_MISC_BOOST_ON_INIT(addon, frame)
end

function PVP_MINE_MISC_BOOST_CLOSE(frame, msg, argStr, argNum)
	frame:ShowWindow(0);
end


function BEFORE_APPLIED_PVP_MINE_MISC_BOOST_USE(invItem)
	if invItem.isLockState or invItem:GetIESID() == 0 or invItem:GetIESID() == '' or invItem:GetIESID() == nil then         
		return;
	end

	local acc = GetMyAccountObj();	
	local end_time = TryGetProp(acc, 'PVP_MINE_MISC_BOOST_END_DATETIME', 'None')	
	local itemobj = GetIES(invItem:GetObject());
	local time = TryGetProp(itemobj, 'NumberArg1', 0)
	
	local result_time = GET_TIME_PVP_MINE_MISC_END_TIME(acc, time, GetMyPCObject())	
	local diff = date_time.get_diff_sec(result_time, date_time.get_lua_now_datetime_str())
	if diff > 25920000 then		
		ui.SysMsg(ScpArgMsg('AlreadyTooMuchReaminTime'));
		return
	end	

	local frame = ui.GetFrame("pvp_mine_misc_boost");
	if 0 == frame:IsVisible() then
		frame:ShowWindow(1)
	end

	local invFrame = ui.GetFrame("inventory");	
	
	if itemobj == nil then
		return;
	end

	frame = ui.GetFrame("pvp_mine_misc_boost");
	local richtext = frame:GetChild("richtext");
	richtext:SetTextByKey("value", itemobj.Name)

	local str = frame:GetChild("str");
	str:SetTextByKey("value", itemobj.Name);

	local gBox = frame:GetChild("gBox");
	gBox:RemoveAllChild();
	local ctrlSet = gBox:CreateControlSet("pvp_misc_boost_Detail", "CTRLSET_" .. 1,  ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0);

    local prop = ctrlSet:GetChild("prop");

	local msg = PVP_MINE_MISC_BOOST_DESC()
    prop:SetTextByKey("value", '{s25}'..msg)
    local value = GET_CHILD_RECURSIVELY(ctrlSet, "value");
    value:ShowWindow(0);

	local detail = GET_CHILD_RECURSIVELY(frame, "detail");
	detail:ShowWindow(0);

	invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
		
end

function PVP_MINE_MISC_BOOST_USE(frame)
	SKILLSTAT_SELEC_CANCLE(frame)

	local argList = ''    	

	local invFrame = ui.GetFrame("inventory")
	local guid = invFrame:GetUserValue("REQ_USE_ITEM_GUID")

    pc.ReqExecuteTx_Item("USE_ITEM_PVP_MINE_MISC_BOOST", guid, argList)
end

