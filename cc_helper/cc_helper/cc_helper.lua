-- v1.0.0 エーテルジェム対応
-- v1.0.1 シンプルモード搭載、搬入搬出速度見直し、終了時のメッセージタイミング見直し
-- v1.0.2　インベの表示微修正　print排除
-- v1.0.3 シンプルモード→エコモードに変更　エコモード時レジェカ外れない様に。チェックボックスをインベントリに移す
-- v1.0.4 エーテルジェムマネージャーとコラボ
-- v1.0.5 エーテルジェムマネージャーとコラボ見直し。ＩＮボタンをシームレスに
-- v1.0.6 縦長画面でのボタン位置修正。一部ツールチップ追加。
-- v1.0.7 インアウトボタンをチーム倉庫にも付けた。センス溢れるUIに。monstercard_changeのボタンもチーム倉庫に付けた。
-- v1.0.8 ヘアコス対応とか。MCCと連携。ディレイタイムを設定できるように。
-- v1.0.9 MCCと連携強化。ヘアコスのエンチャントオプチョンを装備するタイミングで上書き。
-- v1.1.0 ヘアコスの付け替えで韓国語と英語クライアントで動かないバグを修正したつもり
-- v1.1.1 △入れた。見え方を自然に
-- v1.1.2 ヘアコス外した時のセッティングスファイルのバグ修正したつもり
-- v1.1.3 ギルティネの冠も移動可能に
local addonName = "CC_HELPER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.1.3"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

if not g.loaded then
    g.settings = {
        delay = 0.3,
        charid = {
            sealiesid = {},
            sealimage = {},
            arkiesid = {},
            arkimage = {},
            gemid = {},
            legiesid = {},
            legimage = {},
            godiesid = {},
            godimage = {},
            legclassid = {},
            godclassid = {},
            hair1 = {},
            hair1_iesid = {},
            hair2 = {},
            hair2_iesid = {},
            hair3 = {},
            hair3_iesid = {},
            hair1_str = {},
            hair2_str = {},
            hair3_str = {},
            mcc_use = {}
        }
    }
end

--[[local function child_name()
    local equipItemList = session.GetEquipItemList();
    local cnt = equipItemList:Count();
    local count = 0

    for i = 0, cnt - 1 do
        local equipItem = equipItemList:GetEquipItemByIndex(i);
        local spotName = item.GetEquipSpotName(equipItem.equipSpot);
        local iesid = tostring(equipItem:GetIESID())
        local itemtype = equipItem.type;
        local iteminfo = session.GetEquipItemByType(itemtype);
        print(tostring(spotName) .. ":" .. i)
    end
end
child_name()]]
function CC_HELPER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.monstercard = nil
    if not g.ischecked then
        g.ischecked = 0
    end

    if not g.loaded then
        g.loaded = true
    end

    local invframe = ui.GetFrame("inventory")

    local setbtn = invframe:CreateOrGetControl("button", "set", 232, 345, 30, 30)
    AUTO_CAST(setbtn)
    setbtn:SetSkinName("None")

    setbtn:SetText("{img config_button_normal 30 30}")

    setbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_frame_init")
    setbtn:SetTextTooltip(
        "{@st59}Character Change Helper{nl}マウス左ボタンクリック、キャラ毎に出し入れするアイテム設定。{nl}Left mouse button click, setting items to be moved in and out for each character.{/}")

    local eco = invframe:CreateOrGetControl("richtext", "eco", 210, 342)

    eco:SetText("{#FF0000}{s10}Eco")

    local checkbox = invframe:CreateOrGetControl('checkbox', 'checkbox', 210, 350, 25, 25)
    AUTO_CAST(checkbox)
    checkbox:SetCheck(g.ischecked)
    checkbox:SetEventScript(ui.LBUTTONUP, "cc_helper_ischecked")
    checkbox:ShowWindow(1)
    checkbox:SetTextTooltip(
        "{@st59}Character Change Helper{nl}チェックすると外すのにシルバーが必要なレジェンドカードとエーテルジェムの動作をスキップします。{nl}If checked, it skips the operation of legend cards and ether gems that require silver to remove.{/}")

    acutil.setupEvent(addon, "ACCOUNTWAREHOUSE_CLOSE", "CC_HELPER_ACCOUNTWAREHOUSE_CLOSE");
    acutil.setupEvent(addon, "INVENTORY_CLOSE", "cc_helper_settings_close");
    addon:RegisterMsg("GAME_START", "cc_helper_load_settings")
    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then

        addon:RegisterMsg("OPEN_DLG_ACCOUNTWAREHOUSE", "cc_helper_accountwarehouse_init")
    end
    child_name()
    -- acutil.setupHook(cc_helper_GET_SLOTSET_NAME, "GET_SLOTSET_NAME")

end

function cc_helper_GET_SLOTSET_NAME(invIndex)
    -- print(tostring(invIndex))
    local cls = GET_BASEID_CLS_BY_INVINDEX(invIndex)
    if cls == nil then
        return 'error'
    else
        local className = cls.ClassName
        if cls.MergedTreeTitle ~= "NO" then
            className = cls.MergedTreeTitle
        end
        return 'sset_' .. className
    end
end

function CC_HELPER_ACCOUNTWAREHOUSE_CLOSE(frame)

    local invframe = ui.GetFrame("inventory")
    local inbtn = GET_CHILD_RECURSIVELY(invframe, "inv_in")
    local outbtn = GET_CHILD_RECURSIVELY(invframe, "inv_out")

    inbtn:ShowWindow(0)
    outbtn:ShowWindow(0)

end

--[[function cc_helper_str(str)
    local langcode = option.GetCurrentCountry()

    if langcode == "Japanese" then
        if str == tostring("relese") then
            str = "解除"
        end
        if str == tostring("equip") then
            str = "装備"
        end

        return str
    end
    return str
end]]

function cc_helper_accountwarehouse_init()
    local awhframe = ui.GetFrame("accountwarehouse")

    local awh_inbtn = awhframe:CreateOrGetControl("button", "in", 545, 120, 40, 30)
    AUTO_CAST(awh_inbtn)
    awh_inbtn:SetText("{img in_arrow 20 20}") -- {@st66}
    awh_inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_aethergem_mgr")
    awh_inbtn:ShowWindow(1) -- test_pvp_btn
    awh_inbtn:SetSkinName("test_pvp_btn")
    awh_inbtn:SetTextTooltip(
        "{@st59}Character Change Helper{nl}装備を外して倉庫へ搬入します。{nl}The equipment is removed and brought into the warehouse.{/}")

    local awh_outbtn = awhframe:CreateOrGetControl("button", "out", 585, 120, 40, 30)
    AUTO_CAST(awh_outbtn)
    awh_outbtn:SetText("{@st66b}{img chul_arrow 20 20}")
    awh_outbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn")
    awh_outbtn:ShowWindow(1)
    awh_outbtn:SetSkinName("test_pvp_btn")
    awh_outbtn:SetTextTooltip(
        "{@st59}Character Change Helper{nl}倉庫から搬出して装備します。{nl}It is carried out from the warehouse and equipped.{/}")

    if _G.ADDONS.norisan.monstercard_change ~= nil then

        local mccbtn = awhframe:CreateOrGetControl("button", "mcc", 625, 120, 30, 30)
        AUTO_CAST(mccbtn)
        mccbtn:SetSkinName("test_red_button")
        mccbtn:SetTextAlign("right", "center")
        mccbtn:SetText("{img monsterbtn_image 30 20}{/}")
        mccbtn:SetTextTooltip(
            "{@st59}カード自動搬出入、自動着脱{nl}Automatic card loading/unloading, automatic insertion/removal{/}")
        mccbtn:SetEventScript(ui.LBUTTONUP, "monstercard_change_MONSTERCARDPRESET_FRAME_OPEN")
    end

    cc_helper_invframe_init()
end

function cc_helper_invframe_init()
    local invframe = ui.GetFrame("inventory")

    local inbtn = invframe:CreateOrGetControl("button", "inv_in", 263, 345, 30, 30)
    AUTO_CAST(inbtn)
    inbtn:SetText("{img in_arrow 20 20}") -- {@st66}
    inbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_in_btn_aethergem_mgr")
    inbtn:ShowWindow(1) -- test_pvp_btn
    inbtn:SetSkinName("test_pvp_btn")
    inbtn:SetTextTooltip(
        "{@st59}Character Change Helper{nl}装備を外して倉庫へ搬入します。{nl}The equipment is removed and brought into the warehouse.{/}")

    local outbtn = invframe:CreateOrGetControl("button", "inv_out", 293, 345, 30, 30)
    AUTO_CAST(outbtn)
    outbtn:SetText("{@st66b}{img chul_arrow 20 20}")
    outbtn:SetEventScript(ui.LBUTTONUP, "cc_helper_out_btn")
    outbtn:ShowWindow(1)
    outbtn:SetSkinName("test_pvp_btn")
    outbtn:SetTextTooltip(
        "{@st59}Character Change Helper{nl}倉庫から搬出して装備します。{nl}It is carried out from the warehouse and equipped.{/}")

end

function cc_helper_save_settings()

    acutil.saveJSON(g.settingsFileLoc, g.settings)
end

function cc_helper_load_settings()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    cc_helper_setting()

end

