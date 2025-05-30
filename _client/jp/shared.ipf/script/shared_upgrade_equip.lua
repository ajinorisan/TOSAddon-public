-- shared_upgrade_equip.lua


-- ClassType {BELT, SHOULDER, ....}
shared_upgrade_equip = {}
local material_table = nil

local function make_shared_upgrade_equip_table()
    if material_table ~= nil then
        return
    end

    material_table = {}    

    for i = 1, 8 do
        material_table['EP16_penetration_belt_' .. i .. '_high'] = {}
        material_table['EP16_penetration_belt_' .. i .. '_high']['JurateCertificate'] = 5000
        material_table['EP16_penetration_belt_' .. i .. '_high']['misc_BlessedStone_1'] = 2
        material_table['EP16_penetration_belt_' .. i .. '_high']['misc_ore28'] = 300

        material_table['NoTrade_EP16_penetration_belt_' .. i .. '_high'] = {}
        material_table['NoTrade_EP16_penetration_belt_' .. i .. '_high']['JurateCertificate'] = 5000
        material_table['NoTrade_EP16_penetration_belt_' .. i .. '_high']['misc_BlessedStone_1'] = 2
        material_table['NoTrade_EP16_penetration_belt_' .. i .. '_high']['misc_ore28'] = 300
    end

    for i = 1, 6 do
        material_table['EP16_fierce_shoulder_' .. i .. '_high'] = {}
        material_table['EP16_fierce_shoulder_' .. i .. '_high']['JurateCertificate'] = 5000
        material_table['EP16_fierce_shoulder_' .. i .. '_high']['misc_BlessedStone_1'] = 2
        material_table['EP16_fierce_shoulder_' .. i .. '_high']['misc_ore28'] = 300

        material_table['NoTrade_EP16_fierce_shoulder_' .. i .. '_high'] = {}
        material_table['NoTrade_EP16_fierce_shoulder_' .. i .. '_high']['JurateCertificate'] = 5000
        material_table['NoTrade_EP16_fierce_shoulder_' .. i .. '_high']['misc_BlessedStone_1'] = 2
        material_table['NoTrade_EP16_fierce_shoulder_' .. i .. '_high']['misc_ore28'] = 300
    end

    local item_list = {
                        "EP16_RAID_SWORD",
                        "EP16_RAID_THSWORD",
                        "EP16_RAID_STAFF",
                        "EP16_RAID_THBOW",
                        "EP16_RAID_BOW",
                        "EP16_RAID_MACE",
                        "EP16_RAID_THMACE",
                        "EP16_RAID_SHIELD",
                        "EP16_RAID_SPEAR",
                        "EP16_RAID_THSPEAR",
                        "EP16_RAID_DAGGER",
                        "EP16_RAID_THSTAFF",
                        "EP16_RAID_PISTOL",
                        "EP16_RAID_RAPIER",
                        "EP16_RAID_CANNON",
                        "EP16_RAID_MUSKET",
                        "EP16_RAID_TRINKET",
                        "EP16_RAID_CLOTH_TOP",
                        "EP16_RAID_CLOTH_LEG",
                        "EP16_RAID_CLOTH_FOOT",
                        "EP16_RAID_CLOTH_HAND",
                        "EP16_RAID_LEATHER_TOP",
                        "EP16_RAID_LEATHER_LEG",
                        "EP16_RAID_LEATHER_FOOT",
                        "EP16_RAID_LEATHER_HAND",
                        "EP16_RAID_PLATE_TOP",
                        "EP16_RAID_PLATE_LEG",
                        "EP16_RAID_PLATE_FOOT",
                        "EP16_RAID_PLATE_HAND"
                    }   
                    
    for i = 1, #item_list do
        local name = item_list[i]
        material_table[name] = {}
        material_table[name]['JurateCertificate'] = 2000
        material_table[name]['misc_BlessedStone_1'] = 1
        material_table[name]['misc_ore28'] = 100
    end

    
end

make_shared_upgrade_equip_table()

