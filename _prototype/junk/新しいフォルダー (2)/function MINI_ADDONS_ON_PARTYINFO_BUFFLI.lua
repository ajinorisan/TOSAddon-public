function MINI_ADDONS_ON_PARTYINFO_BUFFLIST_UPDATE(frame, msg, str, num)
    local frame = ui.GetFrame("partyinfo")
    if not frame then
        return
    end
    local pc_party = session.party.GetPartyInfo()
    if not pc_party then
        DESTROY_CHILD_BYNAME(frame, 'ptinfo_')
        frame:ShowWindow(0)
        return
    end

    local buffid_set = {}
    for _, id in ipairs(g.buffids) do
        buffid_set[id] = true
    end

    local list = session.party.GetPartyMemberList(0)
    local count = list:Count()

    local my_info = session.party.GetMyPartyObj()
    for i = 0, count - 1 do
        local party_member_info = list:Element(i)
        if geMapTable.GetMapName(party_member_info:GetMapID()) ~= 'None' then
            local buff_count = party_member_info:GetBuffCount()
            local party_info_ctrl_set = frame:GetChild('ptinfo_' .. party_member_info:GetAID())
            if party_info_ctrl_set then
                local buff_list_slot_set = GET_CHILD(party_info_ctrl_set, "buff_list", "ui::CSlotSet")
                local debuff_list_slot_set = GET_CHILD(party_info_ctrl_set, "debuff_list", "ui::CSlotSet")

                for j = 0, buff_list_slot_set:GetSlotCount() - 1 do
                    local slot = buff_list_slot_set:GetSlotByIndex(j)

                    if slot then
                        slot:SetKeyboardSelectable(false)
                        slot:ShowWindow(0)
                    end
                end

                for j = 0, debuff_list_slot_set:GetSlotCount() - 1 do
                    local slot = debuff_list_slot_set:GetSlotByIndex(j)
                    if slot then
                        slot:ShowWindow(0)
                    end
                end

                if buff_count <= 0 then
                    party_member_info:ResetBuff()
                    buff_count = party_member_info:GetBuffCount()
                end

                if buff_count > 0 then
                    local buff_index, debuff_index = 0, 0
                    for j = 0, buff_count - 1 do
                        local buff_id = party_member_info:GetBuffIDByIndex(j)
                        local cls = GetClassByType("Buff", buff_id)
                        if cls and cls.ClassName ~= "TeamLevel" then

                            MINI_ADDONS_BUFF_TABLE_INSERT(buff_id)

                            local should_show = (g.settings.party_buff == 1 and buffid_set[buff_id]) or
                                                    (g.settings.party_buff ~= 1 and IS_PARTY_INFO_SHOWICON(cls.ShowIcon))
                            if should_show then

                                local slot = nil
                                if cls.Group1 == 'Buff' then
                                    slot = buff_list_slot_set:GetSlotByIndex(buff_index)
                                    buff_index = buff_index + 1
                                elseif cls.Group1 == 'Debuff' then
                                    slot = debuff_list_slot_set:GetSlotByIndex(debuff_index)
                                    debuff_index = debuff_index + 1
                                end

                                local buff_over = party_member_info:GetBuffOverByIndex(j)
                                local buff_time = party_member_info:GetBuffTimeByIndex(j)

                                if slot then
                                    local icon = slot:GetIcon()
                                    if not icon then
                                        icon = CreateIcon(slot)
                                    end

                                    local handle = 0
                                    if my_info then
                                        if my_info:GetMapID() == party_member_info:GetMapID() and my_info:GetChannel() ==
                                            party_member_info:GetChannel() then
                                            handle = party_member_info:GetHandle()
                                        end
                                    end

                                    icon:SetDrawCoolTimeText(math.floor(buff_time / 1000))
                                    icon:SetTooltipType('buff')
                                    icon:SetTooltipArg(tostring(handle), buff_id, "")

                                    local image_name = 'icon_' .. TryGetProp(cls, 'Icon', 'None')
                                    if image_name ~= "icon_None" then
                                        icon:Set(image_name, 'BUFF', buff_id, 0)
                                    end

                                    if buff_over > 1 then
                                        slot:SetText('{s13}{ol}{b}' .. buff_over, 'count', ui.RIGHT, ui.BOTTOM, 1, 2)
                                    else
                                        slot:SetText("")
                                    end

                                    slot:ShowWindow(1)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
