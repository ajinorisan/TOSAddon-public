-- buff_raid
--buff_raid 설명서
--buff의 keyword에 RaidBuff 추가하면 buff_raid UI에 출력됩니다
--buff의 keyword에 RaidBuff;AlwayVisible 추가하면 디버프가 지워져도 buff_raid UI에 영구적으로 출력됩니다.
--buff의 Group1에 Buff를 넣으면 Buff 슬롯에, Debuff를 넣으면 Debuff 슬롯에 갑니다

local json = require('json')
local PATH = require('path')

local buff_raid = {}

local path_format = '..\\release\\addon_setting\\buff_raid\\%s\\settings.json'
buff_raid.SettingsFileLocation = string.format(path_format, '0')

buff_raid.Settings = {
	pc_id = {}
};

local function save_setting(frame)		
	if frame == nil then
		return;
	end

	local x = frame:GetX()
	local y = frame:GetY()
	local t = buff_raid.Settings.pc_id[session.GetMySession():GetCID()]	

	if t == nil or t['pos'] == nil or t['pos'].x ~= frame:GetX() or t['pos'].y ~= frame:GetY() then		
		buff_raid.Settings.pc_id[session.GetMySession():GetCID()] = {}
		buff_raid.Settings.pc_id[session.GetMySession():GetCID()]["pos"] = {}
		buff_raid.Settings.pc_id[session.GetMySession():GetCID()].pos.x = x
		buff_raid.Settings.pc_id[session.GetMySession():GetCID()].pos.y = y
		
		save_json(buff_raid.SettingsFileLocation, buff_raid.Settings);
	end
end

local function load_setting(frame)
		--UI 세팅 옵션 불러오기
		if buff_raid.Loaded == nil then		
			buff_raid.SettingsFileLocation = string.format(path_format, session.loginInfo.GetUserID())
			local t, err = load_json(buff_raid.SettingsFileLocation, buff_raid.Settings);			
			if err then
				os.execute('mkdir ' .. PATH.dirname(buff_raid.SettingsFileLocation) .. ' >nul 2>nul')
				save_setting(frame)
			else
				buff_raid.Settings = t;
				buff_raid.Loaded = true;								
			end
		end
		local t = buff_raid.Settings.pc_id[session.GetMySession():GetCID()]			
		if t ~= nil and t['pos'] ~= nil then
			BUFF_RAID_SET_POS(frame)	
		end
end

function BUFF_RAID_ON_INIT(addon, frame)
	addon:RegisterMsg('BUFF_ADD', 'BUFF_RAID_ON_MSG');
	addon:RegisterMsg('BUFF_REMOVE', 'BUFF_RAID_ON_MSG');
	addon:RegisterMsg('BUFF_UPDATE', 'BUFF_RAID_ON_MSG');
	addon:RegisterMsg('RELOAD_BUFF_ADD', 'BUFF_RAID_ON_MSG');
	INIT_BUFF_RAID_UI(frame);
end

function BUFF_RAID_ON_RELOAD(frame)
	INIT_BUFF_RAID_UI(frame);
end

function INIT_BUFF_RAID_UI(frame)
	if frame ~= nil then
		local timer = GET_CHILD_RECURSIVELY(frame, "addontimer");
		tolua.cast(timer, "ui::CAddOnTimer");
		timer:SetUpdateScript("BUFF_RAID_TIME_UPDATE");
		timer:Start(0.45);

		frame:SetUserConfig("BUFF_ROW", 0);
		frame:SetUserConfig("BUFF_COL", 0);

		local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
		gbox:ShowWindow(1);

		local offsetX = tonumber(frame:GetUserConfig("DEFAULT_SLOT_X_OFFSET"));
		local offsetY = tonumber(frame:GetUserConfig("DEFAULT_SLOT_Y_OFFSET"));
		local gboxAdd = tonumber(frame:GetUserConfig("GBOX_ADD"));
		local defaultwidth = tonumber(frame:GetUserConfig("DEFAULT_GBOX_WIDTH"));

		local gbox_debuff = GET_CHILD_RECURSIVELY(frame, "gbox_debuff");
		if gbox_debuff == nil then return; end
		BUFF_RAID_DEBUFF_CTRLSET_GBOX_AUTO_CHECKSIZE(gbox_debuff, 15, offsetX, gboxAdd, defaultwidth, true, offsetY, true);

		local gbox_buff = GET_CHILD_RECURSIVELY(frame, "gbox_buff");
		if gbox_buff == nil then return; end
		BUFF_RAID_DEBUFF_CTRLSET_GBOX_AUTO_CHECKSIZE(gbox_buff, 15, offsetX, gboxAdd, defaultwidth, true, offsetY, true);
		gbox_buff:Invalidate();

		if gbox_debuff:GetChildCount() < 1 and gbox_buff:GetChildCount() < 1 then
			frame:ShowWindow(0);
		end
		
		BUFF_RAID_LIST_CHECKSIZE(frame);
		BUFF_RAID_SET_POS(frame);
	end
