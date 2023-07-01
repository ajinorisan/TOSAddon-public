ADVENTURE_BOOK_GROW = {};

function ADVENTURE_BOOK_GROW.RENEW()
	ADVENTURE_BOOK_GROW.CLEAR();
	ADVENTURE_BOOK_GROW.FILL_CHAR_LIST(gbox);
	ADVENTURE_BOOK_GROW.FILL_CTRL_TYPES();
    ADVENTURE_BOOK_GROW_SET_POINT();
    ADVENTURE_BOOK_GROW_SET_TEAM_LEVEL();
end

function ADVENTURE_BOOK_GROW.CLEAR()
	local frame = ui.GetFrame('adventure_book');
	local gb_adventure = GET_CHILD(frame, "gb_adventure", "ui::CGroupBox");
	local page = GET_CHILD(gb_adventure, "page_grow", "ui::CGroupBox");
	local charList = GET_CHILD(page, "grow_char_list", "ui::CGroupBox");

	local warriorList = GET_CHILD(page, "page_grow_warrior", "ui::CGroupBox");
	local wizardList = GET_CHILD(page, "page_grow_wizard", "ui::CGroupBox");
	local archerList = GET_CHILD(page, "page_grow_archer", "ui::CGroupBox");
	local clericList = GET_CHILD(page, "page_grow_cleric", "ui::CGroupBox");
	local scoutList = GET_CHILD(page, "page_grow_scout", "ui::CGroupBox");

	charList:RemoveAllChild();
	warriorList:RemoveAllChild();
	wizardList:RemoveAllChild();
	archerList:RemoveAllChild();
	clericList:RemoveAllChild();
	scoutList:RemoveAllChild();
end

function ADVENTURE_BOOK_GROW.FILL_CHAR_LIST()
	local frame = ui.GetFrame('adventure_book');
	local gb_adventure = GET_CHILD(frame, "gb_adventure", "ui::CGroupBox");
	local page = GET_CHILD(gb_adventure, "page_grow", "ui::CGroupBox");
	local gbox = GET_CHILD(page, "grow_char_list", "ui::CGroupBox");

	local char_name_func = ADVENTURE_BOOK_GROW_CONTENT['CHAR_NAME_LIST']
	local char_info_func = ADVENTURE_BOOK_GROW_CONTENT['CHAR_INFO']

	if char_name_func == nil or char_info_func == nil then
		return;
	end

	local char_name_table = char_name_func();

    local yPos = 0;
	for i=1,#char_name_table do
		local charName = char_name_table[i]
		local char_info_table = char_info_func(charName);

		local ctrlSet = gbox:CreateOrGetControlSet("adventure_book_grow_elem", "list_char_" .. i, ui.LEFT, ui.TOP, 0, yPos, 0, 0);
		local icon = GET_CHILD(ctrlSet, "icon_pic", "ui::CPicture");
		icon:SetImage(char_info_table.icon);
		SET_TEXT(ctrlSet, "name_text", "value", char_info_table["name"])
		SET_TEXT(ctrlSet, "level_text", "value", char_info_table["level"])
        ADVENTURE_BOOK_GROW_SET_JOB_HISTORY_TOOLTIP(icon, char_info_table["name"]);
        yPos = yPos + ctrlSet:GetHeight();
	end
end

function ADVENTURE_BOOK_GROW.FILL_CTRL_TYPES()
	ADVENTURE_BOOK_GROW.FILL_CTRL_TYPE("Warrior", "page_grow_warrior");
	ADVENTURE_BOOK_GROW.FILL_CTRL_TYPE("Wizard", "page_grow_wizard");
	ADVENTURE_BOOK_GROW.FILL_CTRL_TYPE("Archer", "page_grow_archer");
	ADVENTURE_BOOK_GROW.FILL_CTRL_TYPE("Cleric", "page_grow_cleric");
	ADVENTURE_BOOK_GROW.FILL_CTRL_TYPE("Scout", "page_grow_scout");
end