function cc_helper_setting()

    if g.settings.delay == nil then
        g.settings.delay = 0.3
        cc_helper_save_settings()
    end
    g.delay = g.settings.delay

    local loginCharID = info.GetCID(session.GetMyHandle())

    if g.settings.charid.mcc_use[loginCharID] == nil then
        g.settings.charid.mcc_use[loginCharID] = 0
        cc_helper_save_settings()
    end

    local mcc_use = g.settings.charid.mcc_use[loginCharID]
    g.mcc_use = nil
    if mcc_use ~= nil then
        g.mcc_use = mcc_use
    end

    if g.settings.charid.hair1 == nil then
        g.settings.charid.hair1 = {}
        -- CHAT_SYSTEM("test")
    elseif g.settings.charid.hair2 == nil then
        g.settings.charid.hair2 = {}
    elseif g.settings.charid.hair3 == nil then
        g.settings.charid.hair3 = {}
    elseif g.settings.charid.hair1_iesid == nil then
        g.settings.charid.hair1_iesid = {}
    elseif g.settings.charid.hair2_iesid == nil then
        g.settings.charid.hair2_iesid = {}
    elseif g.settings.charid.hair3_iesid == nil then
        g.settings.charid.hair3_iesid = {}
    elseif g.settings.charid.hair1_str == nil then
        g.settings.charid.hair1_str = {}
    elseif g.settings.charid.hair2_str == nil then
        g.settings.charid.hair2_str = {}
    elseif g.settings.charid.hair3_str == nil then
        g.settings.charid.hair3_str = {}
    end
    -- print(tostring(g.settings[tostring(loginCharID)].crown_image))
    if g.settings[tostring(loginCharID)] ~= nil then

        local crown_image = g.settings[loginCharID].crown_image

        if crown_image ~= nil then
            g.crown_image = crown_image

        end

        local crown_iesid = g.settings[loginCharID].crown_iesid
        if crown_iesid ~= nil then
            g.crown_iesid = crown_iesid

        end
    else
        g.crown_image = nil
        g.crown_iesid = nil
    end
    -- print(tostring(g.crown_image))
    -- print(tostring(g.crown_iesid))

    local hair1 = g.settings.charid.hair1[loginCharID]
    g.hair1 = nil
    if hair1 ~= nil then
        g.hair1 = hair1
    end
    -- print(tostring(loginCharID))
    -- print(tostring(g.hair1))
    local hair1_iesid = g.settings.charid.hair1_iesid[loginCharID]
    g.hair1_iesid = nil
    if hair1_iesid ~= nil then
        g.hair1_iesid = hair1_iesid
    end
    -- print(tostring(g.hair1_iesid))
    local hair1_str = g.settings.charid.hair1_str[loginCharID]
    -- print(tostring(hair1_str))
    g.hair1_str = nil
    if hair1_str ~= nil then
        g.hair1_str = hair1_str
    end
    -- print(tostring(g.hair1_str))
    local hair2 = g.settings.charid.hair2[loginCharID]
    g.hair2 = nil
    if hair2 ~= nil then
        g.hair2 = hair2
    end

    local hair2_iesid = g.settings.charid.hair2_iesid[loginCharID]
    g.hair2_iesid = nil
    if hair2_iesid ~= nil then
        g.hair2_iesid = hair2_iesid
    end

    local hair2_str = g.settings.charid.hair2_str[loginCharID]
    g.hair2_str = nil
    if hair2_str ~= nil then
        g.hair2_str = hair2_str
    end

    local hair3 = g.settings.charid.hair3[loginCharID]
    g.hair3 = nil
    if hair3 ~= nil then
        g.hair3 = hair3
    end

    local hair3_iesid = g.settings.charid.hair3_iesid[loginCharID]
    g.hair3_iesid = nil
    if hair3_iesid ~= nil then
        g.hair3_iesid = hair3_iesid
    end

    local hair3_str = g.settings.charid.hair3_str[loginCharID]
    g.hair3_str = nil
    if hair3_str ~= nil then
        g.hair3_str = hair3_str
    end

    local sealiesid = g.settings.charid.sealiesid[loginCharID]
    g.sealiesid = nil
    if sealiesid ~= nil then
        g.sealiesid = sealiesid
    end

    local sealimage = g.settings.charid.sealimage[loginCharID]
    g.sealimage = nil
    if sealimage ~= nil then
        g.sealimage = sealimage
    end
    -- 
    local arkiesid = g.settings.charid.arkiesid[loginCharID]

    g.arkiesid = nil
    if arkiesid ~= nil then
        g.arkiesid = arkiesid
    end

    local arkimage = g.settings.charid.arkimage[loginCharID]
    g.arkimage = nil
    if arkimage ~= nil then
        g.arkimage = arkimage
    end

    local gemid = g.settings.charid.gemid[loginCharID]
    g.gemid = nil
    if gemid ~= nil then
        g.gemid = gemid
    end

    local legiesid = g.settings.charid.legiesid[loginCharID]
    g.legiesid = nil
    if legiesid ~= nil then
        g.legiesid = legiesid
    end

    local legimage = g.settings.charid.legimage[loginCharID]
    g.legimage = nil
    if legimage ~= nil then
        g.legimage = legimage
    end

    local godiesid = g.settings.charid.godiesid[loginCharID]
    g.godiesid = nil
    if godiesid ~= nil then
        g.godiesid = godiesid
    end

    local godimage = g.settings.charid.godimage[loginCharID]
    g.godimage = nil
    if godimage ~= nil then
        g.godimage = godimage
    end

    local legclassid = g.settings.charid.legclassid[loginCharID]
    g.legclassid = nil
    if legclassid ~= nil then
        g.legclassid = legclassid
    end

    local godclassid = g.settings.charid.godclassid[loginCharID]
    g.godclassid = nil
    if godclassid ~= nil then
        g.godclassid = godclassid
    end

end

function cc_helper_out_btn()
    g.monstercard = 0
    g.agmin = 0
    local fromframe = ui.GetFrame("accountwarehouse")
    local invframe = ui.GetFrame("inventory")
    local invTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")
    invTab:SelectTab(1)

    if fromframe:IsVisible() == 1 then

        if g.crown_iesid ~= nil then
            local crown = cc_helper_check_items_in_warehouse(g.crown_iesid)
            if crown == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.crown_iesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                    fromframe:GetUserIValue("HANDLE"))

                ReserveScript("cc_helper_out_btn()", g.delay)
                return
            end
        end

        if g.sealiesid ~= nil then
            local seal = cc_helper_check_items_in_warehouse(g.sealiesid)
            if seal == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.sealiesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                    fromframe:GetUserIValue("HANDLE"))

                ReserveScript("cc_helper_out_btn()", g.delay)
                return
            end
        end

        if g.arkiesid ~= nil then
            local ark = cc_helper_check_items_in_warehouse(g.arkiesid)
            if ark == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.arkiesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                    fromframe:GetUserIValue("HANDLE"))
                ReserveScript("cc_helper_out_btn()", g.delay)
                return
            end
        end

        local cardTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")
        cardTab:SelectTab(4)

        if g.legiesid ~= nil and (g.ischecked == 0 or g.ischecked == nil) then
            local legcard = cc_helper_check_items_in_warehouse(g.legiesid)
            if legcard == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.legiesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                    fromframe:GetUserIValue("HANDLE"))
                ReserveScript("cc_helper_out_btn()", g.delay)
                return
            end
        end

        if g.godiesid ~= nil then
            local godcard = cc_helper_check_items_in_warehouse(g.godiesid)
            if godcard == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.godiesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                    fromframe:GetUserIValue("HANDLE"))
                ReserveScript("cc_helper_out_btn()", g.delay)
                return
            end

        end

        local hairTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")
        hairTab:SelectTab(1)

        if g.hair1_iesid ~= nil then
            local hair1_iesid = cc_helper_check_items_in_warehouse(g.hair1_iesid)
            if hair1_iesid == true then

                session.ResetItemList()
                session.AddItemID(tonumber(g.hair1_iesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                    fromframe:GetUserIValue("HANDLE"))
                ReserveScript("cc_helper_out_btn()", g.delay)
                return
            end

        end

        if g.hair2_iesid ~= nil then
            local hair2_iesid = cc_helper_check_items_in_warehouse(g.hair2_iesid)
            if hair2_iesid == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.hair2_iesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                    fromframe:GetUserIValue("HANDLE"))
                ReserveScript("cc_helper_out_btn()", g.delay)
                return
            end

        end

        if g.hair3_iesid ~= nil then
            local hair3_iesid = cc_helper_check_items_in_warehouse(g.hair3_iesid)
            if hair3_iesid == true then
                session.ResetItemList()
                session.AddItemID(tonumber(g.hair3_iesid), 1)
                item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                    fromframe:GetUserIValue("HANDLE"))
                ReserveScript("cc_helper_out_btn()", g.delay)
                return
            end

        end

    end
    cc_helper_equip()
end

function cc_helper_equip()

    local frame = ui.GetFrame("inventory")
    local loginCharID = info.GetCID(session.GetMyHandle())

    local hat1_item = session.GetInvItemByGuid(tonumber(g.hair1_iesid));
    if hat1_item ~= nil then

        local str = ""
        local invItem = GET_ITEM_BY_GUID(g.hair1_iesid);
        local obj = GetIES(invItem:GetObject());
        for i = 1, 3 do
            local propName = "HatPropName_" .. i;
            local propValue = "HatPropValue_" .. i;
            if obj[propValue] ~= 0 and obj[propName] ~= "None" then
                local opName = string.format("%s", ScpArgMsg(obj[propName]));
                local strInfo = ABILITY_DESC_PLUS(opName, obj[propValue]);
                local strInfo_gsub = string.gsub(strInfo, "-", "")
                local strInfo_gsub2 = string.gsub(strInfo_gsub, "  ", "")
                local strInfo_gsub3 = string.gsub(strInfo_gsub, " ", "")
                local strInfo_gsub4 = string.gsub(strInfo_gsub2, "#@!!@#", "#@! !@#")
                str = str .. strInfo_gsub4 .. "{nl}"

            end
        end
        -- str = string.gsub(str, "-", "")
        g.settings.charid.hair1_str[tostring(loginCharID)] = str
        cc_helper_save_settings()

        local hat1_spot = "HAT"
        ITEM_EQUIP(hat1_item.invIndex, hat1_spot)

        frame:Invalidate();
        ReserveScript("cc_helper_equip()", g.delay)
        return
    end

    local hat2_item = session.GetInvItemByGuid(tonumber(g.hair2_iesid));
    if hat2_item ~= nil then

        local str = ""
        local invItem = GET_ITEM_BY_GUID(g.hair2_iesid);
        local obj = GetIES(invItem:GetObject());
        for i = 1, 3 do
            local propName = "HatPropName_" .. i;
            local propValue = "HatPropValue_" .. i;
            if obj[propValue] ~= 0 and obj[propName] ~= "None" then
                local opName = string.format("%s", ScpArgMsg(obj[propName]));
                local strInfo = ABILITY_DESC_PLUS(opName, obj[propValue]);
                local strInfo_gsub = string.gsub(strInfo, "-", "")
                local strInfo_gsub2 = string.gsub(strInfo_gsub, "  ", "")
                local strInfo_gsub3 = string.gsub(strInfo_gsub, " ", "")
                local strInfo_gsub4 = string.gsub(strInfo_gsub2, "#@!!@#", "#@! !@#")
                str = str .. strInfo_gsub4 .. "{nl}"
            end
        end
        -- str = string.gsub(str, "-", "")
        g.settings.charid.hair2_str[tostring(loginCharID)] = str
        cc_helper_save_settings()

        local hat2_spot = "HAT_T"
        ITEM_EQUIP(hat2_item.invIndex, hat2_spot)

        frame:Invalidate();
        ReserveScript("cc_helper_equip()", g.delay)
        return
    end

    local hat3_item = session.GetInvItemByGuid(tonumber(g.hair3_iesid));
    if hat3_item ~= nil then

        local str = ""
        local invItem = GET_ITEM_BY_GUID(g.hair3_iesid);
        local obj = GetIES(invItem:GetObject());
        for i = 1, 3 do
            local propName = "HatPropName_" .. i;
            local propValue = "HatPropValue_" .. i;
            if obj[propValue] ~= 0 and obj[propName] ~= "None" then
                local opName = string.format("%s", ScpArgMsg(obj[propName]));
                local strInfo = ABILITY_DESC_PLUS(opName, obj[propValue]);
                local strInfo_gsub = string.gsub(strInfo, "-", "")
                local strInfo_gsub2 = string.gsub(strInfo_gsub, "  ", "")
                local strInfo_gsub3 = string.gsub(strInfo_gsub, " ", "")
                local strInfo_gsub4 = string.gsub(strInfo_gsub2, "#@!!@#", "#@! !@#")
                str = str .. strInfo_gsub4 .. "{nl}"
            end
        end
        -- str = string.gsub(str, "-", "")
        -- print(tostring(str))
        g.settings.charid.hair3_str[tostring(loginCharID)] = str
        cc_helper_save_settings()

        local hat3_spot = "HAT_L"
        ITEM_EQUIP(hat3_item.invIndex, hat3_spot)

        frame:Invalidate();
        ReserveScript("cc_helper_equip()", g.delay)
        return
    end

    local crown_item = session.GetInvItemByGuid(tonumber(g.crown_iesid));
    if crown_item ~= nil then
        local crown_spot = "RELIC"
        ITEM_EQUIP(crown_item.invIndex, crown_spot)

        frame:Invalidate();
        ReserveScript("cc_helper_equip()", g.delay)
        return
    end

    local sealitem = session.GetInvItemByGuid(tonumber(g.sealiesid));
    if sealitem ~= nil then
        local sealspot = "SEAL"
        ITEM_EQUIP(sealitem.invIndex, sealspot)

        frame:Invalidate();
        ReserveScript("cc_helper_equip()", g.delay)
        return
    end

    local arkitem = session.GetInvItemByGuid(tonumber(g.arkiesid));
    if arkitem ~= nil then
        local arkspot = "ARK"
        ITEM_EQUIP(arkitem.invIndex, arkspot)

        frame:Invalidate();

    end

    if g.legiesid ~= nil or g.godiesid ~= nil or g.gemid ~= nil then

        ReserveScript("cc_helper_card_equip()", g.delay)
        return
    else
        cc_helper_end_of_operation()
        return
        -- ui.SysMsg("[CCH]end of operation")
    end
