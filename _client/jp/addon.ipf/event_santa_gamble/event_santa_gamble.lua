-- Constants
local GACHA_UI_CONFIG = {
    SLOT_OFFSET = { 95, 95 },
    MAX_COLUMNS = 4,
    DEFAULT_POSITION = { 270, 200 },
    FLOW_SPEED = 35,
	EFFECT_DELAY = 0.1,
    EFFECT = {
        DURATION = 0.5,
        SCALE = {
            SMALL = nil,  -- 실제 값으로 설정 필요
            MEDIUM = nil  -- 실제 값으로 설정 필요
        }
    }
}

local is_ui_event_over = false;
local is_server_event_over = false;
function EVENT_SANTA_GAMBLE_ON_INIT(addon, frame)
    addon:RegisterMsg("OPEN_DLG_EVENT_SANTA_GAMBLE", "ON_OPEN_SANTA_GAMBLE");
    addon:RegisterMsg("EVENT_GAMBLE_RESULT", "ON_EVENT_GAMBLE_RESULT");
	addon:RegisterMsg('NOTICE_Dm_Clear_Time', 'SET_EVENT_GAMBLE_TIME');
	addon:RegisterMsg('RESET_CURRENT_GACHA_STEP', '_RESET_CURRENT_GACHA_STEP');
end

-- Gacha Type Management
GachaTypeManager = {
    INDUN = 0,
    VILLAGE = 1,
    
    COST_POLICY = {
        PAPAYA = {
            [1] = 0,    
            [2] = 0,    
            [3] = 30000,
            [4] = 50000,
            [5] = 70000 
        }
    }
}

-- 메서드 추가
function GachaTypeManager.getTypeConfig(type)
    local serverNation = config.GetServiceNation();
    
    if type == GachaTypeManager.INDUN then
        return {
            costIcon = "icon_item_pvpmine_2",
            getCost = function(step) 
                if serverNation == "PAPAYA" then
                    return GachaTypeManager.COST_POLICY.PAPAYA[step] or 0
                else
                    return (step == 5) and 50000 or ((step - 1) * 10000)
                end
            end,
            validateLocation = function(pc)
                local cmd = GetMGameCmd(pc)
                return IS_EVENT_2411_SANTA_NPC_CREATED(cmd)
            end
        }
    else
        return {
            costIcon = "icon_item_tenthanni",
            getCost = function() return 1 end,
            validateLocation = function(pc)
                return IS_IN_CITY_SERVER(pc)
            end
        }
    end
end

function GachaTypeManager.calculateCost(step, type)
    local serverNation = GetServerNation()
    if type == GachaTypeManager.INDUN then
        if serverNation == "PAPAYA" then
            return GachaTypeManager.COST_POLICY.PAPAYA[step] or 0
        else
            return (step == 1) and 0 or ((step - 1) * 20000)
        end
    else
        return 1
    end
end

function SET_EVENT_GAMBLE_TIME(frame, msg, argstr, argnum)
	frame:Invalidate(); 

	local GambleType = GET_EVENT_GAMBLE_TYPE(frame)

	if argstr == "RemainTime" then
		if GambleType == 1 then
			SET_REMAIN_TIME(frame, argnum, 0)
		else
			SET_REMAIN_TIME(frame, argnum, 1)
		end
	end
	frame:SetUserValue("RemainTime", argnum);

    if frame:HaveUpdateScript("_UPDATE_SANTA_GAMBLE_REMAIN_TIME") == true then
        return;
	end

	frame:RunUpdateScript('_UPDATE_SANTA_GAMBLE_REMAIN_TIME', 1, 300, 0, 1)
end

function CLOSE_EVENT_SANTA_GAMBLE()
	ui.CloseFrame('event_santa_gamble')
end

function CLOSE_SANTA_GAMBLE()
	control.EnableControl(1);
	local frame = ui.GetFrame('event_santa_gamble')
	frame:StopUpdateScript("_UPDATE_SANTA_GAMBLE_REMAIN_TIME");
end

function GET_EVENT_GAMBLE_TYPE(frame)
	local GambleType = frame:GetUserIValue("GambleType")
	return GambleType;
end

