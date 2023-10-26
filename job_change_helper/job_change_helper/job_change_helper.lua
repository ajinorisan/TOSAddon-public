-- v1.0.1　全部脱ぐボタン実装
-- v1.0.2 直前装備を着ける機能実装。ヘルメット取れないバグも修正
-- v1.0.3 ジョブ専用コスチュームを転職前に着けてたらバグるの修正、全裸でも全装備ボタンが表示されてたのを修正。
local addonName = "JOB_CHANGE_HELPER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.3"

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
        -- alluneqbtn:SetEventScript(ui.RBUTTONUP, "job_change_modechange")
        alluneqbtn:SetTextTooltip("{@st59}装備を全部外します。{nl}Remove all equipment.")

        local alleqbtn = invframe:CreateOrGetControl("button", "alleqbtn", alluneqbtnX, alluneqbtnY, 30, 30)
        AUTO_CAST(alleqbtn)
        alleqbtn:SetSkinName("baseyellow_btn")
        -- CHAT_SYSTEM("test")
        alleqbtn:SetText("{ol}{img equipment_info_btn_mark2 30 25}")
        alleqbtn:SetEventScript(ui.LBUTTONUP, "job_change_helper_allequip")
        alleqbtn:SetEventScript(ui.RBUTTONUP, "job_change_modechange")
        alleqbtn:SetTextTooltip(
            "{@st59}直前に脱いだ装備を全部着けます。右クリックでモードを強制クリア{nl}Put on all the equipment you took off just before.Right-click to force clear mode")

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

function job_change_modechange(frame)
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
        local iteminfo = session.GetEquipItemByType(itemtype);

        if iesid ~= "0" then
            count = count + 1
            g.equipInfoTable[spotName] = iesid
            -- print(i .. ":" .. spotName .. ":" .. iesid)
            if spotName == "HELMET" then
                -- print(i)
                local helmetindex = tonumber(i)
                ReserveScript(string.format("item.UnEquip(%d)", helmetindex), 0.5)
            end
        end

    end

    session.job.ReqUnEquipItemAll()

    local frame = ui.GetFrame("inventory")
    local alluneqbtn = GET_CHILD_RECURSIVELY(frame, "alluneqbtn")
    local alleqbtn = GET_CHILD_RECURSIVELY(frame, "alleqbtn")
    -- print(tostring(count))
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
    -- テーブルの内容を表示（テスト用）
    --[[for spotName, iesid in pairs(equipInfoTable) do
        print(spotName .. ":" .. iesid)
    end]]
end

function job_change_helper_allequip()
    local frame = ui.GetFrame("inventory")
    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        DO_WEAPON_SLOT_CHANGE(frame, 1)
    else
        DO_WEAPON_SWAP(frame, 1)
    end
    for spotName, iesid in pairs(g.equipInfoTable) do
        local equipitem = session.GetInvItemByGuid(tonumber(iesid));
        if spotName == "RH" and equipitem ~= nil then
            ITEM_EQUIP(equipitem.invIndex, spotName)
            ReserveScript("job_change_helper_allequip()", 0.5)
            return

        end
    end
    for spotName, iesid in pairs(g.equipInfoTable) do
        local equipitem = session.GetInvItemByGuid(tonumber(iesid));
        if spotName == "LH" and equipitem ~= nil then
            ITEM_EQUIP(equipitem.invIndex, spotName)
            ReserveScript("job_change_helper_allequip()", 0.5)
            return

        end
    end
    for spotName, iesid in pairs(g.equipInfoTable) do
        local equipitem = session.GetInvItemByGuid(tonumber(iesid));
        if spotName == "RH_SUB" and equipitem ~= nil then
            ITEM_EQUIP(equipitem.invIndex, spotName)
            ReserveScript("job_change_helper_allequip()", 0.5)
            return

        end
    end
    for spotName, iesid in pairs(g.equipInfoTable) do
        local equipitem = session.GetInvItemByGuid(tonumber(iesid));
        if spotName == "LH_SUB" and equipitem ~= nil then
            ITEM_EQUIP(equipitem.invIndex, spotName)
            ReserveScript("job_change_helper_allequip()", 0.5)
            return

        end
    end
    for spotName, iesid in pairs(g.equipInfoTable) do
        local equipitem = session.GetInvItemByGuid(tonumber(iesid));
        -- print(tostring(spotName))

        if equipitem ~= nil and g.outer == 0 and spotName == "OUTER" then
            ITEM_EQUIP(equipitem.invIndex, spotName)
            g.outer = 1
            -- print(tostring("outer:" .. g.outer))
            ReserveScript("job_change_helper_allequip()", 0.5)
            return
        elseif equipitem ~= nil and g.special_costume == 0 and spotName == "SPECIALCOSTUME" then
            ITEM_EQUIP(equipitem.invIndex, spotName)
            g.special_costume = 1
            -- print(tostring("special_costume:" .. g.special_costume))
            ReserveScript("job_change_helper_allequip()", 0.5)
            return
        elseif equipitem ~= nil then
            ITEM_EQUIP(equipitem.invIndex, spotName)
            ReserveScript("job_change_helper_allequip()", 0.5)
            return

        end

    end
    local alluneqbtn = GET_CHILD_RECURSIVELY(frame, "alluneqbtn")
    local alleqbtn = GET_CHILD_RECURSIVELY(frame, "alleqbtn")
    alluneqbtn:ShowWindow(1)
    alleqbtn:ShowWindow(0)
    ui.SysMsg("[JCH]end of operation")
    g.equipmode = 0
    g.outer = 0
    g.special_costume = 0
    -- g.equipInfoTable = {}
    return