end

function cc_helper_card_equip()

    local frame = ui.GetFrame("monstercardslot")

    local legcardslotset = GET_CHILD_RECURSIVELY(frame, "LEGcard_slotset")
    local legitem = session.GetInvItemByGuid(g.legiesid)
    local goditem = session.GetInvItemByGuid(g.godiesid)
    local legcardslot = 12
    local godcardslot = 13

    if legitem ~= nil or goditem ~= nil and frame:IsVisible() == 0 then
        MONSTERCARDSLOT_FRAME_OPEN()
    end

    if legitem ~= nil and (g.ischecked == 0 or g.ischecked == nil) then

        cc_helper_legcard_equip(legcardslot, g.legiesid)
        -- return

    elseif goditem ~= nil and g.ischecked == 0 then
        ReserveScript(string.format("cc_helper_legcard_equip(%d, '%s')", godcardslot, g.godiesid), g.delay * 3)
        return
    elseif goditem ~= nil and g.ischecked == 1 then
        cc_helper_legcard_equip(godcardslot, g.godiesid)

    elseif legitem == nil and goditem == nil and g.ischecked == 1 or g.gemid == nil then
        ReserveScript("MONSTERCARDSLOT_CLOSE()", g.delay * 2)
        cc_helper_end_of_operation()
        -- ui.SysMsg("[CCH]end of operation")
        return
    elseif legitem == nil and goditem == nil and g.gemid ~= nil then
        ReserveScript("cc_helper_gem_to_account_warehouse()", g.delay)
        return
    else
        ReserveScript("MONSTERCARDSLOT_CLOSE()", g.delay * 2)
        cc_helper_end_of_operation()
        -- ui.SysMsg("[CCH]end of operation")
        return
    end
end

function cc_helper_legcard_equip(slotIndex, itemGuid)

    local argStr = string.format("%d#%s", slotIndex, tostring(itemGuid));
    pc.ReqExecuteTx("SCR_TX_EQUIP_CARD_SLOT", argStr);

    ReserveScript("cc_helper_card_equip()", g.delay)
    return

end

function cc_helper_gem_to_account_warehouse()
    -- CHAT_SYSTEM("cc_helper_gem_to_account_warehouse()")
    local fromframe = ui.GetFrame("accountwarehouse")

    if fromframe:IsVisible() == 1 then
        if g.gemid ~= nil then

            local invframe = ui.GetFrame("inventory")
            local gemTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")
            gemTab:SelectTab(6)

            local itemList = session.GetEtcItemList(IT_ACCOUNT_WAREHOUSE);
            local guidList = itemList:GetGuidList();
            local sortedGuidList = itemList:GetSortedGuidList();
            local sortedCnt = sortedGuidList:Count();
            for i = 0, sortedCnt - 1 do
                local guid = sortedGuidList:Get(i)
                local invItem = itemList:GetItemByGuid(guid)
                local iesid = invItem:GetIESID()

                local obj = GetIES(invItem:GetObject());
                if obj.ClassName ~= MONEY_NAME then

                    if tostring(obj.ClassID) == tostring(g.gemid) then

                        session.ResetItemList()
                        session.AddItemID(tonumber(iesid), 1)
                        item.TakeItemFromWarehouse_List(IT_ACCOUNT_WAREHOUSE, session.GetItemIDList(),
                            fromframe:GetUserIValue("HANDLE"))
                        ReserveScript("cc_helper_gem_to_account_warehouse()", g.delay)

                        return

                    end
                end
            end

            -- end
            ReserveScript("MONSTERCARDSLOT_CLOSE()", g.delay * 2)
            -- ReserveScript("cc_helper_end_of_operation()", 0.3)
            cc_helper_end_of_operation()
            return
        end
    end
    ReserveScript("MONSTERCARDSLOT_CLOSE()", g.delay * 2)
    -- ReserveScript("cc_helper_end_of_operation()", 0.3)
    cc_helper_end_of_operation()

end

function cc_helper_monstercard_change(frame, ctrl)
    -- print(tostring(ctrl:GetName()))
    if tostring(ctrl:GetName()) == "cancel_btn" then
        frame:ShowWindow(0)
        return
    elseif tostring(ctrl:GetName()) == "open_btn" then
        frame:ShowWindow(0)
        monstercard_change_MONSTERCARDPRESET_FRAME_OPEN()
        return
    elseif tostring(ctrl:GetName()) == "remove_btn" then
        frame:ShowWindow(0)
        monstercard_change_MONSTERCARDPRESET_FRAME_OPEN()
        ReserveScript("monstercard_change_get_info_accountwarehouse()", g.delay)
        return
    elseif tostring(ctrl:GetName()) == "equip_btn" then
        frame:ShowWindow(0)
        monstercard_change_MONSTERCARDPRESET_FRAME_OPEN()
        ReserveScript("monstercard_change_get_presetinfo()", g.delay)
        return
    else
        return
    end

end

