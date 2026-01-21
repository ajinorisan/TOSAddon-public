local addon_name = "_NEXUS_ADDONS"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]
local json = require("json")

local function ts(...)
    local num_args = select("#", ...)
    if num_args == 0 then
        print("ts() -- 引数がありません")
        return
    end
    local string_parts = {}
    for i = 1, num_args do
        local arg = select(i, ...)
        local arg_type = type(arg)
        local is_success, value_str = pcall(tostring, arg)
        if not is_success then
            value_str = "[tostringでエラー発生]"
        end
        table.insert(string_parts, string.format("(%s) %s", arg_type, value_str))
    end
    print(table.concat(string_parts, "   |   "))
end
-- ancient_monster_bookshelf ここから
function ancient_monster_bookshelf_on_init()
    Ancient_monster_bookshelf_btn_init()
    g.addon:RegisterMsg('ANCIENT_CARD_COMBINE', 'Ancient_monster_bookshelf_on_ancient_card_update')
end

function Ancient_monster_bookshelf_btn_init()
    local ancient_card_list = ui.GetFrame("ancient_card_list")
    local btn = ancient_card_list:GetChildRecursively("topbg"):CreateOrGetControl("button", "btnopen", 0, 0, 90, 33)
    AUTO_CAST(btn)
    btn:SetGravity(ui.LEFT, ui.BOTTOM)
    btn:SetMargin(205, 0, 0, 0)
    btn:SetText("{ol}AMB")
    btn:SetEventScript(ui.LBUTTONUP, "Ancient_monster_bookshelf_init_frame")
end

function Ancient_monster_bookshelf_close()
    ui.DestroyFrame(addon_name_lower .. "amb")
end

function Ancient_monster_bookshelf_init_frame()
    ts("1")
    Ancient_monster_bookshelf_set_working(false)
    ts("2")
    local amb = ui.GetFrame(addon_name_lower .. "amb")
    if amb then
        Ancient_monster_bookshelf_close()
        return
    end
    amb = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "amb", 0, 0, 1090, 900)
    AUTO_CAST(amb)
    amb:RemoveAllChild()
    amb:SetSkinName("test_frame_low")
    amb:SetLayerLevel(92)
    amb:SetPos(300, 50)
    amb:Resize(1090, 900)
    amb:EnableHittestFrame(1)

    local title_gb = amb:CreateOrGetControl("groupbox", "title_gb", 0, 0, amb:GetWidth(), 55)
    AUTO_CAST(title_gb)
    title_gb:SetSkinName("test_frame_top")
    local title_text = title_gb:CreateOrGetControl("richtext", "title_text", 0, 0, ui.CENTER_HORZ, ui.TOP, 0, 15, 0, 0)
    AUTO_CAST(title_text)
    title_text:SetText('{ol}{s26}Ancient Monster Bookshelf')

    local close = amb:CreateOrGetControl("button", "close", 0, 0, 25, 25)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetOffset(1027, 18)
    close:SetEventScript(ui.LBUTTONUP, "Ancient_monster_bookshelf_close")

    local txt_slot = amb:CreateOrGetControl("richtext", "labelslot", 0, 0, 90, 33)
    AUTO_CAST(txt_slot)
    txt_slot:SetGravity(ui.TOP, ui.LEFT)
    txt_slot:SetMargin(20, 60, 0, 0)
    txt_slot:SetText("{ol}{s20}Assister Box")

    local txt_inv = amb:CreateOrGetControl("richtext", "labelinventory", 0, 0, 90, 33)
    AUTO_CAST(txt_inv)
    txt_inv:SetGravity(ui.TOP, ui.LEFT)
    txt_inv:SetMargin(570, 60, 0, 0)
    txt_inv:SetText("{ol}{s20}Inventory")

    local gbox = amb:CreateOrGetControl("groupbox", "gboxwk", 380, 670, 690, 220)
    AUTO_CAST(gbox)
    gbox:SetGravity(ui.TOP, ui.LEFT)
    gbox:SetSkinName("bg2")

    local btn_combine = gbox:CreateOrGetControl("button", "btncombine", 0, 0, 120, 40)
    AUTO_CAST(btn_combine)
    btn_combine:SetGravity(ui.BOTTOM, ui.RIGHT)
    btn_combine:SetMargin(0, 0, 40, 90)
    btn_combine:SetText("{s20}{ol}Combine")
    btn_combine:SetSkinName("test_red_button")
    btn_combine:SetEventScript(ui.LBUTTONUP, "Ancient_monster_bookshelf_do_action")
    btn_combine:SetEventScriptArgNumber(ui.LBUTTONUP, 1)

    local btn_cancel = gbox:CreateOrGetControl("button", "btncancel", 0, 0, 120, 40)
    AUTO_CAST(btn_cancel)
    btn_cancel:SetGravity(ui.BOTTOM, ui.RIGHT)
    btn_cancel:SetMargin(0, 0, 40, 40)
    btn_cancel:SetText("{s20}{ol}Cancel")
    btn_cancel:SetSkinName("test_gray_button")
    btn_cancel:SetEventScript(ui.LBUTTONUP, "Ancient_monster_bookshelf_on_cancel")

    local slot1 = gbox:CreateOrGetControl("slot", "slotcombine1", 0, 0, 100, 140)
    AUTO_CAST(slot1)
    slot1:SetGravity(ui.LEFT, ui.CENTER_VERT)
    slot1:SetMargin(20 + 100 * 0, 0, 0, 0)
    slot1:SetSkinName('accountwarehouse_slot')

    local slot2 = gbox:CreateOrGetControl("slot", "slotcombine2", 0, 0, 100, 140)
    AUTO_CAST(slot2)
    slot2:SetGravity(ui.LEFT, ui.CENTER_VERT)
    slot2:SetMargin(20 + 100 * 1, 0, 0, 0)
    slot2:SetSkinName('accountwarehouse_slot')

    local slot3 = gbox:CreateOrGetControl("slot", "slotcombine3", 0, 0, 100, 140)
    AUTO_CAST(slot3)
    slot3:SetGravity(ui.LEFT, ui.CENTER_VERT)
    slot3:SetMargin(20 + 100 * 2, 0, 0, 0)
    slot3:SetSkinName('accountwarehouse_slot')

    local slot_prod = gbox:CreateOrGetControl("slot", "slotcombineproduct", 0, 0, 100, 140)
    AUTO_CAST(slot_prod)
    slot_prod:SetGravity(ui.LEFT, ui.CENTER_VERT)
    slot_prod:SetMargin(20 + 100 * 3 + 30, 0, 0, 0)
    slot_prod:SetSkinName('accountwarehouse_slot')

    amb:ShowWindow(1)
    Ancient_monster_bookshelf_update()
