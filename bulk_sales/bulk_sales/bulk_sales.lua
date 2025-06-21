-- v1.0.0 公開
-- v1.0.1 ユラテコインショップでも売れる様に
local addon_name = "BULK_SALES"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

function g.mkdir_new_folder()
    local function create_folder(folder_path, file_path)
        local file = io.open(file_path, "r")
        if not file then
            os.execute('mkdir "' .. folder_path .. '"')
            file = io.open(file_path, "w")
            if file then
                file:write("A new file has been created")
                file:close()
            end
        else
            file:close()
        end
    end
    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(folder, file_path)

    local active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, active_id)
    create_folder(user_folder, user_file_path)
end
g.mkdir_new_folder()

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)

    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end

    local origin_func = g.FUNCS[origin_func_name]

    local function hooked_function(...)

        local original_results

        if bool == true then
            original_results = {origin_func(...)}
        end

        g.ARGS = g.ARGS or {}
        g.ARGS[origin_func_name] = {...}
        imcAddOn.BroadMsg(origin_func_name)

        if original_results then
            return table.unpack(original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function

    if not g.REGISTER[origin_func_name .. my_func_name] then -- g.REGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name .. my_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function g.save_json(path, tbl)

    local file = io.open(path, "w")
    local str = json.encode(tbl)
    file:write(str)
    file:close()
end

function g.load_json(path)

    local file = io.open(path, "r")

    if file then
        local content = file:read("*all")
        file:close()
        local table = json.decode(content)
        return table
    else
        return nil
    end
end

function g.save_settings()
    g.save_json(g.settings_path, g.settings)
end

function g.load_settings()

    local settings = g.load_json(g.settings_path)

    if not settings then
        settings = {}
    end

    g.settings = settings
    g.save_settings()
end

function BULK_SALES_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()
    g.login_name = session.GetMySession():GetPCApc():GetName()

    addon:RegisterMsg('DIALOG_CLOSE', 'bulk_sales_SHOP_ON_MSG');

    g.REGISTER = {}
    g.setup_hook_and_event(addon, "SHOP_UI_CLOSE", "bulk_sales_SHOP_UI_CLOSE", true)
    -- SHOP_UI_CLOSE
end

function bulk_sales_SHOP_UI_CLOSE(frame, msgstr, num)
    local frame = ui.GetFrame("bulk_sales")
    if frame:IsVisible() == 1 then
        local shop_frame = ui.GetFrame('shop');
        local check = GET_CHILD_RECURSIVELY(shop_frame, "check")
        if check then
            check:SetCheck(0)
        end
        frame:ShowWindow(0)
    end
end

function bulk_sales_SHOP_ON_MSG(frame, msg, str, num)

    if str ~= "Klapeda_Misc" and str ~= "Orsha_Misc" and str ~= "Fedimian_Misc" and
        not string.find(str, "CertificateCoin_Shop") then

        return

    else

        bulk_sales_check_box(str)
        local shop_frame = ui.GetFrame('shop');
        if shop_frame:IsVisible() == 0 then
            local frame = ui.GetFrame("bulk_sales")
            frame:ShowWindow(0)
            local check = GET_CHILD_RECURSIVELY(shop_frame, "check")
            if check then
                check:SetCheck(0)
            end
            return
        else
            local check = GET_CHILD_RECURSIVELY(shop_frame, "check")
            check:ShowWindow(1)
        end

    end

end

function bulk_sales_check_box(str)
    local shop_frame = ui.GetFrame('shop');
    local check = shop_frame:CreateOrGetControl("checkbox", "check", 40, 70, 20, 20)

    AUTO_CAST(check)
    check:SetText("{ol}Slot open for bulk sales")
    check:SetEventScript(ui.LBUTTONDOWN, "bulk_sales_slotset")

end

function bulk_sales_inv_rbtn(item_obj, slot)
    local icon = slot:GetIcon()
    local icon_info = icon:GetInfo()

    local clsid = icon_info.type
    local inv_item = session.GetInvItemByType(clsid)

    local item_obj = GetIES(inv_item:GetObject());
    local itemProp = geItemTable.GetPropByName(item_obj.ClassName);

    if itemProp:IsEnableShopTrade() == false then
        ui.SysMsg(ClMsg("CannoTradeToNPC"));
        return;
    end

    if item_obj.MarketCategory == "Housing_Furniture" or item_obj.MarketCategory == "PHousing_Furniture" or
        item_obj.MarketCategory == "PHousing_Wall" or item_obj.MarketCategory == "PHousing_Carpet" then
        ui.SysMsg(ClMsg("Housing_Cant_Sell_This_Item"));
        return;
    end

    local inv_item_list = session.GetInvItemList()
    local inv_guid_list = inv_item_list:GetGuidList()
    local count = inv_guid_list:Count()

    local frame = ui.GetFrame("bulk_sales")
    local sellprice = 0

    for i = 0, count - 1 do
        local guid = inv_guid_list:Get(i)
        local inv_item = inv_item_list:GetItemByGuid(guid)

        if true ~= inv_item.isLockState then
            -- ui.SysMsg(ClMsg("MaterialItemIsLock"));

            local inv_obj = GetIES(inv_item:GetObject())
            local inv_clsid = inv_obj.ClassID
            local inv_item_count = inv_item.count

            if clsid == inv_clsid and not g.temp_tbl[tostring(guid)] then
                g.temp_tbl[tostring(guid)] = inv_item_count
                local slot_set = GET_CHILD_RECURSIVELY(frame, "slotset")
                local slot_count = slot_set:GetSlotCount()

                for i = 1, slot_count do
                    local new_slot = GET_CHILD_RECURSIVELY(slot_set, "slot" .. i)

                    local new_icon = new_slot:GetIcon()
                    if not new_icon then

                        local item_cls = GetClassByType("Item", clsid)
                        local itemProp = geItemTable.GetPropByName(item_cls.ClassName);
                        local item_price = geItemTable.GetSellPrice(itemProp) * inv_item_count
                        g.sell_price = g.sell_price + item_price
                        -- slot:SetUserValue("CLASS_ID", clsid)
                        -- slot:SetUserValue("ITEM_COUNT", inv_item_count)
                        new_slot:SetEventScript(ui.RBUTTONDOWN, "bulk_sales_slot_cancel")
                        new_slot:SetEventScriptArgString(ui.RBUTTONDOWN, guid)
                        new_slot:SetEventScriptArgNumber(ui.RBUTTONDOWN, item_price)
                        SET_SLOT_ITEM_CLS(new_slot, item_cls)
                        SET_SLOT_ITEM_TEXT(new_slot, inv_item, item_cls)
                        local item_slot = INV_GET_SLOT_BY_ITEMGUID(guid)
                        item_slot:SetSelectedImage('socket_slot_check')
                        item_slot:Select(1)

                        break
                    end
                end
            end
        end
    end
    local sales_amount = GET_CHILD_RECURSIVELY(frame, "sales_amount")
    AUTO_CAST(sales_amount)
    sales_amount:SetText("{@st41b}{#FFA500}" .. GET_COMMAED_STRING(g.sell_price))
end

function bulk_sales_slot_cancel(frame, ctrl, guid, item_price)

    local inventory = ui.GetFrame("inventory")
    local item_slot = INV_GET_SLOT_BY_ITEMGUID(guid);

    if item_slot then
        item_slot:Select(0)
        --[[local invItem = GET_PC_ITEM_BY_GUID(guid);
        INV_SLOT_UPDATE(inventory, invItem, itemSlot)
       
        local itemSlot_All = INV_GET_SLOT_BY_ITEMGUID(guid, nil, 1)
        if itemSlot_All ~= nil then
            local invItem_All = GET_PC_ITEM_BY_GUID(guid)
            INV_SLOT_UPDATE(inventory, invItem_All, itemSlot_All)
        end]]
        inventory:Invalidate();

    end

    local frame = ui.GetFrame("bulk_sales")
    local sellprice = 0

    g.temp_tbl[tostring(guid)] = false
    g.sell_price = g.sell_price - item_price
    local frame = ui.GetFrame("bulk_sales")
    local sales_amount = GET_CHILD_RECURSIVELY(frame, "sales_amount")
    AUTO_CAST(sales_amount)
    sales_amount:SetText("{@st41b}{#FFA500}" .. GET_COMMAED_STRING(g.sell_price))

    ctrl:ClearText();
    ctrl:ClearIcon();

end

function bulk_sales_sell_execution_reserve(frame, ctrl, str, num)

    local yes_scp = string.format("bulk_sales_sell_execution()")
    ui.MsgBox("Do you sell?", yes_scp, "None");

end

function bulk_sales_sell_execution()

    local frame = ui.GetFrame("bulk_sales")
    local slot_set = GET_CHILD_RECURSIVELY(frame, "slotset")
    AUTO_CAST(slot_set)
    local slot_count = slot_set:GetSlotCount()

    for guid, count in pairs(g.temp_tbl) do

        item.AddToSellList(guid, count);

    end
    item.SellList();
    slot_set:ClearIconAll();

    local shop_frame = ui.GetFrame('shop');
    local check = GET_CHILD_RECURSIVELY(shop_frame, "check")
    bulk_sales_slotset(shop_frame, check)

end

function bulk_sales_slotset(frame, ctrl, str, num)
    local frame = ui.GetFrame("bulk_sales")
    local is_check = ctrl:IsChecked()

    local shop_frame = ui.GetFrame('shop');

    if is_check == 0 then
        frame:ShowWindow(0)
        SHOP_UI_CLOSE(shop_frame)
        return
    end

    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(80)
    frame:SetTitleBarSkin("None")
    frame:RemoveAllChild()

    local gbox = frame:CreateOrGetControl("groupbox", 'gbox', 0, 5, 0, 0)
    AUTO_CAST(gbox)
    gbox:SetSkinName("None")

    local slotset = gbox:CreateOrGetControl('slotset', 'slotset', 10, 10, 0, 0)
    AUTO_CAST(slotset);
    slotset:EnablePop(1)
    slotset:EnableDrag(1)
    slotset:EnableDrop(1)
    slotset:EnableHitTest(1);
    slotset:SetColRow(15, 200)
    slotset:SetSlotSize(35, 35)
    slotset:SetSpc(1, 1)
    slotset:SetSkinName('invenslot2')
    slotset:CreateSlots()

    local sell_btn = frame:CreateOrGetControl("button", "sell_btn", 0, 0, 120, 50)
    AUTO_CAST(sell_btn)
    sell_btn:SetSkinName("test_red_button")
    sell_btn:SetEventScript(ui.LBUTTONDOWN, "bulk_sales_sell_execution_reserve")
    sell_btn:SetPos(slotset:GetWidth() - 115, 790)
    sell_btn:SetText("{@st41b}SELL{/}")

    local amount = frame:CreateOrGetControl("richtext", "amount", 0, 0, 120, 50)
    AUTO_CAST(amount)
    amount:SetPos(30, 790)
    amount:SetText("{@st41b}Sales Amount ▶{/}")

    local sales_amount = frame:CreateOrGetControl("richtext", "sales_amount", 0, 0, 120, 50)
    AUTO_CAST(sales_amount)
    sales_amount:SetPos(200, 790)
    sales_amount:SetText("{@st41b}{#FFA500}0{/}")

    local shop_frame = ui.GetFrame('shop');
    frame:Resize(slotset:GetWidth() + 35, 850)
    gbox:Resize(frame:GetWidth(), frame:GetHeight() - 84)
    gbox:SetScrollPos(0)
    frame:SetPos(shop_frame:GetWidth() + 5, 5)

    frame:ShowWindow(1)
    g.sell_price = 0
    g.temp_tbl = {}
    INVENTORY_SET_CUSTOM_RBTNDOWN("bulk_sales_inv_rbtn")

end
