function TOSHERO_INFO_BUFFSHOP_ON_INIT(addon, frame)
    addon:RegisterMsg('TOSHERO_INFO_GET', 'ON_TOSHERO_INFO_BUFFSHOP_GET')
    addon:RegisterMsg('TOSHERO_INFO_POINT', 'ON_TOSHERO_INFO_BUFFSHOP_POINT')
    addon:RegisterMsg('TOSHERO_INFO_BUFFSHOP', 'ON_TOSHERO_INFO_BUFFSHOP_DATA')
    addon:RegisterMsg('TOSHERO_INFO_COMBINE_SUCCESS', 'ON_TOSHERO_INFO_BUFFSHOP_COMBINE_SUCCESS')
end
local TOSHERO_RANDOMBUFF_INDEX = 9999
local s_combine_table =
{
    [1] = {["from"] = "None", ["type"] = 0},
    [2] = {["from"] = "None", ["type"] = 0},
    [3] = {["from"] = "None", ["type"] = 0}
}

-- AddOnMsg
function ON_TOSHERO_INFO_BUFFSHOP_GET()
    TOSHERO_INFO_BUFFSHOP_SET_POINT()
    TOSHERO_INFO_BUFFSHOP_SET_INVENTORY()
end

function ON_TOSHERO_INFO_BUFFSHOP_DATA()
    TOSHERO_INFO_BUFFSHOP_SET_SHOP()
end

function ON_TOSHERO_INFO_BUFFSHOP_POINT()
    TOSHERO_INFO_BUFFSHOP_SET_POINT()
end

function ON_TOSHERO_INFO_BUFFSHOP_COMBINE_SUCCESS(frame, msg, argStr, type)
    local frame = ui.GetFrame('toshero_info_buffshop')
    if frame == nil then
        return
    end
    TOSHERO_INFO_BUFFSHOP_RESULT_EFFECT()
    TOSHERO_INFO_BUFFSHOP_MATERIAL_EFFECT()

    local buffCls = GetClassByType("Buff", type + g_toshero_group_index)

    -- 버프 이미지
    local slot = GET_CHILD_RECURSIVELY(frame, 'combine_result')
    local icon = slot:GetIcon();
    if icon == nil then
        icon = CreateIcon(slot);
    end
    icon:SetImage('icon_'..buffCls.Icon)

    -- 버프 명칭
    local name = GET_CHILD_RECURSIVELY(frame, 'combine_name_result')

    name:SetTextByKey("name", buffCls.Name)

    -- 조합/확인 버튼 변경
    local button = GET_CHILD_RECURSIVELY(frame, 'combine_btn')
    button:SetTextTooltip("");
    button:SetTextByKey("state", frame:GetUserConfig("COMBINE_STATE_2"))
    button:SetEventScript(ui.LBUTTONDOWN, 'TOSHERO_INFO_BUFFSHOP_COMBINE_CLEAR')

    TOSHERO_INFO_BUFFSHOP_CLEAR_MATERIAL_SLOT()
    -- UI 홀드
    ui.SetHoldUI(true)
end

-- Open/Close
function TOSHERO_INFO_BUFFSHOP_OPEN()
    local frame = ui.GetFrame('toshero_info_buffshop')
    if frame == nil then
        return
    end

    TOSHERO_INFO_BUFFSHOP_SET_SHOP()
    TOSHERO_INFO_BUFFSHOP_SET_POINT()
    TOSHERO_INFO_BUFFSHOP_SET_INVENTORY()
    TOSHERO_INFO_BUFFSHOP_COMBINE_CLEAR()
end

function TOSHERO_INFO_BUFFSHOP_CLOSE()
    ui.SetHoldUI(false)
end

