function LETICIA_PROBABILITY_ON_INIT(addon, frame)
end

function EXTERN_OPEN_LETICIA_PROBABILITY()
    ui.ToggleFrame("leticia_probability")
end

function OPEN_LETICIA_PROBABILITY(frame)
    local managerTab = GET_CHILD(frame, "managerTab");
    local SlotTab = GET_CHILD(managerTab,"SlotTab")
    local leticia_table = LETICIA_CUBE_ITEM_LIST_BUTTON();

    CREATE_LETICIA_PROBABILITY_SLOTS(SlotTab, leticia_table)
end

function LETICIA_PROBABILTY_SEARCH_TAB(parent, ctrl, argStr, argNum)
    local frame = parent:GetTopParentFrame();
    local managerTab = GET_CHILD(frame, "managerTab");
    local SlotTab = GET_CHILD(managerTab,"SlotTab")
    local leticia_table = LETICIA_CUBE_ITEM_LIST_BUTTON();

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
    local leticia_table = LETICIA_CUBE_ITEM_LIST_BUTTON();

    CREATE_LETICIA_PROBABILITY_SLOTS(SlotTab, leticia_table)
end

function CREATE_LETICIA_PROBABILITY_SLOTS(parent, table)
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
        
        local ItemCls = GetClassByStrProp("Item", "ClassName", tab[1])
        local ItemName = TryGetProp(ItemCls, "Name", 'None');
        
        name:SetTextByKey("value", ItemName);
        cnt:SetTextByKey("value", tab[2]);
        grade:SetTextByKey("value", tab[4]);
        percente:SetTextByKey("value", tab[3]);

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
        -- print(tab[1], tab[2], tab[3])
    end
end