end

function BUFF_RAID_SET_POS(frame)

	if frame ~= nil then
		local pos = ui.GetCatchMovePos(frame:GetName());
		local t = buff_raid.Settings.pc_id[session.GetMySession():GetCID()]		

		--UI 위치를 불러오는데 옵션 정보가 없으면 불러온다
		if t == nil then
			load_setting(frame)
			t = buff_raid.Settings.pc_id[session.GetMySession():GetCID()]	
			if t ~= nil then
				frame:MoveFrame(t['pos'].x, t['pos'].y);
			end
		else
			--저장된 위치가 같으면 굳이 움직이지도, 저장도 하지 않는다.
			if pos.x == t['pos'].x and pos.y == t['pos'].y then
				return;
			end
		end

		--모든 버프칸이 비워져 있으면 세팅값을 저장하지 않는다. 리사이즈 과정 때문에 위치값이 이상하게 저장된다
		local gbox_debuff = GET_CHILD_RECURSIVELY(frame, "gbox_debuff");
		local gbox_buff = GET_CHILD_RECURSIVELY(frame, "gbox_buff");
		if gbox_debuff == nil or gbox_buff == nil then
			return;
		end
		if gbox_debuff:GetChildCount() < 1 and gbox_buff:GetChildCount() < 1 then
			return;
		end

		if t ~= nil and t['pos'] ~= nil then
			if pos.x == 0 and pos.y == 0 then
				frame:MoveFrame(t['pos'].x, t['pos'].y);
				return;
			end
			save_setting(frame);
			frame:MoveFrame(pos.x, pos.y);	
		end
	end
end

function BUFF_RAID_TIME_UPDATE(frame, timer, argstr, argnum, passedtime)	

	local myhandle = session.GetMyHandle();
	local TOKEN_BUFF_ID = TryGetProp(GetClass("Buff", "Premium_Token"), "ClassID");

	local gbox_debuff = GET_CHILD_RECURSIVELY(frame, "gbox_debuff");
	if gbox_debuff == nil then
		return;
	end

	local gbox_buff = GET_CHILD_RECURSIVELY(frame, "gbox_buff");
	if gbox_buff == nil then
		return;
	end

	if gbox_debuff:GetChildCount() >= 1 or gbox_buff:GetChildCount() >= 1 then
		BUFF_RAID_SET_POS(frame);
	end

	BUFF_RAID_TIME_UPDATE_GBOX(gbox_debuff, myhandle, TOKEN_BUFF_ID);
	BUFF_RAID_TIME_UPDATE_GBOX(gbox_buff, myhandle, TOKEN_BUFF_ID);
end