function cc_helper_end_of_operation()
    local frame = ui.GetFrame("inventory")
    local allTab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    allTab:SelectTab(0)

    if ADDONS.norisan.monstercard_change ~= nil and (g.ischecked == 0 or g.ischecked == nil) and g.mcc_use == 1 then

        local msgframe = ui.CreateNewFrame("chat_memberlist", "monstercardchange_msg");
        AUTO_CAST(msgframe)
        msgframe:SetLayerLevel(110);

        local screenWidth = ui.GetClientInitialWidth()
        local screenHeight = ui.GetClientInitialHeight()
        msgframe:Resize(390, 90)
        local frameWidth = msgframe:GetWidth()
        local frameHeight = msgframe:GetHeight()

        local posX = (screenWidth - frameWidth) / 2
        local posY = (screenHeight - frameHeight) / 2

        msgframe:SetPos(posX, posY)

        local text = msgframe:CreateOrGetControl('richtext', 'text', 15, 15)
        AUTO_CAST(text)
        text:SetText("{#FFA500}{ol}Call monstercard change Addon?")

        local equip_btn = msgframe:CreateOrGetControl('button', 'equip_btn', 20, 45, 80, 30)
        AUTO_CAST(equip_btn)
        equip_btn:SetText("{ol}EQUIP")
        equip_btn:SetTextTooltip(
            "カードプリセットの1番目のセットを装備します。{nl}Equip the first set of card presets.")
        equip_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_monstercard_change")
        if g.monstercard == 1 then
            equip_btn:SetEnable(0)
            equip_btn:SetSkinName("test_gray_button")
        elseif g.monstercard == 0 then
            equip_btn:SetEnable(1)
            equip_btn:SetSkinName("test_red_button")
        else
            equip_btn:SetEnable(0)
            equip_btn:SetSkinName("test_gray_button")
        end

        local remove_btn = msgframe:CreateOrGetControl('button', 'remove_btn', 105, 45, 90, 30)
        AUTO_CAST(remove_btn)
        remove_btn:SetText("{ol}REMOVE")
        remove_btn:SetTextTooltip(
            "モンスターカードを外して倉庫に搬入します。{nl}Remove the monster card and bring it into the warehouse.")
        remove_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_monstercard_change")
        if g.monstercard == 1 then
            remove_btn:SetEnable(1)
            remove_btn:SetSkinName("test_red_button")
        elseif g.monstercard == 0 then
            remove_btn:SetEnable(0)
            remove_btn:SetSkinName("test_gray_button")
        else
            remove_btn:SetEnable(0)
            remove_btn:SetSkinName("test_gray_button")
        end

        local open_btn = msgframe:CreateOrGetControl('button', 'open_btn', 200, 45, 80, 30)
        AUTO_CAST(open_btn)
        open_btn:SetText("{ol}OPEN")
        open_btn:SetTextTooltip(
            "モンスターカードとモンスターカードプリセットを開きます。{nl}Open the Monster Card and Monster Card Preset.")
        open_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_monstercard_change")

        local cancel_btn = msgframe:CreateOrGetControl('button', 'cancel_btn', 285, 45, 80, 30)
        AUTO_CAST(cancel_btn)
        cancel_btn:SetText("{ol}CANCEL")
        cancel_btn:SetEventScript(ui.LBUTTONUP, "cc_helper_monstercard_change")

        msgframe:ShowWindow(1)

        -- local msg = "Call monstercard change?"
        -- local yes_scp = "monstercard_change_MONSTERCARDPRESET_FRAME_OPEN()"

        -- ui.MsgBox(msg, yes_scp, "None");
    end

    if g.agmin == 0 then
        if ADDONS.norisan.AETHERGEM_MGR ~= nil and (g.ischecked == 0 or g.ischecked == nil) then
            -- local frame = ui.GetFrame("inventory")
            if g.gemid ~= nil then
                local equipItemList = session.GetEquipItemList();
                local rh = GET_CHILD_RECURSIVELY(frame, "RH")
                local lh = GET_CHILD_RECURSIVELY(frame, "LH")
                local rh_sub = GET_CHILD_RECURSIVELY(frame, "RH_SUB")
                local lh_sub = GET_CHILD_RECURSIVELY(frame, "LH_SUB")

                local rh_icon = rh:GetIcon()
                local lh_icon = lh:GetIcon()
                local rh_sub_icon = rh_sub:GetIcon()
                local lh_sub_icon = lh_sub:GetIcon()

                if rh_icon ~= nil then
                    local rh_icon_info = rh_icon:GetInfo()
                    local rh_guid = rh_icon_info:GetIESID()

                    local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(rh_guid).type);
                    local classID = itemCls.ClassID;
                    local equip_item = session.GetEquipItemByType(classID)
                    local gem = equip_item:GetEquipGemID(2)
                    -- gem 無い場合は0　ある場合はIES
                    -- cc_helper_end_of_operation()
                    -- CHAT_SYSTEM(tostring(gem))
                    if gem == 0 then

                        local msg = "Call Aethrgem Manager?"
                        local yes_scp = "AETHERGEM_MGR_GET_EQUIP()"
                        -- local no_scp = "cc_helper_in_btn()"
                        ui.MsgBox(msg, yes_scp, "None");

                        return
                    end
                    -- print(tostring(gem))
                elseif lh_icon ~= nil then
                    local lh_icon_info = lh_icon:GetInfo()
                    local lh_guid = lh_icon_info:GetIESID()

                    local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(lh_guid).type);
                    local classID = itemCls.ClassID;
                    local equip_item = session.GetEquipItemByType(classID)
                    local gem = equip_item:GetEquipGemID(2)
                    if gem == 0 then

                        local msg = "Call Aethrgem Manager?"
                        local yes_scp = "AETHERGEM_MGR_GET_EQUIP()"
                        -- local no_scp = "cc_helper_in_btn()"
                        ui.MsgBox(msg, yes_scp, "None");

                        return

                    end
                elseif rh_sub_icon ~= nil then
                    local rh_sub_icon_info = lh_icon:GetInfo()
                    local rh_sub_guid = rh_sub_icon_info:GetIESID()

                    local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(rh_sub_guid).type);
                    local classID = itemCls.ClassID;
                    local equip_item = session.GetEquipItemByType(classID)
                    local gem = equip_item:GetEquipGemID(2)
                    if gem == 0 then

                        local msg = "Call Aethrgem Manager?"
                        local yes_scp = "AETHERGEM_MGR_GET_EQUIP()"
                        -- local no_scp = "cc_helper_in_btn()"
                        ui.MsgBox(msg, yes_scp, "None");

                        return

                    end
                elseif lh_sub_icon ~= nil then
                    local lh_sub_icon_info = lh_icon:GetInfo()
                    local lh_sub_guid = lh_sub_icon_info:GetIESID()

                    local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(lh_sub_guid).type);
                    local classID = itemCls.ClassID;
                    local equip_item = session.GetEquipItemByType(classID)
                    local gem = equip_item:GetEquipGemID(2)
                    if gem == 0 then

                        local msg = "Call Aethrgem Manager?"
                        local yes_scp = "AETHERGEM_MGR_GET_EQUIP()"
                        -- local no_scp = "cc_helper_in_btn()"
                        ui.MsgBox(msg, yes_scp, "None");

                        return

                    end
                end
            else
                ui.SysMsg("[CCH]end of operation")
                return
            end
        else
            ui.SysMsg("[CCH]end of operation")
            return
        end

        ui.SysMsg("[CCH]end of operation")
        return
    end

    ui.SysMsg("[CCH]end of operation")
    return
end

function cc_helper_check_items_in_warehouse(iesid)
    local item = session.GetEtcItemByGuid(IT_ACCOUNT_WAREHOUSE, iesid)
    if item == nil then

        return false
    else

        return true
    end
end

function cc_helper_crown_enddrop(crown_iesid, crown_image)
    local loginCharID = info.GetCID(session.GetMyHandle())
    if crown_image ~= nil then
        if g.settings[tostring(loginCharID)] == nil then
            g.settings[tostring(loginCharID)] = {}
        end

        g.settings[tostring(loginCharID)] = {
            crown_iesid = crown_iesid,
            crown_image = crown_image
        }

        cc_helper_save_settings()
        cc_helper_load_settings()

    end

end

function cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
    legclassid, godclassid, hair1, hair2, hair3, hair1_iesid, hair2_iesid, hair3_iesid)
    -- CHAT_SYSTEM("enddrop")
    local loginCharID = info.GetCID(session.GetMyHandle())
    if hair1 ~= nil then
        g.settings.charid.hair1[tostring(loginCharID)] = hair1
    end
    if hair1_iesid ~= nil then
        g.settings.charid.hair1_iesid[tostring(loginCharID)] = hair1_iesid
    end
    if hair2 ~= nil then
        g.settings.charid.hair2[tostring(loginCharID)] = hair2
    end
    if hair2_iesid ~= nil then
        g.settings.charid.hair2_iesid[tostring(loginCharID)] = hair2_iesid
    end
    if hair3 ~= nil then
        g.settings.charid.hair3[tostring(loginCharID)] = hair3
    end
    if hair3_iesid ~= nil then
        g.settings.charid.hair3_iesid[tostring(loginCharID)] = hair3_iesid
    end

    if sealiesid ~= nil then
        g.settings.charid.sealiesid[tostring(loginCharID)] = sealiesid
    end
    if sealimage ~= nil then
        g.settings.charid.sealimage[tostring(loginCharID)] = sealimage
    end
    if arkiesid ~= nil then
        g.settings.charid.arkiesid[tostring(loginCharID)] = arkiesid
    end
    if arkimage ~= nil then
        g.settings.charid.arkimage[tostring(loginCharID)] = arkimage
    end
    if gemid ~= nil then
        g.settings.charid.gemid[tostring(loginCharID)] = tostring(gemid)
    end
    if legiesid ~= nil then
        g.settings.charid.legiesid[tostring(loginCharID)] = legiesid
    end
    if legimage ~= nil then
        g.settings.charid.legimage[tostring(loginCharID)] = legimage
    end
    if godiesid ~= nil then
        g.settings.charid.godiesid[tostring(loginCharID)] = godiesid
    end
    if godiesid ~= nil then
        g.settings.charid.godimage[tostring(loginCharID)] = godimage
    end
    if legclassid ~= nil then
        g.settings.charid.legclassid[tostring(loginCharID)] = legclassid
    end
    if godclassid ~= nil then
        g.settings.charid.godclassid[tostring(loginCharID)] = godclassid
    end
    cc_helper_save_settings()
    cc_helper_setting()

end

function cc_helper_cancel(frame, ctrl, argstr, argnum)

    ctrl:ClearIcon()
    ctrl:SetMaxSelectCount(0)
    ctrl:RemoveAllChild()

    -- CHAT_SYSTEM(ctrl:GetName())
    local loginCharID = info.GetCID(session.GetMyHandle())
    -- print(loginCharID)
    if ctrl:GetName() == tostring("crownslot") then

        g.settings[tostring(loginCharID)] = {}
        g.crown_iesid = nil
        g.crown_image = nil

    end
    -- !!
    if ctrl:GetName() == tostring("Hairslot1") then
        g.settings.charid.hair1_iesid[tostring(loginCharID)] = nil
        g.settings.charid.hair1[tostring(loginCharID)] = nil
        g.settings.charid.hair1_str[tostring(loginCharID)] = nil
        g.hair1 = nil
        g.hair1_iesid = nil
        g.hair1_str = nil

    end

    if ctrl:GetName() == tostring("Hairslot2") then
        g.settings.charid.hair2_iesid[tostring(loginCharID)] = nil
        g.settings.charid.hair2[tostring(loginCharID)] = nil
        g.settings.charid.hair2_str[tostring(loginCharID)] = nil
        g.hair2 = nil
        g.hair2_iesid = nil
        g.hair2_str = nil

    end

    if ctrl:GetName() == tostring("Hairslot3") then
        g.settings.charid.hair3_iesid[tostring(loginCharID)] = nil
        g.settings.charid.hair3[tostring(loginCharID)] = nil
        g.settings.charid.hair3_str[tostring(loginCharID)] = nil
        g.hair3 = nil
        g.hair3_iesid = nil
        g.hair3_str = nil

    end

    if ctrl:GetName() == tostring("sealslot") then
        g.settings.charid.sealiesid[tostring(loginCharID)] = nil
        g.settings.charid.sealimage[tostring(loginCharID)] = nil

        g.sealiesid = nil
        g.sealimage = nil

    end

    if ctrl:GetName() == tostring("arkslot") then
        g.settings.charid.arkiesid[tostring(loginCharID)] = nil
        g.settings.charid.arkimage[tostring(loginCharID)] = nil
        g.arkiesid = nil
        g.arkimage = nil
    end

    if ctrl:GetName() == tostring("agemslot") then
        g.settings.charid.gemid[tostring(loginCharID)] = nil
        g.gemid = nil

    end

    if ctrl:GetName() == tostring("legcardslot") then
        g.settings.charid.legiesid[tostring(loginCharID)] = nil
        g.settings.charid.legimage[tostring(loginCharID)] = nil
        g.settings.charid.legclassid[tostring(loginCharID)] = nil
        g.legiesid = nil
        g.legimage = nil
        g.legclassid = nil

    end

    if ctrl:GetName() == tostring("godcardslot") then
        g.settings.charid.godiesid[tostring(loginCharID)] = nil
        g.settings.charid.godimage[tostring(loginCharID)] = nil
        g.settings.charid.godclassid[tostring(loginCharID)] = nil
        g.godiesid = nil
        g.godimage = nil
        g.godclassid = nil
    end

    cc_helper_save_settings()

