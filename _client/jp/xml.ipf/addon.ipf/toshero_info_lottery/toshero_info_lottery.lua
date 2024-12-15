function TOSHERO_INFO_LOTTERY_ON_INIT(addon, frame)
    addon:RegisterMsg('TOSHERO_INFO_POINT', 'TOSHERO_INFO_LOTTERY_RESULT');    
    addon:RegisterMsg('TOSHERO_ZONE_ENTER', 'ON_TOSHERO_ZONE_ENTER')
    addon:RegisterMsg('TOSHERO_LOTTERY_FAIL', 'ON_TOSHERO_LOTTERY_FAIL')
end

function OPEN_TOSHERO_INFO_LOTTERY()
    ui.OpenFrame("toshero_info_lottery")
end

function ON_TOSHERO_INFO_LOTTERY_INIT(frame, msg, argStr, stage)
    GET_CHILD_RECURSIVELY(frame,"point_btn_4"):SetEnable(1);
end

local Type = -1
function TOSHERO_INFO_LOTTERY_EXEC(parent, self, argStr, type)
    Type = type
    if type == 4 then
        local msg = ClMsg("TOSHeroYouCanTryOnlyOnce");
        local yesscp = string.format('TOSHERO_INFO_LOTTERY_ALL_IN()');
        ui.MsgBox_NonNested(msg, parent:GetName(), yesscp, 'None');
    else
        toshero.RequestRunLottery(type)
    end
end

function TOSHERO_INFO_LOTTERY_ALL_IN()
    local frame = ui.GetFrame("toshero_info_lottery");
    toshero.RequestRunLottery(4);
end

function TOSHERO_INFO_LOTTERY_RESULT()
    local frame = ui.GetFrame("toshero_info_lottery");
    if Type == 4 then
        GET_CHILD_RECURSIVELY(frame,"point_btn_4"):SetEnable(0);
    end
end

function ON_TOSHERO_LOTTERY_FAIL()
    Type = -1
end