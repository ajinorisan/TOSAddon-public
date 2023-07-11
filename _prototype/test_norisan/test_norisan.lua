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

    addon:RegisterMsg("GAME_START_3SEC", "TEST_NORISAN_NEWFRAME_INIT")
    -- addon:RegisterMsg("GAME_START_3SEC", "TEST_NORISAN_NEWFRAME_INIT")
    --[[
    local cjframe = ui.GetFrame("changejob")
    -- CHAT_SYSTEM("test1")
    local btn = GET_CHILD_RECURSIVELY(cjframe, 'class_select');
    -- CHAT_SYSTEM("test2")
    if btn ~= nil then
        btn:SetEventScript(ui.LBUTTONDOWN, "test_norisan_cj_click_changejobbutton")
        -- CHAT_SYSTEM("test3")
    end
    -- acutil.SetupHook(test_norisan_cj_click_changejobbutton, "CJ_CLICK_CHANGEJOBBUTTON")
    ]]
end

function TEST_NORISAN_NEWFRAME_INIT()

    local newframe = ui.CreateNewFrame("notice_on_pc", "my_frame", 0, 0, 110, 50)
    AUTO_CAST(newframe)
    newframe:SetOffset(1380, 15)
    newframe:ShowWindow(1)
    newframe:SetSkinName("None")
    local btn = newframe:CreateOrGetControl("button", "myButton", 0, 0, 50, 50)
    AUTO_CAST(btn)
    btn:SetImage("config_button_normal")
    btn:SetEventScript(ui.LBUTTONDOWN, "test_norisan_console_init")
    local btn2 = newframe:CreateOrGetControl("button", "btn2", 60, 0, 50, 50)
    AUTO_CAST(btn2)
    btn2:SetEventScript(ui.LBUTTONDOWN, "test_norisan_btnon")
end

function test_norisan_console_init()
    local console = ui.GetFrame("developerconsole")
    if console:IsVisible() == 0 then
        console:ShowWindow(1)
    else
        console:ShowWindow(0)
    end
end

function test_norisan_btnon()
    local equipItemList = session.GetEquipItemList()
    for i = 0, equipItemList:Count() - 1 do
        local equipItem = equipItemList:GetEquipItemByIndex(i)
        local itemObj = GetIES(equipItem:GetObject())
        print(i)
        -- print(equipItem:GetIESID())
        print(itemObj.ClassName)
        local slotName = itemObj.EquipXpGroup
        print("Slot Name: " .. slotName)
        -- print("---------------")
    end
end

function test_norisan_cj_click_changejobbutton()

    --[[
    local summonedPet = session.pet.GetSummonedPet();
    if summonedPet ~= nil then
        control.SummonPet(0, 0, 0)
    end

    session.job.ReqUnEquipItemAll()
    CHAT_SYSTEM("test")
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

    -- CJ_CLICK_CHANGEJOBBUTTON_OLD(frame, slot, argStr, argNum)
    ]]
end
