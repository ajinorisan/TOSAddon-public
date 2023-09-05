function SYSMENU_ON_INIT(addon, frame)
	addon:RegisterMsg('NOTICE_Dm_levelup_base', 'SYSMENU_ON_MSG');
	addon:RegisterMsg('PC_PROPERTY_UPDATE_TO_SYSMENU', 'SYSMENU_ON_MSG');
	addon:RegisterMsg('GAME_START', 'SYSMENU_ON_MSG');
	addon:RegisterOpenOnlyMsg('RESET_SKL_UP', 'SYSMENU_ON_MSG');
	addon:RegisterMsg('JOB_CHANGE', 'SYSMENU_ON_JOB_CHANGE');
	addon:RegisterMsg('JOB_SKILL_POINT_UPDATE', 'SYSMENU_ON_MSG');
	addon:RegisterMsg("NPC_AUCTION_MYINFO", "ON_SYSMENU_AUCTIONINFO")
	addon:RegisterMsg("UPDATE_FRIEND_LIST", "SYSMENU_ON_MSG")
	addon:RegisterMsg("REMOVE_FRIEND", "SYSMENU_ON_MSG");
	addon:RegisterMsg("ADD_FRIEND", "SYSMENU_ON_MSG");
	addon:RegisterMsg("GUILD_ENTER", "SYSMENU_MYPC_GUILD_JOIN");
	addon:RegisterMsg("ANCIENT_UI_OPEN", "SYSMENU_CHECK_HIDE_VAR_ICONS");

	addon:RegisterMsg('SERV_UI_EMPHASIZE', 'ON_UI_EMPHASIZE');
	addon:RegisterMsg("UPDATE_READ_COLLECTION_COUNT", "SYSMENU_ON_MSG");
	addon:RegisterMsg("PREMIUM_NEXON_PC", "SYSMENU_ON_MSG");
	addon:RegisterMsg("ENABLE_PCBANG_SHOP", "SYSMENU_ON_MSG");
	addon:RegisterMsg("NEW_USER_REQUEST_GUILD_JOIN", "SYSMENU_ON_MSG");
	addon:RegisterMsg("GUILD_PROMOTE_NOTICE", "SYSMENU_GUILD_PROMOTE_NOTICE");
	
	addon:RegisterMsg("ACHIEVE_REWARD", "SYSMENU_ON_MSG")
	addon:RegisterMsg("ACHIEVE_REWARD_ALL", "SYSMENU_ON_MSG")
	addon:RegisterMsg("ACHIEVE_NEW", "SYSMENU_ON_MSG")
	frame:EnableHideProcess(1);
end

local before_state_list = {}
local before_lock_list = {}

function SYSMENU_ON_JOB_CHANGE(frame)
	SYSMENU_CHECK_HIDE_VAR_ICONS(frame);
	
	--"SYSMENU_CHANGED" 메시지 보내기 대신.
	SYSMENU_JOYSTICK_ON_MSG();
	local timerFrame = ui.GetFrame("pcbang_point_timer");
	PCBANG_POINT_TIMER_SET_MARGIN(timerFrame);
end

function SYSMENU_MYPC_GUILD_JOIN(frame)
	SYSMENU_CHECK_HIDE_VAR_ICONS(frame);	
	
	--"SYSMENU_CHANGED" 메시지 보내기 대신.
	SYSMENU_JOYSTICK_ON_MSG();
end

function SYSMENU_ON_MSG(frame, msg, argStr, argNum)
	if msg == "GAME_START" then
		SYSMENU_CHECK_HIDE_VAR_ICONS(frame);
		ReserveScript("SYSMENU_GUILD_PROMOTE_NOTICE_CHECK()", 2);
		frame:StopUpdateScript('UPDATE_GET_REINFORCE_MATERIAL')
		frame:RunUpdateScript('UPDATE_GET_REINFORCE_MATERIAL', 2, 0)

		frame:StopUpdateScript('UPDATE_INHERITANCE_NOTICE')
		frame:RunUpdateScript('UPDATE_INHERITANCE_NOTICE', 2, 0)

		before_state_list = {}
		before_lock_list = {}
		
		frame:StopUpdateScript('UPDATE_LOCK_EQUIPMENT')
		frame:RunUpdateScript('UPDATE_LOCK_EQUIPMENT', 1, 0)
	end

	if msg == "PREMIUM_NEXON_PC" or msg == "ENABLE_PCBANG_SHOP" then
		if argNum == 1 then
			SYSMENU_CHECK_HIDE_VAR_ICONS(frame);
			if IS_PCBANG_POINT_TIMER_CHECKED() == 1 then
				ui.OpenFrame("pcbang_point_timer");
				local timerFrame = ui.GetFrame("pcbang_point_timer");
				PCBANG_POINT_TIMER_SET_MARGIN(timerFrame);
			end
		end
	end

	if msg == 'PC_PROPERTY_UPDATE_TO_SYSMENU' or msg == 'RESET_SKL_UP' or msg =='GAME_START' or msg=='UPDATE_READ_COLLECTION_COUNT' then
		SYSMENU_PC_STATUS_NOTICE(frame);
		SYSMENU_PC_SKILL_NOTICE(frame);
		SYSMENU_CHECK_OPENCONDITION(frame);
		SYSMENU_PC_NEWFRIEND_NOTICE(frame)
		frame:Invalidate();
	end

	if msg == 'JOB_SKILL_POINT_UPDATE' then
		SYSMENU_PC_SKILL_NOTICE(frame);
		imcSound.PlaySoundEvent('sys_alarm_skl_status_point_count');
	end

	if msg =='GAME_START' or msg == 'ACHIEVE_REWARD' or msg == "ACHIEVE_REWARD_ALL" or msg == "ACHIEVE_NEW" then
		SYSMENU_JOURNAL_NOTICE(frame);
	end

	if msg == 'UPDATE_FRIEND_LIST' or msg == 'REMOVE_FRIEND' or msg == 'ADD_FRIEND' then
		SYSMENU_PC_NEWFRIEND_NOTICE(frame)
		frame:Invalidate();
	end
	if msg == "NEW_USER_REQUEST_GUILD_JOIN" then
		SYSMENU_GUILD_NOTICE(frame, 1)
	end
