﻿function TARGETINFOTOBOSS_ON_INIT(addon, frame)
	addon:RegisterMsg('TARGET_SET_BOSS', 'TARGETINFOTOBOSS_TARGET_SET');
	addon:RegisterMsg('TARGET_BUFF_UPDATE', 'TARGETINFOTOBOSS_ON_MSG');
	addon:RegisterMsg('TARGET_CLEAR_BOSS', 'TARGETINFOTOBOSS_ON_MSG');
	addon:RegisterMsg('TARGET_UPDATE', 'TARGETINFOTOBOSS_ON_MSG');
	addon:RegisterMsg('UPDATE_SDR', 'TARGETINFOTOBOSS_UPDATE_SDR');
	addon:RegisterMsg("MISS_CHECK_SHOW_ICON", "TARGETINFOTOBOSS_MISSCHECK");
	addon:RegisterMsg("MISS_CHECK_REMOVE_ICON", "TARGETINFOTOBOSS_MISSCHECK_ICON_REMOVE");

	local timer = frame:GetChild("addontimer");
	tolua.cast(timer, "ui::CAddOnTimer");
	timer:SetUpdateScript("UPDATE_BOSS_DISTANCE");
	timer:Start(0.1);
 end
 
 function UPDATE_BOSS_DISTANCE(frame)
 	local handle = session.GetTargetBossHandle();
	local targetinfo = info.GetTargetInfo(handle);
	if nil == targetinfo then
		session.ResetTargetBossHandle();
		frame:ShowWindow(0);
		return;
	end
 end

function TARGETINFOTOBOSS_UPDATE_SDR(frame, msg, argStr, SDR)
	local imagename = "dice_" .. SDR;
	local animpic = GET_CHILD(frame, "spl", "ui::CAnimPicture");
	animpic:SetFixImage(imagename);
	animpic:PlayAnimation();
end

function TARGETINFOTOBOSS_BUFF_UPDATE(frame, msg, argStr, argNum)
	TARGETINFOTOBOSS_TARGET_SET(frame, msg, argStr, argNum);
end

function TARGETINFOTOBOSS_TARGET_SET(frame, msg, argStr, argNum)
	if argStr == "None" or argNum == nil then
		return;
	end
	
	local targetHandle = argNum ;
	local targetinfo = info.GetTargetInfo(argNum);
	if targetinfo == nil then
		session.ResetTargetBossHandle();
		frame:ShowWindow(0);
		return;
	end

	if 0 == targetinfo.TargetWindow or targetinfo.isBoss == 0 then
		session.ResetTargetBossHandle();
		frame:ShowWindow(0);
		return;
	end

	local boss_attribute_img = GET_CHILD_RECURSIVELY(frame, "boss_attribute_img");
	local attribute = targetinfo.attribute
    local attributeImgName = "attribute_"..attribute
	if attributeImgName == "None" then
		boss_attribute_img:ShowWindow(0)
	else
		boss_attribute_img:ShowWindow(1)
		boss_attribute_img:SetImage(attributeImgName)
	end

	-- name
	local nametext = GET_CHILD_RECURSIVELY(frame, "name", "ui::CRichText");
	local mypclevel = GETMYPCLEVEL();
    local levelColor = "";
    if mypclevel + 10 < targetinfo.level then
        nametext:SetTextByKey('color', frame:GetUserConfig("MON_NAME_COLOR_MORE_THAN_10"));
	elseif mypclevel + 5 < targetinfo.level then
        nametext:SetTextByKey('color', frame:GetUserConfig("MON_NAME_COLOR_MORE_THAN_5"));
    else
        nametext:SetTextByKey('color', frame:GetUserConfig("MON_NAME_COLOR_DEFAULT"));
	end
    nametext:SetTextByKey('lv', targetinfo.level);
    nametext:SetTextByKey('name', targetinfo.name);
	
	-- race
	local raceTypeSet = GET_CHILD(frame, "race");    
    local image = raceTypeSet:GetChild('racePic');    
    local imageStr = TARGETINFO_GET_RACE_TYPE_IMAGE(raceTypeSet, targetinfo.raceType);
    image = tolua.cast(image, 'ui::CPicture');    
    image:SetImage(imageStr);

	-- hp
	local stat = targetinfo.stat;
	local hpGauge = GET_CHILD(frame, "hp", "ui::CGauge");
	if hpGauge ~= nil then
	hpGauge:SetPoint(stat.HP, stat.maxHP);
	if targetinfo.isInvincible ~= hpGauge:GetValue() then
		hpGauge:SetValue(targetinfo.isInvincible);
		if targetinfo.isInvincible == 1 then
			hpGauge:SetColorTone("FF111111");
		else
			hpGauge:SetColorTone("FFFFFFFF");
		end
	end
	end
	
	-- hp text
	local strHPValue = TARGETINFO_TRANS_HP_VALUE(targetHandle, stat.HP, frame:GetUserConfig("HPTEXT_STYLESHEET")); 
	local hpText = frame:GetChild('hpText');
	if hpText ~= nil then
		hpText:SetText(strHPValue);
	end

	-- shield
	local boss_shield_update_from_server = frame:GetUserIValue("boss_shield_update_from_server");
	if boss_shield_update_from_server == 0 then
	local shield = stat:GetShieldStr();
	if shield ~= nil and shield ~= "None" and shield ~= "0" then
		local shield_gauge = GET_CHILD_RECURSIVELY(frame, "shield", "ui::CGauge");
		if shield_gauge ~= nil then
			shield_gauge:ShowWindow(1);
			shield_gauge:SetShieldPoint(shield, stat.maxHP);
		end
	else
		local shield_gauge = GET_CHILD_RECURSIVELY(frame, "shield", "ui::CGauge");
		shield_gauge:ShowWindow(0);		
	end
	end

	-- faint
	local cur_faint = targetinfo.cur_faint;
	local max_faint = targetinfo.max_faint;
	if cur_faint > 0 and max_faint > 0 then
		local faint_gauge = GET_CHILD_RECURSIVELY(frame, "faint", "ui::CGauge");
		if faint_gauge ~= nil then
			local diff_faint = max_faint - cur_faint;
			faint_gauge:ShowWindow(1);
			faint_gauge:SetShieldPoint(diff_faint, max_faint);
		end
	else
		local faint_gauge = GET_CHILD_RECURSIVELY(frame, "faint", "ui::CGauge");
		if faint_gauge ~= nil then
			faint_gauge:ShowWindow(0);
		end
	end

	frame:ShowWindow(1);
	frame:Invalidate();
	frame:SetValue(argNum);	-- argNum 가 핸들임
