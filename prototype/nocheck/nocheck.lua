local addonName = "NOCHECK"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.4"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsDirLoc = string.format("../addons/%s", addonNameLower)
g.settingsFileLoc = string.format("%s/settings.json", g.settingsDirLoc)

local acutil = require("acutil")

local targetMap = {3610, -- 魔族収監所 第1区域
3620, -- 魔族収監所 第2区域
3630, -- 魔族収監所 第3区域
3640, -- 魔族収監所 第4区域
3650 -- 魔族収監所 第5区域
}

function NOCHEK_ISTARGET_MAP()
    local mapID = session.GetMapID()
    for i = 1, #targetMap do
        if mapID == targetMap[i] then
            return true
        end
    end
    return false
end

function NOCHECK_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    acutil.setupHook(NOCHECK_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG, "BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG")
    acutil.setupHook(NOCHECK_CARD_SLOT_EQUIP, "CARD_SLOT_EQUIP")
    acutil.setupHook(NOCHECK_EQUIP_CARDSLOT_INFO_OPEN, "EQUIP_CARDSLOT_INFO_OPEN");
    acutil.setupHook(NOCHECK_EQUIP_GODDESSCARDSLOT_INFO_OPEN, "EQUIP_GODDESSCARDSLOT_INFO_OPEN")
    acutil.setupHook(NOCHECK_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE, "GODDESS_MGR_SOCKET_REQ_GEM_REMOVE")
    acutil.setupHook(NOCHECK_GODDESS_MGR_SOCKET_OPEN, "GODDESS_MGR_SOCKET_OPEN")
    acutil.setupHook(NOCHECK_GODDESS_MGR_REFORGE_OPEN, "GODDESS_MGR_REFORGE_OPEN")
    acutil.setupHook(NOCHECK_WARNINGMSGBOX_EX_FRAME_OPEN, "WARNINGMSGBOX_EX_FRAME_OPEN")
    addon:RegisterMsg("DIALOG_CHANGE_SELECT", "NOCHECK_DIALOG_ON_MSG")
    -- acutil.setupHook(NOCHECK_DIALOG_ON_MSG,"DIALOG_ON_MSG")
    -- addon:RegisterMsg("DIALOG_CHANGE_SELECT","NOCHECK_DIALOG_ON_MSG")
    addon:RegisterMsg("DIALOG_ADD_SELECT", "NOCHECK_DIALOGSELECT_ON_MSG")
    CHAT_SYSTEM("NOCHECK loaded")
    -- NOCHECK_FRAME_INIT()

end

