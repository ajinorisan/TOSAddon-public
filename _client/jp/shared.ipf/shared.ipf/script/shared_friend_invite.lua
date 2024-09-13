-- shared_popoboost
local cls_list = nil
function friend_invite_reward_cls_list(GroupName)
    if cls_list == nil then
        cls_list={};
    end
    local clsList, cnt = GetClassList("friend_invite")
    for i = 0, cnt - 1 do
        local cls = GetClassByIndexFromList(i);
        local ClsGroup = TryGetProp(cls, "GroupName", "None")
        print(ClsGroup,GroupName)
        -- if ClsGroup == GroupName then
        -- end
        table.insert(cls_list, cls);
    end
    return cls_list
end
