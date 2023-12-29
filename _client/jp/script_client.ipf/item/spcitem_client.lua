--- scpitem_client.lua

function SPCI_DAGGER_MULTIPLE_HIT_C(actor, skill, hitInfo, additionalInfo)
	
	if hitInfo.clientSkillID == 10 or hitInfo.clientSkillID == 20 then
		additionalInfo.multipleHitCount = 2;
	end
end

function SCR_USE_EVENT_PICTURE_ITEM(invItem)
	local itemobj = GetIES(invItem:GetObject());
	EVENT_PICTURE_OPEN(ui.GetFrame("event_picture"), itemobj.StringArg, itemobj.NumberArg1, itemobj.NumberArg2);
end

function REGISTER_EXP_ORB_ITEM(invItem)
    local itemobj = invItem:GetIESID();
    item.RegExpOrbItem(itemobj);
end

function REGISTER_SUB_EXP_ORB_ITEM(invItem)
    local itemobj = invItem:GetIESID();
    item.RegSubExpOrbItem(itemobj);
end

function SCR_BARRACK_CREATE_FAIRY_GUILTY(handle)
	SCR_CREATE_FAIRY(handle, "guilty");
end

function SCR_CREATE_FAIRY(ownerHandle, monName)
	local ownerActor = world.GetActor(ownerHandle);
	local monActor = ownerActor:GetClientMonster():GetClientMonsterByName(monName);
	if monActor == nil then
		local ownerPos = ownerActor:GetPos();
		ownerActor:GetClientMonster():ClientMonsterToPos(monName, "STD", ownerPos.x, ownerPos.y, ownerPos.z, 0, 0);
		monActor = ownerActor:GetClientMonster():GetClientMonsterByName(monName);
		local monHandle = monActor:GetHandleVal();
		FollowToActor(monHandle, ownerHandle, "None", 15.0, 30.0, 3.0, 1, 0.1);
		StartImitatingAnimation(monHandle, ownerHandle);
	end
end

function SCR_REMOVE_FAIRY(ownerHandle, monName)
	local ownerActor = world.GetActor(ownerHandle);
	ownerActor:GetClientMonster():DeleteClientMonster(monName, 0.75);
end

function SCR_CREATE_FAIRY_GROUND(owner_handle, mon_name)
	local owner_actor = world.GetActor(owner_handle); 
	local mon_actor = owner_actor:GetClientMonster():GetClientMonsterByName(mon_name);
	if mon_actor == nil then
		local owner_pos = owner_actor:GetPos();
		owner_actor:GetClientMonster():ClientMonsterToPos(mon_name, "STD", owner_pos.x, owner_pos.y, owner_pos.z, 0, 0);
		mon_actor = owner_actor:GetClientMonster():GetClientMonsterByName(mon_name);
		local mon_handle = mon_actor:GetHandleVal();
		FollowToActorGround(mon_handle, owner_handle, "None", 0, 0, 0, 1, 0.1, 20);
		StartImitatingAnimation(mon_handle, owner_handle);
	end
end

function SCR_REMOVE_FAIRY_GROUND(owner_handle, mon_name)
	local ownerActor = world.GetActor(owner_handle);
	ownerActor:GetClientMonster():DeleteClientMonster(mon_name, 0.75);
end


function EVENT_1909_ANCIENT_CHECK_REGISTER(invItem)
end


function EVENT_1909_ANCIENT_REGISTER_CARD_C(itemGuid)
end

function ANCIENT_SCROLL_CHECK_MSG(invItem)
end

function ANCIENT_SCROLL_EMPTY_USE(iesID)
end

-- doll_lucy
function SCR_BARRACK_CREATE_FAIRY_DOLL_LUCY(handle)
	SCR_CREATE_FAIRY(handle, "doll_lucy");
end

-- doll_tiny
function SCR_BARRACK_CREATE_FAIRY_DOLL_TINY(handle)
	SCR_CREATE_FAIRY(handle, "doll_tiny");
end

