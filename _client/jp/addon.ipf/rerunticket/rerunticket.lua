local CurrentCatrgory = "None";
local TicketName = "None"

function RERUNTICKET_ON_INIT(addon,frame)
    addon:RegisterMsg('RERUN_TICEKT', 'ON_RERUN_TICEKT');

end

function OPEN_UI_RERUN_TICKET(item_obj)
    local item = GetIES(item_obj:GetObject())	
    local guid = item_obj:GetIESID();
    local Category = TryGetProp(item , "StringArg", "None")
    CurrentCatrgory = Category;
    TicketName = item.Name;

    ui.OpenFrame("rerunticket")
    local frame = ui.GetFrame("rerunticket")
    CRAETE_RERUN_TICKET_ITEM_LIST(frame, item_obj)
    SET_RERUN_TICKET_TITLE(frame, item_obj)
end

function OPEN_RERUN_TICKET(frame)
    
end

function SET_RERUN_TICKET_TITLE(frame, ticket)
    local mainTitle = GET_CHILD_RECURSIVELY(frame, "mainTitle")
    local ticket_item = GetIES(ticket:GetObject())	
    local ticket_Name = ticket_item.Name;
    mainTitle:SetTextByKey("group", ticket_Name);
end

function CRAETE_RERUN_TICKET_ITEM_LIST(frame, ticket)
    local itembox = GET_CHILD_RECURSIVELY(frame, "itembox") 
	itembox:SetScrollPos(0);
    itembox:InvalidateScrollBar();

    itembox:RemoveAllChild();

    local list, cnt = GetClassList("rerunticket");
    local row = 0;
    local col = 0;
    local maxrow = 2;
    local offset = {286,350};
    local guid = ticket:GetIESID();
    local ticket_item = GetIES(ticket:GetObject())	

    for i = 0, cnt - 1 do
        local iteminfocls = GetClassByIndexFromList(list, i);
        local Category = TryGetProp(iteminfocls, "Category", "None")
        local itemClassName = TryGetProp(iteminfocls, "ClassName", "Name")
        if Category == CurrentCatrgory then
            local ctrl = itembox:CreateControlSet("rerunticket_item",itemClassName, row * offset[1] + 15, col * offset[2]);
            if ctrl then
                local lv = GETMYPCLEVEL();
                local job = GETMYPCJOB();            
                local gender = GETMYPCGENDER();

                local itemobj = GetClass("Item", itemClassName);
                local itemName = itemobj.Name;
                local slot = GET_CHILD(ctrl, "icon");
                local title = GET_CHILD(ctrl, "title")
                local btn = GET_CHILD(ctrl, "buyBtn")
                local desc = GET_CHILD_RECURSIVELY(ctrl,"desc")

                local itemclsID = itemobj.ClassID;
                
                SET_SLOT_IMG(slot, GET_ITEM_ICON_IMAGE(itemobj));
                        
                local icon = slot:GetIcon();
                icon:SetTooltipType('wholeitem');
                icon:SetTooltipArg('', itemclsID, 0);
            
                btn:SetEventScriptArgString(ui.LBUTTONUP, guid);
                btn:SetEventScriptArgNumber(ui.LBUTTONUP, itemclsID);

                local sucValue = string.format("{@st41b}%s", itemName);
                title:SetText(sucValue);
        

                local prop = geItemTable.GetProp(itemclsID);
                local result = prop:CheckEquip(lv, job, gender);
            
                -- desc
                if result == "OK" then
                    desc:SetText(GET_USEJOB_TOOLTIP(itemobj))
                else
                    desc:SetText("{#990000}"..GET_USEJOB_TOOLTIP(itemobj).."{/}")
                end
            
                row = row + 1;
                if row > maxrow then
                    col = col + 1;
                    row = 0;
                end
            end
        end
    end
end

function RERUN_TICKET_SELECT_ITEM(parent, ctrl, guid, clsid)
	local item = GetClassByType("Item", clsid)
	if not item  then
		return false;
	end 
    local invItem = session.GetInvItemByGuid(guid)
    if not invItem then
        return; 
    end
    local object = GetIES(invItem:GetObject());
    if not object then
        return;
    end
    ui.MsgBox(ScpArgMsg("ReallyBuy?{TICKET}{SELECT}", "TICKET", object.Name, "SELECT", item.Name), string.format("RERUTN_TICKET_BUY('%s', %d)", guid, clsid), "None");
end

function RERUTN_TICKET_BUY(guid, clsid)
    pc.ReqExecuteTx_Item("RERUN_TICKET_USE", guid, clsid)
    -- clsid
end

function ON_RERUN_TICEKT(frame)
    ui.CloseFrame("rerunticket")
end