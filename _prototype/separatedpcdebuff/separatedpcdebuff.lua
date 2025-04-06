-- dofile("../data/addon_d/separatedpcdebuff/separatedpcdebuff.lua");
-- areas defined
local author = 'meldavy'
local addonName = 'separatedpcdebuff'
local ver = "2.0.0"
_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]
local acutil = require('acutil')

g.slot_count = 0
g.slot_list = {}
g.cap_list = {}

function SEPARATEDPCDEBUFF_ON_INIT(addon, frame)
    g.addon = addon;
    g.frame = frame;
    -- initialize frame
    local targetbuff = ui.GetFrame('targetbuff')
    -- t_buff_ui がどこから来るのか確認！ nil だとエラーになる
    if targetbuff and t_buff_ui then
        SEPARATEDPCDEBUFF_INIT_CASTER_DEBUFF_SLOT(targetbuff, t_buff_ui)
    end
    addon:RegisterMsg('TARGET_BUFF_ADD', 'separatedpcdebuff_TARGETBUFF_ON_MSG');
    addon:RegisterMsg('TARGET_BUFF_REMOVE', 'separatedpcdebuff_TARGETBUFF_ON_MSG');
    addon:RegisterMsg('TARGET_BUFF_UPDATE', 'separatedpcdebuff_TARGETBUFF_ON_MSG');
    addon:RegisterMsg('TARGET_SET', 'separatedpcdebuff_TARGETBUFF_ON_MSG');
    addon:RegisterMsg('TARGET_CLEAR', 'separatedpcdebuff_TARGETBUFF_ON_MSG');

end

function SEPARATEDPCDEBUFF_INIT_CASTER_DEBUFF_SLOT(targetbuff, buff_ui)

    local frame = ui.GetFrame("separatedpcdebuff")
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(300, 70)
    frame:SetPos(targetbuff:GetX(), targetbuff:GetY() + targetbuff:GetHeight() + 5)
    local my_db_ss = frame:GetChild("my_db_ss")
    if (my_db_ss == nil) then

        my_db_ss = frame:CreateOrGetControl("slotset", "my_db_ss", 0, 0, 300, 50)
        AUTO_CAST(my_db_ss)
        my_db_ss:SetColRow(6, 1)
        my_db_ss:SetSlotSize(50, 50)
        my_db_ss:SetSpc(2, 15)
        my_db_ss:CreateSlots();
    else
        AUTO_CAST(my_db_ss)
    end

    local childNames = {}
    local childCount = my_db_ss:GetChildCount()
    for i = 0, childCount - 1 do
        local child = my_db_ss:GetChildByIndex(i)
        table.insert(childNames, child:GetName())
    end

    for i, name in ipairs(childNames) do
        print(name)
    end

    g.slot_count = 0
    g.slot_list = {}
    g.cap_list = {}

    while 1 do
        if my_db_ss == nil then
            break
        end

        local slot = my_db_ss:GetSlotByIndex(g.slot_count);
        if slot == nil then
            break
        end

        g.slot_list[g.slot_count] = slot;
        slot:ShowWindow(1);
        local icon = CreateIcon(slot);
        icon:SetDrawCoolTimeText(0);
        local x = my_db_ss:GetX() + slot:GetX() + buff_ui["txt_x_offset"];
        local y = my_db_ss:GetY() + slot:GetY() + slot:GetHeight() + buff_ui["txt_y_offset"];

        local captWidth, captHeight = 50, 20;
        local capt = slot:CreateOrGetControl('richtext', "_t_" .. 4 .. "_" .. g.slot_count, x, y, captWidth, captHeight);
        capt:SetFontName("yellow_13");
        g.cap_list[g.slot_list] = capt;
        g.slot_count = g.slot_count + 1;
    end

    frame:ShowWindow(1)
end