-- doll_gabia
function SCR_BARRACK_CREATE_FAIRY_DOLL_GABIA(handle)
	SCR_CREATE_FAIRY(handle, "doll_gabia");
end

function SCR_BARRACK_CREATE_FAIRY_DOLL_HAUBERK(handle)
	SCR_CREATE_FAIRY(handle, "doll_hauberk");
end

function SCR_BARRACK_CREATE_FAIRY_DOLL_VAKARINE(handle)
	SCR_CREATE_FAIRY(handle, "doll_vakarine");
end

function SCR_BARRACK_CREATE_FAIRY_DOLL_LAIMA(handle)
	SCR_CREATE_FAIRY(handle, "doll_laima");
end

function SCR_BARRACK_CREATE_FAIRY_DOLL_MEDEINA(handle)
	SCR_CREATE_FAIRY(handle, "doll_medeina");
end

function SCR_BARRACK_CREATE_FAIRY_DOLL_ZEMINA(handle)
	SCR_CREATE_FAIRY(handle, "doll_zemina");
end

function SCR_BARRACK_CREATE_FAIRY_DOLL_ZANAS(handle)
	SCR_CREATE_FAIRY(handle, "doll_zanas");
end

function SCR_BARRACK_CREATE_FAIRY_DOLL_EFFECT_EP13RAINCOAT(handle)
	SCR_CREATE_FAIRY_GROUND(handle, "effect_ep13raincoat");
end

function SCR_BARRACK_CREATE_FAIRY_SANTA_GUILTY(handle)
	SCR_CREATE_FAIRY(handle, "doll_santa_guilty");
end

function SCR_BARRACK_CREATE_FAIRY_DOLL_SUCCUBUS(handle)
	SCR_CREATE_FAIRY(handle, "doll_succubus");
end

function SCR_BARRACK_CREATE_FAIRY_DOLL_PAULIUS(handle)
	SCR_CREATE_FAIRY(handle, "doll_paulius");
end

function SCR_BARRACK_CREATE_FAIRY_FURRY_GUILTY(handle)
	SCR_CREATE_FAIRY(handle, "doll_furry_guilty");
end

function SCR_BARRACK_CREATE_FAIRY_JELLYZELE(handle)
	SCR_CREATE_FAIRY(handle, "doll_jellyzele");
end

function SCR_BARRACK_CREATE_FAIRY_LITTLE_GRAICIER(handle)
	SCR_CREATE_FAIRY(handle, "doll_little_glacier");
end

-- wing item effect offset
function SCR_USE_COMPANION_OFFSET(handle)
	local obj = world.GetActor(handle);
	if obj ~= nil then
		obj:GetAnimEvent():SetUseCompanionOffSet(true);
    end
end



function ANCIENT_CARD_CHECK_REGISTER(invItem)
	local itemobj = GetIES(invItem:GetObject());
	local monClassName = TryGetProp(itemobj,'StringArg')
	local monCls = GetClass("Monster",monClassName)
	local monName = monCls.Name

	local color = ""
	local info = GetClass('Ancient_Info', monClassName);
	if info.Rarity == 1 then
		color = "{#ffffff}"
	elseif info.Rarity == 2 then
		color = "{#0e7fe8}"
	elseif info.Rarity == 3 then
		color = "{#d92400}"
	elseif info.Rarity == 4 then
		color = "{#ffa800}"
	end
	local str = ScpArgMsg("AncientMonRegItemUse","monName",monName,"color",color)
	local guid = invItem:GetIESID()
	local yesScp = string.format("ANCIENT_CARD_REGISTER_C(\"%s\")", guid);
	ui.MsgBox(str, yesScp, "None");
end

function ANCIENT_CARD_REGISTER_C(itemGuid)
	local invItem = session.GetInvItemByGuid(itemGuid)
	
	if nil == invItem then
		return;
	end
	
	if true == invItem.isLockState then
		ui.SysMsg(ClMsg("MaterialItemIsLock"));
		return;
	end
	
	item.UseByGUID(invItem:GetIESID());
end
