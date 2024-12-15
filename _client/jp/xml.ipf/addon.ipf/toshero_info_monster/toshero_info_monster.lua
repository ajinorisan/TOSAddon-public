function OPEN_TOSHERO_INFO_MONSTER(parent, self, argStr, argNum)
    local frame = ui.GetFrame('toshero_info_monster')
    if frame == nil then
        return
    end
    ui.OpenFrame("toshero_info_monster")

    TOSHERO_INFO_MONSTER(frame, argStr)
end

function UPDATE_TOSHERO_INFO_MONSTER(indunCls)
    local frame = ui.GetFrame('toshero_info_monster')
    if frame == nil or frame:IsVisible() == 0 or indunCls.DungeonType ~= "TOSHero" then
        return
    end
    TOSHERO_INFO_MONSTER(frame, indunCls.ClassName)
end

function TOSHERO_INFO_MONSTER(frame, argStr)
    local class = GetClass("TOSHeroMonsterInfo", argStr)
    local bg = GET_CHILD_RECURSIVELY(frame, "monListBox")
    bg:RemoveAllChild();

    for i = 1, 5 do
        local monsterClassName = TryGetProp(class, "MonsterName_"..i)
        local monsterTextInfo = TryGetProp(class, "MonsterInfo_"..i)
        local monsterClass = GetClass("Monster", monsterClassName)

        if monsterClassName ~= "None" then
            local controlset = bg:CreateOrGetControlSet('toshero_monster_info', 'info_'..i, 0, 124 * (i - 1))
            local monsterName = GET_CHILD_RECURSIVELY(controlset, "monsterName")
            local monsterDesc = GET_CHILD_RECURSIVELY(controlset, "monsterDesc")
            local monsterPic = GET_CHILD_RECURSIVELY(controlset, "monsterPic")

            monsterName:SetTextByKey("name", monsterClass.Name)
            monsterDesc:SetText(monsterTextInfo)
            monsterPic:SetImage(monsterClass.Icon)
        else
            return
        end
    end
end