function BARRACK_BUY(buyMap)
	local cls = GetClass("BarrackMap", buyMap);

	local msgBoxStr = ClMsg("ReallyBuy?") .. "{nl}" .. cls.Price .. " " .. "TP";

	local yesScp = string.format("EXEC_BUY_BARRACK(\"%s\")", buyMap);
	if GET_CASH_TOTAL_POINT_C() < cls.Price then
		ui.MsgBox(ClMsg("NotEnoughMedal"));		
	else
		ui.MsgBox(msgBoxStr, yesScp, "None");
	end

end