local currentPoint = 0;
local maxPoint = 0;

function TPTITEM_VERTIGO_PROCESS_POPUP()
    local frame = ui.GetFrame("tpitem");
	local tpitem_vertigo_process = ui.GetFrame("tpitem_vertigo_process");

    if frame == nil or tpitem_vertigo_process == nil then
		return false;
	end

    tpitem_vertigo_process:ShowWindow(1);

end

function TPTEIM_VERTIGO_PROCESS_CLOSE()
    local tpitem_vertigo_process = ui.GetFrame("tpitem_vertigo_process");

    if tpitem_vertigo_process == nil then
		return false;
	end

    tpitem_vertigo_process:ShowWindow(0);
end

function SET_PROGRESS_POINT_AT_VERTIGO_PROCESS(currentValue, maxValue)
	currentPoint = currentValue;
    maxPoint = maxValue;
    
    local tpitem_vertigo_process = ui.GetFrame("tpitem_vertigo_process");
    local purchaseProcess = GET_CHILD_RECURSIVELY(tpitem_vertigo_process, 'purchaseProcess');

	purchaseProcess:SetPoint(currentPoint, maxPoint);
end

function SET_MAXPOINT_AT_VERTIGO_PROCESS(max)
    SET_PROGRESS_POINT_AT_VERTIGO_PROCESS(0,max);
end

function SET_CURPOINT_AT_VERTIGO_PROCESS(current)
    SET_PROGRESS_POINT_AT_VERTIGO_PROCESS(current,maxPoint);
end

function END_VERTIGO_PROCESS(num)
    if currentPoint ~= maxPoint then
        FAIL_VERTIGO_PROCESS(num);
        return false;
    end
    ui.SysMsg(ClMsg('VERTIGO_PROCESS_SUCCESS'));
    TPTEIM_VERTIGO_PROCESS_CLOSE();
    return true;
end

function FAIL_VERTIGO_PROCESS(num)
    TPTEIM_VERTIGO_PROCESS_CLOSE();
    ui.SysMsg(ClMsg('VERTIGO_PROCESS_FAIL'));
end

function GET_VERTIGO_PROCESS_POPUP()
	local tpitem_vertigo_process = ui.GetFrame("tpitem_vertigo_process");
    if tpitem_vertigo_process == nil then
		return nil;
	end
    return tpitem_vertigo_process;
end