end

function cc_helper_on_legendcard_drop(frame, ctrl, argstr, argnum)

    local lifticon = ui.GetLiftIcon();
    local liftframe = ui.GetLiftFrame():GetTopParentFrame()
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local legiesid = iconinfo:GetIESID()
    local itemobj = GetIES(item:GetObject());
    local legclassid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType

    local cardobj = GetClassByType("Item", legclassid)
    if cardobj.CardGroupName ~= "LEG" then
        ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
        return
    end
    local legimage = TryGetProp(cardobj, "TooltipImage", "None")

    SET_SLOT_IMG(ctrl, legimage)
    SET_SLOT_IESID(ctrl, item:GetIESID());
    cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
        legclassid, godclassid, hair1, hair2, hair3, hair1_iesid, hair2_iesid, hair3_iesid)

end

function cc_helper_on_goddesscard_drop(frame, ctrl, argstr, argnum)

    local lifticon = ui.GetLiftIcon();
    local liftframe = ui.GetLiftFrame():GetTopParentFrame()
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local godiesid = iconinfo:GetIESID()
    local itemobj = GetIES(item:GetObject());
    local godclassid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType

    local cardobj = GetClassByType("Item", godclassid)
    if cardobj.CardGroupName ~= "GODDESS" then
        ui.SysMsg(ClMsg("ToEquipSameCardGroup"));
        return
    end
    local godimage = TryGetProp(cardobj, "TooltipImage", "None")

    SET_SLOT_IMG(ctrl, godimage)
    SET_SLOT_IESID(ctrl, item:GetIESID());

    cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
        legclassid, godclassid, hair1, hair2, hair3, hair1_iesid, hair2_iesid, hair3_iesid)

end

function cc_helper_onark_drop(frame, ctrl, argstr, argnum)

    local lifticon = ui.GetLiftIcon();
    local liftframe = ui.GetLiftFrame():GetTopParentFrame()
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local itemobj = GetIES(item:GetObject());
    local classid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType
    local gemtype = GET_EQUIP_GEM_TYPE(itemobj)
    local arkobj = GetClassByType("Item", classid)
    local arkimage = TryGetProp(arkobj, "TooltipImage", "None")

    local itemcls = GetClassByType("Item", item.type);
    local enableTeamTrade = TryGetProp(itemcls, "TeamTrade");

    if enableTeamTrade ~= nil and enableTeamTrade == "NO" then
        ui.SysMsg(ClMsg("ItemIsNotTradable"));
        return;
    end

    if ctrl == GET_CHILD_RECURSIVELY(frame, "arkslot") then
        if type == "Ark" then
            if TryGetProp(itemobj, 'CharacterBelonging', 0) == 1 then
                ui.SysMsg(ClMsg("ItemIsNotTradable"));
                return;
            end
            SET_SLOT_IMG(slot, itemobj.Icon);
            SET_SLOT_IESID(slot, item:GetIESID());
            local arkiesid = iconinfo:GetIESID()
            cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
                legclassid, godclassid, hair1, hair2, hair3, hair1_iesid, hair2_iesid, hair3_iesid)
        else
            ui.SysMsg("Drop it in the correct slot.")
        end
    end

end

function cc_helper_onseal_drop(frame, ctrl, argstr, argnum)

    local lifticon = ui.GetLiftIcon();
    local liftframe = ui.GetLiftFrame():GetTopParentFrame()
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local itemobj = GetIES(item:GetObject());
    local classid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType
    local gemtype = GET_EQUIP_GEM_TYPE(itemobj)
    local sealobj = GetClassByType("Item", classid)
    local sealiesid = item:GetIESID()

    local sealimage = TryGetProp(sealobj, "TooltipImage", "None")

    if ctrl == GET_CHILD_RECURSIVELY(frame, "sealslot") then
        if type == "Seal" and classid ~= 614001 then
            SET_SLOT_IMG(slot, itemobj.Icon);
            SET_SLOT_IESID(slot, item:GetIESID());

        elseif type == "Seal" and classid == 614001 then
            ui.SysMsg("This item cannot be set.")
        else
            ui.SysMsg("Drop it in the correct slot.")
        end
    end
    cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
        legclassid, godclassid, hair1, hair2, hair3, hair1_iesid, hair2_iesid, hair3_iesid)

end

function cc_helper_ongem_drop(frame, ctrl, argstr, argnum)

    local lifticon = ui.GetLiftIcon();
    local liftframe = ui.GetLiftFrame():GetTopParentFrame()
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local itemobj = GetIES(item:GetObject());
    local classid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType
    local gemtype = GET_EQUIP_GEM_TYPE(itemobj)
    local gemcls = GetClassByType("Item", classid)

    if ctrl == GET_CHILD_RECURSIVELY(frame, "agemslot") then
        if gemtype == "aether" then
            SET_SLOT_IMG(slot, itemobj.Icon);
            SET_SLOT_IESID(slot, item:GetIESID());
            local gemid = classid
            cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
                legclassid, godclassid, hair1, hair2, hair3, hair1_iesid, hair2_iesid, hair3_iesid)
        else
            ui.SysMsg("Drop it in the correct slot.")
        end
    end

end
-- cc_helper_crown_drop
function cc_helper_crown_drop(frame, ctrl, argstr, argnum)

    local lifticon = ui.GetLiftIcon();
    local liftframe = ui.GetLiftFrame():GetTopParentFrame()
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local iconinfo = lifticon:GetInfo();
    local item = GET_PC_ITEM_BY_GUID(iconinfo:GetIESID());
    local itemobj = GetIES(item:GetObject());
    local classid = itemobj.ClassID
    local iesid = iconinfo:GetIESID()
    local type = itemobj.ClassType
    -- print(tostring(type))
    -- print(tostring(classid))
    local crown_image = TryGetProp(itemobj, "TooltipImage", "None")

    if ctrl == GET_CHILD_RECURSIVELY(frame, "crownslot") then
        if type == "Relic" then
            SET_SLOT_IMG(slot, itemobj.Icon);
            SET_SLOT_IESID(slot, item:GetIESID());
        else
            ui.SysMsg("It is not the correct slot.")
        end
    end

    cc_helper_crown_enddrop(iesid, crown_image)

end

function cc_helper_settings_close(frame)
    local frame = ui.GetFrame("cc_helper")
    frame:ShowWindow(0)
end

function cc_helper_hairslot_drop(frame, ctrl, argStr, argNum)
    -- print(tostring(ctrl:GetName()))
    local frame = ui.GetFrame("inventory")
    --[[local group = GET_CHILD_RECURSIVELY(frame, 'inventoryGbox', 'ui::CGroupBox')
    local slotSetNameListCnt = ui.inventory.GetInvenSlotSetNameCount();]]
    local liftIcon = ui.GetLiftIcon()
    local iconInfo = liftIcon:GetInfo();
    local guid = iconInfo:GetIESID();
    local invItem = GET_ITEM_BY_GUID(guid);
    local parent = liftIcon:GetParent();
    local fromslot = parent:GetParent();
    local obj = GetIES(invItem:GetObject());
    local slot = tolua.cast(ctrl, 'ui::CSlot')
    local str = ""
    -- print(tostring(parent:GetName()))
    if frame:IsVisible() == 1 then

        --[[

        print(tostring(fromslot:GetName()))]]
        --[[local tree_box = GET_CHILD_RECURSIVELY(group, 'treeGbox_Equip', 'ui::CGroupBox')
        local tree = GET_CHILD_RECURSIVELY(tree_box, 'inventree_Equip', 'ui::CTreeControl')
        for i = 1, slotSetNameListCnt do
            local slotSetName = ui.inventory.GetInvenSlotSetNameByIndex(i - 1);
            -- print(tostring(slotSetName))
            local slotSet = GET_CHILD_RECURSIVELY(tree, slotSetName, 'ui::CSlotSet');
            if slotSet ~= nil then
                for j = 0, slotSet:GetChildCount() - 1 do
                    local slot = slotSet:GetChildByIndex(j);
                    invItem = GET_SLOT_ITEM(slot);
                    -- print(tostring(slot.info))

                end
            end
        end

        local text_1 = string.find(dictionary.ReplaceDicIDInCompStr(GET_REQ_TOOLTIP(obj)), "1")
        local text_2 = string.find(dictionary.ReplaceDicIDInCompStr(GET_REQ_TOOLTIP(obj)), "2")
        local text_3 = string.find(dictionary.ReplaceDicIDInCompStr(GET_REQ_TOOLTIP(obj)), "3")
        -- print(tostring(text_1))
        -- print(tostring(text_2))
        -- print(tostring(text_3))
        local tooltipText = tostring(GET_REQ_TOOLTIP(obj))]]

        if (tostring(fromslot:GetName()) == "sset_HairAcc_Acc1" or tostring(parent:GetName()) == "HAT") and
            tostring(ctrl:GetName()) == "Hairslot1" then
            for i = 1, 3 do
                local propName = "HatPropName_" .. i;
                local propValue = "HatPropValue_" .. i;
                if obj[propValue] ~= 0 and obj[propName] ~= "None" then
                    -- local opName = string.format("[%s] %s", ClMsg("EnchantOption"), ScpArgMsg(obj[propName])); ＩＭＣオリジナルコード
                    local opName = string.format("%s", ScpArgMsg(obj[propName]));
                    local strInfo = ABILITY_DESC_PLUS(opName, obj[propValue]);
                    local strInfo_gsub = string.gsub(strInfo, "-", "")
                    local strInfo_gsub2 = string.gsub(strInfo_gsub, "  ", "")
                    local strInfo_gsub3 = string.gsub(strInfo_gsub, " ", "")
                    local strInfo_gsub4 = string.gsub(strInfo_gsub2, "#@!!@#", "#@! !@#")
                    str = str .. strInfo_gsub4 .. "{nl}"
                end
            end
            -- print(str)
            cc_helper_hair_enddrop(ctrl, str)
            SET_SLOT_IMG(slot, obj.Icon);
            SET_SLOT_IESID(slot, guid);
            local hair1 = TryGetProp(obj, "TooltipImage", "None")
            local hair1_iesid = guid
            cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
                legclassid, godclassid, hair1, hair2, hair3, hair1_iesid, hair2_iesid, hair3_iesid)
        elseif (tostring(fromslot:GetName()) == "sset_HairAcc_Acc2" or tostring(parent:GetName()) == "HAT_T") and
            tostring(ctrl:GetName()) == "Hairslot2" then

            for i = 1, 3 do
                local propName = "HatPropName_" .. i;
                local propValue = "HatPropValue_" .. i;
                -- print(tostring(obj[propName]))
                -- print(tostring(obj[propValue]))
                if obj[propValue] ~= 0 and obj[propName] ~= "None" then
                    local opName = string.format("%s", ScpArgMsg(obj[propName]));
                    local strInfo = ABILITY_DESC_PLUS(opName, obj[propValue]);
                    local strInfo_gsub = string.gsub(strInfo, "-", "")
                    local strInfo_gsub2 = string.gsub(strInfo_gsub, "  ", "")
                    local strInfo_gsub3 = string.gsub(strInfo_gsub, " ", "")
                    local strInfo_gsub4 = string.gsub(strInfo_gsub2, "#@!!@#", "#@! !@#")
                    str = str .. strInfo_gsub4 .. "{nl}"
                end
            end
            cc_helper_hair_enddrop(ctrl, str)

            SET_SLOT_IMG(slot, obj.Icon);
            SET_SLOT_IESID(slot, guid);
            local hair2 = TryGetProp(obj, "TooltipImage", "None")
            local hair2_iesid = guid
            cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
                legclassid, godclassid, hair1, hair2, hair3, hair1_iesid, hair2_iesid, hair3_iesid)

        elseif (tostring(fromslot:GetName()) == "sset_HairAcc_Acc3" or tostring(parent:GetName()) == "HAT_L") and
            tostring(ctrl:GetName()) == "Hairslot3" then

            for i = 1, 3 do
                local propName = "HatPropName_" .. i;
                local propValue = "HatPropValue_" .. i;
                -- print(tostring(obj[propName]))
                -- print(tostring(obj[propValue]))
                if obj[propValue] ~= 0 and obj[propName] ~= "None" then
                    local opName = string.format("%s", ScpArgMsg(obj[propName]));
                    local strInfo = ABILITY_DESC_PLUS(opName, obj[propValue]);
                    local strInfo_gsub = string.gsub(strInfo, "-", "")
                    local strInfo_gsub2 = string.gsub(strInfo_gsub, "  ", "")
                    local strInfo_gsub3 = string.gsub(strInfo_gsub, " ", "")
                    local strInfo_gsub4 = string.gsub(strInfo_gsub2, "#@!!@#", "#@! !@#")
                    str = str .. strInfo_gsub4 .. "{nl}"
                end
            end
            cc_helper_hair_enddrop(ctrl, str)

            SET_SLOT_IMG(slot, obj.Icon);
            SET_SLOT_IESID(slot, guid);
            local hair3 = TryGetProp(obj, "TooltipImage", "None")
            local hair3_iesid = guid
            cc_helper_enddrop(sealiesid, arkiesid, gemid, legiesid, legimage, godiesid, godimage, sealimage, arkimage,
                legclassid, godclassid, hair1, hair2, hair3, hair1_iesid, hair2_iesid, hair3_iesid)
        else
            ui.SysMsg("Drop it in the correct slot.")
        end

    end

