function MESSAGEBOX_OPEN(txt, yesscp, argNum, argStr)
    ui.OpenFrame("re_messagebox")
    local frame = ui.GetFrame("re_messagebox")

    local MainText = GET_CHILD_RECURSIVELY(frame, "MainText")
    local confirm = GET_CHILD_RECURSIVELY(frame, "confirm")

    MainText:SetTextByKey("text", txt)
    confirm:SetEventScript(ui.LBUTTONUP, "MEESAGEBOX_CONFIRM");
    confirm:SetEventScriptArgNumber(ui.LBUTTONUP, argNum);
    confirm:SetEventScriptArgString(ui.LBUTTONUP, yesscp);
end

function RE_MRESSAGEBOX_CANCLE_BTN(funcName, argNum, argStr)
    local frame = ui.GetFrame("re_messagebox")

    local cancle = GET_CHILD_RECURSIVELY(frame, "cancle")

    cancle:SetEventScript(ui.LBUTTONUP, "MEESAGEBOX_CANCLE");
    cancle:SetEventScriptArgNumber(ui.LBUTTONUP, argNum);
    cancle:SetEventScriptArgString(ui.LBUTTONUP, funcName);
end

function MEESAGEBOX_CONFIRM(ctrl, parent, funcName, argNum)
    local confirmFunc = _G[funcName]
    confirmFunc(argNum)

    ui.CloseFrame("re_messagebox")
    local topframe = parent:GetTopParentFrame();
    local confirm = GET_CHILD_RECURSIVELY(topframe, "confirm")

    confirm:SetEventScript(ui.LBUTTONUP, "None");
    confirm:SetEventScriptArgNumber(ui.LBUTTONUP, -1);
    confirm:SetEventScriptArgString(ui.LBUTTONUP, '');
end

function MEESAGEBOX_CANCLE(ctrl, parent, funcName, argNum)
    local confirmFunc = _G[funcName]
    confirmFunc(argNum)

    ui.CloseFrame("re_messagebox")
    local topframe = parent:GetTopParentFrame();
    local cancle = GET_CHILD_RECURSIVELY(topframe, "cancle")

    cancle:SetEventScript(ui.LBUTTONUP, "REMESSAGEBOX_CLOSE_BTN");
    cancle:SetEventScriptArgNumber(ui.LBUTTONUP, -1);
    cancle:SetEventScriptArgString(ui.LBUTTONUP, '');
end

function CLOSE_RE_MESSAGEBOX(frame)
    local confirm = GET_CHILD_RECURSIVELY(frame, "confirm")
    local cancle = GET_CHILD_RECURSIVELY(frame, "cancle")

    confirm:SetEventScript(ui.LBUTTONUP, "None");
    confirm:SetEventScriptArgNumber(ui.LBUTTONUP, -1);
    confirm:SetEventScriptArgString(ui.LBUTTONUP, '');

    cancle:SetEventScript(ui.LBUTTONUP, "REMESSAGEBOX_CLOSE_BTN");
    cancle:SetEventScriptArgNumber(ui.LBUTTONUP, -1);
    cancle:SetEventScriptArgString(ui.LBUTTONUP, '');
end


function REMESSAGEBOX_CLOSE_BTN()
    ui.CloseFrame('re_messagebox')
end