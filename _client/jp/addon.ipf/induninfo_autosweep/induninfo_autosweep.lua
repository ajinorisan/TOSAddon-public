function INDUNINFO_AUTOSWEEP_UI_OPEN(frame)
end

function INDUNINFO_AUTOSWEEP_UI_CLOSE(frame)
    frame:ShowWindow(0)
end

function INDUNINFO_AUTOSWEEP_INIT(frame, arg_str, arg_num)
	if frame == nil then return; end
	local info_text = GET_CHILD_RECURSIVELY(frame, "text");
	if info_text ~= nil then
		local msg = ScpArgMsg(arg_str);
		info_text:SetText(msg);
	end
	local btn = GET_CHILD_RECURSIVELY(frame, "auto_sweep_btn");
	if btn ~= nil then
		btn:SetUserValue("MOVE_INDUN_CLASSID", arg_num);
	end
end

function INDUNINFO_AUTOSWEEP_REQUEST(frame, ctrl)
	if frame == nil then return; end
	if frame:IsVisible() == 0 then return; end
    -- 매칭 던전중이거나 pvp존이면 이용 불가
    if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end
    -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
    if world.GetLayer() ~= 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end
    -- 레이드 지역에서 이용 불가
    local map = GetClass('Map', session.GetMapName());
    local keyword = TryGetProp(map, 'Keyword', 'None');
    local keyword_table = StringSplit(keyword, ';');
    if table.find(keyword_table, 'IsRaidField') > 0 or table.find(keyword_table, 'WeeklyBossMap') > 0 then
        ui.SysMsg(ScpArgMsg('ThisLocalUseNot'));
        return;
    end
    -- 인던 체크
    if ctrl ~= nil then
        local indun_classid = tonumber(ctrl:GetUserValue("MOVE_INDUN_CLASSID"));
        local indun_cls = GetClassByType("Indun", indun_classid);
        local dungeon_type = TryGetProp(indun_cls, "DungeonType", "None");
        local auto_sweep_enable = TryGetProp(indun_cls, "AutoSweepEnable", "None");
        if auto_sweep_enable ~= "YES" and dungeon_type ~= "Raid" and dungeon_type ~= "EarringRaid" and dungeon_type ~= "MythicDungeon_Auto" and dungeon_type ~= "MythicDungeon_Auto_Hard" then
            return;
        end
        ReqUseRaidAutoSweep(indun_classid);
    end
end