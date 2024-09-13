-- barrack_startmap_select.lua --
function BARRACK_STARTMAP_SELECT_INIT()
	ui.SetEscapeScp("BARRACK_STARTMAP_SELECT_CANCEL");

	local frame = ui.GetFrame("barrack_startmap_select");
	BARRACK_STARTMAP_SELECT_RESET(frame);

	local bg = GET_CHILD_RECURSIVELY(frame, "bg");
	local text1 = GET_CHILD_RECURSIVELY(frame, "richtext_1");
	-- local text2 = GET_CHILD_RECURSIVELY(frame, "richtext_2");
	-- local text3 = GET_CHILD_RECURSIVELY(frame, "richtext_3");
	local btnSelect1 = GET_CHILD_RECURSIVELY(frame, "button_select_1");
	local btnSelect2 = GET_CHILD_RECURSIVELY(frame, "button_select_2");
	local btnCancel = GET_CHILD_RECURSIVELY(frame, "button_cancel");

	local selectTxt1 = ClMsg("Lv440KlaipeCastle") .. ClMsg("StartFromWhere");
	local selectTxt2 = ClMsg("Lv1KlaipeWest") .. ClMsg("StartFromWhere");

	-- text2:SetTextByKey("txt", selectTxt2);
	-- text3:SetTextByKey("cond", ClMsg("CondSelectStartFromKlaipeWest"));
	btnSelect1:SetTextByKey("txt", selectTxt1);
	btnSelect1:SetUserValue("SELECT_NUM", 0);
	btnSelect2:SetTextByKey("txt", selectTxt2);
	btnSelect2:SetUserValue("SELECT_NUM", 1);

	-- local accountInfo = session.barrack.GetMyAccount();
	-- if accountInfo:IsTutorialCleared() == true then
	-- 	btnSelect2:SetEnable(1);
	-- else
	-- 	btnSelect2:SetEnable(0);
	-- end

	-- local text2Top = text1:GetHeight() + text1:GetMargin().top + 20

	-- local text3Top = text2:GetHeight() + text2:GetMargin().top + 20
	-- text3:SetMargin(0, text3Top, 0, 0)

	local btnSelect1Top = text1:GetHeight() + text1:GetMargin().top + 20
	btnSelect1:SetMargin(0, btnSelect1Top, 0, 0)

	local btnSelect2Top = btnSelect1:GetHeight() + btnSelect1Top + 2
	btnSelect2:SetMargin(0, btnSelect2Top, 0, 0)

	local btnCancelTop = btnSelect2:GetHeight() + btnSelect2Top + 2
	btnCancel:SetMargin(0, btnCancelTop, 0, 0)

	local bgHeight = btnCancel:GetHeight() + btnCancelTop + 20

	bg:Resize(bg:GetWidth(), bgHeight)

	frame:ShowWindow(1);
end

function BARRACK_STARTMAP_SELECT_CANCEL()
	ui.SetEscapeScp("");
	local frame = ui.GetFrame("barrack_startmap_select");
	BARRACK_STARTMAP_SELECT_RESET(frame);
end

function BARRACK_STARTMAP_SELECT_LBTNUP(parent, ctrl)
	local frame = parent:GetTopParentFrame();
	if nil == frame then
		return
	end

	local select_num = ctrl:GetUserIValue("SELECT_NUM")
	_BARRACK_GO_CREATE(select_num)
	BARRACK_STARTMAP_SELECT_RESET(frame)
end

function BARRACK_STARTMAP_SELECT_RESET(frame)
	if nil == frame then
		return
	end

	frame:ShowWindow(0);
end