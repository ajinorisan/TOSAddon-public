-- --dont use in on_init;



-- --------------------------local function start
-- local function GET_CUPOLE_REINFORCE_SLOT()
--     local cupole_reinforce = ui.GetFrame("cupole_reinforce");
--     if cupole_reinforce == nil then
--         return nil;
--     end
--     local managerTab = GET_CHILD(cupole_reinforce,"managerTab");
--     if managerTab == nil then
--         return nil;
--     end
--     local reinforceItem = GET_CHILD_RECURSIVELY(managerTab,"reinforceItem");
--     if reinforceItem == nil then
--         return nil;
--     end
--     return reinforceItem;
-- end

-- local function CUPOLE_CHECK_VALIDNUMBER(count)
--     local frame = ui.GetFrame("cupole_reinforce")
-- 	if frame == nil then 
-- 		return 0 
-- 	end
--     if count < 0 then
--         return 0;
--     end

--     local item_guid = tonumber(frame:GetUserValue("mat_guid"));
--     local inv_item = session.GetInvItemByGuid(item_guid)
--     if inv_item == nil then
--         return 0;
--     end

--     if inv_item.count <= count then
--         return inv_item.count;
--     end

--     return count;
-- end

-- local function GET_CUPOLE_MULTI_COUNT()
-- 	local frame = ui.GetFrame("cupole_reinforce")
-- 	if frame == nil then 
-- 		return 0 
-- 	end
	
-- 	local item_count = GET_CHILD_RECURSIVELY(frame, 'item_count')
	
-- 	if item_count == nil then 
-- 		return 0 
-- 	end
-- 	local count = tonumber(item_count:GetText())
	
-- 	return CUPOLE_CHECK_VALIDNUMBER(count);
-- end
-- ---------------------------local function end

-- --------------------default function start

-- function CUPOLE_REINFORCE_ON_INIT(addon,frame)
-- end

-- function OPEN_CUPOLE_REINFORCE()
--     local frame = ui.GetFrame("cupole_reinforce");
--     if frame == nil then
--         return;
--     end
--     local pc = GetMyPCObject();
--     if pc == nil then
--         return;
--     end
--     local acc = GetMyAccountObj(pc);
--     if acc == nil then
--         return;
--     end
--     local AccProp = GET_GLOBAL_SELECT_CUPOLE_ACCOUNTPROP()
--     local CupoleExp = TryGetProp(acc, AccProp, 0);
--     local Lv, Exp, reqExp = shared_cupole.get_exp_pair(CupoleExp);

--     SET_CUPOLE_ICON(frame)
--     SET_INIT_INFO(frame)
--     CUPOLE_ITEM_COUNT_TEXT_UPDATE(frame, 0);
--     CUPOLE_REINFORCE_GAUGE(frame, Exp, reqExp);
-- end

-- function CLOSE_CUPOLE_REINFORCE()
--     local frame = ui.GetFrame("cupole_reinforce");
--     if frame == nil then
--         return;
--     end
--     -- local slot = GET_CHILD_RECURSIVELY(frame,"reinforceItem");
--     -- slot:SetUserValue("mat_guid", 0);
-- end

-- ---------------------default function end


-- ---------------------- btn script start
-- function CUPOLE_ITEM_COUNT_UP_BTN(frame, btn, argStr, argNum)
--     local count = GET_CUPOLE_MULTI_COUNT();
--     if argStr == "max" then
--         local maxcnt = CUPOLE_CHECK_VALIDNUMBER(9999)
--         CUPOLE_ITEM_COUNT_TEXT_UPDATE(frame, maxcnt)
--     else
--         CUPOLE_ITEM_COUNT_TEXT_UPDATE(frame, count + 1)
--     end
-- end

-- function CUPOLE_ITEM_COUNT_DOWN_BTN(frame, btn, argStr, argNum)
--     local count = GET_CUPOLE_MULTI_COUNT();
--     if argStr == "min" then
--         CUPOLE_ITEM_COUNT_TEXT_UPDATE(frame, 0)
--     else
--         CUPOLE_ITEM_COUNT_TEXT_UPDATE(frame, count - 1);
--     end
-- end

