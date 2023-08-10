-- v1.0.2 on_init読み込み時にリペアーアイテムの数量確認
local addonName = "AUTO_REPAIR"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.2"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

function AUTO_REPAIR_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame

    CHAT_SYSTEM(addonNameLower .. " loaded")
    -- acutil.setupHook(AUTO_REPAIR_IS_DUR_UNDER_10PER, "IS_DUR_UNDER_10PER")
    acutil.setupHook(AUTO_REPAIR_DURNOTIFY_UPDATE, "DURNOTIFY_UPDATE")

    session.ResetItemList()
    local autorepair_item = session.GetInvItemByName('QuestReward_repairPotion_490')
    local repeatCount = autorepair_item.count
    if repeatCount <= 10 then
        -- 勝手に買う仕様にしよ
    end

end

function AUTO_REPAIR_DURNOTIFY_UPDATE(frame, notOpenFrame)
    if frame:IsVisible() == 0 then
        frame:ShowWindow(1);
    end

    local slotSet = GET_CHILD_RECURSIVELY(frame, 'slotlist', 'ui::CSlotSet')
    slotSet:ClearIconAll();

    for i = 0, slotSet:GetSlotCount() - 1 do
        local slot = slotSet:GetSlotByIndex(i);
        slot:ShowWindow(0);
    end

    local reverseIndex = slotSet:GetSlotCount() - 1;
    local equiplist = session.GetEquipItemList();
    local someflag = 1
    for i = 0, equiplist:Count() - 1 do
        local equipItem = equiplist:GetEquipItemByIndex(i);
        local slotcnt = imcSlot:GetFilledSlotCount(slotSet);
        local tempobj = equipItem:GetObject()
        if tempobj ~= nil then
            local obj = GetIES(tempobj);
            if IS_DUR_UNDER_10PER(obj) == true then
                local colorTone = "FF999900";
                if someflag < 2 then
                    someflag = 2
                    AUTO_REPAIR_ITEM_USE(obj)
                    -- ReserveScript(string.format("AUTO_REPAIR_ITEM_USE(\"%s\")", obj), 1.0)
                end
                if IS_DUR_ZERO(obj) == true then
                    colorTone = "FF990000";
                    if someflag < 3 then
                        someflag = 3
                    end
                end

                local slot = slotSet:GetSlotByIndex(reverseIndex - slotcnt)
                local icon = CreateIcon(slot);
                local iconImg = obj.Icon;
                local briquettingID = TryGetProp(obj, 'BriquettingIndex', 0);
                if briquettingID > 0 then
                    local briquettingItemCls = GetClassByType('Item', briquettingID);
                    iconImg = briquettingItemCls.Icon;
                end
                icon:Set(iconImg, 'Item', equipItem.type, reverseIndex - slotcnt, equipItem:GetIESID());
                icon:SetColorTone(colorTone);
                slot:ShowWindow(1);
            end
        end
    end

    local nowvalue = frame:GetValue();
    if someflag == 1 then
        frame:SetValue(1)
    elseif someflag == 2 and nowvalue < someflag then
        frame:SetValue(2)

        ui.SysMsg(ScpArgMsg('DurUnder30'));

    elseif someflag == 3 and nowvalue < someflag then
        frame:SetValue(3)
        ui.SysMsg(ScpArgMsg('DurUnder0'));

    end
end

function AUTO_REPAIR_ITEM_USE(obj)
    session.ResetItemList()
    local autorepair_item = session.GetInvItemByName('QuestReward_repairPotion_490')

    if autorepair_item == nil then
        -- ui.ChatMsg('[Lv.490]緊急修理キットがありません')
        -- ui.ChatMsg('[Lv.490] Urgent Repair Kit is not available.')
        CHAT_SYSTEM('[Lv.490]緊急修理キットがありません')
        CHAT_SYSTEM('[Lv.490] Urgent Repair Kit is not available.')
        return
    end

    if autorepair_item.isLockState == true then
        -- ui.SysMsg('[Lv.490]緊急修理キットがありません')
        -- ui.SysMsg('[Lv.490] Urgent Repair Kit is not available.')
        -- ui.ChatMsg(ClMsg('MaterialItemIsLock'))
        CHAT_SYSTEM(ClMsg('MaterialItemIsLock'))
        return
    end

    local repeatCount = math.min(autorepair_item.count, 4)
    -- ui.SysMsg("Automatic repair of equipment.") 表示が邪魔なので消した。v1.0.1
    -- ui.ChatMsg("Automatic repair of equipment.")
    CHAT_SYSTEM("Automatic repair of equipment.")

    for i = 0, repeatCount - 1 do
        if obj.Dur / obj.MaxDur < 0.9 then
            item.UseByGUID(autorepair_item:GetIESID())

        else
            break
        end
    end
    -- ReserveScript(string.format("AUTO_REPAIR_ITEM_USE(\"%s\")", obj), 1.0)

end

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
    local autorepair_item = session.GetInvItemByName('misc_Ectonite_Care')
    -- do nothing if no ectonite in inv
    if autorepair_item == nil then return end
    -- do nothing if ectonite is locked
    if autorepair_item.isLockState == true then return end

    local item_idx = autorepair_item:GetIESID()
    local cur_count = autorepair_item.count
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
