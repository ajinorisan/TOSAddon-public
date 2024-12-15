function REPUTATION_SHOP_ON_INIT(addon, frame)
    addon:RegisterMsg('REQUEST_REPUTATION_SHOP_OPEN', 'ON_REQUEST_REPUTATION_SHOP_OPEN')
    addon:RegisterMsg('REQUEST_REPUTATION_SHOP_UPDATE', 'ON_REQUEST_REPUTATION_SHOP_UPDATE')
end

-- 한 화면에 보여줄 아이템 리스트 최대 개수
local _count = 7

-- 구매 목록 / 구매 아이템 개수
local _buy_list = {}
local _buy_list_count = {}

-- 판매 목록 / 판매 아이템 개수
local _sell_list = {}
local _sell_list_count = {}

-- Local Functions
function REPUTATION_SHOP_SET_SHOPTYPE(shopType)
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    frame:SetUserValue("SHOP_TYPE", shopType)
end

function REPUTATION_SHOP_GET_SHOPTYPE()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return "None"
    end

    return frame:GetUserValue("SHOP_TYPE")
end

function REPUTATION_SHOP_SET_PAGE(page)
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    frame:SetUserValue("PAGE", page)
end

function REPUTATION_SHOP_GET_PAGE()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return 1
    end

    return tonumber(frame:GetUserValue("PAGE"))
end

function REPUTATION_SHOP_SET_MAX_PAGE(page)
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    frame:SetUserValue("MAX_PAGE", page)
end

function REPUTATION_SHOP_GET_MAX_PAGE()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return 1
    end

    return tonumber(frame:GetUserValue("MAX_PAGE"))
end

function REPUTATION_SHOP_GET_TOTAL_PRICE()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    local slotSet = AUTO_CAST(frame:GetChild("buy_item_slot"))
    local slotCount = slotSet:GetSlotCount()
    local totalPrice = 0

    for i = 0, slotCount - 1 do
        local productName = _buy_list[i]
        local productCount = _buy_list_count[i]

        if productName ~= nil then
            totalPrice = totalPrice + GetClass("reputation_product", productName).Price * productCount
        end
    end

    return totalPrice
end

function REPUTATION_SHOP_GET_TOTAL_SELL_PRICE()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    local slotSet = GET_CHILD_RECURSIVELY(frame, "sellitemslot")
    local slotCount = slotSet:GetSlotCount()
    local totalPrice = 0

    for i = 1, slotCount do
        local guid = _sell_list[i]
        local sellCount = _sell_list_count[i]

        if guid ~= nil and guid ~= "None" then
            local invitem = session.GetInvItemByGuid(guid)
            if invitem == nil then return end

            local itemCls = GetClassByType("Item", invitem.type)
            if itemCls == nil then return end

            local productName = TryGetProp(itemCls, "ClassName", "None")
            if productName == "None" then return end

            local each_sell_price = GET_REPUTATION_ITEM_SELL_PRICE(GetClassByStrProp("reputation_product", "ItemName", productName))
            totalPrice = totalPrice + each_sell_price * sellCount
        end
    end

    return totalPrice
end

function REPUTATION_SHOP_GET_COIN_NAME()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return "None"
    end

    local reputationName = REPUTATION_SHOP_GET_SHOPTYPE()
    local reputationClass = GetClass("reputation", reputationName)

    return GET_REPUTATION_PRICE_NAME(reputationClass.Group)
end

function REPUTATION_SHOP_GET_COIN_COUNT()
    local coinName = REPUTATION_SHOP_GET_COIN_NAME()
    local coinProp = GetClass("Item", coinName).StringArg

    return TryGetProp(GetMyAccountObj(), coinProp, 0)
end

function REPUATAION_SHOP_GET_LIMIT_COUNT(className)
    local aObj = GetMyAccountObj()
    local productCls = GetClass("reputation_product", className)
    
    return productCls.BuyLimit - TryGetProp(aObj, productCls.ResetProp, 0)
end

-- AddOnMsg Functions
function ON_REQUEST_REPUTATION_SHOP_OPEN(frame, msg, argStr, argNum)
    REPUTATION_SHOP_SET_SHOPTYPE(argStr)
    ui.OpenFrame("reputation_shop")