function NOCHECK_WARNINGMSGBOX_EX_FRAME_OPEN(frame, msg, argStr, argNum, option)
    local arg_list = SCR_STRING_CUT(argStr, ';')
    if arg_list == nil or #arg_list <= 0 then
        return
    end

    local clmsg = ClMsg(arg_list[1])
    local yes_arg = ""
    if #arg_list > 1 then
        yes_arg = arg_list[2]
    end

    ui.OpenFrame("warningmsgbox_ex")

    local frame = ui.GetFrame('warningmsgbox_ex')

    -- 커스터마이징 옵션.
    local compare_msg_color = nil;
    local compare_msg_desc = nil;
    if option ~= nil then
        if option.ChangeTitle ~= nil then
            local warningTitle = GET_CHILD_RECURSIVELY(frame, "warningtitle")
            warningTitle:SetText(ClMsg(option.ChangeTitle));
        end
        if option.CompareTextColor ~= nil then
            compare_msg_color = option.CompareTextColor;
        end
        if option.CompareTextDesc ~= nil then
            compare_msg_desc = option.CompareTextDesc;
        end
    end

    local warningText = GET_CHILD_RECURSIVELY(frame, "warningtext")
    warningText:SetText(clmsg)

    local compareText = GET_CHILD_RECURSIVELY(frame, "comparetext")
    local compareHeight = 0

    local input_frame = GET_CHILD_RECURSIVELY(frame, "input")
    local input_height = 0

    local yes_list = SCR_STRING_CUT(yes_arg, '/')
    local compare_msg = ''
    if #yes_list > 0 then
        compare_msg = ClMsg(yes_list[1])
    end

    if compare_msg ~= '' then
        compareText:ShowWindow(1)

        if compare_msg_desc ~= nil then
            compareText:SetTextByKey('desc', compare_msg_desc)
        end

        if compare_msg_color ~= nil then
            compareText:SetTextByKey('value', compare_msg_color .. compare_msg .. '{/}')
        else
            compareText:SetTextByKey('value', compare_msg)
        end

        compareHeight = compareText:GetHeight()
        -- compareText:SetMargin(0, 0, 0, 170)

        input_frame:ShowWindow(1)
        input_frame:SetText('')
        input_frame:Focus()
        input_height = input_frame:GetHeight()
    else
        compareText:ShowWindow(0)
        input_frame:ShowWindow(0)
    end

    local yesBtn = GET_CHILD_RECURSIVELY(frame, "yes")
    tolua.cast(yesBtn, "ui::CButton")
    yesBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_YES')
    yesBtn:SetEventScriptArgString(ui.LBUTTONUP, yes_arg)

    local noBtn = GET_CHILD_RECURSIVELY(frame, "no")
    tolua.cast(noBtn, "ui::CButton")
    noBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_NO')

    local okBtn = GET_CHILD_RECURSIVELY(frame, "ok")
    tolua.cast(okBtn, "ui::CButton")
    if argnum == 0 then -- 足した
        argnum = 1
    end
    if argNum == 0 then
        yesBtn:ShowWindow(1)
        noBtn:ShowWindow(1)
        okBtn:ShowWindow(0)
    elseif argNum == 1 then
        okBtn:SetEventScript(ui.LBUTTONUP, '_WARNINGMSGBOX_EX_FRAME_OPEN_YES')
        okBtn:SetEventScriptArgString(ui.LBUTTONUP, yes_arg)

        yesBtn:ShowWindow(0)
        noBtn:ShowWindow(1) -- いじった
        okBtn:ShowWindow(1)
    end

    local buttonMargin = noBtn:GetMargin()
    local warningbox = GET_CHILD_RECURSIVELY(frame, 'warningbox')
    local totalHeight =
        warningbox:GetY() + warningText:GetY() + warningText:GetHeight() + compareHeight + input_height +
            noBtn:GetHeight() + 2 * buttonMargin.bottom

    local bg = GET_CHILD_RECURSIVELY(frame, 'bg')
    warningbox:Resize(warningbox:GetWidth(), totalHeight)
    bg:Resize(bg:GetWidth(), totalHeight)
    frame:Resize(frame:GetWidth(), totalHeight)
end

function NOCHECK_DIALOG_ON_MSG(frame, msg, argStr, argNum)
    if string.find(argStr, "HighLvZoneEnterMsgCustom") ~= nil then
        -- if NOCHEK_ISTARGET_MAP() == true then
        local dialog = ui.GetFrame("dialog")
        local x, y = dialog:GetX() + 50, dialog:GetY() + 200 -- ダイアログ内の任意の座標を指定
        ReserveScript(string.format('mouse.SetPos(%d, %d)', x, y), 0.5)
        NOCHECK_DIALOGSELECT()

        -- else
        -- ui.CloseFrame("dialog")
        -- end
    end
end

function NOCHECK_DIALOGSELECT()
    control.DialogSelect(1)
    local x, y = mouse.GetX(), mouse.GetY()
    -- ReserveScript(string.format('mouse.SetPos(%d, %d)', x, y), 0.02)
    string.format('mouse.SetPos(%d, %d)', x, y)
end

function NOCHECK_DIALOGSELECT_ON_MSG(frame, msg, argStr, argNum)
    if argStr == '!@#$WS_ZACHA2F_01_TO_02_ANSWER_GO#@!' then

        NOCHECK_DIALOGSELECT()
    end
