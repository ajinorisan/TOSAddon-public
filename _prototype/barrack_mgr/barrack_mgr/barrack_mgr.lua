local addonName = "BARRACK_MGR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

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

function BARRACK_MGR_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    g.SetupHook(BARRACK_MGR_BARRACK_START_FRAME_OPEN, "BARRACK_START_FRAME_OPEN")
    g.SetupHook(BARRACK_MGR_SELECT_CHARBTN_LBTNUP, "SELECT_CHARBTN_LBTNUP")

    -- addon:RegisterMsg("GAME_START", "AUTO_REPAIR_FRAME_INIT")

end

function BARRACK_MGR_BARRACK_START_FRAME_OPEN(frame)
    if frame == nil then
        return;
    end

    local hidelogin = GET_CHILD_RECURSIVELY(frame, "hidelogin", "ui::CCheckBox");
    hidelogin:SetCheck(1)
    barrack.SetHideLogin(1);
end

function BARRACK_MGR_SELECT_CHARBTN_LBTNUP(parent, ctrl, cid, argNum)
    local pcPCInfo = session.barrack.GetMyAccount():GetByStrCID(cid);
    if pcPCInfo == nil then
        return;
    end

    local lbtnupScp = barrack.GetLBtnDownScript();
    if lbtnupScp == "COMPANION_SELECT_PC" then
        barrack.SetLBtnDownScript("None");
        local selActor = barrack.GetPCByID(cid);
        COMPANION_SELECT_PC(selActor);
        return;
    end

    local mainBox = parent:GetParent();
    barrack.SelectCharacterByCID(cid);
    CUR_SELECT_GUID = cid;

    -- local parentFrame = mainBox:GetTopParentFrame();
    -- UPDATE_SELECT_CHAR_SCROLL(parentFrame);
    UPDATE_PET_BTN_SELECTED();
end

