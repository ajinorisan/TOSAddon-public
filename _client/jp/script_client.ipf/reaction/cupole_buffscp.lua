---------------큐폴 소환하기
function CUPOLE_SUMMON_RES_SCRIPT(handle, index)
	if index >= 0 then
		local cls = GET_CUPOLE_CLASS_BY_INDEX(index)
		local clsname = TryGetProp(cls, "ClassName", "None")
		SCR_CREATE_CUPOLE(handle, clsname);
	else
		-- SCR_CREATE_CUPOLE(handle, clsname);
	end
end

--큐폴 불러오기
function CUPOLE_UNSUMMON_SCRIPT(handle, index)
	if index == -1 then
		local list, cnt = GetClassList("cupole_list");
		for i = 0 , cnt -1 do
			local Cls = GetClassByIndexFromList(list,i);
			if Cls ~= nil then
				local ClsName = TryGetProp(Cls, "ClassName", "None")
				SCR_REMOVE_CUPOLE(handle, ClsName);
			end
		end
	else
		local cls = GET_CUPOLE_CLASS_BY_INDEX(index)
		local clsname = TryGetProp(cls, "ClassName", "None")
		SCR_REMOVE_CUPOLE(handle, clsname);
	end
end