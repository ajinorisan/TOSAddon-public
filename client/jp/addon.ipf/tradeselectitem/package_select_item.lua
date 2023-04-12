

function OPEN_TRADE_SELECT_JAGUAR_PACKAGE_WEAPON(invItem)
	local frame = ui.GetFrame("tradeselectitem")
	frame:SetTitleName('{@st43}{s22}' ..ScpArgMsg('JaguarPackageSelectWeapon'))
	local box = frame:GetChild('box');
	tolua.cast(box, "ui::CGroupBox");
	box:DeleteAllControl();
	local y = 5;
	
	local itemGuid = invItem:GetIESID();
	local itemObj = GetObjectByGuid(itemGuid)


	local item_list = {'EP14_RAID_SWORD', 'EP14_RAID_DAGGER', 'EP14_RAID_PISTOL', 'EP14_RAID_SHIELD'}

	for i = 1, #item_list do
		local Cls = GetClass('Item', item_list[i])
		if Cls ~= nil then			
			y = CREATE_QUEST_REWARE_CTRL_JOB(box, y, i, Cls);	
			y = y + 5
		end
	end

	local cancelBtn = frame:GetChild('CancelBtn');
	local useBtn = frame:GetChild('UseBtn');
	useBtn:SetEventScript(ui.LBUTTONUP,'REQUEST_TRADE_SELECT_JAGUAR_PACKAGE_WEAPON')

	box:Resize(box:GetOriginalWidth(), y);	    
	local screen_height = option.GetClientHeight();
	local maxSizeHeightFrame = box:GetY() + box:GetHeight() + 20;
	local maxSizeHeightWnd = ui.GetSceneHeight();
    
    if maxSizeHeightWnd >= 950 then        
        maxSizeHeightWnd = 950
    
        if maxSizeHeightWnd > screen_height then
            maxSizeHeightWnd = screen_height * 0.8
        end
    end
    
    if maxSizeHeightFrame >= maxSizeHeightWnd then
        maxSizeHeightFrame = maxSizeHeightWnd
    end
       
	if maxSizeHeightWnd < (maxSizeHeightFrame + 50) then                 
		local margin = maxSizeHeightWnd/2;
		box:EnableScrollBar(1);

		box:Resize(box:GetOriginalWidth(), margin - useBtn:GetHeight() - 40);
		box:SetScrollBar(0);
		box:InvalidateScrollBar();
		frame:Resize(frame:GetOriginalWidth(), margin + 100);
	else
		box:SetCurLine(0) 
		
		box:Resize(box:GetOriginalWidth(), y);
		frame:Resize(frame:GetOriginalWidth(), maxSizeHeightFrame);
	end;
	box:SetScrollPos(0);
	
	local NeedItemSlot = frame:GetChild('NeedItemSlot')
	local NeedItemName = frame:GetChild('NeedItemName')
	NeedItemName:SetVisible(0)
	NeedItemSlot:SetVisible(0)

	frame:SetUserValue("UseItemGuid", itemGuid);
	frame:ShowWindow(1);
end


function REQUEST_TRADE_SELECT_JAGUAR_PACKAGE_WEAPON(frame)    
	local box = frame:GetChild('box')
	tolua.cast(box, "ui::CGroupBox")

	local selectExist = 0
	local selected = 0
	local select_job = 0

	local cnt = box:GetChildCount()
	for i = 0 , cnt - 1 do
		local ctrlSet = box:GetChildByIndex(i)
		local name = ctrlSet:GetName()		
		if string.find(name, "REWARD_") ~= nil then
			tolua.cast(ctrlSet, "ui::CControlSet")
			if ctrlSet:IsSelected() == 1 then				
				selected = ctrlSet:GetValue();				

			end
			selectExist = 1
		end
	end

	if selectExist == 1 and selected == 0 then
		ui.MsgBox(ScpArgMsg("Auto_BoSangeul_SeonTaegHaeJuSeyo."))
		return
	end
	
	if selected ~= 0 then
		local itemGuid = frame:GetUserValue("UseItemGuid")
		local yesScp = string.format("REQUEST_TRADE_SELECT_JAGUAR_PACKAGE_WEAPON_WARNINGYES(\"%s\", \"%s\")", itemGuid, selected)
		ui.MsgBox(ScpArgMsg('SelectEquipment{ITEM}','ITEM', '+15 ' .. GetClassByType('Item', selected).Name) , yesScp, 'None')
	end

	frame = frame:GetTopParentFrame()
	frame:ShowWindow(0)
end


function REQUEST_TRADE_SELECT_JAGUAR_PACKAGE_WEAPON_WARNINGYES(itemGuid, type)
	local frame = ui.GetFrame("tradeselectitem")
	itemGuid = frame:GetUserValue("UseItemGuid")	
    pc.ReqExecuteTx_Item("GIVE_WEAPON_JAGUAR", itemGuid, type)
end
