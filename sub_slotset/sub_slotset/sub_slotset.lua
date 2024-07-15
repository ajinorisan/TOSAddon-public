-- v1.0.1 レイヤー設定追加。再設定機能追加。エモを右クリックでチャット。
local addonName = "SUB_SLOTSET"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.1"

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

function sub_slotset_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)
    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        settings = {
            index = 0
        }
    end
    g.settings = settings

    sub_slotset_save_settings()
    sub_slotset_personal_load_settings()

end

function sub_slotset_personal_load_settings()

    local cid = info.GetCID(session.GetMyHandle())
    g.personalFileLoc = string.format('../addons/%s/%s.json', addonNameLower, cid)

    local settings, err = acutil.loadJSON(g.personalFileLoc)
    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings or next(settings) == nil then
        settings = {}
    end

    g.personal = settings

    sub_slotset_personal_save_settings()

    sub_slotset_frame_init()

end

function sub_slotset_personal_save_settings()

    acutil.saveJSON(g.personalFileLoc, g.personal)
end

function sub_slotset_save_settings()
    acutil.saveJSON(g.settingsFileLoc, g.settings)

end

function SUB_SLOTSET_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.settings = g.settings or {}
    g.personal = g.personal or {}

    addon:RegisterMsg("GAME_START", "sub_slotset_load_settings")
    -- addon:RegisterMsg("GAME_START", "sub_slotset_frame_init")
    acutil.setupEvent(addon, "MAKE_QUEST_INFO_TYPE_ICON", "sub_slotset_MAKE_QUEST_INFO_TYPE_ICON");
    acutil.setupEvent(addon, "EMO_OPEN", "sub_slotset_EMO_OPEN");

end

function sub_slotset_frame_init()

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local frame = ui.GetFrame("sub_slotset")

        frame:SetSkinName("None")
        frame:SetTitleBarSkin("None")
        frame:Resize(30, 30)

        frame:SetPos(783, 5)
        frame:SetLayerLevel(30);
        frame:ShowWindow(1)

        local slot = frame:CreateOrGetControl('slot', 'slot', 0, 0, 25, 25)
        AUTO_CAST(slot)
        slot:SetSkinName("None");
        slot:EnablePop(0)
        slot:EnableDrop(0)
        slot:EnableDrag(0)
        slot:SetEventScript(ui.LBUTTONUP, "sub_slotset_make_frame");

        local icon = CreateIcon(slot);
        AUTO_CAST(icon)
        icon:SetImage("btn_plus");
        icon:SetTextTooltip("Sub SlotSet")
    end
    sub_slotset_slotset_frame_init("character")
    sub_slotset_slotset_frame_init("shared")
end

function sub_slotset_slotset_frame_init(belong, isnew)

    local slot_frame
    local table = {}
    local index = g.settings.index or 0
    if belong == "shared" then
        table = g.settings

    elseif belong == "character" then
        table = g.personal

    end

    local X = ui.GetClientInitialWidth() / 2 -- 1920
    local Y = ui.GetClientInitialHeight() / 2 -- 1080
    local column = g.column or tonumber(3)
    local row = g.row or tonumber(3)
    local size = g.size or tonumber(48)
    local layer = g.layer or tonumber(90)

    if isnew then

        slot_frame = ui.CreateNewFrame("notice_on_pc", "sub_slotset_" .. index, 0, 0, 0, 0)
        slot_frame:SetSkinName("chat_window_2")
        slot_frame:SetAlpha(20)
        slot_frame:SetLayerLevel(layer)
        slot_frame:ShowWindow(1)
        slot_frame:EnableHittestFrame(1)
        slot_frame:EnableMove(1)

        slot_frame:SetEventScript(ui.RBUTTONUP, "sub_slotset_newframe_rbutton")

        slot_frame:SetEventScript(ui.LBUTTONUP, "sub_slotset_newframe_end_drag")

        slot_frame:SetPos(X, Y)

        slot_frame:Resize(size * column + 10 + column * 2, size * row + 10 + row * 2)

        slot_frame:SetUserValue("ISNEW", "true")
        slot_frame:SetUserValue("BELONG", belong)

        sub_slotset_slotset_init(slot_frame)
    end

    for key, value in pairs(table) do

        if string.find(key, "sub_slotset_") then

            slot_frame = ui.CreateNewFrame("notice_on_pc", key, 0, 0, 0, 0)
            slot_frame:SetSkinName("chat_window_2")
            slot_frame:SetAlpha(20)
            slot_frame:SetLayerLevel(layer)
            slot_frame:ShowWindow(1)
            slot_frame:EnableHittestFrame(1)
            slot_frame:EnableMove(1)

            slot_frame:SetEventScript(ui.RBUTTONUP, "sub_slotset_newframe_rbutton")

            slot_frame:SetEventScript(ui.LBUTTONUP, "sub_slotset_newframe_end_drag")

            for k2, v2 in pairs(value) do
                if k2 == "etc" then
                    X = v2.X
                    Y = v2.Y
                    column = v2.column
                    row = v2.row
                    size = v2.size
                    break
                end

            end

            slot_frame:SetPos(X, Y)

            slot_frame:Resize(size * column + 10 + column * 2, size * row + 10 + row * 2)

            slot_frame:SetUserValue("ISNEW", "false")
            slot_frame:SetUserValue("BELONG", belong)
            sub_slotset_slotset_init(slot_frame)
        end
    end

end

