local addonName = "monstercard_changer"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

g.SettingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

function MONSTERCARD_CHANGER_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    -- acutil.setupHook(monstercard_changer_CARD_PRESET_SELECT_PRESET, "CARD_PRESET_SELECT_PRESET")

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local invframe = ui.GetFrame('inventory')
        local inventoryGbox = invframe:GetChild("inventoryGbox")
        local btnX = inventoryGbox:GetWidth() - 492
        local btnY = inventoryGbox:GetHeight() - 290 -- 290
        local mccqbtn = invframe:CreateOrGetControl("button", "mcc", btnX, btnY, 30, 32)
        AUTO_CAST(mccqbtn)
        mccqbtn:SetSkinName("test_red_button")
        mccqbtn:SetTextAlign("right", "center")
        mccqbtn:SetText("{img monsterbtn_image 28 23}{/}")
        mccqbtn:SetEventScript(ui.LBUTTONUP, "monstercard_changer_frame_init")
        mccqbtn:SetEventScript(ui.RBUTTONUP, "monstercard_changer_MONSTERCARDSLOT_FRAME_INIT")
        -- monstercard_changer_frame_init()
    end
end

function monstercard_changer_MONSTERCARDSLOT_FRAME_INIT()
    --[[
    local frame = ui.GetFrame('monstercardslot')
    CARD_PRESET_CLEAR_SLOT(frame)
    ui.OpenFrame("monstercardslot")

    CARD_SLOTS_CREATE(frame)

    local isOpen = frame:GetUserIValue("CARD_OPTION_OPENED");
    local optionGbox = GET_CHILD_RECURSIVELY(frame, "option_bg")
    optionGbox:ShowWindow(1)

    CARD_OPTION_OPEN(frame)
    frame:SetUserValue("CARD_OPTION_OPENED", 0);
]]
    local frame = ui.GetFrame(addonName)
    CARD_PRESET_CLEAR_SLOT(frame)
    ui.OpenFrame(addonName)

    monstercard_changer_CARD_SLOTS_CREATE(frame)

    local isOpen = frame:GetUserIValue("CARD_OPTION_OPENED");
    local optionGbox = GET_CHILD_RECURSIVELY(frame, "option_bg")
    optionGbox:ShowWindow(1)

    monstercard_changer_CARD_OPTION_OPEN(frame)
    frame:SetUserValue("CARD_OPTION_OPENED", 0);

end

