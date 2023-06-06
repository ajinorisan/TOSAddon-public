local addonName = "AETHERGEM_MGR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

function AETHERGEM_MGR_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    CHAT_SYSTEM(addonNameLower .. " loaded")
    acutil.setupHook(AETHERGEM_MGR_GODDESS_MGR_SOCKET_INV_RBTN, "GODDESS_MGR_SOCKET_INV_RBTN")
    acutil.setupHook(AETHERGEM_MGR_GET_SLOT_PROP, "GET_SLOT_PROP")
    AETHERGEM_MGR_FRAME_INIT()

end

function AETHERGEM_MGR_TEST(icon)
    CHAT_SYTEM("test")
    local agm_liftIcon = ui.GetLiftIcon();
    CHAT_SYTEM("test1")
    local agm_iconInfo = agm_liftIcon:GetInfo();
    CHAT_SYTEM("test2")
    local item_obj = GetIES(agm_liftIcon:GetObject());
    CHAT_SYTEM("test3")
    local invItem = session.GetInvItemByGuid(itemIESID);
    CHAT_SYTEM("test4")
    local groupname = TryGetProp(item_obj, 'GroupName', 'None')
    CHAT_SYTEM("test5")
    local cls = TryGetProp(item_obj, 'ClassName', 'None')
    CHAT_SYTEM("test6")
    local name = TryGetProp(item_obj, 'Name', 'None')
    CHAT_SYTEM("test7")
    CHAT_SYTEM(agm_liftIcon)
    CHAT_SYTEM(agm_iconInfo)
    CHAT_SYTEM(item_obj)
    CHAT_SYTEM(invItem)
    CHAT_SYTEM(groupname)
    CHAT_SYTEM(cls)
    CHAT_SYTEM(name)
    print(agm_liftIcon)
    print(agm_iconInfo)
    print(item_obj)
    print(invItem)
    print(groupname)
    print(cls)
    print(name)
end

function AETHERGEM_MGR_GET_SLOT_PROP(slot)
    GET_SLOT_PROP_OLD(slot)
    AETHERGEM_MGR_TEST(icon)
end

function AETHERGEM_MGR_GODDESS_MGR_SOCKET_INV_RBTN(item_obj, slot, guid)
    GODDESS_MGR_SOCKET_INV_RBTN_OLD(item_obj, slot, guid)
    AETHERGEM_MGR_REMOVE_AETHERGEM()
end

function AETHERGEM_MGR_FRAME_INIT()
    local invframe = ui.GetFrame('inventory')
    local inventoryGbox = invframe:GetChild("inventoryGbox")

    -- ボタンの配置位置
    -- local buttonX = inventoryGbox:GetWidth() - 240
    -- local buttonY = inventoryGbox:GetHeight() - 610

    -- local eqbutton = inventoryGbox:CreateOrGetControl("button", "eqbutton", buttonX, buttonY, 50, 30)
    -- eqbutton:SetText("equip")

    local rmbuttonX = inventoryGbox:GetWidth() - 105
    local rmbuttonY = inventoryGbox:GetHeight() - 610

    local rmeqbutton = inventoryGbox:CreateOrGetControl("button", "rmeqbutton", rmbuttonX, rmbuttonY, 60, 30)
    rmeqbutton:SetText("AG_MGR")

    -- eqbutton:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_EQUIP_BUTTON_CLICK")
    rmeqbutton:SetEventScript(ui.LBUTTONUP, "AETHERGEM_MGR_REMOVEEQUIP_BUTTON_CLICK")