end

function ON_REQUEST_REPUTATION_SHOP_UPDATE(frame, msg, argStr, argNum)
    REPUTATION_SHOP_CLEAR()
    OPEN_REPUTATION_SHOP()
end

-- OPEN/CLOSE
function OPEN_REPUTATION_SHOP()
    REPUTATION_SHOP_INIT()
    REPUTATION_SHOP_DRAW()
    REPUTATION_SHOP_SLOT_UPDATE()
    OPEN_SHOPUI_COMMON()
end

function CLOSE_REPUTATION_SHOP()
    REPUTATION_SHOP_CLEAR()

    SHOP_SELECT_ITEM_LIST = {}

    local invenFrame = ui.GetFrame('inventory')
	INVENTORY_UPDATE_ICONS(invenFrame)
	INVENTORY_CLEAR_SELECT(invenFrame)
	if invenFrame:IsVisible() == 1 then
		invenFrame:ShowWindow(0)
	end
end

-- CLEAR
function REPUTATION_SHOP_CLEAR()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    -- 구매리스트 초기화
    local slotSet = AUTO_CAST(frame:GetChild("buy_item_slot"))
    local slotCount = slotSet:GetSlotCount()
    for i = 0, slotCount-1 do
        _buy_list[i] = nil
        _buy_list_count[i] = 0
    end

    -- 판매리스트 초기화
    local sellSlotSet = GET_CHILD_RECURSIVELY(frame, "sellitemslot")
    local sellSlotCount = sellSlotSet:GetSlotCount()
    for i = 1, sellSlotCount do
        local _iesID = _sell_list[i]
        if _iesID ~= nil then
            SHOP_SELECT_ITEM_LIST[_iesID] = nil
        end
        _sell_list[i] = nil
        _sell_list_count[i] = 0
    end

    INVENTORY_UPDATE_ICONS(ui.GetFrame("inventory"))

    -- 상품 목록 초기화
    frame:GetChild("shop"):RemoveAllChild()
end

