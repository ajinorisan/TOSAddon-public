local json = require "json_imc"

local curPage = 0
local prevPage = 0

function GEAR_SCORE_RANKING_ON_INIT(addon, frame)
end

function GEAR_SCORE_RANKING_OPEN(frame)
	curPage = 0
	if IS_SEASON_SERVER() == 'YES' then
		GetStatusRanking('callback_get_gear_score_ranking', 'account_gear_score', curPage)
	else
		GetStatusRanking('callback_get_gear_score_ranking', 'pc_gear_score', curPage)
	end
end

function GEAR_SCORE_RANKING_PREV_BUTTON(parent, self)
	if curPage == 0 then
		return;
	end
	prevPage = curPage 
	curPage = curPage - 1
	if IS_SEASON_SERVER() == 'YES' then
		GetStatusRanking('callback_get_gear_score_ranking', 'account_gear_score', curPage)
	else
		GetStatusRanking('callback_get_gear_score_ranking', 'pc_gear_score', curPage)
	end
end

function GEAR_SCORE_RANKING_NEXT_BUTTON(parent, self)
	if curPage >= 199 then
		ui.SysMsg(ClMsg('NotExistRankInfo'))
		return
	end
	prevPage = curPage 
	curPage = curPage + 1
	if IS_SEASON_SERVER() == 'YES' then
		GetStatusRanking('callback_get_gear_score_ranking', 'account_gear_score', curPage)
	else
		GetStatusRanking('callback_get_gear_score_ranking', 'pc_gear_score', curPage)
	end
end

function callback_get_gear_score_ranking(code, ret_json)
	local frame = ui.GetFrame("gear_score_ranking")
	local userListBox = GET_CHILD_RECURSIVELY(frame,"userListBox")
	local playerBox = GET_CHILD_RECURSIVELY(frame,"playerBox")

	local pageText = GET_CHILD_RECURSIVELY(frame, "pageText")

	if code == 404 then		
		ui.SysMsg(ScpArgMsg('{datetime}CantUseFor', 'datetime', ret_json))
		curPage = prevPage -- 페이지 변경에 실패
		return
	end

	if code ~= 200 then
		curPage = prevPage -- 페이지 변경에 실패
		SHOW_GUILD_HTTP_ERROR(code, ret_json, "callback_get_party_info")
		return
	end

	local dic = json.decode(ret_json)
	local list_size = dic['size']
	if list_size == 0 then
		curPage = prevPage
		ui.SysMsg(ClMsg('NotExistRankInfo'))
		return
	end

	local myRank = dic["my_rank"]
	local myScore = dic['my_score']
	local rankList = dic["list"]

	userListBox:RemoveAllChild()
	playerBox:RemoveAllChild()
	pageText:SetTextByKey("page", curPage + 1)

    local myHandle = session.GetMyHandle();
	local myGuildIdx = 0
	local myTeamName = info.GetFamilyName(myHandle)
	local myCharName = info.GetName(myHandle)
	local myGuild = GET_MY_GUILD_INFO()
	local myValue = myScore
    if myGuild ~= nil then
		myGuildIdx = myGuild.info:GetPartyID()
	end

	local myRankInfoCtrl = playerBox:CreateOrGetControlSet('gearscore_ranking_ranker', 'USER_INFO', 0, 0)
	GEAR_SCORE_RANKING_CREATE_INFO(myRankInfoCtrl, myRank, myGuildIdx, myTeamName, myCharName, myValue)

	for k,v in pairs(rankList) do 
		local guildName = v["guild_name"]
		local teamName = v["team_name"]
		local charName = v["char_name"]
		local guildIdx = v["guild_idx"]
		local type = v["type"]
		local value = v["value"]
		local rank = v["rank"]
		local rankInfoCtrl = userListBox:CreateOrGetControlSet('gearscore_ranking_ranker', 'USER_INFO_'..rank, 0, 37 + (k - 1) * 64)
		
		rank = curPage * 10 + rank
		if teamName == myTeamName and charName == myCharName then
			teamName = "{#0000FF}"..teamName
			charName = "{#0000FF}"..charName
		end
		GEAR_SCORE_RANKING_CREATE_INFO(rankInfoCtrl, rank, guildIdx, teamName, charName, value)
	end
end

function GEAR_SCORE_RANKING_CREATE_INFO(ctrl, rank, guildIdx, teamName, charName, value)
	local guildPic = GET_CHILD(ctrl, "emblem_pic")
	local rankText = GET_CHILD(ctrl, "rank_text")
	local teamNameText = GET_CHILD(ctrl, "team_name_text")
	local charNameText = GET_CHILD(ctrl, "char_name_text")
	local valueText = GET_CHILD(ctrl, "value_text")

	rankText:SetTextByKey("value", rank)
	teamNameText:SetTextByKey("value", teamName)
	charNameText:SetTextByKey("value", charName)
	valueText:SetTextByKey("value", value)

	if guildIdx ~= "0" then
		local worldID = session.party.GetMyWorldIDStr()
		local emblemImgName = guild.GetEmblemImageName(guildIdx, worldID)
		if emblemImgName ~= 'None' then
			guildPic:SetFileName(emblemImgName)
		end
	end
end