end

function Ancient_monster_bookshelf_update()
    Ancient_monster_bookshelf_refresh_cardslots(false)
    Ancient_monster_bookshelf_refresh_cardslots(true)
    Ancient_monster_bookshelf_update_actions()
end

function Ancient_monster_bookshelf_refresh_cardslots(is_inv)
    local amb = ui.GetFrame(addon_name_lower .. "amb")
    local slot_set
    if not is_inv then
        local gbox = amb:CreateOrGetControl("groupbox", "gboxcards", 20, 90, 540, 570)
        slot_set = gbox:CreateOrGetControl("slotset", "slotcards", 0, 0, 540, 700)
        g.slotsetcards = slot_set
    else
        local gbox = amb:CreateOrGetControl("groupbox", "gboxcardsinv", 560, 90, 540, 570)
        slot_set = gbox:CreateOrGetControl("slotset", "slotcardsinv", 0, 0, 540, 700)
        g.slotsetinvs = slot_set
    end
    AUTO_CAST(slot_set)
    slot_set:SetSkinName('accountwarehouse_slot')
    slot_set:EnableDrag(0)
    slot_set:EnableDrop(0)
    slot_set:EnableSelection(0)
    slot_set:SetSlotSize(100, 140)
    slot_set:SetSpc(3, 3)

    local cards = Ancient_monster_bookshelf_get_all_cards(is_inv, not is_inv, false, true)
    local columns = 5
    slot_set:RemoveAllChild()
    slot_set:SetColRow(columns, math.max(1, math.ceil(#cards / columns)))
    slot_set:CreateSlots()
    slot_set:SetUserValue('islockedselectable', 1)

    for i, v in ipairs(cards) do
        local slot = slot_set:GetSlotByIndex(i - 1)
        if slot then
            AUTO_CAST(slot)
            -- LBUTTONDOWN から LBUTTONUP に変更、関数名も変更
            slot:SetEventScript(ui.LBUTTONUP, 'Ancient_monster_bookshelf_slot_on_lbtn_up')
            slot:SetEventScript(ui.MOUSEMOVE, 'Ancient_monster_bookshelf_slotset_on_mousemove')

            Ancient_monster_bookshelf_set_slot(slot, v, false)
            slot:Select(0)
        end
    end

    local txt_count = amb:CreateOrGetControl("richtext", "labelcardcount", 20, 670, 90, 33)
    AUTO_CAST(txt_count)
    local cnt = session.ancient.GetAncientCardCount()
    local max_cnt = GET_ANCIENT_CARD_SLOT_MAX()
    txt_count:SetText("{ol}{s20}Cards " .. cnt .. "/" .. max_cnt)
end

function Ancient_monster_bookshelf_slot_on_lbtn_up(frame, slot)
    -- デバッグログ: クリックされたら表示
    ts("Slot LBtn Down!")

    local parent = slot:GetParent()
    AUTO_CAST(slot)
    AUTO_CAST(parent)

    -- ロック判定
    local is_locked = slot:GetUserIValue('islocked') == 1
    local can_select_locked = parent:GetUserIValue('islockedselectable') == 1

    if is_locked and not can_select_locked then
        ts("-> Slot is locked")
        return
    end

    -- 選択状態の切り替え
    if slot:IsSelected() == 1 then
        slot:Select(0)
        ts("-> Unselected")
    else
        slot:Select(1)
        ts("-> Selected")
    end

    -- ボタン状態更新
    Ancient_monster_bookshelf_update_actions()
end

function Ancient_monster_bookshelf_create_card_data(card_obj, inv_item, is_locked, count, is_in_slot, is_in_inventory)
    local class_name = card_obj:GetClassName()
    local ancient_cls = GetClass("Ancient_Info", class_name)
    local rarity = ancient_cls.Rarity
    local cost = card_obj:GetCost()
    local guid = card_obj:GetGuid()
    local exp = card_obj:GetStrExp()
    local xp_info = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
    local level = xp_info.level
    local star_rank = card_obj.starrank or 1

    return {
        card = card_obj,
        cost = cost,
        rarity = rarity,
        guid = guid,
        invItem = inv_item,
        exp = exp,
        count = count,
        isinSlot = is_in_slot,
        isinInventory = is_in_inventory,
        name = ancient_cls.Name,
        islocked = is_locked,
        classname = class_name,
        starrank = star_rank,
        lv = level
    }
end

function Ancient_monster_bookshelf_deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Ancient_monster_bookshelf_deepcopy(orig_key)] = Ancient_monster_bookshelf_deepcopy(orig_value)
        end
        setmetatable(copy, Ancient_monster_bookshelf_deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- =========================================================================================
-- データ操作ロジック
-- =========================================================================================

function Ancient_monster_bookshelf_get_all_cards(no_live, no_inventory, no_locked, compact_inv_item)
    local cards = {}

    -- 装備・所持カードの収集
    if not no_live then
        for i = 0, 3 do
            local card = session.ancient.GetAncientCardBySlot(i)
            if card and (not no_locked or not card.isLock) then
                table.insert(cards, Ancient_monster_bookshelf_create_card_data(card, nil, card.isLock, 1, true, false))
            end
        end
        local cnt = session.ancient.GetAncientCardCount()
        for i = 0, cnt - 1 do
            local card = session.ancient.GetAncientCardByIndex(i)
            if card and card.slot > 3 and (not no_locked or not card.isLock) then
                table.insert(cards, Ancient_monster_bookshelf_create_card_data(card, nil, card.isLock, 1, false, false))
            end
        end
    end

    -- インベントリカードの収集
    if not no_inventory then
        local inv_item_list = session.GetInvItemList()
        local guid_list = inv_item_list:GetGuidList()
        local cnt = guid_list:Count()

        for i = 0, cnt - 1 do
            local guid = guid_list:Get(i)
            local inv_item = inv_item_list:GetItemByGuid(guid)
            local item_cls = GetClassByType('Item', inv_item.type)

            if item_cls and string.find(item_cls.ClassName, 'Ancient_Card_') then
                if not no_locked or not inv_item.isLockState then
                    local item_obj = GetIES(inv_item:GetObject())
                    local class_name = TryGetProp(item_obj, 'StringArg')
                    local ancient_cls = GetClass("Ancient_Info", class_name)

                    if ancient_cls then
                        local ancient_cost_cls = GetClassByType("Ancient_Rarity", ancient_cls.Rarity)

                        local dummy_card = {
                            GetStrExp = function()
                                return "0"
                            end,
                            GetClassName = function()
                                return class_name
                            end,
                            GetCost = function()
                                return ancient_cost_cls.Cost
                            end,
                            GetGuid = function()
                                return inv_item:GetIESID()
                            end,
                            level = 1,
                            starrank = 1,
                            rarity = ancient_cls.Rarity,
                            slot = 0
                        }

                        if compact_inv_item then
                            table.insert(cards, Ancient_monster_bookshelf_create_card_data(dummy_card, inv_item,
                                inv_item.isLockState, inv_item.count, false, true))
                        else
                            for j = 1, inv_item.count do
                                table.insert(cards, Ancient_monster_bookshelf_create_card_data(dummy_card, inv_item,
                                    inv_item.isLockState, 1, false, true))
                            end
                        end
                    end
                end
            end
        end
    end
    return cards
end

function Ancient_monster_bookshelf_get_card_by_guid(guid)
    local cards = {}
    local cardraw = session.ancient.GetAncientCardByGuid(guid)
    if cardraw then
        local classname = cardraw:GetClassName()
        local ancientCls = GetClass("Ancient_Info", classname)
        local exp = cardraw:GetStrExp()
        local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
        local level = xpInfo.level
        cards[#cards + 1] = {
            card = cardraw,
            cost = cardraw:GetCost(),
            rarity = ancientCls.Rarity,
            guid = cardraw:GetGuid(),
            invItem = nil,
            exp = exp,
            count = 1,
            isinSlot = false,
            isinInventory = false,
            name = ancientCls.Name,
            islocked = cardraw.isLock,
            classname = cardraw:GetClassName(),
            starrank = cardraw.starrank,
            lv = level
        }
        return cards
    end
    local cards_all = Ancient_monster_bookshelf_get_all_cards()
    for k, v in ipairs(cards_all) do
        if v.guid == guid then
            cards[#cards + 1] = v
            break
        end
    end
    return cards
end

function Ancient_monster_bookshelf_convert_inv_card_to_book_card(cards, nolocked)
    -- 現在の全カード情報を取得（在庫管理用）
    local cardsbook = Ancient_monster_bookshelf_get_all_cards(false, true, nolocked, false)
    local cards = Ancient_monster_bookshelf_deepcopy(cards)
    local out = {}

    -- 1. 既に登録済み（スロット/所持）のカードを処理
    for k, v in ipairs(cards) do
        if not v.isinInventory then
            -- cardsbook から GUID が一致するものを探して追加
            for kk, vv in ipairs(cardsbook) do
                if vv.guid == v.guid and cardsbook[kk].count > 0 then
                    table.insert(out, Ancient_monster_bookshelf_deepcopy(vv))
                    cardsbook[kk].count = cardsbook[kk].count - 1
                    break
                end
            end
        end
    end

    -- 2. インベントリにあるカードを処理
    for k, v in ipairs(cards) do
        if v.isinInventory then
            -- cardsbook から条件（ランク・レベル・クラス名）が一致するものを探して追加
            -- ※登録処理が完了していれば cardsbook に存在しているはず
            for kk, vv in ipairs(cardsbook) do
                if cardsbook[kk].count > 0 and vv.starrank == v.starrank and vv.lv == v.lv and vv.classname ==
                    v.classname then
                    table.insert(out, Ancient_monster_bookshelf_deepcopy(vv))
                    cardsbook[kk].count = cardsbook[kk].count - 1
                    break
                end
            end
        end
    end

    return out
end

-- =========================================================================================
-- 選択・合成ロジック
-- =========================================================================================

function Ancient_monster_bookshelf_get_selected_cards(compactinvitem)
    local cards = {}

    local function collect(slotset, name)
        if not slotset then
            ts("collect: slotset is nil for " .. name)
            return
        end

        local slotCount = slotset:GetSlotCount()
        -- ts("collect: Checking " .. name .. " (Count: " .. slotCount .. ")")

        for i = 0, slotCount - 1 do
            local slot = slotset:GetSlotByIndex(i)
            local icon = slot:GetIcon()

            -- 選択されているかチェック
            if slot:IsSelected() == 1 then
                local guid = icon and icon:GetUserValue("ANCIENT_GUID")
                ts("collect: Slot " .. i .. " SELECTED. GUID: " .. tostring(guid))

                if guid then
                    local all = Ancient_monster_bookshelf_get_all_cards(nil, nil, nil, true)
                    local found = false
                    for _, v in ipairs(all) do
                        if tostring(v.guid) == tostring(guid) then
                            found = true
                            if compactinvitem then
                                table.insert(cards, deepcopy(v))
                            else
                                for k = 1, v.count do
                                    local c = deepcopy(v)
                                    c.count = 1
                                    table.insert(cards, c)
                                end
                            end
                            break
                        end
                    end
                    if not found then
                        ts("collect: Card data NOT found for GUID: " .. tostring(guid))
                    end
                else
                    ts("collect: Icon or GUID missing for selected slot " .. i)
                end
            end
        end
    end

    collect(g.slotsetcards, "Cards")
    collect(g.slotsetinvs, "Invs")
    return cards
end

function Ancient_monster_bookshelf_get_cards_count(cards)
    local count = 0
    for _, v in ipairs(cards) do
        count = count + v.count
    end
    return count
end

function Ancient_monster_bookshelf_can_combine()
    local cards = Ancient_monster_bookshelf_get_selected_cards()
    local count = Ancient_monster_bookshelf_get_cards_count(cards)

    ts("CanCombine: Selected Count =", count)

    if count < 3 then
        ts("-> Count < 3 (Need 3)")
        return false
    end

    local base = cards[1]
    for i, v in ipairs(cards) do
        if base.rarity ~= v.rarity then
            ts("-> Rarity Mismatch! Base:", base.rarity, "Target:", v.rarity, "Index:", i)
            return false
        end
    end

    ts("-> Combine OK!")
    return true
end

-- アクション定義
g.actions = {{
    text = "{#00FFFF}Auto Combine",
    action = function(cards)
        Ancient_monster_bookshelf_combine(cards)
    end,
    state = function()
        return Ancient_monster_bookshelf_can_combine()
    end
}}

function Ancient_monster_bookshelf_update_actions()
    local frame = ui.GetFrame(addon_name_lower .. "amb")
    if not frame then
        return
    end

    local btncombine = frame:GetChildRecursively("btncombine")
    if btncombine then
        local is_enable = 0

        -- 状態確認ログ
        local can_combine = Ancient_monster_bookshelf_can_combine()
        ts("UpdateActions: Working:", tostring(g.amb_working), "CanCombine:", tostring(can_combine))

        if not g.amb_working and can_combine then
            is_enable = 1
        end
        btncombine:SetEnable(is_enable)
    end
end

function Ancient_monster_bookshelf_do_action(frame, ctrl, argstr, argnum)
    local cards = Ancient_monster_bookshelf_get_selected_cards(false)
    if g.actions[argnum] then
        g.actions[argnum].action(cards)
    end
end

-- 合成ロジック
function Ancient_monster_bookshelf_combine(cards)
    if g.amb_working then
        return
    end
    g.amb_wkcards = cards
    ui.MsgBox('Do you want to combine?', string.format('Ancient_monster_bookshelf_do_combine()'), 'None')
end

function Ancient_monster_bookshelf_do_combine()
    g.amb_wkinit = Ancient_monster_bookshelf_get_cards_count(Ancient_monster_bookshelf_get_selected_cards(false))
    Ancient_monster_bookshelf_set_working(true)
    Ancient_monster_bookshelf_combine_process_next()
end

function Ancient_monster_bookshelf_set_working(is_working)
    g.amb_working = is_working

    local amb = ui.GetFrame(addon_name_lower .. "amb")

    if is_working == false then
        -- フレームがある場合のみUI更新とスクリプト停止を行う
        if amb then
            Ancient_monster_bookshelf_update()

            amb:StopUpdateScript("Ancient_monster_bookshelf_process_register_queue")
            amb:StopUpdateScript("Ancient_monster_bookshelf_combine_process_watchdog")
            amb:StopUpdateScript("Ancient_monster_bookshelf_retry_prepare_next")
        end

        -- 変数のクリア（これはフレームがなくても実行する）
        g.amb_wkcards = nil
        g.amb_wkcombine = nil
        g.amb_wkinit = nil
        g.amb_wkreuse = nil
        g.amb_wkcards_before = nil
        g.amb_reg_queue = nil
        g.amb_next_guid = nil
        g.amb_retry_count = 0
    end

    -- アクション更新もフレームが必要
    if amb then
        Ancient_monster_bookshelf_update_actions()
    end
end

function Ancient_monster_bookshelf_combine_process_next(reuse_card)
    ts("Process Next: Start")
    local status, err = pcall(function()
        local cards = g.amb_wkcards
        if not cards then
            ts("Process Next: No cards")
            return
        end

        local classname_list = {}
        for _, v in ipairs(cards) do
            classname_list[v.classname] = (classname_list[v.classname] or 0) + v.count
        end

        local list = {}
        for k, v in pairs(classname_list) do
            table.insert(list, {
                classname = k,
                count = v
            })
        end

        local pick = {}
        local first_card = nil
        local is_same_class = true
        local start_index = 1

        if reuse_card then
            table.insert(pick, reuse_card)
            first_card = reuse_card
            start_index = 2
            ts("Process Next: Reusing card", reuse_card.classname)
        end

        local wkcards_copy = Ancient_monster_bookshelf_deepcopy(g.amb_wkcards)

        for i = start_index, 3 do
            table.sort(list, function(a, b)
                return a.count > b.count
            end)
            local found = false
            for k, v in ipairs(list) do
                if v.count > 0 then
                    local skip = false -- passからskipに変更
                    if i == 1 then
                        first_card = v
                    else
                        if v.classname == first_card.classname then
                            if i == 3 and is_same_class then
                                skip = true -- 3枚目が1,2枚目と同じならスキップして次を探す
                            end
                        else
                            is_same_class = false
                        end
                    end

                    if not skip then
                        for kk, vv in ipairs(wkcards_copy) do
                            if vv.classname == v.classname then
                                table.insert(pick, Ancient_monster_bookshelf_deepcopy(vv))
                                table.remove(wkcards_copy, kk)
                                list[k].count = list[k].count - 1
                                found = true
                                break
                            end
                        end
                    end
                    if found then
                        break
                    end
                end
            end
        end

        ts("Process Next: Picked count =", #pick)

        if #pick < 3 then
            ui.SysMsg("[AMB] Complete.")
            Ancient_monster_bookshelf_set_working(false)
            return
        end

        local inv_card_count = 0
        for _, v in ipairs(pick) do
            if v.isinInventory then
                inv_card_count = inv_card_count + 1
            end
        end

        if GET_ANCIENT_CARD_SLOT_MAX() - session.ancient.GetAncientCardCount() < inv_card_count then
            ui.SysMsg("[AMB] Insufficient Card Slot.")
            Ancient_monster_bookshelf_set_working(false)
            return
        end

        g.amb_wkreuse = reuse_card
        g.amb_wkcards_before = g.amb_wkcards
        g.amb_wkcards = wkcards_copy
        g.amb_wkcombine = pick

        -- インベントリからの登録をキューに入れて順次実行
        g.amb_reg_queue = {}
        for _, v in ipairs(pick) do
            if v.isinInventory then
                table.insert(g.amb_reg_queue, v.guid)
            end
        end

        ts("Process Next: Register Queue Size =", #g.amb_reg_queue)

        local amb = ui.GetFrame(addon_name_lower .. "amb")
        amb:RunUpdateScript("Ancient_monster_bookshelf_process_register_queue", 0.2)
    end)

    if not status then
        print("[AMB] Error in combine_process_next: " .. tostring(err))
        ts("Error:", err)
        Ancient_monster_bookshelf_set_working(false)
    end
end

function Ancient_monster_bookshelf_process_register_queue(amb)
    if not g.amb_reg_queue or #g.amb_reg_queue == 0 then
        ts("Register Queue: Empty, calling Combine Do")
        -- キューが空になったら合成実行へ
        amb:RunUpdateScript("Ancient_monster_bookshelf_combine_process_do", 0.5)
        return 0
    end

    local guid = table.remove(g.amb_reg_queue, 1)
    ts("Register Queue: Registering GUID", guid)

    if _G["ANCIENT_CARD_REGISTER_C"] then
        _G["ANCIENT_CARD_REGISTER_C"](guid)
    end

    return 1 -- 0.2秒後に次を実行
end

function Ancient_monster_bookshelf_combine_process_do(amb)
    ts("Combine Do: Start")
    if g.amb_wkcombine == nil then
        ts("Combine Do: wkcombine is nil")
        return 0
    end

    -- リトライカウンターの初期化
    g.amb_retry_count = g.amb_retry_count or 0

    -- Watchdog check
    for _, v in ipairs(g.amb_wkcombine) do
        local cards = Ancient_monster_bookshelf_get_card_by_guid(v.guid)
        if #cards == 0 then
            g.amb_retry_count = g.amb_retry_count + 1
            if g.amb_retry_count > 5 then
                print("[AMB] Retry limit exceeded. Aborting.")
                Ancient_monster_bookshelf_set_working(false)
                return 0
            end

            ts("Combine Do: Card not found, retrying... (" .. g.amb_retry_count .. "/5)", v.guid)
            g.amb_wkcards = g.amb_wkcards_before
            amb:StopUpdateScript("Ancient_monster_bookshelf_combine_process_watchdog")

            g.amb_next_guid = g.amb_wkreuse and g.amb_wkreuse.guid or "nil"
            amb:RunUpdateScript("Ancient_monster_bookshelf_retry_prepare_next", 0.5)
            return 0
        end
    end

    -- 成功したらカウンターをリセット
    g.amb_retry_count = 0

    local cards = Ancient_monster_bookshelf_convert_inv_card_to_book_card(g.amb_wkcombine, true)
    ts("Combine Do: Converted cards count =", #cards)

    if #cards < 3 then
        ts("Combine Do: Insufficient converted cards, retrying...")
        g.amb_wkcards = g.amb_wkcards_before
        amb:StopUpdateScript("Ancient_monster_bookshelf_combine_process_watchdog")

        g.amb_next_guid = g.amb_wkreuse and g.amb_wkreuse.guid or "nil"
        amb:RunUpdateScript("Ancient_monster_bookshelf_retry_prepare_next", 0.5)
        return 0
    end

    ts("Combine Do: Executing ReqCombineAncientCard")
    amb:RunUpdateScript("Ancient_monster_bookshelf_combine_process_watchdog", 1)

    imcSound.PlaySoundEvent("market_sell")
    ReqCombineAncientCard(cards[1].guid, cards[2].guid, cards[3].guid)
    return 0
end

function Ancient_monster_bookshelf_combine_process_watchdog(amb)
    amb:StopUpdateScript("Ancient_monster_bookshelf_combine_process_watchdog")

    print("[AMB] Combine timeout, retrying...")
    g.amb_wkcards = g.amb_wkcards_before

    g.amb_next_guid = g.amb_wkreuse and g.amb_wkreuse.guid or "nil"
    amb:RunUpdateScript("Ancient_monster_bookshelf_retry_prepare_next", 0.5)
    return 0
end

function Ancient_monster_bookshelf_retry_prepare_next(amb)
    local guid = g.amb_next_guid
    Ancient_monster_bookshelf_combine_process_prepare_next(guid)
    return 0
end

function Ancient_monster_bookshelf_combine_process_prepare_next(guid)
    if not g.amb_wkcombine then
        return
    end

    local card = nil
    if guid and guid ~= "nil" then
        local getcards = Ancient_monster_bookshelf_get_card_by_guid(guid)
        if #getcards == 0 then
            -- まだカード情報が更新されていない場合は待つ
            g.amb_next_guid = guid
            local amb = ui.GetFrame(addon_name_lower .. "amb")
            if amb then
                amb:RunUpdateScript("Ancient_monster_bookshelf_retry_prepare_next", 0.5)
            end
            return
        end

        local c = getcards[1]
        if c and c.rarity == g.amb_wkcombine[1].rarity and c.rarity < 4 then
            card = c
        end
    end

    Ancient_monster_bookshelf_combine_process_next(card)
end

function Ancient_monster_bookshelf_on_ancient_card_update(frame, msg, guid, slot)
    if g.amb_working then
        if msg == "ANCIENT_CARD_COMBINE" and g.amb_wkcombine then
            Ancient_monster_bookshelf_update()

            local amb = ui.GetFrame(addon_name_lower .. "amb")
            amb:StopUpdateScript("Ancient_monster_bookshelf_combine_process_watchdog")

            local getcards = Ancient_monster_bookshelf_get_card_by_guid(guid)
            local slot1 = amb:GetChildRecursively("slotcombine1")
            local slot2 = amb:GetChildRecursively("slotcombine2")
            local slot3 = amb:GetChildRecursively("slotcombine3")
            local slot_prod = amb:GetChildRecursively("slotcombineproduct")

            if slot1 then
                Ancient_monster_bookshelf_set_slot(AUTO_CAST(slot1), g.amb_wkcombine[1], false, true)
            end
            if slot2 then
                Ancient_monster_bookshelf_set_slot(AUTO_CAST(slot2), g.amb_wkcombine[2], false, true)
            end
            if slot3 then
                Ancient_monster_bookshelf_set_slot(AUTO_CAST(slot3), g.amb_wkcombine[3], false, true)
            end

            if slot_prod and #getcards > 0 then
                Ancient_monster_bookshelf_set_slot(AUTO_CAST(slot_prod), getcards[1], false, true)
            end

            -- 次の合成へ
            g.amb_next_guid = guid
            amb:RunUpdateScript("Ancient_monster_bookshelf_retry_prepare_next", 0.5)
        end
    end
end

function Ancient_monster_bookshelf_set_slot(slot, v, nodesc, notooltip)
    slot:ClearIcon()
    slot:RemoveAllChild()

    -- ★追加: スロット自体のヒットテストを有効化
    slot:EnableHitTest(1)

    local icon = CreateIcon(slot)
    local mon_cls = GetClass("Monster", v.classname)
    if not mon_cls then
        return
    end

    local icon_name = TryGetProp(mon_cls, "Icon")

    slot:EnableDrag(0)
    slot:EnableDrop(0)
    slot:SetUserValue('islocked', v.islocked and 1 or 0)

    if nodesc == nil then
        nodesc = false
    end

    local rarity = v.rarity
    if rarity == 1 then
        icon:SetImage("normal_card")
    elseif rarity == 2 then
        icon:SetImage("rare_card")
    elseif rarity == 3 then
        icon:SetImage("unique_card")
    elseif rarity == 4 then
        icon:SetImage("legend_card")
    end

    local pic = slot:CreateOrGetControl('picture', 'pic', 0, 0, 44, 44)
    AUTO_CAST(pic)
    pic:SetGravity(ui.CENTER_HORZ, ui.TOP)
    pic:SetMargin(0, 23, 0, 0)
    pic:SetImage(icon_name)
    pic:SetEnableStretch(1)
    pic:EnableHitTest(0) -- 画像は透過してスロットをクリックさせる

    if nodesc == false then
        local star_str = ''
        for ii = 1, v.starrank do
            star_str = star_str .. string.format("{img monster_card_starmark %d %d}", 15, 15)
        end
        local starr = slot:CreateOrGetControl("richtext", 'rank', 0, 0, 60, 20)
        starr:SetGravity(ui.LEFT, ui.BOTTOM)
        starr:SetMargin(0, 0, 0, 0)
        starr:SetText(star_str)
        starr:EnableHitTest(0)
        starr:SetSkinName('bg2')

        local state_text = slot:CreateOrGetControl('richtext', 'state', 0, 0, 40, 20)
        local state_str = ''
        if v.isinSlot then
            state_str = state_str .. '{img icon_item_ancient_card 20 20}'
        end
        if v.isinInventory then
            state_str = state_str .. '{img icon_item_farm47_sack_01 20 20}'
        end
        if v.islocked then
            state_str = state_str .. '{img inven_lock2 15 20}'
        end
        state_text:SetGravity(ui.RIGHT, ui.BOTTOM)
        state_text:SetMargin(0, 0, 0, 0)
        state_text:SetText(state_str)
        state_text:EnableHitTest(0)
        state_text:SetSkinName('bg')

        if v.isinInventory and v.invItem then
            local count_text = slot:CreateOrGetControl('richtext', 'count', 0, 0, 40, 20)
            count_text:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
            count_text:SetMargin(0, 0, 0, 0)
            count_text:SetText('{s20}{ol}x' .. v.invItem.count .. "")
            count_text:EnableHitTest(0)
            count_text:SetSkinName("bg")
        end

        local cost_text = slot:CreateOrGetControl('richtext', 'cost', 0, 0, 30, 30)
        cost_text:SetGravity(ui.RIGHT, ui.TOP)
        cost_text:SetMargin(3, 3, 3, 3)
        cost_text:SetText('{#44FFFF}{@st41}{s18}' .. tostring(v.cost))
        cost_text:EnableHitTest(0)
        cost_text:SetSkinName('none')

        local rarity_color = ''
        if rarity == 1 then
            rarity_color = '{#ffffff}'
        elseif rarity == 2 then
            rarity_color = '{#0e7fe8}'
        elseif rarity == 3 then
            rarity_color = '{#d92400}'
        elseif rarity == 4 then
            rarity_color = '{#ffa800}'
        end

        local lv_str = rarity_color .. '{ol}{@st41}{s18}' .. rarity_color .. 'Lv' .. v.lv
        local lv_text = slot:CreateOrGetControl('richtext', 'lv', 0, 0, 30, 30)
        lv_text:SetGravity(ui.LEFT, ui.TOP)
        lv_text:SetMargin(3, 3, 3, 3)
        lv_text:SetText(lv_str)
        lv_text:EnableHitTest(0)
        lv_text:SetSkinName('none')

        local name_str = '{ol}{s14}' .. rarity_color .. mon_cls.Name
        local name_text = slot:CreateOrGetControl('richtext', 'name', 0, 0, 30, 30)
        name_text:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
        name_text:SetMargin(0, 0, 0, 24)
        name_text:SetText(name_str)
        name_text:EnableHitTest(0)
        name_text:SetSkinName('none')
    end

    if not notooltip then
        icon:SetTooltipType("ancient_card")
        icon:SetTooltipStrArg(v.guid)
        icon:SetUserValue("ANCIENT_GUID", v.guid)
    end
end

function Ancient_monster_bookshelf_on_cancel()
    Ancient_monster_bookshelf_set_working(false)
end

-- ancient_monster_bookshelf ここまで