-- INIT
function REPUTATION_SHOP_INIT()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    local shopType = REPUTATION_SHOP_GET_SHOPTYPE()
    local productList = SCR_GET_XML_IES("reputation_product", "ShopType", shopType)

    -- 초기 페이지 세팅
    local max_page = math.floor(#productList / _count)
    if math.fmod(#productList, _count) ~= 0 then
        max_page = max_page + 1
    end
    REPUTATION_SHOP_SET_PAGE(1)
    REPUTATION_SHOP_SET_MAX_PAGE(max_page)
end

-- DRAW
function REPUTATION_SHOP_DRAW()
    REPUTATION_SHOP_DRAW_STATUS()
    REPUTATION_SHOP_DRAW_ITEM_LIST()
end

function REPUTATION_SHOP_DRAW_STATUS()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    local aObj = GetMyAccountObj()
    local point = TryGetProp(aObj, REPUTATION_SHOP_GET_SHOPTYPE(), 0)
    local reputation = GET_REPUTATION_RANK(point)
    
    local nowImg = GET_CHILD_RECURSIVELY(frame, "reputation_pic")
    local nowTopText = GET_CHILD_RECURSIVELY(frame, "reputation_top_text")
    local nowBottomText = GET_CHILD_RECURSIVELY(frame, "reputation_bottom_text")

    nowImg:SetImage("reputation0"..(reputation+1))
    nowTopText:SetText("{@st41b}"..GetClass("reputation", REPUTATION_SHOP_GET_SHOPTYPE()).Name)
    nowBottomText:SetTextByKey("rank_name", ClMsg("REPUTATION_RANK_"..reputation))

    local nextBG = GET_CHILD_RECURSIVELY(frame, "reputation_bg_next")
    local nextImg = GET_CHILD_RECURSIVELY(frame, "reputation_pic_next")
    local nextTopText = GET_CHILD_RECURSIVELY(frame, "reputation_top_text_next")
    local nextBottomText = GET_CHILD_RECURSIVELY(frame, "reputation_bottom_text_next")

    local extract = GET_CHILD_RECURSIVELY(frame, "point_up")
    local nextArrow = GET_CHILD_RECURSIVELY(frame, "reputation_pic_arrow")
    local nextArrowText = GET_CHILD_RECURSIVELY(frame, "reputation_arrow_text")

    if point == GET_REPUTATION_MAX() then
        nextBG:ShowWindow(0)
        nextImg:ShowWindow(0)
        nextArrow:ShowWindow(0)
        nextTopText:ShowWindow(0)
        nextArrowText:ShowWindow(0)
        nextBottomText:ShowWindow(0)
        extract:ShowWindow(0)
    else
        nextBG:ShowWindow(1)
        nextImg:ShowWindow(1)
        nextArrow:ShowWindow(1)
        nextTopText:ShowWindow(1)
        nextArrowText:ShowWindow(1)
        nextBottomText:ShowWindow(1)
        extract:ShowWindow(1)

        -- 다음 평판 표기
        nextImg:SetImage("reputation0"..(reputation+2))
        nextBottomText:SetTextByKey("rank_name", ClMsg("REPUTATION_RANK_"..(reputation+1)))

        -- 다음 평판까지 남은 퍼센트 표기
        local inteval_x = GET_REPUTATION_REQUIRE_POINT(reputation)
        local inteval_y = GET_REPUTATION_REQUIRE_POINT(reputation+1)
        local percent = (point - inteval_x) / (inteval_y - inteval_x)

        nextArrowText:SetTextByKey("percent", math.floor(percent * 100))
    end
end

function REPUTATION_SHOP_DRAW_ITEM_LIST()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    -- 상점 데이터
    local bg = AUTO_CAST(frame:GetChild("shop"))
    local nowPage = REPUTATION_SHOP_GET_PAGE()
    local maxPage = REPUTATION_SHOP_GET_MAX_PAGE()
    local shopType = REPUTATION_SHOP_GET_SHOPTYPE()
    local productList = SCR_GET_XML_IES("reputation_product", "ShopType", shopType)

    -- 평판 데이터
    local aObj = GetMyAccountObj()
    local coin = GetClass("Item", REPUTATION_SHOP_GET_COIN_NAME())
    local point = TryGetProp(aObj, REPUTATION_SHOP_GET_SHOPTYPE(), 0)

    for i = 1, _count do
        local productCls = productList[_count*(nowPage-1) + i]
        if productCls == nil then
            break
        end

        local itemCls = GetClass("Item", productCls.ItemName)
        local itemCtrl = bg:CreateOrGetControlSet("reputation_shop_item_list", "SHOPITEM_" .. i, 0, i*55)
        tolua.cast(itemCtrl, "ui::CControlSet")
    
        -- 이름
        local nameText	= '{@st66b}' .. itemCls.Name
        itemCtrl:SetTextByKey('item_name', nameText)

        -- 가격
        local priceText	= string.format("{img "..coin.Icon.." 20 20} {@st66b}%s", GET_COMMA_SEPARATED_STRING(productCls.Price))
        itemCtrl:SetTextByKey('item_price', priceText)

        -- 구매 제한 (기간)
        local buyText = AUTO_CAST(itemCtrl:GetChild("item_limit"))
        local buyCount = TryGetProp(aObj, productCls.ResetProp, 0)

        if productCls.ResetType == "None" then
            buyText:ShowWindow(0)
        else
            buyText:ShowWindow(1)

            local buyCount = TryGetProp(aObj, productCls.ResetProp, 0)
            local limitText = string.format("{@st66b}{#FF0000}"..ClMsg(productCls.ResetType.."_LIMIT_MSG").." (%s/%s)", buyCount, productCls.BuyLimit)

            itemCtrl:SetTextByKey('item_limit', limitText)

            if buyCount == productCls.BuyLimit then
                itemCtrl:GetChild("item_limit"):SetColorTone("FF888888")
            end
        end
        
        -- 구매 제한 (평판)
        local reputationImg = AUTO_CAST(itemCtrl:GetChild("reputation_img"))
        reputationImg:SetImage("reputation0"..(productCls.RankLimit+1))

        -- 아이콘
        local slot = GET_CHILD(itemCtrl, 'slot')
        local icon = CreateIcon(slot)

        icon:Set(itemCls.Icon, 'SHOPITEM', i, 0)
        icon:SetTooltipArg('sell', itemCls.ClassID, "")

        SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID)

        -- 스크립트
        local button = GET_CHILD(itemCtrl, 'button')
        local lockImage = GET_CHILD(itemCtrl, 'reputation_lock')

        button:SetEventScript(ui.RBUTTONDOWN, 'REPUTATION_SHOP_BUY_LIST_ADD_PRE')
        button:SetEventScriptArgString(ui.RBUTTONDOWN, productCls.ClassName)

        -- 활성화/비활성화
        if productCls.RankLimit > GET_REPUTATION_RANK(point) then
            button:SetEnable(0)
            lockImage:ShowWindow(1)
        else
            button:SetEnable(1)
            lockImage:ShowWindow(0)
        end

        -- 크기 조정
        itemCtrl:Resize(bg:GetWidth(), itemCtrl:GetHeight())
        button:Resize(bg:GetWidth(), itemCtrl:GetHeight())
    end

    -- 현재 페이지 세팅
    local pageText = GET_CHILD_RECURSIVELY(frame, "page")
    pageText:SetTextByKey("now_page", nowPage)
    pageText:SetTextByKey("max_page", maxPage)

    -- 좌우버튼 활성화/비활성화
    if nowPage == 1 then
        REPUTATION_SHOP_ENABLE_LEFT_BTN(0)
    else
        REPUTATION_SHOP_ENABLE_LEFT_BTN(1)
    end

    if nowPage == maxPage then
        REPUTATION_SHOP_ENABLE_RIGHT_BTN(0)
    else
        REPUTATION_SHOP_ENABLE_RIGHT_BTN(1)
    end
end

-- BUTTONs
function REPUTATION_SHOP_ENABLE_LEFT_BTN(enable)
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    frame:GetChild("page_front"):SetEnable(enable)
    frame:GetChild("page_left"):SetEnable(enable)
end

function REPUTATION_SHOP_ENABLE_RIGHT_BTN(enable)
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    frame:GetChild("page_right"):SetEnable(enable)
    frame:GetChild("page_end"):SetEnable(enable)
end

function REPUTATION_SHOP_CLICK_LEFT_BTN()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    frame:GetChild("shop"):RemoveAllChild()

    local page = REPUTATION_SHOP_GET_PAGE()
    if page == 1 then
        return
    end

    REPUTATION_SHOP_SET_PAGE(page - 1)
    REPUTATION_SHOP_DRAW_ITEM_LIST()
end

function REPUTATION_SHOP_CLICK_RIGHT_BTN()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    frame:GetChild("shop"):RemoveAllChild()

    local page = REPUTATION_SHOP_GET_PAGE()
    if page == REPUTATION_SHOP_GET_MAX_PAGE() then
        return
    end

    REPUTATION_SHOP_SET_PAGE(page + 1)
    REPUTATION_SHOP_DRAW_ITEM_LIST()
end

function REPUTATION_SHOP_CLICK_FRONT_BTN()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    frame:GetChild("shop"):RemoveAllChild()

    REPUTATION_SHOP_SET_PAGE(1)
    REPUTATION_SHOP_DRAW_ITEM_LIST()
end

function REPUTATION_SHOP_CLICK_END_BTN()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    frame:GetChild("shop"):RemoveAllChild()

    REPUTATION_SHOP_SET_PAGE(REPUTATION_SHOP_GET_MAX_PAGE())
    REPUTATION_SHOP_DRAW_ITEM_LIST()
end

function REPUTATION_SHOP_POINT_UP_BTN()
    local reputation = REPUTATION_SHOP_GET_SHOPTYPE()
    REPUTATION_POINT_EXTRACT_OPEN(reputation)
end

-- SLOT UPDATE
function REPUTATION_SHOP_SLOT_UPDATE()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    local slotSet = AUTO_CAST(frame:GetChild("buy_item_slot"))
    local slotCount = slotSet:GetSlotCount()
    local totalPrice = 0

    -- 지우기
    for i = 0, slotCount - 1 do
        local slot = slotSet:GetSlotByIndex(i)
        if slot:GetIcon() ~= nil then
            slot:ClearText()
            slot:ClearIcon()
        end
    end

    -- 그리기
    for i = 0, slotCount - 1 do
        local slot = slotSet:GetSlotByIndex(i)
        
        local productName = _buy_list[i]
        local productCount = _buy_list_count[i]
        if productName ~= nil then
            local productCls = GetClass("reputation_product", productName)
            local itemCls = GetClass("Item", productCls.ItemName)
            
            -- 아이콘
            local icon = CreateIcon(slot)
            icon:Set(itemCls.Icon, 'BUYITEMITEM', itemCls.ClassID, 0)
            icon:SetTooltipArg('sell', itemCls.ClassID, "")

            -- 툴팁
            SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID)

            -- 스크립트
            slot:SetEventScript(ui.RBUTTONDOWN, "REPUTATION_SHOP_BUY_LIST_REMOVE")
            slot:SetEventScriptArgString(ui.RBUTTONDOWN, productName)

            -- 개수
            slot:SetText('{s18}{ol}{b}'..productCount, 'count', ui.RIGHT, ui.BOTTOM, -2, 1)
        end
    end

    local sellSlotSet = GET_CHILD_RECURSIVELY(frame, "sellitemslot")
    local sellSlotCount = sellSlotSet:GetSlotCount()

    -- 지우기
    for i = 0, sellSlotCount - 1 do
        local slot = sellSlotSet:GetSlotByIndex(i)
        if slot:GetIcon() ~= nil then
            slot:ClearText()
            slot:ClearIcon()
        end
    end

    -- 그리기
    for i = 1, sellSlotCount do
        local guid = _sell_list[i]
        local sellCount = _sell_list_count[i]

        if guid ~= nil and guid ~= "None" then
            local invitem = session.GetInvItemByGuid(guid)
            if invitem ~= nil then
                local itemCls = GetClassByType("Item", invitem.type)
                if itemCls ~= nil then
                    local productCls = GetClassByStrProp("reputation_product", "ItemName", TryGetProp(itemCls, "ClassName", "None"))
                    local slot = sellSlotSet:GetSlotByIndex(i - 1)
                    local icon = CreateIcon(slot)
        
                    -- 아이콘
                    icon:Set(itemCls.Icon, 'SELLITEMITEM', itemCls.ClassID, 0)
                    icon:SetTooltipArg('sell', itemCls.ClassID, "")
        
                    -- 툴팁
                    SET_ITEM_TOOLTIP_TYPE(icon, itemCls.ClassID)
        
                    -- 스크립트
                    slot:SetEventScript(ui.RBUTTONDOWN, "REPUTATION_SHOP_SELL_LIST_REMOVE")
                    slot:SetEventScriptArgString(ui.RBUTTONDOWN, guid)
        
                    -- 개수
                    slot:SetText('{s18}{ol}{b}'..sellCount, 'count', ui.RIGHT, ui.BOTTOM, -2, 1)
                end
            end
        end
    end

    -- 가격 업데이트
    local price = REPUTATION_SHOP_GET_TOTAL_PRICE()
    local sell_price = REPUTATION_SHOP_GET_TOTAL_SELL_PRICE()
    local buyText = AUTO_CAST(frame:GetChild("buy_silver_text"))
    local sellText = GET_CHILD_RECURSIVELY(frame, "sell_silver_text")
    local tradeText = AUTO_CAST(frame:GetChild("trade_silver_text"))
    local remainText = AUTO_CAST(frame:GetChild("remain_silver_text"))

    buyText:SetTextByKey("price", price)
    sellText:SetTextByKey("price", sell_price)
    tradeText:SetTextByKey("price", REPUTATION_SHOP_GET_COIN_COUNT())
    remainText:SetTextByKey("remain", REPUTATION_SHOP_GET_COIN_COUNT() - price + sell_price)
