function PILGRIM_SELECT_ON_INIT(addon, frame)
end

function PILGRIM_SELECT_CLOSE(frame)
    if frame == nil then return; end
    ui.CloseFrame("pilgrim_select");
end

-- ** etc ** --
function GET_PILGRIM_SELECT_FRIST_INDEX()
    local index = -1;
    local frame = ui.GetFrame("pilgrim_select");
    if frame ~= nil then
        local gb = GET_CHILD_RECURSIVELY(frame, "gb_list");
        if gb ~= nil then
            local count = gb:GetChildCount();
            for i = 0, count - 1 do
                local child = gb:GetChildByIndex(i);
                if child ~= nil and string.find(child:GetName(), "pilgrim_select_") ~= nil then
                    index = child:GetUserIValue("index");
                    break;
                end
            end
        end
    end
    return index;
end

-- ** pilgrim list ** --
function ON_PILGRIM_SELECT(tribulation_frame)
    local frame = ui.GetFrame("pilgrim_select");
    if tribulation_frame ~= nil and frame ~= nil then
        frame:ShowWindow(1);
        local x = tribulation_frame:GetX() - frame:GetWidth();
        local y = tribulation_frame:GetY() + (frame:GetHeight() / 4);
        frame:SetOffset(x, y);
        PILGRIM_SELECT_FILL_LIST(frame);
    end
end

function PILGRIM_SELECT_FILL_LIST(frame)
    -- ** 현재 플레이 가능한 스쿼드만 클릭 활성화 되도록 처리 필요.
    local gb = GET_CHILD_RECURSIVELY(frame, "gb_list");
    if gb ~= nil then
        gb:RemoveAllChild();
        local index = 0;
        local start_x = 6;
        local start_y = 6;
        local space_y = 5;
        local height = 36;
        local max = session.SquadSystem.GetSquadMaxCount();
        for i = 0, max - 1 do
            local name = session.SquadSystem.GetSquadName(i);
            if name ~= "None" then
                local ctrl_set_name = "pilgrim_select_"..index;
                local ctrl_set = gb:CreateOrGetControlSet("pilgrim_select_info", ctrl_set_name, start_x, start_y + (i * height) + (i * space_y));
                if ctrl_set ~= nil then
                    local btn = GET_CHILD_RECURSIVELY(ctrl_set, "btn");
                    local text_name = GET_CHILD_RECURSIVELY(btn, "name");
                    if text_name ~= nil then
                        text_name:SetTextByKey("name", name);
                    end
                    ctrl_set:SetUserValue("index", index);
                    index = index + 1; 
                end
            end
        end
    end
end

function ON_PILGRIM_SELECT_INFO(parent, btn, arg_str, arg_num)
    if parent ~= nil then
        local index = parent:GetUserIValue("index");
        local frame = ui.GetFrame("pilgrim_tribulation_rank_select");
        if frame ~= nil then
            frame:SetUserValue("select_pilgrim", index);
            PILGRIM_TRIBULATION_RANK_SELECT_FILL_PILGRIM_SELECT(frame);
            PILGRIM_TRIBULATION_RANK_SELECT_FILL_PILGRIM_LIST(frame);
        end
    end
end