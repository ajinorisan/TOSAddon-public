-- dofile("../data/addon_d/dungeonrpcharger/dungeonrpcharger.lua");
-- areas defined
-- v2.0.0 
-- v2.0.1 大人の事情でレリックオフ機能除去
local author = 'meldavy'
local addonName = 'dungeonrpcharger'
local ver = "2.0.1"

_G['ADDONS'] = _G['ADDONS'] or {}
_G['ADDONS'][author] = _G['ADDONS'][author] or {}
_G['ADDONS'][author][addonName] = _G['ADDONS'][author][addonName] or {}

-- get a pointer to the area
local DungeonRPCharger = _G['ADDONS'][author][addonName]
local acutil = require('acutil')
local json = require('json')

DungeonRPCharger.SettingsFileLoc = string.format('../addons/%s/settings.json', addonName)

DungeonRPCharger.Settings = {
    Position = {
        X = 0,
        Y = 0
    }
};

DungeonRPCharger.ischecked = 0

DungeonRPCharger.Default = {
    Height = 0,
    Width = 0,
    IsVisible = 1,
    Movable = 0,
    Enabled = 0 -- Hittest
};

local base = {}
-- g.sellcount = 0

function DungeonRPCharger.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

-- local icon = nil
-- DUNGEONRPCHARGER_CHECK_ALL_SLOTS(icon)
-- constants
DungeonRPCharger.EctoniteClassName = 'misc_Ectonite';
DungeonRPCharger.EctoniteMercClassName = 'misc_Ectonite_Care';

DungeonRPCharger.BuffIDs = {
    [40049] = 1, -- Res Sacrae Liberation
    [40065] = 1, -- RP Charge Limit
    [40067] = 1, -- RP Charge Limit (Guild Quest)
    [40070] = 1 -- RP Charge Limit
}
DungeonRPCharger.RelicReleaseBuffID = 40049;
DungeonRPCharger.MinimumThreshold = 150;
DungeonRPCharger.MapIDList = {11239, -- 1F
11242, -- 2F
11244 -- 3F
}

function DUNGEONRPCHARGER_ON_INIT(addon, frame)
    DungeonRPCharger.addon = addon;
    DungeonRPCharger.frame = frame;
    -- load settings
    if not DungeonRPCharger.Loaded then
        local t, err = acutil.loadJSON(DungeonRPCharger.SettingsFileLoc, DungeonRPCharger.Settings);
        if err then
        else
            DungeonRPCharger.Settings = t;
            DungeonRPCharger.Loaded = true;
        end
    end
    -- initialize frame
    DUNGEONRPCHARGER_ON_FRAME_INIT(frame)

    addon:RegisterMsg('BUFF_ADD', 'DUNGEONRPCHARGER_ON_BUFF_ADD');
    addon:RegisterMsg('BUFF_REMOVE', 'DUNGEONRPCHARGER_ON_BUFF_REMOVE');
    local curMapID = session.GetMapID()
    -- check if map is rechargeable
    --[[if (DungeonRPCharger:IsRechargeableMap(curMapID) == 1) then
        CHAT_SYSTEM(DungeonRPCharger:IsRechargeableMap(curMapID))
        addon:RegisterMsg('FPS_UPDATE', 'DUNGEONRPCHARGER_CHECK_ALL_SLOTS');
        addon:RegisterMsg('FPS_UPDATE', 'DUNGEONRPCHARGER_ISCHECKED');
    end]]
    -- DungeonRPCharger.SetupHook(DUNGEONRPCHARGER_ICON_USE, "ICON_USE")
end

function DUNGEONRPCHARGER_CHECK_ALL_SLOTS()
    -- CHAT_SYSTEM(DungeonRPCharger.ischecked)
    local frame = ui.GetFrame("quickslotnexpbar")
    if not frame then
        return
    end

    local buff = info.GetBuff(session.GetMyHandle(), DungeonRPCharger.RelicReleaseBuffID)
    -- CHAT_SYSTEM(tostring(DungeonRPCharger.ischecked))

    local slotCount = 40
    if DungeonRPCharger.ischecked == 1 then
        -- CHAT_SYSTEM(DungeonRPCharger.ischecked)
        for i = 0, slotCount - 1 do
            local slot = tolua.cast(frame:GetChildRecursively("slot" .. i + 1), "ui::CSlot")
            if slot and slot:GetIcon() then
                local iconInfo = slot:GetIcon():GetInfo()

                local iconName = iconInfo:GetImageName()
                if iconName == "icon_common_relic_release" and buff ~= nil then
                    local icon = tolua.cast(frame:GetChildRecursively("slot" .. i + 1), "ui::CSlot"):GetIcon()

                    ICON_USE(icon)
                end
            end
        end
    end
end

function DUNGEONRPCHARGER_ON_BUFF_ADD(frame, msg, argStr, classID)
    if (classID == DungeonRPCharger.RelicReleaseBuffID) then
        frame:RunUpdateScript("DUNGEONRPCHARGER_ON_TICK", 1)
    end

end

function DUNGEONRPCHARGER_ON_BUFF_REMOVE(frame, msg, argStr, classID)
    if (DungeonRPCharger.BuffIDs[classID] == 1) then
        frame:StopUpdateScript("DUNGEONRPCHARGER_ON_TICK")
        -- try recharge relic
        DungeonRPCharger:RechargeRelicMerc();
        DungeonRPCharger:RechargeRelic();
    end
end

