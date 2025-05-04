-- v1.0.0 キャラが最後に使ってたペットをCC時に召喚。街だけで動きます。
-- v1.0.1 呼び出し安定しなかったのでディレイ見直し、ペットアイコンを画面上部に設置
-- v1.0.2 動いてたのが不思議なくらい雑なコードだったので見直し。ペット入れ替えた時のアイコン表示修正。
-- v1.0.3 コンパニオンフレームの呼び出しを更に遅延
-- v1.0.4 なんかクライアント関数だと呼べなくなってたので修正
-- v1.0.5 呼んでるペット表示機能削除。シンプルな挙動に変更
local addonName = "AUTO_PET_SUMMON"
local addon_name_lower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.5"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local json = require('json')

function g.mkdir_new_folder()
    local function create_folder(folder_path, file_path)
        local file = io.open(file_path, "r")
        if not file then
            os.execute('mkdir "' .. folder_path .. '"')
            file = io.open(file_path, "w")
            if file then
                file:write("A new file has been created")
                file:close()
            end
        else
            file:close()
        end
    end

    local folder = string.format("../addons/%s", addon_name_lower)
    local file_path = string.format("../addons/%s/mkdir.txt", addon_name_lower)
    create_folder(folder, file_path)

    g.active_id = session.loginInfo.GetAID()
    local user_folder = string.format("../addons/%s/%s", addon_name_lower, g.active_id)
    local user_file_path = string.format("../addons/%s/%s/mkdir.txt", addon_name_lower, g.active_id)
    create_folder(user_folder, user_file_path)

    g.settings_path = string.format("../addons/%s/%s/settings.json", addon_name_lower, g.active_id)
end
g.mkdir_new_folder()

function g.get_map_type()
    local map_name = session.GetMapName()
    local map_cls = GetClass("Map", map_name)
    local map_type = map_cls.MapType
    return map_type
end

function g.save_settings()
    local function save_json(path, tbl)
        local file = io.open(path, "w")
        local str = json.encode(tbl)

        file:write(str)
        file:close()
    end
    save_json(g.settings_path, g.settings)
end

function g.load_settings()

    local function load_json(path)

        local file = io.open(path, "r")
        if file then
            local content = file:read("*all")
            file:close()
            local table = json.decode(content)
            return table
        else
            return nil
        end
    end

    local settings = load_json(g.settings_path)

    if not settings then
        settings = {}
    end

    if not settings[g.cid] then
        settings[g.cid] = {
            iesid = "",
            clsid = 0
        }
    end

    g.settings = settings
    g.save_settings()
end

function AUTO_PET_SUMMON_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    g.lang = option.GetCurrentCountry()
    g.cid = session.GetMySession():GetCID()

    if g.get_map_type() == "City" then
        g.load_settings()
        addon:RegisterMsg("GAME_START_3SEC", "AUTO_PET_SUMMON_COMPANION")
    end
end

function AUTO_PET_SUMMON_COMPANION(frame, msg, str, num)
    if g.settings[g.cid].clsid ~= 0 then
        control.SummonPet(g.settings[g.cid].clsid, g.settings[g.cid].iesid, 0)
    end
    frame:SetSkinName("None")
    frame:SetTitleBarSkin("None")
    frame:Resize(40, 40)
    local handle = session.GetMyHandle();
    FRAME_AUTO_POS_TO_OBJ(frame, handle, -frame:GetWidth() / 2 + 40, -140);
    -- frame:SetPos(1200, 700)
    local gbox = frame:CreateOrGetControl("groupbox", "gbox", 0, 0, 40, 40)
    AUTO_CAST(gbox)
    frame:RunUpdateScript("AUTO_PET_SUMMON_PERSONAL_SAVE_RESERVE", 1.0)
    gbox:RunUpdateScript("AUTO_PET_SUMMON_PET_FRAME_INIT", 1.5)
end

function AUTO_PET_SUMMON_PERSONAL_SAVE_RESERVE(frame)

    local summonedPet = session.pet.GetSummonedPet()
    if not summonedPet and g.settings[g.cid].clsid == 0 then
        return 1
    elseif summonedPet and g.settings[g.cid].clsid ~= 0 then
        return 1
    elseif not summonedPet and g.settings[g.cid].clsid ~= 0 then
        g.settings[g.cid].iesid = ""
        g.settings[g.cid].clsid = 0
    elseif summonedPet and g.settings[g.cid].clsid == 0 then
        local iesid = tostring(summonedPet:GetStrGuid())
        local obj = summonedPet:GetObject()
        local clsid = GetIES(obj).ClassID
        g.settings[g.cid].iesid = iesid
        g.settings[g.cid].clsid = clsid
    end
    g.save_settings()
    return 1
end

function AUTO_PET_SUMMON_PET_FRAME_INIT(gbox)

    local frame = gbox:GetParent()
    local summonedPet = session.pet.GetSummonedPet()
    if not summonedPet then
        frame:SetVisible(0)
        gbox:ShowWindow(0)
        return
    end

    local pet_icon = gbox:CreateOrGetControl("picture", "pet_icon", 0, 0, 40, 40)
    AUTO_CAST(pet_icon)

    local classobj = GetIES(summonedPet:GetObject())
    pet_icon:SetImage(classobj.Icon)
    pet_icon:SetEnableStretch(1)
    frame:SetVisible(1)
    gbox:ShowWindow(1)
    gbox:RunUpdateScript("AUTO_PET_SUMMON_FRAME_CLOSE", 3.0)
end

