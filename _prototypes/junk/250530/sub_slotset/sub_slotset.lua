-- v1.0.1 レイヤー設定追加。再設定機能追加。エモを右クリックでチャット。
-- v1.0.2 増設したスロットに上手くハマらなかったの修正。
-- v1.0.3 インベントリアイテムの数量が0になった時にバグってたの修正。クエストワープの設定方法追加
-- v1.0.4 エモーションの使用出来ないものを分かるようにした。上手いことハマらないエモーションあったのを直した。
-- v1.0.5 ウルトラワイド対応。スロット作るボタンも動かせるように
-- v1.0.6 アドオンボタン修正。使えるエモーション判定部分修正。
local addon_name = "SUB_SLOTSET"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.6"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

local json = require("json")

g.settings_base_FileLoc = string.format('../addons/%s/settings.json', addon_name_lower)
g.active_id = session.loginInfo.GetAID()
g.settingsFileLoc = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)

function g.mkdir_new_folder()
    local folder_path = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    local file = io.open(file_path, "r")
    if not file then
        os.execute('mkdir "' .. folder_path .. '"')
        file = io.open(file_path, "w")
        if file then
            file:write("A new file has been created")
            file:close()
        end
    else
        file:close()
    end

    local folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    local file = io.open(file_path, "r")
    if not file then
        os.execute('mkdir "' .. folder .. '"')
        file = io.open(file_path, "w")
        if file then
            file:write("A new file has been created")
            file:close()
        end
    else
        file:close()
    end
end
g.mkdir_new_folder()

local file = io.open(g.settingsFileLoc, "r")
if not file then
    file = io.open(g.settings_base_FileLoc, "r")
    if file then
        local base_settings = file:read("a")
        file:close()

        file = io.open(g.settingsFileLoc, "w")
        if file then
            file:write(base_settings)
            file:close()
        end
    end
end

function g.setup_hook_and_event(my_addon, origin_func_name, my_func_name, bool)

    g.FUNCS = g.FUNCS or {}
    if not g.FUNCS[origin_func_name] then
        g.FUNCS[origin_func_name] = _G[origin_func_name]
    end

    local origin_func = g.FUNCS[origin_func_name]

    local function hooked_function(...)

        local original_results

        if bool == true then
            original_results = {origin_func(...)}
        end

        g.ARGS = g.ARGS or {}
        g.ARGS[origin_func_name] = {...}
        imcAddOn.BroadMsg(origin_func_name)

        if original_results then
            return table.unpack(original_results)
        else
            return
        end
    end

    _G[origin_func_name] = hooked_function

    if not g.REGISTER[origin_func_name .. my_func_name] then -- g.REGISTERはON_INIT内で都度初期化
        g.REGISTER[origin_func_name .. my_func_name] = true
        my_addon:RegisterMsg(origin_func_name, my_func_name)
    end
end

function g.get_event_args(origin_func_name)
    local args = g.ARGS[origin_func_name]
    if args then
        return table.unpack(args)
    end
    return nil
end

function g.save_json(path, tbl)
    local file = io.open(path, "w")
    if file then
        local str = json.encode(tbl)
        file:write(str)
        file:close()
    end
end

