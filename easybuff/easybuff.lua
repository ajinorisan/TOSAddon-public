local addonName = "EASYBUFF"
local author = "norisan"
local version = '1.0.6'
--CHAT_SYSTEM("Easy Buff by Kiicchan!")

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName];
g.buffIndex = 0;
g.foodIndex = 0;

local acutil = require("acutil");

function EASYBUFF_ON_INIT(addon, frame)
    CHAT_SYSTEM("EASYBUFF_ON_INIT")
    local frame = ui.GetFrame("easybuff")
    frame:Resize(100, 30)
    frame:ShowWindow(1)
    frame:SetAlpha(0)
    -- ボタンを取得する
    local button = GET_CHILD(frame, "myButton", "ui::CButton");
    button:ShowWindow(1) -- ボタンを表示する
    -- ボタンのサイズを変更する
    button:Resize(100, 30)
    frame:SetOffset(10,200)

    addon:RegisterMsg('GAME_START_3SEC', 'EASYBUFF_BUFFSELLER_TARGET_INIT')
    acutil.setupHook(EASYBUFF_HOOK_CLICK, 'TARGET_BUFF_AUTOSELL_LIST')
    acutil.setupHook(EASYBUFF_HOOK_CLICK_FOOD, 'OPEN_FOOD_TABLE_UI')
    acutil.setupHook(EASYBUFF_HOOK_CLICK_REPAIR, 'ITEMBUFF_REPAIR_UI_COMMON')
    acutil.slashCommand("/easybuff",EASYBUFF_CMD);

    button:SetEventScript(ui.LBUTTONDOWN, "EASYBUFF_MYBUTTON_DOWN");

    EASYBUFF_LOADSETTINGS();
end

function EASYBUFF_MYBUTTON_DOWN()
    EASYBUFF_FOODCLEAR();
end

function EASYBUFF_BUFFSELLER_TARGET_INIT()
    local frame = ui.GetFrame('buffseller_target')
    local btn = frame:CreateOrGetControl('button', 'allbuff', 20, 70, 100, 30)
    btn:SetText('{ol}Easy Buff')
    btn:SetEventScript(ui.LBUTTONUP, 'EASYBUFF_ONBUTTON')

    frame = ui.GetFrame('foodtable_ui')
    btn = frame:CreateOrGetControl('button', 'allfood', 20, 50, 100, 30)
    btn:SetText('{ol}Easy Buff')
    btn:SetEventScript(ui.LBUTTONUP, 'EASYBUFF_ONBUTTON_FOOD')

    frame = ui.GetFrame('itembuffrepair')
    btn = frame:CreateOrGetControl('button', 'onerepair', 20, 70, 100, 30)
    btn:SetText('{ol}Easy Buff')
    btn:SetEventScript(ui.LBUTTONUP, 'EASYBUFF_ONBUTTON_REPAIR')
end

function EASYBUFF_LOADSETTINGS()
	local settings, error = acutil.loadJSON("../addons/easybuff/settings.json");
	if error then
		EASYBUFF_SAVESETTINGS();
		return
	end
		g.settings = settings;
end

function EASYBUFF_SAVESETTINGS()
	if g.settings == nil then
		g.settings = {
            useHook = 1
		};
	end
	acutil.saveJSON("../addons/easybuff/settings.json", g.settings);
end

function EASYBUFF_CMD(command)
    if g.settings.useHook == 1 then
        g.settings.useHook = 0
        EASYBUFF_SAVESETTINGS();
        CHAT_SYSTEM('Auto buff off')
    else
        g.settings.useHook = 1
        EASYBUFF_SAVESETTINGS();
        CHAT_SYSTEM('Auto buff on')
    end
    return;
end

function EASYBUFF_ONBUTTON()
    local frame = ui.GetFrame("buffseller_target");
    local handle = frame:GetUserIValue("HANDLE");
	local groupName = frame:GetUserValue("GROUPNAME");
    local sellType = frame:GetUserIValue("SELLTYPE");
    local cnt = session.autoSeller.GetCount(groupName);
    local itemInfo = session.autoSeller.GetByIndex(groupName, 0);
    if itemInfo == nil then
        CHAT_SYSTEM("No buff info")
		return;
    end
    g.buffIndex = 0;
    ReserveScript(string.format('EASYBUFF_BUY(%d, %d, %d)', handle, sellType, cnt), 0.3)
end

function EASYBUFF_BUY(handle, sellType, cnt)
    if g.buffIndex < cnt then
        session.autoSeller.Buy(handle, g.buffIndex, 1, sellType);
        g.buffIndex = g.buffIndex + 1;
        ReserveScript(string.format('EASYBUFF_BUY(%d, %d, %d)', handle, sellType, cnt), 0.3)        
    else
        --CHAT_SYSTEM("Buff completed");
        ReserveScript("EASYBUFF_END()", 0.3)
    end
end

