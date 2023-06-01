local addonName = "AUTO_REPAIR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "0.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

function AUTO_REPAIR_SAVE_SETTINGS()
    -- CHAT_SYSTEM("save")
    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function AUTO_REPAIR_LOADSETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        settings = g.settings
    end

    g.settings = settings
end

function AUTO_REPAIR_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    CHAT_SYSTEM(addonNameLower .. " loaded")
    acutil.setupHook(AUTO_REPAIR_IS_DUR_UNDER_10PER, "IS_DUR_UNDER_10PER")
end

function AUTO_REPAIR_IS_DUR_UNDER_10PER(itemobj)

    if itemobj == nil then
        return false
    end

    local Itemtype = itemobj.ItemType

    if Itemtype == nil then
        print('If This message has appeared, please tell its ClassId to Young.', itemobj.ClassID)
        return false;
    else
        if itemobj.ItemType ~= 'Equip' then
            return false
        end
    end

    if item.IsNoneItem(itemobj.ClassID) == 0 and itemobj.Dur / itemobj.MaxDur < 0.3 and itemobj.MaxDur ~= -1 then
        return true
    end

    return false
end

function AUTO_REPAIR_ITEM_USE()

    if AUTO_REPAIR_IS_DUR_UNDER_10PER() == false then
        return

    else

    end

end
--[[多分これいじったら使える
function REQUEST_SUMMON_BOSS_TX()
	local invFrame = ui.GetFrame("inventory");
	local itemGuid = invFrame:GetUserValue("REQ_USE_ITEM_GUID");
	local invItem = session.GetInvItemByGuid(itemGuid)
	
	if nil == invItem then
		return;
	end
	
	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end
	
	local stat = info.GetStat(session.GetMyHandle());		
	if stat.HP <= 0 then
		return;
	end
	
	local itemtype = invItem.type;
	local curTime = item.GetCoolDown(itemtype);
	if curTime ~= 0 then
		imcSound.PlaySoundEvent("skill_cooltime");
		return;
	end
	
	item.UseByGUID(invItem:GetIESID());
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
    local mat_item = session.GetInvItemByName('misc_Ectonite_Care')
    -- do nothing if no ectonite in inv
    if mat_item == nil then return end
    -- do nothing if ectonite is locked
    if mat_item.isLockState == true then return end

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
]]
