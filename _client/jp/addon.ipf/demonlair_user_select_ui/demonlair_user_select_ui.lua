-- demonlair user select ui
function DEMONLAIR_USER_SELECT_UI_ON_INIT(addon, frame)
    addon:RegisterMsg("DEMONLAIR_USER_SELECT_START", "ON_DEMONLAIR_USER_SELECT_MSG")
    addon:RegisterMsg("DEMONLAIR_USER_SELECT_END", "ON_DEMONLAIR_USER_SELECT_MSG")
    addon:RegisterMsg("DEMONLAIR_USER_SELECT_UPDATE", "ON_DEMONLAIR_USER_SELECT_MSG")
end

function OPEN_DEMONLAIR_USER_SELECT_UI(frame)
    REMOVE_DEMONLAIR_USER_SELECT_GROUP(frame)
end

function CLOSE_DEMONLAIR_USER_SELECT_UI(frame)
    REMOVE_DEMONLAIR_USER_SELECT_GROUP(frame)
end

function ON_DEMONLAIR_USER_SELECT_MSG(frame, msg, arg_str, arg_num)
    if msg == "DEMONLAIR_USER_SELECT_START" then
        ui.OpenFrame("demonlair_user_select_ui")
        MAKE_DEMONLAIR_USER_SELECT_GROUP(frame, arg_str, arg_num)
    elseif msg == "DEMONLAIR_USER_SELECT_END" then
        ui.CloseFrame("demonlair_user_select_ui")
    elseif msg == "DEMONLAIR_USER_SELECT_UPDATE" then
        UPDATE_DEMONLAIR_USER_SELECT_INFO(frame, arg_str, arg_num)
    end
end

function ON_DEMONLAIR_USER_SELECT_TIME_UPDATE(remain_time)
    local frame = ui.GetFrame("demonlair_user_select_ui")
    if frame ~= nil then
        if remain_time <= 0 then
            DEMONLAIR_USER_SELECT_RANDOM_EXEC(frame)
            return
        end
        local text_time = GET_CHILD_RECURSIVELY(frame, "text_time")
        if text_time ~= nil then
            text_time:SetTextByKey("time", remain_time)
        end
    end
end

function SET_DEMONLAIR_USER_SELECT_NEW_PAGE(frame, gbox)
    local count = gbox:GetChildCount()
    for i = 0, count - 1 do
        local child = gbox:GetChildByIndex(i)
        if child ~= nil and string.find(child:GetName(), "DemonLairUserSelectGroup_") ~= nil then
            local guid = child:GetUserIValue("GUID")
            local text_page = GET_CHILD_RECURSIVELY(frame, "text_page")
            if text_page ~= nil then
                text_page:SetTextByKey("page", guid)
                frame:SetUserValue("CUR_PAGE", guid)
            end
            break
        end
    end
end

-- ** ctrlset ** --
---- select group
function IS_EXIST_DEMONLAIR_USER_SELECT_GROUP(gbox)
    local count = gbox:GetChildCount()
    for i = 0, count - 1 do
        local child = gbox:GetChildByIndex(i)
        if child ~= nil and string.find(child:GetName(), "DemonLairUserSelectGroup_") ~= nil then
            return true
        end
    end
    return false
end

function REMOVE_DEMONLAIR_USER_SELECT_GROUP(frame)
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_info")
    if gbox ~= nil then
        local count = gbox:GetChildCount()
		for i = 0, count - 1 do
			local child = gbox:GetChildByIndex(i)
			if child ~= nil and string.find(child:GetName(), "DemonLairUserSelectGroup_") ~= nil then
				gbox:RemoveChild(child:GetName())
			end
		end
    end
end

function MAKE_DEMONLAIR_USER_SELECT_GROUP(frame, arg_str, arg_num)
    if frame ~= nil then
        local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_info")
        if gbox ~= nil then
            local group = gbox:CreateOrGetControlSet("demonlair_user_select_group", "DemonLairUserSelectGroup_"..arg_num, 5, 0)
            if group ~= nil then
                -- info setting
                group:SetUserValue("GUID", arg_num)
                -- current area number
                if IS_EXIST_DEMONLAIR_USER_SELECT_GROUP(gbox) == false then
                    frame:SetUserValue("CUR_PAGE", arg_num)
                else
                    SET_DEMONLAIR_USER_SELECT_NEW_PAGE(frame, gbox)
                end
                MAKE_DEMONLAIR_USER_SELECT_INFO(group, arg_str, arg_num)
            end
            -- visible setting
            VISIBLE_DEMONLAIR_USER_SELECT_GROUP(frame)
        end
    end