function sub_slotset_newframe_end_drag(frame, ctrl, str, num)

    local belong = frame:GetUserValue("BELONG")

    if belong == "shared" then
        for key, value in pairs(g.settings[frame:GetName()]) do

            if key == "etc" then
                for k2, v2 in pairs(value) do

                    g.settings[frame:GetName()]["etc"].X = frame:GetX()
                    g.settings[frame:GetName()]["etc"].Y = frame:GetY()

                end
            end

        end
        sub_slotset_save_settings()
    elseif belong == "character" then
        for key, value in pairs(g.personal[frame:GetName()]) do

            if key == "etc" then
                for k2, v2 in pairs(value) do

                    g.personal[frame:GetName()]["etc"].X = frame:GetX()
                    g.personal[frame:GetName()]["etc"].Y = frame:GetY()

                end
            end

        end

        sub_slotset_personal_save_settings()
    end

end

function sub_slotset_slotset_init(frame)

    local str = frame:GetUserValue("BELONG")
    local isnew = frame:GetUserValue("ISNEW")

    local client_Width = ui.GetClientInitialWidth() -- 1920
    local client_Height = ui.GetClientInitialHeight() -- 1080

    local column = 0
    local row = 0
    local size = 0
    local layer = 0

    if isnew == "true" then

        column = g.column or tonumber(3)
        row = g.row or tonumber(3)
        size = g.size or tonumber(48)
        layer = g.layer or tonumber(90)
    elseif str == "shared" then

        column = g.settings[frame:GetName()]["etc"].column
        row = g.settings[frame:GetName()]["etc"].row
        size = g.settings[frame:GetName()]["etc"].size
        if g.settings[frame:GetName()]["etc"].layer ~= nil then
            layer = g.settings[frame:GetName()]["etc"].layer
        else
            layer = g.layer or tonumber(90)
        end

    elseif str == "character" then
        column = g.personal[frame:GetName()]["etc"].column
        row = g.personal[frame:GetName()]["etc"].row
        size = g.personal[frame:GetName()]["etc"].size
        if g.personal[frame:GetName()]["etc"].layer ~= nil then
            layer = g.personal[frame:GetName()]["etc"].layer
        else
            layer = g.layer or tonumber(90)
        end
    end

    frame:SetLayerLevel(layer)

    local slotset = frame:CreateOrGetControl('slotset', 'slotset', 2, 9, 0, 0)
    AUTO_CAST(slotset);
    slotset:EnablePop(1)
    slotset:EnableDrag(1)
    slotset:EnableDrop(1)
    slotset:EnableHitTest(1);
    slotset:SetColRow(column, row)
    slotset:SetSlotSize(size, size)
    slotset:SetSpc(2, 2)
    slotset:SetSkinName('invenslot2')
    slotset:CreateSlots()

    if str == "shared" then
        local titlelabel = frame:CreateOrGetControl('richtext', 'titlelabel', 0, 0, 0, 0)
        titlelabel:SetTextAlign('center', 'center')
        titlelabel:SetGravity(ui.LEFT, ui.TOP)
        titlelabel:SetText("{ol}{s10}shared")
        if g.settings[frame:GetName()] then
            if g.settings[frame:GetName()]["etc"].lock then
                local controlset = frame:CreateOrGetControlSet('inv_itemlock', "itemlock", 0, 0);
                controlset:SetGravity(ui.RIGHT, ui.TOP);
                controlset:ShowWindow(1)
                -- frame:EnableHittestFrame(0)
                frame:EnableMove(0)
            elseif not g.settings[frame:GetName()]["etc"].lock then
                local controlset = GET_CHILD_RECURSIVELY(frame, "itemlock")
                if controlset ~= nil then
                    controlset:ShowWindow(0)
                    frame:EnableMove(1)
                    -- DESTROY_CHILD_BYNAME(frame, "itemlock");
                end
            end
        end
    elseif str == "character" then
        if g.personal[frame:GetName()] then
            if g.personal[frame:GetName()]["etc"].lock then
                local controlset = frame:CreateOrGetControlSet('inv_itemlock', "itemlock", 0, 0);
                controlset:SetGravity(ui.RIGHT, ui.TOP);
                controlset:ShowWindow(1)
                frame:EnableMove(0)
            elseif not g.personal[frame:GetName()]["etc"].lock then
                local controlset = GET_CHILD_RECURSIVELY(frame, "itemlock")
                if controlset ~= nil then
                    controlset:ShowWindow(0)
                    frame:EnableMove(1)
                    -- DESTROY_CHILD_BYNAME(frame, "itemlock");
                end
            end
        end
    end

    if isnew == "true" then
        local slot_count = slotset:GetSlotCount()

        if str == "shared" then

            if not g.settings[frame:GetName()] then
                g.settings[frame:GetName()] = {}
            end

            local slot_table = {}

            for i = 1, slot_count do

                slot_table[tostring(i)] = {
                    category = "",
                    clsid = 0,
                    iesid = ""

                }

            end

            local etc_table = {
                column = column,
                row = row,
                size = size,
                X = client_Width / 2,
                Y = client_Height / 2,
                lock = false,
                layer = layer
            }

            g.settings[frame:GetName()] = slot_table
            g.settings[frame:GetName()]["etc"] = etc_table -- ここで etc_table を settings として保存

            sub_slotset_save_settings()

        elseif str == "character" then

            if not g.personal[frame:GetName()] then
                g.personal[frame:GetName()] = {}
            end

            local slot_table = {}

            for i = 1, slot_count do
                slot_table[tostring(i)] = {
                    category = "",
                    clsid = 0,
                    iesid = ""

                }

            end

            local etc_table = {
                column = column,
                row = row,
                size = size,
                X = client_Width / 2,
                Y = client_Height / 2,
                lock = false,
                layer = layer
            }

            g.personal[frame:GetName()] = slot_table
            g.personal[frame:GetName()]["etc"] = etc_table -- ここで etc_table を settings として保存

            sub_slotset_personal_save_settings()

        end
    end
    frame:ShowWindow(1)
    frame:SetUserValue("ISNEW", "false")
    frame:RunUpdateScript("sub_slotset_slotset_update", 0.3)
