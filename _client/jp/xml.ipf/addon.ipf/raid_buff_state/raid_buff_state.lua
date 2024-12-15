-- raid buff state
function RAID_BUFF_STATE_ON_INIT(addon, frame)
    addon:RegisterMsg("RAID_BUFF_STATE_START", "ON_RAID_BUFF_STATE_MSG");
    addon:RegisterMsg("RAID_BUFF_STATE_END", "ON_RAID_BUFF_STATE_MSG");
    addon:RegisterMsg("DELMORE_RAID_RAGE_BUFF_STATE", "ON_RAID_BUFF_STATE_MSG");
end

function ON_RAID_BUFF_STATE_MSG(frame, msg, arg_str, arg_num)
    if frame ~= nil then
        if msg == "RAID_BUFF_STATE_START" then
            RAID_BUFF_STATE_SHOW_FRAME(frame, 1);
        elseif msg == "RAID_BUFF_STATE_END" then
            RAID_BUFF_STATE_SHOW_FRAME(frame, 0);            
        elseif msg == "DELMORE_RAID_RAGE_BUFF_STATE" then
            if arg_str == "Delmore" then
                DELMORE_RAID_BUFF_STATE_CHANGE(frame, arg_num);
            end
        end
    end
end

function RAID_BUFF_STATE_SHOW_FRAME(frame, show)
    if frame == nil then return; end
    frame:ShowWindow(show);
end

function DELMORE_RAID_BUFF_STATE_CHANGE(frame, step)
    if frame == nil then return; end
    local pic = GET_CHILD_RECURSIVELY(frame, "pic");
    if pic ~= nil then
        local image_name = "epicraid_icon_eye"..step;
        pic:SetImage(image_name);
    end
    frame:Invalidate();
end