function ON_OPEN_SANTA_GAMBLE(frame, msg, argstr, argnum)
	if frame:IsVisible() == 1 then
		ui.CloseFrame('event_santa_gamble')
	end
	
    ui.OpenFrame('event_santa_gamble');

	local text_gb = GET_CHILD(frame, "text_gb")
	-- DIALOG_TEXTVIEW(text_gb, msg, "W_SANTA_2411_DL_INTRO")
	-- frame:SetUserValue("DialogType", 1);
	ILLSUT_SET(frame, "W_SANTA_2411_DL_INTRO")
	CREATE_ITEM_SLOT(frame)
end

function OPEN_SANTA_GAMBLE(type)
	local frame = ui.GetFrame('event_santa_gamble')
	control.EnableControl(0);

	if frame:IsVisible() == 1 then
		ui.CloseFrame('event_santa_gamble')
	end
	
	if type == 'indun' then
		frame:SetUserValue("GambleType", 0)
		SET_GACHA_PROBABILITY_TYPE(frame, 2)
		SET_REMAIN_TIME(frame, 0, 1)
		SET_CAUTIONTEXT(frame, 0)
	else
		frame:SetUserValue("GambleType", 1)
		SET_GACHA_PROBABILITY_TYPE(frame, 4)
		SET_REMAIN_TIME(frame, 0, 0)
		SET_CAUTIONTEXT(frame, 1)
	end

    ui.OpenFrame('event_santa_gamble');

	local text_gb = GET_CHILD(frame, "text_gb")
	ILLSUT_SET(frame, "W_SANTA_2411_DL_INTRO")
	CREATE_ITEM_SLOT(frame)
	DIALOG_SET(frame, "W_SANTA_2411_DL_INTRO")
	local text_main_gb = GET_CHILD_RECURSIVELY(frame, "text_main_gb");
    pc.ReqExecuteTx_Item("EVENT_GAHCA_START", 0, 512)
end

function ILLSUT_SET(frame, argStr)
	local DialogTable		= GetClass( 'DialogText', argStr);
	if DialogTable == nil then
		local dd = string.find(argStr, "\\");
		if dd ~= nil then
			argStr = string.sub(argStr, 1, dd - 1);
			DialogTable		= GetClass( 'DialogText', argStr);	
		end
	end
	
	local imgObject = frame:GetChild('dialogimage');
	if nil ~= imgObject then
		tolua.cast(imgObject, 'ui::CPicture');
		if DialogTable ~= nil and DialogTable.ImgName ~= 'None' then
			imgObject:SetImage(DialogTable.ImgName);	
		else
			imgObject:SetImage("");
		end
	end

end

function CREATE_ITEM_SLOT(frame)
	local pc = GetMyPCObject()
    if not pc then
        return;
    end
    local acc = GetMyAccountObj(pc);
    if not acc then
        return;
    end
	local GachaStepList = GET_STEP_GACHA_CLS(pc, 1)
	local gambletype = GET_EVENT_GAMBLE_TYPE(frame)
	local GachaStepCurList, ratiolist, step;
	local CurStep = frame:GetUserIValue("CurStep")

    local typeConfig = GachaTypeManager.getTypeConfig(gambletype)
	local cost = typeConfig.getCost(CurStep);
	local itemIcon = typeConfig.costIcon;
	
	if gambletype == 0 then
		GachaStepCurList, ratiolist, step = GET_STEP_GACHA_CLS_LIST(pc, CurStep)		
		SET_GACHA_TEXT(frame, itemIcon,cost);
	else
		local mat_cls = GetClassByNameFromList(item_list, "Event_2512_santaticket")
		curr_my_cnt, itemlist = GET_INV_ITEM_COUNT_BY_PROPERTY({
			{ Name = 'ClassName', Value = "Event_2512_santaticket" }
		}, false)
	
		GachaStepCurList = GET_STEP_GACHA_CLS(pc, 1)
		SET_GACHA_TEXT(frame, itemIcon, curr_my_cnt);
	end
	
	local maingb = frame:GetChild("main_gb")
	local item_gb = GET_CHILD(maingb, "item_gb")

	
	if not maingb or not item_gb then
		return;
	end

	local x = 0
	local y = 0;
	local offset = {95, 95};
	local maxcol = 4;
	local defaultpos = {270, 200};
	for index, cls in pairs(GachaStepList) do
		local itemname = TryGetProp(cls, "ItemName", "None")
		local itemcount = TryGetProp(cls, "Count", 0)
		local ctrl = item_gb:CreateOrGetControlSet('santa_slot', 'slot'..index, x + defaultpos[1] ,y + defaultpos[2]);
		
		local itemslot = GET_CHILD_RECURSIVELY(ctrl, "item_slot");
		local remina_text = GET_CHILD_RECURSIVELY(ctrl, "remina_text");

		local itemCls = GetClass("Item", itemname);
		SET_SLOT_ITEM_INFO(itemslot, itemCls, itemcount,'{s20}{ol}{b}{ds}', -11, -10);  
		SET_SLOT_STAR_TEXT(itemslot, itemCls)

		x = (offset[1] * (index % maxcol));
		y = offset[2] * math.floor(index / maxcol);

		remina_text:SetTextByKey("cur", itemcount);
		local item_frame_effect = GET_CHILD_RECURSIVELY(ctrl, "item_frame_effect")
		item_frame_effect:ShowWindow(0)

		if index > #GachaStepCurList then
			SET_SOLDOUT_FRAME(ctrl, 1);
		else
			SET_SOLDOUT_FRAME(ctrl, 0);
		end
	end