end

-- BUY LIST ADD/REMOVE
function REPUTATION_SHOP_BUY_LIST_ADD_PRE(frame, ctrl, className)
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end
    
    if keyboard.IsKeyPressed("LSHIFT") == 1 then
        local productCls = GetClass("reputation_product", className)

        -- 1. 실버가 허용하는 최대 개수
        local remainSilver = REPUTATION_SHOP_GET_COIN_COUNT() - REPUTATION_SHOP_GET_TOTAL_PRICE()
        local limitBySilver = math.floor(remainSilver / productCls.Price)

        -- 2. 구매 횟수 제한이 허용하는 최대 개수
        local limitByProp = REPUATAION_SHOP_GET_LIMIT_COUNT(className)

        -- 두 조건을 종합한 구매 가능 최대 개수
        local buyAbleCount = math.min(limitBySilver, limitByProp)

        -- 현재 슬롯에 등록된게 있는지 확인
        local slotSet = AUTO_CAST(frame:GetChild("buy_item_slot"))
        local slotCount = slotSet:GetSlotCount()

        for i = 0, slotCount - 1 do
            local productName = _buy_list[i]
            local productCount = _buy_list_count[i]
    
            if productName == className then
                buyAbleCount = buyAbleCount - productCount
                break
            end
        end

        -- 등록할 수 없다면 리턴
        if buyAbleCount <= 0 then
            ui.SysMsg(ClMsg("REPUTATION_SHOP_NO_MONEY"))
            return
        end

        -- 메세지 박스를 통한 인계
        local text = ScpArgMsg("INPUT_CNT_D_D", "Auto_1", 1, "Auto_2", buyAbleCount)
		INPUT_NUMBER_BOX(frame, text, "REPUTATION_SHOP_BUY_LIST_ADD", 1, 1, buyAbleCount, nil, className)
    else
        REPUTATION_SHOP_BUY_LIST_ADD(frame, 1, nil, className)
    end
