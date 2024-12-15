AUTO_MOVE_CNT = 5;

function SCR_ATTACKER_TS_CHASE(selfAi)

	local destAction = selfAi:GetDestAction();
	if 'ATTACK' == destAction then
		selfAi:AttackTarget();
	end

	local arrivalrange = selfAi:GetArriveRange();
	
	-- Main Loop
	while true do

		-- ���� ���� ����

		-- ���� ���� �ȿ� ���� �ߴ��� üũ
		selfAi:UpdateChaseState(arrivalrange);
		local chaseState = selfAi:GetChaseState();

		if chaseState == 'TARGET_MISS' then
			selfAi:ChangeTactics('TS_NONE');
			return;
		end
		
		if chaseState == 'ARRIVED' then
			selfAi:MoveStop();

			-- ��ų
			if 'SKILL' == destAction then
				selfAi:SkillTarget();
			elseif 'SKILL_GROUND' == destAction then
				selfAi:SkillTarget();
				
			-- ������ Pick
			elseif 'PICK' == destAction then
				selfAi:PickTarget();

			-- Trigger ����
			elseif 'TRIGGER' == destAction then
				selfAi:TriggerTarget();				
			
			elseif 'BGEVENT' == destAction then
				selfAi:BGEventTarget();

			-- WatchObject �� ��ũ��Ʈ ����
			elseif 'WATCH' == destAction then
				selfAi:ActivateWatchTarget();
			elseif 'RIDE_CART' == destAction then
				selfAi:RequestRide();
			elseif 'SOCIAL_MODE' == destAction then
				selfAi:SocialTarget();
			end

			-- ���������Ƿ� ���� �������� ����, Ÿ���� ���� ���� ����
			selfAi:ReleaseDest();

			-- AI�� ���� �ൿ ����
			selfAi:ChangeTactics('TS_NONE');
			return;
		 end

		-- ���� ���� ���� ��� ������ �������� ����
		local loopCnt = selfAi:GetAiLoopCnt();
		
		if loopCnt >= AUTO_MOVE_CNT then
			selfAi:MoveToDest();
			loopCnt = 0;
		end
		-- Main Sleep
		selfAi:SetAiLoopCnt(loopCnt + 1);
		sleep(3);
		
	 end
 end
 
function SCR_ATTACKER_TS_CHASE_SKILL_GROUND(selfAi)


	local destAction = selfAi:GetDestAction();

	local arrivalrange = selfAi:GetArriveRange();
	-- Main Loop
	while true do

		local nearEnemyObject = selfAi:GetNearEnemyObject();
		if nearEnemyObject == "YES" then
			selfAi:RequestMoveStop();
			selfAi:ChangeTactics('TS_CHASE');
			return;	
		end

		-- ���� ���� �ȿ� ���� �ߴ��� üũ
		local chaseState = selfAi:GetChaseState(arrivalrange);

		if chaseState == 'TARGET_MISS' then
			selfAi:ChangeTactics('TS_NONE');
			return;
		end

		if chaseState == 'ARRIVED' then

			-- �������� ����� �ൿ
			local destCount  = selfAi:GetDestCount();

			if destCount > 1 then
				selfAi:ReleaseDest();

			else

				selfAi:ReleaseDest();

				selfAi:ChangeTactics('TS_NONE');
				return;
			end
		 end

		selfAi:MoveToDest();

		-- Main Sleep
		sleep(100);
	 end
 end 
 
s_warpTotalTime  = 1.4;
s_warpEndTime	 = 0.3;
s_warpPCHideTime = 1.8;
s_warpSleepTime  = 0.3;
s_warpEffect	 = 0;
 
 function ENTER_QUEST_WARP(actor, argString, warpUpdateType, isMoveMap)
	local fsmActor = GetMyActor();
	if fsmActor:IsDead() == 1 then
		return;
	end

	local scenePos = world.GetActorPos(actor:GetHandleVal());	
	scenePos.y = scenePos.y + s_warpDestYPos;	
	
	actor:SetMoveDestPos(scenePos);
	actor:ReserveArgPos(1);
	actor:SetArgPos(0, world.GetActorPos(actor:GetHandleVal()));
	movie.PlayAnim(actor:GetHandleVal(), "WARP", 1.0, 1);