end

function REFRESH_GAMBLE_LIST(frame, index)
	local pc = GetMyPCObject()
    if not pc then
        return;
    end

	local GachaStepList = GET_STEP_GACHA_CLS(pc, 1)
	local GachaStepCurList = GET_STEP_GACHA_CLS(pc, index)

	local maingb = frame:GetChild("main_gb")
	local item_gb = GET_CHILD(maingb, "item_gb")

	
	if not maingb or not item_gb then
		return;
	end

	local x = 0
	local y = 0;
	local offset = {95, 95};
	local maxcol = 4;
	local defaultpos = {270, 200};
	for index, cls in pairs(GachaStepList) do
		local itemname = TryGetProp(cls, "ItemName", "None")
		local itemcount = TryGetProp(cls, "Count", 0)
		local ctrl = item_gb:CreateOrGetControlSet('santa_slot', 'slot'..index, x + defaultpos[1] ,y + defaultpos[2]);
		
		local itemslot = GET_CHILD_RECURSIVELY(ctrl, "item_slot");
		local remina_text = GET_CHILD_RECURSIVELY(ctrl, "remina_text");

		local itemCls = GetClass("Item", itemname);
		SET_SLOT_ITEM_INFO(itemslot, itemCls, itemcount,'{s20}{ol}{b}{ds}', -11, -10);  
		SET_SLOT_STAR_TEXT(itemslot, itemCls)

		x = (offset[1] * (index % maxcol));
		y = offset[2] * math.floor(index / maxcol);

		remina_text:SetTextByKey("cur", itemcount);
		local item_frame_effect = GET_CHILD_RECURSIVELY(ctrl, "item_frame_effect")
		item_frame_effect:ShowWindow(0)

		if index > #GachaStepCurList then
			SET_SOLDOUT_FRAME(ctrl, 1);
		else
			SET_SOLDOUT_FRAME(ctrl, 0);
		end
	end

end

function DIALOG_SET(frame, dialog)
	-- frame:Invalidate();
	local appsFrame = ui.GetFrame('apps');
	if appsFrame ~= nil and appsFrame:IsVisible() == 1 then
		ui.CloseUI(1);
	end
    -- ui.ShowChatFrames(0);
	-- DIALOG_TEXT_SET(frame, dialog)
	frame:ShowWindow(1);
	-- frame:SetUserValue("DialogType", 3);



-- 	if msg == 'DIALOG_CLOSE' then
--         local textBoxObj	= frame:GetChild('textbox');
-- 		local textObj		= frame:GetChild('textlist');
-- 		textObj:ClearText();
--         tolua.cast(textBoxObj, 'ui::CGroupBox')

-- 		frame:ShowWindow(0);
-- 		frame:SetUserValue("DialogType", 0);

