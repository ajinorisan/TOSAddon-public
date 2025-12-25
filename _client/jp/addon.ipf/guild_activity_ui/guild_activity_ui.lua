-- guild_activity_ui.lua
local s_guild_activity_menu_list = {}
local s_guild_activity_detail_scp_list = {}
local s_guild_activity_guild_quest_reward_info_list = {}
local CATEGORY = { GUILD_GROWTH = 1, GUILD_QUEST = 2, GUILD_TOWER = 3 }
local MENU_IDX = { BOSS_RAID = 1, MISSION = 2, BLOCKADE = 3 }

function GUILD_ACTIVITY_UI_ON_INIT(addon, frame)
	addon:RegisterOpenOnlyMsg("GUILD_PROPERTY_UPDATE", "UPDATE_GUILD_ACTIVITY_GUILD_GROWTH")
	addon:RegisterOpenOnlyMsg("GUILD_MEMBER_PROP_UPDATE", "UPDATE_GUILD_ACTIVITY_GUILD_GROWTH")
	addon:RegisterMsg("GUILD_ACTIVITY_AGIT_EXTENSION", "ON_GUILD_ACTIVITY_AGIT_EXTENSION")
end

local function GetGuildActivity_MenuCount(frame, category_type)
	local gbox = GET_CHILD_RECURSIVELY(frame, "category_gbox")
	if gbox ~= nil then
		local count = gbox:GetChildCount()
		for i = count - 1, 0, -1 do
			local child = gbox:GetChildByIndex(i)
			if child ~= nil then
				local user_value = tonumber(child:GetUserValue("CATEGORY_TYPE"))
				if user_value == category_type then
					return tonumber(child:GetUserValue("MENU_COUNT"))
				end
			end
		end
	end
	return 0
end

local function GetGuildActivity_MenuClassName(category_type, index)
	if s_guild_activity_menu_list == nil or #s_guild_activity_menu_list <= 0 then
		s_guild_activity_menu_list[1] = { "GuildGrowth", "GuildAbility", "GuildAgitExtension" }
		s_guild_activity_menu_list[2] = { "GuildIBossSummon", "GuildMission", "GuildBlockade" }
		s_guild_activity_menu_list[3] = { "GuildCraftTimeReduceBuff", "GuildAgitMove", "GuildTowerControl" }
	end

	local menu_list = s_guild_activity_menu_list[category_type]
	if menu_list == nil or #menu_list <= 0 then
		return "None"
	end

	return menu_list[index]
end

local function GetGuildActivity_MenuIndex(category_type, menu_class_name)
	if s_guild_activity_menu_list ~= nil and #s_guild_activity_menu_list > 0 then
		local menu_list = s_guild_activity_menu_list[category_type]
		if menu_list ~= nil and #menu_list > 0 then
			for index, menu in ipairs(menu_list) do
				if menu == menu_class_name then
					return index
				end
			end
		end
	end
	return nil
end

local function GetMyGuildObject()
	local guild_obj = nil
	local guild = session.party.GetPartyInfo(PARTY_GUILD)
	if guild ~= nil then
		guild_obj = GetIES(guild:GetObject())
	end
	return guild_obj
end

local function RemoveChildByPattern(parent, pattern)
	if parent == nil then
		return
	end
	local count = parent:GetChildCount()
	for i = count - 1, 0, -1 do
		local child = parent:GetChildByIndex(i)
		if child ~= nil and string.find(child:GetName(), pattern) ~= nil then
			parent:RemoveChild(child:GetName())
		end
	end
end

---- UI Start & End
function UI_TOGGLE_GUILD_ACTIVITY()
    if app.IsBarrackMode() == true then
		return;
    end
    if session.world.IsIntegrateServer() == true then
        ui.SysMsg(ScpArgMsg("CantUseThisInIntegrateServer"))
        return
    end

    local guildinfo = session.GetGuildInfo();
    if guildinfo == nil then
        return
    end
	
	ui.ToggleFrame('guild_activity_ui')
end

function ON_GUILD_ACTVITIY_OPEN(frame)
	INIT_GUILD_ACTIVITY_DEATIL(frame)
	INIT_GUILD_ACTIVITY_CATEGORY(frame)
	INIT_GUILD_ACTIVITY_MENU(frame)
	INIT_GUILD_ACTIVITY_BLOCKADE_RANK()
	INIT_GUILD_ACTIVITY_GUILD_QUEST_REWARD_INFO()
end

function ON_GUILD_ACTIVITY_CLOSE(frame)
	ui.CloseFrame("guild_activity_ui")
	s_guild_activity_menu_list = {}
	s_guild_activity_detail_scp_list = {}
	s_guild_activity_guild_quest_reward_info_list = {}
end

---- init
-- init - category
function INIT_GUILD_ACTIVITY_CATEGORY(frame)
	local guild_growth_btn = GET_CHILD_RECURSIVELY(frame, "category_guild_growth_btn")
	if guild_growth_btn ~= nil then
		guild_growth_btn:SetUserValue("MENU_COUNT", 3)
		guild_growth_btn:SetUserValue("CATEGORY_TYPE", 1)
	end
	local guild_quest_btn = GET_CHILD_RECURSIVELY(frame, "category_guild_quest_btn")
	if guild_quest_btn ~= nil then
		guild_quest_btn:SetUserValue("MENU_COUNT", 3)
		guild_quest_btn:SetUserValue("CATEGORY_TYPE", 2)
	end
	local guild_tower_btn = GET_CHILD_RECURSIVELY(frame, "category_guild_tower_btn")
	if guild_tower_btn ~= nil then
		guild_tower_btn:SetUserValue("MENU_COUNT", 3)
		guild_tower_btn:SetUserValue("CATEGORY_TYPE", 3)
	end

	local select_category_type = tonumber(frame:GetUserValue("SELECT_CATEGORY_TYPE"))
	if select_category_type == nil or select_category_type == 0 then
		select_category_type = 1
		frame:SetUserValue("SELECT_CATEGORY_TYPE", select_category_type)
	end
	-- select categroy
	GUILD_ACTIVITY_CATEGORY_SELECT_LBTN(frame, guild_growth_btn)
end

-- init - menu
function INIT_GUILD_ACTIVITY_MENU(frame)
	local select_category_type = tonumber(frame:GetUserValue("SELECT_CATEGORY_TYPE"))
	local gbox = GET_CHILD_RECURSIVELY(frame, "menu_gbox")
	if gbox ~= nil then
		local menu = GET_CHILD_RECURSIVELY(gbox, "GuildActivity_Menu_1")
		if menu ~= nil then
			local gb = GET_CHILD_RECURSIVELY(menu, "gb")
			local btn = GET_CHILD_RECURSIVELY(menu, "select")

			local menu_class_name = menu:GetUserValue("MENU_CLASS_NAME")
			frame:SetUserValue("SELECT_MENU_CLASS_NAME", menu_class_name)

			local index = GetGuildActivity_MenuIndex(select_category_type, menu_class_name)
			SET_VISIBLE_GUILD_ACTIVITY_DEATIL_GBOX(frame, select_category_type, index)
			MAKE_GUILD_ACTIVITY_DEATIL_GBOX(frame, select_category_type, menu_class_name, index)
			GUILD_ACTIVITY_SET_DETAIL_TITLE(frame, menu_class_name)
		end
	end
end

-- init - detail
function INIT_GUILD_ACTIVITY_DEATIL(frame)
	housing.RequestGuildAgitInfo("GUILD_AGIT_INFO_RECEIVE")
	if s_guild_activity_detail_scp_list == nil or #s_guild_activity_detail_scp_list <= 0 then
		s_guild_activity_detail_scp_list[1] = {
			GuildGrowth = { "CREATE_GUILD_ACTIVITY_DETAIL_GUILD_GROWTH_INFO", "REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_GROWTH_INFO" },
			GuildAbility = { "CREATE_GUILD_ACTIVITY_DETAIL_GUILD_ABILITY_INFO", "REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_ABILITY_INFO" },
			GuildAgitExtension = { "CREATE_GUILD_ACTIVITY_DETAIL_AGIT_EXTENSION_INFO", "REMOVE_GUILD_ACTIVITY_DETAIL_AGIT_EXTENSION_INFO" }
		}	
		s_guild_activity_detail_scp_list[2] = {
			GuildIBossSummon = { "CREATE_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_INFO", "REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_INFO" },
			GuildMission = { "CREATE_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_INFO", "REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_INFO" },
			GuildBlockade = { "CREATE_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_INFO", "REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_INFO" }
		}
		s_guild_activity_detail_scp_list[3] = {
			GuildCraftTimeReduceBuff = { "CREATE_GUILD_ACTIVITY_DETAIL_CRAFT_TIME_REDUCE_BUFF_INFO", "None" },
			GuildAgitMove = { "CREATE_GUILD_ACTIVITY_DETAIL_AGIT_MOVE", "REMOVE_GUILD_ACTIVITY_DETAIL_AGIT_MOVE" },
			GuildTowerControl = { "CREATE_GUILD_ACTIVITY_DETAIL_TOWER_CONTROL", "None" }
		}
	end
end

-- init - blockade rank : reserve script
function HOLD_GUILD_ACTIVITY_BLOCKADE_RANK_UNFREEZE()
	local frame = ui.GetFrame("guild_activity_ui")
	if frame ~= nil then
		local rank_list_gbox = GET_CHILD_RECURSIVELY(frame, "guild_blockade_rank_list_gbox")
		if rank_list_gbox ~= nil then
			rank_list_gbox:EnableHitTest(1)
		end
	end
end

-- init - blockade rank : rank data
function INIT_GUILD_ACTIVITY_BLOCKADE_RANK()
	local frame = ui.GetFrame("guild_activity_ui")
	if frame ~= nil then
		local rank_list_gbox = GET_CHILD_RECURSIVELY(frame, "guild_blockade_rank_list_gbox")
		if rank_list_gbox ~= nil then
			rank_list_gbox:EnableHitTest(0)
			rank_list_gbox:RemoveAllChild()
			ReserveScript("HOLD_GUILD_ACTIVITY_BLOCKADE_RANK_UNFREEZE()", 1)
		end
	
		local now_time = geTime.GetServerSystemTime()
		local end_time = session.boruta_ranking.GetBorutaEndTime()
		local week_num = GET_WEEK_NUM_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_REWARD_INFO(frame)
		if week_num < 1 then
			boruta.RequestBorutaNowWeekNum()
		elseif imcTime.IsLaterThan(now_time, end_time) ~= 0 then
			boruta.RequestBorutaEndTime(week_num)
        	boruta.RequestBorutaNowWeekNum()  
		end

		local event_type = GET_EVENT_TYPE_AND_BOSS_NAME_GUILD_ACTIVITY_DETAIL_BLOCAKDE_RANK()
		boruta.RequestBorutaStartTime(week_num) 
    	boruta.RequestBorutaEndTime(week_num)
		boruta.RequestBorutaRankList(week_num, event_type)
    	boruta.RequestBorutaAcceptedRewardInfo(week_num)

		REMOVE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK(frame)
		CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_REWARD_INFO(frame)
		CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_LIST(frame)
	end
end

-- init - guild quest reward info
function INIT_GUILD_ACTIVITY_GUILD_QUEST_REWARD_INFO()
	if #s_guild_activity_guild_quest_reward_info_list <= 0 then
		guild.RequestGuildQuestRewardInfo()
	end
end

-- init - on guild quest reawrd info
function ON_GUILD_ACTIVITY_GUILD_QUEST_REWARD_INFO(info_list)
	if #s_guild_activity_guild_quest_reward_info_list > 0 then
		return	
	end

	if #info_list <= 0 then
		return
	end

	for i = 1, #info_list do
		local list_str = info_list[i]
		local list = StringSplit(list_str, ';')
		if #list > 0 then
			for j = 1, #list do
				local info_str = list[j]
				local info = StringSplit(info_str, '/')
				if #info > 0 then
					local class_name = info[1]
					local guild_exp = tonumber(info[2])
					s_guild_activity_guild_quest_reward_info_list[i] = { class_name, guild_exp, item_list = {} }

					local item_info_list_str = info[3]
					local item_info_list = StringSplit(item_info_list_str, ',')
					if #item_info_list > 0 then
						for k = 1, #item_info_list do
							local item_info_str = item_info_list[k]
							local item_info = StringSplit(item_info_str, '|')
							if #item_info > 0 then
								local item_class_name = item_info[1]
								local item_count = item_info[2]
								s_guild_activity_guild_quest_reward_info_list[i].item_list[k] = { item_class_name, item_count }
							end
						end
					end
				end
			end
		end
	end