function ADVENTURE_BOOK_GROW.FILL_CTRL_TYPE(ctrlType, ctrlName)
	local frame = ui.GetFrame('adventure_book');
	local gb_adventure = GET_CHILD(frame, "gb_adventure", "ui::CGroupBox");
	local page = GET_CHILD(gb_adventure, "page_grow", "ui::CGroupBox");
	local gbox = GET_CHILD(page, ctrlName, "ui::CGroupBox");

	local job_list_func = ADVENTURE_BOOK_GROW_CONTENT['JOB_LIST_BY_TYPE']
	local job_info_func = ADVENTURE_BOOK_GROW_CONTENT['JOB_INFO']

	if job_list_func == nil or job_info_func == nil then
		return;
	end

	local char_name_table = job_list_func(ctrlType);
	
	for i=1,#char_name_table do
		local jobClsID = char_name_table[i]
		local job_info_table = job_info_func(jobClsID);
	
		local width = frame:GetUserConfig("JOB_ELEM_WIDTH")
		local height = frame:GetUserConfig("JOB_ELEM_HEIGHT")

		local x = (i-1)%5*width
		local y = math.floor((i-1)/5)*height
		local ctrlSet = gbox:CreateOrGetControlSet("adventure_book_grow_job_icon", "list_job_" .. i, ui.LEFT, ui.TOP, x, y, 0, 0);
		local icon = GET_CHILD(ctrlSet, "icon_pic", "ui::CPicture");
		icon:SetImage(job_info_table['icon']);
		if job_info_table['has_job'] == 0 then
            local SIHOUETTE_COLOR_TONE = frame:GetUserConfig('SIHOUETTE_COLOR_TONE');
			icon:SetColorTone(SIHOUETTE_COLOR_TONE);
		end
		icon:SetTooltipType('adventure_book_job_info');
		icon:SetTooltipArg(jobClsID, 0, 0);
	end
end

function ADVENTURE_BOOK_GROW.TOOLTIP_JOB(frame, strArg)
	local job_info_func = ADVENTURE_BOOK_GROW_CONTENT['JOB_INFO']
	local job_info_table = job_info_func(strArg);

	local jobname_text = GET_CHILD_RECURSIVELY(frame, "jobname_text")
	local jobrank_text = GET_CHILD_RECURSIVELY(frame, "jobrank_text")
	local jobtype_text = GET_CHILD_RECURSIVELY(frame, "jobtype_text")
	local jobdifficulty_text = GET_CHILD_RECURSIVELY(frame, "jobdifficulty_text")
	local desc_text = GET_CHILD_RECURSIVELY(frame, "desc_text")

	jobname_text:SetTextByKey("value", job_info_table["name"])
	jobrank_text:SetTextByKey("value", job_info_table["ctrltype_and_rank"])
	jobtype_text:SetTextByKey("value", job_info_table["type"])
	jobdifficulty_text:SetTextByKey("value", job_info_table["difficulty"])
	desc_text:SetTextByKey("value", job_info_table["desc"])

	local desc_margin = desc_text:GetMargin()
	local desc_height = desc_text:GetHeight()
	local bottom_margin = 25
	local check_value = desc_margin.top + desc_height + bottom_margin
	if check_value > 300 then
		frame:Resize(frame:GetWidth(), check_value)
	else
		frame:Resize(frame:GetWidth(), 300)
	end
end

function ADVENTURE_BOOK_GROW_SET_POINT()
    local adventure_book = ui.GetFrame('adventure_book');
    local gb_adventure = adventure_book:GetChild('gb_adventure');
    local page_grow = gb_adventure:GetChild('page_grow');
    local total_score_text = page_grow:GetChild('total_score_text');
    local totalScore = ADVENTURE_GROWTH_CATEGORY();   
    total_score_text:SetTextByKey('value', totalScore);
end

function ADVENTURE_BOOK_GROW_SET_TEAM_LEVEL()
    local adventure_book = ui.GetFrame('adventure_book');
    local gb_adventure = adventure_book:GetChild('gb_adventure');
    local page_grow = gb_adventure:GetChild('page_grow');
    local team_level_text = page_grow:GetChild('team_level_text');
    local team_score_text = page_grow:GetChild('team_score_text');
    local class_score_text = page_grow:GetChild('class_score_text');
    local account = session.barrack.GetMyAccount();
    if account ~= nil then
        team_level_text:SetTextByKey('value', account:GetTeamLevel());
    end
    team_score_text:SetTextByKey('value', GET_ADVENTURE_BOOK_TEAMLEVEL_POINT());
    class_score_text:SetTextByKey('value', GET_ADVENTURE_BOOK_CLASS_POINT());
end

function ADVENTURE_BOOK_GROW_SET_JOB_HISTORY_TOOLTIP(icon, charName)
    -- get job and grade
    local jobHistoryStr = GetCharacterJobHistoryString(pc, charName);
    local jobHistoryList = StringSplit(jobHistoryStr, ';');
	local jobInfoTable = {};
	for i = 1, #jobHistoryList do
		local jobName = jobHistoryList[i];
        if jobInfoTable[jobName] == nil then
            jobInfoTable[jobName] = 1;
        else
            jobInfoTable[jobName] = jobInfoTable[jobName] + 1;
        end
	end

    local gender = info.GetGender(session.GetMyHandle());
    local jobtext = '';
    for jobName, grade in pairs(jobInfoTable) do
        local jobCls = GetClass('Job', jobName);        
        if jobCls ~= nil then
            jobtext = jobtext .. ("{@st41}").. GET_JOB_NAME(jobCls, gender).."{nl}";
        end
    end
    icon:SetTextTooltip(jobtext);
	icon:EnableHitTest(1);
end