function separatedpcdebuff_TARGETBUFF_ON_MSG(frame, msg, argStr, argNum)

    local frame = ui.GetFrame("separatedpcdebuff")
    local handle = session.GetTargetHandle();
    local buffCls = GetClassByType('Buff', argNum);

    local buffIndex = tonumber(argStr)

    local actor = world.GetActor(handle)
    local mon_cls = GetClassByType("Monster", actor:GetType())

    if TryGetProp(mon_cls, "MonRank", "None") ~= "Boss" then
        return
    end

    if buffCls ~= nil and buffCls.Group1 ~= "Debuff" then
        return
    end

    if msg == "TARGET_BUFF_ADD" then
        separatedpcdebuff_COMMON_BUFF_MSG(frame, "ADD", argNum, handle, t_buff_ui, argStr);
    elseif msg == "TARGET_BUFF_REMOVE" then
        separatedpcdebuff_COMMON_BUFF_MSG(frame, "REMOVE", argNum, handle, t_buff_ui, argStr);
    elseif msg == "TARGET_BUFF_UPDATE" then
        separatedpcdebuff_COMMON_BUFF_MSG(frame, "UPDATE", argNum, handle, t_buff_ui, argStr);
    elseif msg == "TARGET_CLEAR" then
        separatedpcdebuff_COMMON_BUFF_MSG(frame, "CLEAR", argNum, handle, t_buff_ui);
    end

    -- TARGET_BUFF_UPDATE(frame);
    -- TARGETBUFF_RESIZE(frame, t_buff_ui);
end

function separatedpcdebuff_COMMON_BUFF_MSG(frame, msg, buffType, handle, buff_ui, buffIndex)

    -- separatedpcdebuff_BUFF_TOTAL_COUNT_CHECK(frame, msg, buffType, handle, buff_ui, buffIndex);
    local slotset = frame:GetChild("my_db_ss")
    AUTO_CAST(slotset)
    CHAT_SYSTEM(msg)
    if msg == "CLEAR" then
        if (slotset ~= nil) then

            if g.slot_count ~= nil and g.slot_count >= 0 then
                for i = 0, g.slot_count - 1 do
                    local slot = g.slot_list[i];
                    local text = g.cap_list[i];
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

    local my_cast_debuff = false;
    local pcHandle = session.GetMyHandle();

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

    local slotlist;
    local slotcount;
    local captionlist;
    local colcnt = 0;
    local ApplyLimitCountBuff = "YES";

    slotlist = g.slot_list
    slotcount = g.slot_count
    captionlist = g.cap_list
    if nil ~= slotset then
        colcnt = slotset:GetCol();
    end

    if msg == 'ADD' then
        local skip = false
        if class ~= nil then
            if TryGetProp(class, 'OnlyOneBuff', 'None') == 'YES' and TryGetProp(class, 'Duplicate', 1) == 0 then
                local exist_slot, i = get_exist_debuff_in_slotlist(slotlist, buffType)
                if exist_slot ~= nil then
                    if exist_slot:IsVisible() == 0 then
                        SET_BUFF_SLOT(exist_slot, captionlist[i], class, buffType, handle, slotlist, buffIndex, false);
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
                    SET_BUFF_SLOT(slot, captionlist[i], class, buffType, handle, slotlist, buffIndex, false);
                    break
                end
            end
        end
    elseif msg == 'REMOVE' then

        -- try pc debuff list
        local my_db_ss = frame:GetChild("my_db_ss")
        AUTO_CAST(my_db_ss)
        slotlist = g.slot_list
        slotcount = g.slot_count
        captionlist = g.cap_list
        if nil ~= my_db_ss then
            colcnt = my_db_ss:GetCol();
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
                    SET_BUFF_SLOT(slot, captionlist[i], class, buffType, handle, slotlist, buffIndex, false);
                    break
                end
            end
        end
    end

    -- SEPARATEDPCDEBUFF_ARRANGE_BUFF_SLOT(frame, buff_ui);
    COLONY_BATTLE_INFO_DRAW_BUFF_ICON();
end

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