end

---- update
-- update - guild growth category
function UPDATE_GUILD_ACTIVITY_GUILD_GROWTH(frame, msg)
	if frame ~= nil then
		local select_category_type = tonumber(frame:GetUserValue("SELECT_CATEGORY_TYPE"))
		local menu_class_name = frame:GetUserValue("SELECT_MENU_CLASS_NAME")
		local index = GetGuildActivity_MenuIndex(select_category_type, menu_class_name)
		MAKE_GUILD_ACTIVITY_DEATIL_GBOX(frame, select_category_type, menu_class_name, index)
	end
end

---- category
function GUILD_ACTIVITY_CATEGORY_SELECT_LBTN(parent, btn)
	local frame = parent:GetTopParentFrame()
	if frame ~= nil and btn ~= nil then
		local category_type = tonumber(btn:GetUserValue("CATEGORY_TYPE"))
		local select_category_type = tonumber(frame:GetUserValue("SELECT_CATEGORY_TYPE"))
		if select_category_type ~= category_type then
			select_category_type = category_type
			frame:SetUserValue("SELECT_CATEGORY_TYPE", select_category_type)
		end
		-- menu
		REMOVE_GUILD_ACTIVITY_MENU(frame)
		CREATE_GUILD_ACTIVITY_MENU(frame, select_category_type)
		GUILD_ACTIVITY_SET_DETAIL_GUILD_QUEST_TICKET(frame, select_category_type)
	end
end

---- menu
-- menu - menu ctrlset remove
function REMOVE_GUILD_ACTIVITY_MENU(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "menu_gbox")
	if gbox ~= nil then
		RemoveChildByPattern(gbox, "GuildActivity_Menu_")
	end
end

-- menu - menu ctrlset create
function CREATE_GUILD_ACTIVITY_MENU(frame, category_type)
	local gbox = GET_CHILD_RECURSIVELY(frame, "menu_gbox")
	if gbox ~= nil then
		local y = 0
		local offset_y = frame:GetUserConfig("MENU_START_Y")
		local add_y = frame:GetUserConfig("MENU_ADD_Y")
		local count = GetGuildActivity_MenuCount(frame, category_type)
		local ctrlset_height = ui.GetControlSetAttribute("guild_activity_menu", "height")
		for i = 1, count do
			y = ((ctrlset_height + add_y) * (i - 1)) + offset_y
			local menu = gbox:CreateOrGetControlSet("guild_activity_menu", "GuildActivity_Menu_"..i, 0, y)
			if menu ~= nil then
				local menu_class_name = GetGuildActivity_MenuClassName(category_type, i)
				menu:SetUserValue("CATEGORY_TYPE", category_type)
				menu:SetUserValue("MENU_CLASS_NAME", menu_class_name)

				local slot = GET_CHILD_RECURSIVELY(menu, "slot")
				if slot ~= nil then
					local icon_name = "icon_guild_housing_coin_01" -- ** test 용도.
					SET_SLOT_IMG(slot, icon_name)
				end

				local name_text = GET_CHILD_RECURSIVELY(menu, "name")
				if name_text ~= nil then
					local text = ScpArgMsg(menu_class_name)
					name_text:SetTextByKey("name", text)
				end
			end
		end
	end
end

-- menu - menu ctrlset click
function GUILD_ACTIVITY_MENU_SELECT_LBTN(parent, btn)
	local frame = parent:GetTopParentFrame()
	local gb = parent:GetParent()
	local ctrlset = gb:GetParent()
	if frame ~= nil and ctrlset ~= nil then
		local select_category_type = tonumber(frame:GetUserValue("SELECT_CATEGORY_TYPE"))
		local category_type = tonumber(ctrlset:GetUserValue("CATEGORY_TYPE"))
		if select_category_type == category_type then
			local menu_class_name = ctrlset:GetUserValue("MENU_CLASS_NAME")
			frame:SetUserValue("SELECT_MENU_CLASS_NAME", menu_class_name)

			local index = GetGuildActivity_MenuIndex(category_type, menu_class_name)
			SET_VISIBLE_GUILD_ACTIVITY_DEATIL_GBOX(frame, category_type, index)
			MAKE_GUILD_ACTIVITY_DEATIL_GBOX(frame, category_type, menu_class_name, index)
			GUILD_ACTIVITY_SET_DETAIL_TITLE(frame, menu_class_name)
		end
	end
end

-- menu - menu name set detail title
function GUILD_ACTIVITY_SET_DETAIL_TITLE(frame, menu_class_name)
	local detail_title = GET_CHILD_RECURSIVELY(frame, "detail_title")
	if detail_title ~= nil then
		local title = ScpArgMsg(menu_class_name)
		detail_title:SetTextByKey("title", title)
	end
end

-- menu - guild quest ticket
function GUILD_ACTIVITY_SET_DETAIL_GUILD_QUEST_TICKET(frame, category_type)
	local guild_quest_ticket_text = GET_CHILD_RECURSIVELY(frame, "detail_guild_quest_ticket_text")
	if guild_quest_ticket_text ~= nil then
		if category_type == CATEGORY.GUILD_QUEST then
			guild_quest_ticket_text:ShowWindow(1)
			local have_ticket = 0
			local guild_obj = GetMyGuildObject()
			if guild_obj ~= nil then
				have_ticket = GET_REMAIN_TICKET_COUNT(guild_obj)
			end
			local text = ScpArgMsg("GuildEvent").." ("..ScpArgMsg("RemainTicket:{Ticket}", "Ticket", have_ticket)..")"
			guild_quest_ticket_text:SetTextByKey("text", text)
		else
			guild_quest_ticket_text:ShowWindow(0)
		end
	end
end

---- detail
---- detail - set visible gbox
function SET_VISIBLE_GUILD_ACTIVITY_DEATIL_GBOX(frame, category_type, menu_idx)
	local detail_box = GET_CHILD_RECURSIVELY(frame, "detail_gbox")
	if detail_box ~= nil then
		local gbox_name = "detail_gbox_"..category_type.."_"..menu_idx
		local count = detail_box:GetChildCount()
		for i = 0, count - 1 do
			local child = detail_box:GetChildByIndex(i)
			if child ~= nil and string.find(child:GetName(), "detail_gbox_") ~= nil then
				if child:GetName() == gbox_name then
					child:ShowWindow(1)
				else
					child:ShowWindow(0)
				end
			end
		end
		local sub_gbox_visible = 0
		SET_VISIBLE_GUILD_ACTIVITY_GUILD_QUEST_DETAIL_SUB_GBOX(frame, sub_gbox_visible)
	end
	frame:Invalidate()
end

---- detail - guild qeust : set visible sub gbox
function SET_VISIBLE_GUILD_ACTIVITY_GUILD_QUEST_DETAIL_SUB_GBOX(frame, visible)
	local guild_sub_gbox_name_list = { "guild_boss_raid_sub_gbox", "guild_mission_sub_gbox", "guild_blockade_sub_gbox", "guild_blockade_rank_gbox" }
	for i = 1, #guild_sub_gbox_name_list do
		local sub_gbox_name = guild_sub_gbox_name_list[i]
		local sub_gbox = GET_CHILD_RECURSIVELY(frame, sub_gbox_name)
		if sub_gbox ~= nil then
			sub_gbox:ShowWindow(visible)
		end
	end
end

---- detail - guild quest : set visible sub gbox by SubType
function SET_VISIBLE_GUILD_ACTIVITY_GUILD_QUEST_DETAIL_SUB_GBOX_SUBTYPE(frame, sub_type, visible)	
	local sub_gbox_name = "None"
	if sub_type == "guild_boss_raid" then
		sub_gbox_name = "guild_boss_raid_sub_gbox"
	elseif sub_type == "guild_mission" then
		sub_gbox_name = "guild_mission_sub_gbox"
	elseif sub_type == "guild_blockade" then
		sub_gbox_name = "guild_blockade_sub_gbox"
	elseif sub_type == "guild_blockade_rank" then
		sub_gbox_name = "guild_blockade_rank_gbox"
	end
	if sub_gbox_name ~= "None" then
		local sub_gbox = GET_CHILD_RECURSIVELY(frame, sub_gbox_name)
		if sub_gbox ~= nil then
			sub_gbox:ShowWindow(visible)
		end
	end
end

---- detail - init group box
function MAKE_GUILD_ACTIVITY_DEATIL_GBOX(frame, category_type, menu_cls_name, menu_idx)
	local name = "detail_gbox_"..category_type.."_"..menu_idx
	local gbox = GET_CHILD_RECURSIVELY(frame, name)
	if gbox ~= nil and gbox:IsVisible() == 1 then
		local remove_scp = s_guild_activity_detail_scp_list[category_type][menu_cls_name][2]
		if remove_scp ~= "None" then
			local remove_func = _G[remove_scp]
			if category_type == CATEGORY.GUILD_QUEST then
				remove_func(frame, gbox, menu_idx)
			else
				remove_func(frame, gbox)
			end
		end

		local make_scp = s_guild_activity_detail_scp_list[category_type][menu_cls_name][1]
		if make_scp ~= "None" then
			local make_func = _G[make_scp]
			if category_type == CATEGORY.GUILD_QUEST then
				make_func(frame, gbox, menu_idx, menu_cls_name)
			else
				make_func(frame, gbox, menu_cls_name)
			end
		end
	end
end

---- detail - guild growth
-- guild growth - remove info
function REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_GROWTH_INFO(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "contribution_rank_gbox")
	if gbox ~= nil then
		RemoveChildByPattern(gbox, "GuildGrowthContribution_Rank_Info_")
	end
end

-- guild growth - create info
function CREATE_GUILD_ACTIVITY_DETAIL_GUILD_GROWTH_INFO(frame, gbox)
	local guild_obj = GetMyGuildObject()
	if guild_obj ~= nil then
		local level = TryGetProp(guild_obj, "Level", 0)
		local next_level = level + 1
		local cur_level_cls = GetClassByType("GuildExp", level) 
		local next_level_cls = GetClassByType("GuildExp", next_level)
		local desc_text = GET_CHILD_RECURSIVELY(frame, "guild_growth_next_level_desc_text")
		if desc_text ~= nil then
			if next_level_cls ~= nil then
				desc_text:SetTextByKey("desc", TryGetProp(next_level_cls, "Desc", "None"))
			else
				desc_text:SetTextByKey("desc", ScpArgMsg("MaxLevel"))
			end
		end

		local cur_exp = TryGetProp(guild_obj, "Exp", 0)
		local ret_exp = cur_exp - TryGetProp(cur_level_cls, "Exp", 0)
		local cur_level_text = GET_CHILD_RECURSIVELY(frame, "guild_growth_cur_level_text")
		local next_level_text = GET_CHILD_RECURSIVELY(frame, "guild_growth_next_level_text")
		local exp_gauge = GET_CHILD_RECURSIVELY(frame, "guild_growth_exp_gauge")
		if cur_level_text ~= nil and next_level_text ~= nil and exp_gauge ~= nil then
			cur_level_text:SetTextByKey("cur_level", level)
			if next_level_cls ~= nil then
				local max_exp = TryGetProp(next_level_cls, "Exp", 0) - TryGetProp(cur_level_cls, "Exp", 0)
				exp_gauge:SetPoint(ret_exp, max_exp)
				next_level_text:SetTextByKey("next_level", next_level)
			else
				exp_gauge:SetPoint(1000, 1000)
				next_level_text:SetTextByKey("next_level", ScpArgMsg("MaxLevel"))
			end
		end

		local rank_gbox = GET_CHILD_RECURSIVELY(frame, "contribution_rank_gbox")
		if rank_gbox ~= nil then
			local idx = 1
			local start_y = 40
			local height = ui.GetControlSetAttribute("guild_growth_contribution_rank_info", "height")
	
			local list = session.party.GetSortedPartyMemberList(PARTY_GUILD, "Contribution", true)
			local count = list:Count()
			local cur_exp = TryGetProp(guild_obj, "Exp", 0)
	
			for i = 0, count - 1 do
				local party_member_info = list:Element(i)
				if party_member_info ~= nil then
					local member_obj = GetIES(party_member_info:GetObject())
					if member_obj ~= nil then
						local cur_contribution = member_obj.Contribution
						if cur_contribution > 0 then
							local y = start_y + (height * (idx - 1))
							local ctrlset = rank_gbox:CreateOrGetControlSet("guild_growth_contribution_rank_info", "GuildGrowthContribution_Rank_Info_"..idx, 0, y)
							if ctrlset ~= nil then
								local rank_text = GET_CHILD_RECURSIVELY(ctrlset, "rank")
								if rank_text ~= nil then
									rank_text:SetTextByKey("value", idx)
								end
	
								local name_text = GET_CHILD_RECURSIVELY(ctrlset, "name")
								if name_text ~= nil then
									local member_name = party_member_info:GetName()
									name_text:SetTextByKey("value", member_name)
								end
	
								if cur_exp > 0 then
									local value_text = GET_CHILD_RECURSIVELY(ctrlset, "value")
									if value_text ~= nil then
										value_text:SetTextByKey("value", cur_contribution)
									end
								end
								idx = idx + 1
							end
						end
					end
				end
			end
		end
	end
