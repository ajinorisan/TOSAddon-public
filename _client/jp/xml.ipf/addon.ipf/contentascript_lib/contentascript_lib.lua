-- addon\contentascript_lib.lua


function GetUITutoProg(uituto)
	local cls = GetClass('UITutorial', uituto..'_0')
	if cls == nil then return 100 end

	local userType = TryGetProp(cls, 'UserType')
	if userType ~= 'All' then
		if session.shop.GetEventUserType() == 0 then return 100 end
	end

	if uituto == nil then return end

	local aObj = GetMyAccountObj()
	if aObj == nil then return end

	return TryGetProp(aObj, uituto)
end