end

--[[
function NOCHECK_FRAME_INIT()
   local inveframe = ui.GetFrame('inventory')
   local button = inveframe:CreateOrGetControl("button", "equip", 10, 10, 100, 30)
   button:SetText("equip")
   button:ShowWindow(1)
end
]]

function NOCHECK_GODDESS_MGR_REFORGE_OPEN(frame)
    -- GODDESS_MGR_REFORGE_CLEAR(frame)
    INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_REFORGE_INV_RBTN')
end

function NOCHECK_GODDESS_MGR_SOCKET_OPEN(frame)
    INVENTORY_SET_CUSTOM_RBTNDOWN('GODDESS_MGR_SOCKET_INV_RBTN')
    -- GODDESS_MGR_SOCKET_CLEAR(frame)
end

function NOCHECK_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(parent, btn)
    local frame = parent:GetTopParentFrame()
    local slot = GET_CHILD_RECURSIVELY(frame, 'socket_slot')
    local guid = slot:GetUserValue('ITEM_GUID')
    if guid ~= 'None' then
        local index = parent:GetUserValue('SLOT_INDEX')

        local inv_item = session.GetInvItemByGuid(guid)
        if inv_item == nil then
            return
        end

        local item_obj = GetIES(inv_item:GetObject())
        local item_name = dic.getTranslatedStr(TryGetProp(item_obj, 'Name', 'None'))

        local gem_id = inv_item:GetEquipGemID(index)
        local gem_cls = GetClassByType('Item', gem_id)
        local gem_numarg1 = TryGetProp(gem_cls, 'NumberArg1', 0)
        local price = gem_numarg1 * 100
        local clmsg = 'None'

        local msg_cls_name = ''

        if TryGetProp(gem_cls, 'GemType', 'None') == 'Gem_High_Color' then
            -- msg_cls_name = 'ReallyRemoveGem_AetherGem'
            -- clmsg = "[" .. item_name .. "]" .. ScpArgMsg(msg_cls_name) .. tostring(price)
            _GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(index)
            -- GODDESS_MGR_SOCKET_REQ_GEM_REMOVE_OLD(parent, btn)
        else
            local pc = GetMyPCObject();
            local isGemRemoveCare = IS_GEM_EXTRACT_FREE_CHECK(pc)

            local free_gem = nil
            for optionIdx = 1, 4 do
                free_gem = GET_GEM_PROPERTY_TEXT(item_obj, optionIdx, index)
                if free_gem ~= nil then
                    _GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(index)
                    return
                end
            end

            if isGemRemoveCare == true then
                msg_cls_name = "ReallyRemoveGem_Care"
            else
                msg_cls_name = "ReallyRemoveGem"
            end

            local clmsg = "'" .. item_name .. ScpArgMsg("Auto_'_SeonTaeg") .. ScpArgMsg(msg_cls_name)
            local yesscp = string.format('_GODDESS_MGR_SOCKET_REQ_GEM_REMOVE(%s)', index)
            local msgbox = ui.MsgBox(clmsg, yesscp, '')
            SET_MODAL_MSGBOX(msgbox)
        end
    end
end

-- 欠片アイテム他使用時のメッセージボックス非表示
function NOCHECK_BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG(invItem)

    if invItem == nil then
        return;
    end

    local invFrame = ui.GetFrame("inventory");
    local itemobj = GetIES(invItem:GetObject());
    if itemobj == nil then
        return;
    end
    invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());

    REQUEST_SUMMON_BOSS_TX();
    -- BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG_OLD(invItem)

    return;
end

