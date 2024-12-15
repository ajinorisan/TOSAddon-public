function MINIMIZED_GUILD_COLONY_INFO_ON_INIT(addon, frame)
	addon:RegisterMsg('GAME_START', 'ON_GUILDCOLONY_PLAYING_UPDATE')
	addon:RegisterMsg('IN_COLONYWAR_STATE', 'ON_GUILDCOLONY_PLAYING_UPDATE')
	addon:RegisterMsg('COLONY_STATE_UPDATE', 'ON_GUILDCOLONY_PLAYING_UPDATE')
end

function ON_GUILDCOLONY_PLAYING_UPDATE(frame, msg, arg_str, arg_num)
	if msg == 'GAME_START' or msg == 'IN_COLONYWAR_STATE' then
		frame:ShowWindow(BoolToNumber(IS_COLONY_PROGRESS()))
	elseif msg == 'COLONY_STATE_UPDATE' then
		COLONY_BATTLE_INFO_ICON_NOTICE(arg_num)
	end
end

function TOGGLE_COLONY_INFO(parent, ctrl)
    if IS_COLONY_PROGRESS() == false then
        ui.CloseFrame('colony_battle_info')
        return
    end

	local frame = ui.GetFrame('colony_battle_info')
	if frame:IsVisible() == 1 then
		ui.CloseFrame('colony_battle_info')
	else
		ui.OpenFrame('colony_battle_info')
	end
end

function COLONY_BATTLE_INFO_ICON_NOTICE(enable)
	if IS_COLONY_PROGRESS() == false then
		ui.CloseFrame('minimized_guild_colony_info')
		return
	end

	local frame = ui.GetFrame('minimized_guild_colony_info')
	if enable == 1 then
		frame:ShowWindow(1)
		local openBtn = GET_CHILD_RECURSIVELY(frame, 'openBtn')
		UI_PLAYFORCE(openBtn, 'emphasize_pvp', 0, 0)
	else
		frame:ShowWindow(0)
	end
end