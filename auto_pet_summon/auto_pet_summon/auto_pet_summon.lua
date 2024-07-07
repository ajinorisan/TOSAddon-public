-- v1.0.0 キャラが最後に使ってたペットをCC時に召喚。街だけで動きます。
-- v1.0.1 呼び出し安定しなかったのでディレイ見直し、ペットアイコンを画面上部に設置
-- v1.0.2 動いてたのが不思議なくらい雑なコードだったので見直し。ペット入れ替えた時のアイコン表示修正。
-- v1.0.3 コンパニオンフレームの呼び出しを更に遅延
-- v1.0.4 なんかクライアント関数だと呼べなくなってたので修正
local addonName = "AUTO_PET_SUMMON"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.4"

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

function AUTO_PET_SUMMON_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    local pc = GetMyPCObject();
    local curMap = GetZoneName(pc)
    local mapCls = GetClass("Map", curMap)

    if mapCls.MapType == "City" then
        local loginCharID = info.GetCID(session.GetMyHandle())
        g.personalFileLoc = string.format('../addons/%s/%s.json', addonNameLower, loginCharID)
        local settings, err = acutil.loadJSON(g.personalFileLoc, g.personal)
        if not settings then
            settings = {
                pet_iesid = "",
                pet_clsid = 0
            }
        end

        g.personal = settings

        AUTO_PET_SUMMON_PERSONAL_SAVE_SETTINGS()

        addon:RegisterMsg("GAME_START_3SEC", "AUTO_PET_SUMMON_COMPANION")

    end
    acutil.setupEvent(addon, "control.SummonPet", "AUTO_PET_SUMMON_PET_FRAME_INIT");
    acutil.setupEvent(addon, "HOTKEY_UNSUMMON_COMPANION", "AUTO_PET_SUMMON_PET_RELEASE");
    acutil.setupEvent(addon, "COMPANIONLIST_OPEN", "AUTO_PET_SUMMON_COMPANIONLIST_OPEN");
end

function AUTO_PET_SUMMON_COMPANIONLIST_OPEN(frame, msg)
    local clframe = ui.GetFrame("companionlist");
    if g.frameW ~= nil then
        clframe:Resize(g.frameW, g.frameH)
    end
end

function AUTO_PET_SUMMON_COMPANION(frame)

    if g.personal.pet_clsid ~= 0 then
        local clframe = ui.GetFrame("companionlist");
        g.frameW = clframe:GetWidth()
        g.frameH = clframe:GetHeight();
        clframe:Resize(0, 0)
        ON_OPEN_COMPANIONLIST()
        frame:RunUpdateScript("AUTO_PET_SUMMON_COMPANION_SUMMON", 1.0)
    else
        local frame = ui.GetFrame("companionlist")
        frame:ShowWindow(1)
        UPDATE_COMPANIONLIST(frame);
        frame:RunUpdateScript("CLOSE_COMPANIONLIST", 10)

    end

end

function AUTO_PET_SUMMON_COMPANION_SUMMON(frame)
    local summonedPet = session.pet.GetSummonedPet();

    if summonedPet == nil then
        local petList = session.pet.GetPetInfoVec();

        for i = 0, petList:size() - 1 do

            local info = petList:at(i);
            local obj = GetIES(info:GetObject());
            local id = obj.ClassID
            local frame = ui.GetFrame("companionlist");
            local setName = "_CTRLSET_" .. i;
            local ctrlset = GET_CHILD_RECURSIVELY(frame, setName)

            if ctrlset ~= nil then
                local slot = GET_CHILD_RECURSIVELY(ctrlset, "slot");
                local icon = slot:GetIcon()
                local iconInfo = icon:GetInfo();
                local petGuidStr = iconInfo:GetIESID();
                if petGuidStr == g.personal.pet_iesid then
                    ICON_USE(icon);
                    CLOSE_COMPANIONLIST()
                    frame:Resize(g.frameW, g.frameH)
                    return 1
                end
            end
        end

    else
        AUTO_PET_SUMMON_PET_FRAME_INIT()

        return 0
    end
end