end

function sub_slotset_slotset_update(frame)

    local isnew = frame:GetUserValue("ISNEW")

    if isnew == "true" then
        sub_slotset_slotset_init(frame)
    end

    local belong = frame:GetUserValue("BELONG")

    local frame_name = frame:GetName()

    local frame = ui.GetFrame(frame_name)
    local slotset = GET_CHILD_RECURSIVELY(frame, "slotset")
    AUTO_CAST(slotset)
    slotset:EnablePop(1)
    slotset:EnableDrag(1)
    slotset:EnableDrop(1)
    slotset:EnableHitTest(1);
    local slot_count = slotset:GetSlotCount()

    local clsid = 0
    local category = ""
    local iesid = ""

    for i = 1, slot_count do
        local slot = GET_CHILD(slotset, "slot" .. i)
        AUTO_CAST(slot)

        if belong == "shared" then
            clsid = g.settings[frame_name][tostring(i)].clsid
            category = g.settings[frame_name][tostring(i)].category
            iesid = g.settings[frame_name][tostring(i)].iesid
        elseif belong == "character" then
            clsid = g.personal[frame_name][tostring(i)].clsid
            category = g.personal[frame_name][tostring(i)].category
            iesid = g.personal[frame_name][tostring(i)].iesid
        end
        if clsid == "Normal" then
            clsid = 98
        elseif clsid == "Motion" then
            clsid = 99
        end

        slot:SetEventScript(ui.RBUTTONUP, 'sub_slotset_slot_rbutton');
        slot:SetEventScriptArgNumber(ui.RBUTTONUP, clsid);
        slot:SetEventScriptArgString(ui.RBUTTONUP, category)
        slot:SetEventScript(ui.DROP, 'sub_slotset_drop')
        slot:SetEventScriptArgString(ui.DROP, belong)
        slot:SetEventScript(ui.POP, 'sub_slotset_pop')
        slot:SetEventScriptArgString(ui.POP, belong)

        local isLocked = false
        if g.settings[frame_name] and g.settings[frame_name]["etc"] then
            isLocked = g.settings[frame_name]["etc"].lock == true
        elseif g.personal[frame_name] and g.personal[frame_name]["etc"] then
            isLocked = g.personal[frame_name]["etc"].lock == true
        end

        if isLocked then
            slot:EnablePop(0)
            slot:EnableDrag(0)
        else
            slot:EnablePop(1)
            slot:EnableDrag(1)
        end

        if category == "Item" then
            local invItem = session.GetInvItemByGuid(iesid) or session.GetInvItemByType(clsid)
            local ItemCls = GetClassByType("Item", clsid)
            if invItem ~= nil then

                CreateIcon(slot):SetColorTone('FFFFFFFF')
                SET_SLOT_ITEM_IMAGE(slot, invItem)
                local icon = slot:GetIcon()
                ICON_SET_ITEM_COOLDOWN_OBJ(icon, GetIES(invItem:GetObject()))
                SET_SLOT_ITEM_TEXT(slot, invItem, ItemCls)

            else
                SET_SLOT_ITEM_CLS(slot, ItemCls);
                CreateIcon(slot):SetColorTone('FFFF0000')
            end
        elseif category == "Pose" then
            local icon = CreateIcon(slot)
            local pose = GetClassByType('Pose', clsid)
            icon:Set(pose.Icon, category, clsid, 0, iesid)
            icon:SetColorTone('FFFFFFFF')
            icon:SetTextTooltip(pose.Name)
            slot:ClearText()

        elseif category == "Skill" then
            local icon = CreateIcon(slot)
            local pose = GetClassByType('Pose', clsid)
            icon:SetOnCoolTimeUpdateScp('ICON_UPDATE_SKILL_COOLDOWN')
            icon:SetEnableUpdateScp('ICON_UPDATE_SKILL_ENABLE')
            icon:SetColorTone('FFFFFFFF')
            icon:SetTooltipType('skill')
            icon:Set('icon_' .. GetClassString('Skill', clsid, 'Icon'), category, clsid, 0, iesid)
            icon:SetTooltipNumArg(clsid)
            icon:SetTooltipIESID(iesid)
            slot:ClearText()
            QUICKSLOT_MAKE_GAUGE(slot)
            QUICKSLOT_SET_GAUGE_VISIBLE(slot, 0)
            SET_QUICKSLOT_OVERHEAT(slot)

        elseif category == 'Ability' then

            local pc = GetMyPCObject();
            local abilClass = GetClassByType("Ability", clsid)
            local abilIES = GetAbilityIESObject(pc, abilClass.ClassName);
            if abilIES ~= nil then
                local icon = CreateIcon(slot)
                icon:SetTooltipType("ability")
                icon:SetTooltipNumArg(clsid)
                icon:SetColorTone('FFFFFFFF')
                icon:Set(abilClass.Icon, category, clsid, 0, iesid)
                slot:ClearText()
                SET_ABILITY_TOGGLE_COLOR(icon, clsid)
            else
                local icon = CreateIcon(slot)
                icon:SetTooltipType("ability")
                icon:SetTooltipNumArg(clsid)
                icon:SetColorTone('FFFF0000')
                icon:Set(abilClass.Icon, category, clsid, 0, iesid)
                slot:ClearText()
                SET_ABILITY_TOGGLE_COLOR(icon, clsid)
            end

        elseif category == 'Quest' then
            local pc = GetMyPCObject();
            local questIES = GetClassByType("QuestProgressCheck", clsid);
            local result = SCR_QUEST_CHECK_Q(pc, questIES.ClassName);

            local icon = CreateIcon(slot)
            local questIES = GetClassByType("QuestProgressCheck", clsid);
            local targetMapName = GET_QUEST_LOCATION(questIES)
            local zoneName = GetClassString('Map', targetMapName, 'Name')
            if result == "COMPLETE" then
                icon:SetColorTone('FFFF0000')
            end
            icon:SetImage("questinfo_return");
            SET_SLOT_COUNT_TEXT(slot, zoneName, '{s10}{ol}{b}', ui.LEFT, ui.BOTTOM, 0, 0)

        elseif category == 'Emoticon' then

            local icon = CreateIcon(slot)

            icon:SetImage(iesid)
            icon:SetColorTone('FFFFFFFF')

            slot:ClearText()

        elseif category == 'None' then

            CLEAR_SLOT_ITEM_INFO(slot)
            slot:ClearText()
        end

    end

    return 1
