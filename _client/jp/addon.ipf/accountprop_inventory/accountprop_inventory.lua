function ACCOUNTPROP_INVENTORY_ON_INIT(addon, frame)

end

function ACCOUNTPROP_INVENTORY_OPEN()
	local frame = ui.GetFrame("accountprop_inventory");
    frame:ShowWindow(1);
end

function ACCOUNTPROP_INVENTORY_CLOSE()
	local frame = ui.GetFrame("accountprop_inventory");
    frame:ShowWindow(0);    
end

local _category = {};
local _invenTreeOpenOption = {}; -- key: cid, value: {key: TreegroupName, value: IsToggle}
function ACCOUNTPROP_INVENTORY_OPEN_SCRIPT(frame)
    local mySession = session.GetMySession();
    local cid = mySession:GetCID();
	if _invenTreeOpenOption[cid] == nil then
		_invenTreeOpenOption[cid] = {};
    end
    
    ACCOUNTPROP_INVENTORY_UPDATE(frame);
end

function ACCOUNTPROP_INVENTORY_UPDATE(frame)
    local aObj = GetMyAccountObj()
    local main_gb = GET_CHILD(frame, "main_gb");
    local tree = GET_CHILD(main_gb, "tree");
    if nil == tree then
        return;
    end

    local TREE_NODE_FONT = frame:GetUserConfig("TREE_NODE_FONT");
    tree:EnableDrawTreeLine(false);
    tree:EnableDrawFrame(false);
    tree:SetFitToChild(true, 100);
    tree:SetFontName(TREE_NODE_FONT);
    tree:SetTabWidth(5);
    tree:SetEventScript(ui.LBUTTONDOWN, "ACCOUNTPROP_INVENTORY_TREE_OPENOPTION_CHANGE");

    local clsList, cnt = GetClassList('accountprop_inventory_list');
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(clsList, i);
        if cls ~= nil then
            local Category = cls.Category;            
            if _category[Category] == nil then
                _category[Category] = 1;
            end

            local hGroup = tree:FindByValue(Category);
            if tree:IsExist(hGroup) == 0 then
                hGroup = tree:Add(ClMsg(Category), Category);
            end
            
            local groupbox = tree:GetChild(Category);
            if groupbox == nil then
                groupbox = tree:CreateOrGetControl('groupbox', Category, 0, 0, 400, 200);
                groupbox:EnableHitTest(0);
                groupbox:SetSkinName('None');

                tree:Add(hGroup, groupbox);
            end

            local ctrlset = groupbox:CreateOrGetControlSet('icon_text_count', cls.ClassName, 0, 5);
            local pic = GET_CHILD(ctrlset, "pic");
            local name = GET_CHILD(ctrlset, "name");
            local count = GET_CHILD(ctrlset, "count");

            local PropName = cls.ClassName;
            local value = TryGetProp(aObj, PropName, 'None');
            if value == 'None' then
                value = 0;
            end
            value = GET_COMMAED_STRING(value);

            pic:SetImage(cls.Icon);
            name:SetTextByKey("value", ClMsg(cls.ClassName));
            count:SetTextByKey("value", value);            
            GBOX_AUTO_ALIGN(groupbox, 0, 0, 0, true, false);
            local cnt = groupbox:GetChildCount() - 1;
            local height = (cnt * ctrlset:GetHeight()) + frame:GetUserConfig("TREE_GROUP_BOX_MARGIN");
            groupbox:Resize(groupbox:GetWidth(), height);
        end
    end

    for k, v in pairs(_category) do 
        local Category = k;
        local hGroup = tree:FindByValue(Category);
        if tree:IsExist(hGroup) == 1 then
            local mySession = session.GetMySession();
            local cid = mySession:GetCID();
            
            local treenode = tree:GetNodeByTreeItem(hGroup)
            if _invenTreeOpenOption[cid] then
                if _invenTreeOpenOption[cid][Category] == false then
                    tree:OpenNode(treenode, false, true);
                else
                    _invenTreeOpenOption[cid][Category] = true;
                    tree:OpenNode(treenode, true, true);
                end
            end
        end        
    end
end

function ACCOUNTPROP_INVENTORY_TREE_OPENOPTION_CHANGE(parent, ctrl)
    for k, v in pairs(_category) do 
        local Category = k;
        local hGroup = ctrl:FindByValue(Category);
        if ctrl:IsExist(hGroup) == 1 then
            local mySession = session.GetMySession();
            local cid = mySession:GetCID();

            local treenode = ctrl:GetNodeByTreeItem(hGroup)
            if treenode ~= nil then
                local openoption = treenode:GetIsOpen();
                local mySession = session.GetMySession();
                local cid = mySession:GetCID();

                _invenTreeOpenOption[cid][Category] = openoption;
            end
        end        
    end
end