end

function CHECK_SYSMENU_OPENCOND()
	local frame = ui.GetFrame("sysmenu");
	SYSMENU_CHECK_OPENCONDITION(frame)
end

function SYSMENU_CHECK_OPENCONDITION(frame)

	CHECK_CTRL_OPENCONDITION(frame, "status", "status");
	CHECK_CTRL_OPENCONDITION(frame, "inven", "inventory");
	CHECK_CTRL_OPENCONDITION(frame, "skilltree", "skilltree");
	CHECK_CTRL_OPENCONDITION(frame, "quest", "quest");
	CHECK_CTRL_OPENCONDITION(frame, "sys_collection", "sys_collection");
	CHECK_CTRL_OPENCONDITION(frame, "helplist", "helplist");
	
end

function SYSMENU_CHECK_HIDE_VAR_ICONS(frame)

	if false == VARICON_VISIBLE_STATE_CHANTED(frame, "necronomicon", "necronomicon")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "customdrag", "customdrag")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "grimoire", "grimoire")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "guild", "guild")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "poisonpot", "poisonpot")    
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "pcbang_shop", "pcbang_shop")
	and false == VARICON_VISIBLE_STATE_CHANTED(frame, "ancient_card_list", "ancient_card_list")
	then
		return;
	end

	local pcbangIcon = frame:GetUserConfig("PC_BANG_SHOP_ICON");
	DESTROY_CHILD_BY_USERVALUE(frame, "IS_VAR_ICON", "YES");

    local extraBag = frame:GetChild('extraBag');
	local rankBtn = frame:GetChild("rankBtn");	
    local guildRank = frame:GetChild('guildRank');
    local offsetX = extraBag:GetX() - guildRank:GetX()
	local rightMargin = guildRank:GetMargin().right + offsetX;
	rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "guildinfo", "guildinfo", "sysmenu_guild", rightMargin, offsetX, "Guild");
	rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "ancient_card_list", "ancient_card_list", "Ancient_Menu", rightMargin, offsetX);	   
	rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "customdrag", "customdrag", "sysmenu_alchemist", rightMargin, offsetX);
	rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "necronomicon", "necronomicon", "sysmenu_card", rightMargin, offsetX);
	rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "grimoire", "grimoire", "sysmenu_neacro", rightMargin, offsetX);
	rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "poisonpot", "poisonpot", "sysmenu_wugushi", rightMargin, offsetX);	 
	rightMargin = SYSMENU_CREATE_VARICON(frame, extraBag, "pcbang_shop", "pcbang_shop", pcbangIcon, rightMargin, offsetX);	   
end

function SYSMENU_CREATE_VARICON(frame, status, ctrlName, frameName, imageName, rightMargin, offsetX, hotkeyName)

	local invenOpen = ui.CanOpenFrame(frameName);
	if invenOpen == 0 then
		return rightMargin;
	end

	local margin = status:GetMargin();
	local btn = frame:CreateControl("button", ctrlName, status:GetWidth(), status:GetHeight(), ui.LEFT, ui.BOTTOM, 0, margin.top, margin.right, margin.bottom);
	if btn == nil then
		return rightMargin;
	end
    local btnMargin = btn:GetMargin();
    btn:SetMargin(btnMargin.left, btnMargin.top, rightMargin, btnMargin.bottom);
	btn:CloneFrom(status);

	rightMargin = rightMargin + offsetX;
	AUTO_CAST(btn);
	btn:SetImage(imageName);
	btn:SetUserValue("IS_VAR_ICON", "YES");
	local tooltipString = ScpArgMsg(frameName);
	if hotkeyName ~= nil then
		local hotKey = hotKeyTable.GetHotKeyString(hotkeyName, 2, 1);	
		tooltipString = tooltipString .. string.format(" (%s)", hotKey);
	end

	btn:SetTextTooltip("{@st59}" .. tooltipString);
	if hotkeyName ~= 'Guild' then
		btn:SetEventScript(ui.LBUTTONUP, string.format("ui.ToggleFrame('%s')", frameName), true);
	else
		btn:SetEventScript(ui.LBUTTONUP, 'UI_TOGGLE_GUILD()', true);
		local guildinfonotice = btn:CreateControl("groupbox", "guildinfonotice", 20, 20, ui.LEFT, ui.TOP, 0, 0, 0, 0)
		guildinfonotice:SetSkinName("digitnotice_bg")
		guildinfonotice:EnableHitTest(1)
		guildinfonotice:SetVisible(0)
		local noticeText = guildinfonotice:CreateControl("richtext", "guildinfonoticetext", 20, 20, ui.CENTER_HORZ, ui.CENTER_VERT, 0, 0, 0, 0)
		noticeText:EnableHitTest(0)
    end
	return rightMargin;
end

