-- EFFECT
-- function WORLDMAP2_MAINMAP_EFFECT_ON()
-- 	local frame = ui.GetFrame('worldmap2_mainmap')
--     local myPos = frame:GetUserValue("MY_POS")
--     if myPos == nil or myPos == "None" then
--         return
--     end

--     local myPosSet = frame:GetChild(myPos)
--     local myPosArrow = myPosSet:GetChild("pc_pos")

-- 	myPosArrow:PlayUIEffect("UI_worldmap_pos_01_loop", 8, "MY_POS")
-- end

function TOSHERO_TUTO_EFFECT_ON(state)
    local state = tonumber(state)
    
    local frame1 = ui.GetFrame('toshero_info')
    local target1_1 = frame1:GetChild("reinforce")
    local target1_2 = frame1:GetChild("buff")
    local target1_3 = frame1:GetChild("attribute")
    local target1_4 = frame1:GetChild("ready")
    target1_1:StopUIEffect("TUTO_EFFECT1", true, 0)
    target1_2:StopUIEffect("TUTO_EFFECT1", true, 0)
    target1_3:StopUIEffect("TUTO_EFFECT1", true, 0)
    target1_4:StopUIEffect("TUTO_EFFECT1", true, 0)


    local frame2 = ui.GetFrame('toshero_info_reinforce')
    local target2_1 = frame2:GetChild("equip")
    target2_1:StopUIEffect("TUTO_EFFECT2", true, 0)


    local frame3 = ui.GetFrame('toshero_info_buff')
    local target3_1 = frame3:GetChild("buff_shop_btn")
    local target3_2 = frame3:GetChild("buff_bg_1")
    local target3_3 = target3_2:GetChild("checkbox_1")
    target3_1:StopUIEffect("TUTO_EFFECT3", true, 0)
    target3_2:StopUIEffect("TUTO_EFFECT3", true, 0)
    target3_3:StopUIEffect("TUTO_EFFECT3", true, 0)

    
    local frame4 = ui.GetFrame('toshero_info_attribute')
    local target4_1 = frame4:GetChild("body_bg")
    target4_1:StopUIEffect("TUTO_EFFECT4", true, 0)





    if state == 0 then
        return
    elseif state == 1 then-- 강화

        --종합 UI 강화 슬롯에 이펙트
        local frame1 = ui.GetFrame('toshero_info')
        local target1 = frame1:GetChild("reinforce")
        target1:StopUIEffect("TUTO_EFFECT1", true, 0)
        target1:PlayUIEffect("UI_worldmap_pos_01_loop", 15, "TUTO_EFFECT1")

        --강화 UI 아이템 등록 슬롯에 이펙트
        local frame2 = ui.GetFrame('toshero_info_reinforce')
        local target2 = frame2:GetChild("equip")
        target2:StopUIEffect("TUTO_EFFECT2", true, 0)
        target2:PlayUIEffect("UI_worldmap_pos_01_loop", 15, "TUTO_EFFECT2")
        
    elseif state == 2 then-- 버프, 버프 상점

        local frame1 = ui.GetFrame('toshero_info')
        local target1 = frame1:GetChild("buff")
        target1:StopUIEffect("TUTO_EFFECT1", true, 0)
        target1:PlayUIEffect("UI_worldmap_pos_01_loop", 15, "TUTO_EFFECT1")

        local frame2 = ui.GetFrame('toshero_info_buff')
        local target2 = frame2:GetChild("buff_shop_btn")
        target2:StopUIEffect("TUTO_EFFECT3", true, 0)
        target2:PlayUIEffect("UI_worldmap_pos_01_loop", 15, "TUTO_EFFECT3")
        
    elseif state == 3 then -- 속성

        local frame1 = ui.GetFrame('toshero_info')
        local target1 = frame1:GetChild("attribute")
        target1:StopUIEffect("TUTO_EFFECT1", true, 0)
        target1:PlayUIEffect("UI_worldmap_pos_01_loop", 15, "TUTO_EFFECT1")

        local frame2 = ui.GetFrame('toshero_info_attribute')
        local target2 = frame2:GetChild("body_bg")
        target2:StopUIEffect("TUTO_EFFECT4", true, 0)
        target2:PlayUIEffect("UI_worldmap_pos_01_loop", 30, "TUTO_EFFECT4")

    elseif state == 4 then -- 준비 버튼
        local frame1 = ui.GetFrame('toshero_info')
        local target1 = frame1:GetChild("ready")
        target1:StopUIEffect("TUTO_EFFECT1", true, 0)
        target1:PlayUIEffect("UI_worldmap_pos_01_loop", 15, "TUTO_EFFECT1")
        
    elseif state == 5 then -- 옵션 변경
        local frame1 = ui.GetFrame('toshero_info')
        local target1 = frame1:GetChild("reinforce")
        target1:StopUIEffect("TUTO_EFFECT1", true, 0)
        target1:PlayUIEffect("UI_worldmap_pos_01_loop", 15, "TUTO_EFFECT1")

    elseif state == 6 then -- 히든
        local frame1 = ui.GetFrame('toshero_info')
        local target1 = frame1:GetChild("buff")
        target1:StopUIEffect("TUTO_EFFECT1", true, 0)
        target1:PlayUIEffect("UI_worldmap_pos_01_loop", 15, "TUTO_EFFECT1")

        local frame2 = ui.GetFrame('toshero_info_buff')
        local target2 = frame2:GetChild("buff_bg_1")
        local target3 = target2:GetChild("checkbox_1")
        target3:StopUIEffect("TUTO_EFFECT3", true, 0)
        target3:PlayUIEffect("UI_worldmap_pos_01_loop", 15, "TUTO_EFFECT3")
    elseif state == 7 then
    end


end