end

-- guild growth - drop talt
function DROP_TALT_GUILD_ACTIVITY_DETAIL_GUILD_GROWTH(parent, slot)
	local inv_item = GET_DRAG_INVITEM_INFO()
	if inv_item ~= nil then
		local item_cls = GetClassByType("Item", inv_item.type)
		if item_cls ~= nil then
			local guild_check = TryGetProp(item_cls, "StringArg", "None")
			if guild_check ~= "Guild_EXP" then
				ui.SysMsg(ScpArgMsg("ItemOnlyForGuildExpUpPlz"))
				return
			end

			local frame = parent:GetTopParentFrame()
			INPUT_NUMBER_BOX(frame, ScpArgMsg("InputCount"), "EXEC_DROP_TALT_GUILD_ACTIVITY_DETAIL_GUILD_GROWTH", inv_item.count, 1, inv_item.count)
			frame:SetUserValue("TaltIesID", inv_item:GetIESID())
		end
	end
end

-- guild growth - exec drop talt
function EXEC_DROP_TALT_GUILD_ACTIVITY_DETAIL_GUILD_GROWTH(frame, count, input_frame, from_frame)
	frame = frame:GetTopParentFrame()
	if frame ~= nil then
		local ies_id = frame:GetUserValue("TaltIesID")
		local slot = GET_CHILD_RECURSIVELY(frame, "talt_slot")
		if slot ~= nil then
			local inv_item = session.GetInvItemByGuid(ies_id)
			if inv_item ~= nil then
				SET_SLOT_ITEM(slot, inv_item)
				SET_SLOT_COUNT_TEXT(slot, count)
				frame:SetUserValue("TaltCount", count)
			end
		end
	end
end

-- guild growth - exec growth btn
function EXEC_GROWTH_BTN_GUILD_ACTIVITY_DETAIL_GUILD_GROWTH(parent, btn)
	local frame = parent:GetTopParentFrame()
	local slot = GET_CHILD_RECURSIVELY(frame, "talt_slot")
	if slot ~= nil then
		local item = GET_SLOT_ITEM(slot)
		if item == nil then
			ui.SysMsg(ClMsg('NoTaltinTheSlot'));
			return
		end

		local yes_scp = "EXEC_GROWTH_GUILD_ACTIVITY_DETAIL_GUILD_GROWTH"
		ui.MsgBox(ScpArgMsg("REALLY_DO"), yes_scp, "None")
	end
end

-- guild growth - exec guild growth
function EXEC_GROWTH_GUILD_ACTIVITY_DETAIL_GUILD_GROWTH()
	local frame = ui.GetFrame("guild_activity_ui")
	if frame ~= nil then
		local ies_id = frame:GetUserValue("TaltIesID")
		local count = frame:GetUserIValue("TaltCount")
		local scp_string = string.format("/guildexpup %s %d", ies_id, count)
		ui.Chat(scp_string)
		
		local slot = GET_CHILD_RECURSIVELY(frame, "talt_slot")
		if slot ~= nil then
			CLEAR_SLOT_ITEM_INFO(slot)
		end
	end
end

---- detail - guild ability
-- guild ability - remove info
function REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_ABILITY_INFO(frame, gbox)
	if gbox ~= nil then
		RemoveChildByPattern(gbox, "GuildAbility_Info_")
	end
end

-- guild ability - create info
function CREATE_GUILD_ACTIVITY_DETAIL_GUILD_ABILITY_INFO(frame, gbox)
	local guild_obj = GetMyGuildObject()
	if guild_obj ~= nil then
		local enable_used_abil_point = 0
		local abil_point_text = GET_CHILD_RECURSIVELY(frame, "available_ability_point")
		if abil_point_text ~= nil then
			local cur_point = TryGetProp(guild_obj, "Level", 1)
			local used_point = TryGetProp(guild_obj, "UsedAbilStat", 0)
			local abil_point = cur_point - used_point
			enable_used_abil_point = abil_point
			abil_point_text:SetTextByKey("point", enable_used_abil_point)
		end

		local start_x = 60
		local start_y = 150
		local offset_x = 10
		local width = ui.GetControlSetAttribute("guild_ability_info", "width")
		local list, cnt = GetClassList("Guild_Ability")
		for i = 0, cnt - 1 do
			local cls = GetClassByIndexFromList(list, i)
			if cls ~= nil then
				local x = start_x + (width * i) + (offset_x * i)
				local info = gbox:CreateOrGetControlSet("guild_ability_info", "GuildAbility_Info_"..i, x, start_y)
				if info ~= nil then
					info:SetUserValue("Ability_ClsID", TryGetProp(cls, "ClassID", 0))
					
					local slot = GET_CHILD_RECURSIVELY(info, "slot")
					if slot ~= nil then
						local icon = TryGetProp(cls, "Icon", "None")
						SET_SLOT_IMG(slot, icon)
					end
	
					local name_text = GET_CHILD_RECURSIVELY(info, "name")
					if name_text ~= nil then
						local name = dic.getTranslatedStr(TryGetProp(cls, "Name", "None"))
						name_text:SetTextByKey("name", name)
					end
	
					local desc_text = GET_CHILD_RECURSIVELY(info, "desc")
					if desc_text ~= nil then
						local desc = dic.getTranslatedStr(TryGetProp(cls, "Desc", "None"))
						desc_text:SetTextByKey("desc", desc)
					end
	
					local cur_level = nil
					local max_level = TryGetProp(cls, "MaxLevel", 0)
					local level_text = GET_CHILD_RECURSIVELY(info, "level")
					if level_text ~= nil then
						local prop_name = "AbilLevel_"..TryGetProp(cls, "ClassName", "None")
						cur_level = guild_obj[prop_name]
						level_text:SetTextByKey("level", cur_level)
					end
	
					local btn = GET_CHILD_RECURSIVELY(info, "btn")
					if btn ~= nil then
						if cur_level >= max_level then
							btn:ShowWindow(0)
						else
							if enable_used_abil_point <= 0 then
								local disable_color = frame:GetUserConfig("DISABLE_COLOR")
								btn:SetColorTone(disable_color)
								btn:SetEnable(0)
							else
								btn:SetColorTone("FFFFFFFF")
								btn:SetEnable(1)	
							end
							btn:ShowWindow(1)
						end
					end
				end
			end
		end
	end
end

-- guild abilty - ability up btn
function EXEC_ABILITY_UP_BTN_GUILD_ACTIVITY_DETAIL_GUILD_ABILITY(parent, btn)
	local ctrlset = parent:GetParent():GetParent()
	if ctrlset ~= nil then
		local cls_id = ctrlset:GetUserIValue("Ability_ClsID")
		local yes_scp = string.format("EXEC_ABILITY_UP_GUILD_ACTIVITY_DETAIL_GUILD_ABILITY(%d)", cls_id)
		ui.MsgBox(ScpArgMsg("ExecLearnAbility"), yes_scp, "None")
	end
end

-- guild ability - ability up yesscp
function EXEC_ABILITY_UP_GUILD_ACTIVITY_DETAIL_GUILD_ABILITY(id)
	local guild_obj = GetMyGuildObject()
	if guild_obj ~= nil then
		local used_point = TryGetProp(guild_obj, "UsedAbilStat", 0)
		local cur_point = TryGetProp(guild_obj, "Level", 1)
		local abil_point = cur_point - used_point
		if abil_point <= 0 then
			ui.MsgBox(ScpArgMsg("NotEnoughPoint"));
			return
		end

		local scp_string = string.format("/learnguildabil %d", id)
		ui.Chat(scp_string)
	end
end

---- deatil - agit extension
-- agit extension - remove info
function REMOVE_GUILD_ACTIVITY_DETAIL_AGIT_EXTENSION_INFO(frame, gbox)
	local need_material_gbox = GET_CHILD_RECURSIVELY(frame, "agit_extension_need_material_gbox")
	if need_material_gbox ~= nil then
		RemoveChildByPattern(need_material_gbox, "AgitExtension_Material_info_")
	end

	local step_info_inner_gbox = GET_CHILD_RECURSIVELY(frame, "agit_extension_step_info_inner_gbox")
	if step_info_inner_gbox ~= nil then
		RemoveChildByPattern(step_info_inner_gbox, "AgitExtension_Step_Info_")
	end
end

-- agit extension - craete info
function CREATE_GUILD_ACTIVITY_DETAIL_AGIT_EXTENSION_INFO(frame, gbox)
	-- agit extension level
	local extension_level = 1
	local max_level = GET_GUILD_AGIT_EXTENSION_MAX_LEVEL()
	local guild_agit = housing.GetGuildAgitInfo()
	if guild_agit ~= nil then
		extension_level = guild_agit.extensionLevel
	end

	-- agit extension level pic
	local agit_extension_step_pic = GET_CHILD_RECURSIVELY(frame, "agit_extension_step_pic")
	if agit_extension_step_pic ~= nil then
		-- ** 이미지 추가되면 변경할 부분 : 길드 확장 단계 정보.
		agit_extension_step_pic:SetImage("housing_level_icon_0"..extension_level)
	end

	-- agit extension level gauge
	local agit_extension_step_gauge = GET_CHILD_RECURSIVELY(frame, "agit_extension_step_gauge")
	if agit_extension_step_gauge ~= nil then
		agit_extension_step_gauge:SetPoint(extension_level, max_level)
	end

	-- agit extension need matrial
	local need_material_gbox = GET_CHILD_RECURSIVELY(frame, "agit_extension_need_material_gbox")
	if need_material_gbox ~= nil then
		local start_y = 40
		local offset_y = 5
		local height = ui.GetControlSetAttribute("guild_agit_extension_material_info", "height")
		local need_material_name_list = { "ExtensionNeedGuildLevel", "ExtensionNeedSilver", "ExtensionNeedMileage" }
		local cls = GetClass("guild_housing", "guild_agit_extension"..(extension_level + 1))
		MAKE_GUILD_ACTIVITY_DETAIL_AGIT_EXTENSION_NEED_MATERIAL_CTRLSET(need_material_gbox, need_material_name_list, start_y, offset_y, height, cls)
	end

	-- agit extension step
	local step_info_inner_gbox = GET_CHILD_RECURSIVELY(frame, "agit_extension_step_info_inner_gbox")
	if step_info_inner_gbox ~= nil then
		local start_y = 0
		local offset_y = 5
		local height = ui.GetControlSetAttribute("guild_agit_extension_step_info", "height")
		MAKE_GUILD_ACTIVITY_DETAIL_AGIT_EXTENSION_STEP_INFO_CTRLSET(step_info_inner_gbox, start_y, offset_y, height, max_level)
	end