function BUFF_RAID_TIME_UPDATE_GBOX(gbox, myhandle, token_buff_id)
	local updated = 0;
	local cnt = gbox:GetChildCount();
	for i = 1, cnt do 
		local ctrlSet = gbox:GetChildByIndex(i - 1);
		if ctrlSet ~= nil then
			local slot = GET_CHILD_RECURSIVELY(ctrlSet, "slot");
			local text = GET_CHILD_RECURSIVELY(ctrlSet, "caption");
			if slot:IsVisible() == 1 then
				local icon = slot:GetIcon();
				local iconInfo = icon:GetInfo();
				local buffIndex = icon:GetUserIValue("BuffIndex");
				local buff = info.GetBuff(myhandle, iconInfo.type, buffIndex);
				
				local buffCls = GetClassByType('Buff', iconInfo.type);
				local keyword = TryGetProp(buffCls, "Keyword", "None");
				local keywordTable = StringSplit(keyword, ";")
				local is_alway_visible = 0;
				for i = 1, #keywordTable do
					if keywordTable[i] == "AlwayVisible" then
						is_alway_visible = 1;
					end
				end

				if buff ~= nil then
					--AlwayVisible 키워드가 있는 레이드 버프는 시간초 표시 하지 않는다
					if is_alway_visible == 1 then
						text:SetText(GET_BUFF_TIME_TXT(0, 0));
					else
						text:SetText(GET_BUFF_TIME_TXT(buff.time, 0));
						updated = 1;

						if buff.time < 5000 and buff.time ~= 0.0 then
							if slot:IsBlinking() == 0 then
								slot:SetBlink(600000, 1.0, "55FFFFFF", 1);
							end
						elseif buff.buffID == token_buff_id and GET_REMAIN_TOKEN_SEC() < 3600 then
							if slot:IsBlinking() == 0 then
								slot:SetBlink(0, 1.0, "55FFFFFF", 1);
							end
						else
							if slot:IsBlinking() == 1 then
								slot:ReleaseBlink();
							end
						end
					end
				end
			end
		end
	end

	if updated == 1 then
		ui.UpdateVisibleToolTips("buff");
	end
end

function BUFF_RAID_LIST_CHECKSIZE(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "gbox");
	if gbox == nil then
		return;
	end

	BUFF_RAID_DEBUFF_LIST_GBOX_AUTO_CHECKSIZE(gbox, 20, 5, 20, 0, true, true);
	gbox:Invalidate();

	local gbox_buff = GET_CHILD_RECURSIVELY(gbox, "gbox_buff");
	local gbox_debuff = GET_CHILD_RECURSIVELY(gbox, "gbox_debuff");

	--디버프, 버프가 둘 다 있으면, 둘다 보이게
	if gbox_debuff:GetChildCount() >= 1 and gbox_buff:GetChildCount() >= 1 then
		frame:Resize(frame:GetWidth(), gbox:GetHeight());
	--버프만 있으면, 버프만 보이게
	elseif gbox_debuff:GetChildCount() < 1 then
		frame:Resize(frame:GetWidth(), gbox:GetHeight()/ 2);
	--디버프만 있으면, 디버프만 보이게
	elseif gbox_buff:GetChildCount() < 1 then
		frame:Resize(frame:GetWidth(), gbox:GetHeight()/ 2);
	end

	frame:Invalidate();
end

function BUFF_RAID_DEBUFF_LIST_GBOX_AUTO_CHECKSIZE(gbox, starty, spacey, gboxaddy, alignByMargin, autoResizeGruopBox)
	if onlyAlignVisible == nil then
        onlyAlignVisible = false;
    end
	
	local frame = ui.GetFrame("buff_raid");
	if gbox == nil then
		return;
	end

	local cnt = gbox:GetChildCount();
	if cnt == 0 then return; end

	local gbox_buff = GET_CHILD_RECURSIVELY(gbox, "gbox_buff");
	local gbox_debuff = GET_CHILD_RECURSIVELY(gbox, "gbox_debuff");

	if gbox_buff == nil or gbox_debuff == nil then
		return;
	end

	if gbox_debuff:GetChildCount() >= 1 and gbox_buff:GetChildCount() >= 1 then
		--디버프, 버프가 둘 다 있으면, 둘다 보이게	
		local y = starty;
		local lineCount = 0;
		for i = 0, cnt - 1 do
			local ctrl = gbox:GetChildByIndex(i);
			local ctrlName = ctrl:GetName();
			if string.find(ctrlName, "RAID_DEBUFF_SLOT") == nil then
				lineCount = tonumber(frame:GetUserConfig("BUFF_ROW"));
				
				if alignByMargin == true then
					local rect = ctrl:GetMargin();
					ctrl:SetMargin(rect.left, lineCount * y + rect.top, rect.right, rect.bottom);
				else
					ctrl:SetOffset(ctrl:GetX(), y);
				end
				
				if ctrlName == "gbox_debuff" then
					y = y + ctrl:GetHeight() + spacey;
				else
					y = y + ctrl:GetHeight() + spacey;
				end
			end
		end
		
		if autoResizeGruopBox ~= false then
			gbox:Resize(gbox:GetWidth(), y + gboxaddy);
		end
	elseif gbox_buff:GetChildCount() >= 1 and gbox_debuff:GetChildCount() < 1 then	
		--버프만 있으면, 버프만 보이게
		local y = starty;
		local lineCount = 0;
			lineCount = tonumber(frame:GetUserConfig("BUFF_ROW"));
		if alignByMargin == true then
			local rect = gbox_buff:GetMargin();
			gbox_buff:SetMargin(rect.left, lineCount * y + rect.top, rect.right, rect.bottom);
		else
			gbox_buff:SetOffset(gbox_buff:GetX(), y);
		end
		
		y = y + gbox_buff:GetHeight()*2 + spacey * 5;
		
		if autoResizeGruopBox ~= false then
			gbox:Resize(gbox:GetWidth(), y + gboxaddy);
		end
	elseif gbox_buff:GetChildCount() < 1 and gbox_debuff:GetChildCount() >= 1 then	
		--디버프만 있으면, 디버프만 보이게
		local y = starty;
		local lineCount = 0;
			lineCount = tonumber(frame:GetUserConfig("BUFF_ROW"));
		if alignByMargin == true then
			local rect = gbox_debuff:GetMargin();
			gbox_debuff:SetMargin(rect.left, lineCount * y + rect.top, rect.right, rect.bottom);
		else
			gbox_debuff:SetOffset(gbox_debuff:GetX(), y);
		end
		
		y = y + gbox_debuff:GetHeight()*2 + spacey * 5;
		
		if autoResizeGruopBox ~= false then
			gbox:Resize(gbox:GetWidth(), y + gboxaddy);
		end
	end
