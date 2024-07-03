------가챠 결과 관련 함수들
local GachaResultTable = {};
local posx = 0;
local posy = 0;
local OFFSET = 160
local GACHA_DEFAULT_Y = -50
local UPDATE_INTERVAL = 0.1

local GACHA = 1
local GACHA_MAX = 10;
-- Gacha 결과 초기화 및 시작
function ON_GACHA_CUPOLE_RESULT(frame, msg, argStr, argNum)
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local gachaBG = GET_CHILD_RECURSIVELY_NAME(cupole_gacha, "managerTab/gachaBG");

    TOGGLE_CUPOLE_GACHA_STATE(true)
    GachaResultTable = StringSplit(argStr, ';');
    posx = 0;
    posy = 0;
    if #GachaResultTable == 1 then
        SET_CUPOLE_GACHA_MAX_COUNT(1)
    elseif #GachaResultTable == 11 then
        SET_CUPOLE_GACHA_MAX_COUNT(11)
    end
    gachaBG:RunUpdateScript('SCR_GACHA_CONTROLSET_CREATE', UPDATE_INTERVAL)    
    SET_CUPOLE_RECRUIT_COUNT(cupole_gacha)
end

-- Gacha 상태 토글
function TOGGLE_CUPOLE_GACHA_STATE(state)
    local cupole_gacha = ui.GetFrame("cupole_gacha")
    local cupole_item = ui.GetFrame("cupole_item")

    local gachaBG = GET_CHILD_RECURSIVELY_NAME(cupole_gacha, "managerTab/gachaBG");
    local pickUpBG = GET_CHILD_RECURSIVELY_NAME(cupole_item, "managerTab/pickUpBG");

    gachaBG:RemoveAllChild();

    if state == true then
        ui.OpenFrame("cupole_gacha")
        gachaBG:ShowWindow(1);
        pickUpBG:ShowWindow(0);    
    else
        ui.CloseFrame("cupole_gacha")
        gachaBG:ShowWindow(0);
        pickUpBG:ShowWindow(1);    
    end
end

--Create ControlSet
--Create UIMODEL
-- Gacha 결과 생성
function SET_GACHA_RESULT(frame, Result, dx, dy, offset, index)
    local MaxCount = GET_CUPOLE_GACHA_MAX_COUNT();
    local MaxRow = 5;
    local DefaultX = 90;
    local DefaultY = 105;
    if dy == 0 then
        DefaultX = 200;
    end
    
    if MaxCount == 1 then
        DefaultX = 650;
        DefaultY = 201;
    end

    local GachaResult = StringSplit(Result, '/');
    local cupole_index = tonumber(GET_KUPOLE_INDEX_BY_CLASSNAME(GachaResult[1]));
    if cupole_index < 0 then
        return dx, dy;
    end

    local Ctrl = frame:CreateOrGetControlSet("gacha_kupole", "gacha_kupole"..index, dx * offset[1] + DefaultX, dy * offset[2] + DefaultY);
    if Ctrl == nil then
        return dx, dy;
    end

    local Gacha_BackBox = GET_CHILD(Ctrl, "Gacha_BackBox")
    local Gacha_GroupBox = GET_CHILD(Ctrl, "Gacha_GroupBox")
    local Gacha_FrontFrameBox = GET_CHILD(Gacha_GroupBox, "Gacha_FrontFrameBox")
    -- local Name = GET_CHILD_RECURSIVELY(Ctrl,"Name");
    local BackBoxImg = GET_CHILD(Gacha_BackBox, "BackImg");
    local scrbox = GET_CHILD(Ctrl, "scrbox")

    local FrontBackFrame = GET_CHILD(Gacha_FrontFrameBox, "BackFrame")
    local BackBackFrame = GET_CHILD(Gacha_BackBox, "BackFrame")
    local chainFrame = GET_CHILD(Gacha_BackBox, "chainFrame")
    local CupoleCls = GET_CUPOLE_BY_INDEX_IN_CLASSLIST(cupole_index);
    -- local CupoleName = TryGetProp(CupoleCls, "Dec_Name", "None");
    local Grade = TryGetProp(CupoleCls, "Grade", "R");
    
    KUPOLE_UIMODEL_IN_GACHA_RESULT(Ctrl, cupole_index)
    SET_FRAME_GRADE(BackBoxImg, Grade, "kupolebackground");
    SET_FRAME_GRADE(FrontBackFrame, Grade, "kupolecardframe");
    SET_FRAME_GRADE(BackBackFrame, Grade, "kupolebackground");
    SET_FRAME_GRADE(chainFrame, Grade, "kupolechain");

    -- SET_FRAME_EFFECT(Ctrl, Grade, "UI_gacha_effect")
    -- Ctrl:PlayUIEffect("UI_gacha_effect2", 5, "Gacha_Effect")
    -- Name:SetTextByKey("Name", CupoleName)
    Gacha_BackBox:ShowWindow(1);
    Gacha_GroupBox:ShowWindow(0);

    dx = dx + 1;
    if dx >= MaxRow + dy then
        dx = 0;
        dy = dy + 1;
    end
    scrbox:SetUserValue("IS_OPEN", 0)
    scrbox:SetEventScript(ui.LBUTTONUP, "SCR_GACHA_OPEN_CLICK");
    scrbox:SetEventScriptArgString(ui.LBUTTONUP, Grade);

    return dx, dy;