end

function VISIBLE_DEMONLAIR_USER_SELECT_GROUP(frame)
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_info")
    if gbox ~= nil then
        local min_page = tonumber(frame:GetUserConfig("MIN_PAGE"))
        local max_page = tonumber(frame:GetUserConfig("MAX_PAGE"))
        local cur_page = frame:GetUserIValue("CUR_PAGE")
        for i = min_page, max_page do
            local group = gbox:GetChild("DemonLairUserSelectGroup_"..i)
            if group ~= nil then
                if i == cur_page then
                    group:ShowWindow(1)
                else
                    group:ShowWindow(0)
                end
            end
        end
    end
end

---- select info
function MAKE_DEMONLAIR_USER_SELECT_INFO(group, arg_str)
    local select_list = StringSplit(arg_str, '#')
    if #select_list > 0 then
        for i = 1, #select_list do
            local pair_str = select_list[i]
            local pair = StringSplit(pair_str, '/')
            if #pair > 0 then
                local buff_id, buff_name, buff_icon, buff_desc, buff_step = nil, nil, nil, nil, nil
                local penalty_id, penalty_name, penalty_icon, penalty_desc, penalty_step = nil, nil, nil, nil, nil

                local buff_str = pair[1]
                local buff = StringSplit(buff_str, ';')
                if #buff > 0 then
                    buff_id = buff[1]
                    buff_name = buff[2]
                    buff_icon = buff[3]
                    buff_desc = buff[4]
                    if buff[5] ~= nil then
                        buff_step = tonumber(buff[5])
                    end
                end

                local penalty_str = pair[2]
                local penalty = StringSplit(penalty_str, ';')
                if #penalty > 0 then
                    penalty_id = penalty[1]
                    penalty_name = penalty[2]
                    penalty_icon = penalty[3]
                    penalty_desc = penalty[4]
                    if penalty[5] ~= nil then
                        penalty_step = tonumber(penalty[5])
                    end
                end

                if group ~= nil then
                    local ctrlset = GET_CHILD_RECURSIVELY(group, "select_"..i)
                    if ctrlset ~= nil then
                        local text_title = GET_CHILD_RECURSIVELY(ctrlset, "title")
                        if text_title ~= nil then
                            local title = ScpArgMsg("DemonLair_Ashark_UserSelectInfo_Title", "number", i)
                            text_title:SetTextByKey("name", title)
                        end
                        
                        local pic_buff_icon = GET_CHILD_RECURSIVELY(ctrlset, "buff_icon")
                        if pic_buff_icon ~= nil then
                            pic_buff_icon:SetImage(buff_icon)
                        end
                        
                        local pic_penalty_icon = GET_CHILD_RECURSIVELY(ctrlset, "penalty_icon")
                        if pic_penalty_icon ~= nil then
                            pic_penalty_icon:SetImage(penalty_icon)
                            pic_penalty_icon:SetColorTone("FFFF2222")
                        end
                        
                        local text_buff_name = GET_CHILD_RECURSIVELY(ctrlset, "buff_name")
                        if text_buff_name ~= nil then
                            if buff_step ~= nil then
                                local step_cl_msg = ClMsg("Step")
                                text_buff_name:SetFormat("{@st56}%s(%s"..step_cl_msg.."){/}")
                                text_buff_name:SetTextByKey("buff_step", buff_step)
                            else
                                text_buff_name:SetFormat("{@st56}%s{/}")
                                text_buff_name:SetTextByKey("buff_step", "")
                            end
                            text_buff_name:SetTextByKey("buff_name", buff_name)
                        end

                        local text_penalty_name = GET_CHILD_RECURSIVELY(ctrlset, "penalty_name")
                        if text_penalty_name ~= nil then
                            if penalty_step ~= nil then
                                local step_cl_msg = ClMsg("Step")
                                text_penalty_name:SetFormat("{@st56}%s(%s"..step_cl_msg.."){/}")
                                text_penalty_name:SetTextByKey("penalty_step", penalty_step)
                            else
                                text_penalty_name:SetFormat("{@st56}%s{/}")
                                text_penalty_name:SetTextByKey("penalty_step", "")
                            end
                            text_penalty_name:SetTextByKey("penalty_name", penalty_name)
                        end

                        local text_buff_desc = GET_CHILD_RECURSIVELY(ctrlset, "buff_desc")
                        if text_buff_desc ~= nil then
                            text_buff_desc:SetTextByKey("buff_desc", buff_desc)
                        end
                        
                        local text_penalty_desc = GET_CHILD_RECURSIVELY(ctrlset, "penalty_desc")
                        if text_penalty_desc ~= nil then
                            text_penalty_desc:SetTextByKey("penalty_desc", penalty_desc)
                        end

                        local btn_select = GET_CHILD_RECURSIVELY(ctrlset, "select")
                        if btn_select ~= nil then
                            btn_select:SetUserValue("GROUP_GUID", group:GetUserIValue("GUID"))
                            btn_select:SetUserValue("BUFF_ID", buff_id)
                            btn_select:SetUserValue("PENALTY_ID", penalty_id)
                        end
                    end
                end
            end
        end
    end