-- -- 선물 선택
-- function EVENT_CUPOLE_GIFTITEM_CLICK(frame, ctrl, argStr, argNum)
--     local TopParentFrame = frame:GetTopParentFrame();
--     local ItemList = GET_CHILD_RECURSIVELY(TopParentFrame, "ItemList")
--     TopParentFrame:SetUserValue("mat_guid", argStr);
--     --다른 것들 색 빼기
--     SELECT_FRAME_CHANGE_STATE(ItemList , nil, 1, "FFFFFFFF");
--     --색 칠하기
--     FRAME_COLOR_CHANGE(frame, "FFFFCC33");
--     --텍스트 상자 초기화
--     CUPOLE_ITEM_COUNT_TEXT_UPDATE(TopParentFrame, 0)
-- end

-- --고를 수 없는 선물
-- function EVET_CUPOLE_GIFITEM_EMPTY_ALRET(frame, ctrl, argStr, argNum)
--     local TopParentFrame = frame:GetTopParentFrame();
--     ---보유한 재화가 없습니다. 알람 보내기
--     ui.SysMsg(ClMsg("MaterialItemIsLock"));
--     CUPOLE_ITEM_COUNT_TEXT_UPDATE(TopParentFrame, 0)
-- end

-- --선물을 주는 버튼 눌렀을 때
-- function EVENT_CUPOLE_GIFTITEM_GIVE_A_ITEM(frame, ctrl, argStr, argNum)
--     local TopParentFrame = frame:GetTopParentFrame();
--     local SelectItemName = TopParentFrame:GetUserValue("SEL_GIFT");
--     local mat_guid = TopParentFrame:GetUserValue("mat_guid");

--     local Count = GET_CUPOLE_MULTI_COUNT();

--     local managerTab = GET_CHILD(frame,"managerTab");
--     local item_count = GET_CHILD_RECURSIVELY(frame,"item_count");

-- 	session.ResetItemList()
    
-- 	if mat_guid == '0' then return end

-- 	local mat_item = session.GetInvItemByGuid(mat_guid)
-- 	if mat_item == nil then return end

-- 	if item_count == nil then return end
	
-- 	local cur_count = tonumber(item_count:GetText())
-- 	if cur_count ~= nil and cur_count > 0 then
-- 	    session.AddItemID(mat_guid, cur_count)
--     end

-- 	local msg = ClMsg('REALLY_DO_RELIC_EXP')
-- 	local yesScp = '_CUPOLE_EXP_EXEC()'
-- 	local msgbox = ui.MsgBox(msg, yesScp, 'None')
-- 	SET_MODAL_MSGBOX(msgbox)

-- end
-- ---------------------- btn script end


-- ---------------------- script start
-- function _CUPOLE_EXP_EXEC()
-- 	local result_list = session.GetItemIDList()
--     local arg_list = NewStringList()
--     --#kdh 수정 필요
--     local AccountProp = GET_GLOBAL_SELECT_CUPOLE_ACCOUNTPROP();
--     arg_list:Add(AccountProp);
-- 	item.DialogTransaction('CUPOLE_EXP_UP', result_list, '', arg_list)
-- end


-- function CUPOLE_REINFORCE_GAUGE(frame, Exp, MaxExp)
--     if frame == nil then
--         return;
--     end
--     local managerTab = GET_CHILD(frame,"managerTab");
--     local exp_gauge = GET_CHILD_RECURSIVELY(managerTab,"exp_gauge");
--     if exp_gauge == nil then
--         return;
--     end
--     exp_gauge:SetPoint(Exp,MaxExp);
-- end

-- function 

-- function CUPOLE_ITEM_COUNT_TEXT_UPDATE(text, count)
--     if text == nil then
--         return 0;
--     end
--     local item_count = GET_CHILD_RECURSIVELY(text,"item_count");
--     if item_count == nil then
--         return 0;
--     end
--     local AfterCount = CUPOLE_CHECK_VALIDNUMBER(count);
--     item_count:SetText(AfterCount);
-- end

-- function CUPOLE_ITEM_COUNT_TEXT_TYPING(frame, ctrl, argStr, argNum)
-- 	local count = tonumber(ctrl:GetText());
-- 	if count == nil then
-- 		return
-- 	end
-- 	CUPOLE_ITEM_COUNT_TEXT_UPDATE(frame,count);
-- end

-- function CUPOLE_PORTRAIT_UPDATE(frame,cupole_cls)
--     local portrait = GET_CHILD_RECURSIVELY(frame, "portrait");
--     if portrait == nil then
--         return;
--     end
--     if cupole_cls == nil then
--         return ;
--     end

