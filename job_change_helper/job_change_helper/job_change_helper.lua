-- ｖ1.0.1　全部脱ぐボタン実装
local addonName = "JOB_CHANGE_HELPER"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

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
        -- CHAT_SYSTEM("test")
        alluneqbtn:SetSkinName("test_red_button")
        -- CHAT_SYSTEM("test2")
        -- alluneqbtn:SetText("{img god_btn_inventory 20 20}")
        alluneqbtn:SetText("{img equipment_info_btn_mark2 30 25}")
        -- CHAT_SYSTEM("test3")
        -- alluneqbtn:ShowWindow(1)
        alluneqbtn:SetEventScript(ui.LBUTTONUP, "job_change_helper_allunequip")
    end
    -- CHAT_SYSTEM("JOB_CHANGE_HELPER")
    addon:RegisterMsg("GAME_START_3SEC", "job_change_helper_changejob_init")
    -- CHAT_SYSTEM("test")
end

function job_change_helper_allunequip()
    session.job.ReqUnEquipItemAll()
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
    -- CHAT_SYSTEM("equip")
    -- local invframe = ui.GetFrame("inventory")
    -- invframe:ShowWindow(1)
    session.job.ReqUnEquipItemAll()
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
    frame:ShowWindow(1)
    ReserveScript("job_change_helper_do()", 1.0)
    return
    -- frame:ShowWindow(1)
end

function job_change_helper_do()
    local rrbframe = ui.GetFrame("rankrollback")
    rrbframe:ShowWindow(0)
    ui.SysMsg("Ready to change jobs")
    local frame = ui.GetFrame("changejob")
    -- local frame = ui.GetFrame("rankrollback")
    CHANGEJOB_OPEN(frame)
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
