-- v1.0.1 BOSS倒したら矢印速攻消える様に。サイズ控え目に。
-- v1.0.2 角度調整
-- v1.0.3 レイヤー修正。スキルショートカットより低く設定。
-- v1.0.4 バグ修正
-- v1.0.5 クエストモードから復帰した時にちゃんと動かなかったの修正。
-- v1.0.6 レダニアの本体を見つける
-- v1.0.7 全体のロジックを変更
local addon_name = "BOSS_DIRECTION"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
local ver = "1.0.7"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]

function BOSS_DIRECTION_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    g.handles = {}
    local pc = GetMyPCObject()
    local cur_map = GetZoneName(pc)
    local map_cls = GetClass("Map", cur_map)
    g.map_name = map_cls.ClassName
    if map_cls.MapType ~= "City" then
        addon:RegisterMsg('GAME_START_3SEC', 'boss_direction_handle_check_reserve')
    end
end

function boss_direction_handle_check_reserve()
    local boss_direction = ui.GetFrame("boss_direction")
    boss_direction:ShowWindow(1)
    boss_direction:RunUpdateScript("boss_direction_handle_check", 1.0)
end

function boss_direction_handle_check(boss_direction)

    local visible_bosses = {}
    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 500, "ENEMY")
    for i = 1, selected_objects_count do
        local handle = GetHandle(selected_objects[i])
        -- local target_info = info.GetMonRankbyHandle(handle)
        -- if target_info == "Boss" then
        local target_info = info.GetTargetInfo(handle)
        if target_info.isBoss == 1 then
            local cls_name = info.GetMonsterClassName(handle)
            local mon_cls = GetClass("Monster", cls_name)
            local icon_name = mon_cls.Icon
            if icon_name ~= "icon_item_nothing" then
                visible_bosses[handle] = true
                local frame = ui.GetFrame(addon_name_lower .. "_" .. handle)
                if not frame then
                    frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "_" .. handle, 0, 0, 0, 0)
                    frame:SetSkinName("None")
                    frame:SetTitleBarSkin("None")
                    frame:Resize(120, 120)
                    frame:SetLayerLevel(1)
                    local arrow = frame:CreateOrGetControl("picture", "arrow", 0, 0, 70, 70)
                    AUTO_CAST(arrow)
                    arrow:SetImage("class_tree_arrow")
                    arrow:SetEnableStretch(1)
                    arrow:EnableHitTest(0)
                    arrow:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
                    arrow:Resize(60, 60)
                    arrow:SetColorTone("FFFF0000")
                end
                AUTO_CAST(frame)
                if not g.handles[handle] then
                    g.handles[handle] = frame:GetName()
                end
                local arrow = GET_CHILD(frame, "arrow")
                arrow:SetAngle(info.GetAngle(handle) - 23)
                FRAME_AUTO_POS_TO_OBJ(frame, handle, -frame:GetWidth() / 2, -frame:GetHeight() / 2, 0, 0)
                local stat = target_info.stat
                if stat.HP == 0 then
                    frame:ShowWindow(0)
                else
                    frame:ShowWindow(1)
                end
                if string.find(g.map_name, "Raid_Redania") and not string.find(string.upper(cls_name), "ILLUSION") then
                    arrow:SetColorTone("FFFFFF00")
                end
            end
        end
    end

    for handle, frame_name in pairs(g.handles) do
        if not visible_bosses[handle] then
            ui.DestroyFrame(frame_name)
            g.handles[handle] = nil
        end
    end
    return 1
end
--[[for key, value in pairs(info) do
    print(string.format("  Key: %s,  Type: %s", tostring(key), type(value)))
end
function BOSS_DIRECTION_CHECK_HANDLE_STATUS(frame)

    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 500, "ALL")
    print(tostring(selected_objects) .. ":" .. tostring(selected_objects_count))
    for i = 1, selected_objects_count do

        local handle = GetHandle(selected_objects[i])
        print(handle)
        print(tostring(info.GetMonRankbyHandle(handle)))

    end
    frame:ShowWindow(0)
    return 1
end

function BOSS_DIRECTION_ALL_FRAME_CLOSE_RESERVE(frame)

    local visible_bosses = {}
    local selected_objects, selected_objects_count = SelectObject(GetMyPCObject(), 500, "ALL")
    for i = 1, selected_objects_count do

        local handle = GetHandle(selected_objects[i])
        local target_handle = session.GetTargetBossHandle()
        if target_handle ~= 0 then
            local cls_name = info.GetMonsterClassName(handle)
            if string.find(string.upper(cls_name), "BOSS") then
                visible_bosses[handle] = true
                local frame = ui.GetFrame(addon_name_lower .. "_" .. handle)
                if not frame then
                    frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "_" .. handle, 0, 0, 0, 0)
                end
                AUTO_CAST(frame)
                frame:SetSkinName("None")
                frame:SetTitleBarSkin("None")
                frame:Resize(130, 130)
                frame:SetLayerLevel(1)

                if not g.handles[handle] then
                    g.handles[handle] = frame:GetName()
                end

                local arrow = frame:CreateOrGetControl("picture", "arrow", 0, 0, 70, 70)
                AUTO_CAST(arrow)
                arrow:SetImage("class_tree_arrow")
                arrow:SetEnableStretch(1)
                arrow:EnableHitTest(0)
                arrow:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
                arrow:SetAngle(info.GetAngle(handle) - 23)
                arrow:Resize(70, 70)
                arrow:SetColorTone("FFFF0000")
                FRAME_AUTO_POS_TO_OBJ(frame, handle, -frame:GetWidth() / 2, -frame:GetHeight() / 2, 0, 0)
                frame:ShowWindow(1)

                if string.find(g.map_name, "Raid_Redania") then
                    if msg == 'TARGET_SET_BOSS' or msg == 'TARGET_UPDATE' or msg == 'TARGET_BUFF_UPDATE' then
                        local stat = info.GetStat(handle)
                        if stat then
                            local tib_frame = ui.GetFrame("targetinfotoboss")
                            local faint_gauge = GET_CHILD_RECURSIVELY(tib_frame, "faint", "ui::CGauge")
                            local cur_faint = stat.cur_faint
                            local max_faint = stat.max_faint
                            if cur_faint > 0 and max_faint > 0 and faint_gauge and faint_gauge:IsVisible() == 1 then
                                local notice = frame:CreateOrGetControl("picture", "notice", 0, 0, 20, 20)
                                AUTO_CAST(notice)
                                notice:SetEnableStretch(1)
                                notice:EnableHitTest(0)
                                notice:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
                                local mon_cls = GetClassByType("Monster", 59864)
                                local img_name = mon_cls.Icon
                                notice:SetImage(img_name)
                                notice:SetAngleLoop(5)
                                -- arrow:SetColorTone("FFFFFF00")
                            end
                        end
                    end
                end
            end
        end
    end

    for handle, frame_name in pairs(g.handles) do
        if not visible_bosses[handle] then
            ui.DestroyFrame(frame_name)
            g.handles[handle] = nil
        end
    end