function g.load_json(path)

    local file = io.open(path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        local table = json.decode(content)
        return table
    else
        return nil
    end
end

function sub_slotset_load_settings()

    local settings = g.load_json(g.settingsFileLoc)

    if not settings then
        settings = {
            index = 0
        }
    end
    g.settings = settings

    g.save_json(g.settingsFileLoc, g.settings)

    g.personalFileLoc = string.format('../addons/%s/%s.json', addon_name_lower, g.cid)

    local personal = g.load_json(g.personalFileLoc)

    if not personal or not next(settings) then
        personal = {}
    end

    g.personal = personal
    g.save_json(g.personalFileLoc, g.personal)

end

function sub_slotset_GAME_START_3SEC(frame, msg)

    sub_slotset_slotset_frame_init("character")
    sub_slotset_slotset_frame_init("shared")
end

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

function SUB_SLOTSET_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    g.cid = session.GetMySession():GetCID()

    g.REGISTER = {}

    if not g.settings then
        sub_slotset_load_settings()
    end
    addon:RegisterMsg("GAME_START_3SEC", "sub_slotset_GAME_START_3SEC")

    g.setup_hook_and_event(addon, "SET_QUEST_CTRL_TEXT", "sub_slotset_SET_QUEST_CTRL_TEXT", false)
    g.setup_hook_and_event(addon, "MAKE_QUEST_INFO_TYPE_ICON", "sub_slotset_MAKE_QUEST_INFO_TYPE_ICON", true)
    g.setup_hook_and_event(addon, "EMO_OPEN", "sub_slotset_EMO_OPEN", true)
    g.setup_hook_and_event(addon, "TPITEM_CLOSE", "sub_slotset_TPITEM_CLOSE", true)

    local menu_data = {
        name = "Sub Slot Set",
        icon = "icon_item_gold",
        func = "sub_slotset_make_frame",
        image = "{img btn_worldmap_zoomin 30 30}"
    }
    if g.get_map_type() == "City" then
        _G["norisan"]["MENU"][addon_name] = menu_data
    else
        _G["norisan"]["MENU"][addon_name] = nil
    end
    if not _G["norisan"]["MENU"][addon_name_lower] or _G["norisan"]["MENU"].frame_name == addon_name_lower then
        _G["norisan"]["MENU"].frame_name = addon_name_lower
        addon:RegisterMsg("GAME_START", "norisan_menu_create_frame")
    end
end

function sub_slotset_TPITEM_CLOSE()

    local index = g.settings["index"]
    local sources = {g.settings, g.personal}

    for i = 0, index do
        for _, source in pairs(sources) do
            local sub_slot_key = "sub_slotset_" .. tostring(i)
            local sub_slot = source[sub_slot_key]
            if sub_slot then
                local frame = ui.GetFrame(sub_slot_key)
                frame:ShowWindow(1)
            end
        end
    end
end

function sub_slotset_SET_QUEST_CTRL_TEXT(my_frame, my_msg)
    local ctrl, questIES = g.get_event_args(my_msg)

    local Quest_Ctrl = tolua.cast(ctrl, "ui::CControlSet");
    local nametxt = GET_CHILD(Quest_Ctrl, "name", "ui::CRichText");
    local leveltxt = GET_CHILD(Quest_Ctrl, "level", "ui::CRichText");

    local textFont = ""
    local textColor = ""
    if questIES.QuestMode == "MAIN" then
        textFont = Quest_Ctrl:GetUserConfig("MAIN_FONT")
        textColor = Quest_Ctrl:GetUserConfig("MAIN_COLOR")
    elseif questIES.QuestMode == "SUB" then
        textFont = Quest_Ctrl:GetUserConfig("SUB_FONT")
        textColor = Quest_Ctrl:GetUserConfig("SUB_COLOR")
    elseif questIES.QuestMode == "REPEAT" then
        textFont = Quest_Ctrl:GetUserConfig("REPEAT_FONT")
        textColor = Quest_Ctrl:GetUserConfig("REPEAT_COLOR")
    elseif questIES.QuestMode == "PARTY" then
        textFont = Quest_Ctrl:GetUserConfig("PARTY_FONT")
        textColor = Quest_Ctrl:GetUserConfig("PARTY_COLOR")
    elseif questIES.QuestMode == "KEYITEM" then
        textFont = Quest_Ctrl:GetUserConfig("KEYITEM_FONT")
        textColor = Quest_Ctrl:GetUserConfig("KEYITEM_COLOR")
    end

    -- 퀘스트 레벨과 이름의 폰트 및 색상 지정.
    nametxt:SetText(textFont .. textColor .. questIES.Name)
    leveltxt:SetText(textColor .. textColor .. "Lv " .. questIES.Level)

    local rect = leveltxt:GetMargin();
    leveltxt:SetMargin(rect.left - 10, rect.top, rect.right, rect.bottom);

    local questMarkPic = GET_CHILD(Quest_Ctrl, "questmark", "ui::CPicture");
    local image_name = questMarkPic:GetImageName();
    local result = SCR_QUEST_CHECK_C(GetMyPCObject(), questIES.ClassName);
    if (result == 'POSSIBLE' and questIES.POSSI_WARP == 'YES') or (result == 'PROGRESS' and questIES.PROG_WARP == 'YES') or
        (result == 'SUCCESS' and questIES.SUCC_WARP == 'YES') then
        local slot = Quest_Ctrl:CreateOrGetControl("slot", "slot", 78, 5, 20, 20)
        AUTO_CAST(slot)
        slot:EnablePop(1)
        slot:EnableDrop(0)
        slot:SetEventScript(ui.POP, "sub_slotset_questslot_pop")
        slot:SetEventScriptArgNumber(ui.POP, questIES.ClassID)
        slot:SetEventScriptArgString(ui.POP, "Quest")

        local icon = CreateIcon(slot);
        icon:SetImage("questinfo_return");
        icon:SetTextTooltip("{ol}Sub Slotset{nl}LeftClick:for Registration")
    end
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

    local map_frame = ui.GetFrame("map")
    local width = map_frame:GetWidth()

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
                    if width <= 1920 and X > 1920 then
                        X = v2.X / 21 * 16
                    end

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
        g.save_json(g.settingsFileLoc, g.settings)

    elseif belong == "character" then
        for key, value in pairs(g.personal[frame:GetName()]) do

            if key == "etc" then
                for k2, v2 in pairs(value) do

                    g.personal[frame:GetName()]["etc"].X = frame:GetX()
                    g.personal[frame:GetName()]["etc"].Y = frame:GetY()

                end
            end

        end
        g.save_json(g.personalFileLoc, g.personal)
    end

end

function sub_slotset_slotset_init(frame)

    g.emo_check = 0

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
    frame:EnableHittestFrame(1)

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

            g.save_json(g.settingsFileLoc, g.settings)

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

            g.save_json(g.personalFileLoc, g.personal)

        end
    end
    frame:ShowWindow(1)
    frame:SetUserValue("ISNEW", "false")
    frame:RunUpdateScript("sub_slotset_slotset_update", 0.3)

end

function sub_slotset_SET_SLOT_COUNT_TEXT(slot, cnt, font, hor, ver, stateX, stateY)
    if font == nil then
        font = '{s15}{ol}{b}';
    end

    if hor == nil then
        hor = ui.RIGHT;
    end

    if ver == nil then
        ver = ui.BOTTOM;
    end

    if stateX == nil then
        stateX = -2;
    end

    if stateY == nil then
        stateY = 1;
    end

    slot:SetText(font .. cnt, 'count', hor, ver, stateX, stateY);

end

function sub_slotset_SET_SLOT_ITEM_TEXT(slot, invItem, obj)
    if obj.MaxStack > 1 then
        sub_slotset_SET_SLOT_COUNT_TEXT(slot, invItem.count);
        return;
    end

    local lv = TryGetProp(obj, "Level");
    if lv ~= nil and lv > 1 then
        slot:SetFrontImage('enchantlevel_indi_icon');
        slot:SetText('{s20}{ol}{#FFFFFF}{b}' .. lv, 'count', ui.LEFT, ui.TOP, 8, 2);
        return;
    end
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
            if g.settings[frame_name][tostring(i)] ~= nil then
                clsid = g.settings[frame_name][tostring(i)].clsid
                category = g.settings[frame_name][tostring(i)].category
                iesid = g.settings[frame_name][tostring(i)].iesid
            else
                g.settings[frame_name][tostring(i)] = {}
                g.save_json(g.settingsFileLoc, g.settings)
            end
        elseif belong == "character" then
            if g.personal[frame_name][tostring(i)] ~= nil then
                clsid = g.personal[frame_name][tostring(i)].clsid
                category = g.personal[frame_name][tostring(i)].category
                iesid = g.personal[frame_name][tostring(i)].iesid
            else
                g.personal[frame_name][tostring(i)] = {}
                g.save_json(g.personalFileLoc, g.personal)
            end
        end
        if clsid == "Normal" then
            clsid = 98
        elseif clsid == "Motion" then
            clsid = 99
        end

        slot:EnableDrop(1)
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
                -- SET_SLOT_ITEM_TEXT(slot, invItem, ItemCls)
                sub_slotset_SET_SLOT_ITEM_TEXT(slot, invItem, ItemCls)
            else

                SET_SLOT_ITEM_CLS(slot, ItemCls);
                CreateIcon(slot):SetColorTone('FFFF0000')
                slot:SetText("{s15}{ol}{b}" .. 0, 'count', ui.RIGHT, ui.BOTTOM, -2, 1);
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
            local result = SCR_QUEST_CHECK_C(GetMyPCObject(), questIES.ClassName);
            if (result == 'POSSIBLE' and questIES.POSSI_WARP == 'YES') or
                (result == 'PROGRESS' and questIES.PROG_WARP == 'YES') or
                (result == 'SUCCESS' and questIES.SUCC_WARP == 'YES') then
                icon:SetColorTone('FFFFFFFF')
                icon:SetTextTooltip("{ol}" .. questIES.Name)
            else
                icon:SetColorTone('FFFF0000')
                icon:SetTextTooltip("{ol}" .. questIES.Name)
            end
            --[[if result == "COMPLETE" then
                icon:SetColorTone('FFFF0000')
            end]]
            icon:SetImage("questinfo_return");
            SET_SLOT_COUNT_TEXT(slot, zoneName, '{s10}{ol}{b}', ui.LEFT, ui.BOTTOM, 0, 0)

        elseif category == 'Emoticon' then

            local acc = GetMyAccountObj()
            local list, listCnt = GetClassList("chat_emoticons")
            if g.emo_check < 5 then

                for i = 0, listCnt - 1 do
                    local cls = GetClassByIndexFromList(list, i)
                    if TryGetProp(cls, 'HaveUnit', 'None') == 'PC' then
                        acc = GetMyEtcObject()
                    else
                        acc = GetMyAccountObj()
                    end
                    local namelist = StringSplit(cls.ClassName, "motion_")
                    local imageName = namelist[1]
                    if 1 < #namelist then
                        imageName = namelist[2]
                    end

                    local clsId = cls.ClassID
                    if cls.CheckServer == 'YES' then
                        local haveEmoticon = TryGetProp(acc, 'HaveEmoticon_' .. clsId)
                        if haveEmoticon then
                            local icon = CreateIcon(slot)

                            if iesid == imageName then
                                icon:SetImage(iesid)
                                if haveEmoticon > 0 then
                                    icon:SetColorTone('FFFFFFFF')
                                else
                                    icon:SetColorTone('FFFF0000')
                                end
                                slot:ClearText()
                            end
                        end
                    else
                        local icon = CreateIcon(slot)

                        if iesid == imageName then
                            icon:SetImage(iesid)

                            icon:SetColorTone('FFFFFFFF')

                            slot:ClearText()
                        end
                    end

                end
            else
                local icon = CreateIcon(slot)
                icon:SetImage(iesid)
                slot:ClearText()
            end

        elseif category == 'None' then

            CLEAR_SLOT_ITEM_INFO(slot)
            slot:ClearText()
        end

    end

    g.emo_check = g.emo_check + 1
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
            g.save_json(g.settingsFileLoc, g.settings)
            CLEAR_SLOT_ITEM_INFO(ctrl)

        end
    elseif str == "character" then
        if g.personal[frame_name] and g.personal[frame_name][index] then

            g.personal[frame_name][index].clsid = 0
            g.personal[frame_name][index].category = ""
            g.personal[frame_name][index].iesid = ""
            g.save_json(g.personalFileLoc, g.personal)
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

        g.save_json(g.settingsFileLoc, g.settings)
    elseif str == "character" then

        g.personal[frameName][tostring(index)] = {
            category = category,
            clsid = clsid,
            iesid = iesid
        }

        g.save_json(g.personalFileLoc, g.personal)
    end

    sub_slotset_slotset_update(frame)

end

function sub_slotset_make_frame(parent)

    local y = parent:GetY()
    if y >= 800 then
        y = 600
    end

    local frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "_make_frame", parent:GetX(), y + 100, 0, 0)
    AUTO_CAST(frame)

    frame:Resize(225, 200)
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")

    frame:SetLayerLevel(90)
    frame:SetPos(parent:GetX(), y + 100)

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
    cancel:SetEventScript(ui.LBUTTONUP, "sub_slotset_frame_close");

    frame:ShowWindow(1)

