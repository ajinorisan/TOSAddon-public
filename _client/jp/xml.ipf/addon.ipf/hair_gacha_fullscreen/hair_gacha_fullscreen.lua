
function HAIR_GACHA_FULLSCREEN_INIT(addon, frame)
	
end

function HAIR_GACHA_FULLSCREEN_OPEN(frame)
	local itemcount = GET_CHILD_RECURSIVELY(frame,"itemcount")
	itemcount:ShowWindow(0)
end

function HAIR_GACHA_FULLSCREEN_DO_CLOSE(frame)
	frame:ShowWindow(0)
	
end

function HAIR_GACHA_FULLSCREEN_CLOSE(frame)
	local darkframe = ui.GetFrame("fulldark");
	local itemcount = darkframe:GetUserIValue("GACHA_FRAME_MAX_INDEX");
	local nextframeno = tonumber(frame:GetUserValue("GACHA_FRAME_INDEX") + 1)
	local nextframetype = frame:GetUserValue("GACHA_FRAME_TYPE")
	
	if nextframeno == 0 then
		return
	end

	if nextframeno <= itemcount then
		HAIR_GACHA_POP_BIG_FRAME(nextframeno, nextframetype)
	else
		DARK_FRAME_DO_CLOSE()
	end 
	
end