function VARICON_VISIBLE_STATE_CHANTED(frame, ctrlName, frameName)
	local invenOpen = ui.CanOpenFrame(frameName);
	
	local currentVisible = 0;
	local inven = GET_CHILD(frame, ctrlName);
	if inven ~= nil then
		currentVisible = 1;
	end

	return currentVisible ~= beforeVisible;
end

function CHECK_WARP_VISIBLE()
	if 1 == 1 then
		return 0;
	end

	local result = GET_INTE_WARP_LIST();
	if result ~= nil and #result > 0 then
		return 1;
	end

	return 0;
end

function SYSMENU_FORCE_ALARM(childName, abilName)
	local frame = ui.GetFrame("sysmenu");

	local inven = GET_CHILD(frame, childName, "ui::CButton");

	if inven == nil then
		return;
	end

	local msg = ScpArgMsg("{The}AbilityIsActivated", "The", ClMsg(abilName));
	local fx, fy = NOTICE_CUSTOM(msg, inven:GetImageName());

	imcSound.PlaySoundEvent("statsup");
	local tx, ty = GET_UI_FORCE_POS(inven);
	UI_FORCE("sysmenu_alarm", fx, fy, tx, ty, 2, inven:GetImageName());
end

function CHECK_COLLECTION_VISIBLE()

	local colls = session.GetMySession():GetCollection();
	if colls:Count() > 0 then
		return 1;
	else
		return 0;
	end

end

function CHECK_HELPLIST_VISIBLE()

	local helpCount = session.GetHelpVecCount();

	if helpCount > 0 then
		return 1;
	else
		return 0;
	end

end

function CHECK_CTRL_OPENCON_SCP(frame, ctrlName, func, abilName)

	local inven = GET_CHILD(frame, ctrlName, "ui::CButton");
	local beforeVisible = inven:IsVisible();
	local visible = func();
	if beforeVisible == visible then
		return;
	end

	inven:ShowWindow(visible);
	frame:Invalidate();

	if beforeVisible == 0 and session.IsGameStarted() == 1 then
		inven:Emphasize("focus_ui", 10, 1.0, "AAFFFFFF");
		UI_PLAYFORCE(inven, "emphasize_1", 0, 0);
		--imcSound.PlaySoundEvent("statsup");
	end

end

function CHECK_CTRL_OPENCONDITION(frame, ctrlName, frameName)

	local inven = GET_CHILD(frame, ctrlName, "ui::CButton");
	
	if inven == nil then
		return
	end

	local invenOpen = ui.CanOpenFrame(frameName);
	local beforeVisible = inven:IsVisible();
	if beforeVisible == invenOpen then
		return;
	end

	inven:ShowWindow(invenOpen);
	frame:Invalidate();

	if beforeVisible == 0 and session.IsGameStarted() == 1 then
		inven:Emphasize("focus_ui", 0, 1.0, "AAFFFFFF");
		ui.CheckStopEmphaSize(frameName, frame:GetName(), ctrlName);
	end
end

function ON_UI_EMPHASIZE(frame, msg, argStr, argNum)

	local cnt, imageName, frameName, childName, targetName = Tokenize(argStr);
	RUN_UI_EMPHASIZE(imageName, frameName, childName, targetName, argNum);

end

function RUN_UI_EMPHASIZE(imageName, frameName, uiName, openFrameName, time)

	local frame = ui.GetFrame(frameName);
	local ctrl = frame:GetChild(uiName);
	ctrl:Emphasize(imageName, 0, 1.0, "AAFFFFFF");
	ui.CheckStopEmphaSize(openFrameName, frameName, uiName, time);
end

function SYSMENU_PC_STATUS_NOTICE(frame)
	local pc = GetMyPCObject();
	local bonusstat = GET_STAT_POINT(pc);
	local parentCtrl = frame:GetChild('status');
	NOTICE_CTRL_SET(parentCtrl, "status", bonusstat);
end

function SYSMENU_PC_NEWFRIEND_NOTICE(frame)

	local cnt = session.friends.GetFriendCount(FRIEND_LIST_REQUESTED);
	local parentCtrl = frame:GetChild('friend');
	NOTICE_CTRL_SET(parentCtrl, "friend", cnt);

end

function SYSMENU_INVENTORY_WEIGHT_NOTICE()
	local frame = ui.GetFrame("sysmenu");
	if frame == nil then
		return;
	end

	local parentCtrl = GET_CHILD_RECURSIVELY(frame, "inven");
	if parentCtrl == nil then
		return;
	end

	local noticeBallon = MAKE_BALLOON_FRAME(ScpArgMsg("NoticeInventoryOverWeight"), 0, 0, nil, "invenWeightNoticeBallon");
	noticeBallon:ShowWindow(1);

	local margin = parentCtrl:GetMargin();
	local x = margin.right;
	local y = margin.bottom;

	x = x + (parentCtrl:GetWidth() / 2);
	y = y + parentCtrl:GetHeight() - 5;

	noticeBallon:SetGravity(ui.RIGHT, ui.BOTTOM);
	noticeBallon:SetMargin(0, 0, x, y);
	noticeBallon:SetLayerLevel(106);
end

function SYSMENU_INVENTORY_WEIGHT_NOTICE_CLOSE()
	local noticeBallon = ui.GetFrame("invenWeightNoticeBallon");
	if noticeBallon ~= nil then
		noticeBallon:ShowWindow(0);
	end
end