end

function REPUTATION_SHOP_BUY_LIST_ADD(frame, addCount, editFrame, className)
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    -- 인계함수 참조
    -- INPUT_NUMBER_BOX 함수를 통해 넘어오면 editFrame이 존재하며, ArgString 값을 통해 className을 넘겨줌
    -- 직접 참조를 통해 넘어오면 editFrame이 존재하지 않으며, className을 그대로 사용
    if editFrame ~= nil then
        className = editFrame:GetUserValue("ArgString")
        addCount = tonumber(addCount)
    end

    -- 기본 정보
    local slotSet = AUTO_CAST(frame:GetChild("buy_item_slot"))
    local slotCount = slotSet:GetSlotCount()
    local productCls = GetClass("reputation_product", className)

    -- 가격 검사
    local expectPrice = REPUTATION_SHOP_GET_TOTAL_PRICE() + productCls.Price * addCount
    if expectPrice > REPUTATION_SHOP_GET_COIN_COUNT() then
        ui.SysMsg(ClMsg("REPUTATION_SHOP_NO_MONEY"))
        return
    end

    -- 리스트에 있으면 찾아서 넣기
    for i = 0, slotCount - 1 do
        local productName = _buy_list[i]
        local productCount = _buy_list_count[i]

        if productName == className then
            -- 제한 개수 넘겼으면 리턴
            if productCount + addCount > REPUATAION_SHOP_GET_LIMIT_COUNT(className) then
                return
            end

            -- 아이템 추가
            _buy_list_count[i] = productCount + addCount
            return REPUTATION_SHOP_SLOT_UPDATE()
        end
    end

    -- 리스트에 없으면 빈자리 찾아서 넣기
    for i = 0, slotCount - 1 do
        if _buy_list[i] == nil then
            -- 제한 개수 넘겼으면 리턴
            if addCount > REPUATAION_SHOP_GET_LIMIT_COUNT(className) then
                return
            end

            -- 아이템 추가
            _buy_list[i] = className
            _buy_list_count[i] = addCount
            return REPUTATION_SHOP_SLOT_UPDATE()
        end
    end