end

function UPDATE_DEMONLAIR_USER_SELECT_INFO(frame, arg_str, arg_num)
    if frame ~= nil then
        local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_info")
        if gbox ~= nil then
            local group = gbox:GetControlSet("demonlair_user_select_group", "DemonLairUserSelectGroup_"..arg_num)
            if group ~= nil then
                local select_list = StringSplit(arg_str, '#')
                if #select_list > 0 then
                    for i = 1, #select_list do
                        local pair_str = select_list[i]
                        local pair = StringSplit(pair_str, '/')
                        if #pair > 0 then
                            local buff_id, buff_name, buff_icon, buff_desc, buff_step = nil, nil, nil, nil, nil
                            local penalty_id, penalty_name, penalty_icon, penalty_desc, penalty_step = nil, nil, nil, nil, nil

                            local buff_str = pair[1]
                            local buff = StringSplit(buff_str, ';')
                            if #buff > 0 then
                                buff_id = buff[1]
                                buff_name = buff[2]
                                buff_icon = buff[3]
                                buff_desc = buff[4]
                                if buff[5] ~= nil then
                                    buff_step = tonumber(buff[5])
                                end
                            end

                            local penalty_str = pair[2]
                            local penalty = StringSplit(penalty_str, ';')
                            if #penalty > 0 then
                                penalty_id = penalty[1]
                                penalty_name = penalty[2]
                                penalty_icon = penalty[3]
                                penalty_desc = penalty[4]
                                if penalty[5] ~= nil then
                                    penalty_step = tonumber(penalty[5])
                                end
                            end

                            local ctrlset = GET_CHILD_RECURSIVELY(group, "select_"..i)
                            if ctrlset ~= nil then
                                local text_buff_name = GET_CHILD_RECURSIVELY(ctrlset, "buff_name")
                                if text_buff_name ~= nil then
                                    local name = text_buff_name:GetTextByKey("buff_name")
                                    if name == buff_name then
                                        if buff_step ~= nil and buff_step > 0 then
                                            local step_cl_msg = ClMsg("Step")
                                            text_buff_name:SetFormat("{@st56}%s(%s"..step_cl_msg.."){/}")
                                            text_buff_name:SetTextByKey("penalty_step", buff_step)
                                        else
                                            text_buff_name:SetFormat("{@st56}%s{/}")
                                            text_buff_name:SetTextByKey("penalty_step", "")
                                        end
                                    end
                                end

                                local text_penalty_name = GET_CHILD_RECURSIVELY(ctrlset, "penalty_name")
                                if text_penalty_name ~= nil then
                                    local name = text_penalty_name:GetTextByKey("penalty_name")
                                    if name == penalty_name then
                                        if penalty_step ~= nil and penalty_step > 0 then
                                            local step_cl_msg = ClMsg("Step")
                                            text_penalty_name:SetFormat("{@st56}%s(%s"..step_cl_msg.."){/}")
                                            text_penalty_name:SetTextByKey("penalty_step", penalty_step)
                                        else
                                            text_penalty_name:SetFormat("{@st56}%s{/}")
                                            text_penalty_name:SetTextByKey("penalty_step", "")
                                        end
                                    end
                                end
                                ctrlset:Invalidate()
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ** button ** --
---- page left button
function DEMONLAIR_USER_SELECT_LEFT_BTN(parent, btn)
    local frame = ui.GetFrame("demonlair_user_select_ui")
    if frame ~= nil then
        local min_page = tonumber(frame:GetUserConfig("MIN_PAGE"))
        local cur_page = frame:GetUserIValue("CUR_PAGE")

        cur_page = cur_page - 1
        if min_page >= cur_page then
            cur_page = min_page
        end
        
        local text_page = GET_CHILD_RECURSIVELY(frame, "text_page")
        if text_page ~= nil then
            text_page:SetTextByKey("page", cur_page)
            frame:SetUserValue("CUR_PAGE", cur_page)
        end
        VISIBLE_DEMONLAIR_USER_SELECT_GROUP(frame)
    end
