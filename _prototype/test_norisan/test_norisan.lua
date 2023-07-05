local addonName = "TEST_NORISAN"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

function TEST_NORISAN_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    local frame = ui.GetFrame(addonNameLower)
    frame:Resize(200, 200)
    frame:SetOffset(300, 300)
    frame:SetSkinName("None")

    local btn = frame:CreateOrGetControl("button", "myButton", 0, 0, 200, 200)
    AUTO_CAST(btn)
    btn:SetText("My Button")
    btn:SetEventScript(ui.LBUTTONUP, "test_norisan_on_btn")
    CHAT_SYSTEM(addonNameLower .. " loaded")
    acutil.SetupHook(test_norisan_cj_click_changejobbutton, "CJ_CLICK_CHANGEJOBBUTTON")
end

function test_norisan_on_btn()

    local console = ui.GetFrame("developerconsole")
    console:ShowWindow(1)
    local equipItemList = session.GetEquipItemList()

    for i = 0, equipItemList:size() - 1 do
        local equipItem = equipItemList:at(i)
        local equipSlot = equipItem.equipSlot
        local slotName = equipSlot:GetName()
        local slotIndex = equipSlot:GetSlotIndex()

        -- CHAT_SYSTEM(string.format("Slot Index: %d, Slot Name: %s", slotIndex, slotName))
        print(string.format("Slot Index: %d, Slot Name: %s", slotIndex, slotName))
    end
end

function test_norisan_cj_click_changejobbutton(frame, slot, argStr, argNum)

    OUT_PARTY()

    local summonedPet = session.pet.GetSummonedPet();
    if summonedPet ~= nil then
        control.SummonPet(0, 0, 0)
    end

    session.job.ReqUnEquipItemAll()

    local pc = GetMyPCObject();
    local nowjobName = pc.JobName;
    local nowjobID = GetClass("Job", nowjobName).ClassID;
    local havepts = GetRemainSkillPts(pc, nowjobID);
    local jobid = argNum
    local jobinfo = GetClassByType('Job', jobid);

    local rollbackInfoBox = GET_CHILD_RECURSIVELY(frame:GetTopParentFrame(), 'rollbackInfoBox');
    if rollbackInfoBox:IsVisible() == 1 then
        _EXCHANGE_JOB(frame, jobid);
        return;
    end

    exechangejobid = jobid

    local yesScp = string.format("EXEC_CHANGE_JOB()");
    local Iscompanionride = IS_COMPANIONSKILL_JOB(jobinfo);
    local str = ScpArgMsg("JobClassSelect") .. " : {@st41}'" .. GET_JOB_NAME(jobinfo, GETMYPCGENDER()) .. "'{/}";
    if Iscompanionride == true then
        str = str .. "{nl}" .. ScpArgMsg("CHANGEJOB_COMPANIONSKILL_GUID");
    end
    str = str .. ScpArgMsg("Auto__{nl}JeongMalLo_JinHaengHaSiKessSeupNiKka?");
    ui.MsgBox(str, yesScp, "None");

    CJ_CLICK_CHANGEJOBBUTTON_OLD(frame, slot, argStr, argNum)
end
