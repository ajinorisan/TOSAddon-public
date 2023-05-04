local addonName = "EASYBUFF"
local addonNameLower = string.lower(addonName)
local author = "Kiicchan"
local version = '2.0.1'
--CHAT_SYSTEM("Easy Buff by Kiicchan!")

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName];

g.settingsFileLoc = string.format("../addons/%s/settings.json", addonNameLower);

g.settings = {useHook = 1}
g.buffIndex = 0;
g.foodIndex = 0;


local acutil = require("acutil");

function EASYBUFF_ON_INIT(addon, frame)
CHAT_SYSTEM("EASYBUFF loaded")
    frame:ShowWindow(1);
    
    if not g.loaded then
    local t, err = acutil.loadJSON(g.settingsFileLoc, g.settings);
    if err then
      --設定ファイル読み込み失敗時処理
      CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonName))
    else
      --設定ファイル読み込み成功時処理
      g.settings = t;
    end
    g.loaded = true
  end
  
  EASYBUFF_SAVESETTINGS();
  
    addon:RegisterMsg('GAME_START_3SEC', 'EASYBUFF_BUFFSELLER_TARGET_INIT')
    --addon:RegisterMsg('OPEN_ITEMBUFF_UI_COMMON', 'EASYBUFF_OPEN_ITEMBUFF_UI_COMMON');
    acutil.setupHook(EASYBUFF_HOOK_CLICK, 'TARGET_BUFF_AUTOSELL_LIST')
    acutil.setupHook(EASYBUFF_HOOK_CLICK_FOOD, 'OPEN_FOOD_TABLE_UI')
    acutil.setupHook(EASYBUFF_HOOK_CLICK_REPAIR, 'ITEMBUFF_REPAIR_UI_COMMON')
    acutil.setupHook(EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL, 'SQUIRE_BUFF_EQUIP_CTRL')
   
    acutil.slashCommand("/easybuff",EASYBUFF_CMD);
    acutil.slashCommand("/esbf",EASYBUFF_CMD);
end

function EASYBUFF_BUFFSELLER_TARGET_INIT()
    --local frame = ui.GetFrame('buffseller_target')
    --local btn = frame:CreateOrGetControl('button', 'allbuff', 20, 70, 100, 30)
    --btn:SetText('{ol}Easy Buff')
    --btn:SetEventScript(ui.LBUTTONUP, 'EASYBUFF_ONBUTTON')

    frame = ui.GetFrame('foodtable_ui')
    btn = frame:CreateOrGetControl('button', 'clearfood', 10, 50, 80, 30)
    btn:SetSkinName("test_red_button")
    btn:SetText('{ol}foodclear')
    btn:SetEventScript(ui.LBUTTONUP, 'EASYBUFF_FOODCLEAR')

    frame = ui.GetFrame('foodtable_ui')
    btn2 = frame:CreateOrGetControl('button', 'myButton2', 140, 50, 80, 30)
    btn2:SetText('{ol}4foodonly')
    btn2:SetEventScript(ui.LBUTTONUP, 'EASYBUFF_4FOODONLY')

    frame = ui.GetFrame('foodtable_ui')
    btn3 = frame:CreateOrGetControl('button', 'myButton3', 240, 50, 80, 30)
    btn3:SetText('{ol}5foodonly')
    btn3:SetEventScript(ui.LBUTTONUP, 'EASYBUFF_5FOODONLY')

    frame = ui.GetFrame('foodtable_ui')
    btn4 = frame:CreateOrGetControl('button', 'myButton4', 340, 50, 80, 30)
    btn4:SetText('{ol}allfood')
    btn4:SetEventScript(ui.LBUTTONUP, 'EASYBUFF_ALLFOOD')
    
    --frame = ui.GetFrame('itembuffrepair')
    --btn = frame:CreateOrGetControl('button', 'onerepair', 20, 70, 100, 30)
    --btn:SetText('{ol}Easy Buff')
    --btn:SetEventScript(ui.LBUTTONUP, 'EASYBUFF_ONBUTTON_REPAIR')
end

function EASYBUFF_SAVESETTINGS()
	acutil.saveJSON(g.settingsFileLoc, g.settings);
end


function EASYBUFF_SQUIRE_BUFF_EQUIP_CTRL(frame)
    SQUIRE_BUFF_EQUIP_CTRL_OLD(frame)

    if g.settings.useHook ~= 1 then
        return
    end

    EASYBUFF_SQUIRE_BUFF_EXCUTE()
end