shared_upgrade_equip.is_valid_item = function(item)
    if TryGetProp(item, 'UpgradeRank', 0) >= 20 then
        return false, 'AlreadyMaxGrade'
    end

    if TryGetProp(item, 'EnableUpgrade', 'None') ~= 'YES' then
        return false, 'NotValidItem'
    end
    
    local class_type = TryGetProp(item, 'ClassType', 'None')
    if class_type == 'Neck' or class_type == 'Ring' then
        return false, 'NotValidItem'
    end

    local GroupName = TryGetProp(item, 'GroupName', 'None')
    if GroupName == 'BELT' or GroupName == 'SHOULDER' then
        return true, 'None'
    end

    if TryGetProp(item, 'Reinforce_2', 0) < 25 then
        return false, 'Need25Reinforcement'
    end

    return true
end

shared_upgrade_equip.get_cost = function(item)
    local name = TryGetProp(item, 'ClassName', 'None')
    if material_table[name] == nil then
        return nil
    end

    return material_table[name]
end

shared_upgrade_equip.get_value = function(item, _rank)
    local ret = {}

    local use_lv = TryGetProp(item, 'UseLv', 0)    
    if use_lv >= 510 and use_lv <= 530 then
        local rank = TryGetProp(item, 'UpgradeRank', 0)
        if _rank ~= nil then
            rank = _rank
        end

        local value = rank * 5 
        table.insert(ret, {'ALLSTAT', value})
        return ret
    elseif use_lv >= 540 and use_lv <= 560 then
        
    end

    table.insert(ret, {'None', 0})
    return ret
end



------------------------------------------------------------------------------------------------------------------------------------------

function TOOLTIP_UPGRADE_BELT_510(invitem, property_gbox, inner_yPos)
    local grade = TryGetProp(invitem, 'UpgradeRank', 0)
    if grade > 0 then
        local ret = shared_upgrade_equip.get_value(invitem, grade)
        local desc = ClMsg(ret[1][1])		
		local strInfo = string.format("%s : {@st42_red}%d{/} / 20 - %s "..ScpArgMsg("PropUp").."%d", ClMsg('Grade'), grade, desc, ret[1][2]);
		
		local cnt = property_gbox:GetChildCount();
		local ControlSetObj	= property_gbox:CreateControlSet('tooltip_item_prop_richtxt', "ITEM_PROP_" .. cnt , 0, inner_yPos);
		local ControlSetCtrl = tolua.cast(ControlSetObj, 'ui::CControlSet');
		local richText = GET_CHILD(ControlSetCtrl, "text", "ui::CRichText");
		richText:SetTextByKey('text', strInfo);
		ControlSetCtrl:Resize(ControlSetCtrl:GetWidth(), richText:GetHeight());
		property_gbox:ShowWindow(1)
		property_gbox:Resize(property_gbox:GetWidth(),property_gbox:GetHeight() + ControlSetObj:GetHeight())

		inner_yPos = ControlSetCtrl:GetHeight() + ControlSetCtrl:GetY()
    end

    return inner_yPos
end

function TOOLTIP_UPGRADE_ACC_510(invitem, property_gbox, inner_yPos)
    local grade = TryGetProp(invitem, 'UpgradeRank', 0)
    if grade > 0 then        
		local strInfo = string.format("%s : {@st42_red}%d{/} / 20", ClMsg('Grade'), grade)
		
		local cnt = property_gbox:GetChildCount();
		local ControlSetObj	= property_gbox:CreateControlSet('tooltip_item_prop_richtxt', "ITEM_PROP_" .. cnt , 0, inner_yPos);
		local ControlSetCtrl = tolua.cast(ControlSetObj, 'ui::CControlSet');
		local richText = GET_CHILD(ControlSetCtrl, "text", "ui::CRichText");
		richText:SetTextByKey('text', strInfo);
		ControlSetCtrl:Resize(ControlSetCtrl:GetWidth(), richText:GetHeight());
		property_gbox:ShowWindow(1)
		property_gbox:Resize(property_gbox:GetWidth(),property_gbox:GetHeight() + ControlSetObj:GetHeight())

		inner_yPos = ControlSetCtrl:GetHeight() + ControlSetCtrl:GetY()
    end

    return inner_yPos
end
