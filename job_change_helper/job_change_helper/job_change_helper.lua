-- v1.0.1　全部脱ぐボタン実装
-- v1.0.2 直前装備を着ける機能実装。ヘルメット取れないバグも修正
-- v1.0.3 ジョブ専用コスチュームを転職前に着けてたらバグるの修正、全裸でも全装備ボタンが表示されてたのを修正。
-- v1.0.4 着けられない装備をパスする様に変更。多分。
local addonName = "JOB_CHANGE_HELPER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.4"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)
g.equipmode = 0
local acutil = require("acutil")

function JOB_CHANGE_HELPER_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local invframe = ui.GetFrame('inventory')
        local inventoryGbox = invframe:GetChild("inventoryGbox")
        local alluneqbtnX = inventoryGbox:GetWidth() - 107
        local alluneqbtnY = inventoryGbox:GetHeight() - 290

        local alluneqbtn = invframe:CreateOrGetControl("button", "alluneqbtn", alluneqbtnX, alluneqbtnY, 30, 30)
        AUTO_CAST(alluneqbtn)
        alluneqbtn:SetSkinName("test_red_button")
        alluneqbtn:SetText("{img equipment_info_btn_mark2 30 25}")
        alluneqbtn:SetEventScript(ui.LBUTTONUP, "job_change_helper_allunequip")
        alluneqbtn:SetTextTooltip(g.lang == "Japanese" and "装備を全部外します。" or "Remove all equipment.")

        local alleqbtn = invframe:CreateOrGetControl("button", "alleqbtn", alluneqbtnX, alluneqbtnY, 30, 30)
        AUTO_CAST(alleqbtn)
        alleqbtn:SetSkinName("baseyellow_btn")
        alleqbtn:SetText("{ol}{img equipment_info_btn_mark2 30 25}")
        alleqbtn:SetEventScript(ui.LBUTTONUP, "job_change_helper_allequip")
        alleqbtn:SetEventScript(ui.RBUTTONUP, "job_change_helper_modechange")
        alleqbtn:SetTextTooltip(g.lang == "Japanese" and
                                    "直前に脱いだ装備を全部着けます。{nl}右クリックでモードを強制クリア" or
                                    "Put on all the equipment you took off just before.{nl}Right-click to force clear mode")

        if g.equipmode == 0 then
            alluneqbtn:ShowWindow(1)
            alleqbtn:ShowWindow(0)
        else
            alluneqbtn:ShowWindow(0)
            alleqbtn:ShowWindow(1)
        end
    end

    addon:RegisterMsg("GAME_START_3SEC", "job_change_helper_changejob_init")

end

function job_change_helper_modechange(frame)
    local frame = ui.GetFrame("inventory")
    local alluneqbtn = GET_CHILD_RECURSIVELY(frame, "alluneqbtn")
    local alleqbtn = GET_CHILD_RECURSIVELY(frame, "alleqbtn")

    if g.equipmode == 1 then
        g.equipmode = 0
        alluneqbtn:ShowWindow(1)
        alleqbtn:ShowWindow(0)
    end
end

function job_change_helper_allunequip()

    g.equipInfoTable = {}
    local count = 0
    local equipItemList = session.GetEquipItemList();
    local cnt = equipItemList:Count();

    for i = 0, cnt - 1 do
        local equipItem = equipItemList:GetEquipItemByIndex(i);
        local spotName = item.GetEquipSpotName(equipItem.equipSpot);
        local iesid = tostring(equipItem:GetIESID())
        local itemtype = equipItem.type;

        if iesid ~= "0" then
            count = count + 1
            g.equipInfoTable[spotName] = {
                iesid = iesid,
                clsid = itemtype
            }
            if spotName == "HELMET" then
                local helmetindex = tonumber(i)
                ReserveScript(string.format("item.UnEquip(%d)", helmetindex), 0.5)
            end
        end
    end

    session.job.ReqUnEquipItemAll()

    local frame = ui.GetFrame("inventory")
    local alluneqbtn = GET_CHILD_RECURSIVELY(frame, "alluneqbtn")
    local alleqbtn = GET_CHILD_RECURSIVELY(frame, "alleqbtn")
    if count ~= 0 then
        alluneqbtn:ShowWindow(0)
        alleqbtn:ShowWindow(1)
    else
        alluneqbtn:ShowWindow(1)
        alleqbtn:ShowWindow(0)
    end
    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        DO_WEAPON_SLOT_CHANGE(frame, 1)
    else
        DO_WEAPON_SWAP(frame, 1)
    end
    g.equipmode = 1
    g.spot_tbl = {"RH", "LH", "RH_SUB", "LH_SUB"}

    local cj_frame = ui.GetFrame("changejob")
    if cj_frame:IsVisible() == 1 then
        ReserveScript("job_change_helper_rankrollback()", 0.5)
    end
end

function job_change_helper_CHECK_EQUIPABLE(type)
    local pc = GetMyPCObject();
    local lv = GETMYPCLEVEL();
    local job = GETMYPCJOB();
    local gender = GETMYPCGENDER();
    local prop = geItemTable.GetProp(type);

    local ret = prop:CheckEquip(lv, job, gender);
    local haveAbil = session.IsEquipWeaponAbil(type);
    if ret == 'OK' then
        if 0 ~= haveAbil then
            return ret;
        else
            return 'ABIL'
        end
    elseif ret == 'NOEQUIP' then
        return ret
    else
        if ret == 'LV' or ret == 'GENDER' or ret == 'JOB' then
            return ret;
        elseif 0 ~= haveAbil then
            return 'OK'
        end
    end
    return ret;