end

function BUFF_RAID_DEBUFF_CTRLSET_GBOX_AUTO_CHECKSIZE(gbox, startx, spacex, gboxaddx, defaultWidth, alignByMargin, lineHeight, autoResizeHeight)
	if lineHeight == nil then
		lineHeight = 0;
	end

	local maxHeight = gbox:GetHeight();
	local cnt = gbox:GetChildCount();
	if cnt == 0 then return; end

	local x = startx;
	local lineCount = 0;
	local maxX = x;
	for i = 0, cnt - 1 do
		local ctrl = gbox:GetChildByIndex(i);
		local ctrlName = ctrl:GetName();
		if string.find(ctrlName, "gbox") == nil then
			if x + ctrl:GetWidth() > defaultWidth then
				x = startx;
				lineCount = lineCount + 1;
			end

			if alignByMargin == true then
				local rect = ctrl:GetMargin();
				ctrl:SetMargin(x, lineCount * lineHeight, rect.right, rect.bottom);
				if autoResizeHeight == true then
					maxHeight = lineCount * lineHeight + gboxaddx;
				end
			else
				ctrl:SetOffset(x, ctrl:GetY());
			end

			x = x + ctrl:GetWidth() + spacex;
			maxX = math.max(maxX, x);
		end
	end
	
	if autoResizeHeight == true then
		local resizedWidth = gbox:GetWidth();
		if lineCount == 0 then
			maxHeight = lineHeight;
		end
		gbox:Resize(maxX + 8, maxHeight);

		local topParent = gbox:GetTopParentFrame();
		if topParent ~= nil then
			local gbox_debuff_real_width = 0;

			local gbox_debuff = GET_CHILD_RECURSIVELY(topParent, "gbox_debuff");
			local gbox_buff = GET_CHILD_RECURSIVELY(topParent, "gbox_buff");

			if gbox_debuff:GetChildCount() >= gbox_buff:GetChildCount() then
				if gbox_debuff ~= nil then
					local count = gbox_debuff:GetChildCount();
					for i = 0, count - 1 do
						local child = gbox_debuff:GetChildByIndex(i);
						if child ~= nil and string.find(child:GetName(), "RAID_DEBUFF_SLOT") ~= nil then
							gbox_debuff_real_width = gbox_debuff_real_width + child:GetWidth() + spacex + 8;
						end
					end
				end

				local gbox_width = gbox:GetWidth(); 
				if gbox_width < gbox_debuff_real_width then
					gbox_width = gbox_debuff_real_width;
				end
				topParent:Resize(gbox_width + 5 , maxHeight);
			else
				if gbox_buff ~= nil then
					local count = gbox_buff:GetChildCount();
					for i = 0, count - 1 do
						local child = gbox_buff:GetChildByIndex(i);
						if child ~= nil and string.find(child:GetName(), "RAID_DEBUFF_SLOT") ~= nil then
							gbox_debuff_real_width = gbox_debuff_real_width + child:GetWidth() + spacex + 8;
						end
					end
				end

				local gbox_width = gbox:GetWidth(); 
				if gbox_width < gbox_debuff_real_width then
					gbox_width = gbox_debuff_real_width;
				end
				topParent:Resize(gbox_width + 5 , maxHeight);
			end
		end
	end