end

---- page right button
function DEMONLAIR_USER_SELECT_RIGHT_BTN(parent, btn)
    local frame = ui.GetFrame("demonlair_user_select_ui")
    if frame ~= nil then
        local max_page = tonumber(frame:GetUserConfig("MAX_PAGE"))
        local cur_page = frame:GetUserIValue("CUR_PAGE")

        cur_page = cur_page + 1
        if max_page <= cur_page then
            cur_page = max_page
        end

        local text_page = GET_CHILD_RECURSIVELY(frame, "text_page")
        if text_page ~= nil then
            text_page:SetTextByKey("page", cur_page)
            frame:SetUserValue("CUR_PAGE", cur_page)
        end
        VISIBLE_DEMONLAIR_USER_SELECT_GROUP(frame)
    end
end

---- select button
function DEMONLAIR_USER_SELECT_BTN(parent, btn)
    if btn ~= nil then
        local group_guid = btn:GetUserIValue("GROUP_GUID")
        local buff_id = btn:GetUserIValue("BUFF_ID")
        local penalty_id = btn:GetUserIValue("PENALTY_ID")
        geMGame.ApplyDemonLairBuffAndPenalty(group_guid, buff_id, penalty_id)

        local frame = ui.GetFrame("demonlair_user_select_ui")
        if frame ~= nil then
            local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_info")
            if gbox ~= nil then
                local group = gbox:GetChild("DemonLairUserSelectGroup_"..group_guid)
                if group ~= nil then
                    gbox:RemoveChild("DemonLairUserSelectGroup_"..group_guid)
                end
            end

            local is_exist = IS_EXIST_DEMONLAIR_USER_SELECT_GROUP(gbox)
            if is_exist == true then
                SET_DEMONLAIR_USER_SELECT_NEW_PAGE(frame, gbox)
                VISIBLE_DEMONLAIR_USER_SELECT_GROUP(frame)
            else
                ui.CloseFrame("demonlair_user_select_ui")
                REMOVE_DEMONLAIR_USER_SELECT_GROUP(frame)
            end
        end
    end
end

---- select random button
function DEMONLAIR_USER_SELECT_RANDOM_BTN(parent, btn)
    local frame = ui.GetFrame("demonlair_user_select_ui")
    if frame ~= nil then
        local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_info")
        if gbox ~= nil then
            -- random select
            local cur_page = frame:GetUserIValue("CUR_PAGE")
            local group = gbox:GetControlSet("demonlair_user_select_group", "DemonLairUserSelectGroup_"..cur_page)
            if group ~= nil then
                local random = IMCRandom(1, 3)
                local ctrlset_name = "select_"..random
                local ctrlset = GET_CHILD_RECURSIVELY(group, ctrlset_name)
                if ctrlset ~= nil then
                    local select_btn = GET_CHILD_RECURSIVELY(ctrlset, "select")
                    if select_btn ~= nil then
                        DEMONLAIR_USER_SELECT_BTN(group, select_btn)
                    end
                end
            end
        end
    end
end

---- select random exec
function DEMONLAIR_USER_SELECT_RANDOM_EXEC(frame)
    if frame ~= nil then
        local btn_random = GET_CHILD_RECURSIVELY(frame, "btn_random")
        local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_info")
        if gbox ~= nil and btn_random ~= nil then
            DEMONLAIR_USER_SELECT_RANDOM_BTN(gbox, btn_random)
        end
    end
end