end

function job_change_helper_allequip()

    local frame = ui.GetFrame("inventory")
    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        DO_WEAPON_SLOT_CHANGE(frame, 1)
    else
        DO_WEAPON_SWAP(frame, 1)
    end

    for _, spot in ipairs(g.spot_tbl) do
        local itemData = g.equipInfoTable[spot]
        if itemData then
            local clsid = itemData.clsid
            local iesid = itemData.iesid
            local equipitem = session.GetInvItemByGuid(tonumber(iesid))
            if equipitem ~= nil then
                local ret = job_change_helper_CHECK_EQUIPABLE(clsid)
                if ret == "OK" then
                    ITEM_EQUIP(equipitem.invIndex, spot)
                    table.remove(g.spot_tbl, 1)
                    ReserveScript("job_change_helper_allequip()", 0.5)
                    return
                end
            end
        end
    end

    for spotName, _ in pairs(g.equipInfoTable) do
        if spotName ~= "RH" and spotName ~= "LH" and spotName ~= "RH_SUB" and spotName ~= "LH_SUB" then
            local clsid = g.equipInfoTable[spotName].clsid
            local iesid = g.equipInfoTable[spotName].iesid
            local equipitem = session.GetInvItemByGuid(tonumber(iesid));
            if equipitem ~= nil then
                local ret = job_change_helper_CHECK_EQUIPABLE(clsid)
                if ret == "OK" then

                    ITEM_EQUIP(equipitem.invIndex, spotName)
                    ReserveScript("job_change_helper_allequip()", 0.5)
                    return
                end
            end
        end
    end

    local alluneqbtn = GET_CHILD_RECURSIVELY(frame, "alluneqbtn")
    local alleqbtn = GET_CHILD_RECURSIVELY(frame, "alleqbtn")
    alluneqbtn:ShowWindow(1)
    alleqbtn:ShowWindow(0)
    ui.SysMsg("[JCH]End of Operation")
    g.equipmode = 0
    g.equipInfoTable = nil

    return

end

function job_change_helper_cj_click()

    local frame = ui.GetFrame("changejob")
    local summonedPet = session.pet.GetSummonedPet();
    if summonedPet == nil then
        ReserveScript("job_change_helper_allunequip()", 0.5)
        return
    else
        ReserveScript(string.format("job_change_helper_pet_bye('%s')", tostring(summonedPet)), 0.5)
        return
    end
end

function job_change_helper_pet_bye(summonedPet)
    if summonedPet ~= nil then
        control.SummonPet(0, 0, 0)
        ReserveScript("job_change_helper_allunequip()", 0.5)
        return
    end
end

function job_change_helper_changejob_init()
    local frame = ui.GetFrame("changejob")

    if frame ~= nil then
        local jobchangesetting = frame:CreateOrGetControl("button", "jobchangesetting", 70, 110, 226, 78)
        AUTO_CAST(jobchangesetting)
        jobchangesetting:SetSkinName("None")
        jobchangesetting:SetImage("btn_lv3")
        jobchangesetting:SetText("{ol}Job Change Helper")
        jobchangesetting:EnableHitTest(1);
        jobchangesetting:SetAnimation("MouseOnAnim", "btn_mouseover");
        jobchangesetting:SetEventScript(ui.LBUTTONDOWN, "OUT_PARTY")
        jobchangesetting:SetEventScript(ui.LBUTTONUP, "job_change_helper_cj_click")

        return
    end
end

function job_change_helper_rankrollback()

    ui.SysMsg(g.lang == "Japanese" and "転職準備完了" or "Ready to change jobs")
end

--[[function job_change_helper_do()
    local frame = ui.GetFrame("rankrollback")
    frame:ShowWindow(1)
    -- local frame = ui.GetFrame("changejob")
    -- CHANGEJOB_OPEN(frame)
    ui.SysMsg("Ready to change jobs")
end

function job_change_helper_unequip()
    g.equipInfoTable = {}
    local equipItemList = session.GetEquipItemList();
    local cnt = equipItemList:Count();
    local count = 0

    for i = 0, cnt - 1 do
        local equipItem = equipItemList:GetEquipItemByIndex(i);
        local spotName = item.GetEquipSpotName(equipItem.equipSpot);
        local iesid = tostring(equipItem:GetIESID())
        local itemtype = equipItem.type;
        local iteminfo = session.GetEquipItemByType(itemtype);

        if iesid ~= "0" then
            count = count + 1
            g.equipInfoTable[spotName] = iesid
            if spotName == "HELMET" then

                local helmetindex = tonumber(i)
                ReserveScript(string.format("item.UnEquip(%d)", helmetindex), 0.5)
            end
        end

    end

    session.job.ReqUnEquipItemAll()

    local frame = ui.GetFrame("inventory")
    local alluneqbtn = GET_CHILD_RECURSIVELY(frame, "alluneqbtn")
    local alleqbtn = GET_CHILD_RECURSIVELY(frame, "alleqbtn")

    if count ~= 0 then

        alluneqbtn:ShowWindow(0)
        alleqbtn:ShowWindow(1)
    else
        alluneqbtn:ShowWindow(1)
        alleqbtn:ShowWindow(0)
    end

    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        DO_WEAPON_SLOT_CHANGE(frame, 1)
    else
        DO_WEAPON_SWAP(frame, 1)
    end
    g.equipmode = 1
    g.outer = 0
    g.special_costume = 0

    ReserveScript("job_change_helper_rankrollback()", 0.5)
    return
end]]
