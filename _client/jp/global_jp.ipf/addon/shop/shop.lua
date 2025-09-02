function CONTEXT_SOLD_ITEM(frame, slot, guid)
	if frame == nil then
		frame = ui.GetFrame('shop');
	end
	local list = session.GetSoldItemList();
	local info = list:GetItemByGuid(guid);
	if info == nil then
		return;
	end
	local obj = GetIES(info:GetObject());

	local topFrame = frame:GetTopParentFrame();
	local context = ui.CreateContextMenu("SOLD_ITEM_CONTEXT", "{@st41}".. GET_FULL_NAME(obj).. "{@st42b}..",0, 0, 100, 100);
	local strScp = string.format("SHOP_REQ_CANCEL_SELL('%s', '%s')", guid, topFrame:GetName());

--	ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}JaeMaeip"), strScp);
	strScp = string.format("SHOP_REQ_DELETE_SOLDITEM('%s', '%s')", guid, topFrame:GetName());
	ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}yeongKuJeKeo"), strScp);
	ui.AddContextMenuItem(context, ScpArgMsg("Auto_{@st42b}ChwiSo"), "SHOP_SOLDED_CANCEL");
	ui.OpenContextMenu(context);
end