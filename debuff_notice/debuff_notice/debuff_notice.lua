local addon_name = "DEBUFF_NOTICE"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

function DEBUFF_NOTICE_ON_INIT(addon, frame)
    g.addon = addon;
    g.frame = frame;

    addon:RegisterMsg('GAME_START', 'debuff_notice_frame_init');

    addon:RegisterMsg('TARGET_BUFF_ADD', 'debuff_notice_TARGETBUFF_ON_MSG');
    addon:RegisterMsg('TARGET_BUFF_REMOVE', 'debuff_notice_TARGETBUFF_ON_MSG');
    addon:RegisterMsg('TARGET_BUFF_UPDATE', 'debuff_notice_TARGETBUFF_ON_MSG');

    g.slot_table = {}
end

function debuff_notice_frame_init()

    local targetbuff = ui.GetFrame("targetbuff")

    local frame = ui.GetFrame("debuff_notice")
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(300, 50)
    frame:SetPos(targetbuff:GetX() + 100, targetbuff:GetY() + targetbuff:GetHeight() + 50)

    local debuff_slotset = GET_CHILD(frame, "debuff_slotset")

    if not debuff_slotset then
        debuff_slotset = frame:CreateOrGetControl("slotset", "debuff_slotset", 0, 0, 315, 50)
        AUTO_CAST(debuff_slotset)
        debuff_slotset:SetColRow(6, 1)
        debuff_slotset:SetSlotSize(50, 50)
        debuff_slotset:SetSpc(0, 0)
        debuff_slotset:EnablePop(0)
        debuff_slotset:EnableDrag(0)
        debuff_slotset:EnableDrop(0)
        -- debuff_slotset:EnableHitTest(0);
        debuff_slotset:CreateSlots();
    else
        AUTO_CAST(debuff_slotset)
    end

    local slot_count = debuff_slotset:GetSlotCount()
    for i = 1, slot_count do
        local slot = GET_CHILD(debuff_slotset, "slot" .. i)
        AUTO_CAST(slot)
        local icon = CreateIcon(slot)
        AUTO_CAST(icon)
        local time_text = slot:CreateOrGetControl('richtext', "time_text", 25, 30, 20, 20);
        AUTO_CAST(time_text)
    end
    frame:ShowWindow(1)
    frame:RunUpdateScript("debuff_notice_frame_resize", 0.2)
end

function debuff_notice_frame_resize(frame)

    for handle, _ in pairs(g.slot_table) do
        local boss_actor = world.GetActor(handle)
        if boss_actor == nil then
            g.slot_table[handle] = nil
            frame:Resize(0, 50)
            return 1
        end
    end

    local debuff_slotset = GET_CHILD(frame, "debuff_slotset")
    AUTO_CAST(debuff_slotset)
    local slot_count = debuff_slotset:GetSlotCount()
    for i = 1, slot_count do
        local slot = GET_CHILD(debuff_slotset, "slot" .. i)
        AUTO_CAST(slot)

        local handle = slot:GetUserIValue("DEBUFF_HANDLE")
        local buff_id = slot:GetUserIValue("DEBUFF_ID")
        local buff_index = slot:GetUserIValue("DEBUFF_INDEX")
        local time_text = GET_CHILD(slot, "time_text")
        local buff = info.GetBuff(handle, buff_id, buff_index) or info.GetBuff(handle, buff_id)
        if not buff or buff.time <= 0 then
            time_text:SetText("")
            slot:ClearIcon();
            debuff_notice_common_buff_msg(frame, "REMOVE", buff_id, handle, buff_index)
        end
    end

    return 1

end

function debuff_notice_TARGETBUFF_ON_MSG(frame, msg, arg_str, buff_id)

    local frame = ui.GetFrame("debuff_notice")
    local handle = session.GetTargetHandle()

    local buff_cls = GetClassByType('Buff', buff_id)

    if not buff_cls then
        return
    end

    if buff_cls and buff_cls.Group1 ~= "Debuff" then
        return
    end

    if buff_cls.ShowIcon == "FALSE" then
        return;
    end

    local image_name = GET_BUFF_ICON_NAME(buff_cls);
    if image_name == "icon_None" then
        return
    end

    local buff_index = tonumber(arg_str)
    local buff = info.GetBuff(handle, buff_id, buff_index);
    if not buff then
        buff = info.GetBuff(handle, buff_id);
    end

    local my_handle = session.GetMyHandle()

    if buff then
        local caster_handle = buff:GetHandle()
        if caster_handle ~= my_handle then
            return
        end
    end

    local actor = world.GetActor(handle)
    local mon_cls = GetClassByType("Monster", actor:GetType())
    if TryGetProp(mon_cls, "MonRank", "None") ~= "Boss" then
        return
    else
        if not g.slot_table[handle] then
            g.slot_table[handle] = {}
        end
    end

    if msg == "TARGET_BUFF_ADD" then
        debuff_notice_common_buff_msg(frame, "ADD", buff_id, handle, arg_str)
    elseif msg == "TARGET_BUFF_REMOVE" then
        debuff_notice_common_buff_msg(frame, "REMOVE", buff_id, handle, arg_str)
    elseif msg == "TARGET_BUFF_UPDATE" then
        debuff_notice_common_buff_msg(frame, "UPDATE", buff_id, handle, arg_str)

    end

