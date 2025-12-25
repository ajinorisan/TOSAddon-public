function GUILD_MISSION_INFO_GAUGE_ON_INIT(addon, frame)
    addon:RegisterMsg("GUILD_MISSION_ROMUVA_STAGE_START", "ON_START_GUILD_MISSION_ROMUVA_INFO_GAUGE")
    addon:RegisterMsg("GUILD_MISSION_ROMUVA_STAGE_UPDATE", "ON_UPDATE_GUILD_MISSION_ROMUVA_INFO_GAUGE")
    addon:RegisterMsg("GUILD_MISSION_ROMUVA_STAGE_BOSS", "ON_BOSS_GUILD_MISSION_ROMUVA_INFO_GAUGE")
    addon:RegisterMsg("GUILD_MISSION_CATHEDRAL_STAGE_INFO", "ON_GUILD_MISSION_CATHEDRAL_INFO_GAUGE")
    addon:RegisterMsg("GUILD_MISSION_CATHEDRAL_STAGE_BOSS", "ON_BOSS_GUILD_MISSION_CATHEDRAL_INFO_GAUGE")
end

function GET_DATA_GUILD_MISSION_ROMUVA_INFO_GAUGE(msg, arg_str)
    local data = {}
    if msg == "GUILD_MISSION_ROMUVA_STAGE_START" then
        local list = StringSplit(arg_str, '/')
        if #list >= 4 then
            data = { cur_point = tonumber(list[1]), max_point = tonumber(list[2]), boss_icon = list[3], boss_time = list[4] }
        end
    elseif msg == "GUILD_MISSION_ROMUVA_STAGE_UPDATE" then
        local list = StringSplit(arg_str, '/')
        if #list >= 3 then
            data = { cur_point = tonumber(list[1]), max_point = tonumber(list[2]), boss_time = list[3] }
        end
    end
    return data
end

function ON_START_GUILD_MISSION_ROMUVA_INFO_GAUGE(frame, msg, arg_str, arg_num)
    ui.OpenFrame("guild_mission_info_gauge")

    local data = GET_DATA_GUILD_MISSION_ROMUVA_INFO_GAUGE(msg, arg_str)
    if data ~= nil then
        local stage_text = GET_CHILD_RECURSIVELY(frame, "stage_text")
        if stage_text ~= nil then
            local stage = arg_num
            stage_text:SetTextByKey("stage", stage)
        end
    
        local max_pic = GET_CHILD_RECURSIVELY(frame, "max_pic")
        if max_pic ~= nil then
            max_pic:ShowWindow(0)
        end
    
        local gauge = GET_CHILD_RECURSIVELY(frame, "gauge")
        if gauge ~= nil then
            local cur_point = data.cur_point
            local max_point = data.max_point
            gauge:SetPoint(cur_point, max_point)
        end

        local boss_icon_pic = GET_CHILD_RECURSIVELY(frame, "boss_icon_pic")
        if boss_icon_pic ~= nil then
            boss_icon_pic:SetImage(data.boss_icon)
        end

        local boss_time_text = GET_CHILD_RECURSIVELY(frame, "boss_time_text")
        if boss_time_text ~= nil then
            boss_time_text:SetTextByKey("time", data.boss_time)
        end
    end
end

function ON_UPDATE_GUILD_MISSION_ROMUVA_INFO_GAUGE(frame, msg, arg_str, arg_num)
    local data = GET_DATA_GUILD_MISSION_ROMUVA_INFO_GAUGE(msg, arg_str)
    if data ~= nil then
        local stage_text = GET_CHILD_RECURSIVELY(frame, "stage_text")
        if stage_text ~= nil then
            local stage = arg_num
            stage_text:SetTextByKey("stage", stage)
        end

        local gauge = GET_CHILD_RECURSIVELY(frame, "gauge")
        local max_pic = GET_CHILD_RECURSIVELY(frame, "max_pic")
        if gauge ~= nil and max_pic ~= nil then
            local cur_point = data.cur_point
            local max_point = data.max_point
            if cur_point >= max_point then
                max_pic:ShowWindow(1)
            else
                max_pic:ShowWindow(0)
            end
            gauge:SetPoint(cur_point, max_point)
        end

        local boss_time_text = GET_CHILD_RECURSIVELY(frame, "boss_time_text")
        if boss_time_text ~= nil then
            boss_time_text:SetTextByKey("time", data.boss_time)
        end
    end
end

function ON_BOSS_GUILD_MISSION_ROMUVA_INFO_GAUGE(frame, msg, arg_str, arg_num)
    local max_pic = GET_CHILD_RECURSIVELY(frame, "max_pic")
    if max_pic ~= nil then
        max_pic:ShowWindow(1)
    end

    local gauge = GET_CHILD_RECURSIVELY(frame, "gauge")
    if gauge ~= nil then
        local cur_point = gauge:GetMaxPoint()
        local max_point = gauge:GetMaxPoint()
        gauge:SetPoint(cur_point, max_point)
    end
end

function GET_DATA_GUILD_MISSION_CATHEDRAL_INFO_GAUGE(arg_str)
    local data = {}
    local list = StringSplit(arg_str, '/')
    if #list >= 2 then
        data = { cur_point = tonumber(list[1]), max_point = tonumber(list[2]), boss_icon = list[3] }
    end
    return data
end

function ON_GUILD_MISSION_CATHEDRAL_INFO_GAUGE(frame, msg, arg_str, arg_num)
    ui.OpenFrame("guild_mission_info_gauge")

    local data = GET_DATA_GUILD_MISSION_CATHEDRAL_INFO_GAUGE(arg_str)
    if data ~= nil then
        local stage_text = GET_CHILD_RECURSIVELY(frame, "stage_text")
        if stage_text ~= nil then
            local stage = arg_num
            stage_text:SetTextByKey("stage", stage)
        end
    
        local max_pic = GET_CHILD_RECURSIVELY(frame, "max_pic")
        if max_pic ~= nil then
            max_pic:ShowWindow(0)
        end
    
        local gauge = GET_CHILD_RECURSIVELY(frame, "gauge")
        if gauge ~= nil then
            local cur_point = data.cur_point
            local max_point = data.max_point
            gauge:SetPoint(cur_point, max_point)
        end

        local boss_title_text = GET_CHILD_RECURSIVELY(frame, "boss_title_text")
        if boss_title_text ~= nil then
            boss_title_text:SetTextByKey("text", "BOSS")
        end

        local boss_icon_pic = GET_CHILD_RECURSIVELY(frame, "boss_icon_pic")
        if boss_icon_pic ~= nil then
            boss_icon_pic:SetImage(data.boss_icon)
        end

        local boss_time_text = GET_CHILD_RECURSIVELY(frame, "boss_time_text")
        if boss_time_text ~= nil then
            boss_time_text:ShowWindow(0)
        end
    end
end

function ON_BOSS_GUILD_MISSION_CATHEDRAL_INFO_GAUGE(frame, msg, arg_str, arg_num)
    local max_pic = GET_CHILD_RECURSIVELY(frame, "max_pic")
    if max_pic ~= nil then
        max_pic:ShowWindow(1)
    end

    local gauge = GET_CHILD_RECURSIVELY(frame, "gauge")
    if gauge ~= nil then
        local cur_point = gauge:GetMaxPoint()
        local max_point = gauge:GetMaxPoint()
        gauge:SetPoint(cur_point, max_point)
    end
end