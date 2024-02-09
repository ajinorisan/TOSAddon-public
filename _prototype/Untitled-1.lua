function indun_panel_item_use(frame, ctrl, argStr, argNum)

    session.ResetItemList()
    local invItemList = session.GetInvItemList()
    local guidList = invItemList:GetGuidList();
    local cnt = guidList:Count();

    local count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", argNum).PlayPerResetType)

    if argNum == 647 then

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            local life_time = GET_REMAIN_ITEM_LIFE_TIME(itemobj)

            if life_time ~= nil then

                if classid == 10820018 and count == 0 and tonumber(life_time) < 86400 then

                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end

                if classid == 11030067 and count == 0 then

                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end
            end
        end

        local dcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
        if dcount == 1 and count == 0 then
            indun_panel_buyuse(frame, ctrl, "PVP_MINE_41", argNum)
            return
        end

        local wcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")
        if wcount >= 1 and count == 0 then
            g.ex = 1
            indun_panel_buyuse(frame, ctrl, "PVP_MINE_42", argNum)
            return
        end

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID

            if classid == 10820018 and count == 0 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            end

        end

    elseif argNum == 644 then

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            local life_time = GET_REMAIN_ITEM_LIFE_TIME(itemobj)

            if life_time ~= nil then
                if classid == 10820019 and count == 1 and tonumber(life_time) < 86400 then

                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end

                if classid == 641954 and count == 1 then

                    INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                    return
                end
            end
        end

        local trade_count = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_40")
        if trade_count >= 1 and count == 1 then
            indun_panel_buyuse(frame, ctrl, "PVP_MINE_40", argNum)
            return
        end

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local classid = itemobj.ClassID
            if classid == 10820019 and count == 1 then
                INV_ICON_USE(session.GetInvItemByType(tonumber(classid)))
                return
            end
        end

    end

end

function INDUN_PANEL_ITEM_BUY_USE(recipeName)

    local recipeCls = GetClass("ItemTradeShop", recipeName)
    session.ResetItemList()
    session.AddItemID(tostring(0), 1)
    local itemlist = session.GetItemIDList()
    local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1))
    item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText)

    local itemCls = GetClass("Item", recipeCls.TargetItem)
    ReserveScript(string.format("INV_ICON_USE(session.GetInvItemByType(%d));", recipeCls.ClassID), 1)
    return

end

function indun_panel_buyuse(frame, ctrl, recipeName, indunType)

    if recipeName == "PVP_MINE_52" then
        local count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indunType).PlayPerResetType)
        local trade_count = GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", indunType).PlayPerResetType)
        if count == 1 and trade_count == 1 then

            INDUN_PANEL_ITEM_BUY_USE(recipeName)

        elseif count == 1 and trade_count == 0 then
            local vel_recipecls = GetClass('ItemTradeShop', recipeName);
            local vel_overbuy_max = TryGetProp(vel_recipecls, 'MaxOverBuyCount', 0)

            if vel_overbuy_max >= 1 then
                INDUN_PANEL_ITEM_BUY_USE(recipeName)

                return
            else
                ui.SysMsg("No trade count.")
                return
            end
        end
    elseif indunType == 647 then

        INDUN_PANEL_ITEM_BUY_USE(recipeName)

    elseif indunType == 646 then

        INDUN_PANEL_ITEM_BUY_USE(recipeName)

    end

end

function indun_panel_item_overbuy_use(recipeCls)

    session.ResetItemList()
    session.AddItemID(tostring(0), 1)
    local itemlist = session.GetItemIDList()
    local cntText = string.format("%s %s", tostring(recipeCls.ClassID), tostring(1))
    item.DialogTransaction("PVP_MINE_SHOP", itemlist, cntText)
    -- local itemCls = GetClass("Item", recipeCls.TargetItem)
    ReserveScript(string.format("INV_ICON_USE(session.GetInvItemByType(%d));", recipeCls.ClassID), 1)
    return
end

function indun_panel_velnice_buyuse()

    if GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 201).PlayPerResetType) == 1 then
        local recipeName = "PVP_MINE_52"
        INDUN_PANEL_ITEM_BUY_USE(recipeName)
    else
        ui.SysMsg("The number of remains")
        return
    end

end

function indun_panel_singularity_buyuse()

    local dcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_41")
    local wcount = INDUN_PANEL_GET_RECIPE_TRADE_COUNT("PVP_MINE_42")
    if GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 647).PlayPerResetType) == 0 then
        if dcount == 0 then
            local recipeName = "PVP_MINE_42"
            INDUN_PANEL_ITEM_BUY_USE(recipeName)
        else
            g.ex = 1
            local recipeName = "PVP_MINE_41"
            INDUN_PANEL_ITEM_BUY_USE(recipeName)

        end
    else
        ui.SysMsg("The number Challenge EX remains")
    end
end

function indun_panel_challenge_buyuse()

    if GET_CURRENT_ENTERANCE_COUNT(GetClassByType("Indun", 646).PlayPerResetType) == 1 then
        local recipeName = "PVP_MINE_40"
        INDUN_PANEL_ITEM_BUY_USE(recipeName)
    else
        ui.SysMsg("The number of challenge remains")
    end
end