end

function TARGETINFOTOBOSS_ON_MSG(frame, msg, argStr, argNum)
	if msg == 'TARGET_CLEAR_BOSS' then
		session.ResetTargetBossHandle();
		frame:SetVisible(0); -- visible값이 1이면 다른 몬스터 hp gauge offset이 옆으로 밀림.(targetinfo.lua 참조)
		frame:ShowWindow(0);
	end
	
	if msg == 'TARGET_UPDATE' or msg == 'TARGET_BUFF_UPDATE' then
		local target = session.GetTargetBossHandle();
		if target ~= 0 then  
			if session.IsBoss(target) == true then	
				TARGETINFOTOBOSS_TARGET_SET(frame, 'TARGET_SET_BOSS', "Enemy", target)
			end
		end
		
		local stat = info.GetStat(session.GetTargetBossHandle());	
		if stat ~= nil then
			-- hp
			local hpGauge = GET_CHILD(frame, "hp", "ui::CGauge");
			hpGauge:SetPoint(stat.HP, stat.maxHP);
			-- hp text
			local strHPValue = TARGETINFO_TRANS_HP_VALUE(session.GetTargetBossHandle(), stat.HP, frame:GetUserConfig("HPTEXT_STYLESHEET"));
			local hpText = frame:GetChild('hpText');
            hpText:SetText(strHPValue);
			-- shield
			local boss_shield_update_from_server = frame:GetUserIValue("boss_shield_update_from_server");
			if boss_shield_update_from_server == 0 then
			local shield = stat:GetShieldStr();
			if shield ~= nil and shield ~= "None" and shield ~= "0" then
				local shield_gauge = GET_CHILD_RECURSIVELY(frame, "shield", "ui::CGauge");
				if shield_gauge ~= nil then
					shield_gauge:ShowWindow(1);
					shield_gauge:SetShieldPoint(shield, stat.maxHP);
				end
			else
				local shield_gauge = GET_CHILD_RECURSIVELY(frame, "shield", "ui::CGauge");
				shield_gauge:ShowWindow(0);		
			end
			end
			-- faint
			local cur_faint = stat.cur_faint;
			local max_faint = stat.max_faint;
			if cur_faint > 0 and max_faint > 0 then
				local faint_gauge = GET_CHILD_RECURSIVELY(frame, "faint", "ui::CGauge");
				if faint_gauge ~= nil then
					local diff_faint = max_faint - cur_faint;
					faint_gauge:ShowWindow(1);
					faint_gauge:SetShieldPoint(diff_faint, max_faint);
				end
			else
				local faint_gauge = GET_CHILD_RECURSIVELY(frame, "faint", "ui::CGauge");
				if faint_gauge ~= nil then
					faint_gauge:ShowWindow(0);
				end
			end
			if frame:IsVisible() == 0 then
				frame:ShowWindow(1)
			end
			frame:Invalidate();
		end
	end
 end

 function TARGETINFO_GET_RACE_TYPE_IMAGE(monsterRaceSet, raceType)
    local raceStr = '';
    if raceType == 'Klaida' then
	    raceStr = monsterRaceSet:GetUserConfig('IMG_RACE_INSECT');
    elseif raceType == 'Widling' then
        raceStr = monsterRaceSet:GetUserConfig('IMG_RACE_WILD');
    elseif raceType == 'Velnias' then
        raceStr = monsterRaceSet:GetUserConfig('IMG_RACE_DEVIL');
    elseif raceType == 'Forester' then
        raceStr = monsterRaceSet:GetUserConfig('IMG_RACE_PLANT');
    elseif raceType == 'Paramune' then
        raceStr = monsterRaceSet:GetUserConfig('IMG_RACE_VARIATION');
    elseif raceType == 'None' then
        raceStr = monsterRaceSet:GetUserConfig('IMG_RACE_NONE');
    end
    return raceStr;
 end