end

function BOSS_DIRECTION_ALL_FRAME_CLOSE()

    for handle, frame_name in pairs(g.handles) do
        local frame = ui.GetFrame(frame_name)
        frame:ShowWindow(0)
    end
    return 0
end

local targetinfotoboss = ui.GetFrame("targetinfotoboss")
        if targetinfotoboss and targetinfotoboss:IsVisible() == 0 then
            targetinfotoboss:RunUpdateScript("BOSS_DIRECTION_ALL_FRAME_CLOSE", 2.0)
        end
function BOSS_DIRECTION_ON_MSG(frame, msg, str, num)

    if msg == "TARGET_CLEAR_BOSS" then
        local frame = ui.GetFrame(addon_name_lower .. "_" .. num)
        -- frame:RunUpdateScript("BOSS_DIRECTION_CHECK_HANDLE_STATUS", 2.0)
        frame:StopUpdateScript("BOSS_DIRECTION_ALL_FRAME_CLOSE")
        frame:RunUpdateScript("BOSS_DIRECTION_ALL_FRAME_CLOSE", 2.0)
        return
    end

    local handle = session.GetTargetBossHandle()
    if handle ~= 0 then
        if not g.handles[handle] then
            g.handles[handle] = frame:GetName()
        end
        
        local frame = ui.GetFrame(addon_name_lower .. "_" .. handle)
        if not frame then
            frame = ui.CreateNewFrame("notice_on_pc", addon_name_lower .. "_" .. handle, 0, 0, 0, 0)
        end
        AUTO_CAST(frame)
        frame:SetSkinName("None")
        frame:SetTitleBarSkin("None")
        frame:Resize(130, 130)
        frame:SetLayerLevel(1)

        local arrow = frame:CreateOrGetControl("picture", "arrow", 0, 0, 70, 70)
        AUTO_CAST(arrow)
        arrow:SetImage("class_tree_arrow")
        arrow:SetEnableStretch(1)
        arrow:EnableHitTest(0)
        arrow:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
        arrow:SetAngle(info.GetAngle(handle) - 23)
        arrow:Resize(70, 70)
        arrow:SetColorTone("FFFF0000")
        FRAME_AUTO_POS_TO_OBJ(frame, handle, -frame:GetWidth() / 2, -frame:GetHeight() / 2, 0, 0)
        frame:ShowWindow(1)

        if string.find(g.map_name, "Raid_Redania") then
            if msg == 'TARGET_SET_BOSS' or msg == 'TARGET_UPDATE' or msg == 'TARGET_BUFF_UPDATE' then
                local stat = info.GetStat(handle)
                if stat then
                    local tib_frame = ui.GetFrame("targetinfotoboss")
                    local faint_gauge = GET_CHILD_RECURSIVELY(tib_frame, "faint", "ui::CGauge")
                    local cur_faint = stat.cur_faint
                    local max_faint = stat.max_faint
                    if cur_faint > 0 and max_faint > 0 and faint_gauge and faint_gauge:IsVisible() == 1 then
                        local notice = frame:CreateOrGetControl("picture", "notice", 0, 0, 20, 20)
                        AUTO_CAST(notice)
                        notice:SetEnableStretch(1)
                        notice:EnableHitTest(0)
                        notice:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
                        local mon_cls = GetClassByType("Monster", 59864)
                        local img_name = mon_cls.Icon
                        notice:SetImage(img_name)
                        notice:SetAngleLoop(5)
                        -- arrow:SetColorTone("FFFFFF00")
                    end
                end
            end
        end
    end
end]]