function SYSMENU_INVENTORY_SLOTCOUNT_NOTICE()
	local frame = ui.GetFrame("sysmenu");
	if frame == nil then
		return;
	end

	local parentCtrl = GET_CHILD_RECURSIVELY(frame, "inven");
	if parentCtrl == nil then
		return;
	end

	local noticeBallon = MAKE_BALLOON_FRAME(ScpArgMsg("NoticeInventoryOverSlotCount"), 0, 0, nil, "invenSlotCountNoticeBalloon");
	noticeBallon:ShowWindow(1);

	local margin = parentCtrl:GetMargin();
	local x = margin.right;
	local y = margin.bottom;

	x = x + (parentCtrl:GetWidth() / 2);
	local weightBalloon = ui.GetFrame("invenWeightNoticeBallon");
	if weightBalloon ~= nil then
		y = y + parentCtrl:GetHeight() + weightBalloon:GetHeight() - 5;
	else
		y = y + parentCtrl:GetHeight() - 5;
	end

	noticeBallon:SetGravity(ui.RIGHT, ui.BOTTOM);
	noticeBallon:SetMargin(0, 0, x, y);
	noticeBallon:SetLayerLevel(106);
end

function SYSMENU_INVENTORY_SLOTCOUNT_NOTICE_CLOSE()
	local noticeBallon = ui.GetFrame("invenSlotCountNoticeBalloon");
	if noticeBallon ~= nil then
		noticeBallon:ShowWindow(0);
	end
end

function SYSMENU_GUILD_NOTICE(frame, isChecked)
	local parentCtrl = frame:GetChild('guildinfo');
	if parentCtrl == nil then
		return
	end

	local notice = GET_CHILD_RECURSIVELY(parentCtrl:GetTopParentFrame(), "guildinfonotice");    
	local noticeText = notice:GetChild("guildinfonoticetext");

	if isChecked > 0 then
		notice:ShowWindow(1);        
		noticeText:ShowWindow(1);
		noticeText:SetText('{ol}{b}{s14}!');
		notice:SetTextTooltip(ClMsg("GuildNewJoinRequest"))

     
		local noticeBalloon = MAKE_BALLOON_FRAME(ClMsg("GuildNewJoinRequest"), 0, 0, nil, "guildinfonotice", "{ol}{b}{s14}", 0)
		noticeBalloon:ShowWindow(1);
		noticeBalloon:SetDuration(5);
		noticeBalloon:SetGravity(ui.RIGHT, ui.BOTTOM) 

		local margin = parentCtrl:GetMargin(); 
		local x = margin.right + (parentCtrl:GetWidth() / 2);
		local y = margin.bottom + parentCtrl:GetHeight() + 5;
		
		noticeBalloon:SetMargin(margin.left, margin.top, x, y);
	elseif isChecked == nil or isChecked == 0  then
		notice:ShowWindow(0);
		noticeText:ShowWindow(0);
	end

end

function SYSMENU_PC_SKILL_NOTICE(frame)

	local parentCtrl = frame:GetChild("skilltree");
	local point = session.GetSkillPoint();
	NOTICE_CTRL_SET(parentCtrl, "skilltree", point);
end

function SYSMENU_JOURNAL_NOTICE(frame)
	local parentCtrl = frame:GetChild("journal");
	local list = ADVENTURE_BOOK_ACHIEVE_CONTENT.LIST_REWARD()
	local point = #list
	NOTICE_CTRL_SET(parentCtrl, "journal", point);
end

function SYSMENU_COLLECTION_NOTICE(frame)

	local parentCtrl = frame:GetChild("sys_collection");

	local pc = session.GetMySession();
	local etcObj = GetMyEtcObject();
	local colls = pc:GetCollection();
	local cnt = colls:Count();
	local point = 0
	for i = 0 , cnt - 1 do
		local coll = colls:GetByIndex(i);
		local isread = etcObj['CollectionRead_' .. coll.type]
		if isread == 0 then
			point = point + 1
		end
	end
	
	NOTICE_CTRL_SET(parentCtrl, "sys_collection", point);
end

function NOTICE_CTRL_SET(parentCtrl, noticeName, point)

	if parentCtrl == nil then
		return
	end

    local topFrame = parentCtrl:GetTopParentFrame(); 
	local notice = GET_CHILD_RECURSIVELY(parentCtrl:GetTopParentFrame(), noticeName.."notice");    
	local noticeText = notice:GetChild(noticeName.."noticetext");

	if point > 0 then
		notice:ShowWindow(1);        
		noticeText:ShowWindow(1);
		noticeText:SetText('{ol}{b}{s14}'..tostring(point));
        SYSMENU_NOTICE_TEXT_RESIZE(notice, point);
	elseif point == 0 then
		notice:ShowWindow(0);
		noticeText:ShowWindow(0);
	end
end

function SYSMENU_NOTICE_TEXT_RESIZE(box, point)
    if point >= 10 and point < 100 then
		box:Resize(30, 22);
	elseif point >= 100 and point < 1000 then
		box:Resize(40, 22);
	else
		box:Resize(22, 22);			
	end
end

function SYSMENU_BTN_MOUSE_MOVE(frame, btnCtrl, argStr, argNum)
	ui.OpenFrame("apps");
end

function SYSMENU_BTN_LCLICK(frame, btnCtrl, argStr, argNum)
	ui.OpenFrame("apps");
end

function SYSMENU_BTN_LOST_FOCUS(frame, btnCtrl, argStr, argNum)

	local focusFrame = ui.GetFocusFrame();
	if focusFrame ~= nil then
		local focusFrameName = focusFrame:GetName();
		if focusFrameName == "apps" then
			return;
		end

		if focusFrameName == "sysmenu" then
			local object = ui.GetFocusObject();
			if ui.GetFocusObject() == btnCtrl then
				return;
			end
		end
	end

	ui.CloseFrame("apps");
end