function AUTO_PET_SUMMON_FRAME_CLOSE(gbox)
    local frame = gbox:GetParent()
    frame:SetVisible(0)
    gbox:ShowWindow(0)
end

--[[function AUTO_PET_SUMMON_COMPANION_SUMMON(frame)
    local summonedPet = session.pet.GetSummonedPet()

    if summonedPet == nil then
        local petList = session.pet.GetPetInfoVec()

        for i = 0, petList:size() - 1 do

            local info = petList:at(i)
            local obj = GetIES(info:GetObject())
            local id = obj.ClassID
            local frame = ui.GetFrame("companionlist")
            local setName = "_CTRLSET_" .. i
            local ctrlset = GET_CHILD_RECURSIVELY(frame, setName)

            if ctrlset ~= nil then
                local slot = GET_CHILD_RECURSIVELY(ctrlset, "slot")
                local icon = slot:GetIcon()
                local iconInfo = icon:GetInfo()
                local petGuidStr = iconInfo:GetIESID()
                if petGuidStr == g.personal.pet_iesid then
                    ICON_USE(icon)
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

local acutil = require("acutil")

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName

    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName]
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

function AUTO_PET_SUMMON_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame

    local pc = GetMyPCObject()
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
    acutil.setupEvent(addon, "control.SummonPet", "AUTO_PET_SUMMON_PET_FRAME_INIT")
    acutil.setupEvent(addon, "HOTKEY_UNSUMMON_COMPANION", "AUTO_PET_SUMMON_PET_RELEASE")
    acutil.setupEvent(addon, "COMPANIONLIST_OPEN", "AUTO_PET_SUMMON_COMPANIONLIST_OPEN")
end

function AUTO_PET_SUMMON_COMPANIONLIST_OPEN(frame, msg)
    local clframe = ui.GetFrame("companionlist")
    if g.frameW ~= nil then
        clframe:Resize(g.frameW, g.frameH)
    end
end

function AUTO_PET_SUMMON_COMPANION(frame)

    if g.personal.pet_clsid ~= 0 then
        local clframe = ui.GetFrame("companionlist")
        g.frameW = clframe:GetWidth()
        g.frameH = clframe:GetHeight()
        clframe:Resize(0, 0)
        ON_OPEN_COMPANIONLIST()
        frame:RunUpdateScript("AUTO_PET_SUMMON_COMPANION_SUMMON", 1.0)
    else
        local frame = ui.GetFrame("companionlist")
        frame:ShowWindow(1)
        UPDATE_COMPANIONLIST(frame)
        frame:RunUpdateScript("CLOSE_COMPANIONLIST", 10)

    end

end

function AUTO_PET_SUMMON_COMPANION_SUMMON(frame)
    local summonedPet = session.pet.GetSummonedPet()

    if summonedPet == nil then
        local petList = session.pet.GetPetInfoVec()

        for i = 0, petList:size() - 1 do

            local info = petList:at(i)
            local obj = GetIES(info:GetObject())
            local id = obj.ClassID
            local frame = ui.GetFrame("companionlist")
            local setName = "_CTRLSET_" .. i
            local ctrlset = GET_CHILD_RECURSIVELY(frame, setName)

            if ctrlset ~= nil then
                local slot = GET_CHILD_RECURSIVELY(ctrlset, "slot")
                local icon = slot:GetIcon()
                local iconInfo = icon:GetInfo()
                local petGuidStr = iconInfo:GetIESID()
                if petGuidStr == g.personal.pet_iesid then
                    ICON_USE(icon)
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
    frame:SetLayerLevel(10)
    frame:ShowWindow(1)

    local slot = frame:CreateOrGetControl("slot", "slot", 0, 0, 20, 20)
    AUTO_CAST(slot)
    slot:SetSkinName("None")
    slot:EnablePop(0)
    slot:EnableDrop(0)
    slot:EnableDrag(0)
    slot:SetEventScript(ui.RBUTTONUP, "AUTO_PET_SUMMON_PET_RELEASE")
    frame:ShowWindow(1)

    frame:RunUpdateScript("AUTO_PET_SUMMON_CONFIRMATION", 1.0)
end

function AUTO_PET_SUMMON_CONFIRMATION()
    local frame = ui.GetFrame("auto_pet_summon")
    local slot = GET_CHILD(frame, "slot")
    local summonedPet = session.pet.GetSummonedPet()
    if summonedPet ~= nil then
        local obj = summonedPet:GetObject()
        local classobj = GetIES(obj)

        local icon = CreateIcon(slot)
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

    local summonedPet = session.pet.GetSummonedPet()

    if summonedPet ~= nil then
        local loginCharID = info.GetCID(session.GetMyHandle())
        local pet_iesid = tostring(summonedPet:GetStrGuid())
        g.personal.pet_iesid = pet_iesid
        local obj = summonedPet:GetObject()
        local pet_clsid = GetIES(obj).ClassID
        g.personal.pet_clsid = pet_clsid

    else

        g.personal.pet_iesid = ""
        g.personal.pet_clsid = 0

    end
    AUTO_PET_SUMMON_PERSONAL_SAVE_SETTINGS()
end

function AUTO_PET_SUMMON_PERSONAL_SAVE_SETTINGS()

    acutil.saveJSON(g.personalFileLoc, g.personal)

end

function AUTO_PET_SUMMON_PET_RELEASE()
    control.SummonPet(0, 0, 0)

    local frame = ui.GetFrame("companionlist")
    frame:ShowWindow(1)
    UPDATE_COMPANIONLIST(frame)
    frame:RunUpdateScript("CLOSE_COMPANIONLIST", 10)
end]]