-- 		local uidirector = ui.GetFrame('directormode');
-- 		if uidirector:IsVisible() == 1 then
-- 			return;
-- 		else
-- --			ui.OpenFrame('quickslotnexpbar');
-- --			ui.OpenFrame('minimap');
-- 		end
-- 	end

	-- ui.SetEscapeScp("");
end

function DIALOG_TEXT_SET(frame, argStr)
	local npcDialog = nil;
	local DialogTable = GetClass('DialogText', argStr);
	g_lastClassName = argStr;

	local text = "";
	local voiceName = "None";
	local titleName = nil;
	if DialogTable == nil then
		local dd = string.find(argStr, "\\");
		if dd ~= nil then
			local npcName = string.sub(argStr, 1, dd - 1);
			npcDialog = GetClass( 'DialogText', npcName);

			local dd = string.find(argStr, "\\");
			argStr = string.sub(argStr, dd + 1);
		end

		dd = string.find(argStr, "*@*");
		local tokenList  = TokenizeByChar(argStr, "*@*");
		if #tokenList == 2 then
			titleName = tokenList[1];
			argStr = tokenList[2];
		end
	end
	
	if DialogTable ~= nil then
		text = DialogTable.Text;
	else
		text = argStr;
	end
    text = ui.HighlightText(text, "{#003399}", argStr)

	if DialogTable ~= nil then
		if DialogTable.Caption ~= 'None' then
			if DialogTable.Caption == 'GET_PC_NAME' then
				local pc = GetMyPCObject()
				local pc_name = TryGetProp(pc, 'Name')
				titleName = pc_name;
			else
				titleName = DialogTable.Caption;
			end
		else
		    titleName = '';
		end

		voiceName = DialogTable.VoiceName
	elseif npcDialog ~= nil then

		if npcDialog.Caption ~= 'None' then
			if npcDialog.Caption == 'GET_PC_NAME' then
				local pc = GetMyPCObject()
				local pc_name = TryGetProp(pc, 'Name')
				titleName =  pc_name;
			else
				titleName =  npcDialog.Caption;
			end
		else
			titleName =  '';
		end
		voiceName = npcDialog.VoiceName
	end
	DIALOG_SHOW_TEXT(frame, text, titleName, voiceName);
end

function DIALOG_SHOW_TEXT(frame, text, titleName, voiceName)
    local textObj = GET_CHILD_RECURSIVELY(frame, "textlist", "ui::CFlowText");
    local npcname = GET_CHILD_RECURSIVELY(frame, "npcname", "ui::CFlowText");
    local text_title_gb = GET_CHILD_RECURSIVELY(frame, "text_title_gb");


	
	
	textObj:SetText(" ");

	local dialogFrame = ui.GetFrame('event_santa_gamble');
	tolua.cast(dialogFrame, "ui::CFrame");

	-- if titleName == nil then
	-- 	dialogFrame:ShowTitleBar(0);
	-- else
	-- 	dialogFrame:ShowTitleBar(1);
	-- 	
	-- end
	npcname:SetTextByKey('value','{s20}{ol}{gr gradation2}  '..titleName..'  {/}');
	local height = text_title_gb:GetHeight()
	local length = npcname:GetTextWidth() + 58;
	local spaceObj = GET_CHILD_RECURSIVELY(dialogFrame, "space", "ui::CAnimPicture");
	text_title_gb:Resize(length, height)
	spaceObj:PlayAnimation();

	local ViewText = string.format('{s20}{b}{#1f100b}' .. text);
	textObj:ClearText();
	textObj:SetText(ViewText);
	textObj:SetVoiceName(voiceName);
    textObj:SetFontName('dialog');
	textObj:SetNextPageFont(string.format('{s20}{b}{#1f100b}'));
	textObj:SetFlowSpeed(35);

end