-- Inventory
function TOSHERO_INFO_BUFFSHOP_SET_INVENTORY()
    local frame = ui.GetFrame('toshero_info_buffshop')
    if frame == nil then
        return
    end

    for i = 0, 2 do
        local buffType = GetTOSHeroBuffType(i)
        local buffLevel = GetTOSHeroBuffLevel(i)
        local buffClass = GetClassByType("Buff", buffType + g_toshero_group_index)

        local slot = GET_CHILD_RECURSIVELY(frame, 'slot_'..i + 1)
        local name = GET_CHILD_RECURSIVELY(frame, 'inventory_name_'..i + 1)
        local level = GET_CHILD_RECURSIVELY(frame, 'level_'..i + 1)
        local shadow = GET_CHILD_RECURSIVELY(frame, 'level_shadow_'..i + 1)
        local icon = slot:GetIcon();
        if icon == nil then
            icon = CreateIcon(slot);
        end
        if buffClass ~= nil then
            -- 버프 이미지 / 툴팁
            icon:SetImage("icon_"..buffClass.Icon)
            icon:SetTextTooltip(buffClass.ToolTip)

            -- 버프 명칭
            name:SetTextByKey("name", buffClass.Name)

            -- 버프 레벨
            level:SetTextByKey("level", buffLevel)
            shadow:SetVisible(1)
        else
            -- 버프 이미지 / 툴팁
            slot:ClearIcon()
            slot:SetTextTooltip("")

            -- 버프 명칭
            name:SetTextByKey("name", frame:GetUserConfig("DEFAULT_NAME"))

            -- 버프 레벨
            level:SetTextByKey("level", "")
            shadow:SetVisible(0)
        end

        local upBtn = GET_CHILD_RECURSIVELY(frame, 'up_lv_'..i + 1)

        upBtn:SetTextTooltip(TOSHERO_BUFF_UPGRADE_PRICE..ClMsg("POINT"))
    end
end

-- Combine
function TOSHERO_INFO_BUFFSHOP_SET_COMBINE()
    local frame = ui.GetFrame('toshero_info_buffshop')
    if frame == nil then
        return
    end

    local totalPrice = 0

    for i = 1, 3 do
        local slot = GET_CHILD_RECURSIVELY(frame, 'combine_slot_'..i)
        local name = GET_CHILD_RECURSIVELY(frame, 'combine_name_'..i)
        local shadow = GET_CHILD_RECURSIVELY(frame, 'combine_shadow_'..i)
        local fromText = GET_CHILD_RECURSIVELY(frame, 'combine_from_'..i)

        local from = s_combine_table[i]["from"]
        local type = s_combine_table[i]["type"]
        local icon = slot:GetIcon();
        if icon == nil then
            icon = CreateIcon(slot);
        end
        if type > 0 then
            local buffCls = nil

            if from == "inventory" then
                buffCls = GetClassByType("Buff", GetTOSHeroBuffType(type - 1) + g_toshero_group_index)
            else
                buffCls = GetClassByType("Buff", type + g_toshero_group_index)
            end

            if buffCls ~= nil then
                icon:SetImage("icon_"..buffCls.Icon)
                name:SetTextByKey("name", buffCls.Name)
            end

            shadow:ShowWindow(1)
            fromText:ShowWindow(1)

            if from == "inventory" then
                fromText:SetTextByKey("from", "Inv"..type)
            else
                fromText:SetTextByKey("from", "Shop")
            end

            if from == "shop" then
                totalPrice = totalPrice + GetTOSHeroBuffShopPrice(type)
            end
        else
            slot:ClearIcon()

            name:SetTextByKey("name", frame:GetUserConfig("DEFAULT_NAME"))

            shadow:ShowWindow(0)
            fromText:ShowWindow(0)
        end
    end

    local combineBtn = GET_CHILD_RECURSIVELY(frame, "combine_btn")

    if totalPrice > 0 then
        combineBtn:SetTextTooltip(totalPrice..ClMsg("POINT"))
    else
        combineBtn:SetTextTooltip("")
    end
end