end

function sub_slotset_pop(frame, ctrl, str, num)

    local index = string.gsub(ctrl:GetName(), "slot", "")

    local frame_name = frame:GetTopParentFrame():GetName()

    if str == "shared" then

        if g.settings[frame_name] and g.settings[frame_name][index] then

            g.settings[frame_name][index].clsid = 0
            g.settings[frame_name][index].category = ""
            g.settings[frame_name][index].iesid = ""
            sub_slotset_save_settings()
            CLEAR_SLOT_ITEM_INFO(ctrl)

        end
    elseif str == "character" then
        if g.personal[frame_name] and g.personal[frame_name][index] then

            g.personal[frame_name][index].clsid = 0
            g.personal[frame_name][index].category = ""
            g.personal[frame_name][index].iesid = ""
            sub_slotset_personal_save_settings()
            CLEAR_SLOT_ITEM_INFO(ctrl)

        end
    end
end

function sub_slotset_drop(frame, slot, str, num)

    local liftIcon = ui.GetLiftIcon()
    local poseid = liftIcon:GetUserValue('POSEID')

    local info = liftIcon:GetInfo()
    local clsid = info.type
    local iesid = info:GetIESID()
    local category = info:GetCategory()
    local index = string.gsub(slot:GetName(), "slot", "")
    local image = info:GetImageName()

    if g.emoticon_category ~= nil then
        category = g.emoticon_category
        clsid = g.emoticon_clsid
        iesid = g.emoticon_iesid
        g.emoticon_clsid = nil
        g.emoticon_category = nil
        g.emoticon_iesid = nil
    end

    if image == "questinfo_return" then
        category = g.quest_category
        clsid = g.quest_clsid
        iesid = ""
        g.quest_category = nil
        g.quest_clsid = nil
    end

    if poseid ~= "None" then
        category = 'Pose'
        clsid = poseid
        iesid = ""
    end

    local frame = slot:GetTopParentFrame()
    local frameName = slot:GetTopParentFrame():GetName()

    if str == "shared" then

        g.settings[frameName][tostring(index)] = {
            category = category,
            clsid = clsid,
            iesid = iesid
        }

        sub_slotset_save_settings()
    elseif str == "character" then

        g.personal[frameName][tostring(index)] = {
            category = category,
            clsid = clsid,
            iesid = iesid
        }

        sub_slotset_personal_save_settings()
    end

    sub_slotset_slotset_update(frame)

end

function sub_slotset_make_frame(frame)
    frame:Resize(225, 200)
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:SetLayerLevel(90)

    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 35, 0, frame:GetWidth() - 35, frame:GetHeight())
    AUTO_CAST(gbox)
    gbox:SetSkinName("test_frame_midle_light")

    local title = gbox:CreateOrGetControl("richtext", "title", 10, 10, 80, 25)
    AUTO_CAST(title)
    title:SetText("{ol}{s18}Sub Slotset")

    local column = gbox:CreateOrGetControl("richtext", "column", 10, 40, 80, 25)
    AUTO_CAST(column)
    column:SetText("{ol}{s16}Column")

    local column_edit = gbox:CreateOrGetControl('edit', 'column_edit', 10, 65, 80, 25)
    AUTO_CAST(column_edit)
    column_edit:SetFontName('white_16_ol')
    column_edit:SetSkinName('test_weight_skin')
    column_edit:SetTextAlign('center', 'center')
    column_edit:SetEventScript(ui.ENTERKEY, "sub_slotset_set_edit");
    column_edit:SetText(g.column or tonumber(3))

    local row = gbox:CreateOrGetControl("richtext", "row", 100, 40, 80, 25)
    AUTO_CAST(row)
    row:SetText("{ol}{s16}Row")

    local row_edit = gbox:CreateOrGetControl('edit', 'row_edit', 100, 65, 80, 25)
    AUTO_CAST(row_edit)
    row_edit:SetFontName('white_16_ol')
    row_edit:SetSkinName('test_weight_skin')
    row_edit:SetTextAlign('center', 'center')
    row_edit:SetEventScript(ui.ENTERKEY, "sub_slotset_set_edit");
    row_edit:SetText(g.row or tonumber(3))

    local size = gbox:CreateOrGetControl("richtext", "size", 10, 100, 80, 25)
    AUTO_CAST(size)
    size:SetText("{ol}{s16}Slot Size")

    local size_edit = gbox:CreateOrGetControl('edit', 'size_edit', 10, 125, 80, 25)
    AUTO_CAST(size_edit)
    size_edit:SetFontName('white_16_ol')
    size_edit:SetSkinName('test_weight_skin')
    size_edit:SetTextAlign('center', 'center')
    size_edit:SetEventScript(ui.ENTERKEY, "sub_slotset_set_edit");
    size_edit:SetText(g.size or tonumber(48))

    local layer = gbox:CreateOrGetControl("richtext", "layer", 100, 100, 80, 25)
    AUTO_CAST(layer)
    layer:SetText("{ol}{s16}Layer")

    local layer_edit = gbox:CreateOrGetControl('edit', 'layer_edit', 100, 125, 80, 25)
    AUTO_CAST(layer_edit)
    layer_edit:SetFontName('white_16_ol')
    layer_edit:SetSkinName('test_weight_skin')
    layer_edit:SetTextAlign('center', 'center')
    layer_edit:SetEventScript(ui.ENTERKEY, "sub_slotset_set_edit");
    layer_edit:SetText(g.layer or tonumber(90))

    local make = gbox:CreateOrGetControl('button', 'make', 10, 160, 80, 30)
    AUTO_CAST(make)
    make:SetSkinName("test_red_button")
    make:SetText("{ol}{s16}Make")
    make:SetEventScript(ui.LBUTTONUP, "sub_slotset_make_context");

    local cancel = gbox:CreateOrGetControl('button', 'cancel', 100, 160, 80, 30)
    AUTO_CAST(cancel)
    cancel:SetSkinName("test_gray_button")
    cancel:SetText("{ol}{s16}Cancel")
    cancel:SetEventScript(ui.LBUTTONUP, "sub_slotset_frame_init");