function monstercard_changer_CARD_SLOTS_CREATE(frame)
    local monsterCardSlotFrame = frame;

    if monsterCardSlotFrame == nil then

        monsterCardSlotFrame = ui.GetFrame('monstercardslot')
    end

    monstercard_changer_CARD_SLOT_CREATE(monsterCardSlotFrame, 'ATK', 0 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    monstercard_changer_CARD_SLOT_CREATE(monsterCardSlotFrame, 'DEF', 1 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    monstercard_changer_CARD_SLOT_CREATE(monsterCardSlotFrame, 'UTIL', 2 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    monstercard_changer_CARD_SLOT_CREATE(monsterCardSlotFrame, 'STAT', 3 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)
    -- monstercard_changer_CARD_SLOT_CREATE(monsterCardSlotFrame, 'LEG', 4 * MONSTER_CARD_SLOT_COUNT_PER_TYPE)

end

function monstercard_changer_CARD_SLOT_CREATE(monsterCardSlotFrame, cardGroupName, slotIndex)
    local frame = monsterCardSlotFrame;
    if frame == nil then

        frame = ui.GetFrame('monstercardslot')
    end

    if cardGroupName == nil then
        return
    end

    local card_slotset = GET_CHILD_RECURSIVELY(frame, cardGroupName .. "card_slotset");
    local card_labelset = GET_CHILD_RECURSIVELY(frame, cardGroupName .. "card_labelset");

    if card_slotset ~= nil and card_labelset ~= nil then
        for i = 0, MONSTER_CARD_SLOT_COUNT_PER_TYPE - 1 do -- 슬롯은 왼쪽부터 순서대로 결정
            local slot_label = card_labelset:GetSlotByIndex(i);
            if slot_label == nil then
                return;
            end
            local icon_label = CreateIcon(slot_label)
            if cardGroupName == 'ATK' then
                icon_label:SetImage('red_cardslot1')
            elseif cardGroupName == 'DEF' then
                icon_label:SetImage('blue_cardslot1')
            elseif cardGroupName == 'UTIL' then
                icon_label:SetImage('purple_cardslot1')
            elseif cardGroupName == 'STAT' then
                icon_label:SetImage('green_cardslot1')
                -- elseif cardGroupName == 'LEG' then
                -- icon_label:SetImage('legendopen_cardslot')
            end
            local cardID, cardLv, cardExp = GETMYCARD_INFO(slotIndex + i);
            monstercard_changer_CARD_SLOT_SET(card_slotset, card_labelset, i, cardID, cardLv, cardExp);
        end
    end

end

function monstercard_changer_CARD_SLOT_SET(ctrlSet, slot_label_set, slotIndex, itemClsId, itemLv, itemExp)
    local cls = nil;
    local cardID = tonumber(itemClsId);
    local cardLv = tonumber(itemLv);
    local cardExp = tonumber(itemExp);

    local cardCls = GetClassByType("Item", itemClsId)
    local cardGroupName = 'None';
    if cardCls == nil then
        return;
    end
    if cardCls.CardGroupName == nil or cardCls.CardGroupName == 'None' then
        return
    end
    cardGroupName = cardCls.CardGroupName

    local slot = ctrlSet:GetSlotByIndex(slotIndex);
    if slot == nil then
        return;
    end

    local slot_label = slot_label_set:GetSlotByIndex(slotIndex);
    if slot_label == nil then
        return;
    end

    if cardID > 0 then
        cls = GetClassByType("Item", cardID);
        if cls.GroupName ~= "Card" then
            return;
        end
    else
        slot:ClearIcon();
        return;
    end

    local icon = slot:GetIcon();
    local icon_label = slot_label:GetIcon();
    if icon == nil or icon_label == nil then
        -- icon이 없다는 건 아직 장착되지 않았다는 말.
        icon = CreateIcon(slot);
        icon_label = CreateIcon(slot_label)
    end

    if cls ~= nil then
        local imageName = cls.TooltipImage;
        if imageName ~= nil then
            icon:SetImage(cls.TooltipImage);
            local icon_label = CreateIcon(slot_label)
            if cardGroupName == 'ATK' then
                icon_label:SetImage('red_cardslot')
            elseif cardGroupName == 'DEF' then
                icon_label:SetImage('blue_cardslot')
            elseif cardGroupName == 'UTIL' then
                icon_label:SetImage('purple_cardslot')
            elseif cardGroupName == 'STAT' then
                icon_label:SetImage('green_cardslot')
                -- elseif cardGroupName == 'LEG' then
                -- icon_label:SetImage('yellow_cardslot')
            end
            icon:Invalidate();
            icon_label:Invalidate();
        end
    end

    -- 카드 프리셋 임시 등록용 데이터
    icon:SetUserValue("CARD_TEMP_CLASSID", itemClsId)
    icon:SetUserValue("CARD_TEMP_LEVEL", itemLv)
    icon:SetUserValue("CARD_TEMP_EXP", itemExp)

    -- 툴팁 생성 (카드 아이템은 IES가 사라지기 때문에 똑같이 생긴 툴팁을 따로 만들어서 적용)
    slot:SetEventScript(ui.MOUSEMOVE, "EQUIP_CARDSLOT_INFO_TOOLTIP_OPEN");
    slot:SetEventScriptArgNumber(ui.MOUSEMOVE, slotIndex);
    slot:SetEventScript(ui.LOST_FOCUS, "EQUIP_CARDSLOT_INFO_TOOLTIP_CLOSE");
    -- CHAT_SYSTEM("3")
end

function monstercard_changer_CARD_OPTION_OPEN(monsterCardSlotFrame)
    local frame = monsterCardSlotFrame;
    if frame == nil then
        frame = ui.GetFrame('monstercardslot')
    end

    local isOpen = frame:GetUserIValue("CARD_OPTION_OPENED");
    if isOpen == nil then
        return;
    end

    local optionGbox = GET_CHILD_RECURSIVELY(frame, 'option_bg')
    local optionBtn = frame:GetChild('optionBtn');

    local bg = frame:GetChild('bg');
    local mainGbox = frame:GetChild('mainGbox');
    local pip = frame:GetChild('pip4');

    local option_H = optionGbox:GetHeight();
    local bg_X = bg:GetOriginalX();
    local bg_Y = bg:GetOriginalY();
    local bg_W = bg:GetWidth();
    local bg_H = bg:GetHeight();

    monstercard_changer_CARD_OPTION_CREATE(frame)
    bg:Resize(bg_X, bg_Y, bg_W, mainGbox:GetHeight() + pip:GetHeight() + option_H);
end

function monstercard_changer_frame_close(frame)
    ui.CloseFrame(addonName)
end

function monstercard_changer_frame_init()

    local frame = ui.GetFrame(addonName)
    if frame:IsVisible() == 1 then
        monstercard_changer_frame_close(frame)
        return
    end
    frame:ShowWindow(1)

    local closebtn = GET_CHILD_RECURSIVELY(frame, 'close')
    closebtn:SetEventScript(ui.LBUTTONUP, "monstercard_changer_frame_close")

    local bg = GET_CHILD_RECURSIVELY(frame, "bg")
    bg:Resize(550, 736)

    local isOpen = frame:GetUserIValue("CARD_OPTION_OPENED");
    local optionGbox = GET_CHILD_RECURSIVELY(frame, "option_bg")
    optionGbox:ShowWindow(1)

    monstercard_changer_CARD_OPTION_OPEN(frame)
    frame:SetUserValue("CARD_OPTION_OPENED", 0);

end