function TOSHERO_INFO_BUFFSHOP_CLEAR_MATERIAL_SLOT()
    local frame = ui.GetFrame('toshero_info_buffshop')
    if frame == nil then
        return
    end

    for i = 1, 3 do
        local slot = GET_CHILD_RECURSIVELY(frame, 'combine_slot_'..i)
        local name = GET_CHILD_RECURSIVELY(frame, 'combine_name_'..i)
        local shadow = GET_CHILD_RECURSIVELY(frame, 'combine_shadow_'..i)
        local fromText = GET_CHILD_RECURSIVELY(frame, 'combine_from_'..i)
        local icon = slot:GetIcon();
        if icon == nil then
            icon = CreateIcon(slot);
        end
        icon:SetImage("")
        name:SetTextByKey("name", frame:GetUserConfig("DEFAULT_NAME"))
        shadow:ShowWindow(0)
        fromText:ShowWindow(0)
    end
end

-- Shop
function TOSHERO_INFO_BUFFSHOP_SET_SHOP()
    local frame = ui.GetFrame('toshero_info_buffshop')
    if frame == nil then
        return
    end

    local shopBG = GET_CHILD_RECURSIVELY(frame, "buffshop_bg")
    if shopBG == nil then
        return
    end

    shopBG:RemoveAllChild()

    local width = 10
    local height = 0

    local shopList = GetTOSHeroBuffShopList()
    for i = 1, #shopList do
        local buffCls = GetClassByType("Buff", shopList[i] + g_toshero_group_index)
        if shopList[i] == 0 then
            buffCls = GetClassByType("Buff", TOSHERO_RANDOMBUFF_INDEX + g_toshero_group_index)
        end
        local buffPrice = GetTOSHeroBuffShopPrice(shopList[i])

        local controlSet = shopBG:CreateOrGetControlSet("toshero_buffshop_info", "shop_info_"..i, ui.LEFT, ui.TOP, width, height, 0, 0)

        local slot = GET_CHILD_RECURSIVELY(controlSet, "slot")
        local name = GET_CHILD_RECURSIVELY(controlSet, "name")
        local price = GET_CHILD_RECURSIVELY(controlSet, "price_info")
      
        -- 버프 이미지
        slot:SetImage("icon_"..buffCls.Icon)
        slot:SetTextTooltip(buffCls.ToolTip)

        -- 슬롯 이미지 좌클릭 : 구매
        slot:SetEventScript(ui.LBUTTONUP, 'TOSHERO_INFO_BUFFSHOP_REQUEST_BUY')
        slot:SetEventScriptArgNumber(ui.LBUTTONUP, shopList[i])

        -- 슬롯 이미지 우클릭 : 조합식 등록
        slot:SetEventScript(ui.RBUTTONUP, 'TOSHERO_INFO_BUFFSHOP_ADD_MATERIAL')
        slot:SetEventScriptArgNumber(ui.RBUTTONUP, shopList[i])
        slot:SetEventScriptArgString(ui.RBUTTONUP, "shop")

        -- 이름 / 가격
        name:SetTextByKey("name", buffCls.Name)
        price:SetTextByKey("point", GET_COMMAED_STRING(buffPrice))

        width = width + controlSet:GetWidth() + 10
        
        if i % 4 == 0 then
            width = 10
            height = height + controlSet:GetHeight() + 10
        end
    end
end