function SCR_GAHCA_START_BTN(frame, parent, str, num)
	local mypc = GetMyPCObject()
    if not mypc then
        return;
    end
    local acc = GetMyAccountObj(mypc);
    if not acc then
        return;
    end
	local TopParentFrame = frame:GetTopParentFrame()
	local CurStep = TopParentFrame:GetUserIValue("CurStep")

	local GachaStepList, ratiolist, step = GET_STEP_GACHA_CLS_LIST_BY_INDEX(mypc, CurStep)
	local tokencnt = TryGetProp(acc, "MISC_PVP_MINE2", 0)
	local GambleType = TopParentFrame:GetUserIValue("GambleType")

    local typeConfig = GachaTypeManager.getTypeConfig(GambleType)
	local cost = typeConfig.getCost(CurStep);


	local mat_cls = GetClassByNameFromList(item_list, "Event_2512_santaticket")
    curr_my_cnt, itemlist = GET_INV_ITEM_COUNT_BY_PROPERTY({
        { Name = 'ClassName', Value = "Event_2512_santaticket" }
    }, false)

	local mat_guid = 0;
	if GambleType == 1 and curr_my_cnt > 0 then
		local mat_item = itemlist[1];
		if mat_item ~= nil then
			mat_guid = mat_item:GetIESID();
		end
	
	elseif GambleType == 1 and curr_my_cnt <= 0 then
		--send msg
		ui.SysMsg(ScpArgMsg("{item}NotEnoughMaterial","item", mat_cls.Name));
		return;
	elseif GambleType == 0 then
		if step > 5 then
			ui.SysMsg(ClMsg("Excnaged_No_Enough"));
			return;
		end
		if tonumber(tokencnt) < cost then
			ui.SysMsg(ScpArgMsg("{item}NotEnoughMaterial","item", ClMsg("MISC_PVP_MINE2")));

			return;
		end
	end
    pc.ReqExecuteTx_Item("EVENT_GAHCA_START", mat_guid, GambleType)
	PLAY_GACHA_RANDOM_SLOT_EFFECT()
	TOGGLE_GACHA_BTN(frame, 0)
end

function SCR_GACHA_OPEN_GACHA_PROBAILITY(frame, parent, str, num)
	ui.ToggleFrame("leticia_probability")
end

function PLAY_GACHA_RANDOM_SLOT_EFFECT(frame, msg, class_name, itemCount)
	local pc = GetMyPCObject()
    if not pc then
        return;
    end
    local acc = GetMyAccountObj(pc);
    if not acc then
        return;
    end
	local mainframe = ui.GetFrame("event_santa_gamble");
	local CurStep = mainframe:GetUserIValue("CurStep")

	local gambletype = GET_EVENT_GAMBLE_TYPE(mainframe)
	local GachaStepList, ratiolist, step = GET_STEP_GACHA_CLS_LIST_BY_INDEX(pc, CurStep)
    local typeConfig = GachaTypeManager.getTypeConfig(gambletype)
	local cost = typeConfig.getCost(CurStep);
	local itemIcon = typeConfig.costIcon;

	if gambletype == 0 then
		-- GachaStepList = GET_STEP_GACHA_CLS_LIST(pc, acc)
		SET_GACHA_TEXT(mainframe, itemIcon, cost);
	else
		local mat_cls = GetClassByNameFromList(item_list, "Event_2512_santaticket")
		curr_my_cnt, itemlist = GET_INV_ITEM_COUNT_BY_PROPERTY({
			{ Name = 'ClassName', Value = "Event_2512_santaticket" }
		}, false)

		GachaStepList = GET_STEP_GACHA_CLS(pc, 1)
		SET_GACHA_TEXT(mainframe, itemIcon, curr_my_cnt);
	end

	local item_gb = GET_CHILD_RECURSIVELY(mainframe, "item_gb")
	local child_cnt = #GachaStepList - 1
	local randlist = GET_RANDOM_SORT_LIST(child_cnt)
	local sec = 0;
	local secFactor = 0.1;
	local RESULT_EFFECT_DURATION = tonumber(mainframe:GetUserConfig('RESULT_EFFECT_DURATION'));

	for i = 1, child_cnt do
		local ctrl = GET_CHILD(item_gb, 'slot'..randlist[i])

		ctrl:ReserveScript("_PLAY_SATAN_RESULT_EFFECT", secFactor * i, i, "");

		ctrl:ReserveScript("_EVENT_SANTA_RESULT_EFFECT", RESULT_EFFECT_DURATION + secFactor * i, i, "");
	end

	mainframe:ReserveScript("REFRESH_GACHA_BTN", secFactor * child_cnt + RESULT_EFFECT_DURATION, 0, "");
