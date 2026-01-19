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

function ancient_monster_bookshelf_on_init()
    Ancient_monster_bookshelf_btn_init()
    g.addon:RegisterMsg('ANCIENT_CARD_COMBINE', 'Ancient_monster_bookshelf_on_ancient_card_update')
    g.addon:RegisterMsg('ANCIENT_CARD_EVOLVE', 'Ancient_monster_bookshelf_on_ancient_card_update')
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

function Ancient_monster_bookshelf_init_frame()
    ui.DestroyFrame(addon_name_lower .. "amb")
    local amb = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "amb", 0, 0, 1270, 900)
    AUTO_CAST(amb)
    amb:RemoveAllChild()
    amb:SetSkinName("test_frame_low")
    amb:SetLayerLevel(92)
    amb:SetPos(300, 50)
    -- amb:SetGravity(ui.TOP, ui.CENTER_VERT)
    amb:Resize(1270, 900)
    amb:SetTitleBarSkin("None")
    amb:EnableHittestFrame(1)
    local txt_slot = amb:CreateOrGetControl("richtext", "labelslot", 0, 0, 90, 33)
    AUTO_CAST(txt_slot)
    txt_slot:SetGravity(ui.TOP, ui.LEFT)
    txt_slot:SetMargin(16, 120, 0, 0)
    txt_slot:SetText("{ol}{s20}Assister Box")
    local txt_inv = amb:CreateOrGetControl("richtext", "labelinventory", 0, 0, 90, 33)
    AUTO_CAST(txt_inv)
    txt_inv:SetGravity(ui.TOP, ui.LEFT)
    txt_inv:SetMargin(566, 120, 0, 0)
    txt_inv:SetText("{ol}{s20}Inventory")
    local txt_count = amb:CreateOrGetControl("richtext", "labelcardcount", 0, 0, 90, 33)
    AUTO_CAST(txt_count)
    txt_count:SetGravity(ui.LEFT, ui.BOTTOM)
    txt_count:SetMargin(40, 0, 0, 60)
    txt_count:SetText("{ol}{s20}Cards")
    local gauge = amb:CreateOrGetControl("gauge", "progresscardcount", 0, 0, 500, 16)
    AUTO_CAST(gauge)
    gauge:SetGravity(ui.LEFT, ui.BOTTOM)
    gauge:SetMargin(40, 0, 0, 30)
    gauge:SetDrawStyle(ui.GAUGE_DRAW_CELL)
    gauge:SetCellPoint(1)
    gauge:SetSkinName("dot_skillslot")
    local gbox = amb:CreateOrGetControl("groupbox", "gboxwk", 0, 0, 800, 220)
    AUTO_CAST(gbox)
    gbox:SetGravity(ui.RIGHT, ui.BOTTOM)
    gbox:SetMargin(0, 0, 20, 10)
    gbox:SetSkinName("bg2")
    local txt_prog = gbox:CreateOrGetControl("richtext", "txtprogress", 0, 0, 66, 140)
    AUTO_CAST(txt_prog)
    txt_prog:SetGravity(ui.LEFT, ui.TOP)
    txt_prog:SetMargin(20, 20, 0, 0)
    txt_prog:SetText("{ol}Workbench")
    local btn_cancel = gbox:CreateOrGetControl("button", "btncancel", 0, 0, 120, 40)
    AUTO_CAST(btn_cancel)
    btn_cancel:SetGravity(ui.BOTTOM, ui.RIGHT)
    btn_cancel:SetMargin(0, 0, 40, 40)
    btn_cancel:SetText("{s20}{ol}Cancel")
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
    --[[Ancient_monster_bookshelf_refresh_cardslots(false)
    Ancient_monster_bookshelf_refresh_cardslots(true)
    Ancient_monster_bookshelf_update_actions()]]
end

