-- lib_groupbox.lua

function QUEST_GBOX_AUTO_ALIGN(frame, GroupCtrl, starty, spacey, gboxaddy) -- questinfoset_2
	local height = GroupCtrl:GetHeight()
	local needResize = true
	if height >= GroupCtrl:GetOriginalHeight() then
		needResize = false
	end

	if needResize then
		GBOX_AUTO_ALIGN(GroupCtrl, starty, spacey, gboxaddy);
	else
		GroupCtrl:SetScrollBar(GroupCtrl:GetOriginalHeight())
		GBOX_AUTO_ALIGN(GroupCtrl, starty, spacey, gboxaddy, false, false);
	end
end

function GBOX_AUTO_ALIGN(gbox, starty, spacey, gboxaddy, alignByMargin, autoResizeGroupBox, onlyAlignVisible, reverse)
	if type(gbox) == "table" then
		local argtbl = gbox
		gbox = argtbl.gbox
		starty = argtbl.starty
		spacey = argtbl.spacey
		gboxaddy = argtbl.gboxaddy
		alignByMargin = argtbl.alignByMargin
		autoResizeGroupBox = argtbl.autoResizeGroupBox
		onlyAlignVisible = argtbl.onlyAlignVisible
		reverse = argtbl.reverse
	end
	local cnt = gbox:GetChildCount();
	local y = starty;

	local do_align = function(i)
		local ctrl = gbox:GetChildByIndex(i);
		if ctrl:GetName() ~= "_SCR" and (not onlyAlignVisible or ctrl:IsVisible() ~= 0) then
			
			if alignByMargin then
				local rect = ctrl:GetMargin();
				ctrl:SetMargin(rect.left, y, rect.right, rect.bottom);
			else
				ctrl:SetOffset(ctrl:GetX(), y);
			end

			y = y + ctrl:GetHeight() + spacey;
		end
	end

	if reverse then
		for i = cnt - 1, 0, -1 do do_align(i) end
	else
		for i = 0, cnt - 1 do do_align(i) end
	end
	
	if autoResizeGroupBox then
		gbox:Resize(gbox:GetWidth(), y + gboxaddy);
	end
end

function BUFF_SEPARATED_LIST_GBOX_AUTO_ALIGN(gbox, starty, spacey, gboxaddy, alignByMargin, autoResizeGruopBox)
	if onlyAlignVisible == nil then
        onlyAlignVisible = false;
    end
	
	local frame = ui.GetFrame("buff_separatedlist");
	if gbox == nil then
		return;
	end
	local cnt = gbox:GetChildCount();
	local y = starty;
	local lineCount = 0;
	for i = 0, cnt - 1 do
		local ctrl = gbox:GetChildByIndex(i);
		local ctrlName = ctrl:GetName();
		
		if string.find(ctrlName, "BUFFSLOT") == nil then
			if string.find(ctrlName, "buff") ~= nil then
				lineCount = tonumber(frame:GetUserConfig("BUFF_ROW"));
			end

			if alignByMargin == true then
				local rect = ctrl:GetMargin();
				ctrl:SetMargin(rect.left, lineCount * y + rect.top, rect.right, rect.bottom);
			else
				ctrl:SetOffset(ctrl:GetX(), y);
			end

			y = y + ctrl:GetHeight() + spacey;
		end
	end
	
	if autoResizeGruopBox ~= false then
		gbox:Resize(gbox:GetWidth(), y + gboxaddy);
	end
end

function BUFF_SEPARATEDLIST_CTRLSET_GBOX_AUTO_ALIGN(gbox, startx, spacex, gboxaddx, defaultWidth, alignByMargin, lineHeight, autoResizeHeight)
	if lineHeight == nil then
		lineHeight = 0;
	end

	local maxHeight = gbox:GetHeight();
	local cnt = gbox:GetChildCount();
	local x = startx;
	local lineCount = 0;
	local maxX = x;
	for i = 0, cnt - 1 do
		local ctrl = gbox:GetChildByIndex(i);
		local ctrlName = ctrl:GetName();
		if string.find(ctrlName, "GBox") == nil then
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
			topParent:Resize(gbox:GetWidth() + 10, maxHeight);
		end
	end
end

function GBOX_AUTO_ALIGN_HORZ(gbox, startx, spacex, gboxaddx, alignByMargin, autoResizeWidth, lineHeight, autoResizeHeight)

	if lineHeight == nil then
		lineHeight = 0;
	end

	local maxHeight = gbox:GetHeight();
	local cnt = gbox:GetChildCount();
	local x = startx;
	local lineCount = 0;
	local maxX = x;
	for i = 0, cnt - 1 do
		local ctrl = gbox:GetChildByIndex(i);
		if ctrl:GetName() ~= "_SCR" then
			
			if x + ctrl:GetWidth() > gbox:GetWidth() then
				x = startx;
				lineCount = lineCount + 1;
			end

			if alignByMargin == true then
				local rect = ctrl:GetMargin();
				ctrl:SetMargin(x, rect.top + lineCount * lineHeight, rect.right, rect.bottom);
				if autoResizeHeight == true then
					maxHeight = math.max(maxHeight, ctrl:GetY() + ctrl:GetHeight());
				end
			else
				ctrl:SetOffset(x, ctrl:GetY());
			end

			x = x + ctrl:GetHeight() + spacex;
			maxX = math.max(maxX, x);
		end
	end
	
	if autoResizeWidth ~= false or autoResizeHeight == true then
		local resizedWidth = gbox:GetWidth();
		if autoResizeWidth ~= false then
			resizedWidth = maxX;
		end

		gbox:Resize(resizedWidth, maxHeight);
	end
