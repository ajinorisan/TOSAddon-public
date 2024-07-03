-- collection_allstatus_view.lua
function COLLECTION_ALL_STATUS_VIEW_OPEN(collection_frame)		
	if collection_frame == nil then
		return;
	end

	local collection_all_status_btn = GET_CHILD_RECURSIVELY(collection_frame, "collection_all_status_btn", "ui::CButton");
	if collection_all_status_btn == nil then
		return;
	end

	local x = collection_frame:GetGlobalX() + collection_frame:GetWidth() - 5;
	local y = collection_all_status_btn:GetGlobalY();
	local frame = ui.GetFrame("collection_allstatus_view");
	if frame ~= nil then
		if frame:IsVisible() == 1 then
			frame:ShowWindow(0);
		else 
			frame:SetOffset(x, y);
			frame:ShowWindow(1);
		end
	end
end

function COLLECTION_ALL_STATUS_VIEW_CLOSE(frame)
	frame:ShowWindow(0);
end

-- 리스트를 받고 리치텍스트에 입력한다.
local function sort_all_status_prop_name(a, b)
	return a.name < b.name;
end

function SET_COLLECTION_ALL_STATUS_VIEW_LIST(collection_frame, complete_magic_list, complete_count)
	local frame = ui.GetFrame("collection_allstatus_view");
	if frame == nil or collection_frame == nil then
		return;
	end
	-- 넘어온 리스트로부터 sort할 리스트로 만든다.
	local index = 1;
	local list = {};
	for i,v in pairs(complete_magic_list) do
		list[index] = { name = i, value = v };
		index = index +1;
	end
	-- sort
	table.sort(list, sort_all_status_prop_name);
	-- make value
	local text_list = "";
	for i,v in pairs(list) do
		if i > 1 then
			text_list = text_list .. "{nl}";
		end
		text_list = text_list.."{@st68b}{s18}".."- ["..v.name.."]{/}".." {#a00000}+"..tostring(v.value).."{/}";
	end
	-- status text
	local all_status_text = GET_CHILD(frame, "richtext_all_stauts_list", "ui::CRichText");
	local title_text = GET_CHILD(frame, "richtext_title", "ui::CRichText");
	if all_status_text == nil or title_text == nil then
		return 
	end
	all_status_text:SetTextByKey("value", text_list);
	title_text:SetTextByKey("value", complete_count);
	-- height
	local height = frame:GetUserConfig("TITLE_MARGIN_Y") * 2  + all_status_text:GetHeight();
	height = height + frame:GetUserConfig("BODY_MARGIN_Y") * 2 + title_text:GetHeight();
	-- resize
	local gbox_bg = GET_CHILD(frame, "bg", "ui::CGroupBox");
	if gbox_bg ~= nil then
		gbox_bg:Resize(gbox_bg:GetWidth(), height);
	end
	frame:Resize(frame:GetWidth(), height);
end