end

function REPUTATION_SHOP_BUY_LIST_REMOVE(frame, ctrl, className)
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    local slotSet = AUTO_CAST(frame:GetChild("buy_item_slot"))
    local slotCount = slotSet:GetSlotCount()

    for i = 0, slotCount - 1 do
        local productName = _buy_list[i]
        local productCount = _buy_list_count[i]

        if productName == className then
            _buy_list[i] = nil
            _buy_list_count[i] = 0

            return REPUTATION_SHOP_SLOT_UPDATE()
        end
    end
end

function REPUTATION_SHOP_TRADE_LIST_REMOVE_ALL(frame, ctrl)
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    local slotSet = AUTO_CAST(frame:GetChild("buy_item_slot"))
    local slotCount = slotSet:GetSlotCount()
    for i = 0, slotCount - 1 do
        _buy_list[i] = nil
        _buy_list_count[i] = 0
    end

    local sellItemSlot = GET_CHILD_RECURSIVELY(frame, "sellitemslot")
    local sellSlotCount = sellItemSlot:GetSlotCount()
    for i = 1, sellSlotCount do
        local _iesID = _sell_list[i]
        if SHOP_SELECT_ITEM_LIST[_iesID] ~= nil then
            SHOP_SELECT_ITEM_LIST[_iesID] = nil
            _sell_list[i] = nil
            _sell_list_count[i] = 0
        end
    end

    INVENTORY_UPDATE_ICONS(ui.GetFrame("inventory"))

    return REPUTATION_SHOP_SLOT_UPDATE()