--     local IconName = TryGetProp(cupole_cls, "Icon", "None");
--     portrait:SetImage(IconName)
-- end



-- ---------------------- script end


-- -----set---

-- function SET_CUPOLE_ICON(frame)
--     local infoGB = GET_CHILD_RECURSIVELY(frame, "infoGB")
--     local CupoleRichText = GET_CHILD_RECURSIVELY(infoGB, "CupoleRichText")
--     local cupole_slot = infoGB:CreateOrGetControlSet('cupole_slot', "reinforce_cupole_slot", 0, 50);
--     cupole_slot:SetGravity(ui.CENTER_HORZ, ui.TOP)

--     local select_cupole_index = GET_GLOBAL_SELECT_CUPOLE()
--     local cupole_cls = GET_CUPOLE_CLASS_BY_INDEX(select_cupole_index);
--     SET_SLOT_CUPOLE_INFO(cupole_slot, tonumber(select_cupole_index))
--     local Name = TryGetProp(cupole_cls, "Dec_Name", "None");
--     CupoleRichText:SetTextByKey("value", Name);
-- end

-- function SET_INIT_INFO(frame)
--     local ItemList = GET_CHILD_RECURSIVELY(frame,"ItemList");
--     local giftitemlist, cnt = GetClassList("cupole_giftitem");

--     local initX = 10
--     local initY = 10
--     local Offset = {115, 115}
--     local max = 3;
--     for i = 0, cnt - 1 do
--         local cls = GetClassByIndexFromList(giftitemlist, i);
--         if cls ~= nil then
--             local ctrlset = ItemList:CreateOrGetControlSet("mat_required_cupole_gift", "mat_required_cupole_gift"..i, initX + (i % 3) * Offset[1], initY + math.floor(i / 3) * Offset[2]);
--             local mat_slot = GET_CHILD_RECURSIVELY(ctrlset, "mat_slot")
--             local cnt_in_my_bag = GET_CHILD_RECURSIVELY(ctrlset, "cnt_in_my_bag")

--             local Tags = TryGetProp(cls, "Tags", "None")
--             local ItemClassName = TryGetProp(cls, "ClassName", "None")
--             local mat_cls = GetClassByNameFromList(item_list, ItemClassName)
--             local curr_my_cnt = GET_INV_ITEM_COUNT_BY_PROPERTY({
--                 { Name = 'ClassName', Value = ItemClassName }
--             }, false)

--             local icon = imcSlot:SetImage(mat_slot,TryGetProp(mat_cls,"Icon","None"))
--             SET_ITEM_TOOLTIP_BY_NAME(icon, mat_cls.ClassName)
--             icon:SetTooltipOverlap(1)   
            
--             cnt_in_my_bag:SetTextByKey("value", curr_my_cnt);
--             SET_GIFTITEM_LIKE_STATE(ctrlset, Tags);

--             if curr_my_cnt > 0 then
--                 local mat_item = session.GetInvItemByName(ItemClassName)
--                 local mat_guid = mat_item:GetIESID()
--                 mat_slot:SetEventScript(ui.LBUTTONUP, "EVENT_CUPOLE_GIFTITEM_CLICK")
--                 mat_slot:SetEventScriptArgString(ui.LBUTTONUP, mat_guid)
--             else
--                 mat_slot:SetEventScript(ui.LBUTTONUP, "EVET_CUPOLE_GIFITEM_EMPTY_ALRET")
--             end

--         end
--     end

-- end


-- function SET_GIFTITEM_LIKE_STATE(ctrl, itemtag)
--     if ctrl == nil then
--         return;
--     end
--     local LikeImg = GET_CHILD_RECURSIVELY(ctrl, "Like")
--     local cupoleindex = GET_GLOBAL_SELECT_CUPOLE()
--     local cupolecls = GET_CUPOLE_CLASS_BY_INDEX(cupoleindex)
--     if cupolecls == nil then
--         return;
--     end
--     local LikeTag = TryGetProp(cupolecls, "Like_Tag", "None");
--     local DislikeTag = TryGetProp(cupolecls, "Dislike_Tag", "None");

--     local taglist = StringSplit(itemtag, "/")

--     for k,v in pairs(taglist) do
--         if LikeTag == v then
--             LikeImg:SetImage("icon_smile_up")
--         elseif DislikeTag == v then
--             LikeImg:SetImage("icon_smile_down")
--         end
--     end
-- end

-- -----set-----end