function TOSHERO_INFO_BUFFSHOP_ADD_MATERIAL(parent, self, from, type)
    if ui.CheckHoldedUI() == true then
        ui.SysMsg(ClMsg("TOSHeroNeedConfirmButton"));
        return
    end
    
    if from == "inventory" then
        local targetIndex = type - 1

        local nowIndex = GetTOSHeroBuffIndex()
        local buffType = GetTOSHeroBuffType(targetIndex)
        local buffCls = GetClassByType("Buff", buffType + g_toshero_group_index)

        -- 대상 인벤토리에 버프가 존재하지 않음
        if buffCls == nil then
            return
        end

        -- 대상 버프가 3렙 이상임
        if string.sub(buffCls.ClassName, -1) == '3' then
            ui.SysMsg(ClMsg("TOSHeroCanNotCombineBuff"));
            return
        end
        
        -- 대상 버프가 히든 버프임
        if string.sub(buffCls.ClassName, -2) == '_H' then
            ui.SysMsg(ClMsg("TOSHeroCanNotCombineBuff"));
            return;
        end


        -- 대상 인벤토리의 버프가 선택중임
        if nowIndex == targetIndex then
            ui.SysMsg(ClMsg("TOSHeroNeedRemoveBuff"));
            return
        end

        -- 이미 등록한 인벤토리 인덱스임
        for key, value in pairs(s_combine_table) do
            if s_combine_table[key]["from"] == from and s_combine_table[key]["type"] == type then
                return
            end
        end
        
    end

    -- 대상 버프가 히든 버프임
    if type > 54 then
        ui.SysMsg(ClMsg("TOSHeroCanNotCombineBuff"));
        return;
    end

    for key, value in pairs(s_combine_table) do
        if value["type"] == 0 then
            s_combine_table[key]["from"] = from
            s_combine_table[key]["type"] = type

            return TOSHERO_INFO_BUFFSHOP_SET_COMBINE()
        end
    end
end

function TOSHERO_INFO_BUFFSHOP_REMOVE_MATERIAL(parent, self, argStr, index)
    if ui.CheckHoldedUI() == true then
        return
    end
    
    s_combine_table[index]["from"] = "None"
    s_combine_table[index]["type"] = 0

    return TOSHERO_INFO_BUFFSHOP_SET_COMBINE()
end

function TOSHERO_INFO_BUFFSHOP_COMBINE_CLEAR()
    local frame = ui.GetFrame('toshero_info_buffshop')
    if frame == nil then
        return
    end

    -- 조합식 초기화
    for key, value in pairs(s_combine_table) do
        s_combine_table[key]["from"] = "None"
        s_combine_table[key]["type"] = 0
    end

    -- 조합 결과 초기화
    local slot = GET_CHILD_RECURSIVELY(frame, 'combine_result')
    local name = GET_CHILD_RECURSIVELY(frame, 'combine_name_result')
    local icon = slot:GetIcon();
    if icon == nil then
        icon = CreateIcon(slot);
    end
    slot:ClearIcon()
    name:SetTextByKey("name", frame:GetUserConfig("DEFAULT_NAME"))

    -- 조합/확인 버튼 초기화
    local button = GET_CHILD_RECURSIVELY(frame, 'combine_btn')

    button:SetTextByKey("state", frame:GetUserConfig("COMBINE_STATE_1"))
    button:SetEventScript(ui.LBUTTONDOWN, 'TOSHERO_INFO_BUFFSHOP_REQUEST_COMBINE')

    -- UI 홀드 해제
    ui.SetHoldUI(false)

    -- UI 갱신
    TOSHERO_INFO_BUFFSHOP_SET_COMBINE()
end

-- Point
function TOSHERO_INFO_BUFFSHOP_SET_POINT()
    local frame = ui.GetFrame('toshero_info_buffshop')
    if frame == nil then
        return
    end

    local point = GET_CHILD_RECURSIVELY(frame, 'point_info')

    point:SetTextByKey("point", GetTOSHeroPoint())
end

-- Request
function OPEN_TOSHERO_INFO_BUFFSHOP()
    local frame = ui.GetFrame('toshero_info_buffshop')
    if frame == nil then
        return
    end

    if frame:IsVisible() == 0 then
        ui.OpenFrame('toshero_info_buffshop')
    else
        ui.CloseFrame('toshero_info_buffshop')
    end
end

function TOSHERO_INFO_BUFFSHOP_REQUEST_BUY(parent, self, argStr, buffType)
    toshero.RequestBuyBuff(buffType)
end

function TOSHERO_INFO_BUFFSHOP_REQUEST_SELL(parent, self, argStr, index)
    toshero.RequestSellBuff(index)
end

function TOSHERO_INFO_BUFFSHOP_REQUEST_UPGRADE(parent, self, argStr, index)
    toshero.RequestUpgradeBuff(index)
