function LETICIA_PROBABILITY_ON_INIT(addon, frame)
end

function EXTERN_OPEN_LETICIA_PROBABILITY(frame, parent, argStr, argNum)
    if config.GetServiceNation() == 'PAPAYA' then
        local textmsg = string.format("[ %s ]{nl}%s", '{@st66d_y}'..ClMsg('ContainWarningItem2')..'{/}{/}', '{nl} {nl}'..ScpArgMsg("ContainWarningItem_URL"))
        ui.MsgBox(textmsg, 'LETICIA_CUBE_ITEM_LIST_BUTTON_URL', "None")
        return
    end
    local probailty = ui.GetFrame("leticia_probability");
    probailty:SetUserValue("Type", argNum);
    probailty:SetUserValue("Round", argStr);

    ui.ToggleFrame("leticia_probability")
end

function CHANGE_TAB_LETICIA_PROBAILITY(frame, parent, argStr, argNum)
    local probailty = ui.GetFrame("leticia_probability");
    probailty:SetUserValue("Type", argNum);
    probailty:SetUserValue("Round", argStr);
    OPEN_LETICIA_PROBABILITY(probailty)
end

--frame type 별로 리스트 가져오기
function GET_LIST_BY_FRAME_TYPE(frame)
    local TopTab = GET_CHILD_RECURSIVELY(frame, "TopTab")
    local RounTab = GET_CHILD_RECURSIVELY(frame, "RounTab")
    RounTab:RemoveAllChild();

    local TypeNum = frame:GetUserIValue("Type")
    local RoundStr = frame:GetUserIValue("Round")
    local Round = tonumber(RoundStr);

    local table = {}
    if TypeNum == 1 then
        table = LETICIA_CUBE_ITEM_LIST_BUTTON();
        TopTab:ShowWindow(1)
    elseif TypeNum == 2 then
        table = GET_STEP_GACHA_PROBABILITY_TABLE(Round);
        CREATE_PROBABILITY_ROUND_BTN(RounTab)
        RounTab:ShowWindow(1)
        TopTab:ShowWindow(0)
    elseif TypeNum == 3 then
        table = GET_GODDESS_CUBE_PROBABILITY("Gacha_Blessed_CUBE_001")
        TopTab:ShowWindow(1);
    else
        table = GET_STEP_GACHA_PROBABILITY_TABLE(Round);
        RounTab:ShowWindow(0)
        TopTab:ShowWindow(0)
        -- CREATE_PROBABILITY_ROUND_BTN(RounTab)
    end
    return table;
end

function CREATE_PROBABILITY_ROUND_BTN(frame)
    for i = 0, 4 do
        local ctrl = frame:CreateOrGetControlSet("event_probaility_sel_slot", 'slot'..i, 91 * i , 0);
        local select_btn = GET_CHILD(ctrl, "select_btn")
        select_btn:SetEventScript(ui.LBUTTONUP, "CHANGE_TAB_LETICIA_PROBAILITY")
        select_btn:SetEventScriptArgNumber(ui.LBUTTONUP, 2)
        select_btn:SetEventScriptArgString(ui.LBUTTONUP, tostring(i + 1))

        
        select_btn:SetTextByKey("value", tostring(i + 1))
    end
end

--레티샤 확률 보기

function OPEN_LETICIA_PROBABILITY(frame)
    local managerTab = GET_CHILD(frame, "managerTab");
    local SlotTab = GET_CHILD(managerTab,"SlotTab")
    local table = GET_LIST_BY_FRAME_TYPE(frame);

    
    CREATE_LETICIA_PROBABILITY_SLOTS(SlotTab, table)
end