-- レジェンドカード装着時のメッセージボックス非表示
function NOCHECK_CARD_SLOT_EQUIP(slot, item, groupNameStr)
    local obj = GetIES(item:GetObject());
    if obj.GroupName == "Card" then
        local slotIndex = CARD_SLOT_GET_SLOT_INDEX(groupNameStr, slot:GetSlotIndex());
        local cardInfo = equipcard.GetCardInfo(slotIndex + 1);

        if cardInfo ~= nil then
            ui.SysMsg(ClMsg("AlreadyEquippedThatCardSlot"));
            return;
        end

        if item.isLockState == true then
            ui.SysMsg(ClMsg("MaterialItemIsLock"));
            return
        end

        local itemGuid = item:GetIESID();
        local invFrame = ui.GetFrame("inventory");
        invFrame:SetUserValue("EQUIP_CARD_GUID", itemGuid);
        invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", slotIndex);

        if groupNameStr == 'LEG' then
            local pcEtc = GetMyEtcObject();
            if pcEtc.IS_LEGEND_CARD_OPEN ~= 1 then
                ui.SysMsg(ClMsg("LegendCard_Slot_NotOpen"))
                return
            end

            REQUEST_EQUIP_CARD_TX();
        else
            REQUEST_EQUIP_CARD_TX();
        end
    end
end

function NOCHECK_EQUIP_CARDSLOT_INFO_OPEN(slotIndex)
    -- EQUIP_CARDSLOT_INFO_OPEN_OLD(slotIndex)
    -- local slv = tonumber(GET_TOTAL_MONEY_STR());
    -- local cardslv = tonumber(cardLv * 2000)
    -- if slv < cardslv then
    -- ui.SysMsg("Not enough silver.")
    -- return
    -- else

    NOCHECK_EQUIP_CARDSLOT_BTN_REMOVE_WITHOUT_EFFECT()
    -- end

    EQUIP_CARDSLOT_INFO_OPEN_OLD(slotIndex)
end

function NOCHECK_EQUIP_GODDESSCARDSLOT_INFO_OPEN(slotIndex)

    NOCHECK_EQUIP_GODDESSCARDSLOT_BTN_REMOVE()

    EQUIP_GODDESSCARDSLOT_INFO_OPEN_OLD(slotIndex)
end

function NOCHECK_EQUIP_CARDSLOT_BTN_REMOVE_WITHOUT_EFFECT()
    local legcardslot = 13
    local frame = ui.GetFrame("monstercardslot")
    local argStr = legcardslot - 1

    argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
    pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)

end

function NOCHECK_EQUIP_GODDESSCARDSLOT_BTN_REMOVE()

    local legcardslot = 14
    local frame = ui.GetFrame("monstercardslot")
    local argStr = legcardslot - 1

    argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
    pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)

end