end

function UPDATE_QUEST_WARP(actor, elapsedTime, argString, warpUpdateType, isMoveMap, enterAppTime)
	local fsmActor = GetMyActor();	
	if fsmActor:IsHitState() == 1 or fsmActor:IsDead() == 1 then
		actor:ActorMoveStop();
		movie.ShowModel(actor:GetHandleVal(), 1);
		return;		
	end
	
	if warpUpdateType == 0 then		-- warp ready
		UPDATE_QUEST_WARP_READY(actor, elapsedTime, argString, warpUpdateType, isMoveMap, enterAppTime);
	elseif warpUpdateType == 1 then	-- warp
		UPDATE_QUEST_WARP_PROC(actor, elapsedTime, argString, warpUpdateType, isMoveMap, enterAppTime);
	elseif warpUpdateType == 2 then	-- warp end
		UPDATE_QUEST_WARP_END(actor, elapsedTime, argString, warpUpdateType, isMoveMap, enterAppTime);
	end	
end

function UPDATE_QUEST_WARP_READY(actor, elapsedTime, argString, warpUpdateType, isMoveMap, enterAppTime)
	local startPos = actor:GetArgPos(0);
	local destPos = actor:GetMoveDestPos();
	
	local ratio = (imcTime.GetAppTime() - enterAppTime) / s_warpTotalTime;
	
	local yPos  = s_warpDestYPos * ratio * ratio * ratio * ratio * ratio + startPos.y;
	startPos.y = yPos;
	
	if ratio < 1.0 then
		actor:SetPos(startPos);
	else
		local isEnableWarpEffect = actor:GetUserIValue("IsEnableWarpEffect");
		if isEnableWarpEffect == 1 then
			local isPlayedWarpEffect = actor:GetUserIValue("IsPlayedWarpEffect");
			if isPlayedWarpEffect == 0 then
				actor:GetEffect():PlayEffect("F_light029_blue", 0.2);
				actor:SetUserValue("IsPlayedWarpEffect", 1);
			end
		end
	end		
	
	if ratio >= 1.0 and (imcTime.GetAppTime() - enterAppTime) > s_warpPCHideTime then				
		if argString == nil or argString ~= "None" then
			ui.Chat(argString);
		end

		actor:SetUserValue("IsEnableWarpEffect", 1);
		return;
	end
end
 
function UPDATE_QUEST_WARP_PROC(actor, elapsedTime, argString, warpUpdateType, isMoveMap, enterAppTime)
	actor:SetJumpAniType(1);

	if isMoveMap == true then
		s_warpSleepTime = 5.0;
	else
		s_warpSleepTime = 0.3;
	end
	if (imcTime.GetAppTime() - enterAppTime) > s_warpSleepTime then
		local scenePos = world.GetActorPos(actor:GetHandleVal());
		scenePos.y = scenePos.y - s_warpDestYPos;
		actor:SetMoveDestPos(scenePos);
		actor:ReserveArgPos(1);
		actor:SetArgPos(0, world.GetActorPos(actor:GetHandleVal()));
		
		actor:GetEffect():RemoveEffect("F_light029_blue", 1);
		
		return;
	end
end

function UPDATE_QUEST_WARP_END(actor, elapsedTime, argString, warpUpdateType, isMoveMap, enterAppTime)
	local ratio = (imcTime.GetAppTime() - enterAppTime) / s_warpEndTime;
	
	if ratio >= 0.2 and ratio < 1.0 then
		local isEnableWarpEffect = actor:GetUserIValue("IsEnableWarpEffect");
		if isEnableWarpEffect == 1 then
			local isPlayedWarpEffect = actor:GetUserIValue("IsPlayedWarpEffect");
			if isPlayedWarpEffect == 0 then
				actor:GetEffect():PlayEffect("F_light029_blue", 0.2);
				actor:SetUserValue("IsPlayedWarpEffect", 1);
			end
		end
	end

	if ratio >= 1.0 then
		actor:ProcessVerticalMove(elapsedTime);
		movie.ShowModel(actor:GetHandleVal(), 1);
		return;
	end	
end

function ClearDirectSkillCasting()
	control.ClearDirectSkill();
	control.AutoShotOn();
end