function LETICIA_PROBABILTY_SEARCH_TAB(parent, ctrl, argStr, argNum)
    local frame = parent:GetTopParentFrame();
    local managerTab = GET_CHILD(frame, "managerTab");
    local SlotTab = GET_CHILD(managerTab,"SlotTab")
    local leticia_table = GET_LIST_BY_FRAME_TYPE(frame);

    local input = GET_CHILD_RECURSIVELY(frame, "input");
	local searchFortext = input:GetText();
	
	searchFortext = string.lower(searchFortext)
    local newtable = {};
    for i = 1, #leticia_table do 
        local tab = leticia_table[i];
        local ItemCls = GetClassByStrProp("Item", "ClassName", tab[1])
        local ItemName = TryGetProp(ItemCls, "Name", 'None');

        if config.GetServiceNation() ~= "KOR" and config.GetServiceNation() ~= "GLOBAL_KOR" then
            ItemName = dic.getTranslatedStr(ItemName);				
        end
        ItemName = string.lower(ItemName)
        local startNum, endNum = string.find(ItemName, searchFortext);
        if (startNum ~= nil) or (endNum ~= nil) then
            table.insert(newtable, {tab[1],tab[2],tab[3],tab[4]});
        end
    end

    CREATE_LETICIA_PROBABILITY_SLOTS(SlotTab, newtable)
end

function LETICIA_PROBABILITY_SEARCH_CLICK(parent, ctrl, argStr, argNum)
	ctrl:ClearText();
    local frame = parent:GetTopParentFrame();
    local managerTab = GET_CHILD(frame, "managerTab");
    local SlotTab = GET_CHILD(managerTab,"SlotTab")
    local leticia_table = GET_LIST_BY_FRAME_TYPE(frame);

    CREATE_LETICIA_PROBABILITY_SLOTS(SlotTab, leticia_table)    
end

function CREATE_LETICIA_PROBABILITY_SLOTS(parent, table)
    local topframe = parent:GetTopParentFrame();
    local TypeNum = topframe:GetUserIValue("Type")

    parent:RemoveAllChild();

    local x = 10;
    local y = 0;
    local offset = 75;
    for i = 1, #table do
        local tab = table[i]

        local probability_slot = parent:CreateOrGetControlSet("leticia_probability_slot", "leticia_probability_slot"..i, x, y);
        y = offset * i;

        local maintab = GET_CHILD(probability_slot, "maintab")
        local name = GET_CHILD(maintab, "name")
        local cnt = GET_CHILD(maintab, "cnt")
        local grade = GET_CHILD(maintab, "grade")
        local percente = GET_CHILD(maintab, "percente")
        local pic = GET_CHILD(maintab, "pic")
        local inSlotCnt = GET_CHILD(pic, "inSlotCnt")

        local ItemCls = GetClassByStrProp("Item", "ClassName", tab[1])
        local ItemName = TryGetProp(ItemCls, "Name", 'None');
        
        if TypeNum == 1 or TypeNum == 3 then
            inSlotCnt:ShowWindow(0)
            cnt:ShowWindow(1);
        else
            inSlotCnt:ShowWindow(1)
            cnt:ShowWindow(0);
            tab[4] = tab[4]..'F';
        end


        name:SetTextByKey("value", ItemName);
        cnt:SetTextByKey("value", tab[2]);
        grade:SetTextByKey("value", tab[4]);
        percente:SetTextByKey("value", tab[3]);
        inSlotCnt:SetTextByKey("value", tab[2]);


        local fullImage = GET_LEGENDEXPPOTION_ICON_IMAGE_FULL(ItemCls);

        local icon = pic:GetIcon()
        if icon ~= nil then
            icon:SetImage(fullImage)
        else
            icon = CreateIcon(pic);
            icon:SetImage(fullImage)
        end       
        SET_BALCK_MARKET_TOOLTIP(icon,ItemCls)
    
        SET_BALCK_MARKET_ITEM_NAME(maintab,ItemCls)
    end
end


---다른 변동 확률 리스트 보기
function OPEN_EVENT_PROBAILITY(frame)
    local pc = GetMyPCObject()
    if not pc then
        return;
    end

    local managerTab = GET_CHILD(frame, "managerTab");
    local SlotTab = GET_CHILD(managerTab,"SlotTab")
    local event_table = GET_STEP_GACHA_CLS(pc, 0);

    CREATE_LETICIA_PROBABILITY_SLOTS(SlotTab, event_table)
end