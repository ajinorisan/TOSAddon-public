-- shared_leticia_prop.lua

local blessed_goddess_cube_list = nil

local function make_blessed_goddess_cube_list()
	if blessed_goddess_cube_list == nil then
		blessed_goddess_cube_list = {};
	end

	local rewardID = 'reward_tp';
	local clslist, cnt = GetClassList(rewardID);
	for i = 0, cnt - 1 do
		local rewardCls = GetClassByIndexFromList(clslist, i);
		
		local group = TryGetProp(rewardCls, 'Group', 'None');		
		local reward = {};
		reward['Group'] = group;
		reward['ItemName'] = TryGetProp(rewardCls, 'ItemName');
		reward['Count'] = TryGetProp(rewardCls, 'Count');
		reward['Ratio'] = TryGetProp(rewardCls, 'Ratio', 0);
		reward['Rank'] = TryGetProp(rewardCls, 'Rank');
		reward['ClassID'] = TryGetProp(rewardCls, 'ClassID');
		reward['TeamBelonging'] = TryGetProp(rewardCls, 'TeamBelonging', 0);
		reward['CharacterBelonging'] = TryGetProp(rewardCls, 'CharacterBelonging', 0);

		if TryGetProp(rewardCls, 'NeedProperty') ~= nil then
			reward['NeedProperty'] = TryGetProp(rewardCls, 'NeedProperty');
		end
		if TryGetProp(rewardCls, 'NeedPropertyValue') ~= nil then
			reward['NeedPropertyValue'] = TryGetProp(rewardCls, 'NeedPropertyValue');
		end
		
		if blessed_goddess_cube_list[group] == nil then
			blessed_goddess_cube_list[group] = {};
		end

		local rewardList = blessed_goddess_cube_list[group];
		rewardList[#rewardList + 1] = reward;
	end
end


function GET_LETICIA_PROBABILITY()
    local total = 0
    local ret = {}
    local start = 7001
    local group_name = 'Gacha_TP2_001'
    if config.GetServiceNation() == 'PAPAYA' then
        start = 7501
        group_name = 'Gacha_TP2_001_PAPAYA'
    end
    for i = start, start + 100 do
        local cls = GetClassByType('reward_tp', i)
        if TryGetProp(cls, 'Group', 'None') == group_name then
            total = total + TryGetProp(cls, 'Ratio', 0)
        end
    end

    -- ItemName, Count, Prop
    for i = start, start + 100 do
        local cls = GetClassByType('reward_tp', i)
        if TryGetProp(cls, 'Group', 'None') == group_name then
            local name = TryGetProp(cls, 'ItemName', 'None')
            local count = TryGetProp(cls, 'Count', 0)
            local ratio = TryGetProp(cls, 'Ratio', 0)
            local rank = TryGetProp(cls, 'Rank', 'None')

            local str = string.format('%.5f', ratio / total * 100)
            table.insert(ret, {name, count, str, rank})
        end
    end

    return ret
end


local function GET_GODDESS_CUBE_GROUP_TABLE(ratioGroupName)
    return GET_GODDESS_CUBE_PROBABILITY()
end


function GET_GODDESS_CUBE_PROBABILITY()
    if blessed_goddess_cube_list == nil then
        make_blessed_goddess_cube_list()
    end
    
    local reward_group = 'Gacha_Blessed_CUBE_001'
    local nation = config.GetServiceNation()
    if nation == 'PAPAYA' then
        reward_group = 'Gacha_Blessed_CUBE_001_PAPAYA'
    end
    local clslist = blessed_goddess_cube_list[reward_group];
    
    local ratioList = {}; -- 등급별 확률
	local rewardGradeList = {}; -- 등급 {S, A, B, C}
    local listIndex = 0;
    local totalRatio = 0;
    
    local table_list = {} -- 확률 데이터 반환

	for i, rewardcls in ipairs(clslist) do
		local itemName = rewardcls['ItemName'];		
        if rewardcls["Group"] == reward_group then
            ratioList[listIndex] = rewardcls["Ratio"];
			rewardGradeList[listIndex] = rewardcls["Rank"];			
            listIndex = listIndex + 1;
            totalRatio = totalRatio + rewardcls["Ratio"];
        end
    end

    for i = 0, listIndex - 1 do
        local rewardRank = rewardGradeList[i]
        if rewardRank == 'S' then
            local rewardList_S = {};
            local rewardCnt_S = {};
            local ratioList_S = {};
            local rewardGradeList_S = {};
            local rewardClsIDList_S = {};
            local listIndex_S = 0;
            local totalRatio_S = 0;
    
            local parent_ratio = ratioList[i] / totalRatio            

            local s_rank_name = 'Blessed_New_S'
            if nation == 'PAPAYA' then
                s_rank_name = 'Blessed_New_S_PAPAYA'
            end
            local clslist_S = blessed_goddess_cube_list[s_rank_name]
    
            for j, rewardcls_S in ipairs(clslist_S) do
                local itemName_S = rewardcls_S['ItemName'];
                if rewardcls_S["Group"] == s_rank_name then                    
                    totalRatio_S = totalRatio_S + rewardcls_S["Ratio"];
                end
            end
            
            for j, rewardcls_S in ipairs(clslist_S) do
                local itemName_S = rewardcls_S['ItemName'];
                if rewardcls_S["Group"] == s_rank_name then
                    rewardList_S[listIndex_S] = itemName_S;
                    rewardCnt_S[listIndex_S] = rewardcls_S["Count"];
                    ratioList_S[listIndex_S] = rewardcls_S["Ratio"];
                    rewardGradeList_S[listIndex_S] = rewardcls_S["Rank"];
                    rewardClsIDList_S[listIndex_S] = rewardcls_S["ClassID"];
                    listIndex_S = listIndex_S + 1;

                    local ratio = rewardcls_S["Ratio"] / totalRatio_S * parent_ratio
                    local count = rewardcls_S["Count"]
                    local str = string.format('%.5f', ratio * 100)
                    table.insert(table_list, {itemName_S, count, str, rewardRank})                    
                end
            end
            
        elseif rewardRank == 'C' then
            local rewardList_C = {};
            local rewardCnt_C = {};
            local ratioList_C = {};
            local rewardGradeList_C = {};
            local rewardClsIDList_C = {};
            local listIndex_C = 0;
            local totalRatio_C = 0;
    
            local parent_ratio = ratioList[i] / totalRatio

            local c_rank_hair_name = 'Blessed_HairAcc_C'
            if nation == 'PAPAYA' then
                c_rank_hair_name = 'Blessed_HairAcc_C_PAPAYA'	
            end
            local clslist_C = blessed_goddess_cube_list[c_rank_hair_name];	
    
            for j, rewardcls_C in ipairs(clslist_C) do
                local itemName_C = rewardcls_C['ItemName'];
                if rewardcls_C["Group"] == c_rank_hair_name then
                    totalRatio_C = totalRatio_C + rewardcls_C["Ratio"];
                end
            end

            for j, rewardcls_C in ipairs(clslist_C) do
                local itemName_C = rewardcls_C['ItemName'];
                if rewardcls_C["Group"] == c_rank_hair_name then
                    rewardList_C[listIndex_C] = itemName_C;
                    rewardCnt_C[listIndex_C] = rewardcls_C["Count"];
                    ratioList_C[listIndex_C] = rewardcls_C["Ratio"];
                    rewardGradeList_C[listIndex_C] = rewardcls_C["Rank"];
                    rewardClsIDList_C[listIndex_C] = rewardcls_C["ClassID"];
                    listIndex_C = listIndex_C + 1;
                    
                    local ratio = rewardcls_C["Ratio"] / totalRatio_C * parent_ratio
                    local count = rewardcls_C["Count"]
                    local str = string.format('%.5f', ratio * 100)
                    table.insert(table_list, {itemName_C, count, str, rewardRank})
                end
            end
        elseif rewardRank == 'B' then
            local rewardList_AB = {};
            local rewardCnt_AB = {};
            local ratioList_AB = {};
            local rewardGradeList_AB = {};
            local rewardClsIDList_AB = {};
            local listIndex_AB = 0;
            
    
            local rewGroup_AB_list = {'Blessed_New_', 'Blessed_Old_'}
            local add_ratio = {0.35, 0.65} -- 35% / 65%
            local parent_ratio = ratioList[i] / totalRatio            
            if nation == 'PAPAYA' then
                rewGroup_AB_list = {'Blessed_New_'}
                add_ratio = {1}
            end

            for i = 1, #rewGroup_AB_list do
                local totalRatio_AB = 0;

                rewGroup_AB = rewGroup_AB_list[i]..rewardRank                
                if nation == 'PAPAYA' then
                    rewGroup_AB = rewGroup_AB .. '_PAPAYA'
                end
                local clslist_AB = blessed_goddess_cube_list[rewGroup_AB];
                
                if clslist_AB ~= nil then
                    for j, rewardcls_AB in ipairs(clslist_AB) do                        
                        if rewardcls_AB["Group"] == rewGroup_AB then
                            totalRatio_AB = totalRatio_AB + rewardcls_AB["Ratio"];	-- 전체 확률        
                        end
                    end

                    for j, rewardcls_AB in ipairs(clslist_AB) do
                        local itemName_AB = rewardcls_AB['ItemName'];			
                        if rewardcls_AB["Group"] == rewGroup_AB then
                            rewardList_AB[listIndex_AB] = itemName_AB;
                            rewardCnt_AB[listIndex_AB] = rewardcls_AB["Count"];
                            ratioList_AB[listIndex_AB] = rewardcls_AB["Ratio"];
                            rewardGradeList_AB[listIndex_AB] = rewardcls_AB["Rank"];
                            rewardClsIDList_AB[listIndex_AB] = rewardcls_AB["ClassID"];
                            listIndex_AB = listIndex_AB + 1;
                            
        
                            local ratio = rewardcls_AB["Ratio"] / totalRatio_AB * parent_ratio * add_ratio[i]

                            local count = rewardcls_AB["Count"]
                            local str = string.format('%.5f', ratio * 100)
                            table.insert(table_list, {itemName_AB, count, str, rewardRank})
                        end
                    end
                end
            end
        elseif  rewardRank == 'A' then
            local rewardList_AB = {};
            local rewardCnt_AB = {};
            local ratioList_AB = {};
            local rewardGradeList_AB = {};
            local rewardClsIDList_AB = {};
            local listIndex_AB = 0;
            
    
            local rewGroup_AB_list = {'Blessed_New_', 'Blessed_Old_'}
            local add_ratio = {0.35, 0.65} -- 35% / 65%
            local parent_ratio = ratioList[i] / totalRatio
    
            local rand = IMCRandom(1, 10000)
    
            if nation == 'PAPAYA' then
                rand = 1
            end
            
            for i = 1, #rewGroup_AB_list do
                local totalRatio_AB = 0;
                rewGroup_AB = rewGroup_AB_list[i]..rewardRank
         
                if nation == 'PAPAYA' then
                    rewGroup_AB = rewGroup_AB .. '_PAPAYA'
                end

                local clslist_AB = blessed_goddess_cube_list[rewGroup_AB];	-- 보상 리스트 얻어온다.
                
                if clslist_AB ~= nil then 
                    for j, rewardcls_AB in ipairs(clslist_AB) do	-- 보상리스트에서 확률로 보상 계산			
                        local itemName_AB = rewardcls_AB['ItemName'];			
                        if rewardcls_AB["Group"] == rewGroup_AB then
                            totalRatio_AB = totalRatio_AB + rewardcls_AB["Ratio"];	-- 전체 확률        
                        end
                    end
    
                    for j, rewardcls_AB in ipairs(clslist_AB) do	-- 보상리스트에서 확률로 보상 계산			
                        local itemName_AB = rewardcls_AB['ItemName'];			
                        if rewardcls_AB["Group"] == rewGroup_AB then
                            rewardList_AB[listIndex_AB] = itemName_AB;
                            rewardCnt_AB[listIndex_AB] = rewardcls_AB["Count"];
                            ratioList_AB[listIndex_AB] = rewardcls_AB["Ratio"];
                            rewardGradeList_AB[listIndex_AB] = rewardcls_AB["Rank"];
                            rewardClsIDList_AB[listIndex_AB] = rewardcls_AB["ClassID"];
                            listIndex_AB = listIndex_AB + 1;
                            
        
                            local ratio = rewardcls_AB["Ratio"] / totalRatio_AB * parent_ratio * add_ratio[i]
                            local count = rewardcls_AB["Count"]
                            local str = string.format('%.5f', ratio * 100)
                            table.insert(table_list, {itemName_AB, count, str, rewardRank})                            
                        end
                    end
                end
            end
        end
    end

    return table_list
end
