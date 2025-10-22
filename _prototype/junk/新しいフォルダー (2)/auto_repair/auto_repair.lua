-- v1.0.2 on_init読み込み時にリペアーアイテムの数量確認
-- v1.0.3 SetupHookの競合修正
-- v1.0.4 23.09.05patch対応。修理キット買うコード変えてやがった許せねえ。
-- v1.0.5 数量設定を可能に
-- v1.0.6 イベント修理キットと緊急修理キットを先に使うように設定('EVENT_2005_repairPotion')と('Premium_repairPotion')それ以外持ってない
-- v1.0.7 510修理キットに対応。
-- v1.0.8 フレームの場所変更 
-- v1.0.9 フレーム動かせて記憶する様に。表示最適化
-- v1.1.0 520アップデート対応
local addonName = "AUTO_REPAIR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/new_settings.json', addonNameLower)

local acutil = require("acutil")

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
-- ここを変更すればいつまでも使えそう。知らんけど。
local repair_item_classid = 11201231
local repair_item_name = "QuestReward_repairPotion_520"
local repair_tradeshop_item = "JurateCertificate_13"
local shop_type = "JurateCertificate"

function AUTO_REPAIR_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.language = option.GetCurrentCountry()

    g.SetupHook(AUTO_REPAIR_DURNOTIFY_UPDATE, "DURNOTIFY_UPDATE")
    acutil.addSysIcon("auto_repair", "sysmenu_mac", "Auto Repair", "AUTO_REPAIR_SETTING_FRAME_INIT")

    local player_character = GetMyPCObject();
    local current_map = GetZoneName(player_character)
    local map_class = GetClass("Map", current_map)
    if map_class.MapType == "City" then

        AUTO_REPAIR_LOADSETTINGS()

        local auto_repair_item = session.GetInvItemByName(repair_item_name)

        if auto_repair_item ~= nil then
            local repair_count = auto_repair_item.count
            if repair_count < g.settings.msg_quantity then
                addon:RegisterMsg("GAME_START_3SEC", "AUTO_REPAIR_FRAME_INIT")
            end
        else
            addon:RegisterMsg("GAME_START_3SEC", "AUTO_REPAIR_FRAME_INIT")
        end
    end
end

function AUTO_REPAIR_END_DRAG(frame, ctrl, argStr, argNum)

    local frame_name = frame:GetName()
    if frame_name == "auto_repair_notice" then
        g.settings.x = frame:GetX();
        g.settings.y = frame:GetY();
    elseif frame_name == "auto_repair_setting" then
        g.settings.setting_x = frame:GetX();
        g.settings.setting_y = frame:GetY();
    end
    AUTO_REPAIR_SAVE_SETTINGS()
end

function AUTO_REPAIR_SETTING_FRAME_INIT()

    local frame = ui.CreateNewFrame("chat_memberlist", "auto_repair_setting");
    if g.settings.setting_x == nil or g.settings.setting_y == nil then
        frame:SetPos(900, 730)
    else
        frame:SetPos(g.settings.setting_x, g.settings.setting_y)
    end
    frame:EnableHitTest(1)
    frame:SetSkinName("chat_window")
    frame:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_END_DRAG")

    local text_1 = frame:CreateOrGetControl('richtext', 'text_1', 10, 10)
    AUTO_CAST(text_1)
    local item_class = GetClassByType('Item', repair_item_classid)
    local item_name = item_class.Name
    text_1:SetText("{ol}{s18}" .. item_name .. AUTO_REPAIR_LANG(" Purchase Settings"))

    local text_2 = frame:CreateOrGetControl('richtext', 'text_2', 10, 50)
    AUTO_CAST(text_2)
    text_2:SetText("{s18}{ol}" .. AUTO_REPAIR_LANG("Number of automatic purchases"))

    local text_3 = frame:CreateOrGetControl('richtext', 'text_3', 10, 80)
    AUTO_CAST(text_3)

    text_3:SetText("{s18}{ol}" .. AUTO_REPAIR_LANG("Message with less than input quantity"))

    local width = math.max(text_2:GetWidth(), text_3:GetWidth())

    local edit_1 = frame:CreateOrGetControl('edit', 'edit_1', width + 20, 45, 60, 30)
    AUTO_CAST(edit_1)
    edit_1:SetText("{ol}" .. g.settings.buy_quantity)
    edit_1:SetFontName("white_16_ol")
    edit_1:SetTextAlign("center", "center")
    edit_1:SetEventScript(ui.ENTERKEY, "AUTO_REPAIR_SETTING")
    edit_1:SetTextTooltip(g.language == "Japanese" and "エンターキー押下で登録" or
                              "Register by pressing enter key")

    local edit_2 = frame:CreateOrGetControl('edit', 'edit_2', width + 20, 75, 60, 30)
    AUTO_CAST(edit_2)
    edit_2:SetText("{ol}" .. g.settings.msg_quantity)
    edit_2:SetFontName("white_16_ol")
    edit_2:SetTextAlign("center", "center")
    edit_2:SetEventScript(ui.ENTERKEY, "AUTO_REPAIR_SETTING")
    edit_2:SetTextTooltip(g.language == "Japanese" and "エンターキー押下で登録" or
                              "Register by pressing enter key")

    local close_button = frame:CreateOrGetControl("button", "close_button", text_1:GetWidth() + 20, 0, 30, 30)
    AUTO_CAST(close_button)
    close_button:SetSkinName("None")
    close_button:SetImage("testclose_button")
    close_button:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_SETTING_FRAME_CLOSE")

    frame:Resize(text_1:GetWidth() + 60, 115)
    frame:ShowWindow(1)

