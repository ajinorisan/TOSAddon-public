-- demonlair status ui
function DEMONLAIR_STATUS_UI_ON_INIT(addon, frame)
    addon:RegisterMsg("DEMONLAIR_FINAL_BOSS_BUFF_INFO", "MAKE_DEMONLAIR_STATUS_UI_FINAL_BOSS_BUFF_LIST")
    addon:RegisterMsg("DEMONLAIR_FINAL_BOSS_BUFF_INFO_UPDATE", "MAKE_DEMONLAIR_STATUS_UI_FINAL_BOSS_BUFF_LIST")
    addon:RegisterMsg("DEMONLAIR_USER_SELECT_INFO", "MAKE_DEMONLAIR_STATUS_UI_USER_SELECT_LIST")
end

function OPEN_DEMONLAIR_STATUS_UI(frame)
    ui.OpenFrame("demonlair_status_ui")
    geMGame.ReqDemonLairStatusInfo()
end

function CLOSE_DEMONLAIR_STATUS_UI(frame)
    ui.CloseFrame("demonlair_status_ui")
end

---- final boss buff
function GET_DEMONLAIR_STATUS_UI_FINAL_BOSS_BUFF_INFO_LIST(buff_info_str)
    local buff_list = {}
    if buff_info_str == "" or buff_info_str == "None" then
        return buff_list
    end
    local buff_info_list = StringSplit(buff_info_str, ';')
    if #buff_info_list > 0 then
        for i = 1, #buff_info_list do
            local buff_name = buff_info_list[i]
            local cls = GetClass("Buff", buff_name)
            if cls ~= nil then
                local icon = "icon_"..TryGetProp(cls, "Icon", "None")
                local name = TryGetProp(cls, "Name", "None")
                local tooltip = TryGetProp(cls, "ToolTip", "None")
                buff_list[#buff_list + 1] = { icon_name = icon, buff_name = name, desc = tooltip }
            end
        end
    end
    return buff_list
end

function REMOVE_DEMONLAIR_STATUS_UI_FINAL_BOSS_BUFF_LIST(frame)
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_fianl_boss_buff")
    if gbox ~= nil then
        local count = gbox:GetChildCount();
		for i = 0, count - 1 do
			local child = gbox:GetChildByIndex(i);
			if child ~= nil and string.find(child:GetName(), "DemonLairFinalBossBuffInfo_") ~= nil then
				gbox:RemoveChild(child:GetName())
			end
		end
    end
end

function MAKE_DEMONLAIR_STATUS_UI_FINAL_BOSS_BUFF_LIST(frame, msg, arg_str, arg_num)
    if frame ~= nil then
        if msg == "DEMONLAIR_FINAL_BOSS_BUFF_INFO_UPDATE" then
            REMOVE_DEMONLAIR_STATUS_UI_FINAL_BOSS_BUFF_LIST(frame)
        end
        local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_fianl_boss_buff")
        if gbox ~= nil then
            local x, y = 0, 0
            local ctrlset_name = "demonlair_final_boss_buff_info"
            local buff_list = GET_DEMONLAIR_STATUS_UI_FINAL_BOSS_BUFF_INFO_LIST(arg_str)
            if #buff_list > 0 then
                local ctrlset_height = ui.GetControlSetAttribute(ctrlset_name, "height") 
                for i = 1, #buff_list do
                    y = ctrlset_height * (i - 1)
                    local ctrlset = gbox:CreateOrGetControlSet(ctrlset_name, "DemonLairFinalBossBuffInfo_"..i, x, y)
                    if ctrlset ~= nil then
                        local buff_info = buff_list[i]
                        ctrlset:SetUserValue("BUFF_NAME", buff_info.buff_name)

                        local slot = GET_CHILD_RECURSIVELY(ctrlset, "slot")
                        if slot ~= nil then
                            SET_SLOT_IMG(slot, buff_info.icon_name)
                        end
                        
                        local name_text = GET_CHILD_RECURSIVELY(ctrlset, "name")
                        if name_text ~= nil then
                            name_text:SetTextByKey("name", buff_info.buff_name)
                        end

                        local desc_text = GET_CHILD_RECURSIVELY(ctrlset, "desc")
                        if desc_text ~= nil then
                            desc_text:SetTextByKey("desc", buff_info.desc)
                        end
                    end
                end
            end
        end
        frame:Invalidate()
    end
end

---- user seelct buff & penalty
function GET_DEMONLAIR_STATUS_UI_USER_SELECT_INFO(arg_str)
    local select_list = {}
    if arg_str == "" or arg_str == nil then
        return select_list
    end
    local arg_str_list = StringSplit(arg_str, '/')
    if #arg_str_list > 0 then
        for i = 1, #arg_str_list do
            local arg_str = arg_str_list[i]
            if arg_str ~= "" then
                local info_list = StringSplit(arg_str, '/')
                if #info_list > 0 then
                    local select_info = {}
                    for j = 1, #info_list do
                        local name, icon, step, is_penalty = nil, nil, nil, nil
                        local info_str = info_list[j]
                        if info_str ~= nil and info_str ~= "" and string.sub(info_str, 1, 5) == "Buff;" then
                            -- buff
                            local buff_data_str = string.sub(info_str, 6)
                            local buff_info = StringSplit(buff_data_str, ';')
                            if buff_info ~= nil and buff_info ~= "" and #buff_info > 0 then
                                name = buff_info[1]
                                icon = buff_info[2]
                                step = tonumber(buff_info[3]) 
                                is_penalty = false
                                select_info = { name = name, icon = icon, step = step, is_penalty = is_penalty }
                            end
                        elseif info_str ~= nil and info_str ~= "" and string.sub(info_str, 1, 8) == "Penalty;" then
                            -- penalty
                            local penalty_data_str = string.sub(info_str, 9)
                            local penalty_info = StringSplit(penalty_data_str, ';')
                            if penalty_info ~= nil and penalty_info ~= "" and #penalty_info > 0 then
                                name = penalty_info[1]
                                icon = penalty_info[2]
                                step = tonumber(penalty_info[3])
                                is_penalty = true
                                select_info = { name = name, icon = icon, step = step, is_penalty = is_penalty }
                            end
                        end
                    end
                    select_list[#select_list + 1] = select_info
                end
            end
        end
    end
    return select_list
end

function REMOVE_DEMONLAIR_STATUS_UI_USER_SELECT_LIST(frame)
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_user_select_list")
    if gbox ~= nil then
        local count = gbox:GetChildCount();
		for i = 0, count - 1 do
			local child = gbox:GetChildByIndex(i);
			if child ~= nil and string.find(child:GetName(), "DemonLairUserSelectInfo_") ~= nil then
				gbox:RemoveChild(child:GetName())
			end
		end
    end
end

function MAKE_DEMONLAIR_STATUS_UI_USER_SELECT_LIST(frame, msg, arg_str, arg_num)
    if frame ~= nil then
        REMOVE_DEMONLAIR_STATUS_UI_USER_SELECT_LIST(frame)
        local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_user_select_list")
        if gbox ~= nil then
            local x, y = 0, 0
            local ctrlset_name = "demonlair_user_select_stauts_info"
            local select_list = GET_DEMONLAIR_STATUS_UI_USER_SELECT_INFO(arg_str)
            if #select_list > 0 then
                local ctrlset_height = ui.GetControlSetAttribute(ctrlset_name, "height") 
                for i = 1, #select_list do
                    local select_info = select_list[i]
                    if select_info ~= nil then
                        local name = select_info.name
                        local icon = select_info.icon
                        local step = select_info.step
                        local is_penalty = select_info.is_penalty

                        y = ctrlset_height * (i - 1)
                        local ctrlset = gbox:CreateOrGetControlSet(ctrlset_name, "DemonLairUserSelectInfo_"..i, x, y)
                        if ctrlset ~= nil then
                            ctrlset:SetUserValue("SELECT_INFO_NAME", name)

                            local pic_icon = GET_CHILD_RECURSIVELY(ctrlset, "icon")
                            if pic_icon ~= nil then
                                pic_icon:SetImage(icon)
                                if is_penalty == true then
                                    pic_icon:SetColorTone("FFFF2222")
                                end
                            end

                            local text_name = GET_CHILD_RECURSIVELY(ctrlset, "name")
                            if text_name ~= nil then
                                text_name:SetTextByKey("name", name)
                            end

                            local text_step = GET_CHILD_RECURSIVELY(ctrlset, "step")
                            if text_step ~= nil then
                                if step == nil or step == 0 then
                                    text_step:SetText("")
                                else
                                    text_step:SetTextByKey("step", step)
                                end
                            end
                        end
                    end
                end
            end
            gbox:Invalidate()
        end
        frame:Invalidate()
    end
end