end

function sub_slotset_set_edit(frame, ctrl, str, num)
    local ctrl_name = ctrl:GetName()
    local ctrl_type = type(tonumber(ctrl:GetText()))
    if ctrl_type ~= "number" then
        ui.SysMsg("Numeric input")
        return
    end
    if tonumber(ctrl:GetText()) > 10 and ctrl_name ~= "size_edit" and ctrl_name ~= "layer_edit" then
        ui.SysMsg("Enter less than 10")
        return
    end
    if ctrl_name == "column_edit" then
        ui.SysMsg("Set " .. tonumber(ctrl:GetText()))
        g.column = tonumber(ctrl:GetText())
        return
    elseif ctrl_name == "row_edit" then
        ui.SysMsg("Set " .. tonumber(ctrl:GetText()))
        g.row = tonumber(ctrl:GetText())
        return
    elseif ctrl_name == "layer_edit" then
        ui.SysMsg("Set " .. tonumber(ctrl:GetText()))
        g.layer = tonumber(ctrl:GetText())
        return
    end
    local row_edit = GET_CHILD_RECURSIVELY(frame, "row_edit")
    local row = tonumber(row_edit:GetText())
    if row ~= nil then
        local mapFrame = ui.GetFrame("map");
        local h = mapFrame:GetHeight()
        local limit_size = math.floor(tonumber(h) / row)

        if tonumber(ctrl:GetText()) <= limit_size and ctrl_name == "size_edit" then
            ui.SysMsg("Set " .. tonumber(ctrl:GetText()))
            g.size = tonumber(ctrl:GetText())
            return
        elseif tonumber(ctrl:GetText()) > limit_size and ctrl_name == "size_edit" then
            ui.SysMsg(string.format("Input is limited to %d or less.", limit_size))
            ctrl:SetText(48)
            return
        end
    end

end

function sub_slotset_make_context(frame, ctrl, str, num)

    local context = ui.CreateContextMenu("make_context", "Shared or Character", 0, 0, 100, 100);
    ui.AddContextMenuItem(context, " ", "None");
    local scp = string.format("sub_slotset_make_slotset_frame('%s')", "shared")
    ui.AddContextMenuItem(context, "Make team shared slotset", scp);
    scp = string.format("sub_slotset_make_slotset_frame('%s')", "character")
    ui.AddContextMenuItem(context, "Make character slotset", scp);
    ui.OpenContextMenu(context);

end

function sub_slotset_make_slotset_frame(str)
    sub_slotset_frame_init()

    local client_Width = ui.GetClientInitialWidth() -- 1920
    local client_Height = ui.GetClientInitialHeight() -- 1080

    g.settings.index = g.settings.index + 1
    local isnew = true
    sub_slotset_save_settings()
    sub_slotset_slotset_frame_init(str, isnew)

end

function sub_slotset_newframe_rbutton(frame, ctrl, str, num)
    local belong = frame:GetUserValue("BELONG")

    local table = {}

    local context = ui.CreateContextMenu("slotset_context", "ETC Setting", 0, 0, 100, 100);
    ui.AddContextMenuItem(context, " ", "None");
    local scp = string.format("sub_slotset_newframe_remove_msg('%s')", tostring(frame:GetName()))
    ui.AddContextMenuItem(context, "Remove the slotset frame", scp);
    scp = string.format("sub_slotset_lock_slotset_frame('%s')", tostring(frame:GetName()))
    ui.AddContextMenuItem(context, "Lock the slotset frame", scp);
    if belong == "shared" then
        table = g.settings
    elseif belong == "character" then
        table = g.personal
    end
    if not table[frame:GetName()]["etc"].lock then
        scp = string.format("sub_slotset_resetting('%s')", tostring(frame:GetName()))
        ui.AddContextMenuItem(context, "Slot set re-setting", scp);
    else
        ui.AddContextMenuItem(context, "Unlock the frame for re-setting", "None");
    end
    ui.AddContextMenuItem(context, "  ", "None");
    ui.OpenContextMenu(context);

end

function sub_slotset_newframe_remove_msg(frame_name)
    local scp = string.format("sub_slotset_newframe_remove('%s')", frame_name)
    ui.MsgBox("remove this frame?", scp, "None")
end

function sub_slotset_newframe_remove(frame_name)

    local frame = ui.GetFrame(frame_name)
    local belong = frame:GetUserValue("BELONG")

    if belong == "shared" then
        if g.settings[frame_name] then
            g.settings[frame:GetName()] = nil
        end
        sub_slotset_save_settings()
    elseif belong == "character" then
        if g.personal[frame_name] then
            g.personal[frame:GetName()] = nil

        end

        sub_slotset_personal_save_settings()
    end

    ui.DestroyFrame(frame_name);