end

-- agit extension - create info : need material make controlset
function MAKE_GUILD_ACTIVITY_DETAIL_AGIT_EXTENSION_NEED_MATERIAL_CTRLSET(gbox, mat_list, start_y, offset_y, height, cls)
	for i = 1, #mat_list do
		local y = start_y + (height * (i - 1)) + (offset_y * (i - 1))
		local ctrlset = gbox:CreateOrGetControlSet("guild_agit_extension_material_info", "AgitExtension_Material_info_"..i, 0, y)
		if ctrlset ~= nil then
			local mat_name = mat_list[i]
			local icon_name = "icon_guild_housing_coin_01" -- ** test 용도 : 이미지 나오면 각 이름에 대한 이미지 설정 해야 함.
			local name = ScpArgMsg(mat_name)
			local value = 0
			if cls ~= nil then
				value = TryGetProp(cls, mat_name)
			end
			
			local slot = GET_CHILD_RECURSIVELY(ctrlset, "slot")
			if slot ~= nil then
				SET_SLOT_IMG(slot, icon_name)
			end

			local name_text = GET_CHILD_RECURSIVELY(ctrlset, "name")
			if name_text ~= nil then
				name_text:SetTextByKey("name", name)
			end

			local value_text = GET_CHILD_RECURSIVELY(ctrlset, "value")
			if value_text ~= nil then
				value_text:SetTextByKey("value", GET_COMMAED_STRING(value))
			end
		end
	end
end

-- agit extension - create info : extension step info make controlset
function MAKE_GUILD_ACTIVITY_DETAIL_AGIT_EXTENSION_STEP_INFO_CTRLSET(gbox, start_y, offset_y, height, max_level)
	for i = 1, max_level do
		local y = start_y + (height * (i - 1)) + (offset_y * (i - 1))
		local ctrlset = gbox:CreateOrGetControlSet("guild_agit_extension_step_info", "AgitExtension_Step_Info_"..i, 0, y)
		if ctrlset ~= nil then
			local cls = GetClass("guild_housing", "guild_agit_extension"..i)
			if cls ~= nil then
				local pic = GET_CHILD_RECURSIVELY(ctrlset, "pic")
				if pic ~= nil then
					-- ** 단계 이미지가 추가되면 변경할 부분
					pic:SetImage("housing_level_icon_0"..i)
				end

				local desc_text = GET_CHILD_RECURSIVELY(ctrlset, "desc")
				if desc_text ~= nil then
					local desc = TryGetProp(cls, "Caption1", "")
					desc_text:SetTextByKey("desc", desc)
				end
			end
		end
	end
end

-- agit extension - step up
function STEP_UP_GUILD_ACTIVITY_DETAIL_AGIT_EXTENSION(parent, btn)
	local extension_level = 1
	local guild_agit = housing.GetGuildAgitInfo()
	if guild_agit ~= nil then
		local max_extension_level = GET_GUILD_AGIT_EXTENSION_MAX_LEVEL()
		if extension_level >= max_extension_level then
			ui.MsgBox(ClMsg("MaxSkillLevel"))
			return
		end
		extension_level = guild_agit.extensionLevel
	end

	local frame = parent:GetTopParentFrame()
	local idx = frame:GetUserIValue("ACCEPT_MSGBOX_INDEX")
	ui.CloseMsgBoxByIndex(idx)

	local cls = GetClass("guild_housing", "guild_agit_extension"..extension_level + 1)
	if cls == nil then
		ui.MsgBox(ClMsg("MaxSkillLevel"))
		return
	end

	local need_sliver = GET_COMMAED_STRING(TryGetProp(cls, "ExtensionNeedSilver", 0))
	local need_mileage = GET_COMMAED_STRING(TryGetProp(cls, "ExtensionNeedMileage", 0))
	local msg = ScpArgMsg("Housing_Really_Agit_Extension{LEVEL}{GUILD_MONEY}{GUILD_MILEAGE}", "LEVEL", extension_level + 1, "GUILD_MONEY", need_sliver, "GUILD_MILEAGE", need_mileage)
	if extension_level <= 1 then
		msg = ScpArgMsg("Housing_Really_Agit_Extension_First{LEVEL}{GUILD_MONEY}{GUILD_MILEAGE}", "LEVEL", extension_level + 1, "GUILD_MONEY", need_sliver, "GUILD_MILEAGE", need_mileage)
	end

	local yes_scp = "EXEC_GUILD_ACTIVITY_DETAIL_AGIT_EXTENSION"
	local accept_msg_box = ui.MsgBox(msg, yes_scp, "None")
	accept_msg_box = tolua.cast(accept_msg_box, "ui::CMessageBoxFrame")
	frame:SetUserValue("ACCEPT_MSGBOX_INDEX", accept_msg_box:GetIndex())
end

-- agit extension - exec
function EXEC_GUILD_ACTIVITY_DETAIL_AGIT_EXTENSION()
	housing.RequestGuildAgitExtension("GUILD_ACTIVITY_AGIT_EXTENSION")
end

-- agit extension - receive addon
function ON_GUILD_ACTIVITY_AGIT_EXTENSION(frame)
	CREATE_GUILD_ACTIVITY_DETAIL_AGIT_EXTENSION_INFO(frame)
	-- frame:Invalidate()
end

---- detail - guild raid boss, guild mission, blockade
-- guild quest common - get list box name
function GET_LIST_GBOX_NAME_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(frame, menu_idx)
	local gbox_names = {
		"guild_boss_raid_list_gbox",
		"guild_mission_list_gbox",
		"guild_blockade_list_gbox"
	}
	return gbox_names[menu_idx] or "None"
end

-- guild quest common - get ctrlset name
function GET_CTRLSET_NAME_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(frame, menu_idx)
	local ctrlset_names = {
		"GuildRaidBoss_Info_",
		"GuiildMission_Info_",
		"Blockade_Info_"
	}
	return ctrlset_names[menu_idx] or "None"
end

-- guild quest common - set visible
function SET_VISIBLE_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_INFO_LIST(frame, menu_idx, visible)	
	local list_gbox_name = GET_LIST_GBOX_NAME_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(frame, menu_idx)
	local gbox = GET_CHILD_RECURSIVELY(frame, list_gbox_name)
	if gbox ~= nil then
		gbox:ShowWindow(visible)
	end
end

-- guild quest common - before view
function BEFORE_VIEW_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_VIEW(frame)
	local select_category_type = tonumber(frame:GetUserValue("SELECT_CATEGORY_TYPE"))
	local menu_class_name = frame:GetUserValue("SELECT_MENU_CLASS_NAME")
	local index = GetGuildActivity_MenuIndex(select_category_type, menu_class_name)
	SET_VISIBLE_GUILD_ACTIVITY_DEATIL_GBOX(frame, select_category_type, index)
	MAKE_GUILD_ACTIVITY_DEATIL_GBOX(frame, select_category_type, menu_class_name, index)
end

-- guild quest common - remove info
function REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_INFO(frame, gbox, menu_idx)
	local list_gbox_name = GET_LIST_GBOX_NAME_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(frame, menu_idx)
	local ctrlset_name = GET_CTRLSET_NAME_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(frame, menu_idx)
	local list_gbox = GET_CHILD_RECURSIVELY(frame, list_gbox_name)
	if list_gbox ~= nil then
		RemoveChildByPattern(list_gbox, ctrlset_name)
	end
end

-- guild quest common - get slot img
function GET_SLOT_IMG_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(cls, menu_idx, is_sub)
	if is_sub == nil then
		is_sub = false
	end

	if cls ~= nil then
		if menu_idx == MENU_IDX.BOSS_RAID then
			-- guild boss raid
			local boss_name = TryGetProp(cls, "BossName", "None")
			local mon_cls = GetClass("Monster", boss_name)
			if mon_cls ~= nil then
				return TryGetProp(mon_cls, "Icon", "None")
			end
		elseif is_sub == false and (menu_idx == MENU_IDX.MISSION or menu_idx == MENU_IDX.BLOCKADE) then
			return "guild_event_indeon" -- ** test 용도 : 별도 처리 필요.
		elseif is_sub == true and menu_idx == MENU_IDX.BLOCKADE then
			-- blockade boss
			local boss_name = TryGetProp(cls, "BossName", "None")
			local mon_cls = GetClass("Monster", boss_name)
			if mon_cls ~= nil then
				return TryGetProp(mon_cls, "Icon", "None")
			end
		end
	end
	return "None"
end