end

-- SELL LIST
function REPUTATION_SHOP_SELL(invitem, sellCount, frame, totalCount)
    if frame == nil then
        frame = ui.GetFrame('reputation_shop')
    else
        frame = frame:GetTopParentFrame()
    end

    if true == invitem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"))
		return
    end
    
    -- 기본 정보
    local slotSet = GET_CHILD_RECURSIVELY(frame, "sellitemslot")
    local slotCount = slotSet:GetSlotCount()
    local itemCls = GetClassByType("Item", invitem.type)
    local productCls = GetClassByStrProp("reputation_product", "ItemName", TryGetProp(itemCls, "ClassName", "None"))

    -- 판매 가능 여부 검사
    if productCls == nil then
        return
    end

    if TryGetProp(productCls, "ResetType", "None") == "NO_RESET" then
        ui.SysMsg(ClMsg("CannoTradeToNPC"))
        return
    end

    imcSound.PlaySoundEvent('button_inven_click_item')

    local slot = nil
    local ind = 0
    local curCount = 0
    
    -- 리스트에 있으면 찾아서 넣기(MaxStack 고려해야 함)
    local maxStack = TryGetProp(itemCls, "MaxStack", 0)
    for i = 1, slotCount do
        local _guid = _sell_list[i]
        
        if _guid == invitem:GetIESID() and curCount + sellCount <= maxStack then
            -- 아이템 추가
            slot = slotSet:GetSlotByIndex(i)
            ind = i
            curCount = _sell_list_count[i]
            break
        end
    end

    -- 리스트에 없으면 빈자리 찾아서 넣기
    if table.find(_sell_list, invitem:GetIESID()) <= 0 then
        for i = 1, slotCount do
            if _sell_list[i] == nil then
                slot = slotSet:GetSlotByIndex(i)
                _sell_list[i] = invitem:GetIESID()
                ind = i
                break
            end
        end
    end

    if totalCount == true then
        curCount = sellCount
    else
        curCount = curCount + sellCount
    end

    if curCount > invitem.count then
        curCount = invitem.count
    end

    _sell_list_count[ind] = curCount
    SHOP_SELECT_ITEM_LIST[invitem:GetIESID()] = curCount

    REPUTATION_SHOP_SLOT_UPDATE()

    local invFrame = ui.GetFrame('inventory')
    INVENTORY_UPDATE_ITEM_BY_GUID(invFrame, invitem:GetIESID())
    INVENTORY_UPDATE_ICON_BY_INVITEM(invFrame, invitem)
end