end

function sub_slotset_frame_close(frame, ctrl)

    local top_frame = frame:GetTopParentFrame()
    top_frame:ShowWindow(0)
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

    g.settings.index = g.settings.index + 1
    local isnew = true
    g.save_json(g.settingsFileLoc, g.settings)
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
        g.save_json(g.settingsFileLoc, g.settings)
    elseif belong == "character" then
        if g.personal[frame_name] then
            g.personal[frame:GetName()] = nil

        end

        g.save_json(g.personalFileLoc, g.personal)
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
        g.save_json(g.settingsFileLoc, g.settings)
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

        g.save_json(g.personalFileLoc, g.personal)
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
        g.save_json(g.settingsFileLoc, g.settings)
    elseif belong == "character" then
        g.personal[frame_name]["etc"] = table
        g.save_json(g.personalFileLoc, g.personal)
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
    g.save_json(g.settingsFileLoc, g.settings)
    g.save_json(g.personalFileLoc, g.personal)

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

        if (result == 'POSSIBLE' and questIES.POSSI_WARP == 'YES') or
            (result == 'PROGRESS' and questIES.PROG_WARP == 'YES') or
            (result == 'SUCCESS' and questIES.SUCC_WARP == 'YES') then
            local questnpc_state = GET_QUEST_NPC_STATE(questIES, result, pc);
            if mapClassName ~= questIES[questnpc_state .. 'Map'] then
                isMoveMap = 1;
            end
            local cheat = string.format("/retquest %d", clsid);
            movie.QuestWarp(session.GetMyHandle(), cheat, isMoveMap);
            packet.ClientDirect("QuestWarp");
        else
            CreateIcon(slot):SetColorTone('FFFF0000')
        end

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