-- guild quest common - get guild quest reward list
function GET_REWARD_LIST_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(cls_name)
	local reward_list = {}
	for i = 1, #s_guild_activity_guild_quest_reward_info_list do
		local info = s_guild_activity_guild_quest_reward_info_list[i]
		local class_name = info[1]
		if class_name == cls_name then
			reward_list[#reward_list + 1] = info[2]
			reward_list[#reward_list + 1] = info.item_list
		end
	end
	return reward_list
end

-- guild quest common - create info
function CREATE_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_INFO(frame, gbox, menu_idx)
	local guild_obj = GetMyGuildObject()
	if guild_obj ~= nil then
		local guild_lv = TryGetProp(guild_obj, "Level", 0)
		SET_VISIBLE_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_INFO_LIST(frame, menu_idx, 1)
		local list_gbox_name = GET_LIST_GBOX_NAME_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(frame, menu_idx)
		if list_gbox_name ~= "None" then
			local list_gbox = GET_CHILD_RECURSIVELY(frame, list_gbox_name)
			if list_gbox ~= nil then
				local list, cnt = GetClassList("GuildEvent")
				if list ~= nil and cnt > 0 then
					local start_y = 0
					if menu_idx == MENU_IDX.BLOCKADE then 
						start_y = 20
						local rank_btn = GET_CHILD_RECURSIVELY(frame, "guild_blockade_rank_btn")
						if rank_btn ~= nil then
							rank_btn:ShowWindow(1)
						end
					end
					local offset_y = 8
					local info_idx = 1
					local height = ui.GetControlSetAttribute("guild_quest_info", "height")
					for i = 0, cnt - 1 do
						local cls = GetClassByIndexFromList(list, i)
						if cls ~= nil then
							local cls_lv = TryGetProp(cls, "GuildLv", 0)
							if cls_lv > 0 then
								local is_enable = true
								if guild_lv < cls_lv then
									is_enable = false
								end

								local index = TryGetProp(cls, "TabIndex", 0)
								local ctrlset_name = GET_CTRLSET_NAME_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(frame, menu_idx)
								if index == (menu_idx - 1) then
									local y = start_y + (height * (info_idx - 1)) + (offset_y * (info_idx - 1))
									local info = list_gbox:CreateOrGetControlSet("guild_quest_info", ctrlset_name..info_idx, 0, y)
									if info ~= nil then
										info:SetUserValue("GUILD_EVENT_CTRL", "YES")
										info:SetUserValue("GUILD_EVENT_NAME", TryGetProp(cls, "ClassName", "None"))
										info:SetUserValue("GUILD_EVENT_ID", TryGetProp(cls, "ClassID", 0))
										info:SetUserValue("MENU_IDX", menu_idx)
										
										local slot = GET_CHILD_RECURSIVELY(info, "slot")
										if slot ~= nil then
											local img = GET_SLOT_IMG_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(cls, menu_idx)
											SET_SLOT_IMG(slot, img)
										end
			
										local name_text = GET_CHILD_RECURSIVELY(info, "name")
										if name_text ~= nil then
											local name = TryGetProp(cls, "Name", "None")
											name_text:SetTextByKey("name", name)
										end
			
										local user_count_text = GET_CHILD_RECURSIVELY(info, "user_count_text")
										if user_count_text ~= nil then
											local max_player_count = TryGetProp(cls, "MaxPlayerCnt", 0)
											user_count_text:SetTextByKey("value", max_player_count)
										end
			
										local time_limit_text = GET_CHILD_RECURSIVELY(info, "time_limit_text")
										if time_limit_text ~= nil then
											local time_limit = TryGetProp(cls, "TimeLimit", 0)
											local value = tostring(time_limit / 60)
											time_limit_text:SetTextByKey("value", value)
										end
			
										local ticket_text = GET_CHILD_RECURSIVELY(info, "ticket_text")
										if ticket_text ~= nil then
											local ticket = TryGetProp(cls, "TicketCount", 0)
											ticket_text:SetTextByKey("value", ticket)
										end

										local notice_msg_gb = GET_CHILD_RECURSIVELY(info, "notice_msg_gb")
										local notice_text = GET_CHILD_RECURSIVELY(info, "notice_text")
										if notice_msg_gb ~= nil and notice_text ~= nil then
											if is_enable == false then
												local msg = ClMsg("GuildQuest_GuildLv_Notice")
												notice_text:SetTextByKey("value", msg)
												notice_text:ShowWindow(1)
												notice_msg_gb:ShowWindow(1)
											else
												notice_text:ShowWindow(0)
												notice_msg_gb:ShowWindow(0)
											end
										end

										local wrap_btn = GET_CHILD_RECURSIVELY(info, "wrap_btn")
										if wrap_btn ~= nil then
											if is_enable == false then
												wrap_btn:SetEnable(0)
											else
												wrap_btn:SetEnable(1)
											end
										end
			
										info_idx = info_idx + 1
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

-- guild quest common - ctrlset click
function OPEN_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_SUB_GBOX(ctrlset, gb)
	local frame = ui.GetFrame("guild_activity_ui")
	if frame ~= nil then
		local guild_event_id = ctrlset:GetUserIValue("GUILD_EVENT_ID")
		frame:SetUserValue("SELECT_GUILD_EVENT_ID", guild_event_id)

		local menu_idx = ctrlset:GetUserIValue("MENU_IDX")
		SET_VISIBLE_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_INFO_LIST(frame, menu_idx, 0)

		local is_enable = true
		local guild_obj = GetMyGuildObject()
		if guild_obj ~= nil then
			local guild_lv = TryGetProp(guild_obj, "Level", 0)
			local event_cls = GetClassByType("GuildEvent", guild_event_id)
			if event_cls ~= nil then
				local cls_lv = TryGetProp(event_cls, "GuildLv", 0)
				if guild_lv < cls_lv then
					is_enable = false
				end
			end
		end

		if menu_idx == MENU_IDX.BOSS_RAID then
			SET_VISIBLE_GUILD_ACTIVITY_GUILD_QUEST_DETAIL_SUB_GBOX_SUBTYPE(frame, "guild_boss_raid", 1)
			REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_RAID_BOSS(frame)
			CREATE_GUILD_ACTIVITY_DETAIL_GUILD_RAID_BOSS(frame, guild_event_id, menu_idx, is_enable)
		elseif menu_idx == MENU_IDX.MISSION then
			SET_VISIBLE_GUILD_ACTIVITY_GUILD_QUEST_DETAIL_SUB_GBOX_SUBTYPE(frame, "guild_mission", 1)
			REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_MISSION(frame)
			CREATE_GUILD_ACTIVITY_DETAIL_GUILD_MISSION(frame, guild_event_id, menu_idx, is_enable)
		elseif menu_idx == MENU_IDX.BLOCKADE then
			SET_VISIBLE_GUILD_ACTIVITY_GUILD_QUEST_DETAIL_SUB_GBOX_SUBTYPE(frame, "guild_blockade", 1)
			SET_VISIBLE_GUILD_ACTIVITY_GUILD_QUEST_DETAIL_SUB_GBOX_SUBTYPE(frame, "guild_blockade_rank", 0)
			REMOVE_GUILD_ACTIVITY_DETAIL_BLOCKADE(frame)
			CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE(frame, guild_event_id, menu_idx, is_enable)
		end
	end
end

-- guild quest common - ctrlset move btn
function MOVE_BTN_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(parent, btn)
	local ctrlset = parent:GetParent():GetParent()
	if ctrlset ~= nil then
		local cls_id = ctrlset:GetUserIValue("GUILD_EVENT_ID")
		local cls = GetClassByType("GuildEvent", cls_id)
		if cls ~= nil then
			local map_cls_name = TryGetProp(cls, "StartMap", "None")
			local map_cls = GetClass("Map", map_cls_name)
			if map_cls ~= nil then
				local map_name = TryGetProp(map_cls, "Name", "None")
				local msg = ScpArgMsg("{StartMap}DoYouWantMove", "StartMap", map_name)
				local yes_scp = string.format("MOVE_GUILD_EVENT_RUN(%d)", cls_id)
				ui.MsgBox(msg, yes_scp, "None")
			end
		end
	end
end

-- guild quest common - accept btn
function ACCEPT_BTN_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(parent, btn)
	local frame = parent:GetTopParentFrame()
	if frame ~= nil then
		local cls_id = frame:GetUserIValue("SELECT_GUILD_EVENT_ID")
		control.CustomCommand("REQ_EXIST_GUILD_EVENT_CHECK", cls_id)
		ui.CloseFrame("guild_activity_ui")
	end
end

-- guild quest common - make reward slot
function MAKE_REWARD_SLOT_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(frame, class_name, menu_idx)
	local gbox_name = "None"
	if menu_idx == MENU_IDX.BOSS_RAID then
		gbox_name = "guild_boss_raid_reward_gbox"
	elseif menu_idx == MENU_IDX.MISSION then
		gbox_name = "guild_mission_reward_gbox"
	elseif menu_idx == MENU_IDX.BLOCKADE then
		gbox_name = "guild_blockade_reward_gbox"
	end

	if gbox_name ~= "None" then
		local gbox = GET_CHILD_RECURSIVELY(frame, gbox_name)
		if gbox ~= nil then
			gbox:RemoveAllChild()
			local list = GET_REWARD_LIST_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(class_name)
			local count = #list
			local slot_size = 80
			local width = gbox:GetWidth()
			local height = gbox:GetHeight()
			local gap = 5
			local slots_per_row = math.floor((width - gap) / (slot_size + gap))
			local start_x = 5
			local start_y = 10

			local guild_exp = list[1]
			local item_list = list[2]
			for i = 0, #item_list do
				local row = math.floor(i / slots_per_row) -- cur row
				local col = i % slots_per_row -- cur col
				local x = start_x + col * (slot_size + gap)
				local y = start_y + row * (slot_size + gap)
				local slot = gbox:CreateControl("slot", "guild_quest_reward_slot_"..i, slot_size, slot_size, ui.LEFT, ui.TOP, x, y, 0, 0)
				if slot ~= nil then
					if i == 0 then
						local exp_img = "expup_img"	
						local font = "{s16}{ol}{b}"
						SET_SLOT_IMG(slot, exp_img)
						SET_SLOT_COUNT_TEXT(slot, guild_exp, font)
					else
						local item_info = item_list[i]
						if #item_info >= 2 then
							local item_name = item_info[1]
							local item_count = item_info[2]
							local item_cls = GetClass("Item", item_name)
							if item_cls ~= nil then
								SET_SLOT_ITEM_CLS(slot, item_cls)
								SET_SLOT_COUNT_TEXT(slot, item_count)
							end
						end
					end
					AUTO_CAST(slot)
					slot:SetSkinName('invenslot2') -- ** 임시 스킨 설정
					slot:EnableDrag(0)
					slot:EnableDrop(0)
				end
			end
		end
	end
end

-- guild raid boss - sub gbox info remove
function REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_RAID_BOSS(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "guild_boss_raid_reward_gbox")
	if gbox ~= nil then
		RemoveChildByPattern(gbox, "guild_quest_reward_slot_")
	end
end

-- guild raid boss - sub gbox info create
function CREATE_GUILD_ACTIVITY_DETAIL_GUILD_RAID_BOSS(frame, guild_event_id, menu_idx, is_enable)
	local cls = GetClassByType("GuildEvent", guild_event_id)
	if cls ~= nil then
		local boss_pic = GET_CHILD_RECURSIVELY(frame, "guild_boss_raid_boss_pic")
		if boss_pic ~= nil then
			local img = GET_SLOT_IMG_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(cls, menu_idx)
			boss_pic:SetImage(img)
		end

		-- ** 맵 이미지 : 아직 작업 안됨 - 맵 이미지가 길드 보스 레이드 및 길드 미션 리뉴얼 다음 제작되어야 함.
		local map_pic = GET_CHILD_RECURSIVELY(frame, "guild_boss_raid_map_pic")
		if map_pic ~= nil then
			-- map_pic:SetImage("")
		end

		local desc_text = GET_CHILD_RECURSIVELY(frame, "guild_boss_raid_desc_text")
		if desc_text ~= nil then
			local desc = TryGetProp(cls, "DetailInfo", "None")
			desc_text:SetTextByKey("desc", desc)
		end

		local class_name = TryGetProp(cls, "ClassName", "None")
		MAKE_REWARD_SLOT_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(frame, class_name, menu_idx)

		local start_btn = GET_CHILD_RECURSIVELY(frame, "guild_boss_raid_start_btn")
		if start_btn ~= nil then
			if is_enable == true then
				start_btn:SetEnable(1)
			else
				start_btn:SetEnable(0)
			end
		end
	end
	frame:Invalidate()
end

-- guild raid boss - before btn or reset view
function BEFORE_DEATIL_VIEW_GUILD_ACTIVITY_DETAIL_GUILD_RAID_BOSS(parent, btn)
	local frame = ui.GetFrame("guild_activity_ui")
	if frame ~= nil then
		SET_VISIBLE_GUILD_ACTIVITY_GUILD_QUEST_DETAIL_SUB_GBOX_SUBTYPE(frame, "guild_boss_raid", 0)
		REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_RAID_BOSS(frame)
		BEFORE_VIEW_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_VIEW(frame)
	end
end

-- guild mission - sub gbox info remove
function REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_MISSION(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "guild_mission_reward_gbox")
	if gbox ~= nil then
		RemoveChildByPattern(gbox, "guild_quest_reward_slot_")
	end
end

-- guild mission - sub gbox info create
function CREATE_GUILD_ACTIVITY_DETAIL_GUILD_MISSION(frame, guild_event_id, menu_idx, is_enable)
	local cls = GetClassByType("GuildEvent", guild_event_id)
	if cls ~= nil then
		-- ** 보스 이미지 : 보스 이미지로 하기에는 길드 미션 리뉴얼을 시켜야 가능할 듯해 보인다.
		local mission_pic = GET_CHILD_RECURSIVELY(frame, "guild_mission_pic")
		if mission_pic ~= nil then
			-- mission_pic:SetImage("")
		end

		-- ** 맵 이미지 : 아직 작업 안됨 - 맵 이미지가 길드 보스 레이드 및 길드 미션 리뉴얼 다음 제작되어야 함.
		local map_pic = GET_CHILD_RECURSIVELY(frame, "guild_mission_map_pic")
		if map_pic ~= nil then
			-- map_pic:SetImage("")
		end

		local desc_text = GET_CHILD_RECURSIVELY(frame, "guild_mission_desc_text")
		if desc_text ~= nil then
			local desc = TryGetProp(cls, "DetailInfo", "None")
			desc_text:SetTextByKey("desc", desc)
		end

		local class_name = TryGetProp(cls, "ClassName", "None")
		MAKE_REWARD_SLOT_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(frame, class_name, menu_idx)

		local start_btn = GET_CHILD_RECURSIVELY(frame, "guild_mission_start_btn")
		if start_btn ~= nil then
			if is_enable == true then
				start_btn:SetEnable(1)
			else
				start_btn:SetEnable(0)
			end
		end
	end
	frame:Invalidate()
end

-- guild mission - before btn or reset view
function BEFORE_DETAIL_VIEW_GUILD_ACTIVITY_DETIAL_GUILD_MISSION(parent, btn)
	local frame = ui.GetFrame("guild_activity_ui")
	if frame ~= nil then
		SET_VISIBLE_GUILD_ACTIVITY_GUILD_QUEST_DETAIL_SUB_GBOX_SUBTYPE(frame, "guild_mission", 0)
		REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_MISSION(frame)
		BEFORE_VIEW_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_VIEW(frame)
	end
end

-- blockade - sub gbox info remove
function REMOVE_GUILD_ACTIVITY_DETAIL_BLOCKADE(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "guild_blockade_reward_gbox")
	if gbox ~= nil then
		RemoveChildByPattern(gbox, "guild_quest_reward_slot_")
	end
end

-- blockade - sub gbox info create
function CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE(frame, guild_event_id, menu_idx, is_enable)
	local rank_btn = GET_CHILD_RECURSIVELY(frame, "guild_blockade_rank_btn")
	if rank_btn ~= nil then
		rank_btn:ShowWindow(0)
	end

	local cls = GetClassByType("GuildEvent", guild_event_id)
	if cls ~= nil then
		local boss_pic = GET_CHILD_RECURSIVELY(frame, "guild_blockade_pic")
		if boss_pic ~= nil then
			local img = GET_SLOT_IMG_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(cls, menu_idx, true)
			boss_pic:SetImage(img)
		end

		local boss_info_ctrlset_1 = GET_CHILD_RECURSIVELY(frame, "guild_blockade_boss_info_1")
		local boss_info_ctrlset_2 = GET_CHILD_RECURSIVELY(frame, "guild_blockade_boss_info_2")
		local boss_info_ctrlset_3 = GET_CHILD_RECURSIVELY(frame, "guild_blockade_boss_info_3")
		local boss_info_ctrlset_4 = GET_CHILD_RECURSIVELY(frame, "guild_blockade_boss_info_4")
		local boss_info_ctrlset_5 = GET_CHILD_RECURSIVELY(frame, "guild_blockade_boss_info_5")
		local boss_info_ctrlset_6 = GET_CHILD_RECURSIVELY(frame, "guild_blockade_boss_info_6")
		SET_BOSS_INFO_CTRLSET_GUILD_ACTIVITY_DETAIL_BLOCKADE(guild_event_id, boss_info_ctrlset_1, 1)
		SET_BOSS_INFO_CTRLSET_GUILD_ACTIVITY_DETAIL_BLOCKADE(guild_event_id, boss_info_ctrlset_2, 2)
		SET_BOSS_INFO_CTRLSET_GUILD_ACTIVITY_DETAIL_BLOCKADE(guild_event_id, boss_info_ctrlset_3, 3)
		SET_BOSS_INFO_CTRLSET_GUILD_ACTIVITY_DETAIL_BLOCKADE(guild_event_id, boss_info_ctrlset_4, 4)
		SET_BOSS_INFO_CTRLSET_GUILD_ACTIVITY_DETAIL_BLOCKADE(guild_event_id, boss_info_ctrlset_5, 5)
		SET_BOSS_INFO_CTRLSET_GUILD_ACTIVITY_DETAIL_BLOCKADE(guild_event_id, boss_info_ctrlset_6, 6)

		local desc_text = GET_CHILD_RECURSIVELY(frame, "guild_blockade_desc_text")
		if desc_text ~= nil then
			local desc = TryGetProp(cls, "DetailInfo", "None")
			desc_text:SetTextByKey("desc", desc)
		end

		local class_name = TryGetProp(cls, "ClassName", "None")
		MAKE_REWARD_SLOT_GUILD_ACTIVITY_DETAIL_GUILD_QUEST(frame, class_name, menu_idx)

		local start_btn = GET_CHILD_RECURSIVELY(frame, "guild_blockade_start_btn")
		if start_btn ~= nil then
			if is_enable == true then
				start_btn:SetEnable(1)
			else
				start_btn:SetEnable(0)
			end
		end
	end
	frame:Invalidate()
end

-- blockade - set boss info
function SET_BOSS_INFO_CTRLSET_GUILD_ACTIVITY_DETAIL_BLOCKADE(guild_event_id, ctrlset, index)
	local setting_info_list = {}
	setting_info_list[1] = { "Name", "Name" }
	setting_info_list[2] = { "RaceType", "RaceType" }
	setting_info_list[3] = { "Attribute", "Attribute" }
	setting_info_list[4] = { "MonInfo_ArmorMaterial", "ArmorMaterial" }
	setting_info_list[5] = { "Level", "Level" }
	setting_info_list[6] = { "Area", "Name" }

	local info = setting_info_list[index]
	if info ~= nil then
		local info_name = info[1]
		local name_text = GET_CHILD_RECURSIVELY(ctrlset, "name")
		if name_text ~= nil then
			name_text:SetTextByKey("value", ScpArgMsg(info_name))
		end

		local value_text = GET_CHILD_RECURSIVELY(ctrlset, "value")
		if value_text ~= nil then
			local prop_name = info[2]
			local cls = GetClassByType("GuildEvent", guild_event_id)
			if cls ~= nil then
				if info_name == "Area" then
					local map_cls_name = "None"
					if guild_event_id == 501 then
						map_cls_name = "guild_f_remains_37_3"
					elseif guild_event_id == 502 then
						map_cls_name = "Raid_Veliora"
					elseif guild_event_id == 503 then
						map_cls_name = "guild_ep14_2_d_castle_2"
					end

					local map_cls = GetClass("Map", map_cls_name)
					if map_cls ~= nil then
						local name = TryGetProp(map_cls, "Name", "None")
						value_text:SetTextByKey("value", name)
					end
				else
					local boss_name = TryGetProp(cls, "BossName", "None")
					local mon_cls = GetClass("Monster", boss_name)
					if mon_cls ~= nil then
						local prop_value = TryGetProp(mon_cls, prop_name)
						if info_name == "Name" or info_name == "Level" then
							value_text:SetTextByKey("value", prop_value)
						else
							local value = ScpArgMsg(prop_value)
							if info_name == "Attribute" then
								value = ScpArgMsg("MonInfo_Attribute_"..prop_value)
							end
							value_text:SetTextByKey("value", value)
						end
					end
				end
			end
		end
	end
end

-- blockade - before btn or reset view
function BEFORE_DETAIL_VIEW_GUILD_ACTIVITY_DETIAL_BLOCKADE(parent, btn)
	local frame = ui.GetFrame("guild_activity_ui")
	if frame ~= nil then
		local rank_btn = GET_CHILD_RECURSIVELY(frame, "guild_blockade_rank_btn")
		if rank_btn ~= nil then
			rank_btn:ShowWindow(1)
		end
		SET_VISIBLE_GUILD_ACTIVITY_GUILD_QUEST_DETAIL_SUB_GBOX_SUBTYPE(frame, "guild_blockade", 0)
		REMOVE_GUILD_ACTIVITY_DETAIL_GUILD_MISSION(frame)
		BEFORE_VIEW_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_VIEW(frame)
	end
end

-- blockade - rank btn click
function OPEN_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_SUB_GBOX(parent, btn)
	local frame = ui.GetFrame("guild_activity_ui")
	if frame ~= nil then
		btn:ShowWindow(0) -- 랭크 버튼 숨기기.
		SET_VISIBLE_GUILD_ACTIVITY_DETAIL_GUILD_QUEST_INFO_LIST(frame, MENU_IDX.BLOCKADE, 0)
		SET_VISIBLE_GUILD_ACTIVITY_GUILD_QUEST_DETAIL_SUB_GBOX_SUBTYPE(frame, "guild_blockade_rank", 1)
		REMOVE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK(frame)
		CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK(frame)
	end
end

-- blockade - rank info remove
function REMOVE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK(frame)
	local reward_list_gbox = GET_CHILD_RECURSIVELY(frame, "guild_blockade_rank_reward_info_gbox")
	if reward_list_gbox ~= nil then
		RemoveChildByPattern(reward_list_gbox, "Blockade_RankReward_Info_")
	end

	local rank_list_gbox = GET_CHILD_RECURSIVELY(frame, "guild_blockade_rank_list_gbox")
	if rank_list_gbox ~= nil then
		RemoveChildByPattern(rank_list_gbox, "Blockade_Rank_Info_")
	end
end

-- blockade - rank info create
function CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK(frame)
	INIT_GUILD_ACTIVITY_BLOCKADE_RANK()
	CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE_INFO(frame)
	CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_REWARD_INFO(frame)
	CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_LIST(frame)
end

-- blockade - blockade get clear time 
function GET_CLEAR_TIME_GUILD_ACTIVITY_DETAIL_BLOCKADE(rank)
	local clear_time_str = session.boruta_ranking.GetRankInfoClearTime(rank)
	local clear_time_ms = tonumber(clear_time_str)
	local clear_hour = math.floor(clear_time_ms / (60 * 60 * 1000))
	local clear_min = math.floor(clear_time_ms / (60 * 1000)) - (clear_hour * 60)
	local clear_sec = math.floor(clear_time_ms / 1000) - ((clear_hour * 60 + clear_min) * 60)
	local clear_ms = math.fmod(clear_time_ms, 1000)
	if clear_ms < 0 then
		clear_ms = 0
	end

	local time_text = "-"
	if clear_hour > 0 then
		time_text = string.format("%d:%02d:%02d.%03d", clear_hour, clear_min, clear_sec, clear_ms)
	else
		time_text = string.format("%02d:%02d.%03d", clear_min, clear_sec, clear_ms)
	end
	return time_text
end

-- blokcade - bloackde info create
function CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE_INFO(frame)
	local guild_info = session.party.GetPartyInfo(PARTY_GUILD)
	if guild_info ~= nil then
		local guild_id = guild_info.info:GetPartyID()
		local guild_rank = session.boruta_ranking.GetGuildRank(guild_id)
		local clear_time = nil
		if guild_rank > 0 then
			clear_time = GET_CLEAR_TIME_GUILD_ACTIVITY_DETAIL_BLOCKADE(guild_rank - 1)
		else
			guild_rank = "0"
			clear_time = ClMsg("HaveNoClearInfo")
		end

		local info_rank = GET_CHILD_RECURSIVELY(frame, "guild_blockade_info_1")
		if info_rank ~= nil then
			local name_text = GET_CHILD_RECURSIVELY(info_rank, "name")
			if name_text ~= nil then
				name_text:SetTextByKey("value", ScpArgMsg("ServerRanking"))
			end
	
			local value_text = GET_CHILD_RECURSIVELY(info_rank, "value")
			if value_text ~= nil then
				value_text:SetTextByKey("value", guild_rank)
			end
		end

		local info_time = GET_CHILD_RECURSIVELY(frame, "guild_blockade_info_2")
		if info_time ~= nil then
			local name_text = GET_CHILD_RECURSIVELY(info_time, "name")
			if name_text ~= nil then
				if config.GetServiceNation() == 'GLOBAL' or config.GetServiceNation() == 'PAPAYA' then
					name_text:SetTextByKey("value", "Time")
				else
					name_text:SetTextByKey("value", ScpArgMsg("Auto_SiKan"))
				end
			end
	
			local value_text = GET_CHILD_RECURSIVELY(info_time, "value")
			if value_text ~= nil then
				value_text:SetTextByKey("value", clear_time)
			end
		end

		local time_gauge = GET_CHILD_RECURSIVELY(frame, "guild_blockade_time_gauge")
		local time_text = GET_CHILD_RECURSIVELY(frame, "guild_blockade_time_text")
		if time_gauge ~= nil and time_text ~= nil then
			local start_time = session.boruta_ranking.GetBorutaStartTime()
			local end_time = session.boruta_ranking.GetBorutaEndTime()
			local dur_time = imcTime.GetDifSec(end_time, start_time)
			local sys_time = geTime.GetServerSystemTime()
			local dif_sec = imcTime.GetDifSec(end_time, sys_time)
			if dif_sec > 0 then
				time_gauge:SetPoint(dur_time - dif_sec, dur_time)

				local time_text_value = GET_TIME_TXT(dif_sec)..ClMsg("After_Exit")
				time_text:SetTextByKey("value", time_text_value)
				time_text:SetUserValue("START_SEC", imcTime.GetAppTime())
				time_text:SetUserValue("REMAIN_SEC", dif_sec)
				time_text:RunUpdateScript("GUILD_ACTIVITY_DETAIL_BLOCKADE_INFO_TIME")
			elseif dif_sec < 0 then
				time_gauge:SetPoint(1, 1)

				local time_text_value = ClMsg("Already_Exit_Raid")
				time_text:SetTextByKey("value", time_text_value)
				time_text:StopUpdateScript("GUILD_ACTIVITY_DETAIL_BLOCKADE_INFO_TIME")
			end
		end
	end
end

-- blockade - blockade info time
function GUILD_ACTIVITY_DETAIL_BLOCKADE_INFO_TIME(time_text)
	local elapsed_sec = imcTime.GetAppTime() - time_text:GetUserIValue("START_SEC")
	local start_sec = time_text:GetUserIValue("REMAIN_SEC")
	start_sec = start_sec - elapsed_sec

	if start_sec < 0 then
		time_text:SetFontName("red_18")
		time_text:StopUpdateScript("GUILD_ACTIVITY_DETAIL_BLOCKADE_INFO_TIME")
		time_text:ShowWindow(0)
		return 0
	end

	local time_text_value = GET_TIME_TXT(start_sec)
	time_text:SetTextByKey("value", time_text_value)
	return 1
end

-- blockade - blockade rank get reward list
function GET_REWARD_LIST_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_REWARD_INFO(event_id)
	local list, idx = {}, 1
	local reward_list, reward_cnt = GET_BORUTA_REWARD(event_id)
	if reward_list ~= nil and reward_cnt > 0 then
		for i = 1, reward_cnt do
			local reward_str = reward_list[i]
			local pre_reward_str = ""
			if idx - 1 > 0 then
				pre_reward_str = reward_list[idx - 1].rewardstr
			end

			if pre_reward_str == "" or pre_reward_str ~= reward_str then
				local temp = {}
				temp["start_rank"] = i
				temp["end_rank"] = i
				temp["rewardstr"] = reward_str
				list[idx] = temp
				idx = idx + 1
			else
				list[idx - 1].end_rank = i
			end
		end
	end
	return list
end

-- blockade - blockade rank get week num
function GET_WEEK_NUM_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_REWARD_INFO(frame)
	local tab = GET_CHILD_RECURSIVELY(frame, "guild_blocakde_season_tab")
	if tab ~= nil then
		local select_idx = tab:GetSelectItemIndex()
		return session.boruta_ranking.GetNowWeekNum() - select_idx
	end
	return 0
end

-- blokcade - bloackde rank reward info create
function CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_REWARD_INFO(frame)
	local event_id = GET_EVENT_TYPE_AND_BOSS_NAME_GUILD_ACTIVITY_DETAIL_BLOCAKDE_RANK()
	local list = GET_REWARD_LIST_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_REWARD_INFO(event_id)
	local gbox = GET_CHILD_RECURSIVELY(frame, "guild_blockade_rank_reward_info_gbox")
	if gbox ~= nil then
		local guild_info = session.party.GetPartyInfo(PARTY_GUILD)
		if guild_info ~= nil then
			local guild_id = guild_info.info:GetPartyID()
			local guild_rank = session.boruta_ranking.GetGuildRank(guild_id)
			local week_num = GET_WEEK_NUM_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_REWARD_INFO(frame)
			local y = 0
			for i = 1, #list do
				local reward_info = list[i]
				if reward_info ~= nil then
					local start_rank = reward_info.start_rank
					local end_rank = reward_info.end_rank
					local ctrlset = gbox:CreateOrGetControlSet("guild_blockade_rank_reward_info", "Blockade_RankReward_Info_"..i, 0, y)
					if ctrlset ~= nil then
						local text = GET_CHILD_RECURSIVELY(ctrlset, "text")
						if text ~= nil then
							text:SetFontName("black_16_b")
							if start_rank == end_rank then
								local rank_format = frame:GetUserConfig("BLOCKADE_RANK_REWARD_FORMAT_1")
								text:SetFormat(rank_format)
								text:AddParamInfo("value", start_rank)
								text:UpdateFormat()
								text:SetText("")
							else
								local rank_format = frame:GetUserConfig("BLOCKADE_RANK_REWARD_FORMAT_2")
								text:SetFormat(rank_format)
								text:AddParamInfo("min", start_rank)
								text:AddParamInfo("max", end_rank)
								text:UpdateFormat()
								text:SetText("")
							end
						end
						CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_REWARD_INFO_REWARD_LIST(frame, ctrlset, reward_info.rewardstr)

						local btn = GET_CHILD_RECURSIVELY(ctrlset, "btn")
						if btn ~= nil then
							if session.boruta_ranking.RewardAccepted(week_num) == 1 then
								btn:SetEnable(0)
								local pic = GET_CHILD_RECURSIVELY(ctrlset, "pic")
								if pic ~= nil then
									pic:SetImage("adventure_stamp")
								end
							elseif guild_rank > 0 and guild_rank >= start_rank and guild_rank <= end_rank then
								btn:EnableHitTest(0)
							else
								btn:SetEnable(0)				
							end
						end
						y = y + ctrlset:GetHeight()
					end
				end
			end
		end
	end
end

-- blokcade - bloackde rank reward info - detail reward list create
function CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_REWARD_INFO_REWARD_LIST(frame, parent_ctrlset, reward_str)
	local gb = GET_CHILD_RECURSIVELY(parent_ctrlset, "gb")
	if gb ~= nil then
		gb:RemoveAllChild()
		local reward_list = StringSplit(reward_str, ';')
		if reward_list ~= nil and #reward_list > 0 then
			local offset_small = 5
			local offset_mid = 10
			local list_y = offset_small + offset_mid
			for i = 1, #reward_list do
				local reward_list_info = reward_list[i]
				local reward_ctrlset = gb:CreateOrGetControlSet("guild_blockade_rank_reward_list_info", "Blockade_RankRewardList_Info_"..i, 0, list_y)
				if reward_ctrlset ~= nil then
					local item_cls = nil
					local reward_item_info_list = StringSplit(reward_list_info, '/')
					if #reward_item_info_list > 0 then
						item_cls = GetClass("Item", reward_item_info_list[1])
					end

					if item_cls ~= nil then
						local pic = GET_CHILD_RECURSIVELY(reward_ctrlset, "pic")
						if pic ~= nil then
							pic:SetImage(GET_ITEM_ICON_IMAGE(item_cls))
						end

						local name_text = GET_CHILD_RECURSIVELY(reward_ctrlset, "name_text")
						if name_text ~= nil then
							local item_name = dic.getTranslatedStr(TryGetProp(item_cls, "Name", "None"))
							name_text:SetTextByKey("value", item_name)
						end
						
						local count_text = GET_CHILD_RECURSIVELY(reward_ctrlset, "count_text")
						if count_text ~= nil then
							local value = reward_item_info_list[2]
							count_text:SetTextByKey("value", value)
						end
						reward_ctrlset:Resize(reward_ctrlset:GetWidth(), math.max(name_text:GetHeight() + count_text:GetHeight(), reward_ctrlset:GetHeight()))

						if name_text:GetWidth() < name_text:GetTextWidth() then
							name_text:EnableSlideShow(1)
							name_text:SetCompareTextWidthBySlideShow(true)
						else
							name_text:EnableSlideShow(0)
							name_text:SetCompareTextWidthBySlideShow(false)
						end
						list_y = list_y + reward_ctrlset:GetHeight() + offset_mid
					end
				end
			end

			local btn = GET_CHILD_RECURSIVELY(parent_ctrlset, "btn")
			if btn ~= nil then
				btn:Resize(btn:GetWidth(), list_y + offset_mid)
			end
			gb:Resize(gb:GetWidth(), list_y + offset_mid)
			parent_ctrlset:Resize(parent_ctrlset:GetWidth(), list_y + offset_small)
		end
	end
end

-- blockade - blockade select event_type
function GET_EVENT_TYPE_AND_BOSS_NAME_GUILD_ACTIVITY_DETAIL_BLOCAKDE_RANK()
	local event_id = "0"
	local mon_cls_name = "None"
	local frame = ui.GetFrame("guild_activity_ui")
	if frame ~= nil then
		local tab = GET_CHILD_RECURSIVELY(frame, "guild_blockade_event_type_tab", "ui::CTabControl")
		if tab ~= nil then
			local select_idx = tab:GetSelectItemIndex()
			event_id = "50"..select_idx

			local cls = GetClassByType("GuildEvnet", tonumber(event_id))
			if cls ~= nil then
				mon_cls_name = TryGetProp(cls, "BossName", "None")
			end
		end
	end
	return tonumber(event_id), mon_cls_name
end 

-- blokcade - bloackde rank list create
function CREATE_GUILD_ACTIVITY_DETAIL_BLOCKADE_RANK_LIST(frame)
	local week_num = session.boruta_ranking.GetNowWeekNum()
	local season_tab = GET_CHILD_RECURSIVELY(frame, "guild_blocakde_season_tab")
	if season_tab ~= nil then
		local cnt = season_tab:GetItemCount()
		for i = 0, cnt - 1 do
			if week_num - i > 0 then
				season_tab:ChangeCaption(i, "{@st42b}{s16}"..tostring(week_num - i), false)
			else
				season_tab:ChangeCaption(i, "{@st42b}{s16}-", false)
			end
		end
	end

	local gbox = GET_CHILD_RECURSIVELY(frame, "guild_blockade_rank_list_gbox")
	if gbox ~= nil then
		local cnt = session.boruta_ranking.GetRankInfoListSize()
		local height = ui.GetControlSetAttribute("guild_blockade_rank_info", "height")
		for i = 1, cnt do
			local y = height * (i - 1)
			local ctrlset = gbox:CreateOrGetControlSet("guild_blockade_rank_info", "Blockade_Rank_Info_"..i, 0, y)
			if ctrlset ~= nil then
				local rank_pic = GET_CHILD_RECURSIVELY(ctrlset, "rank_pic")
				local rank_text = GET_CHILD_RECURSIVELY(ctrlset, "rank_text")
				if rank_pic ~= nil and rank_text ~= nil then
					if i <= 3 then
						rank_pic:SetImage("raid_week_rank_0"..i)
						rank_pic:ShowWindow(1)
						rank_text:ShowWindow(0)
					else
						rank_pic:ShowWindow(0)
						rank_text:SetTextByKey("value", i)
						rank_text:ShowWindow(1)
					end
				end

				local value_text = GET_CHILD_RECURSIVELY(ctrlset, "value_text")
				if value_text ~= nil then
					local clear_time_text = GET_CLEAR_TIME_GUILD_ACTIVITY_DETAIL_BLOCKADE(i - 1)
					value_text:SetTextByKey("time", clear_time_text)
				end

				local guild_id = session.boruta_ranking.GetRankInfoGuildID(i - 1)
				if guild_id ~= "0" then
					ctrlset:SetUserValue("GUILD_IDX", guild_id)
					GetGuildEmblemImage("SET_GUILD_EMBLEM_ACTIVITY_DETAIL_BLOCKADE_RANK_LIST", guild_id)
				end
				
				local name_text = GET_CHILD_RECURSIVELY(ctrlset, "name_text")
				if name_text ~= nil then
					local guild_name = session.boruta_ranking.GetRankInfoGuildName(i - 1)
					name_text:SetTextByKey("value", guild_name)
				end
			end
		end
	end
end

-- blockade - blockade rank list : guild emblem image set
function SET_GUILD_EMBLEM_ACTIVITY_DETAIL_BLOCKADE_RANK_LIST(code, return_json)
	if code ~= 200 then
        if code == 400 or code == 404 then
            return
        else
            SHOW_GUILD_HTTP_ERROR(code, return_json, "SET_GUILD_EMBLEM_ACTIVITY_DETAIL_BLOCKADE_RANK_LIST")
            return
        end
    end

	local guild_idx = return_json
	local emblem_folder_path = filefind.GetBinPath("GuildEmblem"):c_str()
	local emblem_path = emblem_folder_path.."\\"..guild_idx..".png"

	local frame = ui.GetFrame("guild_activity_ui")
	if frame ~= nil then
		local gbox = GET_CHILD_RECURSIVELY(frame, "guild_blockade_rank_list_gbox")
		if gbox ~= nil then
			local count = gbox:GetChildCount()
			for i = 0, count do
				local ctrlset = gbox:GetChildByIndex(i)
				if ctrlset ~= nil and ctrlset:GetUserValue("GUILD_IDX") == guild_idx then
					local emblem_pic = GET_CHILD_RECURSIVELY(ctrlset, "emblem_pic")
					if emblem_pic ~= nil then
						emblem_pic = tolua.cast(emblem_pic, "ui::CPicture")
						ui.SetImageByPath(emblem_path, emblem_pic)
					end
				end
			end
		end
	end
end

---- detail - guild tower control
-- craft time reduce buff - create info
function CREATE_GUILD_ACTIVITY_DETAIL_CRAFT_TIME_REDUCE_BUFF_INFO(frame, gbox)
	local buff_name = "ReduceCraftTime_Buff"
	local buff_cls = GetClass("Buff", buff_name)
	if buff_cls ~= nil then
		local pic = GET_CHILD_RECURSIVELY(gbox, "buff_pic")
		if pic ~= nil then
			local icon = TryGetProp(buff_cls, "Icon", "None")
			icon = "icon_"..icon
			pic:SetImage(icon)
		end

		local name_text = GET_CHILD_RECURSIVELY(gbox, "buff_name_text")
		if name_text ~= nil then
			local name = dic.getTranslatedStr(TryGetProp(buff_cls, "Name", "None"))
			name_text:SetTextByKey("value", name)
		end

		local desc_text = GET_CHILD_RECURSIVELY(gbox, "buff_desc_text")
		if desc_text ~= nil then
			local desc = dic.getTranslatedStr(TryGetProp(buff_cls, "ToolTip", "None"))
			desc_text:SetTextByKey("value", desc)
		end
	end
end

-- craft time reduec buff - add buff
function ADD_BUFF_GUILD_ACTIVITY_DETAIL_CRAFT_TIME_REDUCE_BUFF(parent, btn)
	guild.RequestCraftTimeReduceBuff()
	ui.CloseFrame("guild_activity_ui")
end

-- guild agit move - remove info
function REMOVE_GUILD_ACTIVITY_DETAIL_AGIT_MOVE(frame)
	local gbox = GET_CHILD_RECURSIVELY(frame, "agit_move_housing_facilities_info_gbox")
	if gbox ~= nil then
		RemoveChildByPattern(gbox, "Guild_Facilities_Info_")
	end
end

-- guild agit move - create info
function CREATE_GUILD_ACTIVITY_DETAIL_AGIT_MOVE(frame, gbox)
	-- agit extension, production, weapon_research, armor_research, attribute_research 
	local extension_level = 1
	local facilities_level = {}
	local guild_agit = housing.GetGuildAgitInfo()
	if guild_agit ~= nil then
		extension_level = guild_agit.extensionLevel
		facilities_level["production"] = guild_agit.productionLevel
		facilities_level["weapon_research"] = guild_agit.labLevels[tos.housing.guild.eWeapon + 1]
		facilities_level["armor_research"] = guild_agit.labLevels[tos.housing.guild.eArmor + 1]
		facilities_level["attribute_research"] = guild_agit.labLevels[tos.housing.guild.eAttribute + 1]
		
		-- agit extension level pic
		local agit_move_extension_step_pic = GET_CHILD_RECURSIVELY(frame, "guild_agit_move_extension_step_pic")
		if agit_move_extension_step_pic ~= nil then
			-- ** 이미지 추가되면 변경할 부분 : 길드 확장 단계 정보.
			agit_move_extension_step_pic:SetImage("housing_level_icon_0"..extension_level)
		end
	
		-- agit extension level gauge
		local agit_move_extension_step_gauge = GET_CHILD_RECURSIVELY(frame, "guild_agit_move_extension_step_gauge")
		if agit_move_extension_step_gauge ~= nil then
			local max_level = 5
			agit_move_extension_step_gauge:SetPoint(extension_level, max_level)
		end
	
		-- guild housing facilities
		local info_gbox = GET_CHILD_RECURSIVELY(gbox, "guild_agit_move_housing_facilities_info_gbox")
		if info_gbox ~= nil then
			local facilities_list = {} -- ctrlset_name, class_name, clmsg, **icon_name(이건 새롭게 추가되면 변경 예정.)
			facilities_list[1] = { "production", "guild_manufacture_workshop_extension", "Housing_ProductionLab", "icon_guild_housing_manufacture" }
			facilities_list[2] = { "weapon_research", "guild_weapon_lab_extension", "Housing_WeaponLab", "icon_guild_housing_lab_weapon" }
			facilities_list[3] = { "armor_research", "guild_armor_lab_extension", "Housing_ArmorLab", "icon_guild_housing_lab_armor" }
			facilities_list[4] = { "attribute_research", "guild_attribute_lab_extension", "Housing_AttributeLab", "icon_guild_housing_lab_attribute" }
	
			local start_y = 50
			for i = 1, #facilities_list do
				local name = facilities_list[i][1]
				local class_name = facilities_list[i][2]
				local cl_msg = facilities_list[i][3]
				local icon_name = facilities_list[i][4]
				local level = facilities_level[name]
				local ctrlset_height = ui.GetControlSetAttribute("guild_agit_move_facilities_info", "height")
				local y = start_y + (ctrlset_height * (i - 1))
				local ctrlset = info_gbox:CreateOrGetControlSet("guild_agit_move_facilities_info", "Guild_Facilities_Info_"..i, 0, y)
				if ctrlset ~= nil then
					ctrlset = AUTO_CAST(ctrlset)
					local disable_color = frame:GetUserConfig("DISABLE_COLOR")
					if level < 1 then
						ctrlset:SetColorTone(disable_color)
					else
						ctrlset:SetColorTone("FFFFFFFF")
					end
	
					local pic = GET_CHILD_RECURSIVELY(ctrlset, "pic")
					if pic ~= nil then
						pic:SetImage(icon_name)
					end
	
					local name_text = GET_CHILD_RECURSIVELY(ctrlset, "name")
					if name_text ~= nil then
						name_text:SetTextByKey("level", tostring(level))
						name_text:SetTextByKey("name", ClMsg(cl_msg))
					end
	
					local desc_text = GET_CHILD_RECURSIVELY(ctrlset, "desc")
					if desc_text ~= nil then
						local cls = GetClass("guild_housing", class_name..level)
						if cls ~= nil then
							local desc = TryGetProp(cls, "Caption1")
							desc_text:SetTextByKey("desc", desc)
						else
							desc_text:SetTextByKey("desc", "")
						end
					end
				end
			end
		end
	end
end

-- guild agit move - move btn
function EXEC_AGIT_MOVE_GUILD_ACTIVITY_DETAIL_AGIT_MOVE(parent, btn)
	guild.RequestGuildAgitMove()
	ui.CloseFrame("guild_activity_ui")
end

-- guild tower control - create info
function CREATE_GUILD_ACTIVITY_DETAIL_TOWER_CONTROL(frame, gbox)
	local guild_obj = GetMyGuildObject()
	if guild_obj ~= nil then
		local map_text = GET_CHILD_RECURSIVELY(gbox, "guild_tower_map_text")
		local time_text = GET_CHILD_RECURSIVELY(gbox, "guild_tower_time_text")
		local tower_remove_btn = GET_CHILD_RECURSIVELY(gbox, "guild_tower_remove_btn")

		local is_tower_exist = true
		local tower_position = TryGetProp(guild_obj, "HousePosition", "None")
		if tower_position == "None" then
			is_tower_exist = false
		end

		if is_tower_exist == false then
			map_text:SetTextByKey("map", ScpArgMsg("NoGuildTowerToShow"))
			time_text:ShowWindow(0)
			tower_remove_btn:SetColorTone("FF444444")
			tower_remove_btn:SetEnable(0)
		else
			time_text:ShowWindow(1)
			tower_remove_btn:SetColorTone("FFFFFFFF")
			tower_remove_btn:SetEnable(1)
			
			local tower_info = StringSplit(tower_position, '#')
			if #tower_info == 3 then
				-- destroy by other guild
				local destroy_party_name = tower_info[2]
				if destroy_party_name == "None" then
					destroy_party_name = ScpArgMsg("Enemy")
				end
				local position_text = "{#FF0000}"..ScpArgMsg("DestroyedByGuild{Name}", "Name", destroy_party_name).."{/}"
				map_text:SetTextByKey("map", position_text)

				local destroy_time = tower_info[3]
				time_text:SetUserValue("PartyName", destroy_party_name)
				time_text:SetUserValue("DestroyTime", destroy_time)
				time_text:RunUpdateScript("UPDATE_TOWER_DESTROY_TIME_GUILD_ACTIVITY_DETAIL_TOWER_CONTROL", 1, 0, 0, 1)
				UPDATE_TOWER_DESTROY_TIME_GUILD_ACTIVITY_DETAIL_TOWER_CONTROL(time_text)
			else
				local map_id = tower_info[1]
				local tower_id = tower_info[2]
				local x, y, z = tower_info[3], tower_info[4], tower_info[5]
				local map_cls = GetClassByType("Map", map_id)
				if map_cls ~= nil then
					local map_cls_name = TryGetProp(map_cls, "ClassName", "None")
					local map_link_text = MAKE_LINK_MAP_TEXT(map_cls_name, x, z)
					map_text:SetTextByKey("map", map_link_text)
				end

				local time = tower_info[6]
				time_text:SetUserValue("TowerTime", time)
				time_text:RunUpdateScript("UPDATE_TOWER_REMAIN_TIME_GUILD_ACTIVITY_DETAIL_TOWER_CONTROL", 1, 0, 0, 1)
				UPDATE_TOWER_REMAIN_TIME_GUILD_ACTIVITY_DETAIL_TOWER_CONTROL(time_text)
			end
		end
	end
end

-- guild tower control - update tower time
function UPDATE_TOWER_REMAIN_TIME_GUILD_ACTIVITY_DETAIL_TOWER_CONTROL(time_text)
	local time = time_text:GetUserValue("TowerTime")
	local end_time = imcTime.GetSysTimeByStr(time)
	end_time = imcTime.AddSec(end_time, GUILD_TOWER_LIFE_MIN * 60)

	local sys_time = geTime.GetServerSystemTime()
	local dif_sec = imcTime.GetDifSec(end_time, sys_time)

	local dif_sec_str = GET_TIME_TXT_DHM(dif_sec)
	time_text:SetTextByKey("time", dif_sec_str)
	return 1
end

-- guild tower control - detroy tower time
function UPDATE_TOWER_DESTROY_TIME_GUILD_ACTIVITY_DETAIL_TOWER_CONTROL(time_text)
	local time = time_text:GetUserValue("DestroyTime")
	local end_time = imcTime.GetSysTimeByStr(time)
	end_time = imcTime.AddSec(end_time, GUILD_TOWER_DESTROY_REBUILD_ABLE_MIN * 60)

	local sys_time = geTime.GetServerSystemTime()
	local dif_sec = imcTime.GetDifSec(end_time, sys_time)
	if dif_sec > 0 then
		local dif_sec_str = GET_TIME_TXT_DHM(dif_sec)
		time_text:SetTextByKey("time", dif_sec_str)
	else
		local destroy_party_name = time_text:GetUserValue("PartyName")
		local position_text = "{#FF0000}"..ScpArgMsg("DestroyedByGuild{Name}", "Name", destroy_party_name).."{/}"
		time_text:SetTextByKey("time", position_text)
		return 0
	end
	return 1
end

-- guild tower control - tower remove btn
function REMOVE_GUILD_TOWER_GUILD_ACTIVITY_DETAIL_TOWER_CONTROL(parent, btn)
	guild.RequestGuildTowerRemove()
	ui.CloseFrame("guild_activity_ui")
end