function EASYBUFF_SQUIRE_BUFF_EXCUTE()
    --CHAT_SYSTEM("test")
    local enable_slot_list = {
        'RH', 'LH', 'RH_SUB', 'LH_SUB', 'SHIRT', 'PANTS', 'GLOVES', 'BOOTS',
    }
    local frame = ui.GetFrame("itembuffopen")
    local handle = frame:GetUserValue("HANDLE")
    local skillName = frame:GetUserValue("SKILLNAME")

    session.ResetItemList()

    local cnt = 0
    for i = 1, #enable_slot_list do
        local slot_name = enable_slot_list[i]
        local ctrlset = GET_CHILD_RECURSIVELY(frame, 'ITEMBUFF_CTRL_' .. slot_name)
        if ctrlset ~= nil then
            local checkbox = GET_CHILD(ctrlset, 'checkbox')
            checkbox:SetCheck(1)
            if checkbox:IsChecked() == 1 then
                local inv_item = session.GetEquipItemBySpot(item.GetEquipSpotNum(slot_name))
                if inv_item ~= nil then
                    session.AddItemID(inv_item:GetIESID())
                    cnt = cnt + 1
                end
            end
        end
    end

    if cnt <= 0 then
        ui.MsgBox(ScpArgMsg("SelectBuffItemPlz"))
        return
    end
    
    
    --frame:ShowWindow(0)
    ui.SysMsg("{#FF0000}Equipment Maintenance in progress")
    ui.SysMsg("{#FFFFFF}装備メンテナンス中 キャンセルは取消ボタンで!")
    session.autoSeller.BuyItems(handle, AUTO_SELL_SQUIRE_BUFF, session.GetItemIDList(), skillName)
    ReserveScript(string.format('SQUIRE_TARGET_UI_CLOSE()'),5.0) 
end

function EASYBUFF_4FOODONLY()
    
    local handle = frame:GetUserIValue("HANDLE");
    local sellType = frame:GetUserIValue("SELLTYPE");
    
    if g.foodIndex < 4 then
        session.autoSeller.Buy(handle, g.foodIndex, 1, sellType);
        g.foodIndex = g.foodIndex + 1;
        ReserveScript(string.format('EASYBUFF_4FOODONLY()'), 0.5)        
    else
        ReserveScript("EASYBUFF_END_FOOD()", 0.3)
    end
end

function EASYBUFF_5FOODONLY()
    
    local handle = frame:GetUserIValue("HANDLE");
    local sellType = frame:GetUserIValue("SELLTYPE");
    
    if g.foodIndex < 5 then
        session.autoSeller.Buy(handle, g.foodIndex, 1, sellType);
        g.foodIndex = g.foodIndex + 1;
        ReserveScript(string.format('EASYBUFF_5FOODONLY()'), 0.5)        
    else
        ReserveScript("EASYBUFF_END_FOOD()", 0.3)
    end
end

function EASYBUFF_ALLFOOD()
    
    local handle = frame:GetUserIValue("HANDLE");
    local sellType = frame:GetUserIValue("SELLTYPE");
    
    if g.foodIndex <= 5 then
        session.autoSeller.Buy(handle, g.foodIndex, 1, sellType);
        g.foodIndex = g.foodIndex + 1;
        ReserveScript(string.format('EASYBUFF_ALLFOOD()'), 0.5)        
    else
        ReserveScript("EASYBUFF_END_FOOD()", 0.3)
    end
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
    ReserveScript(string.format('EASYBUFF_BUY(%d, %d, %d)', handle, sellType, cnt), 0.5)
end

function EASYBUFF_BUY(handle, sellType, cnt)
    if g.buffIndex < cnt then
        session.autoSeller.Buy(handle, g.buffIndex, 1, sellType);
        g.buffIndex = g.buffIndex + 1;
        ReserveScript(string.format('EASYBUFF_BUY(%d, %d, %d)', handle, sellType, cnt), 0.5)        
    else
        CHAT_SYSTEM("Buff completed");
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

--[[
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
        session.autoSeller.Buy(handle, g.foodIndex, 1, sellType);
        g.foodIndex = g.foodIndex + 1;
        ReserveScript(string.format('EASYBUFF_BUY_FOOD(%d, %d, %d)', handle, sellType, cnt), 0.3)        
    else
        CHAT_SYSTEM("Buff completed")
        ReserveScript("EASYBUFF_END_FOOD()", 0.3)
    end
end
]]
    
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
        --EASYBUFF_ONBUTTON_FOOD()
    end
    --return;
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
    local myhandle = session.GetMyHandle()
    local bufftable = {
        [4022] = true,
        [4023] = true,
        [4024] = true,
        [4021] = true,
        [4087] = true,
        [4136] = true
    }
      
    local shouldReserveScript = false
    for buffID, _ in pairs(bufftable) do
        local buff = info.GetBuff(myhandle, buffID)
        if buff ~= nil then
            
            packet.ReqRemoveBuff(buffID)
            shouldReserveScript = true
        end
    end

    if shouldReserveScript then
        ReserveScript("EASYBUFF_FOODCLEAR()", 0.3)
    else
        ui.SysMsg("{#FF0000}food buffs have disappeared")
        return;
    end
end