--[[
local success, err = pcall(function()
    
end)

if not success then
    -- エラーが発生した場合の処理
    print("Error: " .. err)
end
]]
--[[
function EQUIP_CARDSLOT_INFO_OPEN(slotIndex)
	local other_frame = ui.GetFrame('equip_cardslot_info_goddess')
	other_frame:ShowWindow(0)

	local frame = ui.GetFrame('equip_cardslot_info');
	
	if frame:IsVisible() == 1 then
		frame:ShowWindow(0);	
	end
	
	local cardID, cardLv, cardExp = GETMYCARD_INFO(slotIndex);	
	if cardID == 0 then
		return;
	end

	local prop = geItemTable.GetProp(cardID);
	if prop ~= nil then
		cardLv = prop:GetLevel(cardExp);
	end
	
	-- 카드 슬롯 제거하기 위함
	frame:SetUserValue("REMOVE_CARD_SLOTINDEX", slotIndex);

	local inven = ui.GetFrame("inventory");
	local cls = GetClassByType("Item", cardID);

	-- 안내메세지에 이름 적용
	local infoMsg = GET_CHILD(frame, "infoMsg");
	infoMsg:SetTextByKey("Name", cls.Name);

	-- 카드 이미지 적용
	local card_img = GET_CHILD(frame, "card_img");
	card_img:SetImage(TryGetProp(cls, "TooltipImage"));

	local multiValue = 64;	-- 꽉 찬 카드 이미지를 하고 싶다면 90 으로. (단, 카드레벨 하락 정보가 잘 안보일 수 있음.)
	local star_bg = GET_CHILD(frame, "star_bg");
	local cardStar_Before = GET_CHILD(star_bg, "cardStar_Before");
	local imgSize = frame:GetUserConfig('starSize');
	if cardLv <= 1 then	
		multiValue = 90;
		cardStar_Before:SetVisible(0);
	else
		cardStar_Before:SetTextByKey("value", GET_STAR_TXT(imgSize, cardLv, cls));
		cardStar_Before:SetVisible(1);
	end;

	-- 카드 크기 변환.
--	card_img:Resize(3 * multiValue, 4 * multiValue);

	-- 제거되는 효과 표시하는 곳. 
	local removedEffect =  string.format("%s{/}", cls.Desc);	
	if cls.Desc == "None" then
		removedEffect = "{/}";
	end

	local needSilverText = GET_CHILD_RECURSIVELY(frame, "button_3")
	local needSilver = tonumber(CALC_NEED_SILVER(cls, cardLv))
	needSilverText:SetTextByKey("needSilver", GET_COMMAED_STRING(needSilver))
	local bg = GET_CHILD(frame, "bg");
	local effect_info = GET_CHILD(bg, "effect_info");
	effect_info:SetTextByKey("RemovedEffect", removedEffect);
	
	-- 정보창 위치를 인벤 옆으로 붙힘.
	frame:SetOffset(inven:GetX() - frame:GetWidth(), frame:GetY());

	frame:ShowWindow(1);	
end

function BEFORE_APPLIED_YESSCP_OPEN_BASIC_MSG(invItem)
	if invItem == nil then
		return;
	end
	
	local invFrame = ui.GetFrame("inventory");	
	local itemobj = GetIES(invItem:GetObject());
	if itemobj == nil then
		return;
	end
	invFrame:SetUserValue("REQ_USE_ITEM_GUID", invItem:GetIESID());
	
	local textmsg = string.format("[ %s ]{nl}%s", itemobj.Name, ScpArgMsg("YESSCP_OPEN_BASIC_MSG"));
	ui.MsgBox_NonNested(textmsg, itemobj.Name, 'REQUEST_SUMMON_BOSS_TX', "None");
	
	return;
end

function CARD_SLOT_EQUIP(slot, item, groupNameStr)
	local obj = GetIES(item:GetObject());
	if obj.GroupName == "Card" then			
		local slotIndex = CARD_SLOT_GET_SLOT_INDEX(groupNameStr, slot:GetSlotIndex());
		local cardInfo = equipcard.GetCardInfo(slotIndex + 1);


		if cardInfo ~= nil then
			ui.SysMsg(ClMsg("AlreadyEquippedThatCardSlot"));
			return;
		end
			
		if item.isLockState == true then
			ui.SysMsg(ClMsg("MaterialItemIsLock"));
			return
		end

		local itemGuid = item:GetIESID();
		local invFrame = ui.GetFrame("inventory");	
		invFrame:SetUserValue("EQUIP_CARD_GUID", itemGuid);
		invFrame:SetUserValue("EQUIP_CARD_SLOTINDEX", slotIndex);	

		if groupNameStr == 'LEG' then
			local pcEtc = GetMyEtcObject();
			if pcEtc.IS_LEGEND_CARD_OPEN ~= 1 then
				ui.SysMsg(ClMsg("LegendCard_Slot_NotOpen"))
				return
			end	

			local textmsg = string.format("[ %s ]{nl}%s", obj.Name, ScpArgMsg("AreYouSureEquipCard"));	
			ui.MsgBox_NonNested(textmsg, invFrame:GetName(), "REQUEST_EQUIP_CARD_TX", "REQUEST_EQUIP_CARD_CANCLE");		
		else
			REQUEST_EQUIP_CARD_TX();
		end
	end
end

]]
