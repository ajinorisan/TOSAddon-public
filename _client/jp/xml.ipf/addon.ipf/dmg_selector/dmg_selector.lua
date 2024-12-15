local dmgfont_list;
local dmgeffect_list;
local function SET_DMGFONT_LIST(list)
	dmgfont_list = tolua.cast(list,"ui::CDropList");
end

local function SET_DMGEFFECT_LIST(list)
	dmgeffect_list = tolua.cast(list,"ui::CDropList");
end
local function GET_DMGFONT_LIST()
	return dmgfont_list;
end

function OPEN_DMGSELECTOR(frame)
	local dmgfontlist = GET_CHILD_RECURSIVELY(frame,"dmgfont_list");
	local dmgeffectlist = GET_CHILD_RECURSIVELY(frame,"dmgeffect_list");
	SET_DMGFONT_LIST(dmgfontlist);
	SET_DMGEFFECT_LIST(dmgeffectlist);
	DMGSELECTOR_ADDDROPLIST();
end

function DMGSELECTOR_ADDDROPLIST()
	local pc = GetMyPCObject();
	if pc == nil then
		return;
	end
	local aObj = GetMyAccountObj();
	if aObj == nil then
		return;
	end
	local etc = GetMyEtcObject();
	if etc == nil then
		return ;
	end	
	dmgfont_list:ClearItems();
    local damagefontlist, cnt = GetClassList('damage_font');
	local selectedItem = GetDamageFontSkin();
	if damagefontlist == nil then
		return;
    end
	local index = 0;
	for i = 0, cnt - 1 do
		local propName = string.format("dmg_font_00%d", i + 1);
		local time = TryGetProp(aObj, propName, "None");
		if (time ~= "None" and time ~= '0') or i == 0 then
			local cls = GetClassByIndexFromList(damagefontlist, i);
			local clsName = TryGetProp(cls, "Name");
        	dmgfont_list:AddItem(i, clsName);
			if (i + 1) == selectedItem then
				dmgfont_list:SelectItem(index);
			end
        	index = index + 1;
		end
	end

end



function DMGSELECTOR_FONT_SELECT(frame, ctrl)
    local key = ctrl:GetSelItemKey();
	SetDamageFontSkin(key);
end

function DMGSELECTOR_EFFECT_SELECT(frame, ctrl)
    local key = ctrl:GetSelItemKey();
	SetDamageEffectSkin(key);
end