function EASYBUFF_HOOK_CLICK(groupName, sellType, handle)
    TARGET_BUFF_AUTOSELL_LIST_OLD(groupName, sellType, handle)
    if g.settings.useHook ~= 1 then
        return;
    end

    local frame = ui.GetFrame("buffseller_target");
    if frame ~= nil then
        local sellType = frame:GetUserIValue("SELL_TYPE");
        if sellType == AUTO_SELL_BUFF and g.buffIndex == 0 then        
            EASYBUFF_ONBUTTON()
        end
    end
end

function EASYBUFF_END()
    g.buffIndex = 0;
    ui.CloseFrame("buffseller_target");
end

function EASYBUFF_ONBUTTON_FOOD()
    local frame = ui.GetFrame("foodtable_ui");
    local handle = frame:GetUserIValue("HANDLE");
    local groupName = frame:GetUserValue('GroupName')
    local sellType = frame:GetUserIValue("SELLTYPE");
    local cnt = session.autoSeller.GetCount(groupName)
    g.foodIndex = 0;
    if cnt > 0 then
        EASYBUFF_BUY_FOOD(handle, sellType, cnt)
    else
        CHAT_SYSTEM("No food available")
    end
end

function EASYBUFF_BUY_FOOD(handle, sellType, cnt)
    if g.foodIndex < cnt then
        if g.foodIndex <= 4 then
            session.autoSeller.Buy(handle, g.foodIndex, 1, sellType)
            g.foodIndex = g.foodIndex + 1
            ReserveScript(string.format('EASYBUFF_BUY_FOOD(%d, %d, %d)', handle, sellType, cnt), 0.3)
        else
            ReserveScript("EASYBUFF_END_FOOD()", 0.3)
        end
    else
        --CHAT_SYSTEM("FoodBuff completed")
        ReserveScript("EASYBUFF_END_FOOD()", 0.3)
    end
end
    
function EASYBUFF_END_FOOD()
    g.foodIndex = 0;
    ui.CloseFrame("foodtable_ui");
end

-- Food Hook --

function EASYBUFF_HOOK_CLICK_FOOD(groupName, sellType, handle, sellerCID, arg_num)
    OPEN_FOOD_TABLE_UI_OLD(groupName, sellType, handle, sellerCID, arg_num)
    
    if g.settings.useHook ~= 1 then
        return;
    end

    local myTable = false;
	if session.GetMySession():GetCID() == sellerCID then
		myTable = true;
	end

    if myTable then
        return;
    elseif g.foodIndex == 0 then
        EASYBUFF_ONBUTTON_FOOD()
    end
end

-- Repair buff
function EASYBUFF_ONBUTTON_REPAIR()
    session.ResetItemList();
    
    local frame = ui.GetFrame("itembuffrepair");
    local handle = frame:GetUserValue("HANDLE");
    local skillName = frame:GetUserValue("SKILLNAME");
    local slotSet = GET_CHILD_RECURSIVELY(frame, "slotlist", "ui::CSlotSet")
    local slotCount = slotSet:GetSlotCount();

    local cheapest = nil;
    local price = 0;
	for i = 0, slotCount - 1 do
		local slot = slotSet:GetSlotByIndex(i);
		if slot:GetIcon() ~= nil then
            local Icon = slot:GetIcon();
            local iconInfo = Icon:GetInfo();
            local invitem = GET_ITEM_BY_GUID(iconInfo:GetIESID());
            local itemobj = GetIES(invitem:GetObject());
            local needItem, needCount = ITEMBUFF_NEEDITEM_Squire_Repair(GetMyPCObject(), itemobj);  
            
            if needCount < price or price == 0 then
                cheapest = slot;
                price = needCount;
            end
		end
	end
    if cheapest ~= nil then
        local Icon = cheapest:GetIcon();
		local iconInfo = Icon:GetInfo();
		session.AddItemID(iconInfo:GetIESID());
    end

    session.autoSeller.BuyItems(handle, AUTO_SELL_SQUIRE_BUFF, session.GetItemIDList(), skillName);
end

function EASYBUFF_HOOK_CLICK_REPAIR(groupName, sellType, handle)
    ITEMBUFF_REPAIR_UI_COMMON_OLD(groupName, sellType, handle)
    if g.settings.useHook ~= 1 then
        return;
    end
    local frame = ui.GetFrame("itembuffrepair");
    if frame ~= nil then
        EASYBUFF_ONBUTTON_REPAIR()
    end
end

function EASYBUFF_FOODCLEAR()
    local bufftable = {
        [1] = 4022,
        [2] = 4023,
        [3] = 4024,
        [4] = 4021,
        [5] = 4087,
        [6] = 4136
    }
    
    local handle = session.GetMyHandle()

    for _, buffID in pairs(bufftable) do
        local buff = info.GetBuff(handle, buffID)
        if buff ~= nil then
            packet.ReqRemoveBuff(buffID)
            ReserveScript(string.format("EASYBUFF_FOODCLEAR()"),0.3)
        end
    end
end
