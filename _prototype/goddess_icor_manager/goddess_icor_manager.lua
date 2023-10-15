local addonName = "GODDESS_ICOR_MANAGER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

function GODDESS_ICOR_MANAGER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    -- addon:RegisterMsg("PARTY_BUFFLIST_UPDATE", "test_norisan_ON_PARTYINFO_BUFFLIST_UPDATE");
    -- g.SetupHook(test_norisan_ON_PARTYINFO_BUFFLIST_UPDATE, "PARTY_BUFFLIST_UPDATE")
    acutil.setupHook(goddess_icor_manager_GODDESS_MGR_RANDOMOPTION_PRESET_SELECT,
        "GODDESS_MGR_RANDOMOPTION_PRESET_SELECT")

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        goddess_icor_manager_frame_init()
        return;
    end

end

function goddess_icor_manager_GODDESS_MGR_RANDOMOPTION_PRESET_SELECT(parent, ctrl)
    local frame = parent:GetTopParentFrame()
    local index = ctrl:GetSelItemKey()
    -- print(tostring(index))
    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, 'randomoption_bg')
    randomoption_bg:SetUserValue('PRESET_INDEX', index)
    -- print(tostring(randomoption_bg:GetUserValue('PRESET_INDEX')))

    local randomoption_tab = GET_CHILD_RECURSIVELY(frame, 'randomoption_tab')
    local index = randomoption_tab:GetSelectItemIndex()
    if index == 0 then
        GODDESS_MGR_RANDOMOPTION_ENGRAVE_ICOR_UPDATE(frame) -- 각인 저장(아이커)
    elseif index == 1 then
        GODDESS_MGR_RANDOMOPTION_APPLY_OPEN(frame) -- 각인 부여
    elseif index == 2 then
        GODDESS_MGR_RANDOMOPTION_ENGRAVE_OPEN(frame) -- 각인 저장(옛날)
    end
end

function goddess_icor_manager_frame_init()
    local frame = ui.GetFrame("goddess_equip_manager")
    local randomoption_bg = GET_CHILD_RECURSIVELY(frame, "randomoption_bg")
    local listbtn = randomoption_bg:CreateOrGetControl("button", "listbtn", 520, 12, 160, 40)
    AUTO_CAST(listbtn)
    listbtn:SetText("{ol}list")
    listbtn:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_init")

end

function goddess_icor_manager_get_pagename(index)
    local pc_etc = GetMyEtcObject()
    local acc = GetMyAccountObj()
    if pc_etc == nil or acc == nil then
        return nil
    end
    local page_name = TryGetProp(pc_etc, 'RandomOptionPresetName_' .. index, 'None')
    if page_name == 'None' then
        return ScpArgMsg('EngravePageNumber{index}', 'index', index)
    else
        return page_name
    end

end

function goddess_icor_manager_list_maxcount(frame)

    local acc = GetMyAccountObj()

    local page_max = GET_MAX_ENGARVE_SLOT_COUNT(acc)
    for i = 1, page_max do
        local bg = GET_CHILD_RECURSIVELY(frame, "bg" .. i)
        if bg ~= nil then
            frame:RemoveChild("bg" .. i)
        end
    end
    local Y = 20
    local YY = 20
    for i = 1, 10 do
        -- for i = 1, page_max do
        if i <= 5 then
            local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, Y, 0, 265, 440)
            Y = Y + 265

            local pagename = bg:CreateOrGetControl("richtext", "pagename" .. i, 10, 5)
            pagename:SetText(goddess_icor_manager_get_pagename(i))
            bg:SetSkinName("bg")
            bg:ShowWindow(1)
        end
        if i >= 6 then
            local bg = frame:CreateOrGetControl("groupbox", "bg" .. i, YY, 445, 265, 440)
            YY = YY + 265

            local pagename = bg:CreateOrGetControl("richtext", "pagename" .. i, 10, 5)
            pagename:SetText(goddess_icor_manager_get_pagename(i))
            bg:SetSkinName("bg")
            bg:ShowWindow(1)
        end

    end
    local gemframe = ui.GetFrame("goddess_equip_manager")
    local randapplybg = GET_CHILD_RECURSIVELY(gemframe, 'rand_apply_bg')
    local rand_preset_list = GET_CHILD_RECURSIVELY(gemframe, 'rand_preset_list')
    local randomoption_bg = GET_CHILD_RECURSIVELY(gemframe, 'randomoption_bg')
    local index = randomoption_bg:GetUserValue('PRESET_INDEX')
    -- local arg_list = NewStringList()
    local arg_list = {}
    for i = 1, page_max do
        -- session.ResetItemList()
        arg_list:Add(i)

        print(tostring(arg_list))

    end

    --[[for i = 1, page_max do
        local page_name = goddess_icor_manager_get_pagename(i)

        rand_preset_list:AddItem(tostring(i), page_name)
        -- print(tostring(rand_preset_list))
    end

    -- リスト内のアイテムを表示
    for i = 0, rand_preset_list:GetItemCount() - 1 do
        local item = rand_preset_list:GetItemByIndex(i)
        local itemName = item:GetText()
        print(tostring(itemName))
    end]]
end

function goddess_icor_manager_list_init()
    local frame = ui.GetFrame("goddess_icor_manager")
    frame:Resize(1400, 900)
    frame:ShowWindow(1)
    frame:SetLayerLevel(120)
    local close = frame:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    close:SetText("×")
    close:SetGravity(ui.RIGHT, ui.TOP);
    close:SetMargin(0, 0, 20, -70);
    close:ShowWindow(1)
    close:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_close")
    goddess_icor_manager_list_maxcount(frame)
    -- close:SetEventScript(ui.LBUTTONUP, "goddess_icor_manager_list_maxcount")
end

function goddess_icor_manager_list_close(frame)
    frame:ShowWindow(0)
end
