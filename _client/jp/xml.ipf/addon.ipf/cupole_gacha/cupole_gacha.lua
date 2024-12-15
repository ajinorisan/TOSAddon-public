function CUPOLE_RESULT_SKIL_BTN(parent, ctrl, argStr, argNum)
    ui.CloseFrame("cupole_gacha");
end

function OPEN_CUPOLE_GACHA(frame)
    frame:RunUpdateScript("UPDATE_CUPOLE")
    frame:SetUserValue("GachaCnt", 0);
    SET_CUPOLE_RECURIT_CHECK_BTN_VISIBLILITY(frame, 0);
    BLOCK_ESCAPE_BTN();
    imcSound.PlaySoundEvent("sys_card_eff_3")
end

function CLOSE_CUPOLE_GACHA(frame)
    frame:StopUpdateScript('UPDATE_CUPOLE')
    END_CUPOLE_GACHA()
end

function END_CUPOLE_GACHA()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    TOGGLE_CUPOLE_GACHA_STATE(false)
    RESET_CUPOLE_GACHA_COUNT(cupole_gacha)
    UNBLOCK_ESCAPE_BTN();
end

function CHECK_MAX_COUNT()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local maxval = cupole_gacha:GetUserIValue("MAXCnt");
    local count = cupole_gacha:GetUserIValue("curCnt");

    if maxval <= count then
        SET_CUPOLE_RECURIT_CHECK_BTN_VISIBLILITY(cupole_gacha, 1);
        return true;
    end
    return false;
end

function RESET_CUPOLE_GACHA_COUNT(frame)
    frame:SetUserValue("GachaCnt", 0)
    frame:SetUserValue("MAXCnt", 0)
    frame:SetUserValue("curCnt", 0)
    frame:SetUserValue("IsSkip", 0);
    ui.FlushGachaDelayPacket();
    SET_CUPOLE_RECURIT_CHECK_BTN_VISIBLILITY(frame, 0)
end

function SET_CUPOLOE_GACHA_COUNT()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local count = cupole_gacha:GetUserIValue("GachaCnt");
    cupole_gacha:SetUserValue("GachaCnt", count + 1);
end

function SET_CUPOLE_GACHA_MAX_COUNT(count)
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    cupole_gacha:SetUserValue("MAXCnt", count);
end

function GET_CUPOLE_GACHA_MAX_COUNT()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local count = cupole_gacha:GetUserIValue("MAXCnt");
    return count;
end

function SET_CUPOLE_GACHA_CUR_OPEN_COUNT()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local count = cupole_gacha:GetUserIValue("curCnt");
    cupole_gacha:SetUserValue("curCnt", count + 1);
end

function GET_CUPOLE_GACHA_CUR_COUNT()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local count = cupole_gacha:GetUserIValue("GachaCnt");
    return count;
end

function GET_CUPOLE_GACHA_CUR_OPEN_COUNT()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local count = cupole_gacha:GetUserIValue("curCnt");
    return count;
end

function SET_CUPOLE_RECRUIT_COUNT(frame)
    local onemore = GET_CHILD_RECURSIVELY(frame,"onemore")
    local invItem = session.GetInvItemByName("Premium_cupole_recruit_ticket")
    local max = GET_CUPOLE_GACHA_MAX_COUNT()
    if max == 11 then
        max = max - 1;
    end
    local count = nil;
    if invItem == nil then
        count = 0;
    else
        count = invItem:GetAmountStr();
    end
    local text = count;
    if tonumber(count) < max then
        text = "{#FF0000}"..text.."{/}";
    end
    onemore:SetTextByKey("count", text);
    onemore:SetTextByKey("max", max);
end

function SET_CUPOLE_RECURIT_CHECK_BTN_VISIBLILITY(frame, visible)
    local onemore = GET_CHILD_RECURSIVELY(frame,"onemore")
    local cancle = GET_CHILD_RECURSIVELY(frame,"cancle")

    onemore:ShowWindow(visible)
    cancle:ShowWindow(visible)
end


function RE_RECRUIT_CUPOLE_GACHA()
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local maxcount = GET_CUPOLE_GACHA_MAX_COUNT();
    local types = 0;
    if maxcount == 11 then
        types = 1;
    elseif maxcount == 1 then
        types = 0;
    end
    END_CUPOLE_GACHA()
    RE_MRESSAGEBOX_CANCLE_BTN("END_CUPOLE_GACHA",0 ,'0');
    RESET_CUPOLE_GACHA_COUNT(cupole_gacha);
    GACHA_CUPOLE_START_ON(cupole_gacha, nil, nil, types);
    -- CUPOLE_GACHA_START(types)
end

function BLOCK_ESCAPE_BTN()
    ui.SetEscapeScp("BLOCKING_FUNC()")
end

function UNBLOCK_ESCAPE_BTN()
    ui.SetEscapeScp("")
end


function BLOCKING_FUNC()

end