function sub_slotset_EMO_OPEN(my_frame, my_msg)
    local button = g.get_event_args(my_msg)

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
    -- print(tostring(image))
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

function sub_slotset_MAKE_QUEST_INFO_TYPE_ICON(my_frame, my_msg)

    local ctrlset, x, y, questIES, result = g.get_event_args(my_msg)

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

-- アドオンメニューボタン
local norisan_menu_addons = string.format("../%s", "addons")
local norisan_menu_addons_mkfile = string.format("../%s/mkdir.txt", "addons")
local norisan_menu_settings = string.format("../addons/%s/settings.json", "norisan_menu")
local norisan_menu_folder = string.format("../addons/%s", "norisan_menu")
local norisan_menu_mkfile = string.format("../addons/%s/mkdir.txt", "norisan_menu")
_G["norisan"] = _G["norisan"] or {}
_G["norisan"]["MENU"] = _G["norisan"]["MENU"] or {}

local json = require("json")

local function norisan_menu_create_folder_file()

    local addons_file = io.open(norisan_menu_addons_mkfile, "r")
    if not addons_file then
        os.execute('mkdir "' .. norisan_menu_addons .. '"')
        addons_file = io.open(norisan_menu_addons_mkfile, "w")
        if addons_file then
            addons_file:write("created");
            addons_file:close()
        end
    else
        addons_file:close()
    end

    local file = io.open(norisan_menu_mkfile, "r")
    if not file then
        os.execute('mkdir "' .. norisan_menu_folder .. '"')
        file = io.open(norisan_menu_mkfile, "w")
        if file then
            file:write("created");
            file:close()
        end
    else
        file:close()
    end