function SYSMENU_UPDATE_QUEUE(frame, queue)
	queue:UpdateData();
	if queue:GetChildCount() == 0 then
		queue:ShowWindow(0);
	else
		queue:ShowWindow(1);
	end
	queue:Invalidate();
	frame:Invalidate();
end

function SYSMENU_DELETE_QUEUE_BTN(frame, ctrlName)
	local queue = frame:GetChild("alarmqueue");
	queue:RemoveChild(ctrlName);
	SYSMENU_UPDATE_QUEUE(frame, queue);
end


function SYSMENU_CREATE_QUEUE_BTN(frame, ctrlName, image, updateQueue)
	local queue = frame:GetChild("alarmqueue");
	local pic = queue:CreateOrGetControl("picture", ctrlName, 44, 44, ui.CENTER_HORZ, ui.TOP, 0, 0, 0, 0);
	pic = tolua.cast(pic, "ui::CPicture");
	pic:SetEnableStretch(1);
	pic:SetImage(image);
	pic:ShowWindow(1);

	if updateQueue == 1 then
		SYSMENU_UPDATE_QUEUE(frame, queue);
	end

	return pic;
end

function ON_SYSMENU_AUCTIONINFO(frame)

	local mySession = session.GetMySession();
	local cid = mySession:GetCID();
	local vec = geNPCAuction.GetAuctionVec();

	local queue = frame:GetChild("alarmqueue");
	local aucItem = nil;
	for i = 0 , vec:size() - 1 do
		local auc = vec:at(i);
		aucItem = auc:GetRelatedItem(cid);
		if aucItem ~= nil then
			break;
		end
	end

	if aucItem == nil then
		queue:RemoveChild("AUCTION");
	else
		local pic = SYSMENU_CREATE_QUEUE_BTN(frame, "AUCTION", "skillpower_icon");
		pic:SetTooltipType("auction_sysmenu");
		pic:SetTooltipArg("", 0, aucItem:GetGuid());

		if aucItem:GetCID() == cid then
			pic:SetColorTone("FFFFFFFF");
		else
			pic:SetColorTone("FFFF0000");
		end
	end

	SYSMENU_UPDATE_QUEUE(frame, queue);

end

function UPDATE_AUCTION_SYSMENU_TOOLTIP(frame, strArg, num, guid)

	local mySession = session.GetMySession();
	local cid = mySession:GetCID();

	local item = geNPCAuction.GetByGuid(guid);

	local itemCls = GetClassByType("Item", item.itemType);
	local pic = GET_CHILD(frame, "pic", "ui::CPicture");
	pic:SetImage(itemCls.Icon);

	local itemtext = GET_CHILD(frame, "itemtext", "ui::CRichText");
	local text;
	local font;
	if cid == item:GetCID() then
		text = ScpArgMsg("NowYouAreTopBidderOf{Auto_1}", "Auto_1", itemCls.Name);
		font = "{@st55_c}";
	else
		font = "{@st42_red}";
		local tname = item:GetName();
		if tname == "" then
			tname = ClMsg("OtherPC");
		end

		text = ScpArgMsg("{Bidder}IsTopBidderOf{ItemName}", "Bidder", tname, "ItemName", itemCls.Name);
	end

	itemtext:SetText(font .. text);
	itemtext:Resize(220, 50);
	itemtext:SetTextFixWidth(1);
	itemtext:EnableResizeByText(1);

	local money =  GET_CHILD(frame, "money", "ui::CRichText");
	local text = "{@sti9}" .. GET_MONEY_IMG(24) .. " " .. GetCommaedText(item.curPrice);
	money:SetText(text);

	frame:SetUserValue("GUID", guid);
	frame:RunUpdateScript("UPDATE_AUCTION_TOOLTIP_TIME", 0, 0, 0, 1);
	AUCTION_TOOLTIP_SET_REMAINTIME(frame, item);

	frame:Invalidate();
end

function UPDATE_AUCTION_TOOLTIP_TIME(frame)
	local guid = frame:GetUserValue("GUID");
	local aucItem = geNPCAuction.GetByGuid(guid);
	AUCTION_TOOLTIP_SET_REMAINTIME(frame, aucItem);
	return 1;
end

function AUCTION_TOOLTIP_SET_REMAINTIME(frame, aucItem)

	local endTime = aucItem:GetEndSysTime();
	local curTime = geTime.GetServerSystemTime();
	local difSec = imcTime.GetIntDifSec(endTime, curTime);
	local timeString = GET_DHMS_STRING(difSec);
	local text = ScpArgMsg("RemainTime:{Auto_1}","Auto_1", timeString);
	frame:GetChild("remaintime"):SetText("{@55_c}" .. text);

end

-- 카드 합성
function TOGGLE_CARD_REINFORCE(frame)
    if GetCraftState() == 1 then
        ui.SysMsg(ClMsg('CHATHEDRAL53_MQ03_ITEM02'));
        return;
	end
	
	if control.IsRestSit() == false then
		ui.SysMsg(ClMsg("AvailableOnlyWhileResting"));
		return;
	end

	local rframe = ui.GetFrame("reinforce_by_mix");
	if rframe:IsVisible() == 1 then
		rframe:ShowWindow(0);
	else
		local title = rframe:GetChild("title");
		title:SetTextByKey("value", ClMsg("CardReinforce"));
		rframe:ShowWindow(1);
	end
end