--[[local addon_name = "ANCIENT_MONSTER_BOOKSHELF"
local addon_name_lower = string.lower(addon_name)
local author = "ebisuke"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local acutil = require('acutil')

g.version = 0
g.settings = g.settings or {
    x = 300,
    y = 300,
    style = 0
}
g.wkcards = nil
g.wkcombine = nil
g.wkinit = nil
g.working = false
g.wkreuse = nil
g.wkcards_before = nil
g.configurepattern = {}
g.settings_file_loc = string.format('../addons/%s/settings.json', addon_name_lower)
g.framename = 'ancient_monster_bookshelf'
g.debug = false
g.cardsize = {100, 140}

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

local function DBGOUT(msg)
    if g.debug == true then
        CHAT_SYSTEM(msg)
        print(msg)
    end
end

local function ERROUT(msg)
    CHAT_SYSTEM(msg)
    print(msg)
end

-- ロジックテーブル
g.aam = {
    get_selected_slot_indices = function(slotset)
        local selected = {}
        for i = 0, slotset:GetSlotCount() - 1 do
            local slot = slotset:GetSlotByIndex(i)
            if slot:GetIcon() ~= nil then
                if slot:IsSelected() == 1 then
                    selected[#selected + 1] = true
                else
                    selected[#selected + 1] = false
                end
            end
        end
        return selected
    end,

    get_selected_cards = function(compactinvitem)
        local frame = g.frame
        local cards = g.aam.get_selected_slots_as_card(AUTO_CAST(frame:GetChildRecursively("slotcards")), compactinvitem)
        local cardsinv = g.aam.get_selected_slots_as_card(AUTO_CAST(frame:GetChildRecursively("slotcardsinv")), compactinvitem)
        for k, v in ipairs(cardsinv) do
            cards[#cards + 1] = v
        end
        return cards
    end,

    convert_inv_card_to_book_card = function(cards, nolocked)
        local frame = g.frame
        local cardsbook = g.aam.get_all_cards(false, true, nolocked, false)
        local cards = deepcopy(cards)
        local out = {}
        for k, v in ipairs(cards) do
            if not v.isinInventory then
                -- 既にブックにあるカード
            else
                for kk, vv in ipairs(cardsbook) do
                    if cards[k].isinInventory == false and cards[k].count > 0 and cardsbook[kk].count > 0 and vv.guid == v.guid then
                        out[#out + 1] = deepcopy(vv)
                        cardsbook[kk].count = cardsbook[kk].count - 1
                        cards[k].count = cards[k].count - 1
                        break
                    end
                end
            end
        end
        for k, v in ipairs(cards) do
            if v.isinInventory then
                for kk, vv in ipairs(cardsbook) do
                    if cards[k].count > 0 and cardsbook[kk].count > 0 and vv.starrank == v.starrank and vv.lv == v.lv and vv.classname == v.classname then
                        out[#out + 1] = deepcopy(vv)
                        cardsbook[kk].count = cardsbook[kk].count - 1
                        cards[k].count = cards[k].count - 1
                        break
                    end
                end
            end
        end
        return out
    end,

    get_selected_slots_as_card = function(slotset, compactinvitem)
        local aamcards = {}
        local ref = g.aam.get_all_cards(nil, nil, nil, true)
        for i = 0, slotset:GetSlotCount() - 1 do
            local slot = slotset:GetSlotByIndex(i)
            local icon = slot:GetIcon()
            if icon and slot:IsSelected() == 1 then
                local guid = icon:GetUserValue("ANCIENT_GUID")
                if guid then
                    for k, v in ipairs(ref) do
                        if v.guid == guid then
                            if compactinvitem then
                                aamcards[#aamcards + 1] = deepcopy(v)
                                table.remove(ref, k)
                                break
                            else
                                for i = 1, ref[k].count do
                                    aamcards[#aamcards + 1] = deepcopy(v)
                                    aamcards[#aamcards].count = 1
                                end
                                table.remove(ref, k)
                                break
                            end
                        end
                    end
                end
            end
        end
        return aamcards
    end,

    get_same_stat_cards = function(cards)
        local assisters = g.aam.get_all_cards(true, true)
        local sames = {}
        for k, v in ipairs(cards) do
            for kk, vv in ipairs(assisters) do
                if vv.islocked == false and vv.classname == v.classname and vv.lv == v.lv then
                    sames[#sames + 1] = vv
                    table.remove(assisters, kk)
                    break
                end
            end
        end
        return sames
    end,

    get_same_rarity_cards = function(cards)
        local assisters = g.aam.get_all_cards(true, true)
        local sames = {}
        for k, v in ipairs(cards) do
            for kk, vv in ipairs(assisters) do
                if vv.islocked == false and vv.rarity == v.rarity then
                    sames[#sames + 1] = vv
                    table.remove(assisters, kk)
                    break
                end
            end
        end
        return sames
    end,

    get_cards_count = function(cards, noinv)
        local count = 0
        for k, v in ipairs(cards) do
            if not noinv or not v.isinInventory then
                count = count + v.count
            end
        end
        return count
    end,

    get_card_by_guid = function(guid)
        local cards = {}
        local cardraw = session.ancient.GetAncientCardByGuid(guid)
        if cardraw then
            local classname = cardraw:GetClassName()
            local ancientCls = GetClass("Ancient_Info", classname)
            local exp = cardraw:GetStrExp()
            local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
            local level = xpInfo.level
            cards[#cards + 1] = {
                card = cardraw, cost = cardraw:GetCost(), rarity = ancientCls.Rarity, guid = cardraw:GetGuid(), invItem = nil, exp = exp, count = 1,
                isinSlot = false, isinInventory = false, name = ancientCls.Name, islocked = cardraw.isLock, classname = cardraw:GetClassName(), starrank = cardraw.starrank, lv = level
            }
            return cards
        end

        local card
        local cards_all = g.aam.get_all_cards()
        for k, v in ipairs(cards_all) do
            if v.guid == guid then
                card = v
                break
            end
        end
        if card == nil then
            return {}
        end
        local classname = card.card:GetClassName()
        local ancientCls = GetClass("Ancient_Info", classname)
        local exp = card.card:GetStrExp()
        local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
        local level = xpInfo.level

        cards[#cards + 1] = {
            card = card, cost = card.card:GetCost(), rarity = ancientCls.Rarity, guid = card.card:GetGuid(), invItem = nil, exp = exp, count = card.count,
            isinSlot = false, isinInventory = card.isinInventory, name = ancientCls.Name, islocked = card.isLock, classname = card.card:GetClassName(), starrank = card.starrank, lv = level
        }

        return cards
    end,

    get_all_cards = function(nolive, noinventory, nolocked, compactinvitem)
        local cards = {}
        if not nolive then
            for i = 0, 3 do
                local card = session.ancient.GetAncientCardBySlot(i)
                if card then
                    local classname = card:GetClassName()
                    local ancientCls = GetClass("Ancient_Info", classname)
                    local exp = card:GetStrExp()
                    local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
                    local level = xpInfo.level
                    if not nolocked or not card.isLock then
                        cards[#cards + 1] = {
                            card = card, cost = card:GetCost(), rarity = ancientCls.Rarity, guid = card:GetGuid(), invItem = nil, exp = exp, count = 1,
                            isinSlot = true, isinInventory = false, name = ancientCls.Name, islocked = card.isLock, classname = card:GetClassName(), starrank = card.starrank, lv = level
                        }
                    end
                end
            end
            local cnt = session.ancient.GetAncientCardCount()

            for i = 0, cnt - 1 do
                local card = session.ancient.GetAncientCardByIndex(i)
                if card and card.slot > 3 then
                    local classname = card:GetClassName()
                    local ancientCls = GetClass("Ancient_Info", classname)
                    local exp = card:GetStrExp()
                    local xpInfo = gePetXP.GetXPInfo(gePetXP.EXP_ANCIENT, tonumber(exp))
                    local level = xpInfo.level
                    if not nolocked or not card.isLock then
                        cards[#cards + 1] = {
                            card = card, cost = card:GetCost(), rarity = ancientCls.Rarity, guid = card:GetGuid(), invItem = nil, exp = exp, count = 1,
                            isinSlot = false, isinInventory = false, name = ancientCls.Name, islocked = card.isLock, classname = card:GetClassName(), starrank = card.starrank, lv = level
                        }
                    end
                end
            end
        end
        if not noinventory then
            local invItemList = session.GetInvItemList()

            FOR_EACH_INVENTORY(invItemList, function(invItemList, invItem)
                local class = GetClassByType('Item', invItem.type)
                if class.ClassName:find('Ancient_Card_') then
                    local classname = TryGetProp(GetIES(invItem:GetObject()), 'StringArg')
                    local ancientCls = GetClass("Ancient_Info", classname)
                    local ancientCostCls = GetClassByType("Ancient_Rarity", ancientCls.Rarity)
                    if compactinvitem then
                        if not nolocked or not invItem.isLockState then
                            cards[#cards + 1] = {
                                card = {
                                    GetStrExp = function(self) return "0" end,
                                    GetClassName = function(self) return classname end,
                                    GetCost = function(self) return ancientCostCls.Cost end,
                                    GetGuid = function(self) return invItem:GetIESID() end,
                                    level = 1,
                                    starrank = 1,
                                    rarity = ancientCls.Rarity,
                                    slot = 0,
                                },
                                cost = ancientCostCls.Cost, rarity = ancientCls.Rarity, guid = invItem:GetIESID(), invItem = invItem, exp = 0, count = invItem.count,
                                isinSlot = false, isinInventory = true, name = ancientCls.Name, islocked = invItem.isLockState, classname = classname, starrank = 1, lv = 1
                            }
                        end
                    else
                        for i = 1, invItem.count do
                            if not nolocked or not invItem.isLockState then
                                cards[#cards + 1] = {
                                    card = {
                                        GetStrExp = function(self) return "0" end,
                                        GetClassName = function(self) return classname end,
                                        GetCost = function(self) return ancientCostCls.Cost end,
                                        GetGuid = function(self) return invItem:GetIESID() end,
                                        level = 1,
                                        starrank = 1,
                                        rarity = ancientCls.Rarity,
                                        slot = 0,
                                    },
                                    cost = ancientCostCls.Cost, rarity = ancientCls.Rarity, guid = invItem:GetIESID(), invItem = invItem, exp = 0, count = 1,
                                    isinSlot = false, isinInventory = true, name = ancientCls.Name, islocked = invItem.isLockState, classname = classname, starrank = 1, lv = 1
                                }
                            end
                        end
                    end
                end
            end, false)
        end
        return cards
    end,

    actions = {
        {
            text = "Deselect All",
            action = function(cards)
                for i = 0, g.slotsetcards:GetSlotCount() - 1 do
                    local slot = g.slotsetcards:GetSlotByIndex(i)
                    slot:Select(0)
                end
                for i = 0, g.slotsetinvs:GetSlotCount() - 1 do
                    local slot = g.slotsetinvs:GetSlotByIndex(i)
                    slot:Select(0)
                end
            end,
            state = function() return true end
        },
        {
            text = "Lock",
            action = function(cards) Ancient_monster_bookshelf_lock(cards, true) end,
            state = function() return true end
        },
        {
            text = "Unlock",
            action = function(cards) Ancient_monster_bookshelf_lock(cards, false) end,
            state = function() return true end
        },
        {
            text = "{#00FF00}Evolve",
            action = function(cards) Ancient_monster_bookshelf_evolve(cards) end,
            state = function() return g.aam.is_unsafe() and g.aam.is_all_unlocked() and g.aam.can_evolve() end
        },
        {
            text = "{#00FFFF}Auto Combine",
            action = function(cards) Ancient_monster_bookshelf_combine(cards) end,
            state = function() return g.aam.is_unsafe() and g.aam.is_all_unlocked() and g.aam.can_combine() and (g.aam.get_cards_count(g.aam.get_selected_cards()) >= 3) end
        },
    },

    is_unsafe = function()
        local frame = g.frame
        local chk = frame:GetChildRecursively("chkmode")
        AUTO_CAST(chk)
        return chk:IsChecked() == 0
    end,

    is_all_unlocked = function()
        local cards = g.aam.get_selected_cards()
        for _, v in ipairs(cards) do
            if v.islocked == true then
                return false
            end
        end
        return true
    end,

    is_all_inv = function()
        local cards = g.aam.get_selected_cards()
        if #cards == 0 then
            return false
        end
        for _, v in ipairs(cards) do
            if not v.isinInventory then
                return false
            end
        end
        return true
    end,

    can_evolve = function()
        local cards = g.aam.get_selected_cards()
        if g.aam.get_cards_count(cards) < 3 then
            return false
        end
        local base = cards[1]
        for _, v in ipairs(cards) do
            if base.classname ~= v.classname or base.starrank ~= v.starrank then
                return false
            end
        end
        return true
    end,

    can_combine = function()
        local cards = g.aam.get_selected_cards()
        if g.aam.get_cards_count(cards) < 3 then
            return false
        end
        local base = cards[1]
        for _, v in ipairs(cards) do
            if base.rarity ~= v.rarity then
                return false
            end
        end
        return true
    end,
}

-- 初期化
function Ancient_monster_bookshelf_on_init(addon, frame)
    g.addon = addon
    g.frame = ui.GetFrame(g.framename)
    
    if not g.loaded then
        g.loaded = true
    end
    Ancient_monster_bookshelf_init_frame()
    addon:RegisterMsg('ANCIENT_CARD_COMBINE', 'Ancient_monster_bookshelf_on_ancient_card_update')
    addon:RegisterMsg('ANCIENT_CARD_EVOLVE', 'Ancient_monster_bookshelf_on_ancient_card_update')
end



function Ancient_monster_bookshelf_update()
    Ancient_monster_bookshelf_refresh_cardslots(false)
    Ancient_monster_bookshelf_refresh_cardslots(true)
    Ancient_monster_bookshelf_update_actions()
end

function Ancient_monster_bookshelf_update_actions()
    local frame = ui.GetFrame(g.framename)
    local gbox = frame:CreateOrGetControl("groupbox", "gboxaction", 0, 0, 150, frame:GetHeight() - 300)
    gbox:SetGravity(ui.RIGHT, ui.TOP)
    gbox:SetMargin(0, 150, 20, 0)
    for k, v in ipairs(g.aam.actions) do
        local btn = gbox:CreateOrGetControl("button", 'btn' .. k, 0, 32 * (k - 1), 150, 30)
        btn:SetText(v.text)
        btn:SetEventScript(ui.LBUTTONUP, "Ancient_monster_bookshelf_do_action")
        btn:SetEventScriptArgNumber(ui.LBUTTONUP, k)
        if v.state and g.working == false then
            if v.state() then
                btn:SetEnable(1)
            else
                btn:SetEnable(0)
            end
        else
            btn:SetEnable(0)
        end
    end
end

function Ancient_monster_bookshelf_do_action(frame, ctrl, argstr, argnum)
    frame = g.frame
    local cards = g.aam.get_selected_cards(false)
    g.aam.actions[argnum].action(cards)
end

function Ancient_monster_bookshelf_lock(aamcards, lock)
    local delay = 0.0
    aamcards = g.aam.get_selected_cards(true)
    Ancient_monster_bookshelf_set_working(true)
    local sentguid = {}
    for _, v in ipairs(aamcards) do
        if not sentguid[v.guid] then
            if v.isinInventory then
                if v.islocked ~= lock then
                    ReserveScript(string.format("session.inventory.SendLockItem('%s', %d)", v.guid, BoolToNumber(lock)), delay)
                    delay = delay + 0.8
                end
            else
                if v.islocked ~= lock then
                    ReserveScript(string.format("ReqLockAncientCard('%s')", v.guid), delay)
                    delay = delay + 0.8
                end
            end
            sentguid[v.guid] = true
        end
    end
    delay = delay + 0
    ReserveScript(string.format("Ancient_monster_bookshelf_set_working(false)"), delay)
    return delay
end

function Ancient_monster_bookshelf_toggle()
    ui.ToggleFrame(g.framename)
end

function Ancient_monster_bookshelf_on_open()
    local frame = g.frame
    local chk = frame:GetChildRecursively("chkmode")
    AUTO_CAST(chk)
    chk:SetCheck(1)
    Ancient_monster_bookshelf_update()
end

function Ancient_monster_bookshelf_refresh_cardslots(isinv)
    local frame = ui.GetFrame(g.framename)
    local slotset
    if not isinv then
        local gbox = frame:CreateOrGetControl("groupbox", "gboxcards", 20, 150, 540, 500)
        slotset = gbox:CreateOrGetControl("slotset", "slotcards", 0, 0, 540, 700)
        g.slotsetcards = slotset
    else
        local gbox = frame:CreateOrGetControl("groupbox", "gboxcardsinv", 560, 150, 540, 500)
        slotset = gbox:CreateOrGetControl("slotset", "slotcardsinv", 0, 0, 540, 700)
        g.slotsetinvs = slotset
    end
    AUTO_CAST(slotset)
    slotset:SetSkinName('accountwarehouse_slot')
    slotset:EnableDrag(0)
    slotset:EnableDrop(0)
    slotset:EnableSelection(0)
    slotset:SetSlotSize(g.cardsize[1], g.cardsize[2])
    slotset:SetSpc(3, 3)
    local cards = g.aam.get_all_cards(isinv, not isinv, false, true)
    if g.aam.sort then
        table.sort(cards, g.aam.sort)
    end
    local columns = 5
    slotset:RemoveAllChild()
    slotset:SetColRow(columns, math.max(1, math.ceil(#cards / columns)))
    slotset:CreateSlots()
    
    slotset:SetUserValue('islockedselectable', 1)
    for i, v in ipairs(cards) do
        local slot = slotset:GetSlotByIndex(i - 1)
        if slot then
            AUTO_CAST(slot)
            slot:SetEventScript(ui.MOUSEMOVE, 'Ancient_monster_bookshelf_slotset_on_mousemove')
            Ancient_monster_bookshelf_set_slot(slot, v, false)
            slot:Select(0)
        end
    end
    
    local gauge = frame:GetChild("progresscardcount")
    AUTO_CAST(gauge)
    gauge:SetStatFont(0, "yellow_14_b")
    local cnt = session.ancient.GetAncientCardCount()
    local max_cnt = GET_ANCIENT_CARD_SLOT_MAX()
    gauge:SetTextStat(0, cnt .. "/" .. max_cnt)
    gauge:SetMaxPoint(max_cnt)
    gauge:SetCurPoint(cnt)
    local txt = frame:CreateOrGetControl("richtext", "labelcardcountnum", 0, 0, 90, 33)
    AUTO_CAST(txt)
    txt:SetGravity(ui.LEFT, ui.BOTTOM)
    txt:SetMargin(140, 0, 0, 60)
    txt:SetText("{ol}{s20}" .. cnt .. "/" .. max_cnt)
end

function Ancient_monster_bookshelf_set_slot(slot, v, nodesc, notooltip)
    slot:ClearIcon()
    slot:RemoveAllChild()
    local icon = CreateIcon(slot)
    local monCls = GetClass("Monster", v.classname)
    local iconName = TryGetProp(monCls, "Icon")
    slot:EnableDrag(0)
    slot:EnableDrop(0)
    
    slot:SetUserValue('islocked', BoolToNumber(v.islocked))
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
    pic:SetImage(iconName)
    pic:SetEnableStretch(1)
    pic:EnableHitTest(0)
    if nodesc == false then
        local starStr = ''
        for ii = 1, v.starrank do
            starStr = starStr .. string.format("{img monster_card_starmark %d %d}", 15, 15)
        end
        local starr = slot:CreateOrGetControl("richtext", 'rank', 0, 0, 60, 20)
        starr:SetGravity(ui.LEFT, ui.BOTTOM)
        starr:SetMargin(0, 0, 0, 0)
        starr:SetText(starStr)
        starr:EnableHitTest(0)
        starr:SetSkinName('bg2')
        local statetext = slot:CreateOrGetControl('richtext', 'state', 0, 0, 40, 20)
        local stateStr = ''
        if v.isinSlot then
            stateStr = stateStr .. '{img icon_item_ancient_card 20 20}'
        end
        if v.isinInventory then
            stateStr = stateStr .. '{img icon_item_farm47_sack_01 20 20}'
        end
        if v.islocked then
            stateStr = stateStr .. '{img inven_lock2 15 20}'
        end
        statetext:SetGravity(ui.RIGHT, ui.BOTTOM)
        statetext:SetMargin(0, 0, 0, 0)
        statetext:SetText(stateStr)
        statetext:EnableHitTest(0)
        statetext:SetSkinName('bg')
        if v.isinInventory then
            local statetext = slot:CreateOrGetControl('richtext', 'count', 0, 0, 40, 20)
            statetext:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
            statetext:SetMargin(0, 0, 0, 0)
            statetext:SetText('{s20}{ol}x' .. v.invItem.count .. "")
            statetext:EnableHitTest(0)
            statetext:SetSkinName("bg")
        end
        local costtext = slot:CreateOrGetControl('richtext', 'cost', 0, 0, 30, 30)
        costtext:SetGravity(ui.RIGHT, ui.TOP)
        costtext:SetMargin(3, 3, 3, 3)
        costtext:SetText('{#44FFFF}{@st41}{s18}' .. tostring(v.cost))
        costtext:EnableHitTest(0)
        costtext:SetSkinName('none')
        local ancientCls = GetClass("Ancient_Info", monCls.ClassName)
        local rarity = ancientCls.Rarity
        local raritycolor = ''
        if rarity == 1 then
            raritycolor = '{#ffffff}'
        elseif rarity == 2 then
            raritycolor = '{#0e7fe8}'
        elseif rarity == 3 then
            raritycolor = '{#d92400}'
        elseif rarity == 4 then
            raritycolor = '{#ffa800}'
        end
        local lvstr = raritycolor .. '{ol}{@st41}{s18}' .. raritycolor .. 'Lv' .. v.lv
        local lvtext = slot:CreateOrGetControl('richtext', 'lv', 0, 0, 30, 30)
        lvtext:SetGravity(ui.LEFT, ui.TOP)
        lvtext:SetMargin(3, 3, 3, 3)
        lvtext:SetText(lvstr)
        lvtext:EnableHitTest(0)
        lvtext:SetSkinName('none')
        local namestr = '{ol}{s14}' .. raritycolor .. monCls.Name
        local nametext = slot:CreateOrGetControl('richtext', 'name', 0, 0, 30, 30)
        nametext:SetGravity(ui.CENTER_HORZ, ui.BOTTOM)
        nametext:SetMargin(0, 0, 0, 24)
        nametext:SetText(namestr)
        nametext:EnableHitTest(0)
        nametext:SetSkinName('none')
    end
    if not notooltip then
        icon:SetTooltipType("ancient_card")
        icon:SetTooltipStrArg(v.guid)
        icon:SetUserValue("ANCIENT_GUID", v.guid)
    end
end

function Ancient_monster_bookshelf_slotset_on_mousemove(frame, slot)
    local parent = slot:GetParent()
    AUTO_CAST(slot)
    local state = tonumber(parent:GetUserValue("lbtnpressed"))
    if mouse.IsLBtnPressed() == 1 then
        if state == nil then
            if slot:IsSelected() == 1 then
                state = 0
            else
                state = 1
            end
            parent:SetUserValue('lbtnpressed', tostring(state))
        end
        if (slot:GetUserIValue('islocked') == 1 and parent:GetUserIValue('islockedselectable') ~= 1) then
            state = 0
        end
        if slot:IsSelected() ~= state then
            slot:Select(state)
            Ancient_monster_bookshelf_update_actions()
        end
    else
        state = nil
        parent:SetUserValue('lbtnpressed', nil)
    end
end

function Ancient_monster_bookshelf_set_sort(_, _, _, type)
    if type == nil then
        g.aam.sort = nil
    else
        if type == 1 then
            -- by rarity
            g.aam.sort = function(a, b)
                if a.rarity == b.rarity then
                    if a.starrank == b.starrank then
                        return a.name < b.name
                    end
                    return a.starrank > b.starrank
                end
                return a.rarity > b.rarity
            end
        elseif type == 2 then
            -- by rank
            g.aam.sort = function(a, b)
                if a.starrank == b.starrank then
                    if a.rarity == b.rarity then
                        return a.name < b.name
                    end
                    return a.rarity > b.rarity
                end
                return a.starrank > b.starrank
            end
        elseif type == 3 then
            -- by level
            g.aam.sort = function(a, b)
                if a.lv == b.lv then
                    return a.name < b.name
                end
                return a.lv > b.lv
            end
        elseif type == 4 then
            -- by name
            g.aam.sort = function(a, b)
                if a.name == b.name then
                    return a.starrank > b.starrank
                end
                return a.name < b.name
            end
        end
    end
    Ancient_monster_bookshelf_init_frame()
end

function Ancient_monster_bookshelf_on_sort()
    local context = ui.CreateContextMenu('context_menusort', '', 0, 10, 200, 200)
    ui.AddContextMenuItem(context, 'No Sort', 'Ancient_monster_bookshelf_set_sort(nil,nil,nil,nil)')
    ui.AddContextMenuItem(context, 'Sort by Rarity', 'Ancient_monster_bookshelf_set_sort(nil,nil,nil,1)')
    ui.AddContextMenuItem(context, 'Sort by Rank', 'Ancient_monster_bookshelf_set_sort(nil,nil,nil,2)')
    ui.AddContextMenuItem(context, 'Sort by Level', 'Ancient_monster_bookshelf_set_sort(nil,nil,nil,3)')
    ui.AddContextMenuItem(context, 'Sort by Name', 'Ancient_monster_bookshelf_set_sort(nil,nil,nil,4)')
    ui.OpenContextMenu(context)
end

function Ancient_monster_bookshelf_evolve(cards)
    if g.working then
        return
    end
    local basecard = cards[1]
    local delay = 0
    local adds = g.aam.get_cards_count(cards, true) + 1
    local cardsforfind = g.aam.get_all_cards(true, false, true, false)
    local invcards = {}
    for i = adds, 3 do
        local found = false
        for k, v in ipairs(cardsforfind) do
            if v.starrank == basecard.starrank and v.classname == basecard.classname then
                cards[#cards + 1] = deepcopy(v)
                found = true
                invcards[#invcards + 1] = deepcopy(v)
                table.remove(cardsforfind, k)
                break
            end
        end
        if found == false then
            ERROUT("[AMB]Card not found.")
            return
        end
    end
    
    if GET_ANCIENT_CARD_SLOT_MAX() - session.ancient.GetAncientCardCount() < #invcards then
        ui.SysMsg("[AMB]Insufficient Card Slot.")
        return
    end
    for k, v in ipairs(invcards) do
        ReserveScript(string.format("ANCIENT_CARD_REGISTER_C('%s')", v.guid), delay)
        delay = delay + 0.25
    end
    Ancient_monster_bookshelf_set_working(true)
    g.wkcards = cards
    ReserveScript(string.format("Ancient_monster_bookshelf_do_evolve()"), delay)
    delay = delay + 0.25
    ReserveScript(string.format("Ancient_monster_bookshelf_set_working(false)"), delay)
end

function Ancient_monster_bookshelf_set_working(wk)
    g.working = wk
    if wk == false then
        Ancient_monster_bookshelf_update()
        local frame = ui.GetFrame(g.framename)
        local gauge = frame:GetChildRecursively("progresscombine")
        AUTO_CAST(gauge)
        gauge:SetCurPoint(0)
        g.wkcards = nil
        g.wkcombine = nil
        g.wkinit = nil
    else
        Ancient_monster_bookshelf_update_actions()
    end
end

function Ancient_monster_bookshelf_combine(cards)
    if g.working then
        return
    end
    g.wkcards = cards
    ui.MsgBox('Do you want to combine?', string.format('Ancient_monster_bookshelf_do_combine()'), 'None')
end

function Ancient_monster_bookshelf_do_combine()
    g.wkinit = g.aam.get_cards_count(g.aam.get_selected_cards(false))
    Ancient_monster_bookshelf_set_working(true)
    Ancient_monster_bookshelf_combine_process_next()
end

function Ancient_monster_bookshelf_combine_process_next(reusecard)
    local cards = g.wkcards
    
    local classnamelist = {}
    for k, v in ipairs(cards) do
        if not classnamelist[v.classname] then
            classnamelist[v.classname] = v.count
        else
            classnamelist[v.classname] = classnamelist[v.classname] + v.count
        end
    end
    -- reformat
    local list = {}
    for k, v in pairs(classnamelist) do
        list[#list + 1] = {classname = k, count = v}
    end
    
    -- 多い順から3つピックアップ
    local first = nil
    local same = true
    local cursor = 1
    local pick = {}
    local cd = 1
    
    -- 再利用
    if reusecard then
        pick[#pick + 1] = reusecard
        cd = 2
        first = reusecard
    end
    local wkcards = deepcopy(g.wkcards)
    local i
    for i = cd, 3 do
        -- 多い順にソート
        table.sort(list, function(a, b) return a.count > b.count end)
        
        local brk = false
        for k, v in ipairs(list) do
            local pass = false
            if v.count > 0 then
                if i == 1 then
                    first = v
                end
                
                for kk, vv in ipairs(wkcards) do
                    if i == 1 then
                    else
                        if v.classname == first.classname then
                            if i == 3 and same == true then
                                -- continue
                                pass = true
                            end
                        else
                            same = false
                        end
                    end
                    
                    if not pass then
                        if vv.classname == v.classname then
                            pick[#pick + 1] = deepcopy(vv)
                            table.remove(wkcards, kk)
                            list[k].count = list[k].count - 1
                            brk = true
                            break
                        end
                    end
                end
                if brk then
                    break
                end
            end
        end
    end
    if #pick < 3 then
        ui.SysMsg("[AMB]Complete.")
        Ancient_monster_bookshelf_set_working(false)
        return
    end
    local invCardCount = 0
    for _, v in ipairs(pick) do
        if v.isinInventory then
            invCardCount = invCardCount + 1
        end
    end
    if GET_ANCIENT_CARD_SLOT_MAX() - session.ancient.GetAncientCardCount() < invCardCount then
        ui.SysMsg("[AMB]Insufficient Card Slot.")
        Ancient_monster_bookshelf_set_working(false)
        return
    end
    g.wkreuse = reusecard
    g.wkcards_before = g.wkcards
    g.wkcards = wkcards
    local delay = 0.2
    g.wkcombine = pick
    -- インベントリにあるなら引き出す
    for k, v in ipairs(pick) do
        if v.isinInventory then
            ReserveScript(string.format("ANCIENT_CARD_REGISTER_C('%s')", v.guid), delay)
            delay = delay + 0.25
        end
    end
    delay = delay + 0.8
    ReserveScript(string.format("Ancient_monster_bookshelf_combine_process_do()"), delay)
    delay = delay + 0.25
end

function Ancient_monster_bookshelf_combine_process_do()
    if g.wkcombine == nil then
        return
    end
    -- Watchdog
    local frame = ui.GetFrame(g.framename)

    for k, v in ipairs(g.wkcombine) do
        if not g.aam.get_card_by_guid(v.guid) then
            -- retry
            g.wkcards = g.wkcards_before
            
            frame:StopUpdateScript("Ancient_monster_bookshelf_combine_process_watchdog", 1)
            ReserveScript(string.format("Ancient_monster_bookshelf_combine_process_prepare_next('%s')", g.wkreuse), 0.5)
            return
        end
    end
    
    local cards = g.aam.convert_inv_card_to_book_card(g.wkcombine, true)
    if #cards < 3 then
        g.wkcards = g.wkcards_before
        
        frame:StopUpdateScript("Ancient_monster_bookshelf_combine_process_watchdog", 1)
        ReserveScript(string.format("Ancient_monster_bookshelf_combine_process_prepare_next('%s')", g.wkreuse), 0.5)
        return
    end
    
    frame:RunUpdateScript("Ancient_monster_bookshelf_combine_process_watchdog", 1)
    imcSound.PlaySoundEvent("market_sell")
    ReqCombineAncientCard(cards[1].guid, cards[2].guid, cards[3].guid)
end

function Ancient_monster_bookshelf_combine_process_watchdog()
    local frame = ui.GetFrame(g.framename)
    
    frame:StopUpdateScript("Ancient_monster_bookshelf_combine_process_watchdog", 1)
    g.wkcards = g.wkcards_before
    ReserveScript(string.format("Ancient_monster_bookshelf_combine_process_prepare_next('%s')", g.wkreuse), 0.5)
end

function Ancient_monster_bookshelf_do_evolve()
    imcSound.PlaySoundEvent("market_sell")
    local cards = g.aam.convert_inv_card_to_book_card(g.wkcards, true)
    ReqEvolveAncientCard(cards[1].guid, cards[2].guid, cards[3].guid)
end

function Ancient_monster_bookshelf_combine_process_prepare_next(guid)
    if not g.wkcombine then
        return
    end
    local getcards = g.aam.get_card_by_guid(guid)
    if #getcards == 0 then
        ReserveScript(string.format("Ancient_monster_bookshelf_combine_process_prepare_next('%s')", guid), 0.5)
        return
    end
    local card = getcards[1]
    
    local frame = ui.GetFrame(g.framename)
    
    if card and card.rarity == g.wkcombine[1].rarity and card.rarity < 4 then
    else
        card = nil
    end
    
    Ancient_monster_bookshelf_combine_process_next(card)
end

function Ancient_monster_bookshelf_on_ancient_card_update(frame, msg, guid, slot)
    if g.working then
        if msg == "ANCIENT_CARD_COMBINE" and g.wkcombine then
            Ancient_monster_bookshelf_update()
            local getcards = g.aam.get_card_by_guid(guid)
            
            local frame = ui.GetFrame(g.framename)
            
            frame:StopUpdateScript("Ancient_monster_bookshelf_combine_process_watchdog", 1)
            
            local gauge = frame:GetChildRecursively("progresscombine")
            AUTO_CAST(gauge)
            gauge:SetCurPoint(g.wkinit - #g.wkcards)
            gauge:SetMaxPoint(g.wkinit)
            local slot = frame:GetChildRecursively("slotcombine1")
            AUTO_CAST(slot)
            Ancient_monster_bookshelf_set_slot(slot, g.wkcombine[1], false, true)
            local slot = frame:GetChildRecursively("slotcombine2")
            AUTO_CAST(slot)
            Ancient_monster_bookshelf_set_slot(slot, g.wkcombine[2], false, true)
            local slot = frame:GetChildRecursively("slotcombine3")
            AUTO_CAST(slot)
            Ancient_monster_bookshelf_set_slot(slot, g.wkcombine[3], false, true)
            local slot = frame:GetChildRecursively("slotcombineproduct")
            AUTO_CAST(slot)
            if #getcards > 0 then
                Ancient_monster_bookshelf_set_slot(slot, getcards[1], false, true)
            end
            ReserveScript(string.format("Ancient_monster_bookshelf_combine_process_prepare_next('%s')", guid), 0.5)
        end
    end
end

function Ancient_monster_bookshelf_on_cancel()
    Ancient_monster_bookshelf_set_working(false)
end]]

--[[function Cc_helper_save_settings()
    g.save_lua(g.cc_helper_path, g.cc_helper_settings)
end

function Cc_helper_load_settings()
    g.cc_helper_path = string.format("../addons/%s/%s/cc_helper.lua", addon_name_lower, g.active_id)
    local json_path = string.format("../addons/%s/%s/cc_helper.json", addon_name_lower, g.active_id)
    local settings = g.load_lua(g.cc_helper_path)
    local need_save = false
    local ver = 1.1
    if not settings then
        settings = g.load_json(json_path)
        if settings then
            need_save = true -- JSONから読み込めたので、後でLua形式で保存する
        end
    end
    if not settings then
        settings = {
            etc = {
                eco = 0,
                agm_stop = 0,
                wh_close = 0,
                copys = {}
            },
            ver = ver
        }
        local old_copy_path = string.format("../addons/%s/%s/%s_copy.json", "cc_helper", g.active_id, g.active_id)
        local copy_settings = g.load_json(old_copy_path)
        if copy_settings then
            local item_keys = {"seal", "ark", "leg", "god", "hair1", "hair2", "hair3", "gem1", "gem2", "gem3", "gem4",
                               "pet", "core", "relic"}
            local item_key_map = {}
            for _, key in ipairs(item_keys) do
                item_key_map[key] = true
            end
            for cid, char_data in pairs(copy_settings) do
                if type(char_data) == "table" and next(char_data) then
                    settings.etc.copys[cid] = {
                        items = {}
                    }
                    for key, value in pairs(char_data) do
                        if type(value) == "table" then
                            if item_key_map[key] then
                                settings.etc.copys[cid].items[key] = {}
                                for k, v in pairs(value) do
                                    if k == "memo" then
                                        local result = StringSplit(v, ":::")
                                        if #result > 0 then
                                            if string.find(key, "hair") then
                                                settings.etc.copys[cid].items[key].rank = result[#result]
                                                table.remove(result, #result)
                                                settings.etc.copys[cid].items[key].option = table.concat(result, ":::")
                                            elseif key == "pet" then
                                                settings.etc.copys[cid].items[key].option = result[#result]
                                            end
                                        end
                                    elseif k ~= "skin" then
                                        settings.etc.copys[cid].items[key][k] = v
                                    end
                                end
                            end
                        else
                            settings.etc.copys[cid][key] = value
                        end
                    end
                end
            end
        end
        need_save = true
    end
    if not settings.ver or settings.ver < ver then
        settings.ver = ver
        need_save = true
    end
    g.cc_helper_settings = settings
    if need_save then
        Cc_helper_save_settings()
    end
end

function Cc_helper_char_load_settings()
    local settings = g.load_lua(g.cc_helper_path)
    if not settings[g.cid] then
        settings[g.cid] = {
            agm = 0,
            agm_check = 0,
            mcc = 0,
            items = {},
            name = g.login_name
        }
    end
    local tbl = {"seal", "ark", "leg", "god", "hair1", "hair2", "hair3", "gem1", "gem2", "gem3", "gem4", "pet", "core",
                 "relic"}
    for _, key in ipairs(tbl) do
        if not settings[g.cid].items[key] then
            settings[g.cid].items[key] = {
                iesid = "",
                clsid = 0,
                option = "",
                rank = "",
                image = ""
            }
        end
    end
    g.cc_helper_settings[g.cid] = settings[g.cid]
    Cc_helper_save_settings()
end
]]

--[=[function Cc_helper_unequip(in_btn)
    local inventory = ui.GetFrame("inventory")
    local eqp_tab = GET_CHILD_RECURSIVELY(inventory, "inventype_Tab")
    eqp_tab:SelectTab(1)
    local equip_tbl = {0, 20, 1, 25, 27, 29, 35}
    local temp_tbl = {"hair1", "hair2", "hair3", "seal", "ark", "relic", "core"}
    local equip_item_list = session.GetEquipItemList()
    for i, equip_index in ipairs(equip_tbl) do
        local equip_item = equip_item_list:GetEquipItemByIndex(equip_index)
        if equip_item then
            local iesid = equip_item:GetIESID()
            local setting_data = g.cc_helper_settings[g.cid].items[temp_tbl[i]]
            if setting_data and setting_data.clsid ~= 0 then
                if iesid ~= "0" and setting_data.iesid == iesid then
                    item.UnEquip(equip_index)
                    return 1
                end
            end
        end
    end
    for i, key in ipairs(temp_tbl) do
        local setting_data = g.cc_helper_settings[g.cid].items[key]
        if setting_data and setting_data.clsid ~= 0 then
            if setting_data.iesid and setting_data.iesid ~= "0" then
                local inv_item = session.GetInvItemByGuid(setting_data.iesid)
                if inv_item == nil then
                    local equip_item = session.GetEquipItemByGuid(setting_data.iesid)
                    if equip_item ~= nil then
                        return 1
                    end
                end
            end
        end
    end
    in_btn:StopUpdateScript("Cc_helper_unequip")
    Cc_helper_putitem(nil, in_btn, nil, 2)
    return 0
end]=]