end
--[[
function AETHERGEM_MGR_EQUIP_BUTTON_CLICK()
    print("equipボタンがクリックされました")

end
]]
function AETHERGEM_MGR_REMOVE_AETHERGEM()
    -- CHAT_SYSTEM("TEST")
    local eqpframe = ui.GetFrame("inventory")

    local gemframe = ui.GetFrame("goddess_equip_manager")
    local am_socket = GET_CHILD_RECURSIVELY(gemframe, "socket_slot")

    local am_aether_inner_bg = GET_CHILD_RECURSIVELY(gemframe, 'aether_inner_bg')

    local am_ctrlset = GET_CHILD(am_aether_inner_bg, 'AETHER_CSET_0')
    local am_aether_cover_bg = GET_CHILD_RECURSIVELY(gemframe, 'aether_cover_bg')

    if am_aether_cover_bg:IsVisible() == 1 then
        return;

    end

    local am_gem_slot = GET_CHILD(am_ctrlset, 'gem_slot', "ui::CSlot")
    -- local am_gem_name = GET_CHILD(am_ctrlset, 'socket_name', "ui::CRichText")
    -- CHAT_SYSTEM(am_gem_name:GetText())
    local am_do_remove = GET_CHILD(am_ctrlset, "do_remove")
    local isClickable = am_do_remove:IsEnable()
    if isClickable == 1 then
        local am_guid = am_socket:GetUserValue('ITEM_GUID')
        local am_tx_name = 'GODDESS_SOCKET_AETHER_GEM_UNEQUIP'
        local am_index = 2

        pc.ReqExecuteTx_Item(am_tx_name, am_guid, am_index)
        -- CHAT_SYSTEM("押せる")
    else
        local invTab = GET_CHILD_RECURSIVELY(eqpframe, "inventype_Tab")
        invTab:SelectTab(6)
        -- CHAT_SYSTEM("押せない")
    end

end

function AETHERGEM_MGR_REMOVEEQUIP_BUTTON_CLICK()
    -- print("rmequipボタンがクリックされました")
    local frame = ui.GetFrame('goddess_equip_manager')
    AETHERGEM_MGR_GODDESS_EQUIP_MANAGER_OPEN(frame)
end

function AETHERGEM_MGR_GODDESS_EQUIP_MANAGER_OPEN(frame)
    if TUTORIAL_CLEAR_CHECK(GetMyPCObject()) == false then
        ui.SysMsg(ClMsg('CanUseAfterTutorialClear'))
        frame:ShowWindow(0)
        return
    end

    ui.CloseFrame('rareoption')
    ui.CloseFrame('item_cabinet')
    for i = 1, #revertrandomitemlist do
        local revert_name = revertrandomitemlist[i]
        local revert_frame = ui.GetFrame(revert_name)
        if revert_frame ~= nil and revert_frame:IsVisible() == 1 then
            ui.CloseFrame(revert_name)
        end
    end

    ui.OpenFrame('goddess_equip_manager')
    local main_tab = GET_CHILD_RECURSIVELY(frame, 'main_tab')
    main_tab:SelectTab(2)
    CLEAR_GODDESS_EQUIP_MANAGER(frame)
    GODDESS_MGR_SOCKET_OPEN(frame)
    AETHERGEM_MGR_UNEQUIP()
end