end

function job_change_helper_cj_click()
    local frame = ui.GetFrame("changejob")
    -- frame:SetLayerLevel(31)
    -- NICO_CHAT(string.format("{@st55_a}%s", "Out PT"))
    local summonedPet = session.pet.GetSummonedPet();
    -- print(tostring(summonedPet))
    if summonedPet == nil then
        -- CHAT_SYSTEM("inai")
        ReserveScript("job_change_helper_unequip()", 0.5)
        return
    else
        -- CHAT_SYSTEM("iru")
        ReserveScript(string.format("job_change_helper_pet_bye('%s')", tostring(summonedPet)), 0.5)
        return
    end
end

function job_change_helper_pet_bye(summonedPet)

    if summonedPet ~= nil then
        control.SummonPet(0, 0, 0)
        -- NICO_CHAT(string.format("{@st55_a}%s", "Returned Pet"))
        -- local frame = ui.GetFrame("rankrollback")
        -- RANKROLLBACK_PC_WITH_COMMPANION(frame)
        ReserveScript("job_change_helper_unequip()", 0.5)
        return
    end
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
            -- print(i .. ":" .. spotName .. ":" .. iesid)
            if spotName == "HELMET" then
                -- print(i)
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
    -- alluneqbtn:ShowWindow(0)
    -- alleqbtn:ShowWindow(1)
    if tonumber(USE_SUBWEAPON_SLOT) == 1 then
        DO_WEAPON_SLOT_CHANGE(frame, 1)
    else
        DO_WEAPON_SWAP(frame, 1)
    end
    g.equipmode = 1
    g.outer = 0
    g.special_costume = 0
    -- session.job.ReqUnEquipItemAll()
    -- NICO_CHAT(string.format("{@st55_a}%s", "Unequipped OK"))
    ReserveScript("job_change_helper_rankrollback()", 0.5)
    return
end

function job_change_helper_changejob_init()
    local frame = ui.GetFrame("changejob")
    -- CHAT_SYSTEM("frame")
    -- frame:ShowWindow(1)
    if frame ~= nil then
        local jobchangesetting = frame:CreateOrGetControl("button", "jobchangesetting", 70, 110, 226, 78)
        AUTO_CAST(jobchangesetting)
        jobchangesetting:SetSkinName("None")
        -- jobchangesetting:SetAlpha(0)
        jobchangesetting:SetText("{img btn_lv3 226 78}")

        jobchangesetting:EnableHitTest(1);
        jobchangesetting:SetAnimation("MouseOnAnim", "btn_mouseover");
        -- jobchangesetting:SetTooltipArg("Returned Pet & Unequipped & OutPT")
        -- jobchangesetting:SetAlrha(0)
        -- jobchangesetting:SetOffset(0, 110)
        -- jobchangesetting:SetEventScript(ui.MOUSEMOVE, "btn_mouseover")
        jobchangesetting:SetEventScript(ui.LBUTTONDOWN, "OUT_PARTY")
        jobchangesetting:SetEventScript(ui.LBUTTONUP, "job_change_helper_cj_click")
        -- local jobchangesetting = frame:CreateOrGetControl("button", "jobchangesetting", 20, 110, 226, 78)
        local text = frame:CreateOrGetControl("richtext", "text", 115, 135, 226, 78)
        text:EnableHitTest(1);
        text:SetEventScript(ui.LBUTTONDOWN, "OUT_PARTY")
        text:SetEventScript(ui.LBUTTONUP, "job_change_helper_cj_click")
        text:SetText("Job Change Helper")

        return

    end

end
function job_change_helper_rankrollback()
    local frame = ui.GetFrame("rankrollback")
    frame:ShowWindow(0)
    -- ReserveScript(string.format("RANKROLLBACK_CHECK_PLAYER_STATE('%s')", tostring(frame), 0.5))
    RANKROLLBACK_CHECK_PLAYER_STATE(frame)
    -- NICO_CHAT("ready go")
    -- NICO_CHAT(string.format("{@st55_a}%s", "ALL OK"))
    -- ui.SysMsg("ready")
    -- frame:ShowWindow(1)
    ReserveScript("job_change_helper_do()", 1.0)
    return
    -- frame:ShowWindow(1)
end

function job_change_helper_do()
    local rrbframe = ui.GetFrame("rankrollback")
    rrbframe:ShowWindow(0)

    local frame = ui.GetFrame("changejob")
    -- local frame = ui.GetFrame("rankrollback")
    CHANGEJOB_OPEN(frame)
    ui.SysMsg("Ready to change jobs")
    -- frame:ShowWindow(1)
end

--[[
function job_change_helper_summoned_pet(frame)

    frame:Invalidate();
    -- RANKROLLBACK_PC_WITH_COMMPANION(frame)
end

function job_change_helper_rankrollback_invalidate(frame)
    RANKROLLBACK_PC_WITH_COMMPANION(frame)
    frame:Invalidate();
    return
end
]]