end

function cc_helper_hair_enddrop(ctrl, str)
    -- print(tostring(str))
    -- print(tostring(ctrl:GetName()))
    local loginCharID = info.GetCID(session.GetMyHandle())
    if ctrl:GetName() == "Hairslot1" then
        if g.settings.charid.hair1_str == nil then
            g.settings.charid.hair1_str = {}
            g.settings.charid.hair1_str[tostring(loginCharID)] = str
            -- print(tostring(str))
        else
            g.settings.charid.hair1_str[tostring(loginCharID)] = str
            -- print(tostring(str))
        end
    elseif ctrl:GetName() == "Hairslot2" then
        if g.settings.charid.hair2_str == nil then
            g.settings.charid.hair2_str = {}
            g.settings.charid.hair2_str[tostring(loginCharID)] = str
            -- print(tostring(str))
        else
            g.settings.charid.hair2_str[tostring(loginCharID)] = str
            -- print(tostring(str))
        end
    elseif ctrl:GetName() == "Hairslot3" then
        if g.settings.charid.hair3_str == nil then
            g.settings.charid.hair3_str = {}
            g.settings.charid.hair3_str[tostring(loginCharID)] = str
            -- print(tostring(str))
        else
            g.settings.charid.hair3_str[tostring(loginCharID)] = str
            -- print(tostring(str))
        end
    end
    cc_helper_save_settings()
end

function cc_helper_tooltip(frame, ctrl, argStr, argNum)
    -- print(tostring(frame:GetName()))
    if ctrl:GetName() == "Hairslot1" then
        local slot = GET_CHILD_RECURSIVELY(frame, "Hairslot1")
        AUTO_CAST(slot)
        local icon = slot:GetIcon()
        icon:SetTextTooltip(g.hair1_str)
    elseif ctrl:GetName() == "Hairslot2" then
        local slot = GET_CHILD_RECURSIVELY(frame, "Hairslot2")
        AUTO_CAST(slot)
        local icon = slot:GetIcon()
        icon:SetTextTooltip(g.hair2_str)
    elseif ctrl:GetName() == "Hairslot3" then
        local slot = GET_CHILD_RECURSIVELY(frame, "Hairslot3")
        AUTO_CAST(slot)
        local icon = slot:GetIcon()
        icon:SetTextTooltip(g.hair3_str)
    end

end

function cc_helper_mcc_use_check(frame, ctrl, argStr, argNum)
    local loginCharID = info.GetCID(session.GetMyHandle())

    -- local mcc_use = GET_CHILD_RECURSIVELY(frame, "mcc_use")

    local ischeck = ctrl:IsChecked();

    if ischeck == 1 then
        g.settings.charid.mcc_use[loginCharID] = 1
        g.mcc_use = 1
        cc_helper_save_settings()
    else
        g.settings.charid.mcc_use[loginCharID] = 0
        g.mcc_use = 0
        cc_helper_save_settings()
    end

end

function cc_helper_delay_change(frame, ctrl, argStr, argNum)
    local value = tonumber(ctrl:GetText())
    -- print(tostring(value))
    if value ~= nil then
        ui.SysMsg("Delay Time setting set to" .. value)
        g.settings.delay = value
        g.delay = value
        cc_helper_save_settings()
    else
        ui.SysMsg("Invalid value. Please enter one-byte numbers.")
        local text = GET_CHILD_RECURSIVELY(frame, "delay")
        text:SetText("0.3")
        g.settings.delay = 0.3
        g.delay = 0.3
        cc_helper_save_settings()
    end
end