end

function BUFF_RAID_ON_MSG(frame, msg, argStr, argNum)
	local handle = session.GetMyHandle();
	if msg == "BUFF_ADD" or msg == "BUFF_UPDATE" or msg == "RELOAD_BUFF_ADD" then
		BUFF_RAID_CTRLSET_CREATE(frame, msg, handle, argStr, argNum);
	elseif msg == "BUFF_REMOVE" then
		BUFF_RAID_CTRLSET_REMOVE(frame, handle, argStr, argNum);
	end
	BUFF_RAID_TIME_UPDATE(frame);	
	BUFF_RAID_LIST_CHECKSIZE(frame);
end

function BUFF_RAID_CTRLSET_CREATE(frame, msg, handle, buffIndex, buffID)
	local buff = info.GetBuff(tonumber(handle), buffID);
	local buffCls = GetClassByType("Buff", buffID);
	if buffCls == nil then
		return;
	end

	if BUFF_CHECK_RAID(buffID) == false then
		return;
	end

	BUFF_RAID_CTRLSET_CREATE_EXEC(frame, msg, handle, buff, buffCls, buffIndex, buffID);
end

function BUFF_RAID_CTRLSET_CREATE_EXEC(frame, msg, handle, buff, buffCls, buffIndex, buffID)
	if handle == nil then return; end
	if frame ~= nil then
		frame:ShowWindow(1);
	end

	local buffGroup1 = TryGetProp(buffCls, "Group1");
	if buffGroup1 ~= "Debuff" and buffGroup1 ~= "Buff" then 
		return; 
	end

	if buffGroup1 =="Debuff" then
		BUFF_RAID_CTRLSET_CREATE_EXEC_GBOX_DEBFF(frame, msg, handle, buff, buffCls, buffIndex, buffID);
	elseif buffGroup1 == "Buff" then
		BUFF_RAID_CTRLSET_CREATE_EXEC_GBOX_BUFF(frame, msg, handle, buff, buffCls, buffIndex, buffID);
	end
end

function BUFF_RAID_CTRLSET_CREATE_EXEC_GBOX_DEBFF(frame, msg, handle, buff, buffCls, buffIndex, buffID)
	local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_debuff");
	if gbox == nil then
		return;
	end

	local colCnt = tonumber(frame:GetUserConfig("COL_COUNT"));
	local col = frame:GetUserIValue("GBOX_DEBUFF_COL");
	if col == nil then 
		col = 0;
	end

	if col > colCnt - 1 then
		return;
	end

	BUFF_RAID_CTRLSET_CREATE_EXEC_COMMON(frame, msg, gbox, handle, buff, buffCls, buffIndex, buffID, "GBOX_DEBUFF_COL", col);
end

function BUFF_RAID_CTRLSET_CREATE_EXEC_GBOX_BUFF(frame, msg, handle, buff, buffCls, buffIndex, buffID)
	local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_buff");
	if gbox == nil then
		return;
	end

	local row = tonumber(frame:GetUserConfig("BUFF_ROW"));
	local colCnt = tonumber(frame:GetUserConfig("COL_COUNT"));
	local col = frame:GetUserIValue("GBOX_TIME_DEBUFF_COL");
	if col == nil then 
		col = 0;
	end

	if col % colCnt == 0 and col > colCnt - 1 then
		col = 0;
		row = row + 1;
		frame:SetUserConfig("BUFF_ROW", row);
	end			

	BUFF_RAID_CTRLSET_CREATE_EXEC_COMMON(frame, msg, gbox, handle, buff, buffCls, buffIndex, buffID, "GBOX_TIME_DEBUFF_COL", col);
end

