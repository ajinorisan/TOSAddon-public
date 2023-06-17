function CONTENTS_ALERT_ON_INIT(addon, frame)
	addon:RegisterMsg('SHOW_CONTENTS_ALERT_UI', 'CONTENTS_ALERT_OPEN');
	addon:RegisterMsg('GAME_START', 'CONTENTS_ALERT_OPEN_POPUP');
end

g_showIndex = 0

function CONTENTS_ALERT_OPEN(frame, msg, argStr, argNum)
	local frame = ui.GetFrame("contents_alert")
	local text = GET_CHILD_RECURSIVELY(frame,"text")
	local yesBtn = GET_CHILD(frame, "yesBtn")
	local cls = GetClassByType("contents_alert_table", argNum)
	local gearScore = CONTENTS_ALERT_GET_CUTLINE(argNum)
	local contentsName = TryGetProp(cls, "ContentsName")

	local indunName = TryGetProp(cls, "IndunName")

	text:SetTextByKey("value", ScpArgMsg('ContentsAlert_SysMsg_1', 'SCORE', gearScore, 'MGAMENAME', contentsName))

	yesBtn:SetEventScript(ui.LBUTTONUP, "CONTENTS_ALERT_MOVE_CHECK");
	yesBtn:SetEventScriptArgNumber(ui.LBUTTONUP, argNum);

	OPEN_CONTENTS_ALERT_REWARD(argNum)
	frame:ShowWindow(1)
end

function CONTENTS_ALERT_CLOSE()
	ui.CloseFrame("contents_alert")
	ui.CloseFrame("contents_alert_reward")
end


function CONTENTS_ALERT_MOVE_CHECK(parent, self, argStr, argNum)
	ui.CloseFrame("contents_alert_reward")
	local cls = GetClassByType("contents_alert_table", argNum)
	local mapName = TryGetProp(cls, "MapName")
	local moveForce = TryGetProp(cls, "MoveForce")

	if moveForce == 1 or mapName ~= GetZoneName(self) then
		local text = GET_CHILD_RECURSIVELY(parent,"text")
		local yesBtn = GET_CHILD(parent, "yesBtn")
		text:SetTextByKey("value", ScpArgMsg('ContentsAlert_SysMsg_3'))
		yesBtn:SetEventScript(ui.LBUTTONUP, "CONTENTS_ALERT_REQUEST_MOVE");
		yesBtn:SetEventScriptArgNumber(ui.LBUTTONUP, argNum);
	else
		parent:ShowWindow(0)
		CONTENTS_ALERT_OPEN_POPUP(nil, nil, nil, argNum)
	end
end

function CONTENTS_ALERT_REQUEST_MOVE(frame, self, argStr, argNum)
	local cls = GetClassByType("contents_alert_table", argNum)
	local mapName = TryGetProp(cls, "MapName")
	g_showIndex = argNum
	contents_alert.RequestMove()
	frame:ShowWindow(0)

	if mapName == GetZoneName(self) then
		CONTENTS_ALERT_OPEN_POPUP(nil, nil, nil, argNum)
	end
end

function CONTENTS_ALERT_OPEN_POPUP(parent, self, argSt, argNum)
	local cls = GetClassByType("contents_alert_table", argNum)
	if cls == nil then
		cls = GetClassByType("contents_alert_table", g_showIndex)
	end
	g_showIndex = 0
	if cls == nil then
		return;
	end

	local ShowNpcInfo = TryGetProp(cls, "ShowNpcInfo")

	if ShowNpcInfo ~= "None" then
		local str = ScpArgMsg("ContentsAlert_SysMsg_4", "NPCNAME", ShowNpcInfo)
		local msgBox = ui.MsgBox_OneBtnScp(str, "None");
		return;
	end

	local indunInfo = TryGetProp(cls, "ShowIndunInfo")
	local dungeonType = "None"

	if indunInfo == "MythicDungeon_Auto" then
		dungeonType = indunInfo
	else
		local indunCls = GetClass("Indun", indunInfo)
		dungeonType = TryGetProp(indunCls, "DungeonType")
	end

	local isRaid = (dungeonType == 'UniqueRaid' or dungeonType == 'Raid' or dungeonType == 'GTower' or dungeonType == "MythicDungeon_Auto" or dungeonType == "MythicDungeon_Auto_Hard") or dungeonType == "MythicDungeon";
	local frame = ui.GetFrame("induninfo")
	frame:ShowWindow(1)

	if isRaid == true then	
		INDUNINFO_UI_OPEN(frame, 2, indunInfo)
	else
		INDUNINFO_UI_OPEN(frame, 1, indunInfo)
	end
end