end

function sub_slotset_lock_slotset_frame(frame_name)
    local frame = ui.GetFrame(frame_name)
    local belong = frame:GetUserValue("BELONG")
    if belong == "shared" then
        if g.settings[frame_name] then
            if g.settings[frame:GetName()]["etc"].lock == nil then
                g.settings[frame:GetName()]["etc"].lock = true
            elseif g.settings[frame:GetName()]["etc"].lock == true then
                g.settings[frame:GetName()]["etc"].lock = false
            elseif g.settings[frame:GetName()]["etc"].lock == false then
                g.settings[frame:GetName()]["etc"].lock = true
            end
        end
        sub_slotset_save_settings()
        sub_slotset_slotset_init(frame)
    elseif belong == "character" then
        if g.personal[frame_name] then
            if g.personal[frame_name]["etc"].lock == nil then
                g.personal[frame_name]["etc"].lock = true
            elseif g.personal[frame_name]["etc"].lock == true then
                g.personal[frame_name]["etc"].lock = false
            elseif g.personal[frame_name]["etc"].lock == false then
                g.personal[frame_name]["etc"].lock = true
            end
        end

        sub_slotset_personal_save_settings()
        sub_slotset_slotset_init(frame)
    end

end

function sub_slotset_resetting(frame_name)

    local frame = ui.GetFrame(frame_name)
    local belong = frame:GetUserValue("BELONG")

    local table = {}
    if belong == "shared" then
        table = g.settings[frame_name]

    elseif belong == "character" then
        table = g.personal[frame_name]

    end

    local column = 0
    local row = 0
    local size = 0
    local layer = 0

    for key, value in pairs(table) do
        if key == "etc" then

            column = value.column
            row = value.row
            size = value.size
            layer = value.layer or tonumber(90)

        end
    end

    local resetting_frame = ui.CreateNewFrame("notice_on_pc", "resetting" .. frame_name, 0, 0, 0, 0)

    AUTO_CAST(resetting_frame)

    resetting_frame:SetLayerLevel(90)

    resetting_frame:Resize(225, 200)
    resetting_frame:SetSkinName("None")
    resetting_frame:SetTitleBarSkin("None")
    local client_Width = ui.GetClientInitialWidth() -- 1920
    local client_Height = ui.GetClientInitialHeight() -- 1080
    local X = client_Width / 2

    local Y = client_Height / 2
    resetting_frame:SetPos(X, Y)

    resetting_frame:ShowWindow(1)

    local gbox = resetting_frame:CreateOrGetControl("groupbox", "gbox", 35, 0, resetting_frame:GetWidth() - 35,
        resetting_frame:GetHeight())
    AUTO_CAST(gbox)
    gbox:SetSkinName("test_frame_midle_light")

    local title = gbox:CreateOrGetControl("richtext", "title", 10, 10, 80, 25)
    AUTO_CAST(title)
    title:SetText("{ol}{s18}Re Setting")

    local column_text = gbox:CreateOrGetControl("richtext", "column_text", 10, 40, 80, 25)
    AUTO_CAST(column_text)
    column_text:SetText("{ol}{s16}Column")

    local column_edit = gbox:CreateOrGetControl('edit', 'column_edit', 10, 65, 80, 25)
    AUTO_CAST(column_edit)
    column_edit:SetFontName('white_16_ol')
    column_edit:SetSkinName('test_weight_skin')
    column_edit:SetTextAlign('center', 'center')
    column_edit:SetEventScript(ui.ENTERKEY, "sub_slotset_reset_edit");
    column_edit:SetEventScriptArgString(ui.ENTERKEY, belong);
    column_edit:SetEventScriptArgNumber(ui.ENTERKEY, column);
    column_edit:SetText(column)

    local row_text = gbox:CreateOrGetControl("richtext", "row_text", 100, 40, 80, 25)
    AUTO_CAST(row_text)
    row_text:SetText("{ol}{s16}Row")

    local row_edit = gbox:CreateOrGetControl('edit', 'row_edit', 100, 65, 80, 25)
    AUTO_CAST(row_edit)
    row_edit:SetFontName('white_16_ol')
    row_edit:SetSkinName('test_weight_skin')
    row_edit:SetTextAlign('center', 'center')
    row_edit:SetEventScript(ui.ENTERKEY, "sub_slotset_reset_edit");
    row_edit:SetEventScriptArgString(ui.ENTERKEY, belong);
    row_edit:SetEventScriptArgNumber(ui.ENTERKEY, row);
    row_edit:SetText(row)

    local size_text = gbox:CreateOrGetControl("richtext", "size_text", 10, 100, 80, 25)
    AUTO_CAST(size_text)
    size_text:SetText("{ol}{s16}Slot Size")

    local size_edit = gbox:CreateOrGetControl('edit', 'size_edit', 10, 125, 80, 25)
    AUTO_CAST(size_edit)
    size_edit:SetFontName('white_16_ol')
    size_edit:SetSkinName('test_weight_skin')
    size_edit:SetTextAlign('center', 'center')
    size_edit:SetEventScript(ui.ENTERKEY, "sub_slotset_reset_edit");
    size_edit:SetEventScriptArgString(ui.ENTERKEY, belong);
    size_edit:SetEventScriptArgNumber(ui.ENTERKEY, size);
    size_edit:SetText(size)
    size_edit:SetTextTooltip("{ol}Default value is 48")

    local layer_text = gbox:CreateOrGetControl("richtext", "layer_text", 100, 100, 80, 25)
    AUTO_CAST(layer_text)
    layer_text:SetText("{ol}{s16}Layer")

    local layer_edit = gbox:CreateOrGetControl('edit', 'layer_edit', 100, 125, 80, 25)
    AUTO_CAST(layer_edit)
    layer_edit:SetFontName('white_16_ol')
    layer_edit:SetSkinName('test_weight_skin')
    layer_edit:SetTextAlign('center', 'center')
    layer_edit:SetEventScript(ui.ENTERKEY, "sub_slotset_reset_edit");
    layer_edit:SetEventScriptArgString(ui.ENTERKEY, belong);
    layer_edit:SetEventScriptArgNumber(ui.ENTERKEY, layer);
    layer_edit:SetText(layer)
    layer_edit:SetTextTooltip("{ol}Default value is 90")

    local change = gbox:CreateOrGetControl('button', 'change', 10, 160, 80, 30)
    AUTO_CAST(change)
    change:SetSkinName("test_red_button")
    change:SetText("{ol}{s16}Change")
    change:SetEventScript(ui.LBUTTONUP, "sub_slotset_change_belong");
    change:SetEventScriptArgString(ui.LBUTTONUP, belong);
    change:SetTextTooltip("{ol}Change for team or character per")

    local close = gbox:CreateOrGetControl('button', 'close', 100, 160, 80, 30)
    AUTO_CAST(close)
    close:SetSkinName("test_gray_button")
    close:SetText("{ol}{s16}Close")
    close:SetEventScript(ui.LBUTTONUP, "sub_slotset_frame_destroy")
    close:SetEventScriptArgString(ui.LBUTTONUP, resetting_frame:GetName())