function cc_helper_frame_init()

    -- エンチャントオプション上書き
    local loginCharID = info.GetCID(session.GetMyHandle())

    local hair1_str = g.settings.charid.hair1_str[loginCharID]
    g.hair1_str = nil
    if hair1_str ~= nil then
        g.hair1_str = hair1_str
    end

    local hair2_str = g.settings.charid.hair2_str[loginCharID]
    g.hair2_str = nil
    if hair2_str ~= nil then
        g.hair2_str = hair2_str
    end

    local hair3_str = g.settings.charid.hair3_str[loginCharID]
    g.hair3_str = nil
    if hair3_str ~= nil then
        g.hair3_str = hair3_str
    end
    -- エンチャントオプション上書き終わり

    local frame = ui.GetFrame(addonNameLower)
    frame:SetSkinName("test_frame_low")
    frame:SetLayerLevel(93)
    frame:Resize(270, 255)
    frame:SetPos(1140, 380)
    frame:SetTitleBarSkin("None")
    frame:EnableHittestFrame(1)
    frame:EnableHitTest(1)

    if frame:IsVisible() == 0 then

        frame:ShowWindow(1)

    else
        frame:ShowWindow(0)
    end

    local title = frame:CreateOrGetControl("richtext", "title", 40, 15)
    title:SetText("{#000000}{s16}CC Helper")

    local close = frame:CreateOrGetControl('button', 'close', 10, 10, 30, 30)
    AUTO_CAST(close)
    close:SetText("×")
    close:SetEventScript(ui.LBUTTONUP, "cc_helper_settings_close")

    local delay = frame:CreateOrGetControl('edit', 'delay', 120, 10, 60, 30)
    AUTO_CAST(delay)
    delay:SetText("{ol}" .. g.delay)
    delay:SetFontName("white_16_ol")
    delay:SetTextAlign("center", "center")
    delay:SetEventScript(ui.ENTERKEY, "cc_helper_delay_change")
    -- delay:SetEventScript(ui.ENTERKEY, "cc_helper_delay_change")
    delay:SetTextTooltip(
        "動作のディレイ時間を設定します。デフォルトは0.3秒。早過ぎると失敗が多発します。{nl}Sets the delay time for the operation. Default is 0.3 seconds. Too early and many failures will occur.")

    if ADDONS.norisan.monstercard_change ~= nil then
        local mcc_use = frame:CreateOrGetControl('checkbox', 'mcc_use', 180, 10, 30, 30)
        AUTO_CAST(mcc_use)
        mcc_use:SetCheck(g.mcc_use)
        mcc_use:SetEventScript(ui.LBUTTONUP, "cc_helper_mcc_use_check")
        mcc_use:ShowWindow(1)
        mcc_use:SetTextTooltip(
            "{@st59}Character Change Helper{nl}Monster Card Changeとの連携をキャラ毎に設定。チェックを入れると連携します。{nl}Set up linkage with Monster Card Change on a character-by-character basis. Check the box to link.{/}")
    end

    local Hairslot1 = frame:CreateOrGetControl("slot", "Hairslot1", 10, 190, 50, 50)
    AUTO_CAST(Hairslot1)
    Hairslot1:SetSkinName("invenslot2")
    Hairslot1:SetText("{ol}{s14}HAIR1")
    Hairslot1:EnablePop(1)
    Hairslot1:EnableDrag(1)
    Hairslot1:EnableDrop(1)
    Hairslot1:SetEventScript(ui.DROP, "cc_helper_hairslot_drop")
    Hairslot1:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")
    Hairslot1:SetEventScript(ui.MOUSEON, "cc_helper_tooltip")
    -- print(tostring(g.hair1_iesid))
    -- Hairslot1:SetEventScriptArgString(ui.MOUSEON, g.hair1_iesid)
    if g.hair1 ~= nil then

        SET_SLOT_IMG(Hairslot1, g.hair1);

    end

    local Hairslot2 = frame:CreateOrGetControl("slot", "Hairslot2", 70, 190, 50, 50)
    AUTO_CAST(Hairslot2)
    Hairslot2:SetSkinName("invenslot2")
    Hairslot2:SetText("{ol}{s14}HAIR2")
    Hairslot2:EnablePop(1)
    Hairslot2:EnableDrag(1)
    Hairslot2:EnableDrop(1)
    Hairslot2:SetEventScript(ui.DROP, "cc_helper_hairslot_drop")
    Hairslot2:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")
    Hairslot2:SetEventScript(ui.MOUSEON, "cc_helper_tooltip")

    if g.hair2 ~= nil then

        SET_SLOT_IMG(Hairslot2, g.hair2);

    end

    local Hairslot3 = frame:CreateOrGetControl("slot", "Hairslot3", 130, 190, 50, 50)
    AUTO_CAST(Hairslot3)
    Hairslot3:SetSkinName("invenslot2")
    Hairslot3:SetText("{ol}{s14}HAIR3")
    Hairslot3:EnablePop(1)
    Hairslot3:EnableDrag(1)
    Hairslot3:EnableDrop(1)
    Hairslot3:SetEventScript(ui.DROP, "cc_helper_hairslot_drop")
    Hairslot3:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")
    Hairslot3:SetEventScript(ui.MOUSEON, "cc_helper_tooltip")
    if g.hair3 ~= nil then

        SET_SLOT_IMG(Hairslot3, g.hair3);

    end

    local sealslot = frame:CreateOrGetControl("slot", "sealslot", 210, 70, 50, 50)
    AUTO_CAST(sealslot)
    sealslot:SetSkinName("invenslot2")
    sealslot:SetText("{ol}{s14}SEAL")
    sealslot:EnablePop(1)
    sealslot:EnableDrag(1)
    sealslot:EnableDrop(1)
    sealslot:SetEventScript(ui.DROP, "cc_helper_onseal_drop")
    sealslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")

    if g.sealiesid ~= nil then

        SET_SLOT_IMG(sealslot, g.sealimage);

    end

    local arkslot = frame:CreateOrGetControl("slot", "arkslot", 210, 130, 50, 50)
    AUTO_CAST(arkslot)
    arkslot:SetSkinName("invenslot2")
    arkslot:SetText("{ol}{s14}ARK")
    arkslot:EnablePop(1)
    arkslot:EnableDrag(1)
    arkslot:EnableDrop(1)
    arkslot:SetEventScript(ui.DROP, "cc_helper_onark_drop")
    arkslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")

    if g.arkiesid ~= nil then
        SET_SLOT_IMG(arkslot, g.arkimage);

    end

    local agemslot = frame:CreateOrGetControl("slot", "agemslot", 210, 10, 50, 50)
    AUTO_CAST(agemslot)
    agemslot:SetSkinName("invenslot2")
    agemslot:SetText("{ol}{s12}AETHER{nl}GEM")
    agemslot:EnablePop(1)
    agemslot:EnableDrag(1)
    agemslot:EnableDrop(1)
    agemslot:SetEventScript(ui.DROP, "cc_helper_ongem_drop")
    agemslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")

    if g.gemid ~= nil then
        local itemCls = GetClassByType("Item", g.gemid)
        local gemicon = itemCls.Icon

        SET_SLOT_IMG(agemslot, gemicon);

    end

    local legcardslot = frame:CreateOrGetControl("slot", "legcardslot", 10, 50, 90, 130)
    AUTO_CAST(legcardslot)
    legcardslot:SetSkinName("legendopen_cardslot")
    legcardslot:SetText("{ol}{s14}LEGEND{nl}CARD")
    legcardslot:EnablePop(1)
    legcardslot:EnableDrag(1)
    legcardslot:EnableDrop(1)
    legcardslot:SetEventScript(ui.DROP, "cc_helper_on_legendcard_drop")
    legcardslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")

    if g.legimage ~= nil then

        SET_SLOT_IMG(legcardslot, g.legimage)

    end

    local godcardslot = frame:CreateOrGetControl("slot", "godcardslot", 110, 50, 90, 130)
    AUTO_CAST(godcardslot)
    godcardslot:SetSkinName("goddess_card__activation")
    godcardslot:SetText("{ol}{s14}GODDESS{nl}CARD")
    godcardslot:EnablePop(1)
    godcardslot:EnableDrag(1)
    godcardslot:EnableDrop(1)
    godcardslot:SetEventScript(ui.DROP, "cc_helper_on_goddesscard_drop")
    godcardslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")

    if g.godimage ~= nil then

        SET_SLOT_IMG(godcardslot, g.godimage)

    end

    local crownslot = frame:CreateOrGetControl("slot", "crownslot", 210, 190, 50, 50)
    AUTO_CAST(crownslot)
    crownslot:SetSkinName("invenslot2")
    crownslot:SetText("{ol}{s12}CROWN")
    crownslot:EnablePop(1)
    crownslot:EnableDrag(1)
    crownslot:EnableDrop(1)
    crownslot:SetEventScript(ui.DROP, "cc_helper_crown_drop")
    crownslot:SetEventScript(ui.RBUTTONDOWN, "cc_helper_cancel")
    if g.crown_iesid ~= nil then
        SET_SLOT_IMG(crownslot, g.crown_image);
    end

end

function cc_helper_ischecked()
    local frame = ui.GetFrame(addonNameLower)

    local invframe = ui.GetFrame("inventory")
    local checkbox = GET_CHILD_RECURSIVELY(invframe, "checkbox")
    local simplemode = GET_CHILD_RECURSIVELY(invframe, "ecomode")
    local ischeck = checkbox:IsChecked();

    if ischeck == 1 then
        g.ischecked = 1
        simplemode:ShowWindow(1)
        return
    else
        g.ischecked = 0
        simplemode:ShowWindow(0)

        return
    end

end

function cc_helper_in_btn_aethergem_mgr()
    g.monstercard = 1
    g.agmin = 1
    local frame = ui.GetFrame("inventory")
    if ADDONS.norisan.AETHERGEM_MGR ~= nil then
        local equipItemList = session.GetEquipItemList();
        local rh = GET_CHILD_RECURSIVELY(frame, "RH")
        local lh = GET_CHILD_RECURSIVELY(frame, "LH")
        local rh_sub = GET_CHILD_RECURSIVELY(frame, "RH_SUB")
        local lh_sub = GET_CHILD_RECURSIVELY(frame, "LH_SUB")

        local rh_icon = rh:GetIcon()
        local lh_icon = lh:GetIcon()
        local rh_sub_icon = rh_sub:GetIcon()
        local lh_sub_icon = lh_sub:GetIcon()

        if rh_icon ~= nil then
            local rh_icon_info = rh_icon:GetInfo()
            local rh_guid = rh_icon_info:GetIESID()

            local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(rh_guid).type);
            local classID = itemCls.ClassID;
            local equip_item = session.GetEquipItemByType(classID)
            local gem = equip_item:GetEquipGemID(2)
            -- gem 無い場合は0　ある場合はIES
            -- cc_helper_end_of_operation()
            -- CHAT_SYSTEM(tostring(gem))
            if tostring(gem) == tostring(g.gemid) then
                cc_helper_msgbox_frame()
                return
            end
            -- print(tostring(gem))
        elseif lh_icon ~= nil then
            local lh_icon_info = lh_icon:GetInfo()
            local lh_guid = lh_icon_info:GetIESID()

            local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(lh_guid).type);
            local classID = itemCls.ClassID;
            local equip_item = session.GetEquipItemByType(classID)
            local gem = equip_item:GetEquipGemID(2)
            if tostring(gem) == tostring(g.gemid) then
                cc_helper_msgbox_frame()
                return
            end
        elseif rh_sub_icon ~= nil then
            local rh_sub_icon_info = lh_icon:GetInfo()
            local rh_sub_guid = rh_sub_icon_info:GetIESID()

            local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(rh_sub_guid).type);
            local classID = itemCls.ClassID;
            local equip_item = session.GetEquipItemByType(classID)
            local gem = equip_item:GetEquipGemID(2)
            if tostring(gem) == tostring(g.gemid) then
                cc_helper_msgbox_frame()
                return
            end
        elseif lh_sub_icon ~= nil then
            local lh_sub_icon_info = lh_icon:GetInfo()
            local lh_sub_guid = lh_sub_icon_info:GetIESID()

            local itemCls = GetClassByType("Item", session.GetEquipItemByGuid(lh_sub_guid).type);
            local classID = itemCls.ClassID;
            local equip_item = session.GetEquipItemByType(classID)
            local gem = equip_item:GetEquipGemID(2)
            if tostring(gem) == tostring(g.gemid) then
                cc_helper_msgbox_frame()
                return
            else

                cc_helper_in_btn()
            end
        else

            cc_helper_in_btn()
        end
    else
        cc_helper_in_btn()
    end

    cc_helper_in_btn()
end

function cc_helper_msgbox_frame()

    local msg = "Do you want to start Aethrgem Manager first?"
    local yes_scp = "cc_helper_in_btn_start()"
    local no_scp = "cc_helper_in_btn()"
    ui.MsgBox(msg, yes_scp, no_scp);

    return
end

function cc_helper_in_btn_start()
    local cchframe = ui.GetFrame("cc_helper")
    cchframe:ShowWindow(0)
    AETHERGEM_MGR_GET_EQUIP()
    ReserveScript("cc_helper_in_btn()", 4.0)
end

function cc_helper_in_btn()
    -- CHAT_SYSTEM("test")
    local cchframe = ui.GetFrame("cc_helper")
    cchframe:ShowWindow(0)

    local frame = ui.GetFrame("inventory")

    if true == BEING_TRADING_STATE() then
        return;
    end

    local isEmptySlot = false;

    if session.GetInvItemList():Count() < MAX_INV_COUNT then
        isEmptySlot = true;
    end

    if isEmptySlot == true then

        local induninfo = ui.GetFrame("induninfo")
        local indunenter = ui.GetFrame("indunenter")

        if induninfo:IsVisible() == 0 or indunenter:IsVisible() == 0 then
            cc_helper_unequip_seal()
            return

        end
    else
        ui.SysMsg(ScpArgMsg("Auto_inBenToLie_Bin_SeulLosi_PilyoHapNiDa."))
    end
end

