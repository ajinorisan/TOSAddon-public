local addon_name = "DEBUFF_NOTICE"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]
local json = require("json")

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
        debuff_slotset:SetSpc(2, 0)
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
        local time_text = slot:CreateOrGetControl('richtext', "time_text", 30, 30, 20, 20);
        AUTO_CAST(time_text)
    end
    frame:ShowWindow(1)
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
    if not buff then
        time_text:SetText("")
        slot:ClearIcon();
        debuff_notice_common_buff_msg(frame, "REMOVE", buff_id, handle, buff_index)
    else
        local sec = buff.time / 1000
        sec = math.floor(sec * 10 + 0.5) / 10
        sec = string.format("%d", sec)
        time_text:SetText("{ol}{s15}{#FFFF00}" .. sec)
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
                addon_timer:Stop()
                addon_timer:SetUpdateScript("debuff_notice_time_update");
                addon_timer:Start(0.3);

            end

        end

    end

    frame:Invalidate()
end

function debuff_notice_common_buff_msg(frame, msg, buff_id, handle, buff_index)
    local frame = ui.GetFrame("debuff_notice")
    -- (buff_index の nil チェックと tonumber は同じ)
    if "None" == buff_index or not buff_index then
        buff_index = 0
    end
    buff_index = tonumber(buff_index)

    if not g.slot_table[handle] then
        g.slot_table[handle] = {}
    end

    if msg == 'ADD' or msg == "UPDATE" then
        CHAT_SYSTEM(msg .. " " .. buff_id)
        g.slot_table[handle][buff_id] = buff_index
    elseif msg == 'REMOVE' then
        CHAT_SYSTEM("REMOVE " .. buff_id)
        g.slot_table[handle][buff_id] = nil
    end

    debuff_notice_frame_redraw(frame, handle)
end

--[[

function debuff_notice_remove_time(slot)

    local handle = slot:GetUserIValue("DEBUFF_HANDLE")
    local buff_id = slot:GetUserIValue("DEBUFF_ID")
    local buff_index = slot:GetUserIValue("DEBUFF_INDEX")

    local time_text = GET_CHILD(slot, "time_text")
    time_text:SetText("")

    local frame = slot:GetTopParentFrame()
    if g.slot_table[handle][buff_id] then
        g.slot_table[handle][buff_id] = nil
    end
    slot:ClearIcon();
    CHAT_SYSTEM("test4")

end
function debuff_notice_frame_redraw(frame, handle, msg)
    local debuff_slotset = frame:GetChild("debuff_slotset")
    local buffids = {}
    local slot_count = debuff_slotset:GetSlotCount()

    if msg == "REMOVE" then
        for i = 1, slot_count do
            local slot = GET_CHILD(debuff_slotset, "slot" .. i)
            AUTO_CAST(slot)
            local icon = slot:GetIcon() or CreateIcon(slot)
            local iconInfo = icon:GetInfo()

            if g.slot_table[handle] then
                for buff_id, buff_index in pairs(g.slot_table[handle]) do
                    if buff_id == iconInfo.type then
                        g.slot_table[handle][buff_id] = nil
                        icon:ClearIcon()
                        return
                    end
                end
            end

        end
    end
    for i = 1, slot_count do
        local slot = GET_CHILD(debuff_slotset, "slot" .. i)
        AUTO_CAST(slot)
        local icon = slot:GetIcon() or CreateIcon(slot)

        local iconInfo = icon:GetInfo()
        if iconInfo.type == 0 then
            if g.slot_table[handle] then
                for buff_id, buff_index in pairs(g.slot_table[handle]) do
                    if not buffids[buff_id] then
                        buffids[buff_id] = true
                        local buff = info.GetBuff(handle, buff_id, buff_index);
                        if not buff then
                            buff = info.GetBuff(handle, buff_id);
                        end
                        local buff_cls = GetClassByType('Buff', buff_id)
                        local image_name = GET_BUFF_ICON_NAME(buff_cls);
                        icon:Set(image_name, 'BUFF', buff_id, 0);
                        icon:SetTooltipType('buff');
                        icon:SetTooltipArg(handle, buff_id, buff_index)
                    end
                end
            end
        end

        local time_text = frame:CreateOrGetControl('richtext', "time_text" .. i, slot:GetX(), slot:GetY() + 55, 50, 20);
        time_text:SetFontName("yellow_13");
    end
end]]