function AETHERGEM_MGR_UNEQUIP()
    local eqpframe = ui.GetFrame("inventory")

    if true == BEING_TRADING_STATE() then
        return;
    end

    local isEmptySlot = false;

    local invItemList = session.GetInvItemList();
    local itemCount = session.GetInvItemList():Count();

    if session.GetInvItemList():Count() < MAX_INV_COUNT then
        isEmptySlot = true;
    end

    local RH = GET_CHILD_RECURSIVELY(eqpframe, "RH")
    local LH = GET_CHILD_RECURSIVELY(eqpframe, "LH")
    local RH_SUB = GET_CHILD_RECURSIVELY(eqpframe, "RH_SUB")
    local LH_SUB = GET_CHILD_RECURSIVELY(eqpframe, "LH_SUB")

    if isEmptySlot == true then

        if tonumber(USE_SUBWEAPON_SLOT) == 1 then
            DO_WEAPON_SLOT_CHANGE(eqpframe, 1)
        else
            DO_WEAPON_SWAP(eqpframe, 1)
        end

        local rh_icon = RH:GetIcon()

        local lh_icon = LH:GetIcon()

        local rh_sub_icon = RH_SUB:GetIcon()

        local lh_sub_icon = LH_SUB:GetIcon()

        if rh_sub_icon ~= nil then
            local rhlh_sub = 30

            local rh_sub_icon_info = rh_sub_icon:GetInfo()
            local rh_sub_iesid = rh_sub_icon_info:GetIESID()
            print(rh_sub_iesid)

            local lh_sub_icon_info = lh_sub_icon:GetInfo()
            local lh_sub_iesid = lh_sub_icon_info:GetIESID()
            print(lh_sub_iesid)

            imcSound.PlaySoundEvent('inven_unequip');
            item.UnEquip(tonumber(rhlh_sub));
            -- AETHERGEM_MGR_REMOVE_AETHERGEM(eqpframe, guid)

            ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.5)
        elseif lh_icon ~= nil then
            local lh = 9

            local lh_icon_info = lh_icon:GetInfo()
            local lh_iesid = lh_icon_info:GetIESID()
            print(lh_iesid)

            imcSound.PlaySoundEvent('inven_unequip');
            item.UnEquip(tonumber(lh));
            ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.5)
        elseif rh_icon ~= nil then
            local rh = 8

            local rh_icon_info = rh_icon:GetInfo()
            local rh_iesid = rh_icon_info:GetIESID()
            print(rh_iesid)

            imcSound.PlaySoundEvent('inven_unequip');
            item.UnEquip(tonumber(rh));

            ReserveScript("AETHERGEM_MGR_UNEQUIP()", 0.5)
        else
            local invTab = GET_CHILD_RECURSIVELY(eqpframe, "inventype_Tab")
            invTab:SelectTab(1)
            -- local WEAPON_bg = GET_CHILD_RECURSIVELY(eqpframe, "WEAPON_bg")
            AETHERGEM_MGR_REMOVE_AETHERGEM(eqpframe)
            return
        end

    else
        ui.SysMsg(ScpArgMsg("Auto_inBenToLie_Bin_SeulLosi_PilyoHapNiDa."))
    end

end