end

-- 프레임 등급 설정
function SET_FRAME_GRADE(frame, grade, imgname)
    local name = "";
    if grade == "UR" then
        name = imgname.."_UR"
        if imgname == "kupolebackground" then
            name = imgname.."_UR_Goddess"
        end
    elseif grade == "SR" then
        name = imgname.."_SR"
    else
        name = imgname.."_R"
    end
    if frame then
        frame:SetImage(name);
    end
end
-- 프레임 효과 설정
function SET_FRAME_EFFECT(frame, grade ,effectname)
    local name = "";
    if grade == "UR" then
        name = effectname..1
    elseif grade =="SR" then
        name = effectname..2
    else
        name = effectname..3
    end
    frame:PlayUIEffect(name, 4.5, "Gacha_Effect")
end

--------가챠 UI 관련
function OPEN_CUPOLE_PICKUP_TAB()
    local frame = ui.GetFrame("cupole_item");
    local managerTab = frame:GetChild("managerTab")
    local gachaBG = managerTab:GetChild("gachaBG")
    local pickUpBG = managerTab:GetChild("pickUpBG")
    local GachaName= GET_CHILD_RECURSIVELY(pickUpBG, "GachaName")

    local pickuplist = GET_CURRENT_PICKUP_KUPOLE()
    local imc_random = IMCRandom(1, #pickuplist)
    local name = TryGetProp(pickuplist[imc_random],"ClassName", "None");
    CUPOLE_SPINE_ANIMAITON_SET(pickUpBG, name);
    
    gachaBG:ShowWindow(0);
    pickUpBG:ShowWindow(1);

    SET_CUPOLE_PICKUP_LIST(pickUpBG, 0);
    SET_CURRENT_CUPOLE_PICKUP_ITEM_VALUE_COLOR(frame)

    local cls = GET_KUPOLE_CLS_BY_CLASSNAME(name)
    local Dec_Name = TryGetProp(cls, "Dec_Name", "None")
    local KupoleName = "{img cupole_grade_UR 40 24}"..Dec_Name;

    GachaName:SetTextByKey("Name", KupoleName);
end

-----초기 픽업 UI 생성
function SET_CUPOLE_PICKUP_LIST(frame, initY)
    local pickupSelectBG = GET_CHILD_RECURSIVELY(frame, "pickupSelectBG")
    local pickuplist, cnt =  GetClassList("cupole_pickuplist");
    local y = initY;
    
    for i = 0, cnt - 1 do
        local pickupcls = GetClassByIndexFromList(pickuplist, i)
        local nation = TryGetProp(pickupcls, "Nation", "None");
        if nation == config.GetServiceNation() then
            if pickupcls ~= nil then
                local StartTime = TryGetProp(pickupcls, "StartTime", "1999-01-01 01:00:00");
                local EndTime = TryGetProp(pickupcls, "EndTime", "1999-01-01 02:00:00");
                local SysTime = geTime.GetServerSystemTime();
                local Always = TryGetProp(pickupcls, "Always", "False");

                local nowstr = string.format("%04d-%02d-%02d %02d:%02d:%02d", SysTime.wYear, SysTime.wMonth, SysTime.wDay, SysTime.wHour, SysTime.wMinute, SysTime.wSecond)
                local StartAfterTime = date_time.get_lua_datetime_from_str(StartTime) - date_time.get_lua_datetime_from_str(nowstr)
                local RemainTime = date_time.get_lua_datetime_from_str(EndTime) - date_time.get_lua_datetime_from_str(nowstr)

                if StartAfterTime < 0 and RemainTime > 0 then
                    local PickupClsName = TryGetProp(pickupcls, "ClassName", "None")
                    local ctrl = pickupSelectBG:CreateOrGetControlSet("cupole_pickup_list", PickupClsName, 0, y * OFFSET + GACHA_DEFAULT_Y);
                    local Banner = GET_CHILD_RECURSIVELY(ctrl, "Banner");
                    local Disable_Shadow = GET_CHILD_RECURSIVELY(ctrl, "disable_shadow");
                    local Gacha_GroupBox = GET_CHILD_RECURSIVELY(ctrl, "Gacha_GroupBox")
                    local TimeText = GET_CHILD_RECURSIVELY(ctrl, "Time");
                    ctrl:SetGravity(ui.CENTER_HORZ, ui.TOP);

                    local BannerImageName = TryGetProp(pickupcls,"BannerImage", "None");
                    Banner:SetImage(BannerImageName);
                
                    Disable_Shadow:ShowWindow(0);
                    y = y + 1;

                    local timeTxt = GET_TIME_TXT(RemainTime, 0);
                    if Always == "True" then
                        TimeText:ShowWindow(0);
                    end
                    TimeText:SetTextByKey("Time", timeTxt);
                end            
            end
        end
    end

    pickupSelectBG:SetUserValue("CURRENT_GACHA_INDEX", 0);
    TOGGLE_DISABLE_SHADOW(pickupSelectBG, 0);

    frame:SetEventScript(ui.MOUSEWHEEL, "GACHA_PICKUP_LIST_CHANGE");

end

local function IsValidRange(index, min, max)
        if index < min or index >= max then
            return false;
    end
    return true;
end

function GACHA_PICKUP_LIST_CHANGE(frame, ctrl, argStr, wheel)
    local pickupSelectBG = GET_CHILD_RECURSIVELY(ctrl,"pickupSelectBG")
    local ChildCnt = pickupSelectBG:GetChildCount();
    local index = pickupSelectBG:GetUserIValue("CURRENT_GACHA_INDEX");

    if pickupSelectBG:HaveUpdateScript("UPDATE_DEALY_FUNCTION") == true then
        return;
    else
        pickupSelectBG:RunUpdateScript("UPDATE_DEALY_FUNCTION",0.2)
    end

    if IsValidRange(index, 0, ChildCnt) == false then
        return;
    end
    if wheel < 0 then
        if IsValidRange(index + 1, 0, ChildCnt) == true then
            pickupSelectBG:SetUserValue("CURRENT_GACHA_INDEX", index + 1);
        end
    elseif wheel > 0 then        
        if IsValidRange(index - 1, 0, ChildCnt) == true then
            pickupSelectBG:SetUserValue("CURRENT_GACHA_INDEX", index - 1);
        end
    end

    local SetIndex = pickupSelectBG:GetUserIValue("CURRENT_GACHA_INDEX");

    TOGGLE_DISABLE_SHADOW(pickupSelectBG, SetIndex)
end

function UPDATE_DEALY_FUNCTION(frame)
    return 0;
end


function TOGGLE_DISABLE_SHADOW(frame, TargetIndex)
    local ChildCount = frame:GetChildCount();
    for i = 0, ChildCount do
        local Ctrl = frame:GetChildByIndex(i);
        if Ctrl ~= nil then
            local Disable_Shadow = GET_CHILD_RECURSIVELY(Ctrl, "Disable_Shadow")
            if TargetIndex ~= i then
                Disable_Shadow:ShowWindow(1);
                GACHA_SELECT_STATE(Ctrl, 0)
            else
                Disable_Shadow:ShowWindow(0);
                GACHA_SELECT_STATE(Ctrl, 1)
            end
            Ctrl:SetPos(0, OFFSET * (i + 1) - (OFFSET * TargetIndex) + GACHA_DEFAULT_Y);
        end
    end
end

function GACHA_SELECT_STATE(frame, state)
    frame:SetUserValue("IsSelect", state)
    ----
    ----관련 추가 작업
end




---가챠돌리는 함수
function GACHA_CUPOLE_START_ON(frame, ctrl, argStr, argNum)

    curr_my_cnt, itemlist = GET_INV_ITEM_COUNT_BY_PROPERTY({
        { Name = 'ClassName', Value = get_cupole_recruit_item_name() }
    }, false)

    local count = 0;
    if argNum == 0 then
        if curr_my_cnt < GACHA then
            ui.SysMsg(ClMsg('NotEnoughCupoleTicket'));
            END_CUPOLE_GACHA();
            return 0;
        end
        count = GACHA;
    elseif argNum == 1 then
        if curr_my_cnt < GACHA_MAX then
            ui.SysMsg(ClMsg('NotEnoughCupoleTicket'));
            END_CUPOLE_GACHA();
            return ;
        end
        count = GACHA_MAX;
    end

    local text = ScpArgMsg('QuestionKupoleGacha{COUNT}', "COUNT", count);
    MESSAGEBOX_OPEN(text, 'CUPOLE_GACHA_START', argNum);
end

function CUPOLE_GACHA_START(argNum)
    if IS_IN_CITY() == 0 then
        ui.SysMsg(ClMsg('AllowedInTown'));
        return ;
    end
    local item = session.GetInvItemByName(get_cupole_recruit_item_name())
    if item == nil then
        ui.SysMsg(ClMsg('NotEnoughCupoleTicket'));
        return;
    end
    local guid = item:GetIESID()
    local type = argNum -- 0:단차 1:10연차 2:픽업
    type = type .. ' 10'
    pc.ReqExecuteTx_Item("CUPOLE_RECRUIT", guid, type)
    REMOVE_ALL_CUPOLE_UIMODEL();

end

------가챠 UI생성 update
function SCR_GACHA_CONTROLSET_CREATE(frame)
    local offset = {221,280};
    local curIndex = GET_CUPOLE_GACHA_CUR_COUNT();
    local Result = GachaResultTable[curIndex]
    if Result ~= nil or v ~= "" or Result ~= "None"  then
        posx, posy = SET_GACHA_RESULT(frame, Result, posx, posy, offset, curIndex);
        SET_CUPOLOE_GACHA_COUNT();
        curIndex = curIndex + 1;
    end
    local max = GET_CUPOLE_GACHA_MAX_COUNT();
    if curIndex <= max then
        return 1;
    end

    local parent = frame:GetTopParentFrame()
    SET_GACHA_SKIP_BTN(parent, "SCP_CUPOLE_GACHA_SKIP_BTN")
    return 0;
end

function SET_GACHA_SKIP_BTN(frame, funcname)
    local skip_gacha_btn = GET_CHILD_RECURSIVELY(frame, "skip_gacha_btn")
    skip_gacha_btn:SetEventScript(ui.LBUTTONDOWN, funcname);
end

----가챠 UI 클릭 이벤트
function SCR_GACHA_OPEN_CLICK(frame, ctrl, argStr, argNum)
    local scrbox = GET_CHILD_RECURSIVELY(frame, "scrbox")
    local IsOpne = scrbox:GetUserIValue("IS_OPEN")
    SET_CUPOLE_GACHA_CUR_OPEN_COUNT();
    if IsOpne == 1 then
        return;
    end
    scrbox:SetUserValue("IS_OPEN", 1)

    if argStr == "UR" then
        scrbox:PlayUIEffect("UI_gacha_kupole_UR", 32, "Effect");
    elseif argStr == "SR" then
        scrbox:PlayUIEffect("UI_gacha_kupole_SR", 32, "Effect");
    else
        scrbox:PlayUIEffect("UI_gacha_kupole_R", 32, "Effect");
    end
    local curcnt = GET_CUPOLE_GACHA_CUR_OPEN_COUNT()

    scrbox:SetEventScript(ui.LBUTTONUP,"None");
    frame:ReserveScript("RESERVE_GACHA_EFFECT_END",2.1, curcnt, argStr)
    frame:ReserveScript("INVISIBLE_FRAME_RESERVE", UPDATE_INTERVAL, 0, "")
end

---가챠 종료 시 실행
function RESERVE_GACHA_EFFECT_END(ctrl, argnum, argstr)
    local BackImg = GET_CHILD_RECURSIVELY(ctrl, "BackImg")
    local effectname = "UI_gacha_effect"
    if argstr == "UR" then
        effectname = effectname..1;
    elseif argstr == "SR" then
        effectname = effectname..2;
    else
        effectname = effectname..3;
    end
    local maxcnt = GET_CUPOLE_GACHA_MAX_COUNT();
    BackImg:PlayUIEffect(effectname, 4.6, "Gacha_Effect")

    if CHECK_MAX_COUNT() == true and argnum == maxcnt then
        UNBLOCK_ESCAPE_BTN();
    end
end

---가챠 종료시 visiblelilty 처리
function INVISIBLE_FRAME_RESERVE(ctrl, argnum, argstr)
    local Gacha_GroupBox = GET_CHILD_RECURSIVELY(ctrl, "Gacha_GroupBox")
    local Gacha_BackBox = GET_CHILD_RECURSIVELY(ctrl, "Gacha_BackBox")

    Gacha_BackBox:ShowWindow(0);
    Gacha_GroupBox:ShowWindow(1);
end

--가챠 시 텍스트 color 체크
function SET_CUPOLE_GACHA_COLOR(frame)
    local invItem = session.GetInvItemByName("Premium_cupole_recruit_ticket")
    local count = invItem and tonumber(invItem:GetAmountStr()) or 0

    local gachacnt1 = GET_CHILD_RECURSIVELY(frame, "gachacnt1")
    local gachacnt2 = GET_CHILD_RECURSIVELY(frame, "gachacnt2")

    if count < 1 then
        gachacnt1:SetText("{@st66d}{s18}{#FF0000}1{/}")
    else
        gachacnt1:SetText("{@st66d}{s18}1")
    end
    if count < 10 then
        gachacnt2:SetText("{@st66d}{s18}{#FF0000}10{/}")
    else
        gachacnt2:SetText("{@st66d}{s18}10")
    end
end

--가챠 스킵 버튼 시 자동으로 열기 
function SCP_CUPOLE_GACHA_SKIP_BTN(parent, ctrl, argStr, argNum)
    --0.5초 이후 부터 cupole 자동적으로 opend
    local IsSkip = parent:GetUserIValue("IsSkip");
    if IsSkip == 1 then
        return;
    end
    parent:SetUserValue("curCnt", 0)
    parent:SetUserValue("IsSkip", 1);

    parent:RunUpdateScript("EXEC_CUPOLE_GACHA_AUTO_OPEND", 0.5);
    local frame = parent:GetTopParentFrame();
    SET_GACHA_SKIP_BTN(frame, "None")
end

function EXEC_CUPOLE_GACHA_AUTO_OPEND(frame)
    local curIndex = GET_CUPOLE_GACHA_CUR_OPEN_COUNT();
    local MaxCount = GET_CUPOLE_GACHA_MAX_COUNT();
    local gachaBG = GET_CHILD_RECURSIVELY(frame, "gachaBG")

    for i = 1, (MaxCount + 1) do
        local ctrl = gachaBG:GetChildByIndex(i)
        if not ctrl then
            return 0;
        end
        local scrbox = GET_CHILD_RECURSIVELY(ctrl, "scrbox")
        local grade = scrbox:GetEventScriptArgString(ui.LBUTTONUP)
        SCR_GACHA_OPEN_CLICK(ctrl, scrbox, grade, argNum)
    end
    return 0;
end