end

function sub_slotset_reset_edit(frame, ctrl, str, num)
    local ctrl_name = ctrl:GetName()
    local ctrl_type = type(tonumber(ctrl:GetText()))
    if ctrl_type ~= "number" then
        ui.SysMsg("Numeric input")
        return
    end
    if tonumber(ctrl:GetText()) > 10 and ctrl_name ~= "size_edit" and ctrl_name ~= "layer_edit" then
        ui.SysMsg("Enter less than 10")
        return
    end
    local frame = ctrl:GetTopParentFrame()
    local frame_name = string.gsub(frame:GetName(), "resetting", "")
    local belong = str

    local table = {}
    if belong == "shared" then
        table = g.settings[frame_name]["etc"]

    elseif belong == "character" then
        table = g.personal[frame_name]["etc"]

    end

    local row_edit = GET_CHILD_RECURSIVELY(frame, "row_edit")
    local row = tonumber(row_edit:GetText())
    if row ~= nil and ctrl_name == "size_edit" then
        local mapFrame = ui.GetFrame("map");
        local h = mapFrame:GetHeight()
        local limit_size = math.floor(tonumber(h) / row)

        if tonumber(ctrl:GetText()) <= limit_size then
            table.size = tonumber(ctrl:GetText())

        elseif tonumber(ctrl:GetText()) > limit_size then
            ui.SysMsg(string.format("Input is limited to %d or less.", limit_size))
            ctrl:SetText(num)
            return
        end
    end
    if ctrl_name == "column_edit" then
        table.column = tonumber(ctrl:GetText())

    elseif ctrl_name == "row_edit" then
        table.row = tonumber(ctrl:GetText())
    elseif ctrl_name == "layer_edit" then
        table.layer = tonumber(ctrl:GetText())
    end

    if belong == "shared" then
        g.settings[frame_name]["etc"] = table
        sub_slotset_save_settings()
    elseif belong == "character" then
        g.personal[frame_name]["etc"] = table
        sub_slotset_personal_save_settings()
    end

    local slot_frame = ui.GetFrame(frame_name)
    slot_frame:RemoveAllChild()
    sub_slotset_slotset_frame_init(belong, false)
end

function sub_slotset_change_belong(frame, ctrl, belong, num)
    local frame = ctrl:GetTopParentFrame()

    local frame_name = string.gsub(frame:GetName(), "resetting", "")

    local table = {}
    if belong == "shared" then
        if g.settings[frame_name] then
            table = g.settings[frame_name]
            g.personal[frame_name] = table
            g.settings[frame_name] = nil
            belong = "character"
        end
    elseif belong == "character" then
        if g.personal[frame_name] then
            table = g.personal[frame_name]
            g.settings[frame_name] = table
            g.personal[frame_name] = nil
            belong = "shared"
        end
    end
    sub_slotset_save_settings()
    sub_slotset_personal_save_settings()

    local slot_frame = ui.GetFrame(frame_name)
    slot_frame:RemoveAllChild()
    sub_slotset_slotset_frame_init(belong, false)

    local resetting_frame_name = frame:GetName()

    ui.DestroyFrame(resetting_frame_name)
end

function sub_slotset_frame_destroy(frame, ctrl, frame_name, num)
    ui.DestroyFrame(frame_name)
end