-- 증표 합성
function TOGGLE_CERTIFICATE_REINFORCE(frame)		-- This is registered in restquickslotinfo.xml
    if GetCraftState() == 1 then
        ui.SysMsg(ClMsg('CHATHEDRAL53_MQ03_ITEM02'));
        return;
    end

	local rframe = ui.GetFrame("reinforce_by_mix_certificate");
	if rframe:IsVisible() == 1 then
		rframe:ShowWindow(0);
	else
		local title = rframe:GetChild("title");
		title:SetTextByKey("value", ClMsg("CertificateReinforce"));
		rframe:ShowWindow(1);
	end
end

-- 젬 강화
function TOGGLE_GEM_REINFORCE(frame)
    if GetCraftState() == 1 then
        ui.SysMsg(ClMsg('CHATHEDRAL53_MQ03_ITEM02'));
        return;
    end

	local rframe = ui.GetFrame("reinforce_by_mix");
	if rframe:IsVisible() == 1 then
		rframe:ShowWindow(0);
	else
		local title = rframe:GetChild("title");
		title:SetTextByKey("value", ClMsg("GemReinforce"));
		rframe:ShowWindow(1);
	end
end

-- 고급 카드(여신,레전드 카드) 강화
function TOGGLE_LEGEND_CARD_REINFORCE(frame)
    if GetCraftState() == 1 then
        ui.SysMsg(ClMsg('CHATHEDRAL53_MQ03_ITEM02'));
        return;
	end
	
	if control.IsRestSit() == false then
		ui.SysMsg(ClMsg("AvailableOnlyWhileResting"));
		return;
	end

	local rframe = ui.GetFrame("legendcardupgrade");
	if rframe:IsVisible() == 1 then
		rframe:ShowWindow(0);
	else
		local title = rframe:GetChild("title");
		title:SetTextByKey("value", ClMsg("AdvancedCardReinforce"));
		rframe:ShowWindow(1);
	end
end

-- 아크 합성
function TOGGLE_ARK_COMPOSITION(frame)
    if GetCraftState() == 1 then
        ui.SysMsg(ClMsg('CHATHEDRAL53_MQ03_ITEM02'));
        return;
    end

	local rframe = ui.GetFrame("ark_composition");
	if rframe:IsVisible() == 1 then
		TOGGLE_ARK_COMPOSITION_UI(0);
	else
		TOGGLE_ARK_COMPOSITION_UI(1);
	end
end

-- 아크 이전
function TOGGLE_ARK_RELOCATION(frame)
    if GetCraftState() == 1 then
        ui.SysMsg(ClMsg('CHATHEDRAL53_MQ03_ITEM02'));
        return;
    end

	local rframe = ui.GetFrame("ark_relocation");
	if rframe:IsVisible() == 1 then
		TOGGLE_ARK_RELOCATION_UI(0);
	else
		TOGGLE_ARK_RELOCATION_UI(1);
	end
end

function SYSMENU_GUILD_PROMOTE_NOTICE_CHECK()
	local frame = ui.GetFrame("sysmenu");
	if frame == nil then
		return;
	end

	if session.party.GetPartyInfo(PARTY_GUILD) ~= nil then
		return;
	end
	
	local aObj = GetMyAccountObj();
	local cnt = TryGetProp(aObj, "GUILD_PROMOTE_NOTICE_COUNT");
	local maxCnt = GET_GUILD_PROMOTE_NOTICE_MAX_COUNT();

	if cnt < maxCnt then
        control.CustomCommand("REQ_GUILD_PROMOTE_NOTICE_COUNT", 0);
	end
end

function SYSMENU_GUILD_PROMOTE_NOTICE(frame)
	local frame = ui.GetFrame("sysmenu");

	local parentCtrl = GET_CHILD_RECURSIVELY(frame, "guildRank");
	if parentCtrl == nil then
		return;
	end

	local noticeBallon = MAKE_BALLOON_FRAME(ScpArgMsg("GuildPromoteNotice"), 0, 0, nil, "GuildPromoteNoticeBallon", nil, nil, 1);

	local margin = parentCtrl:GetMargin();
	local x = margin.right - noticeBallon:GetWidth();
	local y = margin.bottom;

	x = x + (parentCtrl:GetWidth() / 2);
	y = y + parentCtrl:GetHeight() - 5;

	noticeBallon:SetGravity(ui.RIGHT, ui.BOTTOM);
	noticeBallon:SetMargin(0, 0, x, y);
	noticeBallon:SetLayerLevel(60);
	noticeBallon:ShowWindow(1);
end

function REQUEST_ICOR_MANAGE_DLG(frame)
	ui.CloseFrame('reinforce_by_mix')
	ui.CloseFrame('icoradd_multiple')
	ui.CloseFrame('icorrelease_multiple')
	ui.CloseFrame('icorrelease_random_multiple')
	control.CustomCommand('REQ_ICOR_MANAGE_DLG', 0)
end


function SYSMENU_INVENTORY_WEAPON_BOX_NOTICE()	
	local frame = ui.GetFrame("sysmenu");
	if frame == nil then
		return;
	end

	local parentCtrl = GET_CHILD_RECURSIVELY(frame, "inven");
	if parentCtrl == nil then
		return;
	end

	local noticeBallon = MAKE_BALLOON_FRAME(ScpArgMsg("NoticeStartWeaponBOX"), 0, 0, nil, "NoticeStartWeaponBOX");
	noticeBallon:ShowWindow(1);

	local margin = parentCtrl:GetMargin();
	local x = margin.right;
	local y = margin.bottom;

	x = x + (parentCtrl:GetWidth() / 2);
	y = y + parentCtrl:GetHeight() - 5;

	noticeBallon:SetGravity(ui.RIGHT, ui.BOTTOM);
	noticeBallon:SetMargin(0, 0, x, y);
	noticeBallon:SetLayerLevel(106);

	frame:RunUpdateScript('CHECK_SYSMENU_INVENTORY_WEAPON_BOX_NOTICE', 1, 0)
