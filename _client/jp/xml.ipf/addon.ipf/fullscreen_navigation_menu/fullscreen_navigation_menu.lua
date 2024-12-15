-- full screen menu
local s_fullscreen_navi_category_list = {};

function FULLSCREEN_NAVIGATION_MENU_ON_INIT(addon, frame)
    addon:RegisterMsg("CHANGE_RESOLUTION", "FULLSCREEN_NAVIGATION_MENU_FRAEM_RESIZE");
end

function FULLSCREEN_NAVIGATION_MENU_OPEN(frame)
    if frame == nil then return; end
    FULLSCREEN_NAVIGATION_MENU_CREATE(frame, 1);
end

function FULLSCREEN_NAVIGATION_MENU_CLOSE(frame)
    if frame == nil then return; end
    frame:SetUserValue("PAGE", 1);
    FULLSCREEN_NAVIGATION_MENU_PAGE_TEXT_UPDATE(frame, 1);
    FULLSCREEN_NAVIGATION_MENU_REMOVE(frame);
end

function FULLSCREEN_NAVIGATION_MENU_FRAEM_RESIZE(frame, msg, arg_str, arg_num)
    if frame == nil then return; end
    local ratio = math.floor((frame:GetWidth() / frame:GetHeight()) * 10^2 - 0.5) / 10^2;
    local client_ratio = math.floor((option.GetClientWidth() / option.GetClientHeight()) * 10^2 - 0.5) / 10^2;
    if client_ratio == 1.32 then
        local width = tonumber(frame:GetUserConfig("FRAME_WIDTH"));
        local height = tonumber(frame:GetUserConfig("FRAME_HEIGHT2"));
        frame:Resize(width, height);
    elseif client_ratio == 1.77 then
        local width = tonumber(frame:GetUserConfig("FRAME_WIDTH"));
        local height = tonumber(frame:GetUserConfig("FRAME_HEIGHT"));
        frame:Resize(width, height);
    end
    frame:Invalidate();
end

function FULLSCREEN_NAVIGATION_MENU_PAGE_BTN(parent, ctrl)
    if ctrl == nil then return; end
    local frame = parent:GetTopParentFrame();
    local page = tonumber(frame:GetUserValue("PAGE"));
    if page == nil then page = 1; end
    if string.find(ctrl:GetName(), "left") ~= nil then
        if page - 1 < 1 then 
            frame:SetUserValue("PAGE", 1); 
        else
            frame:SetUserValue("PAGE", page - 1);
        end
    elseif string.find(ctrl:GetName(), "right") ~= nil then
        local max_page = tonumber(frame:GetUserConfig("MAX_PAGE"));
        if page + 1 > max_page then
            frame:SetUserValue("PAGE", max_page);
        else
            frame:SetUserValue("PAGE", page + 1);
        end
    end
    FULLSCREEN_NAVIGATION_MENU_PAGE_TEXT_UPDATE(frame, tonumber(frame:GetUserValue("PAGE")));
    FULLSCREEN_NAVIGATION_MENU_CREATE(frame, tonumber(frame:GetUserValue("PAGE")));
end

function FULLSCREEN_NAVIGATION_MENU_PAGE_TEXT_UPDATE(frame, page)
    if frame == nil then return; end
    local text_page = GET_CHILD_RECURSIVELY(frame, "text_page");
    if text_page ~= nil then
        text_page:SetTextByKey("page", tostring(page));
    end
end

function FULLSCREEN_NAVIGATION_MENU_REMOVE(frame)
    s_fullscreen_navi_category_list = {};
    local gbox =  GET_CHILD_RECURSIVELY(frame, "gbox_menu");
    if gbox ~= nil then gbox:RemoveAllChild(); end
end

function FULLSCREEN_NAVIGATION_MENU_CREATE(frame, page)
    local gbox = GET_CHILD_RECURSIVELY(frame, "gbox_menu");
    if gbox ~= nil then
        FULLSCREEN_NAVIGATION_MENU_REMOVE(frame);
        FULLSCREEN_NAVIGATION_MENU_CREATE_SECTION(frame, gbox, page);
    end
end

local s_fullscreen_navi_section = 4;
function FULLSCREEN_NAVIGATION_MENU_CREATE_SECTION(frame, gbox, page)
    local width = gbox:GetWidth() / s_fullscreen_navi_section;
    local height = gbox:GetHeight();
    for i = 1, s_fullscreen_navi_section do
        local name = "SECTION_"..i;
        local section_gbox = gbox:CreateControl("groupbox", name, (i - 1) * width, 0, width, height);
        if section_gbox ~= nil then
            section_gbox = AUTO_CAST(section_gbox);
            section_gbox:EnableDrawFrame(0);
            section_gbox:EnableScrollBar(0);
            FULLSCREEN_NAVIGATION_MENU_CREATE_CATEGORY(frame, section_gbox, page, i);
        end
    end