end
norisan_menu_create_folder_file()

local function norisan_menu_save_json(path, tbl)

    local data_to_save = {
        x = tbl.x,
        y = tbl.y,
        move = tbl.move,
        open = tbl.open,
        layer = tbl.layer
    }
    local file = io.open(path, "w")
    if file then
        local str = json.encode(data_to_save)
        file:write(str)
        file:close()
    end
end

local function norisan_menu_load_json(path)

    local file = io.open(path, "r")
    if file then
        local content = file:read("*all")
        file:close()
        if content and content ~= "" then
            local decoded, err = json.decode(content)
            if decoded then
                return decoded
            end
        end
    end
    return nil
end

function _G.norisan_menu_move_drag(frame, ctrl)
    if not frame then
        return
    end

    local current_frame_y = frame:GetY()
    local current_frame_h = frame:GetHeight()
    local base_button_h = 40

    local y_to_save = current_frame_y

    if current_frame_h > base_button_h and (_G["norisan"]["MENU"].open == 1) then
        local items_area_h_calculated = current_frame_h - base_button_h
        y_to_save = current_frame_y + items_area_h_calculated

    end

    _G["norisan"]["MENU"].x = frame:GetX()
    _G["norisan"]["MENU"].y = y_to_save

    norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
end

function _G.norisan_menu_setting_frame_ctrl(setting, ctrl)
    local ctrl_name = ctrl:GetName()

    local frame_name = _G["norisan"]["MENU"].frame_name
    local frame = ui.GetFrame(frame_name)

    if ctrl_name == "layer_edit" then
        local layer = tonumber(ctrl:GetText())
        if layer then
            _G["norisan"]["MENU"].layer = layer
            frame:SetLayerLevel(layer)
            norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])

            local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}レイヤーを変更" or
                               "{ol}Change Layer"
            ui.SysMsg(notice)
            _G.norisan_menu_create_frame()
            setting:ShowWindow(0)
            return
        end
    end

    if ctrl_name == "def_setting" then

        _G["norisan"]["MENU"].x = 1190
        _G["norisan"]["MENU"].y = 30
        _G["norisan"]["MENU"].move = true
        _G["norisan"]["MENU"].open = 0
        _G["norisan"]["MENU"].layer = 79
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        _G.norisan_menu_create_frame()
        setting:ShowWindow(0)
        return
    end
    if ctrl_name == "close" then
        setting:ShowWindow(0)
        return
    end

    local is_check = ctrl:IsChecked()
    if ctrl_name == "move_toggle" then
        if is_check == 1 then
            _G["norisan"]["MENU"].move = false
        else
            _G["norisan"]["MENU"].move = true
        end
        frame:EnableMove(_G["norisan"]["MENU"].move == true and 1 or 0)
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        return
    elseif ctrl_name == "open_toggle" then
        _G["norisan"]["MENU"].open = is_check
        norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])
        _G.norisan_menu_create_frame()
        return
    end

end

function _G.norisan_menu_setting_frame(frame, ctrl)
    local setting = ui.CreateNewFrame("chat_memberlist", "norisan_menu_setting", 0, 0, 0, 0)
    AUTO_CAST(setting)

    setting:SetTitleBarSkin("None")
    setting:SetSkinName("chat_window")
    setting:Resize(260, 135)
    setting:SetLayerLevel(999)
    setting:EnableHitTest(1)
    setting:EnableMove(1)

    setting:SetPos(frame:GetX() + 200, frame:GetY())
    setting:ShowWindow(1)

    local close = setting:CreateOrGetControl("button", "close", 0, 0, 30, 30)
    AUTO_CAST(close)
    close:SetImage("testclose_button")
    close:SetGravity(ui.RIGHT, ui.TOP)
    close:SetEventScript(ui.LBUTTONUP, "norisan_menu_setting_frame_ctrl");

    local def_setting = setting:CreateOrGetControl("button", "def_setting", 10, 5, 150, 30)
    AUTO_CAST(def_setting)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}デフォルトに戻す" or "{ol}Reset to default"
    def_setting:SetText(notice)
    def_setting:SetEventScript(ui.LBUTTONUP, "norisan_menu_setting_frame_ctrl");

    local move_toggle = setting:CreateOrGetControl('checkbox', "move_toggle", 10, 35, 30, 30)
    AUTO_CAST(move_toggle)
    move_toggle:SetCheck(_G["norisan"]["MENU"].move == true and 0 or 1)
    move_toggle:SetEventScript(ui.LBUTTONDOWN, 'norisan_menu_setting_frame_ctrl')
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}チェックするとフレーム固定" or
                       "{ol}Check to fix frame"
    move_toggle:SetText(notice)

    local open_toggle = setting:CreateOrGetControl('checkbox', "open_toggle", 10, 70, 30, 30)
    AUTO_CAST(open_toggle)
    open_toggle:SetCheck(_G["norisan"]["MENU"].open)
    open_toggle:SetEventScript(ui.LBUTTONDOWN, 'norisan_menu_setting_frame_ctrl')
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}チェックすると上開き" or
                       "{ol}Check to open upward"
    open_toggle:SetText(notice)

    local layer_text = setting:CreateOrGetControl('richtext', 'layer_text', 10, 105, 50, 20)
    AUTO_CAST(layer_text)
    local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{ol}レイヤー設定" or "{ol}Set Layer"
    layer_text:SetText(notice)

    local layer_edit = setting:CreateOrGetControl('edit', 'layer_edit', 130, 105, 70, 20)
    AUTO_CAST(layer_edit)
    layer_edit:SetFontName("white_16_ol")
    layer_edit:SetTextAlign("center", "center")
    layer_edit:SetText(_G["norisan"]["MENU"].layer or 79)
    layer_edit:SetEventScript(ui.ENTERKEY, "norisan_menu_setting_frame_ctrl")
