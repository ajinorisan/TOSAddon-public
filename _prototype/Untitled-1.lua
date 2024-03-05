g.first = 0 -- バラックを選ぶために一度0から始める。

-- hidelogin
local frame = ui.GetFrame("barrack_charlist")
if frame == nil then
    return;
end

local hidelogin = GET_CHILD_RECURSIVELY(frame, "hidelogin", "ui::CCheckBox");
hidelogin:SetCheck(1);

-- ON_INIT
acutil.setupEvent(addon, "SELECT_BARRACK_LAYER", "ADDONNAME_SELECT_BARRACK_LAYER") -- 強制的に選択時に呼び出し

function ADDONNAME_SELECT_BARRACK_LAYER(frame, msg)

    local frame = ui.GetFrame("barrack_charlist")
    local ctrl, arg, layer = acutil.getEventArgs(msg)
    local before = frame:GetUserValue("SelectBarrackLayer")

end