end

function _PLAY_SATAN_RESULT_EFFECT(ctrl, argnum, argstr)
	local mainframe = ui.GetFrame("event_santa_gamble");

	local RESULT_EFFECT_NAME = mainframe:GetUserConfig('RESULT_EFFECT');
	local RESULT_EFFECT_SCALE_S = tonumber(mainframe:GetUserConfig('RESULT_EFFECT_SCALE_S'));
	local RESULT_EFFECT_SCALE_M = tonumber(mainframe:GetUserConfig('RESULT_EFFECT_SCALE_M'));

	ctrl:PlayUIEffect(RESULT_EFFECT_NAME, RESULT_EFFECT_SCALE_S, 'RESULT_EFFECT');
	local item_frame_effect = GET_CHILD_RECURSIVELY(ctrl, "item_frame_effect")
	item_frame_effect:ShowWindow(1)
end	

function _EVENT_SANTA_RESULT_EFFECT(ctrl, argnum, argstr)
	ctrl:StopUIEffect("RESULT_EFFECT", true, 0.5);
	local item_frame_effect = GET_CHILD_RECURSIVELY(ctrl, "item_frame_effect")
	item_frame_effect:ShowWindow(0)

end

function _EVENT_SANTA_GACHA_DELAY_FLUSH(frame, argnum, argstr)
	if is_ui_event_over == false or is_server_event_over == false then
		return;
	end
	is_ui_event_over = false;
	is_server_event_over = false;

    ui.FlushGachaDelayPacket();
	local ItemName = frame:GetUserValue("ItemName")
	local CurStep = frame:GetUserIValue("CurStep")
	local Rank, Count = GET_GACHA_ITEM_STEP(ItemName)

	local Grade = (5 - Rank) * 1000 + 1

	local popupFrame = ui.GetFrame("hair_gacha_popup");

	OPEN_COUNT_REWARD_SET(popupFrame, "", "Event_Santa")
	SHOW_GACHA(0, ItemName, "hair", Grade);
	REFRESH_GAMBLE_LIST(frame, CurStep);
	TOGGLE_GACHA_BTN(frame, 1)
end

--결과 나온 아이템에 이펙트 띄워주기.
function ON_EVENT_GAMBLE_RESULT(frame, msg, argstr, argnum)
	frame:SetUserValue("ItemName", argstr)
	frame:SetUserValue("CurStep", argnum)
	local pc = GetMyPCObject()
    if not pc then
        return;
    end

    local acc = GetMyAccountObj(pc);
    if not acc then
        return;
    end

	local gambletype = GET_EVENT_GAMBLE_TYPE(frame)
    local typeConfig = GachaTypeManager.getTypeConfig(gambletype)
	local cost = typeConfig.getCost(argnum);
	local itemIcon = typeConfig.costIcon;

	if gambletype == 0 then
		SET_GACHA_TEXT(frame, itemIcon, cost);
	else
		local mat_cls = GetClassByNameFromList(item_list, "Event_2512_santaticket")
		curr_my_cnt, itemlist = GET_INV_ITEM_COUNT_BY_PROPERTY({
			{ Name = 'ClassName', Value = "Event_2512_santaticket" }
		}, false)

		SET_GACHA_TEXT(frame, itemIcon, curr_my_cnt);
	end
	is_server_event_over = true;
	_EVENT_SANTA_GACHA_DELAY_FLUSH(frame)
end

function SET_SOLDOUT_FRAME(frame, visible)
	local disable_shadow = GET_CHILD_RECURSIVELY(frame, "disable_shadow")
	local sold_out = GET_CHILD_RECURSIVELY(frame, "sold_out")

	disable_shadow:SetVisible(visible);
	disable_shadow:ShowWindow(visible);
	sold_out:ShowWindow(visible);
end

function SET_REMAIN_TIME(frame, time, visible)
	local remaintime = GET_CHILD_RECURSIVELY(frame, "remaintime")

	remaintime:SetTextByKey("value", time);
	remaintime:ShowWindow(visible);
end