function sub_slotset_slot_rbutton(frame, slot, category, clsid)

    if category == 'Item' then
        SLOT_ITEMUSE_BY_TYPE(frame, slot, category, clsid)

    elseif category == 'Pose' then
        control.Pose(GetClassByType('Pose', clsid).ClassName)

    elseif category == 'Skill' or category == 'Ability' then
        local icon = slot:GetIcon()
        if not icon then
            return
        end
        ICON_USE(icon)
    elseif category == 'Quest' then
        local isMoveMap = 0;
        local mapClassName = session.GetMapName();
        local questIES = GetClassByType("QuestProgressCheck", clsid);
        local pc = GetMyPCObject();
        local result = SCR_QUEST_CHECK_Q(pc, questIES.ClassName);
        local questnpc_state = GET_QUEST_NPC_STATE(questIES, result, pc);

        if mapClassName ~= questIES[questnpc_state .. 'Map'] then
            isMoveMap = 1;
        end
        local cheat = string.format("/retquest %d", clsid);

        movie.QuestWarp(session.GetMyHandle(), cheat, isMoveMap);
        packet.ClientDirect("QuestWarp");

    elseif category == 'Emoticon' then

        local icongroup = ""
        if clsid == 98 then
            icongroup = 'Normal'
        elseif clsid == 99 then
            icongroup = 'Motion'
        end
        local emo_frame = ui.GetFrame("chat_emoticon")
        local chatFrame = ui.GetFrame('chat');
        local edit = chatFrame:GetChild('mainchat');
        AUTO_CAST(edit)
        chatFrame:ShowWindow(1)
        edit:ShowWindow(1)

        if icongroup == 'Motion' then

            local icon = slot:GetIcon()
            if icon ~= nil then
                local imageName = icon:GetInfo():GetImageName()

                if imageName ~= "" then
                    if string.find(imageName, "motion_") == nil then
                        imageName = "motion_" .. imageName
                    end
                    local spinetag = string.format("{spine %s %d %d}{/}", imageName, 120, 120)
                    SET_CHAT_TEXT_TO_CHATFRAME(spinetag)
                    edit:RunEnterKeyScript();
                    ui.ProcessReturnKey()

                end
            end

        elseif icongroup == 'Normal' then
            local icon = slot:GetIcon()
            if icon ~= nil then
                local imageName = icon:GetInfo():GetImageName()

                if imageName ~= "" then
                    local spinetag = string.format("{spine %s %d %d}{/}", imageName, 120, 120, " ")
                    local imgheight = 30
                    local imgtag = string.format("{img %s %d %d}{/}", imageName, imgheight, imgheight)

                    local left = edit:GetCursurLeftText()
                    local right = edit:GetCursurRightText()
                    -- 이 함수 들어오는 시점에서 이미 스페이스키를 클릭한 상태이므로 추가해줌
                    right = right .. " "
                    local resultText = string.format("%s%s%s", left, imgtag, right)
                    SET_CHAT_TEXT_TO_CHATFRAME(resultText)
                    edit:RunEnterKeyScript();
                    ui.ProcessReturnKey()
                end
            end

        end

    end
end

function sub_slotset_EMO_OPEN(frame, msg)
    local button = acutil.getEventArgs(msg)

    sub_slotset_EMO_OPEN_(button)

end

function sub_slotset_EMO_OPEN_(button)

    local frame = ui.GetFrame("chat_emoticon")
    local group_name = frame:GetUserValue("EMOTICON_GROUP")
    if group_name == "None" then
        group_name = "Normal"
    end

    local emoticons = GET_CHILD_RECURSIVELY(frame, "emoticons")
    local slotCount = emoticons:GetSlotCount();
    local count = 0
    for i = 1, slotCount do
        local slot = GET_CHILD_RECURSIVELY(emoticons, "slot" .. i)
        local icon = slot:GetIcon()
        if icon ~= nil then
            count = count + 1
        end
    end

    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox")
    gbox:RemoveAllChild()
    local emoticons = gbox:CreateOrGetControl('slotset', 'emoticons', 0, 0, 420, 0)
    AUTO_CAST(emoticons);
    emoticons:SetSlotSize(42, 42) -- スロットの大きさ
    emoticons:EnablePop(1)
    emoticons:EnableDrag(1)
    emoticons:EnableDrop(0)
    emoticons:EnableHitTest(1);
    emoticons:SetColRow(10, math.ceil(count / 10))
    emoticons:SetSpc(0, 0)
    emoticons:SetSkinName('invenslot')
    emoticons:CreateSlots()

    for i = 0, count - 1 do
        local slot = emoticons:GetSlotByIndex(i)
        AUTO_CAST(slot)
        local icon = CreateIcon(slot)
        slot:SetEventScript(ui.LBUTTONDOWN, "CHAT_EMOTICON_SELECT")

        slot:SetEventScript(ui.POP, "sub_slotset_emoticon_pop")
        slot:SetEventScriptArgString(ui.POP, group_name)

    end

    CHAT_EMOTICON_MAKELIST(frame)

end

function sub_slotset_emoticon_pop(frame, ctrl, str, num)
    local liftIcon = ui.GetLiftIcon();
    local iconInfo = liftIcon:GetInfo();
    local image = iconInfo:GetImageName()
    local topframe = liftIcon:GetTopParentFrame()

    local group_name = str

    g.emoticon_clsid = group_name
    g.emoticon_category = "Emoticon"
    g.emoticon_iesid = image

    local frame = ui.GetFrame("sub_slotset")
    frame:RunUpdateScript("sub_slotset_emoticon_clear", 15)

end

function sub_slotset_emoticon_clear(frame)

    g.emoticon_clsid = nil
    g.emoticon_category = nil
    g.emoticon_iesid = nil
end

function sub_slotset_MAKE_QUEST_INFO_TYPE_ICON(frame, msg)
    local ctrlset, x, y, questIES, result = acutil.getEventArgs(msg)

    local picture = GET_CHILD_RECURSIVELY(ctrlset, "statepicture")
    local image = picture:GetImageName()

    if image == "questinfo_return" then

        local slot = ctrlset:CreateOrGetControl("slot", "slot" .. y, ctrlset:GetWidth() - 20, y + 18, 20, 20)
        AUTO_CAST(slot)
        slot:EnablePop(1)
        slot:EnableDrop(0)
        slot:SetEventScript(ui.POP, "sub_slotset_questslot_pop")
        slot:SetEventScriptArgNumber(ui.POP, questIES.ClassID)
        slot:SetEventScriptArgString(ui.POP, "Quest")

        local icon = CreateIcon(slot);
        icon:SetImage("questinfo_return");

        icon:SetTextTooltip("Sub Slotset{nl}for Registration")
    end

end

function sub_slotset_questslot_pop(frame, ctrl, str, num)
    g.quest_clsid = num
    g.quest_category = str

end