end

imcGroupBox = {
	StartAlphaEffect = function(self, box, totalSec, updateSec)
		box:SetUserValue('UPDATE_TERM', updateSec);
		box:SetUserValue('TOTAL_SEC', totalSec);
		box:SetUserValue('ACCUMULATE_SEC', 0);
		box:RunUpdateScript('UPDATE_IMC_GROUPBOX_ALPHA_EFFECT', updateSec, totalSec);
	end,
};

function UPDATE_IMC_GROUPBOX_ALPHA_EFFECT(box)
	local updateTerm = box:GetUserValue('UPDATE_TERM');
	local accumulateSec = box:GetUserValue('ACCUMULATE_SEC');
	local totalSec = tonumber(box:GetUserValue('TOTAL_SEC'));
	accumulateSec = tonumber(accumulateSec) + tonumber(updateTerm);
	box:SetUserValue('ACCUMULATE_SEC', accumulateSec);
	if accumulateSec >= totalSec then
		return 0;
	end

	local destAlpha = (1 - accumulateSec / totalSec) * 100;
	box:SetAlpha(destAlpha);
	return 1;
end

function BUFF_RAID_DEBUFF_LIST_GBOX_AUTO_ALIGN(gbox, starty, spacey, gboxaddy, alignByMargin, autoResizeGruopBox)
	if onlyAlignVisible == nil then
        onlyAlignVisible = false;
    end
	
	local frame = ui.GetFrame("buff_raid");
	if gbox == nil then
		return;
	end

	local cnt = gbox:GetChildCount();
	if cnt == 0 then return; end

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
				y = y + 75;
			else
				y = y + ctrl:GetHeight() + spacey;
			end
		end
	end
	
	if autoResizeGruopBox ~= false then
		gbox:Resize(gbox:GetWidth(), y + gboxaddy);
	end
end

function BUFF_RAID_DEBUFF_CTRLSET_GBOX_AUTO_ALIGN(gbox, startx, spacex, gboxaddx, defaultWidth, alignByMargin, lineHeight, autoResizeHeight)
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

			topParent:Resize(gbox_width + 10, maxHeight);
		end
	end
end

function NOTICE_RAID_PC_CTRL_GBOX_AUTO_ALIGN(gbox, spacex, gboxaddx, defaultWidth, alignByMargin, lineHeight, autoResizeHeight)
	if lineHeight == nil then
		lineHeight = 0;
	end

	local total_x = 0;
	local count = gbox:GetChildCount();
	for i = 0, count - 1 do
		local ctrl = gbox:GetChildByIndex(i);
		if ctrl ~= nil then
			local ctrlName = ctrl:GetName();
			if string.find(ctrlName, "gbox") == nil and ctrl:IsVisible() == 1 then
				total_x = total_x + ctrl:GetWidth();
			end
		end
	end

	-- row 조절
	local line_count = 0;
	local max_height = gbox:GetHeight();
	
	-- col 조절
	x = total_x / count; -- 첫번째 아이콘의 중심 x 좌표
	if count == 1 then -- 갯수가 하나일떄에는 중앙에 위치하도록 설정.
		x = (defaultWidth - total_x) / 2;
	end

	-- 정렬
	local start_x = x;
	local max_x = total_x;
	for i = 0, count - 1 do
		local ctrl = gbox:GetChildByIndex(i);
		if ctrl ~= nil then
			local ctrlName = ctrl:GetName();
			if string.find(ctrlName, "gbox") == nil then
				if x + ctrl:GetWidth() > defaultWidth then
					x = start_x;
					line_count = line_count + 1;
				end

				if alignByMargin == true then
					local rect = ctrl:GetMargin();
					ctrl:SetMargin(x, line_count * lineHeight, rect.right, rect.bottom);
					if autoResizeHeight == true then
						maxHeight = line_count * lineHeight + gboxaddx;
					end
				else
					ctrl:SetOffset(x, ctrl:GetY());
				end

				x = x + ctrl:GetWidth() + spacex;
				max_x = math.max(max_x, x);
			end
		end
	end

	if autoResizeHeight == true then
		local resize_width = gbox:GetWidth();
		if line_count == 0 then
			max_height = lineHeight;
		end
		gbox:Resize(max_x, max_height);

		local parent = gbox:GetTopParentFrame();
		if parent ~= nil then
			topParent:Resize(gbox:GetWidth() + 10, max_height);
		end
	end
end