function AUTO_PET_SUMMON_PET_FRAME_INIT()
    local frame = ui.GetFrame("auto_pet_summon")
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(20, 20)
    frame:SetPos(700, 7)
    frame:SetLayerLevel(10);
    frame:ShowWindow(1)

    local slot = frame:CreateOrGetControl("slot", "slot", 0, 0, 20, 20)
    AUTO_CAST(slot)
    slot:SetSkinName("None");
    slot:EnablePop(0)
    slot:EnableDrop(0)
    slot:EnableDrag(0)
    slot:SetEventScript(ui.RBUTTONUP, "AUTO_PET_SUMMON_PET_RELEASE");
    frame:ShowWindow(1)

    frame:RunUpdateScript("AUTO_PET_SUMMON_CONFIRMATION", 1.0)
end

function AUTO_PET_SUMMON_CONFIRMATION()
    local frame = ui.GetFrame("auto_pet_summon")
    local slot = GET_CHILD(frame, "slot")
    local summonedPet = session.pet.GetSummonedPet();
    if summonedPet ~= nil then
        local obj = summonedPet:GetObject();
        local classobj = GetIES(obj)

        local icon = CreateIcon(slot);
        AUTO_CAST(icon)

        icon:SetImage(classobj.Icon)
        icon:SetTextTooltip("{ol}Right click to return the pet")
        frame:ShowWindow(1)
    else
        slot:ClearIcon()
    end
    frame:RunUpdateScript("AUTO_PET_SUMMON_PERSONAL_SAVE_RESERVE", 1.5)
end

function AUTO_PET_SUMMON_PERSONAL_SAVE_RESERVE(summonedPet)

    local summonedPet = session.pet.GetSummonedPet();

    if summonedPet ~= nil then
        local loginCharID = info.GetCID(session.GetMyHandle())
        local pet_iesid = tostring(summonedPet:GetStrGuid())
        g.personal.pet_iesid = pet_iesid
        local obj = summonedPet:GetObject();
        local pet_clsid = GetIES(obj).ClassID;
        g.personal.pet_clsid = pet_clsid

    else

        g.personal.pet_iesid = ""
        g.personal.pet_clsid = 0

    end
    AUTO_PET_SUMMON_PERSONAL_SAVE_SETTINGS()
end

function AUTO_PET_SUMMON_PERSONAL_SAVE_SETTINGS()

    acutil.saveJSON(g.personalFileLoc, g.personal);

end

function AUTO_PET_SUMMON_PET_RELEASE()
    control.SummonPet(0, 0, 0);

    local frame = ui.GetFrame("companionlist")
    frame:ShowWindow(1)
    UPDATE_COMPANIONLIST(frame);
    frame:RunUpdateScript("CLOSE_COMPANIONLIST", 10)
end