end

function AUTO_REPAIR_SETTING(frame, ctrl)
    local value = tonumber(ctrl:GetText())
    local ctrl_name = tostring(ctrl:GetName())

    if tonumber(value) ~= tonumber(g.settings.buy_quantity) and ctrl_name == tostring("edit_1") then
        ui.SysMsg(g.language == "Japanese" and "購入数量を " .. value .. " 個に設定しました" or
                      "Buy quantity set to " .. value)
        g.settings.buy_quantity = value

    elseif tonumber(value) ~= tonumber(g.settings.msg_quantity) and ctrl_name == tostring("edit_2") then
        ui.SysMsg(g.language == "Japanese" and "お知らせ数量を " .. value .. " 個に設定しました" or
                      "Msg quantity set to " .. value)
        g.settings.msg_quantity = value

    end
    AUTO_REPAIR_SAVE_SETTINGS()
end

function AUTO_REPAIR_SETTING_FRAME_CLOSE(frame)
    ui.CloseFrame("auto_repair_setting")
end

function AUTO_REPAIR_LANG(str)

    if g.language == "Japanese" then
        if str == " Purchase Settings" then
            str = " 購入設定"
        end

        if str == "Number of automatic purchases" then
            str = "自動購入数入力"
        end

        if str == "Message with less than input quantity" then
            str = "入力数以下で補充メッセージ"
        end

        if str == "Do you want to replenish the few remaining?" then
            str = "残り少ないですが補充しますか？"
        end

    end
    return str

end

function AUTO_REPAIR_FRAME_INIT()

    local frame = ui.CreateNewFrame("chat_memberlist", "auto_repair_notice");

    if g.settings.x == nil or g.settings.y == nil then
        frame:SetPos(680, 660)
    else
        frame:SetPos(g.settings.x, g.settings.y)
    end

    frame:SetSkinName("chat_window")
    frame:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_END_DRAG")

    local item_class = GetClassByType('Item', repair_item_classid)
    local item_name = item_class.Name

    local text_1 = frame:CreateOrGetControl('richtext', 'text_1', 10, 10)
    AUTO_CAST(text_1)
    text_1:SetText("{s18}{ol}" .. item_name .. "{nl}" .. AUTO_REPAIR_LANG("Do you want to replenish the few remaining?"))
    text_1:SetTextAlign("center", "center")

    local yes_button = frame:CreateOrGetControl('button', 'yes_button', 50, 65, 80, 40)
    yes_button:SetSkinName("test_red_button")
    yes_button:SetText("{ol}YES")
    yes_button:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_BUY")

    local no_button = frame:CreateOrGetControl('button', 'no_button', 140, 65, 80, 40)
    no_button:SetSkinName("test_gray_button")
    no_button:SetText("{ol}NO")
    no_button:SetEventScript(ui.LBUTTONUP, "AUTO_REPAIR_CLOSE")

    if g.language == "Japanese" then
        frame:Resize(290, 110)
    else
        frame:Resize(420, 110)
        yes_button:SetMargin(115, 65, 80, 40)
        no_button:SetMargin(205, 65, 80, 40)
    end
    frame:EnableHittestFrame(1);
    frame:EnableMove(1);
    frame:ShowWindow(1)
    ReserveScript("AUTO_REPAIR_CLOSE()", 7.0)