function BUFF_RAID_CTRLSET_CREATE_EXEC_COMMON(frame, msg, gbox, handle, buff, buffCls, buffIndex, buffID, colUserValueName, colCount)
	local ctrlSet = gbox:CreateOrGetControlSet("raid_bufficon_slot", "RAID_DEBUFF_SLOT"..buffID, 0, 0);
	if ctrlSet == nil then 
		return;
	end

	if msg == "BUFF_ADD" then
		colCount = colCount + 1;
		frame:SetUserValue(colUserValueName, colCount);
	end

	local slot = GET_CHILD_RECURSIVELY(ctrlSet, "slot");
	local caption = GET_CHILD_RECURSIVELY(ctrlSet, "caption");
	if slot ~= nil and caption ~= nil then
		local icon = CreateIcon(slot);
		local iconImageName = GET_BUFF_ICON_NAME(buffCls);
		icon:SetDrawCoolTimeText(0);
		icon:Set(iconImageName, "BUFF", buffID, 0);
		if buffIndex ~= nil then
			icon:SetUserValue("BuffIndex", buffIndex);
		end				

		local bufflockoffset = tonumber(frame:GetUserConfig("DEFAULT_BUFF_LOCK_OFFSET"));
		local isRemove = TryGetProp(buffCls, "RemoveBySkill", "NO");
		if buffGroup1 == "Debuff" and isRemove == "YES" then
			local bufflv = TryGetProp(buffCls, "Lv", "99");
			if bufflv <= 3 then
				slot:SetBgImage("buff_lock_icon_3");
			elseif bufflv == 4 then
				slot:SetBgImage("buff_lock_icon_4");
			end
			slot:SetBgImageSize(slot:GetWidth() + bufflockoffset, slot:GetHeight() + bufflockoffset);
		end

		if buff.over >= 1 then
			slot:SetText('{s15}{ol}{b}'..buff.over, 'count', ui.RIGHT, ui.BOTTOM, -5, -3);
		else
			slot:SetText("");
		end

		if slot:GetTopParentFrame():GetName() ~= "targetbuff" then
    		slot:SetEventScript(ui.RBUTTONUP, 'REMOVE_BUF');
    		slot:SetEventScriptArgNumber(ui.RBUTTONUP, buffID);
		end 

		slot:EnableDrop(0);
		slot:EnableDrag(0);
		caption:ShowWindow(1);
		caption:SetText(GET_BUFF_TIME_TXT(buff.time, 0));

		local targetinfo = info.GetTargetInfo(handle);
		if targetinfo ~= nil then
			if targetinfo.TargetWindow == 0 then
				slot:ShowWindow(0);	
			else
				slot:ShowWindow(1);
			end
		else
			slot:ShowWindow(1);
		end

		icon:SetTooltipType("buff");
		if buffIndex ~= nil then
			icon:SetTooltipArg(handle, buffID, buffIndex);
		end
		slot:Invalidate();
	end

	local offsetX = tonumber(frame:GetUserConfig("DEFAULT_SLOT_X_OFFSET"));
	local offsetY = tonumber(frame:GetUserConfig("DEFAULT_SLOT_Y_OFFSET"));
	local gboxAdd = tonumber(frame:GetUserConfig("GBOX_ADD"));
	local defaultwidth = tonumber(frame:GetUserConfig("DEFAULT_GBOX_WIDTH"));
	BUFF_RAID_DEBUFF_CTRLSET_GBOX_AUTO_CHECKSIZE(gbox, 15, offsetX, gboxAdd, defaultwidth, true, offsetY, true);
	gbox:Invalidate();
end