end

function _G.norisan_menu_toggle_items_display(frame, ctrl, open_dir)

    local open_up = (open_dir == 1)

    local menu_src = _G["norisan"]["MENU"]
    local max_cols = 5
    local item_w = 35
    local item_h = 35
    local y_off_down = 35

    local items = {}
    if menu_src then
        for key, data in pairs(menu_src) do
            if type(data) == "table" then
                if key ~= "x" and key ~= "y" and key ~= "open" and key ~= "move" and data.name and data.func and
                    ((data.image and data.image ~= "") or (data.icon and data.icon ~= "")) then
                    table.insert(items, {
                        key = key,
                        data = data
                    })
                end
            end
        end
    end

    local num_items = #items

    local num_rows = math.ceil(num_items / max_cols)

    local items_h = num_rows * item_h
    local frame_h_new = 40 + items_h
    local frame_y_new = _G["norisan"]["MENU"].y or 30

    if open_up then
        frame_y_new = frame_y_new - items_h
    end

    local frame_w_new
    if num_rows == 1 then
        frame_w_new = math.max(40, num_items * item_w)
    else
        frame_w_new = math.max(40, max_cols * item_w)
    end

    frame:SetPos(frame:GetX(), frame_y_new)
    frame:Resize(frame_w_new, frame_h_new)

    for idx, entry in ipairs(items) do
        local item_sidx = idx - 1
        local data = entry.data
        local key = entry.key
        local col = item_sidx % max_cols
        local x = col * item_w
        local y = 0

        if open_up then

            local logical_row_from_bottom = math.floor(item_sidx / max_cols)

            y = (frame_h_new - 40) - ((logical_row_from_bottom + 1) * item_h)
        else

            local row_down = math.floor(item_sidx / max_cols)
            y = y_off_down + (row_down * item_h)
        end

        local ctrl_name = "menu_item_" .. key
        local item_elem

        if data.image and data.image ~= "" then
            item_elem = frame:CreateOrGetControl('button', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(item_elem);
            item_elem:SetSkinName("None");
            item_elem:SetText(data.image)
        else
            item_elem = frame:CreateOrGetControl('picture', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(item_elem);
            item_elem:SetImage(data.icon);
            item_elem:SetEnableStretch(1)
        end

        if item_elem then
            item_elem:SetTextTooltip("{ol}" .. data.name)
            item_elem:SetEventScript(ui.LBUTTONUP, data.func)
            item_elem:ShowWindow(1)
        end
    end

    local main_btn = GET_CHILD(frame, "norisan_menu_pic")
    if main_btn then
        if open_up then
            main_btn:SetPos(0, frame_h_new - 40)
        else
            main_btn:SetPos(0, 0)
        end
    end
end

function _G.norisan_menu_frame_open(frame, ctrl)
    if not frame then
        return
    end

    if frame:GetHeight() > 40 then

        local children = {}
        for i = 0, frame:GetChildCount() - 1 do
            local child_obj = frame:GetChildByIndex(i)
            if child_obj then
                table.insert(children, child_obj)
            end
        end

        for _, child_obj in ipairs(children) do
            if child_obj:GetName() ~= "norisan_menu_pic" then

                frame:RemoveChild(child_obj:GetName())
            end
        end

        frame:Resize(40, 40)
        frame:SetPos(frame:GetX(), _G["norisan"]["MENU"].y or 30)
        local main_pic = GET_CHILD(frame, "norisan_menu_pic")
        if main_pic then
            main_pic:SetPos(0, 0)
        end
        return
    end

    local open_dir_val = _G["norisan"]["MENU"].open or 0
    _G.norisan_menu_toggle_items_display(frame, ctrl, open_dir_val)
end

function _G.norisan_menu_create_frame()

    _G["norisan"]["MENU"].lang = option.GetCurrentCountry()

    local loaded_cfg = norisan_menu_load_json(norisan_menu_settings)

    if loaded_cfg and loaded_cfg.layer ~= nil then
        _G["norisan"]["MENU"].layer = loaded_cfg.layer
    elseif _G["norisan"]["MENU"].layer == nil then
        _G["norisan"]["MENU"].layer = 79
    end

    if loaded_cfg and loaded_cfg.move ~= nil then
        _G["norisan"]["MENU"].move = loaded_cfg.move
    elseif _G["norisan"]["MENU"].move == nil then
        _G["norisan"]["MENU"].move = true
    end

    if loaded_cfg and loaded_cfg.open ~= nil then
        _G["norisan"]["MENU"].open = loaded_cfg.open
    elseif _G["norisan"]["MENU"].open == nil then
        _G["norisan"]["MENU"].open = 0
    end

    local default_x = 1190
    local default_y = 30

    local final_x = default_x
    local final_y = default_y

    if _G["norisan"]["MENU"].x ~= nil then
        final_x = _G["norisan"]["MENU"].x
    end
    if _G["norisan"]["MENU"].y ~= nil then
        final_y = _G["norisan"]["MENU"].y
    end

    if loaded_cfg and type(loaded_cfg.x) == "number" then
        final_x = loaded_cfg.x
    end
    if loaded_cfg and type(loaded_cfg.y) == "number" then
        final_y = loaded_cfg.y
    end

    local map_ui = ui.GetFrame("map")
    local screen_w = 1920
    if map_ui and map_ui:IsVisible() then
        screen_w = map_ui:GetWidth()
    end

    if final_x > 1920 and screen_w <= 1920 then
        final_x = default_x
        final_y = default_y
    end

    _G["norisan"]["MENU"].x = final_x
    _G["norisan"]["MENU"].y = final_y

    norisan_menu_save_json(norisan_menu_settings, _G["norisan"]["MENU"])

    local frame_name = _G["norisan"]["MENU"].frame_name
    local frame = ui.GetFrame(frame_name)

    if frame then
        AUTO_CAST(frame)
        frame:RemoveAllChild()
        frame:SetSkinName("None")
        frame:SetTitleBarSkin("None")
        frame:Resize(40, 40)
        frame:SetLayerLevel(_G["norisan"]["MENU"].layer)
        frame:EnableMove(_G["norisan"]["MENU"].move == true and 1 or 0)
        frame:SetPos(_G["norisan"]["MENU"].x, _G["norisan"]["MENU"].y)
        frame:SetEventScript(ui.LBUTTONUP, "norisan_menu_move_drag")

        local norisan_menu_pic = frame:CreateOrGetControl('picture', "norisan_menu_pic", 0, 0, 35, 40)
        AUTO_CAST(norisan_menu_pic)
        norisan_menu_pic:SetImage("sysmenu_sys")
        norisan_menu_pic:SetEnableStretch(1)
        local notice = _G["norisan"]["MENU"].lang == "Japanese" and "{nl}{ol}右クリック: 設定" or
                           "{nl}{ol}Right click: Settings"
        norisan_menu_pic:SetTextTooltip("{ol}Addons Menu" .. notice)
        norisan_menu_pic:SetEventScript(ui.LBUTTONUP, "norisan_menu_frame_open")
        norisan_menu_pic:SetEventScript(ui.RBUTTONUP, "norisan_menu_setting_frame")

        frame:ShowWindow(1)
    end

end

--[[function _G.norisan_menu_frame_down_open(frame, ctrl)

    local menu_items = _G["norisan"]["MENU"]
    local max_cols = 5
    local item_w = 35
    local item_h = 35
    local y_offset = 35

    local item_idx = 0

    if menu_items then
        for key, data in pairs(menu_items) do
            if key ~= "x" and key ~= "y" and type(data) == "table" and data.name and data.func and
                ((data.image and data.image ~= "") or (data.icon and data.icon ~= "")) then

                local col = item_idx % max_cols
                local row = math.floor(item_idx / max_cols)

                local x = col * item_w
                local y = y_offset + (row * item_h)

                local ctrl_name = "menu_item_" .. key

                local item_ui

                if data.image and data.image ~= "" then
                    item_ui = frame:CreateOrGetControl('button', ctrl_name, x, y, item_w, item_h)
                    AUTO_CAST(item_ui)
                    item_ui:SetSkinName("None")
                    item_ui:SetText(data.image)
                else
                    item_ui = frame:CreateOrGetControl('picture', ctrl_name, x, y, item_w, item_h)
                    AUTO_CAST(item_ui)
                    item_ui:SetImage(data.icon)
                    item_ui:SetEnableStretch(1)
                end

                if item_ui then
                    item_ui:SetTextTooltip("{ol}" .. data.name)
                    item_ui:SetEventScript(ui.LBUTTONUP, data.func)
                    item_ui:ShowWindow(1)
                    item_idx = item_idx + 1
                end
            end
        end
    end

    if item_idx > 0 then
        local num_rows = math.ceil(item_idx / max_cols)
        local frame_w = 0
        if num_rows == 1 then
            frame_w = math.max(40, item_idx * item_w)
        else
            frame_w = math.max(40, max_cols * item_w)
        end

        local items_h_total = (num_rows * item_h) + (num_rows > 1 and num_rows - 1 or 0)
        frame:Resize(frame_w, y_offset + items_h_total)
    else
        frame:Resize(40, 40)
    end
end

function _G.norisan_menu_frame_up_open(frame, ctrl)

    local menu_data = _G["norisan"]["MENU"]
    local max_c = 5
    local item_w = 35
    local item_h = 35

    local items = {}
    if menu_data then
        for key, data_val in pairs(menu_data) do
            if key ~= "x" and key ~= "y" and type(data_val) == "table" and data_val.name and data_val.func and
                ((data_val.image and data_val.image ~= "") or (data_val.icon and data_val.icon ~= "")) then
                table.insert(items, {
                    key = key,
                    data = data_val
                })
            end
        end
    end

    if #items == 0 then
        frame:Resize(40, 40)
        frame:SetPos(frame:GetX(), _G["norisan"]["MENU"].y or 30)
        return
    end

    local num_i = #items
    local num_r = math.ceil(num_i / max_c)

    local area_h = num_r * item_h
    local frame_h = 40 + area_h

    local orig_y = _G["norisan"]["MENU"].y or 30
    local frame_y = orig_y - area_h

    local frame_w
    if num_r == 1 then
        frame_w = math.max(40, num_i * item_w)
    else
        frame_w = math.max(40, max_c * item_w)
    end

    frame:SetPos(frame:GetX(), frame_y)
    frame:Resize(frame_w, frame_h)

    for idx, entry in ipairs(items) do
        local item_s_idx = idx - 1
        local data_val = entry.data
        local key = entry.key

        local col = item_s_idx % max_c
        local row_from_bottom = math.floor(item_s_idx / max_c)

        local y = (frame_h - 40) - ((row_from_bottom + 1) * item_h)
        local x = col * item_w
        local ctrl_name = "menu_item_" .. key
        local ui_elem

        if data_val.image and data_val.image ~= "" then
            ui_elem = frame:CreateOrGetControl('button', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(ui_elem)
            ui_elem:SetSkinName("None")
            ui_elem:SetText(data_val.image)
        else
            ui_elem = frame:CreateOrGetControl('picture', ctrl_name, x, y, item_w, item_h)
            AUTO_CAST(ui_elem)
            ui_elem:SetImage(data_val.icon)
            ui_elem:SetEnableStretch(1)
        end

        if ui_elem then
            ui_elem:SetTextTooltip("{ol}" .. data_val.name)
            ui_elem:SetEventScript(ui.LBUTTONUP, data_val.func)
            ui_elem:ShowWindow(1)
        end
    end

    local main_pic = GET_CHILD(frame, "norisan_menu_pic")
    if main_pic then
        main_pic:SetPos(0, frame_h - 40)
    end
end]]
--[[function sub_slotset_frame_move_reserve(frame, ctrl, str, num)
    AUTO_CAST(frame)
    frame:SetSkinName("chat_window")
    frame:Resize(45, 30)
    frame:EnableHitTest(1)
    frame:EnableHittestFrame(1);
    frame:EnableMove(1)
    frame:SetEventScript(ui.LBUTTONUP, "sub_slotset_frame_move_save")
end

function sub_slotset_frame_move_save(frame, ctrl, str, num)
    local x = frame:GetX();
    local y = frame:GetY();
    g.settings["screen"] = {
        x = x,
        y = y
    }
    sub_slotset_save_settings()
    frame:StopUpdateScript("sub_slotset_frame_move_setskin")
    frame:RunUpdateScript("sub_slotset_frame_move_setskin", 5.0)

end

function sub_slotset_frame_move_setskin(frame)
    frame:SetSkinName("None")
    frame:Resize(30, 30)
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

        if not g.settings["screen"] then
            g.settings["screen"] = {
                x = 783,
                y = 5
            }
            sub_slotset_save_settings()
        end

        local map_frame = ui.GetFrame("map")
        local width = map_frame:GetWidth()

        if g.settings["screen"].x > 1920 and width <= 1920 then
            g.settings["screen"] = {
                x = 783,
                y = 5
            }
        end

        frame:SetPos(g.settings["screen"].x, g.settings["screen"].y)

        -- frame:SetPos(783, 5)
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

        slot:SetEventScript(ui.MOUSEON, "sub_slotset_frame_move_reserve")
        slot:SetEventScript(ui.MOUSEOFF, "sub_slotset_frame_move_save")

    end

end]]