end

function CHECK_SYSMENU_INVENTORY_WEAPON_BOX_NOTICE()	
	local item_1 = session.GetEquipItemBySpot(ES_LH)
	item_1 = GetIES(item_1:GetObject())
	local item_2 = session.GetEquipItemBySpot(ES_RH)
	item_2 = GetIES(item_2:GetObject())	
	if item.IsNoneItem(item_1.ClassID) ~= 1 or item.IsNoneItem(item_2.ClassID) ~= 1 then
		local noticeBallon = ui.GetFrame("NoticeStartWeaponBOX");
		if noticeBallon ~= nil then
			noticeBallon:ShowWindow(0);
		end	

		local frame = ui.GetFrame("sysmenu")
		frame:StopUpdateScript('CHECK_SYSMENU_INVENTORY_WEAPON_BOX_NOTICE')		
		return 0
	end

	return 1
end

function UPDATE_GET_REINFORCE_MATERIAL()	
	if IS_HIDE_BALLOON_STATE() == true then
		return 1
	end

	local pc = GetMyPCObject()
	if pc.Lv >= 30 then
		local noticeBallon = ui.GetFrame("NoticeReinforceMaterial");
		if noticeBallon ~= nil then
			noticeBallon:ShowWindow(0);
		end
		return 0
	end

	local list = {ES_LH, ES_RH, ES_SHIRT, ES_PANTS, ES_GLOVES, ES_BOOTS}	
	for i = 1, #list do
		local spot = list[i]
		local _item = session.GetEquipItemBySpot(spot)
		_item = GetIES(_item:GetObject())
		if item.IsNoneItem(_item.ClassID) ~= 1 then
			if TryGetProp(_item, 'Reinforce_2', 0) > 0 then
				local noticeBallon = ui.GetFrame("NoticeReinforceMaterial");
				if noticeBallon ~= nil then
					noticeBallon:ShowWindow(0);
				end
				return 0
			end
		end
	end

	local mat = session.GetInvItemByName('misc_Growth_Reinforce_Tier1')
	if mat ~= nil then
		local cls = GetClass('Item', 'misc_Growth_Reinforce_Tier1')
		local count = session.GetInvItemCountByType(cls.ClassID)		
		if count < 7 then
			local noticeBallon = ui.GetFrame("NoticeReinforceMaterial");
			if noticeBallon ~= nil then
				noticeBallon:ShowWindow(0)
			end
			return 1
		end

		local noticeBallon = ui.GetFrame("NoticeReinforceMaterial");
		if noticeBallon == nil then
			local frame = ui.GetFrame("sysmenu");
			local parentCtrl = GET_CHILD_RECURSIVELY(frame, "inven");
			if parentCtrl ~= nil then
				local margin = parentCtrl:GetMargin();
				local x = margin.right;
				local y = margin.bottom;

				x = x + (parentCtrl:GetWidth() / 2);
				y = y + parentCtrl:GetHeight() - 5;

				noticeBallon = MAKE_BALLOON_FRAME(ScpArgMsg("NoticeReinforceMaterial"), 0, 0, nil, "NoticeReinforceMaterial");
				noticeBallon:ShowWindow(1);

				noticeBallon:SetGravity(ui.RIGHT, ui.BOTTOM);
				noticeBallon:SetMargin(0, 0, x, y);
				noticeBallon:SetLayerLevel(106);
			end
		else
			noticeBallon:ShowWindow(1);
		end
	end

	return 1
end

function UPDATE_INHERITANCE_NOTICE()	
	if IS_HIDE_BALLOON_STATE() == true then
		return 1
	end

	local list = {ES_LH, ES_RH, ES_LH_SUB, ES_RH_SUB, ES_SHIRT, ES_PANTS, ES_GLOVES, ES_BOOTS}	
	local exist = false
	for i = 1, #list do
		local spot = list[i]
		local _item = session.GetEquipItemBySpot(spot)
		_item = GetIES(_item:GetObject())
		if item.IsNoneItem(_item.ClassID) ~= 1 then
			if TryGetProp(_item, 'Reinforce_2', 0) == 20 then
				local str = TryGetProp(_item, 'StringArg', 'None')
				local use_lv = TryGetProp(_item, 'UseLv', 0)
				local make = false
				if use_lv == 1 and GetMyPCObject().Lv >= 120 then
					make = true
				elseif use_lv == 120 and GetMyPCObject().Lv >= 280 then
					make = true
				elseif use_lv == 280 and GetMyPCObject().Lv >= 480 then
					make = true
				end
				
				if string.find(str, 'Growth_By_Reinforce') ~= nil and make == true then
					exist = true
					local noticeBallon = ui.GetFrame("NoticedInheritance");
					if noticeBallon == nil then
						local frame = ui.GetFrame("sysmenu");
						local parentCtrl = GET_CHILD_RECURSIVELY(frame, "inven");
						if parentCtrl ~= nil then
							local margin = parentCtrl:GetMargin();
							local x = margin.right;
							local y = margin.bottom;

							x = x + (parentCtrl:GetWidth() / 2);
							y = y + parentCtrl:GetHeight() - 5;

							noticeBallon = MAKE_BALLOON_FRAME(ScpArgMsg("NoticedInheritance", 'name', TryGetProp(_item, 'Name', 'None')), 0, 0, nil, "NoticedInheritance");
							noticeBallon:ShowWindow(1);

							noticeBallon:SetGravity(ui.RIGHT, ui.BOTTOM);
							noticeBallon:SetMargin(0, 0, x, y);
							noticeBallon:SetLayerLevel(106);							
						end
					else
						noticeBallon:ShowWindow(1);
					end
					break
				end				
			end
		end
	end

	if exist == false then
		local noticeBallon = ui.GetFrame("NoticedInheritance");
		if noticeBallon ~= nil then
			noticeBallon:ShowWindow(0)
		end
	end

	return 1
