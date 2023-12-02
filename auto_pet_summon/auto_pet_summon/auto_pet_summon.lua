-- v1.0.0 キャラが最後に使ってたペットをCC時に召喚。街だけで動きます。
local addonName = "AUTO_PET_SUMMON"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

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

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

g.settings = {

    pet = {},
    pet_classid = {}
}

function AUTO_PET_SUMMON_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    AUTO_PET_SUMMON_LOAD_SETTINGS()

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        -- addon:RegisterMsg("GAME_START_3SEC", "AUTO_PET_SUMMON_PET_INIT")
        ReserveScript("AUTO_PET_SUMMON_PET_INIT()", 1.0)
    end
    addon:RegisterMsg("GAME_START_3SEC", "AUTO_PET_SUMMON_PET_FRAME_INIT")

end

function AUTO_PET_SUMMON_PET_FRAME_INIT()
    local frame = ui.GetFrame("auto_pet_summon")
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(10, 10)
    frame:SetPos(0, 0)
    frame:RunUpdateScript("AUTO_PET_SUMMON_PET_UPDATE", 1.0)
    frame:ShowWindow(1)

end

function AUTO_PET_SUMMON_PET_UPDATE()
    local frame = ui.GetFrame("auto_pet_summon")

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)
    if mapCls.MapType == "City" then
        local summonedPet = session.pet.GetSummonedPet();
        if summonedPet ~= nil then
            local petguid = tostring(summonedPet:GetStrGuid())

            if petguid ~= g.pet then
                AUTO_PET_SUMMON_PET_SAVE()
            end

        else
            AUTO_PET_SUMMON_PET_RELEASE()
        end

        return 1
    else
        return 0
    end

end

function AUTO_PET_SUMMON_PET_RELEASE()

    local loginCharID = info.GetCID(session.GetMyHandle())
    g.pet_classid = nil
    g.pet = nil

    g.settings.pet[loginCharID] = nil
    g.settings.pet_classid[loginCharID] = nil

    AUTO_PET_SUMMON_SAVE_SETTINGS()

end

function AUTO_PET_SUMMON_PET_SAVE()
    -- print("test")
    local summonedPet = session.pet.GetSummonedPet();
    local loginCharID = info.GetCID(session.GetMyHandle())

    if summonedPet ~= nil then
        -- print("test")
        local petguid = tostring(summonedPet:GetStrGuid())
        if g.settings.pet == nil then

            g.settings.pet = {}
        end
        -- print("test")
        g.settings.pet[loginCharID] = petguid
        local obj = summonedPet:GetObject();
        local classid = GetIES(obj).ClassID;
        -- print(tostring(classid))
        if g.settings.pet_classid == nil then
            g.settings.pet_classid = {}
        end
        g.settings.pet_classid[loginCharID] = classid
    end

    AUTO_PET_SUMMON_SAVE_SETTINGS()

end

function AUTO_PET_SUMMON_PET_INIT()
    local summonedPet = session.pet.GetSummonedPet();
    if summonedPet == nil then
        if g.pet_classid ~= nil and g.pet ~= nil then

            ReserveScript(string.format("HOTKEY_SUMMON_COMPANION(%d,%d)", g.pet_classid, g.pet), 1.0)
            return
        else
            return
        end
    else
        local petguid = tostring(summonedPet:GetStrGuid())
        -- print(tostring(petguid))
        if tostring(petguid) ~= tostring(g.pet) then
            control.SummonPet(0, 0, 0)
            ReserveScript(string.format("HOTKEY_SUMMON_COMPANION(%d,%d)", g.pet_classid, g.pet), 1.0)
            return
        else
            return
        end
    end
end

function AUTO_PET_SUMMON_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function AUTO_PET_SUMMON_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    local loginCharID = info.GetCID(session.GetMyHandle())

    if not settings then

        g.settings = {

            pet = {},
            pet_classid = {}
        }

        AUTO_PET_SUMMON_SAVE_SETTINGS()

        settings = g.settings
    end

    g.settings = settings

    local pet = g.settings.pet[loginCharID]

    g.pet = nil
    if pet ~= nil then
        g.pet = pet
    end

    local pet_classid = g.settings.pet_classid[loginCharID]

    g.pet_classid = nil
    if pet_classid ~= nil then
        g.pet_classid = pet_classid
    end

end

--[[local summonedPet = session.pet.GetSummonedPet();
    if summonedPet ~= nil then
        local petguid = tostring(summonedPet:GetStrGuid())
        -- print(tostring(summonedPet))

        local btn = frame:CreateOrGetControl("button", "pet_btn", 0, 0, 30, 25)
        AUTO_CAST(btn)
        btn:SetSkinName("None")

        local obj = summonedPet:GetObject();
        local classid = GetIES(obj);
        local imageName = GET_ITEM_ICON_IMAGE(classid);
        -- print(tostring(imageName))
        btn:SetText("{img " .. imageName .. " 25 25}")
        btn:SetTextTooltip(
            "{ol}Auto Pet Summon{nl}左クリックでキャラ毎に現在のペットを登録{nl}CC時に自動で呼び出します。{nl}右クリックで登録解除。" ..
                "{nl}Left click registers the current pet{nl}for each character and automatically recalls it at CC. {nl}Right click to unregister.")

        btn:SetEventScript(ui.LBUTTONUP, "AUTO_PET_SUMMON_PET_SAVE")
        btn:SetEventScript(ui.RBUTTONUP, "AUTO_PET_SUMMON_PET_RELEASE")
    end]]