function DUNGEONRPCHARGER_ON_TICK(frame)
    local buff = info.GetBuff(session.GetMyHandle(), DungeonRPCharger.RelicReleaseBuffID);
    if buff == nil then
        return 0;
    end

    local pc = GetMyPCObject()
    local cur_rp, max_rp = shared_item_relic.get_rp(pc)
    -- only attempt auto recharge if rp is less than or equal to 150
    if (cur_rp <= DungeonRPCharger.MinimumThreshold) then
        -- recharge relic
        DungeonRPCharger:RechargeRelicMerc();
        if (cur_rp <= DungeonRPCharger.MinimumThreshold) then
            DungeonRPCharger:RechargeRelic();
        end
    end

    return 1;
end

function DungeonRPCharger.RechargeRelicMerc(self)
    local curMapID = session.GetMapID()
    -- check if map is rechargeable
    if (DungeonRPCharger:IsRechargeableMap(curMapID) == 0) then
        return;
    end
    local pc = GetMyPCObject()
    local cur_rp, max_rp = shared_item_relic.get_rp(pc)
    session.ResetItemList()
    local mat_item = session.GetInvItemByName('misc_Ectonite_Care')
    -- do nothing if no ectonite in inv
    if mat_item == nil then
        return
    end
    -- do nothing if ectonite is locked
    if mat_item.isLockState == true then
        return
    end

    local item_idx = mat_item:GetIESID()
    local cur_count = mat_item.count
    local recharge_count = (max_rp - cur_rp) // 10

    if cur_count ~= nil and cur_count > 0 then
        if (recharge_count > cur_count) then
            recharge_count = cur_count
        end
        session.AddItemID(item_idx, recharge_count)
        local result_list = session.GetItemIDList()
        item.DialogTransaction('RELIC_CHARGE_RP', result_list)
    end
end

function DungeonRPCharger.RechargeRelic(self)
    local curMapID = session.GetMapID()
    -- check if map is rechargeable
    if (DungeonRPCharger:IsRechargeableMap(curMapID) == 0) then
        return;
    end
    local pc = GetMyPCObject()
    local cur_rp, max_rp = shared_item_relic.get_rp(pc)
    session.ResetItemList()
    local mat_item = session.GetInvItemByName('misc_Ectonite')
    -- do nothing if no ectonite in inv
    if mat_item == nil then
        return
    end
    -- do nothing if ectonite is locked
    if mat_item.isLockState == true then
        return
    end

    local item_idx = mat_item:GetIESID()
    local cur_count = mat_item.count
    local recharge_count = (max_rp - cur_rp) // 10

    if cur_count ~= nil and cur_count > 0 then
        if (recharge_count > cur_count) then
            recharge_count = cur_count
        end
        session.AddItemID(item_idx, recharge_count)
        local result_list = session.GetItemIDList()
        item.DialogTransaction('RELIC_CHARGE_RP', result_list)
    end
end

function DungeonRPCharger.IsRechargeableMap(self, id)
    -- check if map is city
    local mapCls = GetClassByType('Map', id)
    if TryGetProp(mapCls, 'MapType', 'None') == 'City' then
        return 1
    end
    -- check if map is other rechargable map
    if (DungeonRPCharger:IsItemInArray(id, DungeonRPCharger.MapIDList) > -1) then
        return 1
    end
    return 0
end

function DungeonRPCharger.IsItemInArray(self, value, array)
    for index = 1, #array do
        if array[index] == value then
            return index
        end
    end
    return -1
end

function DUNGEONRPCHARGER_ON_FRAME_INIT(frame)
    -- enable frame reposition through drag and move
    -- frame:EnableMove(DungeonRPCharger.Default.Movable);
    -- frame:EnableHitTest(DungeonRPCharger.Default.Enabled);
    frame:SetEventScript(ui.LBUTTONUP, "DUNGEONRPCHARGER_END_DRAG");

    -- draw the frame
    --[[ frame:SetSkinName('None');
    frame:SetPos(1600, 0)
    frame:Resize(30, 30)
    local checkbox = frame:CreateOrGetControl('checkbox', 'checkbox', 0, 2, 30, 30)
    AUTO_CAST(checkbox)
    checkbox:SetTextTooltip("チェックすると自動でレリックOFF{nl}Automatic relic off when checked.")]]

    -- frame:RunUpdateScript("DUNGEONRPCHARGER_ISCHECKED", 1.0)
    -- set default position of frame
    -- frame:Move(DungeonRPCharger.Settings.Position.X, DungeonRPCharger.Settings.Position.Y);
    -- frame:SetOffset(DungeonRPCharger.Settings.Position.X, DungeonRPCharger.Settings.Position.Y);

    -- set default size and visibility
    -- frame:Resize(DungeonRPCharger.Default.Width, DungeonRPCharger.Default.Height);
    -- frame:ShowWindow(DungeonRPCharger.Default.IsVisible);
    frame:ShowWindow(1)
end

function DUNGEONRPCHARGER_ISCHECKED()
    local frame = ui.GetFrame(addonName)
    local checkbox = GET_CHILD_RECURSIVELY(frame, 'checkbox')
    AUTO_CAST(checkbox)
    local ischeck = checkbox:IsChecked();

    if ischeck == 1 then
        DungeonRPCharger.ischecked = 1

    elseif ischeck == 0 then
        DungeonRPCharger.ischecked = 0

    end
    -- return 1
end

function DUNGEONRPCHARGER_END_DRAG(frame, ctrl)
    DungeonRPCharger.Settings.Position.X = DungeonRPCharger.frame:GetX();
    DungeonRPCharger.Settings.Position.Y = DungeonRPCharger.frame:GetY();
    DUNGEONRPCHARGER_SAVE_SETTINGS();
end

function DUNGEONRPCHARGER_SAVE_SETTINGS()
    acutil.saveJSON(DungeonRPCharger.SettingsFileLoc, DungeonRPCharger.Settings);
end