function REPUTATION_SHOP_SELL_DROP(parent, ctrl)
    local frame = nil
    if parent == nil then
        frame = ui.GetFrame('reputation_shop')
    else
        frame = parent:GetTopParentFrame()
    end
    
	local liftIcon = ui.GetLiftIcon()
	local FromFrame = liftIcon:GetTopParentFrame()
	local toFrame = frame:GetTopParentFrame()
	if ctrl:GetClassName() ~= "slot" then
		return
	end

	local iconInfo = liftIcon:GetInfo()
	local iesID = liftIcon:GetTooltipIESID()
	if iesID == '0' then
		return
    end
    
	local invItem = session.GetInvItemByGuid(iesID)
	if invItem == nil then
		return
	end

	REPUTATION_SHOP_SELL(invItem, invItem.count, toFrame)
end

function EXEC_REPUTATION_SHOP_SELL(frame, cnt)
	local shopFrame = ui.GetFrame("reputation_shop")

	cnt = tonumber(cnt)
	local itemGuid = frame:GetUserValue("SELL_ITEM_GUID")
	local invItem = session.GetInvItemByGuid(itemGuid)
	REPUTATION_SHOP_SELL(invItem, cnt, shopFrame, true)
end

function IS_REPUTATION_SHOP_SELL(invitem, maxStack, frame)
    if frame == nil then
        frame = ui.GetFrame('reputation_shop')
    else
        frame = frame:GetTopParentFrame()
    end
    
    if frame == nil or frame:IsVisible() ~= 1 then
        return 0
    end

    local itemCls = GetClassByType("Item", invitem.type)
    local productCls = GetClassByStrProp("reputation_product", "ItemName", itemCls.ClassName)
    if productCls == nil then
        return 0
    end

    if TryGetProp(productCls, 'ResetType', 'None') == 'NO_RESET' then
        return 0
    end

	local slotSet = GET_CHILD_RECURSIVELY(frame, 'sellitemslot')
	local slotCount = slotSet:GetSlotCount()

	for i = 0, slotCount - 1 do
		local slotIcon	= slotSet:GetIconByIndex(i)
		if slotIcon == nil then
			return 1
        end
        
		if slotIcon ~= nil and nil ~= invitem and 1 < maxStack then
			local slot  = slotSet:GetSlotByIndex(i);
			local itemID = slot:GetUserValue("SLOT_ITEM_ID")
			if invitem:GetIESID() == itemID then
				return 1
			end
		end
    end
    
	return 0
end

function REPUTATION_SHOP_SELL_LIST_REMOVE(frame, ctrl, guid)
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    local slotSet = GET_CHILD_RECURSIVELY(frame, "sellitemslot")
    local slotCount = slotSet:GetSlotCount()

    for i = 1, slotCount do
        local _guid = _sell_list[i]

        if _guid == guid then
            SHOP_SELECT_ITEM_LIST[guid] = nil
            INVENTORY_SLOT_UNCHECK(ui.GetFrame("inventory"), guid)

            _sell_list[i] = nil
            _sell_list_count[i] = 0

            return REPUTATION_SHOP_SLOT_UPDATE()
        end
    end
end

-- EXEC
function REPUTATION_SHOP_EXEC()
    local frame = ui.GetFrame('reputation_shop')
    if frame == nil then
        return
    end

    reputation.ClearReputationShopTradeList()

    local slotSet = AUTO_CAST(frame:GetChild("buy_item_slot"))
    local slotCount = slotSet:GetSlotCount()

    for i = 0, slotCount - 1 do
        local productName = _buy_list[i]
        local productCount = _buy_list_count[i]

        if productName ~= nil then
            local productCls = GetClass("reputation_product", productName)

            reputation.AddReputationShopBuyList(productCls.ClassID, productCount)
        end
    end

    local sellSlotSet = AUTO_CAST(frame:GetChild("sellitemslot"))
    local sellSlotCount = sellSlotSet:GetSlotCount()

    for i = 1, sellSlotCount do
        local guid = _sell_list[i]
        local sellCount = _sell_list_count[i]
        if guid ~= nil and guid ~= "None" then
            reputation.AddReputationShopSellList(guid, sellCount)
        end
    end

    reputation.RequestReputationShopTrade()
end