end

local function make_balloon_frame_by(icon_name, name, up_y)	
	local frame = ui.GetFrame("sysmenu");
	local parentCtrl = GET_CHILD_RECURSIVELY(frame, icon_name);
	if parentCtrl ~= nil then
		local margin = parentCtrl:GetMargin();
		local x = margin.right;
		local y = margin.bottom;

		x = x + (parentCtrl:GetWidth() / 2);
		y = y + parentCtrl:GetHeight() - 5 + up_y;
		noticeBallon = MAKE_BALLOON_FRAME(ScpArgMsg(name), 0, 0, nil, name);
		noticeBallon:ShowWindow(1);

		noticeBallon:SetGravity(ui.RIGHT, ui.BOTTOM);
		noticeBallon:SetMargin(0, 0, x, y);
		noticeBallon:SetLayerLevel(106);		
		return noticeBallon:GetHeight()
	end

	return 0
end


local sort_list = {}
table.insert(sort_list, {'CanEquipArk', 420, ES_ARK})
table.insert(sort_list, {'CanEquipRelic', 458, ES_RELIC})
table.insert(sort_list, {'CanEquipEarring', 470, ES_EARRING})

local lock_list = {}
table.insert(lock_list, {'EARRING', 470})
table.insert(lock_list, {'BELT', 470})
table.insert(lock_list, {'SHOULDER', 480})
table.insert(lock_list, {'RELIC', 458})
table.insert(lock_list, {'SEAL', 350})
table.insert(lock_list, {'ARK', 420})

local function is_same_list(a, b)
	for k, v in pairs(a) do
		if a[k] ~= b[k] then
			return false
		end
	end
	
	return true
end

function IS_HIDE_BALLOON_STATE()	
	local name_list = {'petlist', 'induninfo','market', 'market_sell', 'market_cabinet', 'tpitem', 'inventory', 'skillability', 'adventure_book', 'companionlist'}
	local hide_frame = {'NoticeStartWeaponBOX', 'NoticeReinforceMaterial', 'NoticedInheritance', 'CanEquipArk', 'CanEquipRelic', 'CanEquipEarring'}

	for i = 1, #name_list do
		local frame = ui.GetFrame(name_list[i])		
		if frame ~= nil and frame:IsVisible() == 1 then
			for j = 1, #hide_frame do
				local hide = ui.GetFrame(hide_frame[j])
				if hide ~= nil then
					hide:ShowWindow(0)
				end
			end
			return true
		end
	end
	
	return false
end

function UPDATE_LOCK_EQUIPMENT()		
	if IS_HIDE_BALLOON_STATE() == true then
		before_state_list = {}
		before_lock_list = {}
		return 1
	end

	local function _SET_LOCK_IMAGE(slot, lockState)
		local controlset = slot:CreateOrGetControlSet('inv_equipslotlock', "equipslotlock", 0, 0);		
		controlset:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
		controlset:ShowWindow(lockState);		
	end

	local pc = GetMyPCObject()
	local lv = pc.Lv
	
	local onoff_list = {}
	for i = 1, #sort_list do
		if lv >= sort_list[i][2] and lv <= sort_list[i][2] + 3 and lv < PC_MAX_LEVEL then
			local _item = session.GetEquipItemBySpot(sort_list[i][3])
			_item = GetIES(_item:GetObject())
			local name = sort_list[i][1]
			if item.IsNoneItem(_item.ClassID) == 1 then
				onoff_list[name] = 1
			else
				onoff_list[name] = 0
			end		
		end
	end

	local make = is_same_list(onoff_list, before_state_list) == false
	if make then
		for k, v in pairs(onoff_list) do
			local f = ui.GetFrame(k)		
			if f ~= nil and v == 0 then
				ui.DestroyFrame(k)
				before_state_list[k] = 0
			end
		end

		local y = 0	
		for i = 1, #sort_list do
			local flag = onoff_list[sort_list[i][1]]		
			if flag == 1 then
				ret = make_balloon_frame_by('inven', sort_list[i][1], y)
				y = y + ret
				before_state_list[sort_list[i][1]] = 1
			end
		end
	end
	
	local draw_list = {}
	for i = 1, #lock_list do
		local spot = lock_list[i][1]
		local limit_lv = lock_list[i][2]
		if lv < limit_lv then
			draw_list[spot] = 1
		else
			draw_list[spot] = 0
		end
	end
	
	make = is_same_list(draw_list, before_lock_list) == false
	if make then
		for spot, v in pairs(draw_list) do
			local frame = ui.GetFrame('inventory')
			if frame ~= nil then
				local itemSlotSet = GET_CHILD_RECURSIVELY(frame, 'itemslotset')
				if itemSlotSet ~= nil then
					local slot = GET_CHILD_RECURSIVELY(itemSlotSet, spot)
					if slot ~= nil then				
						if v == 1 then
							_SET_LOCK_IMAGE(slot, 1)
							before_lock_list[spot] = 1
						else
							_SET_LOCK_IMAGE(slot, 0)
							before_lock_list[spot] = 0
						end
					end
				end
			end		
		end
	end

	return 1
end