function BUFF_RAID_CTRLSET_REMOVE(frame, handle, buffIndex, buffID)
	local buffCls = GetClassByType("Buff", buffID);
	if buffCls ~= nil then
		if BUFF_CHECK_RAID(buffID) == false then
			return;
		end

		local keyword = TryGetProp(buffCls, "Keyword", "None");
		local keywordTable = StringSplit(keyword, ";")
		--AlwayVisible 키워드가 있으면 디버프 중첩 0이어도 항시 노출
		for i = 1, #keywordTable do
			if keywordTable[i] == "AlwayVisible" then
				local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_debuff");
				local ctrlSet = gbox:CreateOrGetControlSet("raid_bufficon_slot", "RAID_DEBUFF_SLOT"..buffID, 0, 0);
				if ctrlSet == nil then 
					return;
				end
					--중첩값 0으로 강제 세팅
					local slot = GET_CHILD_RECURSIVELY(ctrlSet, "slot");
					slot:SetText('{s15}{ol}{b}'..0, 'count', ui.RIGHT, ui.BOTTOM, -5, -3);

					--슬롯 위치 조정
					local offsetX = tonumber(frame:GetUserConfig("DEFAULT_SLOT_X_OFFSET"));
					local offsetY = tonumber(frame:GetUserConfig("DEFAULT_SLOT_Y_OFFSET"));
					local gboxAdd = tonumber(frame:GetUserConfig("GBOX_ADD"));
					local defaultwidth = tonumber(frame:GetUserConfig("DEFAULT_GBOX_WIDTH"));
					BUFF_RAID_DEBUFF_CTRLSET_GBOX_AUTO_CHECKSIZE(gbox, 15, offsetX, gboxAdd, defaultwidth, true, offsetY, true);
				return;
			end
		end
		
		BUFF_RAID_CTRLSET_REMOVE_EXEC(frame, buffID);
	end
end

function BUFF_RAID_CTRLSET_REMOVE_EXEC(frame, buffID)
	local gbox_debuff = GET_CHILD_RECURSIVELY(frame, "gbox_debuff");
	if gbox_debuff == nil then return; end
	BUFF_RAID_CTRLSET_REMOVE_EXEC_GBOX(frame, gbox_debuff, buffID, "GBOX_DEBUFF_COL");
	
	local gbox_buff = GET_CHILD_RECURSIVELY(frame, "gbox_buff");
	if gbox_buff == nil then return; end
	BUFF_RAID_CTRLSET_REMOVE_EXEC_GBOX(frame, gbox_buff, buffID, "GBOX_TIME_DEBUFF_COL");

	BUFF_RAID_DEBUFF_FRAME_CLOSE(frame);
end

function BUFF_RAID_CTRLSET_REMOVE_EXEC_GBOX(frame, gbox, buffID, colUserValueName)	
	if gbox ~= nil then
		local slotName = "RAID_DEBUFF_SLOT"..buffID;
		local childCnt = gbox:GetChildCount();
		if childCnt > 0 then
			for i = 0, childCnt - 1 do
				local child = gbox:GetChildByIndex(i);
				if child ~= nil and slotName == child:GetName() then
					gbox:RemoveChildByIndex(i);
					frame:Invalidate();
					break;
				end
			end

			local row = tonumber(frame:GetUserConfig("BUFF_ROW"));
			local col = frame:GetUserIValue(colUserValueName);
			local colCnt = tonumber(frame:GetUserConfig("COL_COUNT"));
			if childCnt % colCnt == 0 then
				row = row - 1;
				col = colCnt;
				frame:SetUserConfig("BUFF_ROW", row);
			end
					
			if col > 0 then
				col = col - 1;
				frame:SetUserValue(colUserValueName, col);
			end
		end

		local offsetX = tonumber(frame:GetUserConfig("DEFAULT_SLOT_X_OFFSET"));
		local offsetY = tonumber(frame:GetUserConfig("DEFAULT_SLOT_Y_OFFSET"));
		local gboxAdd = tonumber(frame:GetUserConfig("GBOX_ADD"));
		local defaultwidth = tonumber(frame:GetUserConfig("DEFAULT_GBOX_WIDTH"));
		BUFF_RAID_DEBUFF_CTRLSET_GBOX_AUTO_CHECKSIZE(gbox, 15, offsetX, gboxAdd, defaultwidth, true, offsetY, true);
		gbox:Invalidate();
	end
end

function BUFF_RAID_DEBUFF_FRAME_CLOSE(frame)
	local gbox_debuff = GET_CHILD_RECURSIVELY(frame, "gbox_debuff");
	local gbox_buff = GET_CHILD_RECURSIVELY(frame, "gbox_buff");
	if gbox_debuff:GetChildCount() + gbox_buff:GetChildCount() < 1 then
		frame:SetUserValue("GBOX_DEBUFF_COL", 0);
		frame:SetUserValue("GBOX_TIME_DEBUFF_COL", 0);
		frame:ShowWindow(0);
	end
end

function BUFF_CHECK_RAID(buffID)
	if buffID == nil then return; end
	if ui.buff.IsRaidDebuff(buffID) == 1 then
		return true;
	end
	return false;
end