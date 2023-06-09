function ANCIENT_CARD_LIST_ON_INIT(addon, frame)
	addon:RegisterMsg('ANCIENT_CARD_ADD', 'ON_ANCIENT_CARD_ADD');
	addon:RegisterMsg('ANCIENT_CARD_REMOVE', 'ON_ANCIENT_CARD_RELOAD');
	addon:RegisterMsg('ANCIENT_CARD_LIST_LOAD', 'ON_ANCIENT_CARD_RELOAD');
	addon:RegisterMsg('ANCIENT_CARD_UPDATE_EXP', 'ON_ANCIENT_CARD_UPDATE');
	addon:RegisterMsg('ANCIENT_CARD_COMBINE', 'ON_ANCIENT_CARD_UPDATE');
	addon:RegisterMsg('ANCIENT_CARD_EVOLVE', 'ON_ANCIENT_CARD_UPDATE');
	addon:RegisterMsg('ANCIENT_CARD_UPDATE_SLOT', 'ON_ANCIENT_CARD_RELOAD');
	addon:RegisterMsg('ANCIENT_CARD_LOCK', 'ON_ANCIENT_CARD_LOCK');
	
end

local ANCIENT_INFO_TAB = 0
local ANCIENT_COMBINE_TAB = 1
local ANCIENT_EVOLVE_TAB = 2
local ANCIENT_PAGE_SIZE = 20
local ANCIENT_MAIN_SLOT_NUM = 4

local ANCIENT_COMBINE_GUID_LIST = {}
--open
function UI_CHECK_ANCIENT_UI_OPEN()
	local aObj = GetMyAccountObj()
	if TryGetProp(aObj,"ANCIENT_UNLOCK_UI") ~= 1 then
		return 0
	end
	return 1
end

function ANCIENT_MON_OPEN()
	ANCIENT_CARD_OPEN()
end

function ANCIENT_CARD_OPEN()
	if UI_CHECK_ANCIENT_UI_OPEN() == 0 then
		return
	end
    ui.ToggleFrame('ancient_card_list')
end
--close
function ANCIENT_CARD_LIST_CLOSE(frame)
	local cnt = session.ancient.GetAncientCardCount()
	for i = 1,cnt do
		local card = session.ancient.GetAncientCardByIndex(i-1)
		card.isNew = false
	end
	_ANCIENT_CARD_LOCK_MODE(0)
end

function TOGGLE_ANCIENT_CARD_LIST()
	ui.ToggleFrame('ancient_card_list')
end

function ANCIENT_CARD_LIST_OPEN(frame)
	local tab = frame:GetChild("tab")
	AUTO_CAST(tab);
	if tab ~= nil then
		tab:SelectTab(0);
		ANCIENT_CARD_LIST_TAB_CHANGE(frame)
	end
end

function ANCIENT_CARD_LIST_GET_TAB_TYPE(frame)
	local tab = GET_CHILD(frame,"tab")
	return tab:GetSelectItemIndex()
end