end

function FULLSCREEN_NAVIGATION_MENU_CREATE_CATEGORY(frame, gbox, page, section)
    local y = 0;
    local width = gbox:GetWidth();
    local title_height = tonumber(frame:GetUserConfig("CATE_TITLE_HEIGHT"));
    local title_top_margin = tonumber(frame:GetUserConfig("CATE_TITLE_TOP_MARGIN"));
    local list, cnt = GetClassList("full_screen_navigation_menu");
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(list, i);
        if cls ~= nil then
            local cls_page = TryGetProp(cls, "Page", 0);
            local group_index = TryGetProp(cls, "GroupIndex", 0);
            if cls_page == page and group_index == section then
                local category = TryGetProp(cls, "Category", "None");
                if category ~= "None" and table.find(s_fullscreen_navi_category_list, category) == 0 then
                    s_fullscreen_navi_category_list[#s_fullscreen_navi_category_list + 1] = category;
                    -- category title
                    local name = "CATEGORY_TITLE_"..category;
                    local category_ctrlset = gbox:CreateOrGetControlSet("fullscreen_navi_category", name, 0, y);
                    if category_ctrlset ~= nil then
                        category_ctrlset:SetMargin(0, y + title_top_margin, 0, 0);
                        category_ctrlset:SetGravity(ui.CENTER_HORZ, ui.TOP);
                        local category_text = GET_CHILD_RECURSIVELY(category_ctrlset, "Name");
                        if category_text ~= nil then
                            local title = TryGetProp(cls, "CategoryName", "None");
                            local format = "{@st66d_y}{s24}";
                            category_text:SetText(format..title.."{/}");
                            category_text:SetTextAlign("center", "center");
                            category_text:EnableResizeByText(1);
                            y = y + category_ctrlset:GetHeight() + 20;
                        end
                    end
                    -- category box
                    name = "CATEGORY_"..category;
                    local category_gbox = gbox:CreateControl("groupbox", name, 0, y, width, 0);
                    if category_gbox ~= nil then
                        category_gbox = AUTO_CAST(category_gbox);
                        category_gbox:EnableDrawFrame(0);
                        category_gbox:EnableScrollBar(0);
                        local height = FULLSCREEN_NAVIGATION_MENU_CREATE_DETAIL(frame, category_gbox, category);
                        y = y + height + 30;
                    end
                end
            end
        end
    end
end

local function sort(a, b)
    return tonumber(TryGetProp(a, "SortIndex", 0)) < tonumber(TryGetProp(b, "SortIndex", 0));
end
function FULLSCREEN_NAVIGATION_MENU_CREATE_DETAIL(frame, gbox, category)
    local detail_list = {};
    local list, cnt = GetClassList("full_screen_navigation_menu");
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(list, i);
        if cls ~= nil then
            local _category = TryGetProp(cls, "Category", "None");
            if _category == category then
                detail_list[#detail_list + 1] = cls;
            end
        end
    end
    if #detail_list > 0 then
        table.sort(detail_list, sort)
        local y = 0;
        for i = 1, #detail_list do
            local cls = detail_list[i];
            if cls ~= nil then
                local class_name = TryGetProp(cls, "ClassName", "None");
                local menu_name = "MENU_"..class_name;
                local ctrl_set = gbox:CreateOrGetControlSet("fullscreen_navi_menu", menu_name, 0, y);
                if ctrl_set ~= nil then
                    -- tooltip
                    local button = GET_CHILD_RECURSIVELY(ctrl_set, "gbox");
                    if button ~= nil then
                        local tooltip_text = TryGetProp(cls, "ToolTip", "None");
                        if tooltip_text ~= nil and tooltip_text ~= "None" then
                            tooltip_text = "{s17}{#00EEEE}"..tooltip_text;
                            button:SetTextTooltip(tooltip_text);
                        end
                    end
                    -- icon
                    local icon = GET_CHILD_RECURSIVELY(ctrl_set, "icon");
                    local menu_icon_name = TryGetProp(cls, "MenuIcon", "None");
                    local active = TryGetProp(cls, "ActiveState", "None");
                    if active == "NO" then
                        menu_icon_name = "inven_lockup_btn"; -- 임시 처리.
                        local tooltip = ClMsg("UnActiveMenuToolTip");
                        icon:SetTextTooltip(tooltip);
                    else
                        icon:SetTextTooltip("");
                    end
                    if icon ~= nil then
                        if menu_icon_name ~= "None" then
                            icon:SetImage(menu_icon_name);
                        end
                    end
                    -- name
                    local name_text = GET_CHILD_RECURSIVELY(ctrl_set, "name");
                    if name_text ~= nil then
                        local name = TryGetProp(cls, "Name", "None");
                        name_text:SetTextByKey("name", name);
                    end
                    local class_id = TryGetProp(cls, "ClassID", 0);
                    ctrl_set:SetUserValue("guid", class_id);
                    y = y + ctrl_set:GetHeight();
                end
            end
        end
        local width = gbox:GetWidth();
        gbox:Resize(width, y);
        gbox:Invalidate();
        return y;
    end
    return 0;
end

function FULLSCREEN_NAVIGATION_MENU_DETAIL_OPEN(ctrl_set, gbox)
    if ctrl_set == nil or gbox == nil then return; end
    local guid = tonumber(ctrl_set:GetUserValue("guid"));
    local cls = GetClassByType("full_screen_navigation_menu", guid);
    if cls ~= nil then
        local active = TryGetProp(cls, "ActiveState", "None");
        if active == "NO" or active == "None" then return; end
        local open_scp = TryGetProp(cls, "OpenScp", "None");
        if open_scp ~= "None" then
            func = _G[open_scp];
            func();
            ui.CloseFrame("fullscreen_navigation_menu");
        else
            local guid = tonumber(ctrl_set:GetUserValue("guid"));
            local yes_scp = string.format("FULLSCREEN_NAVIGATION_MENU_DETAIL_MOVE_NPC(%d)", guid);
            local name = TryGetProp(cls, "Name", "None");
            if name ~= "None" then
                local msg = ScpArgMsg("AskFullScreenMenuMoveNpc", "Menu", name);
                ui.MsgBox(msg, yes_scp, "None");
            end
        end
    end
end

function FULLSCREEN_NAVIGATION_MENU_DETAIL_MOVE_NPC(guid)
    if guid == nil then return; end
    local cls = GetClassByType("full_screen_navigation_menu", guid);
    if cls ~= nil then
        local name = TryGetProp(cls, "Name", "None");
        local move_zone_select = TryGetProp(cls, "MoveZoneSelect", "NO");
        local move_zone = TryGetProp(cls, "MoveZone", "None"); 
        local move_npc_dialog = TryGetProp(cls, "MoveNpcDialog", "None");
        local move_zone_select_msg = TryGetProp(cls, "MoveZoneSelectMsg", "None");
        local move_only_in_town = TryGetProp(cls, "MoveOnlyInTown", "None");
        if move_zone ~= "None" and move_npc_dialog ~= "None" then
            -- 매칭 던전중이거나 pvp존이면 이용 불가
            local pc = GetMyPCObject();
            if session.world.IsIntegrateServer() == true or IsPVPField(pc) == 1 or IsPVPServer(pc) == 1 then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"));
                return;
            end
            -- 퀘스트나 챌린지 모드로 인해 레이어 변경되면 이용 불가
            if world.GetLayer() ~= 0 then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"));
                return;
            end
            -- 프리던전 맵에서 이용 불가
            local cur_map = GetClass("Map", session.GetMapName());
            local map_type = TryGetProp(cur_map, "MapType");
            if map_type == "Dungeon" then
                ui.SysMsg(ScpArgMsg("ThisLocalUseNot"));
                return;
            end
            -- 레이드 지역에서 이용 불가
            local zoneKeyword = TryGetProp(curMap, 'Keyword', 'None')
            local keywordTable = StringSplit(zoneKeyword, ';')
            if table.find(keywordTable, 'IsRaidField') > 0 or table.find(keywordTable, 'WeeklyBossMap') > 0 then
                ui.SysMsg(ScpArgMsg('ThisLocalUseNot'))
                return
            end
            FullScreenMenuMoveNpc(name, move_zone_select, move_zone, move_npc_dialog, move_zone_select_msg, move_only_in_town);
            ui.CloseFrame("fullscreen_navigation_menu");
        end
    end
end

function FULLSCREEN_NAVIGATION_MENU_DEATIL_EQUIPMENT_PROCESSING_NPC()
    ui.Chat('/equipment_processing_npc');
end