function SET_GACHA_TEXT(frame, imgname, count)
	local gacha_start = GET_CHILD_RECURSIVELY(frame, "gacha_start")
	if imgname == "icon_item_pvpmine_2" then
		if count >= 100000 then
			gacha_start:SetTextByKey("cnt", ClMsg("Auto_JongLyo"))
		elseif count > 0 then
			gacha_start:SetTextByKey("cnt", "X"..count)
		elseif count == 0 then
			gacha_start:SetTextByKey("cnt", ClMsg("IsFree"))
		else
			gacha_start:SetTextByKey("cnt", ClMsg("Auto_JongLyo"))
		end
	else
		gacha_start:SetTextByKey("cnt", ClMsg("Auto_BoyuLyang").." : "..count)
	end
	gacha_start:SetTextByKey("value", imgname)
end

function SET_GACHA_PROBABILITY_TYPE(frame, type)
	local Gacha_Probability = GET_CHILD_RECURSIVELY(frame, "Gacha_Probability")
	Gacha_Probability:SetEventScript(ui.LBUTTONUP, "EXTERN_OPEN_LETICIA_PROBABILITY")
	Gacha_Probability:SetEventScriptArgNumber(ui.LBUTTONUP, type)
	Gacha_Probability:SetEventScriptArgString(ui.LBUTTONUP, "1")
end

function OPEN_9th_collection_event()
	local frame = ui.GetFrame('earthtowershop')
	if frame:IsVisible() == 1 then
		ui.CloseFrame('earthtowershop')
	end
	
    frame:SetUserValue("SHOP_TYPE", '9th_event_col');
    ui.OpenFrame('earthtowershop');
end

function _UPDATE_SANTA_GAMBLE_REMAIN_TIME(frame, t, tt, ttt)
	local GambleType = GET_EVENT_GAMBLE_TYPE(frame)
	local remaintime = frame:GetUserIValue("RemainTime")

	if GambleType == 1 then
		SET_REMAIN_TIME(frame, remaintime, 0)
	else
		SET_REMAIN_TIME(frame, remaintime, 1)
	end

	frame:SetUserValue("RemainTime", remaintime - 1);
	return 1;
end

function TOGGLE_GACHA_BTN(frame, state)
	local gacha_start = GET_CHILD_RECURSIVELY(frame, "gacha_start")
	if not gacha_start then
		return;
	end

	gacha_start:SetEnable(state)
end

function SET_CAUTIONTEXT(frame, type)
	local cautionText = GET_CHILD_RECURSIVELY(frame, "cautionText")
	if cautionText then
		if type == 0 then
			cautionText:SetTextByKey("value", ClMsg("EVENT_2411_SANTA_CAUTION1"))
		else
			cautionText:SetTextByKey("value", ClMsg("EVENT_2512_SANTA_CAUTION2"))
		end
	end
end

function _RESET_CURRENT_GACHA_STEP(frame, msg, argstr, argnum)
	frame:SetUserValue("CurStep", argnum )
	local pc = GetMyPCObject()
    if not pc then
        return;
    end
    local acc = GetMyAccountObj(pc);
    if not acc then
        return;
    end
	local gambletype = GET_EVENT_GAMBLE_TYPE(frame)
    local typeConfig = GachaTypeManager.getTypeConfig(gambletype)
	local cost = typeConfig.getCost(argnum);
	local itemIcon = typeConfig.costIcon;

	if gambletype == 0 then
		SET_GACHA_TEXT(frame, itemIcon, cost);
	else
		local mat_cls = GetClassByNameFromList(item_list, "Event_2512_santaticket")
		curr_my_cnt, itemlist = GET_INV_ITEM_COUNT_BY_PROPERTY({
			{ Name = 'ClassName', Value = "Event_2512_santaticket" }
		}, false)
	
		GachaStepCurList = GET_STEP_GACHA_CLS(pc, 1)
		SET_GACHA_TEXT(frame, itemIcon, curr_my_cnt);
	end
	REFRESH_GAMBLE_LIST(frame, argnum);

	is_server_event_over = true;
	_EVENT_SANTA_GACHA_DELAY_FLUSH(frame)
end

function REFRESH_GACHA_BTN(frame)
	-- TOGGLE_GACHA_BTN(frame, 1)
	is_ui_event_over = true;
	_EVENT_SANTA_GACHA_DELAY_FLUSH(frame)
end