end

function AUTO_REPAIR_CLOSE()
    local frame = ui.GetFrame("auto_repair_notice")
    frame:ShowWindow(0)
end

function AUTO_REPAIR_BUY()

    local auto_repair_item = session.GetInvItemByName(repair_item_name)
    local recipe_class = GetClass("ItemTradeShop", repair_tradeshop_item)
    local count = 0

    if auto_repair_item ~= nil then
        local repair_count = auto_repair_item.count
        count = g.settings.buy_quantity - repair_count
    else
        count = g.settings.buy_quantity
    end

    session.ResetItemList()
    session.AddItemID(tostring(0), 1)
    local item_list = session.GetItemIDList()
    local count_text = string.format("%s %s", tostring(recipe_class.ClassID), tostring(count))
    local str_list = NewStringList()
    str_list:Add(shop_type)

    item.DialogTransaction("Certificate_SHOP", item_list, count_text, str_list)
    AUTO_REPAIR_CLOSE()
end

function AUTO_REPAIR_DURNOTIFY_UPDATE(frame, not_open_frame)
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1)
    end

    local slot_set = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
    slot_set:ClearIconAll()

    for i = 0, slot_set:GetSlotCount() - 1 do
        local slot = slot_set:GetSlotByIndex(i)
        slot:ShowWindow(0)
    end

    local reverse_index = slot_set:GetSlotCount() - 1
    local equip_list = session.GetEquipItemList()
    local some_flag = 1

    for i = 0, equip_list:Count() - 1 do
        local equip_item = equip_list:GetEquipItemByIndex(i)
        local spot = item.GetEquipSpotName(equip_item.equipSpot)
        local slot_cnt = imcSlot:GetFilledSlotCount(slot_set)
        local temp_obj = equip_item:GetObject()

        if temp_obj ~= nil then
            local obj = GetIES(temp_obj)
            if IS_DUR_UNDER_10PER(obj) == true then
                local color_tone = "FF999900"
                if some_flag < 2 then
                    some_flag = 2
                    local type = equip_item.type
                    AUTO_REPAIR_ITEM_USE(obj, spot)
                end
                if IS_DUR_ZERO(obj) == true then
                    color_tone = "FF990000"
                    if some_flag < 3 then
                        some_flag = 3
                    end
                end

                local slot = slot_set:GetSlotByIndex(reverse_index - slot_cnt)
                local icon = CreateIcon(slot)
                local icon_img = obj.Icon
                local briquetting_id = TryGetProp(obj, 'BriquettingIndex', 0)
                if briquetting_id > 0 then
                    local briquetting_item_cls = GetClassByType('Item', briquetting_id)
                    icon_img = briquetting_item_cls.Icon
                end
                icon:Set(icon_img, 'Item', equip_item.type, reverse_index - slot_cnt, equip_item:GetIESID())
                icon:SetColorTone(color_tone)
                slot:ShowWindow(1)
            end

        end
    end

    local now_value = frame:GetValue()
    if some_flag == 1 then
        frame:SetValue(1)
    elseif some_flag == 2 and now_value < some_flag then
        frame:SetValue(2)
        ui.SysMsg(ScpArgMsg('DurUnder30'))
    elseif some_flag == 3 and now_value < some_flag then
        frame:SetValue(3)
        ui.SysMsg(ScpArgMsg('DurUnder0'))
    end
end

function AUTO_REPAIR_ITEM_USE(obj, spot)
    session.ResetItemList()
    local repair_potion = session.GetInvItemByName(repair_item_name)
    if repair_potion ~= nil and not repair_potion.isLockState then

        local repeat_count = math.min(repair_potion.count, 4)
        for i = 0, repeat_count - 1 do
            if obj.Dur / obj.MaxDur < 0.9 then
                item.UseByGUID(repair_potion:GetIESID())
            else
                return
            end
        end

    end
end

function AUTO_REPAIR_SAVE_SETTINGS()
    acutil.saveJSON(g.settingsFileLoc, g.settings);
end

function AUTO_REPAIR_LOADSETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then

        settings = {
            buy_quantity = 50,
            msg_quantity = 20,
            setx = 900,
            sety = 730,
            x = 680,
            y = 660
        }

    end

    if not settings.buy_quantity then
        settings.buy_quantity = 50
    elseif not settings.msg_quantity then
        settings.msg_quantity = 20
    end
    AUTO_REPAIR_SAVE_SETTINGS()
    g.settings = settings
end