end

function TOSHERO_INFO_BUFFSHOP_REQUEST_COMBINE()
    local indexTable = {}
    local materialTable = {}

    for i = 1, 3 do
        indexTable[i] = 0
    end

    for key, value in pairs(s_combine_table) do
        local from = value["from"]
        local type = value["type"]

        if type == 0 then
            ui.SysMsg(ClMsg("TOSHeroNeedThreeBuff"));
            return
        end

        if from == "inventory" then
            indexTable[type] = 1
        else
            materialTable[#materialTable + 1] = type
        end
    end

    for i = #materialTable + 1, 3 do
        materialTable[i] = 0
    end
    
    toshero.RequestCombineThreeBuff(indexTable[1], indexTable[2], indexTable[3], materialTable[1], materialTable[2], materialTable[3])
end


-- EFFECT
function TOSHERO_INFO_BUFFSHOP_RESULT_EFFECT()
    local frame = ui.GetFrame("toshero_info_buffshop")
	if frame:IsVisible() == 0 then
		return
    end

	local RESULT_EFFECT_NAME = frame:GetUserConfig('RESULT_EFFECT')
	local RESULT_EFFECT_SCALE = tonumber(frame:GetUserConfig('RESULT_EFFECT_SCALE'))
    local RESULT_EFFECT_DURATION = tonumber(frame:GetUserConfig('RESULT_EFFECT_DURATION'))
    
	local combine_result = GET_CHILD_RECURSIVELY(frame, 'combine_result')
	if combine_result == nil then
		return
    end
    
	imcSound.PlaySoundEvent("sys_class_change")
	combine_result:PlayUIEffect(RESULT_EFFECT_NAME, RESULT_EFFECT_SCALE, 'RESULT_EFFECT')
    ReserveScript("_TOSHERO_INFO_BUFFSHOP_RESULT_EFFECT()", RESULT_EFFECT_DURATION)
end

function _TOSHERO_INFO_BUFFSHOP_RESULT_EFFECT()
	local frame = ui.GetFrame("toshero_info_buffshop")
	if frame:IsVisible() == 0 then
		return
	end

	local combine_result = GET_CHILD_RECURSIVELY(frame, 'combine_result')
    if combine_result == nil then
        return
    end
    
    combine_result:StopUIEffect('RESULT_EFFECT', true, 0.5)
end


function TOSHERO_INFO_BUFFSHOP_MATERIAL_EFFECT()
	local frame = ui.GetFrame("toshero_info_buffshop")
	if frame:IsVisible() == 0 then
		return
    end

	local MATERIAL_EFFECT_NAME = frame:GetUserConfig('MATERIAL_EFFECT')
	local MATERIAL_EFFECT_SCALE = tonumber(frame:GetUserConfig('MATERIAL_EFFECT_SCALE'))
    local MATERIAL_EFFECT_DURATION = tonumber(frame:GetUserConfig('MATERIAL_EFFECT_DURATION'))
    
    for i = 1, 3 do
        local slot = GET_CHILD_RECURSIVELY(frame, 'combine_slot_'..i)
        if slot == nil then
            return
        end
	    slot:PlayUIEffect(MATERIAL_EFFECT_NAME, MATERIAL_EFFECT_SCALE, 'MATERIAL_EFFECT')
	    ReserveScript("_TOSHERO_INFO_BUFFSHOP_MATERIAL_EFFECT()", MATERIAL_EFFECT_DURATION)
    end
end

function _TOSHERO_INFO_BUFFSHOP_MATERIAL_EFFECT()
	local frame = ui.GetFrame("toshero_info_buffshop")
	if frame:IsVisible() == 0 then
		return
	end
	
    for i = 1, 3 do
        local slot = GET_CHILD_RECURSIVELY(frame, 'combine_slot_'..i)
        if slot == nil then
            return
        end
        slot:StopUIEffect('MATERIAL_EFFECT', true, 0.5)
    end
end