--[[function debuff_notice_common_buff_msg(frame, msg, buff_id, handle, buff_ui, buff_index)

    if "None" == buff_index or not buff_index then
        buff_index = 0
    end
    buff_index = tonumber(buff_index)

    if not g.slot_table[handle] then
        g.slot_table[handle] = {}
    end

    if msg == "CLEAR" then
        if slotset then
            debuff_notice_frame_init()
            return
        end
    end

    local buff = info.GetBuff(handle, buff_id, buff_index);
    if not buff then
        buff = info.GetBuff(handle, buff_id);
    end

    local buff_cls = GetClassByType('Buff', buff_id)

    if msg == 'ADD' then
        local skip = false
        if buff_cls ~= nil then
            CHAT_SYSTEM("ADD" .. buff_id .. ":" .. buff_cls.Name)
            if TryGetProp(buff_cls, 'OnlyOneBuff', 'None') == 'YES' and TryGetProp(buff_cls, 'Duplicate', 1) == 0 then

                if not g.slot_table[handle][buff_id] then
                    g.slot_table[handle][buff_id] = buff_index
                end
                debuff_notice_frame_redraw(frame, handle, msg)
                skip = true
            end

            if skip == false then

                if not g.slot_table[handle][buff_id] then
                    g.slot_table[handle][buff_id] = buff_index
                end
                debuff_notice_frame_redraw(frame, handle, msg)
            end

        end

    elseif msg == 'REMOVE' then
        CHAT_SYSTEM("REMOVE" .. buff_id .. ":" .. buff_cls.Name)
        if g.slot_table[handle][buff_id] then
            debuff_notice_frame_redraw(frame, handle, msg)
        end
        --[[elseif msg == "UPDATE" then
        for i = 0, slotcount - 1 do
            local slot = slotlist[i];
            local text = captionlist[i];
            local oldIcon = slot:GetIcon();
            if slot:IsVisible() == 1 then
                local iconInfo = oldIcon:GetInfo();
                if iconInfo.type == buffType and oldIcon:GetUserIValue("BuffIndex") == buffIndex then
                    SET_BUFF_SLOT(slot, captionlist[i], class, buffType, handle, slotlist, buffIndex, false);
                    break
                end
            end
        end]]
-- end

-- SEPARATEDPCDEBUFF_ARRANGE_BUFF_SLOT(frame, buff_ui);
-- COLONY_BATTLE_INFO_DRAW_BUFF_ICON();
-- end
local function get_exist_debuff_slot(frame, buff_id, msg)
    local debuff_slotset = frame:GetChild("debuff_slotset")
    local slot_count = debuff_slotset:GetSlotCount()

    if msg == "ADD" then
        for i = 1, slot_count do
            local slot = GET_CHILD(debuff_slotset, "slot" .. i)
            if slot then
                AUTO_CAST(slot)
                local icon = slot:GetIcon();
                if icon then
                    local iconInfo = icon:GetInfo()
                    if iconInfo.type == 0 then
                        return slot, icon
                    end
                end
            end
        end
    elseif msg == "REMOVE" then
        for i = 1, slot_count do
            local slot = GET_CHILD(debuff_slotset, "slot" .. i)
            if slot then
                AUTO_CAST(slot)
                local icon = slot:GetIcon();
                if icon then
                    local iconInfo = icon:GetInfo()
                    if iconInfo.type == buff_id then
                        return slot, icon, iconInfo
                    end
                end
            end
        end
    end

    return nil
end
--[[function get_exist_debuff_in_slotlist(slotlist, buff_id)
    for k = 0, #slotlist - 1 do
        local slot =  slotlist[k];
        if slot ~= nil then
            local icon = slot:GetIcon(); 
            if icon ~= nil then
                local iconInfo = icon:GetInfo()
                if iconInfo ~= nil then
                    if tonumber(iconInfo.type) == tonumber(buff_id) then
                        return slot, k;
                    end
                end
            end
        end
    end

    return nil;
end]]
--[[function SET_BUFF_SLOT(slot, capt, class, buffType, handle, slotlist, buffIndex, isOtherCast)
	local icon = slot:GetIcon();
	local imageName = GET_BUFF_ICON_NAME(class);
	if imageName ~= "icon_None" then
		icon:Set(imageName, 'BUFF', buffType, 0);
	end
	if buffIndex ~= nil then
		icon:SetUserValue("BuffIndex", buffIndex);	
	end

	if tonumber(handle) == nil then
		return;
	end

	local buff = info.GetBuff(tonumber(handle), buffType, buffIndex);
	if nil == buff then
		return;
	end

	local frame = ui.GetFrame("buff")
	local bufflockoffset = tonumber(frame:GetUserConfig("DEFAULT_BUFF_LOCK_OFFSET"));
	local buffGroup1 = TryGetProp(class, "Group1", "Buff");
	if buffGroup1 == "Debuff" then
		local bufflv = TryGetProp(class, "Lv", "99");
		if bufflv == 4 then
			slot:SetBgImage("buff_lock_icon_3");
		elseif bufflv > 4 then
			slot:SetBgImage("buff_lock_icon_4");
		end

		if bufflv <= 3 then
			slot:SetBgImageSize(0, 0);
		else 
			slot:SetBgImageSize(slot:GetWidth() + bufflockoffset, slot:GetHeight() + bufflockoffset);
		end		
	end

	if buff.over > 1 then
		slot:SetText('{s13}{ol}{b}'..buff.over, 'count', ui.RIGHT, ui.BOTTOM, -5, -3);
	else
		slot:SetText("");
	end
	
    if slot:GetTopParentFrame():GetName() ~= "targetbuff" then
    	slot:SetEventScript(ui.RBUTTONUP, 'REMOVE_BUF');
    	slot:SetEventScriptArgNumber(ui.RBUTTONUP, buffType);
	end

	slot:EnableDrop(0);
	slot:EnableDrag(0);

	if capt ~= nil then
		capt:ShowWindow(1);
		capt:SetText(GET_BUFF_TIME_TXT(buff.time, 0, isOtherCast));
	end
	
	local targetinfo = info.GetTargetInfo( handle );
	if targetinfo ~= nil then
		if targetinfo.TargetWindow == 0 then
			slot:ShowWindow(0);
		else
			slot:ShowWindow(1);
		end
	else
		slot:ShowWindow(1);
	end
	
	if class.ClassName == "Premium_Nexon" or class.ClassName =="Premium_Token" then
		icon:SetTooltipType('premium');
		icon:SetTooltipArg(handle, buffType, buff.arg1);
	elseif TryGetProp(class, 'StringArg', 'None') == 'Ref_Account_datetime' then
		icon:SetTooltipType('premium_boost')		
		icon:SetTooltipArg(handle, buffType, buff.arg1);		
	elseif class.ClassName == 'Water_jewel_complete_Buff' then
		icon:SetTooltipType('Water_jewel_Buff')		
		icon:SetTooltipArg(handle, buffType, buff.arg1);		
	else
	    icon:SetTooltipType('buff');
	    if buffIndex ~= nil then
	    	icon:SetTooltipArg(handle, buffType, buffIndex);
	    end
	end

	slot:Invalidate();
end]]

function separatedpcdebuff_BUFF_TOTAL_COUNT_CHECK(frame, msg, buffType, handle, buff_ui, buffIndex)
    local buffCls = GetClassByType('Buff', buffType);
    if buffCls == nil or buffCls.ShowIcon == "FALSE" then
        return;
    end

    local my_cast_debuff = false;
    local pcHandle = session.GetMyHandle();

    if "None" == buffIndex or nil == buffIndex then
        buffIndex = 0;
    end
    buffIndex = tonumber(buffIndex);

    local buff = info.GetBuff(handle, buffType, buffIndex);
    if (buff == nil) then
        buff = info.GetBuff(handle, buffType);
    end

    if buff ~= nil then
        local casterHandle = buff:GetHandle();
        if (casterHandle == pcHandle) then
            my_cast_debuff = true;
        end
    end

    local apply_limit_count_buff = 0;
    if buffCls.ApplyLimitCountBuff == "YES" then
        apply_limit_count_buff = 1;
    else
        apply_limit_count_buff = 0;
    end

    local buffcount_totalcnt = frame:GetUserIValue("BUFF_COUNT_TOTAL_CNT");
    local buff_totalcnt = frame:GetUserIValue("BUFF_TOTAL_CNT");
    local debuff_totalcnt = frame:GetUserIValue("DEBUFF_TOTAL_CNT");
    local totalCount = 0;
    local buff_ui_index = 0;

    if buffCls.Group1 == 'Debuff' and my_cast_debuff == true then
        debuff_totalcnt = info.GetBuffcountByProperty(handle, buffCls.Group1, apply_limit_count_buff, 1);
        buff_ui_index = 4;
        frame:SetUserValue("DEBUFF_TOTAL_CNT", debuff_totalcnt);
        totalCount = debuff_totalcnt;
    end

    if (buff_ui_index == 4) then
        local my_db_ss = frame:GetChild("my_db_ss")
        AUTO_CAST(my_db_ss)
        if (my_db_ss ~= nil) then
            -- pc debuff
            local row = my_db_ss:GetRow();
            local col = my_db_ss:GetCol();
            if msg == "ADD" and totalCount > col * row then
                my_db_ss:ExpandRow();
                while 1 do
                    if my_db_ss == nil then
                        break
                    end
                    local slot = my_db_ss:GetSlotByIndex(g.slot_count);
                    if slot == nil then
                        break
                    end
                    g.slot_list[g.slot_count] = slot;
                    slot:ShowWindow(0);
                    local icon = CreateIcon(slot);
                    if icon ~= nil then
                        icon:SetDrawCoolTimeText(0);
                    end
                    local x = my_db_ss:GetX() + slot:GetX() + buff_ui["txt_x_offset"];
                    local y = my_db_ss:GetY() + slot:GetY() + slot:GetHeight() + buff_ui["txt_y_offset"];
                    local captWidth, captHeight = 50, 20;
                    local capt = frame:CreateOrGetControl('richtext', "_t_" .. 4 .. "_" .. g.slot_count, x, y,
                                                          captWidth, captHeight);
                    capt:SetFontName("yellow_13");
                    g.cap_list[g.slot_count] = capt;
                    g.slot_count = g.slot_count + 1;
                end
            end
            my_db_ss:AutoCheckDecreaseRow();
            my_db_ss:Invalidate();
        end
    end

end

--[===[ 

function SEPARATEDPCDEBUFF_ON_INIT(addon, frame)
    g.addon = addon;
    g.frame = frame;
    -- initialize frame
    local targetbuff = ui.GetFrame('targetbuff')
    -- t_buff_ui がどこから来るのか確認！ nil だとエラーになる
    if targetbuff and t_buff_ui then
        SEPARATEDPCDEBUFF_INIT_CASTER_DEBUFF_SLOT(targetbuff, t_buff_ui)
    end
    g.setup_hook()
    -- g.setup_hook_and_event(addon, 'COMMON_BUFF_MSG', "SEPARATEDPCDEBUFF_COMMON_BUFF_MSG", false)
    -- g.setup_hook_and_event(addon, 'TARGETBUFF_RESIZE', "SEPARATEDPCDEBUFF_TARGETBUFF_RESIZE", false)
    -- acutil.setupEvent(addon, "TARGET_BUFF_UPDATE", "SEPARATEDPCDEBUFF_TARGET_BUFF_UPDATE");
    -- g.setup_hook_and_event(addon, 'TARGET_BUFF_UPDATE', "SEPARATEDPCDEBUFF_TARGET_BUFF_UPDATE", false)
    -- acutil.setupHook(SEPARATEDPCDEBUFF_COMMON_BUFF_MSG, 'COMMON_BUFF_MSG')
    -- acutil.setupHook(SEPARATEDPCDEBUFF_TARGETBUFF_RESIZE, 'TARGETBUFF_RESIZE')
    -- acutil.setupHook(SEPARATEDPCDEBUFF_TARGET_BUFF_UPDATE, 'TARGET_BUFF_UPDATE')
    SEPARATEDPCDEBUFF_ON_FRAME_INIT(frame)
end

-- implicit addition to INIT_BUFF_UI in lib_uiscp.lua
function SEPARATEDPCDEBUFF_INIT_CASTER_DEBUFF_SLOT(frame, buff_ui)
    local casterDebuffSetPt = frame:GetChild("casterdebuffslot")
    if (casterDebuffSetPt == nil) then
        casterDebuffSetPt = frame:CreateOrGetControl("slotset", "casterdebuffslot", 35, 35, ui.LEFT, ui.TOP, 30, 120, 0,
            0);
        AUTO_CAST(casterDebuffSetPt)
        casterDebuffSetPt:SetColRow(7, 1)
        casterDebuffSetPt:SetSlotSize(60, 60)
        casterDebuffSetPt:SetSpc(2, 15)
        casterDebuffSetPt:CreateSlots();
    else
        AUTO_CAST(casterDebuffSetPt)
    end
    -- buff_ui["buff_group_cnt"] = 4;
    separatedpcdebuff_slotcount = 0;
    separatedpcdebuff_slotlist = {};
    separatedpcdebuff_captionlist = {};

    while 1 do
        if casterDebuffSetPt == nil then
            break
        end

        local slot = casterDebuffSetPt:GetSlotByIndex(separatedpcdebuff_slotcount);
        if slot == nil then
            break
        end

        separatedpcdebuff_slotlist[separatedpcdebuff_slotcount] = slot;
        slot:ShowWindow(0);
        local icon = CreateIcon(slot);
        icon:SetDrawCoolTimeText(0);
        local x = casterDebuffSetPt:GetX() + slot:GetX() + buff_ui["txt_x_offset"];
        local y = casterDebuffSetPt:GetY() + slot:GetY() + slot:GetHeight() + buff_ui["txt_y_offset"];

        local captWidth, captHeight = 50, 20;
        local capt = frame:CreateOrGetControl('richtext', "_t_" .. 4 .. "_" .. separatedpcdebuff_slotcount, x, y,
            captWidth, captHeight);
        capt:SetFontName("yellow_13");
        separatedpcdebuff_captionlist[separatedpcdebuff_slotcount] = capt;
        separatedpcdebuff_slotcount = separatedpcdebuff_slotcount + 1;
    end
end

-- modification of COMMON_BUFF_MSG from buff.lua to separate caster debuff
function SEPARATEDPCDEBUFF_COMMON_BUFF_MSG_(frame, msg, buffType, handle, buff_ui, buffIndex)

    --[[local formatted_string = string.format("Args: %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s", tostring(frame),
        tostring(msg), tostring(buffType), tostring(handle), tostring(buff_ui), tostring(buffIndex), type(frame),
        type(msg), type(buffType), type(handle), type(buff_ui), type(buffIndex))

    print(formatted_string)]]

    if not frame or not msg or not buffType or not handle or not buff_ui then
        print("COMMON_BUFF_MSG Error: 必須引数のいずれかが nil です！処理を中断します。")
        print(string.format("frame:%s, msg:%s, buffType:%s, handle:%s, buff_ui:%s, buffIndex:%s", tostring(frame),
            tostring(msg), tostring(buffType), tostring(handle), tostring(buff_ui), tostring(buffIndex)))
        return -- nil があったら即終了！
    end

    if (frame:GetName() ~= 'targetbuff') then
        separatedpcdebuff_dammy_COMMON_BUFF_MSG(frame, msg, buffType, handle, buff_ui, buffIndex)
        return
    end
    SEPARATEDPCDEBUFF_BUFF_TOTAL_COUNT_CHECK(frame, msg, buffType, handle, buff_ui, buffIndex);
    if msg == "SET" then
        local buffCount = info.GetBuffCount(handle);
        for i = 0, buffCount - 1 do
            local buff = info.GetBuffIndexed(handle, i);
            if buff ~= nil then
                separatedpcdebuff_dammy_COMMON_BUFF_MSG(frame, "ADD", buff.buffID, handle, buff_ui, buff.index);
            end
        end
        return;
    elseif msg == "CLEAR" then
        for i = 0, (buff_ui["buff_group_cnt"]) do
            if buff_ui["slotsets"][i] ~= nil then
                local slotlist = buff_ui["slotlist"][i];
                local slotcount = buff_ui["slotcount"][i];
                local captionlist = buff_ui["captionlist"][i];
                if slotcount ~= nil and slotcount >= 0 then
                    for i = 0, slotcount - 1 do
                        local slot = slotlist[i];
                        local text = captionlist[i];
                        CLEAR_BUFF_SLOT(slot, text)
                    end
                end
            end
        end
        -- for pc debuff
        local slotset = frame:GetChild("casterdebuffslot")
        AUTO_CAST(slotset)
        if (slotset ~= nil) then
            local slotlist = separatedpcdebuff_slotlist;
            local slotcount = separatedpcdebuff_slotcount;
            local captionlist = separatedpcdebuff_captionlist;
            if slotcount ~= nil and slotcount >= 0 then
                for i = 0, slotcount - 1 do
                    local slot = slotlist[i];
                    local text = captionlist[i];
                    if (slot ~= nil) then
                        CLEAR_BUFF_SLOT(slot, text)
                    else
                        break
                    end
                end
            end
        end

        frame:Invalidate();
        return;
    end

    if "None" == buffIndex or nil == buffIndex then
        buffIndex = 0;
    end

    buffIndex = tonumber(buffIndex);

    local class = GetClassByType('Buff', buffType);
    if class.ShowIcon == "FALSE" then
        return;
    end

    local slotlist;
    local slotcount;
    local captionlist;
    local colcnt = 0;
    local ApplyLimitCountBuff = "YES";

    local isOtherCastBuff = false;
    local isPCCastBuff = false;
    local pcHandle = session.GetMyHandle();
    local buff = info.GetBuff(handle, buffType, buffIndex)
    if (buff == nil) then
        buff = info.GetBuff(handle, buffType);
    end
    if buff ~= nil then
        local casterHandle = buff:GetHandle();
        if casterHandle ~= nil and casterHandle ~= handle then
            isOtherCastBuff = true;
        end
        if (casterHandle == pcHandle) then
            isPCCastBuff = true;
        end
    end
    if class.Group1 == 'Debuff' and isPCCastBuff == false then
        slotlist = buff_ui["slotlist"][2];
        slotcount = buff_ui["slotcount"][2];
        captionlist = buff_ui["captionlist"][2];
        if nil ~= buff_ui["slotsets"][2] then
            colcnt = buff_ui["slotsets"][2]:GetCol();
        end
    elseif class.Group1 == 'Debuff' and isPCCastBuff == true then
        local separatedpcdebuff_slotset = frame:GetChild("casterdebuffslot")
        AUTO_CAST(separatedpcdebuff_slotset)
        slotlist = separatedpcdebuff_slotlist;
        slotcount = separatedpcdebuff_slotcount;
        captionlist = separatedpcdebuff_captionlist;
        if nil ~= separatedpcdebuff_slotset then
            colcnt = separatedpcdebuff_slotset:GetCol();
        end
    else
        if class.ApplyLimitCountBuff == 'YES' then
            local slotlistIndex = 0;
            if isOtherCastBuff == true then
                slotlistIndex = 3;
            end

            slotlist = buff_ui["slotlist"][slotlistIndex];
            slotcount = buff_ui["slotcount"][slotlistIndex];
            captionlist = buff_ui["captionlist"][slotlistIndex];
            if nil ~= buff_ui["slotsets"][slotlistIndex] then
                colcnt = buff_ui["slotsets"][slotlistIndex]:GetCol();
            end
        else
            local slotlistIndex = 1;
            if isOtherCastBuff == true and (class.RemoveBySkill == "YES" or class.Lv < 4) then
                slotlistIndex = 3;
            end

            slotlist = buff_ui["slotlist"][slotlistIndex];
            slotcount = buff_ui["slotcount"][slotlistIndex];
            captionlist = buff_ui["captionlist"][slotlistIndex];
            if nil ~= buff_ui["slotsets"][slotlistIndex] then
                colcnt = buff_ui["slotsets"][slotlistIndex]:GetCol();
            end
            ApplyLimitCountBuff = "NO";
        end
    end

    if msg == 'ADD' then
        local skip = false
        if class ~= nil then
            if TryGetProp(class, 'OnlyOneBuff', 'None') == 'YES' and TryGetProp(class, 'Duplicate', 1) == 0 then
                local exist_slot, i = get_exist_debuff_in_slotlist(slotlist, buffType)
                if exist_slot ~= nil then
                    if exist_slot:IsVisible() == 0 then
                        SET_BUFF_SLOT(exist_slot, captionlist[i], class, buffType, handle, slotlist, buffIndex,
                            isOtherCastBuff);
                    end
                    skip = true
                end
            end
        end

        if skip == false then
            for j = 0, slotcount - 1 do
                local i = GET_BUFF_SLOT_INDEX(j, colcnt);
                local slot = slotlist[i];
                if slot:IsVisible() == 0 then
                    SET_BUFF_SLOT(slot, captionlist[i], class, buffType, handle, slotlist, buffIndex, isOtherCastBuff);
                    break
                end
            end
        end
    elseif msg == 'REMOVE' then
        -- On remove, we don't know if it's a PC debuff or regular debuff. So we just try both.
        for i = 0, slotcount - 1 do
            local slot = slotlist[i];
            local text = captionlist[i];
            local oldIcon = slot:GetIcon();
            if slot:IsVisible() == 1 then
                local oldBuffIndex = oldIcon:GetUserIValue("BuffIndex");
                local iconInfo = oldIcon:GetInfo();
                local isBuffIndexSame = oldBuffIndex - buffIndex;
                if iconInfo.type == buffType and isBuffIndexSame == 0 then
                    CLEAR_BUFF_SLOT(slot, text);
                    local j = GET_BUFF_ARRAY_INDEX(i, colcnt);
                    PULL_BUFF_SLOT_LIST(slotlist, captionlist, j, slotcount, colcnt, ApplyLimitCountBuff);
                    frame:Invalidate();
                    break
                end
            end
        end
        REMOVE_BUFF_COUNT_SLOT_SUB(frame, buff_ui, buffType, buffIndex, colcnt, ApplyLimitCountBuff);

        -- try pc debuff list
        local separatedpcdebuff_slotset = frame:GetChild("casterdebuffslot")
        AUTO_CAST(separatedpcdebuff_slotset)
        slotlist = separatedpcdebuff_slotlist;
        slotcount = separatedpcdebuff_slotcount;
        captionlist = separatedpcdebuff_captionlist;
        if nil ~= separatedpcdebuff_slotset then
            colcnt = separatedpcdebuff_slotset:GetCol();
        end
        for i = 0, slotcount - 1 do
            local slot = slotlist[i];
            local text = captionlist[i];
            local oldIcon = slot:GetIcon();
            if slot:IsVisible() == 1 then
                local oldBuffIndex = oldIcon:GetUserIValue("BuffIndex");
                local iconInfo = oldIcon:GetInfo();
                local isBuffIndexSame = oldBuffIndex - buffIndex;
                if iconInfo.type == buffType and isBuffIndexSame == 0 then
                    CLEAR_BUFF_SLOT(slot, text);
                    local j = GET_BUFF_ARRAY_INDEX(i, colcnt);
                    PULL_BUFF_SLOT_LIST(slotlist, captionlist, j, slotcount, colcnt, ApplyLimitCountBuff);
                    frame:Invalidate();
                    break
                end
            end
        end
        TEMPLATE_REMOVE_BUFF_COUNT_SLOT_SUB(frame, buff_ui, buffType, buffIndex, colcnt, ApplyLimitCountBuff);
    elseif msg == "UPDATE" then
        for i = 0, slotcount - 1 do
            local slot = slotlist[i];
            local text = captionlist[i];
            local oldIcon = slot:GetIcon();
            if slot:IsVisible() == 1 then
                local iconInfo = oldIcon:GetInfo();
                if iconInfo.type == buffType and oldIcon:GetUserIValue("BuffIndex") == buffIndex then
                    SET_BUFF_SLOT(slot, captionlist[i], class, buffType, handle, slotlist, buffIndex, isOtherCastBuff);
                    break
                end
            end
        end
    end

    SEPARATEDPCDEBUFF_ARRANGE_BUFF_SLOT(frame, buff_ui);
    COLONY_BATTLE_INFO_DRAW_BUFF_ICON();
end

-- modification of TARGETBUFF_RESIZE in targetbuff.lua
function SEPARATEDPCDEBUFF_TARGETBUFF_RESIZE_(frame, buff_ui)

    local buffcount_slotsets = buff_ui["slotsets"][0];
    local buff_slotsets = buff_ui["slotsets"][1];
    local debuff_slotsets = buff_ui["slotsets"][2];
    local buffcount_subslotsets = buff_ui["slotsets"][3];
    local casterdebuffslot = frame:GetChild("casterdebuffslot");
    local height = buffcount_slotsets:GetHeight() + buffcount_subslotsets:GetHeight() + buff_slotsets:GetHeight() +
                       debuff_slotsets:GetHeight();
    if (casterdebuffslot ~= nil) then
        height = height + casterdebuffslot:GetHeight();
    end
    frame:Resize(frame:GetWidth(), height + 40);
end

function SEPARATEDPCDEBUFF_TARGET_BUFF_UPDATE_(frame, timer, argStr, argNum, passedTime)
    DAMMY_TARGET_BUFF_UPDATE(frame, timer, argStr, argNum, passedTime)
    --[[local formatted_string = string.format("Args: %s, %s, %s, %s, %s, %s, %s, %s, %s, %s", tostring(frame),
        tostring(timer), tostring(argStr), tostring(argNum), tostring(passedTime), type(frame), type(timer),
        type(argStr), type(argNum), type(passedTime))

    print(formatted_string)]]

    if not frame or not timer or not argStr or not argNum or not passedTime then
        print("TARGET_BUFF_UPDATE Error: 必須引数のいずれかが nil です！処理を中断します。")
        print(string.format("frame: %s, timer: %s, argStr: %s, argNum: %s, passedTime: %s", tostring(frame),
            tostring(timer), tostring(argStr), tostring(argNum), tostring(passedTime)))
        return -- nil があったら即終了！
    end

    local handle = session.GetTargetHandle();
    local updated = 0;
    local TOKEN_BUFF_ID = TryGetProp(GetClass("Buff", "Premium_Token"), "ClassID");
    local separatedpcdebuff_slotset = frame:GetChild("casterdebuffslot")
    AUTO_CAST(separatedpcdebuff_slotset)
    if (separatedpcdebuff_slotset ~= nil) then
        local slotlist = separatedpcdebuff_slotlist;
        local captlist = separatedpcdebuff_captionlist;
        if separatedpcdebuff_slotcount >= 0 then
            for i = 0, separatedpcdebuff_slotcount - 1 do
                local slot = slotlist[i];
                local text = captlist[i];
                if slot:IsVisible() == 1 then
                    local icon = slot:GetIcon();
                    local iconInfo = icon:GetInfo();
                    local buffIndex = icon:GetUserIValue("BuffIndex");
                    local buff = info.GetBuff(handle, iconInfo.type, buffIndex);
                    if buff ~= nil then
                        SET_BUFF_TIME_TO_TEXT(text, buff.time);
                        updated = 1;
                        if buff.time < 5000 and buff.time ~= 0.0 then
                            if slot:IsBlinking() == 0 then
                                slot:SetBlink(600000, 1.0, "55FFFFFF", 1);
                            end
                        elseif buff.buffID == TOKEN_BUFF_ID and GET_REMAIN_TOKEN_SEC() < 3600 then
                            if slot:IsBlinking() == 0 then
                                slot:SetBlink(0, 1.0, "55FFFFFF", 1);
                            end
                        else
                            if slot:IsBlinking() == 1 then
                                slot:ReleaseBlink();
                            end
                        end
                    end
                end
            end
        end

        if updated == 1 then
            ui.UpdateVisibleToolTips("buff");
        end
    end
end

-- modification of BUFF_TOTAL_COUNT_CHECK from buff.lua to separate caster debuff
function SEPARATEDPCDEBUFF_BUFF_TOTAL_COUNT_CHECK(frame, msg, buffType, handle, buff_ui, buffIndex)
    local buffCls = GetClassByType('Buff', buffType);
    if buffCls == nil or buffCls.ShowIcon == "FALSE" then
        return;
    end
    local apply_limit_count_buff = 0;
    if buffCls.ApplyLimitCountBuff == "YES" then
        apply_limit_count_buff = 1;
    else
        apply_limit_count_buff = 0;
    end

    local isOtherCastBuff = false;
    local isPCCastBuff = false;
    local pcHandle = session.GetMyHandle();

    if "None" == buffIndex or nil == buffIndex then
        buffIndex = 0;
    end
    buffIndex = tonumber(buffIndex);

    local buff = info.GetBuff(handle, buffType, buffIndex);
    if (buff == nil) then
        buff = info.GetBuff(handle, buffType);
    end
    if buff ~= nil then
        local casterHandle = buff:GetHandle();
        if casterHandle ~= nil and casterHandle ~= handle then
            isOtherCastBuff = true;
        end
        if (casterHandle == pcHandle) then
            isPCCastBuff = true;
        end
    end
    local buffcount_totalcnt = frame:GetUserIValue("BUFF_COUNT_TOTAL_CNT");
    local buff_totalcnt = frame:GetUserIValue("BUFF_TOTAL_CNT");
    local debuff_totalcnt = frame:GetUserIValue("DEBUFF_TOTAL_CNT");
    local totalCount = 0;
    local buff_ui_index = 0;
    if buffCls.Group1 == "Debuff" and isPCCastBuff == false then
        debuff_totalcnt = info.GetBuffcountByProperty(handle, buffCls.Group1, apply_limit_count_buff, 1);
        buff_ui_index = 2;
        frame:SetUserValue("DEBUFF_TOTAL_CNT", debuff_totalcnt);
        totalCount = debuff_totalcnt;
    elseif buffCls.Group1 == 'Debuff' and isPCCastBuff == true then
        debuff_totalcnt = info.GetBuffcountByProperty(handle, buffCls.Group1, apply_limit_count_buff, 1);
        buff_ui_index = 4;
        frame:SetUserValue("DEBUFF_TOTAL_CNT", debuff_totalcnt);
        totalCount = debuff_totalcnt;
    else
        if apply_limit_count_buff == 1 then
            buffcount_totalcnt = info.GetBuffcountByProperty(handle, buffCls.Group1, apply_limit_count_buff, 1);
            buff_ui_index = 0;
            frame:SetUserValue("BUFF_COUNT_TOTAL_CNT", buffcount_totalcnt);
            totalCount = buffcount_totalcnt;
        else
            buff_totalcnt = info.GetBuffcountByProperty(handle, buffCls.Group1, apply_limit_count_buff, 1);
            buff_ui_index = 1;
            frame:SetUserValue("BUFF_TOTAL_CNT", buff_totalcnt);
            totalCount = buff_totalcnt;
        end
    end
    if (buff_ui_index ~= 4) then
        local row = buff_ui["slotsets"][buff_ui_index]:GetRow();
        local col = buff_ui["slotsets"][buff_ui_index]:GetCol();
        if msg == "ADD" and totalCount > col * row then
            buff_ui["slotsets"][buff_ui_index]:ExpandRow();
            UPDATE_BUFF_UI_SLOTSET(frame, buff_ui, buff_ui_index);
        end
        buff_ui["slotsets"][buff_ui_index]:AutoCheckDecreaseRow();
        buff_ui["slotsets"][buff_ui_index]:Invalidate();
    else
        local separatedpcdebuff_slotset = frame:GetChild("casterdebuffslot")
        AUTO_CAST(separatedpcdebuff_slotset)
        if (separatedpcdebuff_slotset ~= nil) then
            -- pc debuff
            local row = separatedpcdebuff_slotset:GetRow();
            local col = separatedpcdebuff_slotset:GetCol();
            if msg == "ADD" and totalCount > col * row then
                separatedpcdebuff_slotset:ExpandRow();
                while 1 do
                    if separatedpcdebuff_slotset == nil then
                        break
                    end
                    local slot = separatedpcdebuff_slotset:GetSlotByIndex(separatedpcdebuff_slotcount);
                    if slot == nil then
                        break
                    end
                    separatedpcdebuff_slotlist[separatedpcdebuff_slotcount] = slot;
                    slot:ShowWindow(0);
                    local icon = CreateIcon(slot);
                    if icon ~= nil then
                        icon:SetDrawCoolTimeText(0);
                    end
                    local x = separatedpcdebuff_slotset:GetX() + slot:GetX() + buff_ui["txt_x_offset"];
                    local y = separatedpcdebuff_slotset:GetY() + slot:GetY() + slot:GetHeight() +
                                  buff_ui["txt_y_offset"];
                    local captWidth, captHeight = 50, 20;
                    local capt = frame:CreateOrGetControl('richtext', "_t_" .. 4 .. "_" .. separatedpcdebuff_slotcount,
                        x, y, captWidth, captHeight);
                    capt:SetFontName("yellow_13");
                    separatedpcdebuff_captionlist[separatedpcdebuff_slotcount] = capt;
                    separatedpcdebuff_slotcount = separatedpcdebuff_slotcount + 1;
                end
            end
            separatedpcdebuff_slotset:AutoCheckDecreaseRow();
            separatedpcdebuff_slotset:Invalidate();
        end
    end
end

function TEMPLATE_REMOVE_BUFF_COUNT_SLOT_SUB(frame, buff_ui, buffType, buffIndex, colcnt, ApplyLimitCountBuff)
    local slotlist = separatedpcdebuff_slotlist;
    local slotcount = separatedpcdebuff_slotcount;
    local captionlist = separatedpcdebuff_captionlist;
    if slotcount == nil or slotcount <= 0 then
        return;
    end

    for i = 0, slotcount - 1 do
        local slot = slotlist[i];
        local text = captionlist[i];
        local oldIcon = slot:GetIcon();
        if slot:IsVisible() == 1 then
            local oldBuffIndex = oldIcon:GetUserIValue("BuffIndex");
            local iconInfo = oldIcon:GetInfo();
            local isBuffIndexSame = oldBuffIndex - buffIndex;
            if iconInfo.type == buffType and isBuffIndexSame == 0 then
                CLEAR_BUFF_SLOT(slot, text);
                local j = GET_BUFF_ARRAY_INDEX(i, colcnt);
                PULL_BUFF_SLOT_LIST(slotlist, captionlist, j, slotcount, colcnt, ApplyLimitCountBuff);
                frame:Invalidate();
                break
            end
        end
    end
end

-- modification of ARRANGE_BUFF_SLOT from buff.lua to modify display logic
function SEPARATEDPCDEBUFF_ARRANGE_BUFF_SLOT(frame, buff_ui)
    if frame:GetName() ~= 'buff' and frame:GetName() ~= "targetbuff" then
        return;
    end

    local default_slot_y_offset = tonumber(frame:GetUserConfig('DEFAULT_SLOT_Y_OFFSET'));
    local default_sub_slot_y_offset = tonumber(frame:GetUserConfig("DEFAULT_SUB_SLOT_Y_OFFSET"));

    -- buff count -----------------------------------------------------------------
    local buffCount = GET_CHILD_RECURSIVELY(frame, "buffcountslot", "ui::CSlotSet");
    if buffCount == nil then
        return;
    end

    local col_buffcount = buffCount:GetCol();
    local slotCnt_buffcount = buffCount:GetRow() * col_buffcount;

    local visibleCnt_buffcount = 0;
    for i = 0, slotCnt_buffcount - 1 do
        local slot = buffCount:GetSlotByIndex(i);
        if slot == nil or slot:IsVisible() == 0 then
            visibleCnt_buffcount = i;
            break
        end
    end

    local visibleRow_buffcount = math.floor(visibleCnt_buffcount / col_buffcount);
    if visibleRow_buffcount > 0 and visibleRow_buffcount % col_buffcount == 0 then
        visibleRow_buffcount = visibleRow_buffcount + 1;
    end
    visibleRow_buffcount = visibleRow_buffcount + 1;
    -------------------------------------------------------------------------------
    -- buff count sub -------------------------------------------------------------
    local buffSub = GET_CHILD_RECURSIVELY(frame, "buffcountslot_sub", "ui::CSlotSet");
    if buffSub == nil then
        return;
    end

    local col_buffsub = buffSub:GetCol();
    local slotCnt_buffsub = buffSub:GetRow() * col_buffsub;
    local visibleCnt_buffsub = 0;
    for i = 0, slotCnt_buffsub - 1 do
        local slot = buffSub:GetSlotByIndex(i);
        if slot == nil or slot:IsVisible() == 0 then
            visibleCnt_buffsub = i;
            break
        end
    end

    local visibleRow_buffsub = math.floor(visibleCnt_buffsub / col_buffsub);
    if visibleRow_buffsub > 0 and visibleRow_buffsub % col_buffsub == 0 then
        visibleRow_buffsub = visibleRow_buffsub + 1;
    end
    visibleRow_buffsub = visibleRow_buffsub + 1;

    buffSub:Resize(buffSub:GetWidth(), default_sub_slot_y_offset * visibleRow_buffsub);
    buffSub:SetOffset(buffSub:GetX(), buffCount:GetY() + default_slot_y_offset * visibleRow_buffcount);
    SET_BUFF_CAPTION_OFFSET(frame, buffSub, buff_ui, 3);
    -------------------------------------------------------------------------------
    -- buff -----------------------------------------------------------------------
    local buff = GET_CHILD_RECURSIVELY(frame, "buffslot", "ui::CSlotSet");
    if buff == nil then
        return;
    end

    local col_buff = buff:GetCol();
    local slotCnt_buff = buff:GetRow() * col_buff;
    local visibleCnt_buff = 0;
    for i = 0, slotCnt_buff - 1 do
        local slot = buff:GetSlotByIndex(i);
        if slot == nil or slot:IsVisible() == 0 then
            visibleCnt_buff = i;
            break
        end
    end

    local visibleRow_buff = math.floor(visibleCnt_buff / col_buff);
    if visibleRow_buff > 0 and visibleRow_buff % col_buff == 0 then
        visibleRow_buff = visibleRow_buff + 1;
    end
    visibleRow_buff = visibleRow_buff + 1;

    buff:Resize(buff:GetWidth(), default_slot_y_offset * visibleRow_buff);
    buff:SetOffset(buff:GetX(), buffSub:GetY() + default_sub_slot_y_offset * visibleRow_buffsub);
    SET_BUFF_CAPTION_OFFSET(frame, buff, buff_ui, 1);
    -------------------------------------------------------------------------------
    -- pccastdebuff ---------------------------------------------------------------------
    local casterdebuff = GET_CHILD_RECURSIVELY(frame, "casterdebuffslot", "ui::CSlotSet");
    if casterdebuff == nil then
        return;
    end

    local col_casterdebuff = casterdebuff:GetCol();
    local slotCnt_casterdebuff = casterdebuff:GetRow() * col_casterdebuff;
    local visibleCnt_casterdebuff = 0;
    for i = 0, slotCnt_casterdebuff - 1 do
        local slot = casterdebuff:GetSlotByIndex(i);
        if slot == nil or slot:IsVisible() == 0 then
            visibleCnt_casterdebuff = i;
            break
        end
    end
    local visibleRow_casterdebuff = math.floor(visibleCnt_casterdebuff / col_casterdebuff);
    if visibleRow_casterdebuff > 0 and visibleRow_casterdebuff % col_casterdebuff == 0 then
        visibleRow_casterdebuff = visibleRow_casterdebuff + 1;
    end
    visibleRow_casterdebuff = visibleRow_casterdebuff + 1;

    casterdebuff:Resize(casterdebuff:GetWidth(), (default_slot_y_offset + 5) * visibleRow_casterdebuff);
    casterdebuff:SetOffset(casterdebuff:GetX(), buff:GetY() + (default_slot_y_offset) * visibleRow_buff);
    SEPARATEDPCDEBUFF_SET_BUFF_CAPTION_OFFSET(frame, casterdebuff, buff_ui, 4);
    -------------------------------------------------------------------------------
    -- debuff ---------------------------------------------------------------------
    local debuff = GET_CHILD_RECURSIVELY(frame, "debuffslot", "ui::CSlotSet");
    if debuff == nil then
        return;
    end

    local col_debuff = debuff:GetCol();
    local slotCnt_debuff = debuff:GetRow() * col_debuff;
    local visibleCnt_debuff = 0;
    for i = 0, slotCnt_debuff - 1 do
        local slot = debuff:GetSlotByIndex(i);
        if slot == nil or slot:IsVisible() == 0 then
            visibleCnt_debuff = i;
            break
        end
    end

    local visibleRow_debuff = math.floor(visibleCnt_debuff / col_debuff);
    if visibleRow_debuff > 0 and visibleRow_debuff % col_debuff == 0 then
        visibleRow_debuff = visibleRow_debuff + 1;
    end
    visibleRow_debuff = visibleRow_debuff + 1;

    debuff:Resize(debuff:GetWidth(), default_slot_y_offset * visibleRow_debuff);
    debuff:SetOffset(debuff:GetX(), casterdebuff:GetY() + (default_slot_y_offset + 15) * visibleRow_casterdebuff);
    SET_BUFF_CAPTION_OFFSET(frame, debuff, buff_ui, 2);
    -------------------------------------------------------------------------------
end

function SEPARATEDPCDEBUFF_SET_BUFF_CAPTION_OFFSET(frame, slotset, buff_ui, index)
    if index == 4 then
        if slotset:GetName() ~= "casterdebuffslot" then
            return;
        end
    end

    local captionlist = separatedpcdebuff_captionlist;
    local totalCount = slotset:GetRow() * slotset:GetCol();
    for i = 0, totalCount - 1 do
        local slot = slotset:GetSlotByIndex(i);
        if slot ~= nil then
            local row = math.floor(i / slotset:GetCol());
            local addHeight = 0;
            if row + 1 > 1 then
                if frame:GetName() == "targetbuff" then
                    addHeight = 12 * row + 1;
                else
                    addHeight = 15 * row + 1;
                end
            end
            local slotHeight = (slot:GetHeight() * (row + 1)) + addHeight;
            local caption = captionlist[i];
            caption:SetOffset(caption:GetX(), slotset:GetY() + slotHeight);
        end
    end
end

function SEPARATEDPCDEBUFF_ON_FRAME_INIT(frame)
    -- enable frame reposition through drag and move
    frame:EnableMove(0);
    frame:EnableHitTest(0);

    -- set default position of frame
    frame:Move(0, 0);
    frame:SetOffset(0, 0);

    -- set default size and visibility
    frame:ShowWindow(0);
end 

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)
    -- bool: true なら元の関数を実行後イベント、false/nil なら元の関数を実行せずイベント発行 (my_func_name はイベントハンドラとして呼ばれる)
    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end

    local origin_func = _G[origin_func_name]

    local function hooked_function(...)
        local original_results
        local original_success = false

        if bool == true then
            original_results = {pcall(origin_func, ...)}
            original_success = original_results[1]

            if not original_success then
                print(string.format("Error in original/previous hook for '%s': %s", origin_func_name,
                    tostring(original_results[2])))
                return
            end
        end

        g.ARGS = g.ARGS or {}
        g.ARGS[origin_func_name] = {...} -- この関数とセット運用：g.get_event_args(origin_func_name)
        imcAddOn.BroadMsg(origin_func_name)

        if bool == true and original_success then
            return table.unpack(original_results, 2, #original_results)
        else
            return -- nil を返す
        end
    end
    _G[origin_func_name] = hooked_function
    my_addon:RegisterMsg(origin_func_name, my_func_name)
end]]

--[[function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
end

g.origin_COMMON_BUFF_MSG = g.origin_COMMON_BUFF_MSG or nil
g.origin_TARGETBUFF_RESIZE = g.origin_TARGETBUFF_RESIZE or nil
g.origin_TARGET_BUFF_UPDATE = g.origin_TARGET_BUFF_UPDATE or nil

local function SEPARATEDPCDEBUFF_COMMON_BUFF_MSG(frame, msg, buffType, handle, buff_ui, buffIndex)
    SEPARATEDPCDEBUFF_COMMON_BUFF_MSG_(frame, msg, buffType, handle, buff_ui, buffIndex)
end

local function SEPARATEDPCDEBUFF_TARGETBUFF_RESIZE(frame, buff_ui)
    SEPARATEDPCDEBUFF_TARGETBUFF_RESIZE_(frame, buff_ui)
end

local function SEPARATEDPCDEBUFF_TARGET_BUFF_UPDATE(frame, timer, argStr, argNum, passedTime)
    SEPARATEDPCDEBUFF_TARGET_BUFF_UPDATE_(frame, timer, argStr, argNum, passedTime)
end

function separatedpcdebuff_dammy_COMMON_BUFF_MSG(frame, msg, buffType, handle, buff_ui, buffIndex)
    BUFF_TOTAL_COUNT_CHECK(frame, msg, buffType, handle, buff_ui, buffIndex);
    if msg == "SET" then
        local buffCount = info.GetBuffCount(handle);
        for i = 0, buffCount - 1 do
            local buff = info.GetBuffIndexed(handle, i);
            if buff ~= nil then
                separatedpcdebuff_dammy_COMMON_BUFF_MSG(frame, "ADD", buff.buffID, handle, buff_ui, buff.index);
            end
        end
        return;
    elseif msg == "CLEAR" then
        for i = 0, buff_ui["buff_group_cnt"] do
            local slotlist = buff_ui["slotlist"][i];
            local slotcount = buff_ui["slotcount"][i];
            local captionlist = buff_ui["captionlist"][i];
            if slotcount ~= nil and slotcount >= 0 then
                for i = 0, slotcount - 1 do
                    local slot = slotlist[i];
                    local text = captionlist[i];
                    slot:ShowWindow(0);
                    slot:ReleaseBlink();
                    text:SetText("");
                end
            end
        end
        frame:Invalidate();
        return;
    end

    if "None" == buffIndex or nil == buffIndex then
        buffIndex = 0;
    end

    buffIndex = tonumber(buffIndex);

    local class = GetClassByType('Buff', buffType);
    if class.ShowIcon == "FALSE" then
        return;
    end

    local slotlist;
    local slotcount;
    local captionlist;
    local colcnt = 0;
    local ApplyLimitCountBuff = "YES";

    local isOtherCastBuff = false;
    local buff = info.GetBuff(handle, buffType);
    if buff ~= nil then
        local casterHandle = buff:GetHandle();
        if casterHandle ~= nil and casterHandle ~= handle then
            isOtherCastBuff = true;
        end
    end

    if class.Group1 == 'Debuff' then
        slotlist = buff_ui["slotlist"][2];
        slotcount = buff_ui["slotcount"][2];
        captionlist = buff_ui["captionlist"][2];
        if nil ~= buff_ui["slotsets"][2] then
            colcnt = buff_ui["slotsets"][2]:GetCol();
        end
    else
        if class.ApplyLimitCountBuff == 'YES' then
            local slotlistIndex = 0;
            if isOtherCastBuff == true then
                slotlistIndex = 3;
            end

            slotlist = buff_ui["slotlist"][slotlistIndex];
            slotcount = buff_ui["slotcount"][slotlistIndex];
            captionlist = buff_ui["captionlist"][slotlistIndex];
            if nil ~= buff_ui["slotsets"][slotlistIndex] then
                colcnt = buff_ui["slotsets"][slotlistIndex]:GetCol();
            end
        else
            local slotlistIndex = 1;
            if isOtherCastBuff == true and (class.RemoveBySkill == "YES" or class.Lv < 4) then
                slotlistIndex = 3;
            end

            slotlist = buff_ui["slotlist"][slotlistIndex];
            slotcount = buff_ui["slotcount"][slotlistIndex];
            captionlist = buff_ui["captionlist"][slotlistIndex];
            if nil ~= buff_ui["slotsets"][slotlistIndex] then
                colcnt = buff_ui["slotsets"][slotlistIndex]:GetCol();
            end
            ApplyLimitCountBuff = "NO";
        end
    end

    if msg == 'ADD' then
        local skip = false
        if class ~= nil then
            if TryGetProp(class, 'OnlyOneBuff', 'None') == 'YES' and TryGetProp(class, 'Duplicate', 1) == 0 then
                local exist_slot, i = get_exist_debuff_in_slotlist(slotlist, buffType)
                if exist_slot ~= nil then
                    if exist_slot:IsVisible() == 0 then
                        SET_BUFF_SLOT(exist_slot, captionlist[i], class, buffType, handle, slotlist, buffIndex,
                            isOtherCastBuff);
                    end
                    skip = true
                end
            end
        end

        if skip == false then
            for j = 0, slotcount - 1 do
                local i = GET_BUFF_SLOT_INDEX(j, colcnt);
                local slot = slotlist[i];
                if slot:IsVisible() == 0 then
                    SET_BUFF_SLOT(slot, captionlist[i], class, buffType, handle, slotlist, buffIndex, isOtherCastBuff);
                    break
                end
            end
        end
    elseif msg == 'REMOVE' then
        for i = 0, slotcount - 1 do
            local slot = slotlist[i];
            local text = captionlist[i];
            local oldIcon = slot:GetIcon();
            if slot:IsVisible() == 1 then
                local oldBuffIndex = oldIcon:GetUserIValue("BuffIndex");
                local iconInfo = oldIcon:GetInfo();
                local isBuffIndexSame = oldBuffIndex - buffIndex;
                if iconInfo.type == buffType and isBuffIndexSame == 0 then
                    CLEAR_BUFF_SLOT(slot, text);
                    local j = GET_BUFF_ARRAY_INDEX(i, colcnt);
                    PULL_BUFF_SLOT_LIST(slotlist, captionlist, j, slotcount, colcnt, ApplyLimitCountBuff);
                    frame:Invalidate();
                    break
                end
            end
        end
        REMOVE_BUFF_COUNT_SLOT_SUB(frame, buff_ui, buffType, buffIndex, colcnt, ApplyLimitCountBuff);
    elseif msg == "UPDATE" then
        for i = 0, slotcount - 1 do
            local slot = slotlist[i];
            local text = captionlist[i];
            local oldIcon = slot:GetIcon();
            if slot:IsVisible() == 1 then
                local iconInfo = oldIcon:GetInfo();
                if iconInfo.type == buffType and oldIcon:GetUserIValue("BuffIndex") == buffIndex then
                    SET_BUFF_SLOT(slot, captionlist[i], class, buffType, handle, slotlist, buffIndex, isOtherCastBuff);
                    break
                end
            end
        end
    end

    ARRANGE_BUFF_SLOT(frame, buff_ui);
    COLONY_BATTLE_INFO_DRAW_BUFF_ICON();
end

function separatedpcdebuff_dammy_TARGET_BUFF_UPDATE(frame, timer, argStr, argNum, passedTime)
    local handle = session.GetTargetHandle();
    BUFF_TIME_UPDATE(handle, t_buff_ui);
end

function g.setup_hook()

    if _G['COMMON_BUFF_MSG'] then

        if not g.origin_COMMON_BUFF_MSG then
            g.origin_COMMON_BUFF_MSG = _G['COMMON_BUFF_MSG']
            local dammy_name = addonName .. "_dammy_COMMON_BUFF_MSG"
            _G[dammy_name] = g.origin_COMMON_BUFF_MSG
            _G['COMMON_BUFF_MSG'] = SEPARATEDPCDEBUFF_COMMON_BUFF_MSG
        end
    end

    if _G['TARGETBUFF_RESIZE'] then

        if not g.origin_TARGETBUFF_RESIZE then
            g.origin_TARGETBUFF_RESIZE = _G['TARGETBUFF_RESIZE']
            local dammy_name = addonName .. "_dammy_TARGETBUFF_RESIZE"
            _G[dammy_name] = g.origin_TARGETBUFF_RESIZE
            _G['TARGETBUFF_RESIZE'] = SEPARATEDPCDEBUFF_TARGETBUFF_RESIZE
        end
    end

    if _G['TARGET_BUFF_UPDATE'] then

        if not g.origin_TARGET_BUFF_UPDATE then
            g.origin_TARGET_BUFF_UPDATE = _G['TARGET_BUFF_UPDATE']
            local dammy_name = addonName .. "_dammy_TARGET_BUFF_UPDATE"
            _G[dammy_name] = g.origin_TARGET_BUFF_UPDATE
            _G['TARGET_BUFF_UPDATE'] = SEPARATEDPCDEBUFF_TARGET_BUFF_UPDATE
        end
    end
end]===]