--[[
    function GET_AETHER_GEM_TOOLTIP(obj, prop_name_list, guid)
	if obj == nil then return; end
	if obj.GroupName ~= "Gem_High_Color" then return; end	

	local level = 1;
		local equip_item = session.GetEquipItemByGuid(guid);
		if equip_item ~= nil then
			local item_object = GetIES(equip_item:GetObject());
			local item_grade = TryGetProp(item_object, "ItemGrade", 0);
			if item_grade == 6 then
				local start_index, end_index = GET_AETHER_GEM_INDEX_RANGE(TryGetProp(item_object, 'UseLv', 0))	
				for i = start_index, end_index do
					if equip_item:IsAvailableSocket(i) == true then
						local gem_class_id = equip_item:GetEquipGemID(i);
						if gem_class_id ~= 0 and gem_class_id == obj.ClassID then
							local gem_class = GetClassByType("Item", gem_class_id);
							if gem_class ~= nil then
								local group_name = TryGetProp(gem_class, "GroupName", "None");
								if group_name == "Gem_High_Color" then
									level = equip_item:GetEquipGemLv(i);
								end
							end
						end
					end
				end
			end
	else
		local info, where = GET_INV_ITEM_BY_ITEM_OBJ(obj);
		if where == "inventory" and tonumber(info:GetIESID()) ~= 0 then
			level = get_current_aether_gem_level(obj);
		elseif where == "inventory" and tonumber(info:GetIESID()) == 0 then
			level = 1;
		end
	end

	local gem_class = GetClassByType("Item", obj.ClassID);
	if gem_class ~= nil then
		local string_arg = TryGetProp(gem_class, "StringArg");
		local get_func_str = "get_aether_gem_"..string_arg.."_prop";
		local func = _G[get_func_str];
		for i = 0, ITEM_SOCKET_PROPERTY_TYPE_COUNT - 1 do
			local socket_type = geItemTable.GetSocketPropertyTypeStr(i);
			if socket_type ~= "Helmet" and socket_type ~= "Armband" and socket_type ~= "ShirtsOrPants" and socket_type ~= "HandOrFoot" then
				local lang_type = "WhenEquipTo"..socket_type;
				prop_name_list[#prop_name_list + 1] = {};
				prop_name_list[#prop_name_list]["Title"] = lang_type;
				local add_count = 1;
				for j = 0, add_count - 1 do
					local prop_name, prop_value, use_operator = func(level);
					prop_name_list[#prop_name_list + 1] = {};
					prop_name_list[#prop_name_list]["PropName"] = prop_name;
					prop_name_list[#prop_name_list]["PropValue"] = prop_value;
					prop_name_list[#prop_name_list]["UseOperator"] = use_operator;
				end
			end
		end
	end
end
    local gemframe = ui.GetFrame("goddess_equip_manager")
    -- local gbox_Equipped = GET_CHILD_RECURSIVELY(eqpframe, "gbox_Equipped")
    -- local equipItemList = session.GetEquipItemList()

    -- for i = 0, equipItemList:Count() - 1 do
    -- local equipItem = equipItemList:GetEquipItemByIndex(i)
    -- local spname = item.GetEquipSpotName(equipItem.equipSpot)
    -- if spname == "RH" then
    -- local slot = GET_CHILD_RECURSIVELY(gbox_Equipped, spname, "ui::CSlot")
    -- if slot ~= nil then

    -- local item = equipItem:GetObject()
    -- if item ~= nil then
    -- CHAT_SYSTEM("true2")

    local socket_slot = GET_CHILD_RECURSIVELY(gemframe, "socket_slot", "ui::CSlot")
    
    local equipItemList = session.GetEquipItemList()
    for i = 0, equipItemList:Count() - 1 do
        local equipItem = equipItemList:GetEquipItemByIndex(i)
        local spname = item.GetEquipSpotName(equipItem.equipSpot)
        if spname == "RH" then
            CHAT_SYSTEM("true")
            local slot = GET_CHILD_RECURSIVELY(gbox_Equipped, spname, "ui::CSlot")
            local slot_bg = GET_CHILD_RECURSIVELY(gbox_Equipped, spname .. "_bg", "ui::CSlot")
            slot:ClearIcon()
            slot:SetMaxSelectCount(0)
            slot:SetText('')
            slot:RemoveAllChild()
            slot:SetSkinName(slot_bg:GetSkinName())
            slot:SetUserValue('clsid', nil)
            slot:SetUserValue('iesid', nil)

            -- アイコンをsocket_slotにセット
            local icon = slot:GetIcon()
            if icon ~= nil then
                local iconInfo = icon:GetInfo()
                socket_slot:SetIcon(iconInfo:GetImageName())
                socket_slot:SetTooltipType(iconInfo:GetTooltipType())
                socket_slot:SetTooltipArg(iconInfo:GetTooltipNumArg())
                socket_slot:SetTooltipIESID(iconInfo:GetTooltipIESID())
            end

            socket_slot:SetUserValue("clsid", tostring(GetIES(equipItem:GetObject()).ClassID))
            socket_slot:SetUserValue("iesid", tostring(equipItem:GetIESID()))
        end
    end
    
end
]]
--[[otehon
function AWWARDROBE_CLEAREQUIP(frame, spname)
    --現在の装備を登録
    AWWARDROBE_try(function()
        local gbox = frame:GetChildRecursively("equip")
        local slot = GET_CHILD_RECURSIVELY(gbox, spname, "ui::CSlot")
        local slot_bg = GET_CHILD_RECURSIVELY(gbox, spname .. "_bg", "ui::CSlot")
        
        slot:ClearIcon()
        slot:SetMaxSelectCount(0)
        slot:SetText('')
        slot:RemoveAllChild()
        slot:SetSkinName(slot_bg:GetSkinName())
        slot:SetUserValue('clsid', nil)
        slot:SetUserValue('iesid', nil)
    
    end)
end

TOS側コード発見　status.lua
function STATUS_SLOT_RBTNDOWN(frame, slot, argStr, equipSpot)
    frame = frame:GetTopParentFrame()
    if true == BEING_TRADING_STATE() then
        return;
    end

    local isEmptySlot = false;

    local invItemList = session.GetInvItemList();    
    local itemCount = session.GetInvItemList():Count();

    if session.GetInvItemList():Count() < MAX_INV_COUNT then
        isEmptySlot = true;
    end

    if isEmptySlot == true then
        imcSound.PlaySoundEvent('inven_unequip');
        local spot = equipSpot;
        item.UnEquip(spot);
    else
        ui.SysMsg(ScpArgMsg("Auto_inBenToLie_Bin_SeulLosi_PilyoHapNiDa."));

    end
end
]]