function ANCIENT_CARD_LIST_TAB_CHANGE(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	local tab = frame:GetChild("tab")
	AUTO_CAST(tab)
	local index = tab:GetSelectItemIndex();

	local zoneName = session.GetMapName();
	if IS_ANCIENT_CARD_UI_ENABLE_MAP(zoneName) == false then
		if index ~= ANCIENT_INFO_TAB then
			addon.BroadMsg("NOTICE_Dm_!", ClMsg("ImpossibleInCurrentMap"), 3);
			tab:SelectTab(ANCIENT_INFO_TAB)
			return
		end
	end

	local page_controller = GET_CHILD_RECURSIVELY(frame,"card_page_control")
	local cnt = math.max(session.ancient.GetAncientCardCount(),1)
	local page_num = math.floor((cnt-1)/ANCIENT_PAGE_SIZE)+1
	local now_page = page_controller:GetCurPage()
	page_controller:SetMaxPage(page_num)
	if now_page >= page_num then
		now_page = page_num-1
	end
	page_controller:SetCurPage(now_page)

	if index == ANCIENT_INFO_TAB then
		INIT_ANCIENT_CARD_INFO_TAB(frame)
		local button = GET_CHILD_RECURSIVELY(frame,"ancient_card_combine_btn")
		button:SetVisible(0)
	elseif index == ANCIENT_COMBINE_TAB then
		INIT_ANCIENT_CARD_COMBINE_TAB(frame,index)
		SET_ANCIENT_CARD_BUTTON(frame,ClMsg("Compose"),"ANCIENT_CARD_COMBINE")
	elseif index == ANCIENT_EVOLVE_TAB then
		INIT_ANCIENT_CARD_COMBINE_TAB(frame,index)
		SET_ANCIENT_CARD_BUTTON(frame,ClMsg("Evolve"),"ANCIENT_CARD_EVOLVE")
	end
end

function SET_ANCIENT_CARD_BUTTON(frame,text,script)
	local button = GET_CHILD_RECURSIVELY(frame,'ancient_card_combine_btn')
	button:SetText("{@st42}{s18}"..text)
	button:SetEventScript(ui.LBUTTONDOWN, script);
	button:SetVisible(1)
end

function INIT_ANCIENT_CARD_INFO_TAB(frame)

	INIT_ANCIENT_CARD_SLOTS(frame,0)

	local ancient_card_list_Gbox =  GET_CHILD_RECURSIVELY(frame,'ancient_card_list_Gbox')
	if ancient_card_list_Gbox == nil then
		return;
	end
	ancient_card_list_Gbox:RemoveAllChild()
	ancient_card_list_Gbox:SetEventScript(ui.DROP,"ANCIENT_CARD_SWAP_ON_DROP")
	INIT_ANCIENT_CARD_LIST_ALL(frame)
	local aObj = GetMyAccountObj();
	local ancient_card_num = GET_CHILD_RECURSIVELY(frame,'ancient_card_num')
	local cnt = session.ancient.GetAncientCardCount()
	local max_cnt = GET_ANCIENT_CARD_SLOT_MAX()
	ancient_card_num:SetTextByKey("count",cnt)
	ancient_card_num:SetTextByKey("max",max_cnt)
    ANCEINT_PASSIVE_LIST_SET(frame)
    ANCIENT_SET_COST(frame)
	local ancient_card_comb_name = GET_CHILD_RECURSIVELY(frame,"ancient_card_comb_name")
	ancient_card_comb_name:SetTooltipType('ancient_passive')
end

function INIT_ANCIENT_CARD_COMBINE_TAB(frame, index)
	INIT_ANCIENT_CARD_SLOTS(frame,index)
	ENABLE_COMBINE_SLOT(frame)
	ANCIENT_CARD_COMBINE_LIST_LOAD(frame)
	_ANCIENT_CARD_LOCK_MODE(0)
end

function INIT_ANCIENT_CARD_EVOLVE_TAB(frame, index)
end

function INIT_ANCIENT_CARD_SLOTS(frame,type)
	local gbox =  GET_CHILD_RECURSIVELY(frame,'ancient_card_slot_Gbox')
	if gbox == nil then
		return;
	end
	gbox:RemoveAllChild()
	local width = 4
	local base_name = "SLOT_"
	if type == ANCIENT_INFO_TAB then
		base_name = "SLOT_"
	elseif type == ANCIENT_COMBINE_TAB then
		base_name = "COMBINE_"
	elseif type == ANCIENT_EVOLVE_TAB then
		base_name = "COMBINE_"
	end
	local isLockMode = frame:GetUserValue("LOCK_MODE") == "YES"
	for index = 0,ANCIENT_MAIN_SLOT_NUM-1 do
		local ctrlSet = gbox:CreateControlSet("ancient_card_item_slot", base_name..index, width, 4);
		width = width + ctrlSet:GetWidth() + 2
		local ancient_card_gbox = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_gbox")
		ancient_card_gbox:SetVisible(0)
		ctrlSet:SetUserValue("INDEX",index)

		if type == ANCIENT_INFO_TAB then
			local slot = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_slot")
			AUTO_CAST(slot)
			local icon = CreateIcon(slot);
			slot:EnableHitTest(1)
			ctrlSet:SetEventScript(ui.DROP, 'ANCIENT_CARD_SWAP_ON_DROP');
			ctrlSet:SetEventScript(ui.RBUTTONDOWN, 'ANCIENT_CARD_SWAP_RBTNDOWN');
			ctrlSet:SetEventScriptArgNumber(ui.RBUTTONDOWN, -1);
			if index == 0 then
				local gold_border = GET_CHILD_RECURSIVELY(ctrlSet,"gold_border")
				AUTO_CAST(gold_border)
				gold_border:SetImage('monster_card_g_frame_02')
				ctrlSet:SetTextTooltip(ClMsg("AncientSlot1Tooltip"))
			end
			local card = session.ancient.GetAncientCardBySlot(index)
			if card ~= nil then
				SET_ANCIENT_CARD_SLOT(ctrlSet,card,isLockMode)
			end
			local default_image = GET_CHILD_RECURSIVELY(ctrlSet,"default_image")
			AUTO_CAST(default_image)
			default_image:SetImage("socket_slot_bg")
		elseif type == ANCIENT_COMBINE_TAB or type == ANCIENT_EVOLVE_TAB then
			ctrlSet:SetEventScript(ui.DROP,"ON_ANCIENT_CARD_COMBINE_DROP")
			ctrlSet:SetEventScript(ui.RBUTTONDOWN, 'ANCIENT_CARD_SLOT_POP_COMBINE')
			if index == ANCIENT_MAIN_SLOT_NUM-1 then
				local default_image = GET_CHILD_RECURSIVELY(ctrlSet,"default_image")
				AUTO_CAST(default_image)
				default_image:SetImage("m_question_mark")
				default_image:Resize(97,128)
				-- default_image:SetAlpha(60)
				ctrlSet:SetEventScript(ui.RBUTTONDOWN,"ON_ANCIENT_CARD_RELOAD")
			else
				local default_image = GET_CHILD_RECURSIVELY(ctrlSet,"default_image")
				AUTO_CAST(default_image)
				if type == ANCIENT_COMBINE_TAB then
					default_image:SetImage("toketmon_compound_plus")
				elseif type == ANCIENT_EVOLVE_TAB then
					default_image:SetImage("toketmon_evolution_star")
				end
			end
		end
	end
end

function SET_ANCIENT_CARD_SLOT(ctrlSet,card,isLockMode)
	local font = "{@st42b}{s14}"
	--slot image
	local slot = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_slot")
	AUTO_CAST(slot)
	local icon = CreateIcon(slot);
	local monCls = GetClass("Monster", card:GetClassName());
	local iconName = TryGetProp(monCls, "Icon");
	icon:SetImage(iconName)
	--star drawing
	local starText = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_grade")
	local starStr=""
	for i = 1, card.starrank do
		starStr = starStr ..string.format("{img monster_card_starmark %d %d}", 21, 20)
	end
	
	starText:SetText(starStr)
	--set lv
	local exp = card:GetStrExp();
	local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
	local level = xpInfo.level
	local lvText = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_lv")
	lvText:SetText(font.."Lv. "..level.."{/}")
	--set lv and name
	local nameText = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_name")
    local cls = GetClass("Monster",card:GetClassName())

	nameText:SetText(font..cls.Name.."{/}")

	--exp gauge
	local ancient_card_gauge = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_gauge")
	AUTO_CAST(ancient_card_gauge)
	local totalExp = xpInfo.totalExp - xpInfo.startExp;
	local curExp = exp - xpInfo.startExp;
	ancient_card_gauge:SetPoint(curExp, totalExp);
	
	
	--type
	local racetypeDic = {
		Klaida="insect",
		Widling="wild",
		Velnias="devil",
		Forester="plant",
		Paramune="variation",
		None="melee"
	}

	local type1Text = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_type1_text")
	type1Text:SetText(font..ScpArgMsg("MonInfo_RaceType_"..cls.RaceType).."{/}")
	local type1Pic = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_type1_pic")
	local type1Icon = CreateIcon(type1Pic)
	type1Icon:SetImage("monster_"..racetypeDic[cls.RaceType])

	local type2Text = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_type2_text")
	type2Text:SetText(font..ScpArgMsg("MonInfo_Attribute_"..cls.Attribute).."{/}")
	local type2Pic = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_type2_pic")
	local type2Icon = CreateIcon(type2Pic)
	type2Icon:SetImage("attribute_"..cls.Attribute)


	ctrlSet:SetUserValue("ANCIENT_GUID",card:GetGuid())
	--tooltip
	ctrlSet:SetTooltipType("ancient_card")
	ctrlSet:SetTooltipStrArg(card:GetGuid())
	icon:SetTooltipType("ancient_card")
	icon:SetTooltipStrArg(card:GetGuid())
	
	local ancientCls = GetClass("Ancient_Info",monCls.ClassName)
	local rarity = ancientCls.Rarity
	--hide
	local background = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_background")
	AUTO_CAST(background)
	if rarity == 1 then
		background:SetImage("normal_card")
	elseif rarity == 2 then
		background:SetImage("rare_card")
	elseif rarity == 3 then
		background:SetImage("unique_card")
	elseif rarity == 4 then
		background:SetImage("legend_card")
	end
	
	local groupbox = ctrlSet:GetChild("ancient_card_gbox")
	groupbox:SetVisible(1)
	SET_CARD_LOCK_MODE(ctrlSet,isLockMode)
	if card.isLock == true then
		local lock = slot:CreateOrGetControlSet('inv_itemlock', "itemlock", 0, 0);
		lock:SetGravity(ui.RIGHT, ui.TOP);
	end
end

function INIT_ANCIENT_CARD_LIST_ALL(frame,func)
	frame = frame:GetTopParentFrame()
	local pageCtrl = GET_CHILD_RECURSIVELY(frame,"card_page_control")
	local page = pageCtrl:GetCurPage()
	local ancient_card_list_Gbox = GET_CHILD_RECURSIVELY(frame,"ancient_card_list_Gbox")
	ancient_card_list_Gbox:RemoveAllChild()
	for i = page*ANCIENT_PAGE_SIZE, (page+1)*ANCIENT_PAGE_SIZE-1 do
		local card = session.ancient.GetAncientCardByIndex(i)
		if card == nil then
			break
		end
		local ctrlSet = INIT_ANCIENT_CARD_LIST(frame,card)
	end
end

function IS_VALID_ANCIENT_CARD(frame,card)
	if card.slot < ANCIENT_MAIN_SLOT_NUM then
		return false
	end
	local type = ANCIENT_CARD_LIST_GET_TAB_TYPE(frame)
	if type == ANCIENT_COMBINE_TAB or type == ANCIENT_EVOLVE_TAB then
		for i = 0,2 do
			local ctrlSet = GET_CHILD_RECURSIVELY(frame,"COMBINE_"..i)
			if ctrlSet ~= nil then
				local guid = ctrlSet:GetUserValue("ANCIENT_GUID")
				if guid == card:GetGuid() then
					return false
				end
			end
		end
	end
	return true
end

function INIT_ANCIENT_CARD_LIST(frame,card)
	frame = frame:GetTopParentFrame()
	local type = ANCIENT_CARD_LIST_GET_TAB_TYPE(frame)
	local isLockMode = frame:GetUserValue("LOCK_MODE") == "YES"

	local ancient_card_list_Gbox = GET_CHILD_RECURSIVELY(frame,'ancient_card_list_Gbox')
	local ctrlSet = SET_ANCIENT_CARD_LIST(ancient_card_list_Gbox,card,isLockMode)
	if type == ANCIENT_INFO_TAB then
		ctrlSet:SetEventScript(ui.DROP,"ANCIENT_CARD_SWAP_ON_DROP")
		ctrlSet:SetEventScript(ui.RBUTTONDOWN, 'ANCIENT_CARD_SWAP_RBTNDOWN');
		ctrlSet:SetEventScriptArgNumber(ui.RBUTTONDOWN, -2);
	else
		ctrlSet:SetEventScript(ui.DROP,"ANCIENT_CARD_SLOT_POP_COMBINE_BY_DROP")
		ctrlSet:SetEventScript(ui.DROP,dropScp)
		ctrlSet:SetEventScript(ui.RBUTTONDOWN, 'ON_ANCIENT_CARD_COMBINE_RBUTTONDOWN');
	end
	return ctrlSet;
end

function SET_ANCIENT_CARD_LIST(gbox,card,isLockMode)
	local height = (gbox:GetChildCount()-1) * 51
	local ctrlSet = GET_CHILD(gbox,"SET_" .. card.slot)
	if ctrlSet == nil then
		ctrlSet = gbox:CreateOrGetControlSet("ancient_card_item_list", "SET_" .. card.slot, 0, height);
	end

	--set level
	local exp = card:GetStrExp();
	local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
	local level = xpInfo.level
	local levelText = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_level")
	levelText:SetText("{@st42b}{s16}Lv. "..level.."{/}")

	--set image
	local monCls = GetClass("Monster", card:GetClassName());
	local iconName = TryGetProp(monCls, "Icon");
	local slot = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_slot")
	local image = CreateIcon(slot)
	image:SetImage(iconName)

	--set name
	local nameText = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_name")
	local name = monCls.Name
	local starStr = ""
	for i = 1, card.starrank do
		starStr = starStr ..string.format("{img monster_card_starmark %d %d}", 21, 20)
	end
	local ancientCls = GetClass("Ancient_Info",monCls.ClassName)
	local rarity = ancientCls.Rarity
	AUTO_CAST(ctrlSet)
	if rarity == 1 then
		name = ctrlSet:GetUserConfig("NORMAL_GRADE_TEXT")..name..' '..starStr.."{/}"
	elseif rarity == 2 then
		name = ctrlSet:GetUserConfig("MAGIC_GRADE_TEXT")..name..' '..starStr.."{/}" 
	elseif rarity == 3 then
		name = ctrlSet:GetUserConfig("UNIQUE_GRADE_TEXT")..name..' '..starStr.."{/}"
	elseif rarity == 4 then
		name = ctrlSet:GetUserConfig("LEGEND_GRADE_TEXT")..name..' '..starStr.."{/}"
	end
	nameText:SetText(name)

	local racetypeDic = {
						Klaida="insect",
						Widling="wild",
						Velnias="devil",
						Forester="plant",
						Paramune="variation",
						None="melee"
					}
	--set type
	local type1Slot = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_type1_pic")
	local type1Icon = CreateIcon(type1Slot)
	type1Icon:SetImage("monster_"..racetypeDic[monCls.RaceType])

	local type2Slot = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_type2_pic")
	local type2Icon = CreateIcon(type2Slot)
	type2Icon:SetImage("attribute_"..monCls.Attribute)	
	
	--tooltip
	ctrlSet:SetTooltipType("ancient_card")
	ctrlSet:SetTooltipStrArg(card:GetGuid())

	ctrlSet:SetUserValue("ANCIENT_GUID",card:GetGuid())

	SET_CARD_LOCK_MODE(ctrlSet,isLockMode)
	if card.isNew == true then
		local slot = GET_CHILD_RECURSIVELY(ctrlSet,'ancient_card_slot')
		slot:SetHeaderImage('new_inventory_icon');
	end
	if card.isLock == true then
		local slot = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_slot")
		local lock = slot:CreateOrGetControlSet('inv_itemlock', "itemlock", 0, 0);
		lock:SetGravity(ui.RIGHT, ui.TOP);
		local remove = GET_CHILD_RECURSIVELY(ctrlSet,"sell_btn")
		remove:SetEnable(0)
end
	local pic_bg = GET_CHILD_RECURSIVELY(ctrlSet,"graybg")
	if IS_VALID_ANCIENT_CARD(gbox:GetTopParentFrame(),card) == true then
		pic_bg:ShowWindow(0)
		ctrlSet:EnableHitTest(1)
	else
		pic_bg:ShowWindow(1)
		local pic = GET_CHILD(pic_bg,"gray")
		pic:SetAlpha(70)
		ctrlSet:EnableHitTest(0)
end
	return ctrlSet
end

function ENABLE_COMBINE_SLOT(frame)
	local button = GET_CHILD_RECURSIVELY(frame,'ancient_card_combine_btn')
	local slotBox = GET_CHILD_RECURSIVELY(frame,"ancient_card_slot_Gbox")
	local cnt = slotBox:GetChildCount()
	for i = 0,cnt-1 do
		local toCtrlSet = slotBox:GetChildByIndex(i)
		local toGuid = toCtrlSet:GetUserValue("ANCIENT_GUID")
		if toCtrlSet:GetUserValue("INDEX") ~= "None" and toCtrlSet:GetUserValue("INDEX") ~= "3" then
			if toGuid == nil or toGuid == "None" then
				button:SetEnable(0)
				return;
			end
		end
	end
	button:SetEnable(1)
end

function ON_ANCIENT_CARD_COMBINE_DROP(parent, FromctrlSet, argStr, argNum)
	local frame = parent:GetTopParentFrame();
	local FromGuid = frame:GetUserValue("LIFTED_GUID")
	for i = 0,2 do
		local slotBox = GET_CHILD_RECURSIVELY(frame,"COMBINE_"..i)
		if slotBox:GetUserValue("ANCIENT_GUID") == FromGuid then
			return;
		end
	end
	SET_ANCIENT_CARD_COMBINE(frame, FromGuid, argStr, argNum)
	frame:SetUserValue("LIFTED_GUID","None")
end

function ON_ANCIENT_CARD_COMBINE_RBUTTONDOWN(parent, FromctrlSet, argStr, argNum)
	local FromGuid = FromctrlSet:GetUserValue("ANCIENT_GUID")
	local frame = parent:GetTopParentFrame();
	local slotBox = GET_CHILD_RECURSIVELY(frame,"ancient_card_slot_Gbox")
	local cnt = slotBox:GetChildCount()
	local ctrlSet = GET_EMPTY_COMBINE_SLOT(frame,FromGuid)
	if ctrlSet == nil then
		ENABLE_COMBINE_SLOT(frame)
		imcSound.PlaySoundEvent("UI_card_move");
		return;
	end
	imcSound.PlaySoundEvent("sys_card_battle_rival_slot_show");
	SET_ANCIENT_CARD_COMBINE(frame, FromGuid, argStr, argNum)
end

function ANCIENT_CARD_COMBINE_CHECK(frame, guid)
	local fromCard = session.ancient.GetAncientCardByGuid(guid)
	local slotBox = GET_CHILD_RECURSIVELY(frame,"ancient_card_slot_Gbox")
	local cnt = slotBox:GetChildCount()
	for i = 0,cnt-1 do
		local toCtrlSet = slotBox:GetChildByIndex(i)
		local toGuid = toCtrlSet:GetUserValue("ANCIENT_GUID")
		if toGuid ~= nil and toGuid ~= "None" then   
			local toCard = session.ancient.GetAncientCardByGuid(toGuid)
			if toCard.rarity ~= fromCard.rarity then
				return false;
			else
				return true;
			end
		end
	end
	return true;
end

function ANCIENT_CARD_EVOLVE_CHECK(frame,guid)
	local fromCard = session.ancient.GetAncientCardByGuid(guid)
	local slotBox = GET_CHILD_RECURSIVELY(frame,"ancient_card_slot_Gbox")
	local cnt = slotBox:GetChildCount()
	if fromCard.starrank >= 3 then
		addon.BroadMsg("NOTICE_Dm_scroll", ClMsg("AncientUnableMonster"), 3);
		return false;
	end
	for i = 0,2 do
		local toCtrlSet = slotBox:GetChildByIndex(i)
		local toGuid = toCtrlSet:GetUserValue("ANCIENT_GUID")
		if toGuid ~= nil and toGuid ~= "None" then   
			local toCard = session.ancient.GetAncientCardByGuid(toGuid)
			if toCard:GetClassName() ~= fromCard:GetClassName() then
				addon.BroadMsg("NOTICE_Dm_scroll", ClMsg("AncientNotSameMonster"), 3);
				return false;
			elseif toCard.starrank ~= fromCard.starrank then
				addon.BroadMsg("NOTICE_Dm_scroll", ClMsg("AncientNotSameStarrank"), 3);
				return false;
			else
				return true;
			end
		end
	end
	return true;
end

function SET_ANCIENT_CARD_COMBINE(frame, FromGuid, argStr, argNum)
	local card = session.ancient.GetAncientCardByGuid(FromGuid)
	if card.isLock == true then
		addon.BroadMsg("NOTICE_Dm_scroll", ClMsg("AncientCardLock"), 3);
		return
	end
	local toCtrlSet = GET_EMPTY_COMBINE_SLOT(frame,FromGuid)
	if toCtrlSet ~= nil then
	        SET_ANCIENT_CARD_SLOT(toCtrlSet,card)
		ENABLE_COMBINE_SLOT(frame)
		local ancient_card_list_Gbox = GET_CHILD_RECURSIVELY(frame,'ancient_card_list_Gbox')
		SET_ANCIENT_CARD_LIST(ancient_card_list_Gbox,card)
	end
end

function GET_EMPTY_COMBINE_SLOT(frame,FromGuid)
	local tab = frame:GetChild("tab")
	AUTO_CAST(tab)
	local index = tab:GetSelectItemIndex();
	local resultBox = GET_CHILD_RECURSIVELY(frame,"COMBINE_3")
	if resultBox:GetUserValue("ANCIENT_GUID") ~= "None" then
		addon.BroadMsg("NOTICE_Dm_scroll", ClMsg("AncientCompseResultRemove"), 3);
		return;
	elseif index == 1 and ANCIENT_CARD_COMBINE_CHECK(frame,FromGuid) == false then
		addon.BroadMsg("NOTICE_Dm_scroll", ClMsg("AncientNotSameRarity"), 3);
		return;
	elseif index == 2 and ANCIENT_CARD_EVOLVE_CHECK(frame,FromGuid) == false then
		return;
	end
	local slotBox = GET_CHILD_RECURSIVELY(frame,"ancient_card_slot_Gbox")
	local cnt = slotBox:GetChildCount()
	for i = 0,cnt-1 do
		local toCtrlSet = slotBox:GetChildByIndex(i)
		local toGuid = toCtrlSet:GetUserValue("ANCIENT_GUID")
		if toCtrlSet:GetUserValue("INDEX") ~= "None" and toCtrlSet:GetUserValue("INDEX") ~= "3" then
			if toGuid == nil or toGuid == "None" then
				return toCtrlSet;
			end
		end
	end
end

function ANCIENT_CARD_SLOT_POP_COMBINE_BY_DROP(parent,ctrlSet)
	local frame = parent:GetTopParentFrame()
	local guid = frame:GetUserValue("LIFTED_GUID")
	for i = 0,2 do
		local slotCtrl = GET_CHILD_RECURSIVELY(frame,"COMBINE_"..i)
		if slotCtrl:GetUserValue("ANCIENT_GUID") == guid then
			ANCIENT_CARD_SLOT_POP_COMBINE(frame,slotCtrl, true)
			break;
		end
	end
	frame:SetUserValue("LIFTED_GUID","None")
end

function ANCIENT_CARD_SLOT_POP_COMBINE(parent, ctrlSet, byDrop)
	imcSound.PlaySoundEvent("UI_card_move");
	local frame = parent:GetTopParentFrame()
	local guid = ctrlSet:GetUserValue("ANCIENT_GUID")
	ANCIENT_CARD_SLOT_POP(parent, ctrlSet)
	ENABLE_COMBINE_SLOT(frame)
	local card = session.ancient.GetAncientCardByGuid(guid)
	if GET_CHILD_RECURSIVELY(frame,"SET_"..card.slot) == nil then
		return
	end
	local ancient_card_list_Gbox = GET_CHILD_RECURSIVELY(frame,'ancient_card_list_Gbox')
	SET_ANCIENT_CARD_LIST(ancient_card_list_Gbox,card)
end

function ANCIENT_CARD_SLOT_POP(parent, ctrlSet)
	local groupbox = ctrlSet:GetChild("ancient_card_gbox")
	groupbox:SetVisible(0)
	local default_box = ctrlSet:GetChild("default_box")
	default_box:SetVisible(1)
	local guid = ctrlSet:GetUserValue("ANCIENT_GUID")
	ctrlSet:SetUserValue("ANCIENT_GUID","None")
	ctrlSet:SetTooltipType("None")
	ctrlSet:SetTooltipStrArg("None")
	ctrlSet:SetDragFrame('None')
	ctrlSet:SetDragScp("None")
	ctrlSet:Invalidate();

	local frame = parent:GetTopParentFrame()
	local listFrame = GET_CHILD_RECURSIVELY(frame, "ancient_card_list_Gbox")
end

function ANCIENT_CARD_COMBINE(parent, control, argStr, argNum)
	local zoneName = session.GetMapName();
	if IS_ANCIENT_CARD_UI_ENABLE_MAP(zoneName) == false then
		addon.BroadMsg("NOTICE_Dm_!", ClMsg("ImpossibleInCurrentMap"), 3);
		return
	end
	local frame = parent:GetTopParentFrame()
	local guids = {}
	for i = 0,2 do
		local gbox = GET_CHILD_RECURSIVELY(frame,'COMBINE_'..i)
		local guid = gbox:GetUserValue("ANCIENT_GUID")
		if guid == "None" or guid == nil then
			return;
		end
		guids[i+1] = guid
	end
	if #guids ~= 3 then
		return
	end
	ReqCombineAncientCard(guids[1],guids[2],guids[3])
	control:SetEnable(0)

	local card = session.ancient.GetAncientCardByGuid(guids[3])
	frame:SetUserValue("RARITY",card.rarity)
end

function ANCIENT_CARD_EVOLVE(parent, control, argStr, argNum)
	local zoneName = session.GetMapName();
	if IS_ANCIENT_CARD_UI_ENABLE_MAP(zoneName) == false then
		addon.BroadMsg("NOTICE_Dm_!", ClMsg("ImpossibleInCurrentMap"), 3);
		return
	end
	local frame = parent:GetTopParentFrame()
	local guids = {}
	for i = 0,2 do
		local gbox = GET_CHILD_RECURSIVELY(frame,'COMBINE_'..i)
		local guid = gbox:GetUserValue("ANCIENT_GUID")
		if guid == "None" or guid == nil then
			return;
		end
		guids[i+1] = guid
	end
	if #guids ~= 3 then
		return
	end
	ReqEvolveAncientCard(guids[1],guids[2],guids[3])
	control:SetEnable(0)
end

function ANCIENT_CARD_SWAP_ON_DROP(parent,toCtrlSet, argStr, argNum)
	local toIndex = tonumber(toCtrlSet:GetUserValue("INDEX"))
	local frame = parent:GetTopParentFrame()
	local guid = frame:GetUserValue("LIFTED_GUID")
	if guid == "None" or guid == nil or tonumber == nil then
		return;
	end
	local card = session.ancient.GetAncientCardByGuid(guid)
	if card.slot >= ANCIENT_MAIN_SLOT_NUM and toIndex ~= nil and toIndex >= ANCIENT_MAIN_SLOT_NUM then
		return
	end
	REQUEST_SWAP_ANCIENT_CARD(toCtrlSet:GetTopParentFrame(),guid,toIndex)
	frame:SetUserValue("LIFTED_GUID","None")
end

function ANCIENT_CARD_GET_EMPTY_SLOT(offset)
	local slot = offset
	local card = session.ancient.GetAncientCardBySlot(slot)
	while card ~= nil do
		slot = slot + 1
		card = session.ancient.GetAncientCardBySlot(slot)
	end
	return slot;
end

function ANCIENT_CARD_SWAP_RBTNDOWN(parent,ctrlSet,argStr,argNum)
	local guid = ctrlSet:GetUserValue("ANCIENT_GUID")
	local slot = nil
	if argNum == -1 then
		imcSound.PlaySoundEvent("UI_card_move");
	elseif argNum == -2 then
		local isEnable = false;
		for i = 0,ANCIENT_MAIN_SLOT_NUM-1 do
			local toCard = session.ancient.GetAncientCardBySlot(i)
			if toCard == nil then
				isEnable = true
				slot = i
				break;
			end
		end

		if isEnable == false then
			imcSound.PlaySoundEvent("UI_card_move");
			return;
		end

		imcSound.PlaySoundEvent("sys_card_battle_rival_slot_show");
	end
	REQUEST_SWAP_ANCIENT_CARD(parent:GetTopParentFrame(),guid,slot)
end

function REQUEST_SWAP_ANCIENT_CARD(frame,guid,slot)
	local zoneName = session.GetMapName();
	local zoneKeyword = GetClass("Map", zoneName).Keyword;
	keywordTable = StringSplit(zoneKeyword, ";");
	
	if IS_ANCIENT_ENABLE_MAP() == "YES" then
		addon.BroadMsg("NOTICE_Dm_!", ClMsg("ImpossibleInCurrentMap"), 3);
		return
	end
	
	if guid == "None" or guid == nil then
		return;
	end
	if slot == nil or slot == 'None' then
		slot = ANCIENT_CARD_GET_EMPTY_SLOT(ANCIENT_MAIN_SLOT_NUM)
	end
	local toCard = session.ancient.GetAncientCardBySlot(slot)
	if toCard ~= nil then
		if toCard:GetGuid() == guid then
			return
		end
	end

	local aObj = GetMyAccountObj()
	local fromCard = session.ancient.GetAncientCardByGuid(guid)
	if fromCard.slot >= ANCIENT_MAIN_SLOT_NUM and slot >= ANCIENT_MAIN_SLOT_NUM then
		return
	end
	local totalCost = 0
	for i = 0,ANCIENT_MAIN_SLOT_NUM-1 do
		if i ~= slot and i ~= fromCard.slot then
			local card = session.ancient.GetAncientCardBySlot(i)
			if card ~= nil then
				totalCost = totalCost + card:GetCost()
			end
		elseif i == slot then
			totalCost = totalCost + fromCard:GetCost()
		elseif i == fromCard.slot and toCard ~= nil then
			totalCost = totalCost + toCard:GetCost()
		end
	end
	if aObj.ANCIENT_MAX_COST < totalCost then
		addon.BroadMsg("NOTICE_Dm_scroll", ClMsg("AncientCostOver"), 3);
	end
	ReqSwapAncientCard(guid,slot)
end

function SORT_ANCIENT_CARD()
	local context = ui.CreateContextMenu("CONTEXT_ANCIENT_SORT", "", 0, 0, 170, 100);
	local scpScp = "";

	local frame = ui.GetFrame("ancient_card_list")
	if frame == nil then
		return
	end

	scpScp = string.format("REQ_ANCIENT_CARD_SORT(%d)", session.ancient.SORT_BY_RARITY);
	ui.AddContextMenuItem(context, ScpArgMsg("SortByGrade"), scpScp);	
	scpScp = string.format("REQ_ANCIENT_CARD_SORT(%d)", session.ancient.SORT_BY_NAME);
	ui.AddContextMenuItem(context, ScpArgMsg("SortByName"), scpScp);	
	scpScp = string.format("REQ_ANCIENT_CARD_SORT(%d)", session.ancient.SORT_BY_STARRANK);
	ui.AddContextMenuItem(context, ScpArgMsg("SortByStarrank"), scpScp);	
	scpScp = string.format("REQ_ANCIENT_CARD_SORT(%d)", session.ancient.SORT_BY_LEVEL);
	ui.AddContextMenuItem(context, ScpArgMsg("SortByLevel"), scpScp);	
	ui.OpenContextMenu(context);
end

function REQ_ANCIENT_CARD_SORT(sortType)
	session.ancient.SortAncientCard(sortType)
end

function ANCIENT_CARD_UPDATE(frame,card)
	local type = ANCIENT_CARD_LIST_GET_TAB_TYPE(frame)
	if card.slot < ANCIENT_MAIN_SLOT_NUM then
		if type == 0 then
			local ctrlSet = GET_CHILD_RECURSIVELY(frame,"SLOT_"..card.slot)
			if ctrlSet ~= nil then
				local isLockMode = frame:GetUserValue("LOCK_MODE") == "YES"
				SET_ANCIENT_CARD_SLOT(ctrlSet,card,isLockMode)
			end
		end
	end
	if GET_CHILD_RECURSIVELY(frame,"SET_"..card.slot) ~= nil then
		local ancient_card_list_Gbox = GET_CHILD_RECURSIVELY(frame,'ancient_card_list_Gbox')
		SET_ANCIENT_CARD_LIST(ancient_card_list_Gbox,card)
	end
end

function ANCIENT_CARD_COMBINE_COMPLETE(frame,guid)
	local type = ANCIENT_CARD_LIST_GET_TAB_TYPE(frame)
	if type == 0 then
		return;
	end
	INIT_ANCIENT_CARD_SLOTS(frame,type)
	local resultBox = GET_CHILD_RECURSIVELY(frame,'COMBINE_3')
	
	local rarity = tonumber(frame:GetUserValue("RARITY"))
	local card = session.ancient.GetAncientCardByGuid(guid)
	if rarity ~= nil and rarity ~= 0 and card.rarity > rarity then
		resultBox:PlayUIEffect(frame:GetUserConfig("COMBINE_EFFECT_SPECIAL"), tonumber(frame:GetUserConfig("COMBINE_EFFECT_SCALE")),"COMBINE")
	else
		resultBox:PlayUIEffect(frame:GetUserConfig("COMBINE_EFFECT"), tonumber(frame:GetUserConfig("COMBINE_EFFECT_SCALE")),"COMBINE")
	end
	resultBox:SetUserValue("ANCIENT_GUID","SOMETHING_EXIST")
	frame:SetUserValue("RARITY",0)
	local scp = string.format('ANCIENT_CARD_COMBINE_END(\"%s\",\"%d\")',guid,type)
	frame:SetEnable(0)
	ReserveScript(scp,1.5)
end

function ANCIENT_CARD_COMBINE_END(guid,index)
	local frame = ui.GetFrame('ancient_card_list')
	frame:SetEnable(1)
	local tab = frame:GetChild("tab")
	AUTO_CAST(tab)
	index = tonumber(index)
	if index ~= tab:GetSelectItemIndex() then
		return;
	end
	local ctrlSet = GET_CHILD_RECURSIVELY(frame,"COMBINE_3")
	local card = session.ancient.GetAncientCardByGuid(guid)
	SET_ANCIENT_CARD_SLOT(ctrlSet,card)
	ctrlSet:Invalidate()
end

function ANCIENT_CARD_COMBINE_LIST_LOAD(frame)
	local ancient_card_list_Gbox = GET_CHILD_RECURSIVELY(frame,'ancient_card_list_Gbox')
	ancient_card_list_Gbox:RemoveAllChild()
	ancient_card_list_Gbox:SetEventScript(ui.DROP,"ANCIENT_CARD_SLOT_POP_COMBINE_BY_DROP")
	local slotBox = GET_CHILD_RECURSIVELY(frame,'ancient_card_slot_Gbox')
	INIT_ANCIENT_CARD_LIST_ALL(frame)
		end
--애드온 메세지
function ON_ANCIENT_CARD_ADD(frame,msg, guid)
	local pageCtrl = GET_CHILD_RECURSIVELY(frame,"card_page_control")
	local cnt = math.max(session.ancient.GetAncientCardCount(),1)
	local page_num = math.floor((cnt-1)/ANCIENT_PAGE_SIZE)+1
	if page_num ~= pageCtrl:GetMaxPage() then
		local now_page = pageCtrl:GetCurPage()
		pageCtrl:SetMaxPage(page_num)
		pageCtrl:SetCurPage(now_page)
	end

	local card = session.ancient.GetAncientCardByGuid(guid)
	if pageCtrl:GetMaxPage() == pageCtrl:GetCurPage()+1 then
		INIT_ANCIENT_CARD_LIST(frame,card)
		end
	local ancient_card_num = GET_CHILD_RECURSIVELY(frame,'ancient_card_num')
	ancient_card_num:SetTextByKey("count",session.ancient.GetAncientCardCount())
end

function ON_ANCIENT_CARD_RELOAD(frame)
	ANCIENT_CARD_LIST_TAB_CHANGE(frame)
end

function ON_ANCIENT_CARD_UPDATE(frame,msg, guid,slot)
	if msg == "ANCIENT_CARD_UPDATE_EXP" then
		local card = session.ancient.GetAncientCardByGuid(guid)
		ANCIENT_CARD_UPDATE(frame,card)
	elseif msg == "ANCIENT_CARD_COMBINE" or msg == "ANCIENT_CARD_EVOLVE" then
		ANCIENT_CARD_COMBINE_COMPLETE(frame,guid)
	end
	local ancient_card_num = GET_CHILD_RECURSIVELY(frame,'ancient_card_num')
	ancient_card_num:SetTextByKey("count",session.ancient.GetAncientCardCount())
end
--제거
function ON_ANCIENT_CARD_SELL(guid)
	local zoneName = session.GetMapName();
	if IS_ANCIENT_CARD_UI_ENABLE_MAP(zoneName) == false then
		addon.BroadMsg("NOTICE_Dm_!", ClMsg("ImpossibleInCurrentMap"), 3);
		return
	end
	local card = session.ancient.GetAncientCardByGuid(guid)
	if card.isLock == true then
		addon.BroadMsg("NOTICE_Dm_!", ClMsg("AncientCardLock"), 3);
		return
	end
	ReqSellAncientCard(guid)
end 

function SCR_ANCIENT_CARD_SELL(parent,ctrl)
	local guid = parent:GetUserValue("ANCIENT_GUID")
	local card = session.ancient.GetAncientCardByGuid(guid)
	
	local monClassName = card:GetClassName()
	local infoCls = GetClass("Ancient_Info",monClassName)
	local monName = '{#003399}{ol}'.. infoCls.Name ..'{/}{/}'.. '{ol}[{/}'
	
	for i = 1,card.starrank do
		monName = monName.. '{#ff6d00}{ol}★{/}{/}'
	end
	monName = monName..'{ol}]{/}'

	local rarityCls = GetClassByNumProp("Ancient_Rarity","Rarity",card.rarity)
	local str = ScpArgMsg("AncientSellMsg","monName",monName)
	local yesScp = string.format("ON_ANCIENT_CARD_SELL(\"%s\")", guid);
	local msgBox = ui.MsgBox(str, yesScp, "None");
	local yesBtn = GET_CHILD_RECURSIVELY(msgBox,"YES")
	yesBtn:SetClickSound('market_sell')
end

function ANCEINT_PASSIVE_LIST_SET(frame)
	local cardList = GetAncientMainCardList()
	local gBox = GET_CHILD_RECURSIVELY(frame,'ancient_card_comb_slots')
	gBox:RemoveAllChild()
	--고유 패시브
	local mainCard = session.ancient.GetAncientCardBySlot(0)
	if mainCard ~= nil then
		local infoCls = GetClass("Ancient_Info",mainCard:GetClassName())
		if infoCls ~= nil then
			local buffName = TryGetProp(infoCls, "StringArg1", "None")
			local buffCls = GetClass("Buff",buffName)
			ANCEINT_PASSIVE_SET(gBox,buffCls,1)
		end
	end
	--조합 패시브
	local comboList = GET_ANCIENT_COMBO_LIST(cardList)
	for i = 1,#comboList do
		local buff = comboList[i][1]
		local buffName = buff.BuffName
		local buffCls = GetClass("Buff",buffName)
		ANCEINT_PASSIVE_SET(gBox,buffCls,i+1)
	end
end

function ANCEINT_PASSIVE_SET(gBox,buffCls,index)
	local slot = gBox:CreateControl("slot", "COMBO_"..index, 35, 35, ui.LEFT, ui.TOP, 40*(index-1), 10, 0, 0);
	AUTO_CAST(slot)
	slot:EnableDrag(0)
	local icon = CreateIcon(slot)
	icon:SetImage("icon_"..buffCls.Icon)
	icon:SetTooltipType('buff');
	icon:SetTooltipArg(session.GetMyHandle(), buffCls.ClassID,0);
end

function ANCIENT_SET_COST(frame)
	local ancient_card_cost = GET_CHILD_RECURSIVELY(frame,'ancient_card_cost')
	local aObj = GetMyAccountObj()
	ancient_card_cost:SetTextByKey("max",aObj.ANCIENT_MAX_COST)
	local cost = 0
	for i = 0,ANCIENT_MAIN_SLOT_NUM-1 do
		local card = session.ancient.GetAncientCardBySlot(i)
		if card ~= nil then
			local ancientCls = GetClass("Ancient_Info",card:GetClassName())
			cost = cost + card:GetCost()
		end
	end
	ancient_card_cost:SetTextByKey("use",cost)
end

function GET_ANCIENT_COMBO_LIST(cardList)
	local comboList = {}
	local clsList,clsCount = GetClassList("ancient_combo")
	for i = 0,clsCount-1 do
		local comboCls = GetClassByIndexFromList(clsList, i);
		if comboCls.PreScript ~= nil and comboCls.PreScript ~= "None" then
			local preScript = _G[comboCls.PreScript]
			local slotList = preScript(comboCls,cardList)
			if slotList ~= "None" then
				slotList = StringSplit(slotList,'/')
				local cardList = {}
				for j = 1,#slotList do
					table.insert(cardList,session.ancient.GetAncientCardBySlot(slotList[j]))
				end
				table.insert(comboList,{comboCls,cardList})
			end
		end
	end
	return comboList
end

function OPEN_ANCIENT_CARD_GACHA_ONCLICK(parent,ctrl,argNum,argStr)
	local zoneName = session.GetMapName();
	if IS_ANCIENT_CARD_UI_ENABLE_MAP(zoneName) == false then
		addon.BroadMsg("NOTICE_Dm_!", ClMsg("ImpossibleInCurrentMap"), 3);
		return
	end
	ui.OpenFrame('ancient_card_gacha')
end

function ON_ANCIENT_CARD_LOCK_MODE()
	local frame = ui.GetFrame('ancient_card_list')
	local tab = frame:GetChild("tab")
	AUTO_CAST(tab)
	local index = tab:GetSelectItemIndex();
	if index ~= ANCIENT_INFO_TAB then
		addon.BroadMsg("NOTICE_Dm_scroll", ClMsg("AncientCardOnlyInfoTab"), 3);
		return
	end
	local isLockMode = frame:GetUserValue("LOCK_MODE") ~= "YES"
	_ANCIENT_CARD_LOCK_MODE(BoolToNumber(isLockMode))
end

function _ANCIENT_CARD_LOCK_MODE(isLockMode)
	local frame = ui.GetFrame('ancient_card_list')
	local nowMode = BoolToNumber(frame:GetUserValue("LOCK_MODE") == "YES")
	if nowMode == isLockMode then
		return
	end
	if isLockMode == 1 then
		frame:SetUserValue("LOCK_MODE","YES")
		ui.GuideMsg("AncientCardLockMsg");
		CHANGE_MOUSE_CURSOR("Lock", "Lock", "None");
		local scpScp = string.format("_ANCIENT_CARD_LOCK_MODE(%d)",0);
		ui.SetEscapeScp(scpScp);
	else
		frame:SetUserValue("LOCK_MODE","NO")
		ui.RemoveGuideMsg("AncientCardLockMsg");
		RESET_MOUSE_CURSOR();
		ui.SetEscapeScp("");
	end
	do
		local cnt = session.ancient.GetAncientCardCount()
		for i = 1,cnt do
			local card = session.ancient.GetAncientCardByIndex(i-1)
			local ctrlSet = GET_CHILD_RECURSIVELY(frame,"SET_"..card.slot)
			if ctrlSet ~= nil then
				SET_CARD_LOCK_MODE(ctrlSet, isLockMode == 1)
			end
		end
		for i = 0,ANCIENT_MAIN_SLOT_NUM-1 do
			local ctrlSet = GET_CHILD_RECURSIVELY(frame,"SLOT_"..i)
			if ctrlSet ~= nil then
				SET_CARD_LOCK_MODE(ctrlSet, isLockMode == 1)
			end
		end
	end
end

function SET_CARD_LOCK_MODE(ctrlSet,isLockMode)
	if isLockMode == true then
		ctrlSet:SetDragScp("None")
		ctrlSet:SetDragFrame("None")
		ctrlSet:SetEventScript(ui.LBUTTONDOWN,"REQ_ANCIENT_CARD_LOCK")
	else
		ctrlSet:SetDragScp("INIT_ANCEINT_FRAME_DRAG")
		ctrlSet:SetDragFrame("ancient_frame_drag")
		ctrlSet:SetEventScript(ui.LBUTTONDOWN,"None")
	end
end

function REQ_ANCIENT_CARD_LOCK(parent,ctrl,argNum,argStr)
	local frame = parent:GetTopParentFrame()
	if frame:GetUserValue("LOCK_MODE") ~= 'YES' then
		return
	end
	local guid = ctrl:GetUserValue("ANCIENT_GUID")
	if guid ~= nil and guid ~= 0 then
		ReqLockAncientCard(guid)
	end
end

function ON_ANCIENT_CARD_LOCK(frame,msg,guid)
	local card = session.ancient.GetAncientCardByGuid(guid)
	local ctrlSet = GET_CHILD_RECURSIVELY(frame,"SET_"..card.slot)
	do
	local slot = GET_CHILD_RECURSIVELY(ctrlSet,"ancient_card_slot")
	local remove = GET_CHILD_RECURSIVELY(ctrlSet,"sell_btn")
		remove:SetEnable(BoolToNumber(card.isLock ~= true))
		if card.isLock == true then
			local lock = slot:CreateOrGetControlSet('inv_itemlock', "itemlock", 0, 0);
			lock:SetGravity(ui.RIGHT, ui.TOP);
		else
			slot:RemoveChild("itemlock")
		end
	end
	for i = 0,ANCIENT_MAIN_SLOT_NUM-1 do
		local slotCtrlSet = GET_CHILD_RECURSIVELY(frame,"SLOT_"..i)
		local guid = slotCtrlSet:GetUserValue("ANCIENT_GUID")
		if guid == card:GetGuid() then
			local slot = GET_CHILD_RECURSIVELY(slotCtrlSet,"ancient_card_slot")
	if card.isLock == true then
		local lock = slot:CreateOrGetControlSet('inv_itemlock', "itemlock", 0, 0);
		lock:SetGravity(ui.RIGHT, ui.TOP);
	else
		slot:RemoveChild("itemlock")
	end
			break
		end
	end
end
--select -> 페이지컨트롤러, 텍스트, ' ', 페에지
--prev,next,prevunit,nextunit ->  페이지컨트롤러, 버튼, ' ', 0
function ANCIENT_CARD_LIST_PAGE_SELECT(pageCtrl,ctrl)
	local page = pageCtrl:GetCurPage()
	if page > pageCtrl:GetMaxPage()-1 then
		pageCtrl:SetCurPage(pageCtrl:GetMaxPage()-1)
		return
	elseif page < 0 then
		pageCtrl:SetCurPage(0)
		return
	end
	INIT_ANCIENT_CARD_LIST_ALL(pageCtrl:GetTopParentFrame())
end

function ANCIENT_GET_COST(card)
	return card.starrank * card.rarity
end

function ANCIENT_SLOT_EXTEND_BTN_CLICK(parent, ctrl)
    local mapClsName = session.GetMapName()
    local mapCls = GetClass('Map', mapClsName)
    if TryGetProp(mapCls, 'MapType', 'None') ~= 'City' then
        ui.SysMsg(ClMsg('AllowedInTown'))
        return
	end
	
	local extend_cost = GET_ANCIENT_SLOT_EXTEND_COST()
	if extend_cost == nil then
		ui.SysMsg(ClMsg('CantExtendAncientCardSlot'))
	else
		local extend_cnt = GET_ANCIENT_SLOT_EXTEND_COUNT()
		local msg = ScpArgMsg('ExtendWarehouseSlot{Silver}{SLOT}', 'Silver', GET_COMMAED_STRING(tostring(extend_cost)), 'SLOT', extend_cnt)
		local msgbox = ui.MsgBox(msg, '_EXEC_ANCIENT_SLOT_EXTEND()', 'None')
		SET_MODAL_MSGBOX(msgbox)
	end
end

function _EXEC_ANCIENT_SLOT_EXTEND()
	local extend_cost = tostring(GET_ANCIENT_SLOT_EXTEND_COST())
	local my_money = GET_TOTAL_MONEY_STR()
	if IsGreaterThanForBigNumber(extend_cost, my_money) == 1 then
		ui.SysMsg(ClMsg('NotEnoughMoney'))
		return
	end

	local argStr = ""
	pc.ReqExecuteTx("SCR_TX_ANCIENT_SLOT_EXTEND", argStr)
end