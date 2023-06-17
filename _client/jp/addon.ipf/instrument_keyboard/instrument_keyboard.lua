function INSTRUMENT_KEYBOARD_ON_INIT(addon, frame)
	INSTRUMENT_KEYBOARD_UPDATE_HOTKEYNAME(frame);

	addon:RegisterMsg('INSTRUMENT_KEYBOARD_OPEN', 'INSTRUMENT_KEYBOARD_OPEN');
	addon:RegisterMsg('INSTRUMENT_KEYBOARD_CLOSE', 'INSTRUMENT_KEYBOARD_CLOSE');
end

function GET_INSTRUMENT_KEYBOARD_CNT()
	return 30;
end

function INSTRUMENT_KEYBOARD_UPDATE_HOTKEYNAME(frame)
	local cnt = GET_INSTRUMENT_KEYBOARD_CNT()
	for i = 0, cnt - 1 do
		local slot = GET_CHILD(frame, "slot"..i+1);
		if slot ~= nil then
			local slotString = 'QuickSlotExecute'..(i+1);
			local text = hotKeyTable.GetHotKeyString(slotString);
			slot:SetText('{s14}{#f0dcaa}{b}{ol}'..text, 'default', ui.LEFT, ui.TOP, 2, 1);
		end
	end
end

function GET_INSTRUMENT_SCALE_LIST_BY_HOT_KEY_NAME(type, hotkeyName)
	local scaleList = {};

	local clsList, cnt = GetClassList('instrument_scale');
	for i = 0 , cnt - 1 do
		local cls = GetClassByIndexFromList(clsList, i);
		if cls.Type == type and cls.HotKey == hotkeyName then
			scaleList[#scaleList + 1] = cls;
		end
	end

	return scaleList;
end

function INSTRUMENT_KEYBOARD_OPEN(frame, msg, type)
	INSTRUMENT_KEYBOARD_UPDATE_HOTKEYNAME(frame);

	local cnt = GET_INSTRUMENT_KEYBOARD_CNT();
	for i = 0, cnt - 1 do
		local slot = GET_CHILD(frame, "slot"..i+1);
		local slotString = 'QuickSlotExecute'..(i+1);
		local clsList = GET_INSTRUMENT_SCALE_LIST_BY_HOT_KEY_NAME(type, slotString);
		SET_INSTRUMENT_KEYBOARD_QUICK_SLOT(slot, clsList);
	end

	for i = 20, cnt - 1 do
		local slot = GET_CHILD(frame, "slot"..i + 1);
		slot:SetVisible(1);
	end

	local closeSlotNum = frame:GetUserConfig("CLOSE_INDEX");
	local closeSlot = GET_CHILD(frame, "slot"..(closeSlotNum));
	SET_INSTRUMENT_KEYBOARD_CLOSE_SLOT(closeSlot);

	if IsJoyStickMode() == 0 then
		local quickFrame = ui.GetFrame('quickslotnexpbar')
		quickFrame:ShowWindow(0);
	elseif IsJoyStickMode() == 1 then
		local joystickQuickFrame = ui.GetFrame('joystickquickslot')
		joystickQuickFrame:ShowWindow(0);
	end

	frame:ShowWindow(1);
end

function INSTRUMENT_KEYBOARD_CLOSE(frame, msg, argStr, argNum)
	frame:ShowWindow(0);
end

function INSTRUMENT_KEYBOARD_CLOSE_SCP()
	Instrument.ReqCloseInstrument();

	if IsJoyStickMode() == 0 then
		local quickFrame = ui.GetFrame('quickslotnexpbar')
		quickFrame:ShowWindow(1);
	elseif IsJoyStickMode() == 1 then
		local joystickQuickFrame = ui.GetFrame('joystickquickslot')
		joystickQuickFrame:ShowWindow(1);
	end
end

function CLOSE_INSTRUMENT_KEYBOARD()
	local frame = ui.GetFrame("instrument_keyboard");
	INSTRUMENT_KEYBOARD_CLOSE(frame);
	
	local joystickrestquickslot = ui.GetFrame('joystickrestquickslot');
	local restquickslot = ui.GetFrame('restquickslot');

	if control.IsRestSit() == true then
		Instrument.ReqCloseInstrument();
		if IsJoyStickMode() == 1 then
			joystickrestquickslot:ShowWindow(1);
		else
			restquickslot:ShowWindow(1);
		end
	end
end

function SET_INSTRUMENT_KEYBOARD_QUICK_SLOT(slot, clslist)
	if #clslist <= 0 then
		slot:ReleaseBlink();
		slot:ClearIcon();
		slot:SetEventScript(ui.LBUTTONPRESSED, "None");
		slot:SetEventScript(ui.LBUTTONDOWN, "None");
		slot:SetEventScript(ui.LBUTTONUP, "None");
		slot:SetUserValue("INSTRUMENT_SCALE_TYPE", "None");
		return;
	end

	for i=1, #clslist do
		local cls = clslist[i];
		if cls.IsSharp ~= "YES" then
			slot:SetUserValue("INSTRUMENT_SCALE_TYPE", cls.ClassID);
			slot:ReleaseBlink();
			slot:ClearIcon();
			local icon 	= CreateIcon(slot);
			local desctext = cls.Desc;
			
			if desctext ~= 'None' then
				icon:SetTextTooltip('{@st59}'..desctext);
			end
			
			if cls.Icon ~= 'None' then
				icon:SetImage(cls.Icon);
			end
	
			slot:EnableDrag(0);
			slot:Invalidate();
			
			slot:SetEventScript(ui.LBUTTONPRESSED, "INSTRUMENT_SLOT_LBTN_PRESSED");
			slot:SetEventScript(ui.LBUTTONDOWN, "INSTRUMENT_SLOT_LBTN_DOWN");
			slot:SetEventScript(ui.LBUTTONUP, "INSTRUMENT_SLOT_LBTN_UP");
		else
			slot:SetUserValue("INSTRUMENT_SCALE_SHARP_TYPE", cls.ClassID);
		end
	end
end

function SET_INSTRUMENT_KEYBOARD_CLOSE_SLOT(slot)
	local icon 	= CreateIcon(slot);
	local desctext = ClMsg("InstrumentKeyboardClose");
	icon:SetTextTooltip('{@st59}'..desctext);
	
	local frame = slot:GetTopParentFrame();
	local iconName = frame:GetUserConfig("CLOSE_ICON");
	if iconName ~= "None" then
		icon:SetImage(iconName);
	end
	slot:EnableDrag(0);
	slot:Invalidate();

	slot:SetEventScript(ui.LBUTTONUP, "CLOSE_INSTRUMENT_KEYBOARD");
end

function INSTRUMENT_SLOT_USE(frame, slotIndex)
	local slot = GET_CHILD(frame, "slot"..slotIndex+1);
	if slot:GetEventScript(ui.LBUTTONUP) == "CLOSE_INSTRUMENT_KEYBOARD" then
		CLOSE_INSTRUMENT_KEYBOARD();
	end
end

function INSTRUMENT_SLOT_LBTN_DOWN(frame, slot, strarg, numarg)
	local type = slot:GetUserIValue("INSTRUMENT_SCALE_TYPE");
	local isSpaceBar = keyboard.IsKeyPressed("SPACE");
	if isSpaceBar == 1 then
		type = slot:GetUserIValue("INSTRUMENT_SCALE_SHARP_TYPE");
	end
	
	if type == 0 then
		type = slot:GetUserIValue("INSTRUMENT_SCALE_TYPE");
	end

	local cls = GetClassByType("instrument_scale", type);	
	if cls == nil then
		return;
	end

	Instrument.ReqPlayInstrument(cls.ClassID);
end

function INSTRUMENT_SLOT_LBTN_PRESSED(frame, slot, strarg, numarg)
	local type = slot:GetUserIValue("INSTRUMENT_SCALE_TYPE");
	local isSpaceBar = keyboard.IsKeyPressed("SPACE");
	if isSpaceBar == 1 then
		type = slot:GetUserIValue("INSTRUMENT_SCALE_SHARP_TYPE");
	end
	
	if type == 0 then
		type = slot:GetUserIValue("INSTRUMENT_SCALE_TYPE");
	end

	local cls = GetClassByType("instrument_scale", type);	
	if cls == nil then
		return;
	end

	Instrument.ReqPlayInstrument(cls.ClassID, true);
end

function INSTRUMENT_SLOT_LBTN_UP(frame, slot, strarg, numarg)
	local type = slot:GetUserIValue("INSTRUMENT_SCALE_TYPE");
	local isSpaceBar = keyboard.IsKeyPressed("SPACE");
	if isSpaceBar == 1 then
		type = slot:GetUserIValue("INSTRUMENT_SCALE_SHARP_TYPE");
	end
	
	if type == 0 then
		type = slot:GetUserIValue("INSTRUMENT_SCALE_TYPE");
	end

	local cls = GetClassByType("instrument_scale", type);	
	if cls == nil then
		return;
	end

	Instrument.ReqStopInstrument(cls.ClassID);
end
