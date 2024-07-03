function TOGGLE_CUPOLE_RATIO(frame, ctrl, argStr, argNum)
    ui.ToggleFrame("cupole_ratio_open")
end

function OPEN_CUPOLE_RATIO_TABLE(frame)
    local table = GET_CUPOLE_PROBABILITY()
    CREATE_CUPOLE_RATIO_LIST(frame, table)
end

function CREATE_CUPOLE_RATIO_LIST(frame, table)
    local ctrlBG = GET_CHILD_RECURSIVELY(frame, "ctrlBG")
    ctrlBG:SetScrollBarSkinName("verticalscrollbar3")
    local URBG = GET_CHILD_RECURSIVELY(ctrlBG, "URBG")
    local SRBG = GET_CHILD_RECURSIVELY(ctrlBG, "SRBG")
    local RBG = GET_CHILD_RECURSIVELY(ctrlBG, "RBG")

    local offset = {495, 55};

    URBG:SetUserValue("x", 0);
    SRBG:SetUserValue("x", 0);
    RBG:SetUserValue("x", 0);
    URBG:SetUserValue("y", 0);
    SRBG:SetUserValue("y", 0);
    RBG:SetUserValue("y", 0);

    local cupolelist, cnt = GetClassList("cupole_list");

    for k,v in pairs(table) do
        local clsname = v[1]
        local ratio = v[2]
        local grade = v[3]
        local bg = nil;
        local cls =  GetClassByNameFromList(cupolelist, clsname);

        if grade == "UR" then
            bg = URBG;
        elseif grade == "SR" then
            bg = SRBG;
        elseif grade == "R" then
            bg = RBG;
        else
            return;
        end

        local x = bg:GetUserIValue("x");
        local y = bg:GetUserIValue("y");
        local ctrl = bg:CreateOrGetControlSet("cupole_probalilty_slot", clsname, x * offset[1], y * offset[2] + 50);
        if ctrl == nil then
            return;
        end
        local rich_name = GET_CHILD_RECURSIVELY(ctrl,"Name")
        local rich_ratio = GET_CHILD_RECURSIVELY(ctrl,"ratio")
        local Cupole_Slot = GET_CHILD_RECURSIVELY(ctrl,"cupole_slot");
        local Gb = GET_CHILD_RECURSIVELY(ctrl,"gb");

        rich_name:SetTextByKey("name", cls.Dec_Name)
        rich_ratio:SetTextByKey("ratio", ratio)

        local RankFrameName = string.format("cupole_grade_frame_%s",grade);
        Gb:SetImage(RankFrameName)
        local Cupole_Icon = Cupole_Slot:GetIcon();
        if Cupole_Icon == nil then
            Cupole_Icon = CreateIcon(Cupole_Slot);
        end
        if cls ~= nil then
            local IconImage = TryGetProp(cls, "Icon", "None");
            if IconImage ~= "None" then
                Cupole_Icon:SetImage(IconImage);
            end
        end
    
        x = x + 1;
        if x > 1 then
            x = 0;
            y = y + 1;
        end
        bg:SetUserValue("x", x);
        bg:SetUserValue("y", y);
    end

    local URpos = URBG:GetUserIValue("y");
    local SRpos = SRBG:GetUserIValue("y");
    local Rpos = RBG:GetUserIValue("y");

    local y = 0;


    URBG:Resize(URBG:GetWidth(), (URpos + 2) * 55);
    SRBG:Resize(SRBG:GetWidth(), (SRpos + 1) * 55);
    RBG:Resize(RBG:GetWidth(), (Rpos + 2) * 55)

    SRBG:SetOffset(URBG:GetX(), (URpos + 3) * 55);
    RBG:SetOffset(URBG:GetX(), (URpos + SRpos + 5)* 55);
end

function GET_CURRENT_PICKUP_KUPOLE()
    local table = GET_CUPOLE_PROBABILITY()
    local cupolelist, cnt = GetClassList("cupole_list");

    local pickuplist = {};
    local maxratio = 0;
    for k,v in pairs(table) do
        local clsname = v[1]
        local ratio = tonumber(v[2])
        local grade = v[3]
        local cls =  GetClassByNameFromList(cupolelist, clsname);
        if grade == "UR" and ratio > maxratio then
            maxratio = ratio;
            pickuplist = {}
            pickuplist[#pickuplist + 1] = cls;
        elseif grade == "UR" and ratio == maxratio then
            pickuplist[#pickuplist + 1] = cls;
        end
    end

    return pickuplist;
end