function SELECT_QUEST_WARP()

	if world.GetLayer() ~= 0 then
		return;
	end

	local frame = ui.GetFrame('questwarp');
	OPEN_QUESTWARP_FRAME(frame);
end

function ENTER_INTE_WARP(actor, argString, warpUpdateType, isMoveMap)
	local fsmActor = GetMyActor();
	
	if fsmActor == nil then
		return
	end

	if fsmActor:IsDead() == 1 then
		return;
	end

	local scenePos = world.GetActorPos(actor:GetHandleVal());	
	scenePos.y = scenePos.y + s_warpDestYPos;
	
	actor:SetMoveDestPos(scenePos);
	actor:ReserveArgPos(1);
	actor:SetArgPos(0, world.GetActorPos(actor:GetHandleVal()));
	actor:SetUserValue("WarpRequested", 0);
	movie.PlayAnim(actor:GetHandleVal(), "WARP", 1.0, 1);
end

function UPDATE_INTE_WARP(actor, elapsedTime, argString, warpUpdateType, isMoveMap, enterAppTime)
	local fsmActor = GetMyActor();	
	if fsmActor:IsHitState() == 1 or fsmActor:IsDead() == 1 then
		actor:ActorMoveStop();
		movie.ShowModel(actor:GetHandleVal(), 1);
		return;		
	end

	if warpUpdateType == 0 then		-- warp ready
		UPDATE_INTE_WARP_READY(actor, elapsedTime, argString, warpUpdateType, isMoveMap, enterAppTime);
	elseif warpUpdateType == 1 then	-- warp
		UPDATE_INTE_WARP_PROC(actor, elapsedTime, argString, warpUpdateType, isMoveMap, enterAppTime);
	end	
end

function UPDATE_INTE_WARP_READY(actor, elapsedTime, argString, warpUpdateType, isMoveMap, enterAppTime)
    local ratio = (imcTime.GetAppTime() - enterAppTime) / s_warpTotalTime;
    local isHide = (imcTime.GetAppTime() - enterAppTime) > s_warpPCHideTime;

    local startPos = actor:GetArgPos(0);
    local destPos = actor:GetMoveDestPos();
    
    startPos.y = s_warpDestYPos * ratio * ratio * ratio * ratio * ratio + startPos.y;
	
    if ratio < 1.0 then
        actor:SetPos(startPos);
        return;
    end

    if actor:GetUserIValue("WarpRequested") == 1 then
        return;
    end

    if isHide then
        INTE_WARP_EXEC(argString);

        actor:GetEffect():PlayEffect("F_light029_blue", 0.2);
        actor:SetUserValue("WarpRequested", 1);

        return;
    end
end

function INTE_WARP_EXEC(argString)
    local sageWarp, sageWarpEnd= string.find(argString,'friends.SageSkillGoFriend');
    if nil ~= sageWarp then
        local length = string.len(argString);
        local string = string.sub(argString, sageWarpEnd+2, length-1)
        local sList = StringSplit(string, ",");
        if #sList >= 6 then
            friends.SageSkillGoFriend(sList[1], tonumber(sList[2]), tonumber(sList[2]), tonumber(sList[2]), tonumber(sList[2]), tonumber(sList[2]));
        end
    else
        if argString == nil or argString ~= "None" then
            ui.Chat(argString);	
        end
    end
end
 
function UPDATE_INTE_WARP_PROC(actor, elapsedTime, argString, warpUpdateType, isMoveMap, enterAppTime)
	actor:SetJumpAniType(1);
	movie.ShowModel(actor:GetHandleVal(), 0);
	
	if isMoveMap == true then
		s_warpSleepTime = 5.0;
	else
		s_warpSleepTime = 0.3;
	end
	
	if (imcTime.GetAppTime() - enterAppTime) > s_warpSleepTime then
		local scenePos = world.GetActorPos(actor:GetHandleVal());
		scenePos.y = scenePos.y - s_warpDestYPos;
		actor:SetMoveDestPos(scenePos);
		actor:ReserveArgPos(1);
		actor:SetArgPos(0, world.GetActorPos(actor:GetHandleVal()));
		
		actor:GetEffect():RemoveEffect("F_light029_blue", 1);		
		return;
	end
end