function TARGETINFOTOBOSS_MISSCHECK(frame, msg, iconName, count)
	if frame == nil then return; end

	local boss_misscheck = GET_CHILD_RECURSIVELY(frame, "boss_misscheck");
	if boss_misscheck == nil then return; end

	local icon = CreateIcon(boss_misscheck);
	if icon ~= nil then
		icon:SetImage(iconName);
		boss_misscheck:SetVisible(1);
		boss_misscheck:SetText("{s13}{ol}{b}"..count, "count", ui.RIGHT, ui.BOTTOM, -5, -3);
	end
end

function TARGETINFOTOBOSS_MISSCHECK_ICON_REMOVE(frame, msg)
	if frame == nil then return; end

	local boss_misscheck = GET_CHILD_RECURSIVELY(frame, "boss_misscheck");
	if boss_misscheck == nil then return; end

	local timer = GET_CHILD_RECURSIVELY(frame, "misschecktimer");
	tolua.cast(timer, "ui::CAddOnTimer");
	timer:SetArgNum(2);
	timer:SetUpdateScript("UPDATE_MISSCHECK_ICON_REMOVE");
	timer:Start(1);
end

function UPDATE_MISSCHECK_ICON_REMOVE(frame, timer, argStr, argNum, time)
	if frame == nil then return; end
	local boss_misscheck = GET_CHILD_RECURSIVELY(frame, "boss_misscheck");
	if boss_misscheck ~= nil then
		if time >= argNum then
			if boss_misscheck:IsBlinking() == 1 then
				boss_misscheck:ReleaseBlink();
			end
			boss_misscheck:SetVisible(0);
			boss_misscheck:SetText("");
			timer:Stop();
		else
			if boss_misscheck:IsBlinking() == 0 then
				boss_misscheck:SetBlink(600000, 1.0, "55FFFFFF", 1);
			end
		end
	end
end

function TARGETINFOTOBOSS_UPDATE_SHIELD(data)
	if data ~= nil and data ~= "None" then
		local frame = ui.GetFrame("targetinfotoboss");
		if frame ~= nil then
			if data == "shield_remove" then
				frame:SetUserValue("boss_shield_update_from_server", 0);
				local shield_gauge = GET_CHILD_RECURSIVELY(frame, "shield", "ui::CGauge");
				if shield_gauge ~= nil then
					shield_gauge:ShowWindow(0);		
				end
			else
				-- HP 설정.
				local target_boss_handle = session.GetTargetBossHandle();
				local stat = info.GetStat(target_boss_handle);	
				if stat ~= nil then
					-- hp
					local hp_gauge = GET_CHILD(frame, "hp", "ui::CGauge");
					hp_gauge:SetPoint(stat.HP, stat.maxHP);
					-- hp text
					local str_hp_value = TARGETINFO_TRANS_HP_VALUE(target_boss_handle, stat.HP, frame:GetUserConfig("HPTEXT_STYLESHEET"));
					local hp_text = frame:GetChild('hpText');
					hp_text:SetText(str_hp_value);
				end
				-- 실드 설정.
				frame:SetUserValue("boss_shield_update_from_server", 1);
				local data_list = StringSplit(data, '/');
				if #data_list > 0 then
					local shield = data_list[1];
					local mhp = tonumber(data_list[2]);
					local shield_gauge = GET_CHILD_RECURSIVELY(frame, "shield", "ui::CGauge");
					if shield_gauge ~= nil then
						shield_gauge:ShowWindow(1);
						shield_gauge:SetShieldPoint(shield, mhp);
					end
				end
			end
			frame:ShowWindow(1);
			frame:Invalidate();
		end
	end
end