function cc_helper_unequip_seal()

    local frame = ui.GetFrame("inventory")
    local eqpTab = GET_CHILD_RECURSIVELY(frame, "inventype_Tab")
    eqpTab:SelectTab(1)
    local seal = GET_CHILD_RECURSIVELY(frame, "SEAL")
    local sealicon = seal:GetIcon()

    local crown = GET_CHILD_RECURSIVELY(frame, "RELIC")
    local crown_icon = crown:GetIcon()

    if crown_icon ~= nil then
        local crown_info = crown_icon:GetInfo()
        print(tostring(crown_info))
        if crown_info ~= nil then
            local crown_iesid = crown_info:GetIESID()
            -- print(tostring(crown_iesid))
            -- print(tostring(g.crown_iesid))
            if crown_iesid ~= nil and tostring(crown_iesid) == tostring(g.crown_iesid) then
                local crown_index = 29 -- スロットインデックスを適切な値に設定する必要があります
                item.UnEquip(crown_index)
                ReserveScript("cc_helper_unequip_seal()", g.delay)

            end
        end
    end
    if sealicon ~= nil then

        local sealinfo = sealicon:GetInfo()
        if sealinfo ~= nil then

            local sealiesid = sealinfo:GetIESID()

            if sealiesid ~= nil and tostring(sealiesid) == tostring(g.sealiesid) then
                local sealindex = 25 -- スロットインデックスを適切な値に設定する必要があります
                item.UnEquip(sealindex)
                ReserveScript("cc_helper_unequip_ark()", g.delay)

                return;
            else
                ReserveScript("cc_helper_unequip_ark()", g.delay)
                return;
            end
        end
    else
        ReserveScript("cc_helper_unequip_ark()", g.delay)
        return;
    end

end

function cc_helper_unequip_ark()

    local frame = ui.GetFrame("inventory")
    local ark = GET_CHILD_RECURSIVELY(frame, "ARK")

    local arkicon = ark:GetIcon()

    if arkicon ~= nil then

        local arkinfo = arkicon:GetInfo()

        if arkinfo ~= nil then

            local arkiesid = arkinfo:GetIESID()

            if arkiesid ~= nil and tostring(arkiesid) == tostring(g.arkiesid) then

                local arkindex = 27 -- スロットインデックスを適切な値に設定する必要があります
                item.UnEquip(arkindex)

                -- ReserveScript("cc_helper_unequip_legcard()", 0.3)
                ReserveScript("cc_helper_hair_remove()", g.delay)
                return;

            else

                -- ReserveScript("cc_helper_unequip_legcard()", 0.3)
                ReserveScript("cc_helper_hair_remove()", g.delay)

                return;
            end
        end
    else

        -- ReserveScript("cc_helper_unequip_legcard()", 0.3)
        ReserveScript("cc_helper_hair_remove()", g.delay)
        return;
    end
    -- cc_helper_hair_remove()
end

function cc_helper_hair_remove()
    -- print("test")
    local frame = ui.GetFrame("inventory")

    local hat = GET_CHILD_RECURSIVELY(frame, "HAT")
    local haticon = hat:GetIcon()

    local hat_l = GET_CHILD_RECURSIVELY(frame, "HAT_L")
    local hat_l_icon = hat_l:GetIcon()

    local hat_t = GET_CHILD_RECURSIVELY(frame, "HAT_T")
    local hat_t_icon = hat_t:GetIcon()

    if haticon ~= nil then

        local hatinfo = haticon:GetInfo()

        if hatinfo ~= nil then

            local hatiesid = hatinfo:GetIESID()

            if hatiesid ~= nil and tostring(hatiesid) == tostring(g.hair1_iesid) then

                local hatindex = 0 -- スロットインデックスを適切な値に設定する必要があります
                item.UnEquip(hatindex)
                ReserveScript("cc_helper_hair_remove()", g.delay)
                return;

            end
        end

    elseif hat_l_icon ~= nil then
        local hat_l_info = hat_l_icon:GetInfo()

        if hat_l_info ~= nil then

            local hat_l_iesid = hat_l_info:GetIESID()

            if hat_l_iesid ~= nil and tostring(hat_l_iesid) == tostring(g.hair3_iesid) then

                local hat_l_index = 1 -- スロットインデックスを適切な値に設定する必要があります
                item.UnEquip(hat_l_index)

                ReserveScript("cc_helper_hair_remove()", g.delay)
                return;

            end
        end

    elseif hat_t_icon ~= nil then
        local hat_t_info = hat_t_icon:GetInfo()

        if hat_t_info ~= nil then

            local hat_t_iesid = hat_t_info:GetIESID()

            if hat_t_iesid ~= nil and tostring(hat_t_iesid) == tostring(g.hair2_iesid) then

                local hat_t_index = 20 -- スロットインデックスを適切な値に設定する必要があります
                item.UnEquip(hat_t_index)

                ReserveScript("cc_helper_hair_remove()", g.delay)
                return;

            end
        end
    end
    ReserveScript("cc_helper_unequip_legcard()", g.delay)
    return;
end

function cc_helper_unequip_legcard()

    local frame = ui.GetFrame("monstercardslot")

    local godcardslot = 14 -- レジェカを外すコード
    local godcardid = GETMYCARD_INFO(godcardslot - 1)
    local godcardInfo = equipcard.GetCardInfo(godcardslot);

    local legcardslotset = GET_CHILD_RECURSIVELY(frame, "LEGcard_slotset")
    local legcardslot = 13
    local legcardid = GETMYCARD_INFO(legcardslot - 1)
    local cardInfo = equipcard.GetCardInfo(legcardslot);

    if godcardInfo == nil and cardInfo == nil then
        local awframe = ui.GetFrame("accountwarehouse");
        if awframe:IsVisible() == 1 then
            ReserveScript("cc_helper_inv_to_warehouse()", g.delay)
            return
        else
            cc_helper_end_of_operation()
        end
    else
        MONSTERCARDSLOT_FRAME_OPEN()

        local invframe = ui.GetFrame("inventory")
        local cardTab = GET_CHILD_RECURSIVELY(invframe, "inventype_Tab")
        cardTab:SelectTab(4)
    end

    if cardInfo ~= nil and tostring(legcardid) == tostring(g.legclassid) and g.ischecked ~= 1 then

        local argStr = legcardslot - 1
        argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
        pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
        ReserveScript("cc_helper_unequip_godcard()", g.delay * 3)
        return;

    end
    ReserveScript("cc_helper_unequip_godcard()", g.delay)
    return
end

function cc_helper_unequip_godcard()

    local frame = ui.GetFrame("monstercardslot")
    local godcardslot = 14 -- レジェカを外すコード
    local godcardid = GETMYCARD_INFO(godcardslot - 1)

    local cardInfo = equipcard.GetCardInfo(godcardslot);

    if cardInfo ~= nil and tostring(godcardid) == tostring(g.godclassid) then

        local argStr = godcardslot - 1
        argStr = argStr .. " 1" -- 1을 arg list로 넘기면 5tp 소모후 카드 레벨 하락 안함
        pc.ReqExecuteTx_NumArgs("SCR_TX_UNEQUIP_CARD_SLOT", argStr)
        ReserveScript("MONSTERCARDSLOT_CLOSE()", g.delay * 2)

    end
    ReserveScript("MONSTERCARDSLOT_CLOSE()", g.delay * 2)

    local awframe = ui.GetFrame("accountwarehouse");
    if awframe:IsVisible() == 1 then
        ReserveScript("cc_helper_inv_to_warehouse()", g.delay)
        return

    end
end

function cc_helper_inv_to_warehouse()

    local frame = ui.GetFrame("accountwarehouse");
    local fromFrame = ui.GetFrame("inventory");

    if frame:IsVisible() == 1 then
        local seal = session.GetInvItemByGuid(tonumber(g.sealiesid));
        local ark = session.GetInvItemByGuid(tonumber(g.arkiesid));
        local leg = session.GetInvItemByGuid(tonumber(g.legiesid));
        local god = session.GetInvItemByGuid(tonumber(g.godiesid));
        local hair1_iesid = session.GetInvItemByGuid(tonumber(g.hair1_iesid));
        local hair2_iesid = session.GetInvItemByGuid(tonumber(g.hair2_iesid));
        local hair3_iesid = session.GetInvItemByGuid(tonumber(g.hair3_iesid));
        local crown_iesid = session.GetInvItemByGuid(tonumber(g.crown_iesid));

        if crown_iesid ~= nil then
            local invTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
            invTab:SelectTab(1)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.crown_iesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", g.delay)
            return
        end

        if hair1_iesid ~= nil then
            local invTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
            invTab:SelectTab(1)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.hair1_iesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", g.delay)
            return
        elseif hair2_iesid ~= nil then
            local invTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
            invTab:SelectTab(1)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.hair2_iesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", g.delay)
            return
        elseif hair3_iesid ~= nil then
            local invTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
            invTab:SelectTab(1)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.hair3_iesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", g.delay)
            return
        elseif seal ~= nil then
            local invTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
            invTab:SelectTab(1)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.sealiesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", g.delay)
            return
        elseif ark ~= nil then
            local invTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
            invTab:SelectTab(1)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.arkiesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", g.delay)
            return
        elseif leg ~= nil then
            local cardTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
            cardTab:SelectTab(4)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.legiesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", g.delay)
            return
        elseif god ~= nil then
            local cardTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
            cardTab:SelectTab(4)
            item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, g.godiesid, 1, nil, nil)
            ReserveScript("cc_helper_inv_to_warehouse()", g.delay)
            return

        else
            cc_helper_gem_inv_to_warehouse()
            return
        end
    end
end

function cc_helper_gem_inv_to_warehouse()

    local frame = ui.GetFrame("accountwarehouse");
    local fromFrame = ui.GetFrame("inventory");

    if frame:IsVisible() == 1 then
        local gemTab = GET_CHILD_RECURSIVELY(fromFrame, "inventype_Tab")
        gemTab:SelectTab(6)

        local invItemList = session.GetInvItemList()
        local guidList = invItemList:GetGuidList();
        local cnt = guidList:Count();

        for i = 0, cnt - 1 do
            local guid = guidList:Get(i);
            local invItem = invItemList:GetItemByGuid(guid)
            local itemobj = GetIES(invItem:GetObject())
            local iesid = invItem:GetIESID()

            if tostring(itemobj.ClassID) == tostring(g.gemid) then
                item.PutItemToWarehouse(IT_ACCOUNT_WAREHOUSE, iesid, 1, nil, nil)
                session.ResetItemList()
                ReserveScript("cc_helper_gem_inv_to_warehouse()", g.delay)
                -- break
                return
            end
            -- 
        end

    end
    cc_helper_end_of_operation()

end
