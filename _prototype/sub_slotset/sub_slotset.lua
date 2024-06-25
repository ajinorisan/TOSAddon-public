local addonName = "SUB_SLOTSET"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")
local os = require("os")
local json = require("json")

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function SUB_SLOTSET_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}

    addon:RegisterMsg("GAME_START", "sub_slotset_frame_init")
    -- acutil.setupEvent(addon, "CABINET_GET_ITEM", "market_voucher_CABINET_GET_ITEM");
    -- g.SetupHook(market_voucher_CABINET_GET_ALL_LIST, "CABINET_GET_ALL_LIST");
end

function sub_slotset_frame_init()
    local frame = ui.GetFrame("quickslotnexpbar")
    local emoticon = frame:CreateOrGetControl("button", "emoticon", 0, 0, 20, 20)

    AUTO_CAST(emoticon)
    emoticon:SetText("{ol}{s11}E")
    emoticon:SetGravity(ui.RIGHT, ui.BOTTOM)
    emoticon:SetMargin(0, 0, 0, 0);
    emoticon:SetEventScript(ui.LBUTTONUP, "sub_slotset_emoticon")

    local move_emoticon = frame:CreateOrGetControl("button", "move_emoticon", 0, 0, 20, 20)
    AUTO_CAST(move_emoticon)
    move_emoticon:SetText("{ol}{s11}E")
    move_emoticon:SetGravity(ui.RIGHT, ui.BOTTOM)
    move_emoticon:SetMargin(0, -25, 0, 0);

end

function sub_slotset_emoticon(frame, ctrl, str, num)

    local frame = ui.GetFrame("chat_emoticon")
    local list, listCnt = GetClassList("chat_emoticons")
    -- local emoticons = GET_CHILD_RECURSIVELY(frame, "emoticons")
    local emoticons = frame:CreateOrGetControl('slotset', 'slotset', 0, 0, 0, 0)
    AUTO_CAST(emoticons);
    emoticons:SetSlotSize(42, 42) -- スロットの大きさ
    emoticons:EnablePop(0)
    emoticons:EnableDrag(0)
    emoticons:EnableDrop(0)
    local emoticons_row = math.ceil(listCnt / 10)
    emoticons:SetColRow(10, emoticons_row)
    emoticons:SetSpc(0, 0)
    emoticons:SetSkinName('invenslot')
    emoticons:CreateSlots()

    local cnt = emoticons:GetSlotCount()
    local acc = GetMyAccountObj()
    local index = 0
    local list, listCnt = GetClassList("chat_emoticons")

    -- 아이콘 타입 확인 : 일반, 모션
    local iconGroup = frame:GetUserValue("EMOTICON_GROUP")
    local curCnt = frame:GetUserIValue("CURCNT")
    if iconGroup == "None" then
        iconGroup = "Normal"
    end

    for i = 0, listCnt - 1 do
        acc = GetMyAccountObj()
        local slot = emoticons:GetSlotByIndex(index)
        slot:SetEventScript(ui.MOUSEMOVE, "CHAT_EMOTICON_ADDDURATION")
        slot:SetOverSound("button_over")
        slot:SetClickSound("button_click_chat")
        if index < cnt then
            local cls = GetClassByIndexFromList(list, i)

            if TryGetProp(cls, 'HaveUnit', 'None') == 'PC' then
                acc = GetMyEtcObject()
            else
                acc = GetMyAccountObj()
            end

            if cls.IconGroup == iconGroup then
                if cls.CheckServer == 'YES' then
                    -- check session emoticons
                    local haveEmoticon = TryGetProp(acc, 'HaveEmoticon_' .. cls.ClassID)
                    if haveEmoticon > 0 then
                        local icon = CreateIcon(slot)
                        local namelist = StringSplit(cls.ClassName, "motion_")
                        local imageName = namelist[1]
                        if 1 < #namelist then
                            imageName = namelist[2]
                        end

                        icon:SetImage(imageName)
                        local tooltipText = string.format("%s%s", "/", cls.IconTokken)
                        icon:SetTextTooltip(tooltipText)

                        index = index + 1
                        slot:ShowWindow(1)
                    end
                else
                    local icon = CreateIcon(slot)
                    local namelist = StringSplit(cls.ClassName, "motion_")
                    local imageName = namelist[1]
                    if 1 < #namelist then
                        imageName = namelist[2]
                    end

                    icon:SetImage(imageName)
                    local tooltipText = string.format("%s%s", "/", cls.IconTokken)
                    icon:SetTextTooltip(tooltipText)
                    index = index + 1
                    slot:ShowWindow(1)
                end
            end
        end
    end

    if curCnt ~= 0 then
        for i = index, curCnt - 1 do
            local slot = emoticons:GetSlotByIndex(i)
            slot:ClearIcon()
        end
    end

    frame:SetUserValue("CURCNT", index)

end