end

function debuff_notice_time_update(slot, timer)

    local handle = slot:GetUserIValue("DEBUFF_HANDLE")
    local buff_id = slot:GetUserIValue("DEBUFF_ID")
    local buff_index = slot:GetUserIValue("DEBUFF_INDEX")

    local frame = slot:GetTopParentFrame()
    local time_text = GET_CHILD(slot, "time_text")

    local buff = info.GetBuff(handle, buff_id, buff_index) or info.GetBuff(handle, buff_id)
    if not buff or buff.time <= 0 then
        time_text:SetText("")
        slot:ClearIcon();
        debuff_notice_common_buff_msg(frame, "REMOVE", buff_id, handle, buff_index)
    else
        local sec = buff.time / 1000
        sec = math.floor(sec * 10 + 0.5) / 10
        sec = string.format("%d", sec)
        time_text:SetText("{ol}{s18}{#FFFF00}" .. sec)
    end

    -- .. ScpArgMsg("Auto_Cho")
end

function debuff_notice_frame_redraw(frame, handle)

    local debuff_slotset = frame:GetChild("debuff_slotset")
    if not debuff_slotset then
        return
    end
    AUTO_CAST(debuff_slotset)

    local buffs_to_display = {}
    if handle and g.slot_table and g.slot_table[handle] then
        for buff_id, buff_index in pairs(g.slot_table[handle]) do
            table.insert(buffs_to_display, {
                buff_id = buff_id,
                buff_index = buff_index
            })
        end
    end

    if #buffs_to_display == 0 then
        frame:Resize(0, 50)
        return
    end

    local slot_count = debuff_slotset:GetSlotCount()
    for i = 1, slot_count do
        local slot = GET_CHILD(debuff_slotset, "slot" .. i)
        AUTO_CAST(slot)
        slot:ClearIcon();
        local icon = CreateIcon(slot)
        AUTO_CAST(icon)

        local buff_data = buffs_to_display[i]
        if buff_data then
            local target_buff_id = tonumber(buff_data.buff_id)
            local target_buff_index = tonumber(buff_data.buff_index)
            local buff_cls = GetClassByType('Buff', target_buff_id)
            if buff_cls then

                local image_name = GET_BUFF_ICON_NAME(buff_cls)
                icon:Set(image_name, 'BUFF', target_buff_id, 0)
                icon:SetTooltipType('buff');
                icon:SetTooltipArg(handle, target_buff_id, target_buff_index);

                slot:SetUserValue("DEBUFF_HANDLE", tonumber(handle))
                slot:SetUserValue("DEBUFF_ID", target_buff_id)
                slot:SetUserValue("DEBUFF_INDEX", target_buff_index)
                local addon_timer = slot:CreateOrGetControl("timer", "addon_timer", 0, 0);
                AUTO_CAST(addon_timer)
                -- addon_timer:Stop()
                addon_timer:SetUpdateScript("debuff_notice_time_update");
                addon_timer:Start(0.2);
                local x = #buffs_to_display * 50
                frame:Resize(x, 50)

            end

        end

    end

    frame:Invalidate()
end

function debuff_notice_common_buff_msg(frame, msg, buff_id, handle, buff_index)

    local frame = ui.GetFrame("debuff_notice")

    if "None" == buff_index or not buff_index then
        buff_index = 0
    end
    buff_index = tonumber(buff_index)

    if msg == 'ADD' or msg == "UPDATE" then

        g.slot_table[handle][buff_id] = buff_index
    elseif msg == 'REMOVE' then

        g.slot_table[handle][buff_id] = nil
    end

    debuff_notice_frame_redraw(frame, handle)
end