--[[

function AUTO_PET_SUMMON_PET_UPDATE()

    AUTO_PET_SUMMON_CONFIRMATION()

end
function AUTO_PET_SUMMON_ICON_USE(frame, msg)
    local object, reAction = acutil.getEventArgs(msg)
    local iconPt = object;
    local icon = tolua.cast(iconPt, 'ui::CIcon');
    local iconInfo = icon:GetInfo();
    print(type(iconInfo.type) .. ":" .. type(iconInfo:GetIESID()))
end
function AUTO_PET_SUMMON_COMPANIONLIST()
    local summonedPet = session.pet.GetSummonedPet();

    if summonedPet == nil then

        local frame = ui.GetFrame("companionlist")
        frame:ShowWindow(1)
        UPDATE_COMPANIONLIST(frame);

        ReserveScript("AUTO_PET_SUMMON_PETLIST_CLOSE()", 10)
        return
    else
        AUTO_PET_SUMMON_PET_FRAME_INIT()
    end
end


function AUTO_PET_SUMMON_RESERVE_COMPANIONLIST()
    if g.first == 0 then
        ReserveScript("AUTO_PET_SUMMON_COMPANIONLIST()", 5.0)
    else
        ReserveScript("AUTO_PET_SUMMON_COMPANIONLIST()", 1.0)
    end
end

function AUTO_PET_SUMMON_PET_INIT(pet, pet_classid)

    if pet ~= 0 and pet_classid ~= 0 then
        AUTO_PET_SUMMON_COMPANION(pet, pet_classid)

        return
    else
        AUTO_PET_SUMMON_COMPANIONLIST()
    end

end

function AUTO_PET_SUMMON_LOAD_SETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        -- CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end

    if not settings then

        g.settings = {

            pet = {},
            pet_classid = {}
        }

        AUTO_PET_SUMMON_SAVE_SETTINGS()

    end
    g.settings = settings
    if g.settings.pet == nil then
        g.settings.pet = {}
    end
    if g.settings.pet_classid == nil then
        g.settings.pet_classid = {}
    end

    if g.settings.pet_classid[loginCharID] == nil then
        g.settings.pet_classid[loginCharID] = 0
    end
    if g.settings.pet[loginCharID] == nil then
        g.settings.pet[loginCharID] = 0
    end

    local summonedPet = session.pet.GetSummonedPet();
    if summonedPet ~= nil then
        g.first = 1
        return
    end

    local pet = g.settings.pet[loginCharID]
    local pet_classid = g.settings.pet_classid[loginCharID]

    AUTO_PET_SUMMON_PET_INIT(pet, pet_classid)
end

function AUTO_PET_SUMMON_COMPANIONLIST()
    local summonedPet = session.pet.GetSummonedPet();
    g.first = 1
    if summonedPet == nil then

        local frame = ui.GetFrame("companionlist")
        frame:ShowWindow(1)
        UPDATE_COMPANIONLIST(frame);
        AUTO_PET_SUMMON_PET_FRAME_INIT()
        ReserveScript("AUTO_PET_SUMMON_PETLIST_CLOSE()", 10)
        return
    else
        AUTO_PET_SUMMON_PET_FRAME_INIT()
    end
end



function AUTO_PET_SUMMON_PET_SAVE(summonedPet)

    local loginCharID = info.GetCID(session.GetMyHandle())
    if summonedPet ~= nil then
        local petguid = tostring(summonedPet:GetStrGuid())
        g.settings.pet[loginCharID] = petguid

        local obj = summonedPet:GetObject();
        local classid = GetIES(obj).ClassID;
        g.settings.pet_classid[loginCharID] = classid
    else
        g.settings.pet[loginCharID] = 0
        g.settings.pet_classid[loginCharID] = 0
    end

    AUTO_PET_SUMMON_SAVE_SETTINGS()

end

function AUTO_PET_SUMMON_PETLIST_CLOSE()
    local frame = ui.GetFrame("companionlist")
    frame:ShowWindow(0)
end

function AUTO_PET_SUMMON_SAVE_SETTINGS()

    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function AUTO_PET_SUMMON_CONFIRMATION(summonedPet)
    local frame = ui.GetFrame("auto_pet_summon")
    local slot = GET_CHILD(frame, "slot")

    if summonedPet ~= nil then
        local obj = summonedPet:GetObject();
        local classobj = GetIES(obj)

        local icon = CreateIcon(slot);
        AUTO_CAST(icon)
        icon:SetTextTooltip(
            "右クリックでペットをバラックへ戻します。{nl}Right click to return the pet to the barracks.")
        icon:SetImage(classobj.Icon)

        frame:ShowWindow(1)
    else
        slot:ClearIcon()
    end

end

--[[local function child_name()
    local frame = ui.GetFrame("pet_info")
    local bg_icon = GET_CHILD_RECURSIVELY(frame, "item_0")
    local childNames = {}
    local childCount = bg_icon:GetChildCount()
    for i = 0, childCount - 1 do
        local child = bg_icon:GetChildByIndex(i)
        table.insert(childNames, child:GetName())
    end

    for i, name in ipairs(childNames) do
        print(name)
    end
end

function AUTO_PET_SUMMON_PET_RELEASE()

    local loginCharID = info.GetCID(session.GetMyHandle())
    g.pet_classid = nil
    g.pet = nil

    g.settings.pet[loginCharID] = 0
    g.settings.pet_classid[loginCharID] = 0
    local summonedPet = session.pet.GetSummonedPet();
    if summonedPet == nil then
        print("test")
        local frame = ui.GetFrame("companionlist")
        frame:ShowWindow(1)
        -- frame:RunUpdateScript("AUTO_PET_SUMMON_PET_UPDATE", 4.0)
        UPDATE_COMPANIONLIST(frame);
    end

    -- frame:SetOffset(800, 400)
    ReserveScript("AUTO_PET_SUMMON_PETLIST_CLOSE()", 10)
    local petframe = ui.GetFrame("auto_pet_summon_iconframe")
    petframe:RemoveAllChild();

end

function AUTO_PET_SUMMON_PET_INIT_CONTROL()
    local petInfo = session.pet.GetPetByGUID(g.pet)
    control.SummonPet(g.pet_classid, petInfo, 0);
    ReserveScript("AUTO_PET_SUMMON_PET_SAVE()", 1.5)
    ReserveScript("AUTO_PET_SUMMON_CONFIRMATION()", 4.0)

end
-- child_name()]]

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
