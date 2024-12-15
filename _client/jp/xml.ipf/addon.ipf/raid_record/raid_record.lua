local json = require "json_imc"

function RAID_RECORD_ON_INIT(addon, frame)
	addon:RegisterMsg('REQ_PLAYER_CONTENTS_RECORD', 'REQ_PLAYER_CONTENTS_RECORD');
end


function RAID_RECORD_OPEN(frame, msg, argStr, argNum)	
	local frame = ui.GetFrame("raid_record")
	RAID_RECORD_INIT(frame)
    GetPlayerRecord('callback_get_player_before_record', argStr)
end


function RAID_RECORD_CLOSE(frame)
	frame:ShowWindow(0);
end


local function sort_by_value(tbl, sortFunction)
    local keys = {}
    for key in pairs(tbl) do
      table.insert(keys, key)
    end
  
    table.sort(keys, function(a, b)
      return sortFunction(tbl[a], tbl[b])
    end)
  
    return keys
end

function RAID_RECORD_SET_DATA(list, my_time)
	local frame = ui.GetFrame("raid_record")
	frame:ShowWindow(1);


	local pc = GetMyPCObject()
	local etc = GetMyEtcObject()
	local mySession = session.GetMySession();

	local jobClsID = TryGetProp(etc, 'RepresentationClassID', 'None')
	if jobClsID == 'None' or tonumber(jobClsID) == 0 then
		jobClsID = info.GetJob(mySession);
	end

	local jobCls = GetClassByType('Job', jobClsID);
    local jobIcon = TryGetProp(jobCls, 'Icon');
    if jobIcon == nil then
        return;
	end    

	local myInfo = GET_CHILD_RECURSIVELY(frame, 'myInfo')
	local nameText = GET_CHILD_RECURSIVELY(myInfo, 'name');

	nameText:SetTextByKey('value', info.GetFamilyName(session.GetMyHandle()))
	if my_time ~= nil then
		local record_time = GET_CHILD_RECURSIVELY(frame, 'textRecord');
		local time = GET_CHILD_RECURSIVELY(myInfo, 'time');

		record_time:SetTextByKey('value', my_time);
		time:SetTextByKey('value', my_time)
	end
	for i = 1, 3 do
		GET_CHILD_RECURSIVELY(frame, 'friendInfo'..i):ShowWindow(0)
	end
    local sortedKeys = sort_by_value(list, function(a, b) return a < b end)
	for i = 1, #sortedKeys do
		if i > 3 then
			return;
		end

        local key = sortedKeys[i]
        local f = session.friends.GetFriendByAID(FRIEND_LIST_COMPLETE, key);
		if nil ~= f then
			local iconInfo = f:GetInfo():GetIconInfo();
			local iconName = ui.CaptureModelHeadImage_IconInfo(iconInfo);
			local friendInfo = GET_CHILD_RECURSIVELY(frame, 'friendInfo'..i)
			friendInfo:ShowWindow(1)

			local nameText = GET_CHILD_RECURSIVELY(friendInfo, 'name');
			local gear = GET_CHILD_RECURSIVELY(friendInfo, 'gear');
			local time = GET_CHILD_RECURSIVELY(friendInfo, 'time');
			local jobCls = GetClassByType('Job', iconInfo.job);
			local jobIcon = TryGetProp(jobCls, 'Icon');
			if jobIcon == nil then
				return;
			end    
 
			nameText:SetTextByKey('value', f:GetInfo():GetFamilyName())
			time:SetTextByKey('value', GetTimeRecodeFormat(tonumber(list[key])))
        end
	end
end

function callback_get_player_current_record(code, ret_json, contents)
	if ret_json == '' then
		ui.SysMsg(ClMsg("TryLater"))
		return
	end
	
	local return_model = json.decode(ret_json)
	if return_model == 43 then
		ui.SysMsg(ClMsg("TryLater"))
		return;
	end
	local my_time = return_model['my_time']
    if my_time == 0 then
		my_time = ClMsg('NoRecord')
	else
		my_time = GetTimeRecodeFormat(my_time)
	end
    local list = return_model['info']
	
	RAID_RECORD_SET_DATA(list)
end

function callback_get_player_before_record(code, ret_json, contents)
	if ret_json == '' then
		ui.SysMsg(ClMsg("TryLater"))
		return
	end

	local return_model = json.decode(ret_json)	
	if return_model == 43 then
		ui.SysMsg(ClMsg("TryLater"))
		return;
	end
	
	local my_time = return_model['my_time']
	if my_time == 0 then
		my_time = ClMsg('NoRecord')
	else
		my_time = GetTimeRecodeFormat(my_time)
	end
    
    local list = return_model['info']
	
	RAID_RECORD_SET_DATA(list, my_time)
end

function RAID_RECORD_INIT(frame)
	GET_CHILD_RECURSIVELY(frame, 'bgIndunClear'):ShowWindow(1)
	GET_CHILD_RECURSIVELY(frame,'textNewRecord'):ShowWindow(0);
end

function REQ_PLAYER_CONTENTS_RECORD(frame, msg, arg_str, state)

	RAID_RECORD_INIT(frame)

    local token = StringSplit(arg_str, ';')
    local name = token[1]
    local before = token[2]
    local record = token[3]
	
	local record_time = GET_CHILD_RECURSIVELY(frame, 'textRecord');
	local myInfo = GET_CHILD_RECURSIVELY(frame, 'myInfo')
	local time = GET_CHILD_RECURSIVELY(myInfo, 'time');

	record_time:SetTextByKey('value', record);

    if state == 1 or state == 2 then
		-- 기록 경신
		GET_CHILD_RECURSIVELY(frame,'textNewRecord'):ShowWindow(1);
		RAID_NEWRECORD_EFFECT(frame)
		time:SetTextByKey('value', record)
	else
		time:SetTextByKey('value', before)
    end

	GetPlayerRecord('callback_get_player_current_record', name)
end


function RAID_NEWRECORD_EFFECT(frame)
	if frame ~= nil then
		local effect_name = frame:GetUserConfig("DO_NEWRECORD_EFFECT");
		local effect_scale = tonumber(frame:GetUserConfig("NEWRECORD_EFFECT_SCALE"));
		local effect_duration = tonumber(frame:GetUserConfig("NEWRECORD_EFFECT_DURATION"));
		local effect_bg = GET_CHILD_RECURSIVELY(frame, "success_effect_bg");
		if effect_bg ~= nil then
			effect_bg:PlayUIEffect(effect_name, effect_scale, "DoNewRecordEffect");
			ReserveScript("_RAID_NEWRECORD_EFFECT()", effect_duration);
		end
	end
end

function _RAID_NEWRECORD_EFFECT()
	local frame = ui.GetFrame("raid_record");
	if frame == nil then return; end
	if frame:IsVisible() == 0 then return; end
	local effect_bg = GET_CHILD_RECURSIVELY(frame, "success_effect_bg");
	if effect_bg ~= nil then
		effect_bg:StopUIEffect("DoNewRecordEffect", true, 0.5);
		ui.SetHoldUI(false);
	end
end