function TOSHERO_INFO_ON_INIT(addon, frame)
    addon:RegisterMsg('TOSHERO_INFO_GET', 'ON_TOSHERO_INFO_GET')
    addon:RegisterMsg('TOSHERO_INFO_POINT', 'ON_TOSHERO_INFO_POINT')
    addon:RegisterMsg('TOSHERO_STAGE_START', 'ON_TOSHERO_INFO_SET_STAGE')
    addon:RegisterMsg('TOSHERO_INFO_NEXT_STAGE', 'ON_TOSHERO_INFO_NEXT_STAGE')
    addon:RegisterMsg('TOSHERO_HIDDEN_BUFF_ADD', 'ON_TOSHERO_HIDDEN_BUFF_ADD')
    addon:RegisterMsg('TOSHERO_ZONE_ENTER', 'ON_TOSHERO_ZONE_ENTER')
    addon:RegisterMsg('TOSHERO_STAGE_END', 'ON_TOSHERO_STAGE_CLEAR')
    addon:RegisterMsg('TOSHERO_STAGE_TEXT', 'ON_TOSHERO_STAGE_TEXT')
end

g_toshero_reinforce_image = "None"
g_toshero_group_index = 200000
g_next_stage_time = 0
g_stage_start = false
-- AddOnMsg
function ON_TOSHERO_INFO_GET()
    local frame = ui.GetFrame('toshero_info')
    if frame == nil then
        return
    end

    ui.OpenFrame('toshero_info')

    TOSHERO_INFO_SET_BUFF(frame)
    TOSHERO_INFO_SET_POINT(frame)
    TOSHERO_INFO_SET_READY(frame)
    TOSHERO_INFO_SET_REINFORCE(frame)
    TOSHERO_INFO_SET_ATTRIBUTE(frame)
    TOSHERO_INFO_SET_ATTRIBUTE_INFO(frame)
end

function ON_TOSHERO_STAGE_CLEAR()
    local frame = ui.GetFrame('toshero_info')
    if frame == nil then
        return
    end

    g_stage_start = false
    GET_CHILD_RECURSIVELY(frame, 'ready'):SetSkinName("test_gray_button")
end

function ON_TOSHERO_STAGE_TEXT(frame, msg, argStr, stage)
    local frame = ui.GetFrame('toshero_info')
    if frame == nil then
        return
    end

    GET_CHILD_RECURSIVELY(frame, 'title'):SetTextByKey("stage", stage)
end

function ON_TOSHERO_INFO_POINT()
    local frame = ui.GetFrame('toshero_info')
    if frame == nil then
        return
    end

    TOSHERO_INFO_SET_POINT(frame)
end

function ON_TOSHERO_INFO_SET_STAGE(frame, msg, argStr, stage)
    RemoveLuaTimerFunc("TOSHERO_UPDATE_NEXT_STAGE_SECOND")

    local frame = ui.GetFrame('toshero_info')
    if frame == nil then
        return
    end
    g_stage_start = true
end

function ON_TOSHERO_ZONE_ENTER(frame, msg, argStr, stage)
    RemoveLuaTimerFunc("TOSHERO_UPDATE_NEXT_STAGE_SECOND")
end

function ON_TOSHERO_INFO_NEXT_STAGE(frame, msg, argStr, argNum)
    g_next_stage_time = argNum

    AddUniqueTimerFunccWithLimitCount("TOSHERO_UPDATE_NEXT_STAGE_SECOND", 1000, argNum)
end

function ON_TOSHERO_HIDDEN_BUFF_ADD(frame,msg,argStr,argNum)
    GET_CHILD_RECURSIVELY(frame, "buff_hidden_icon"):SetVisible(1);
end

-- Open/Close
function TOSHERO_INFO_OPEN()
    g_toshero_reinforce_image = "None"
end

-- Ready
function TOSHERO_INFO_SET_READY(frame)
    local ready = GET_CHILD_RECURSIVELY(frame, 'ready')

    ready:SetTextByKey("readyCount", GetTOSHeroReadyCount())
    ready:SetTextByKey("playerCount", GetTOSHeroPlayerCount())
end

function TOSHERO_UPDATE_NEXT_STAGE_SECOND()
    if g_next_stage_time == 0 then
        return
    end

    if g_next_stage_time % 10 == 0 or g_next_stage_time <= 5 then
        addon.BroadMsg("NOTICE_Dm_!", ScpArgMsg("TOSHeroNextStage{SEC}", "SEC", g_next_stage_time), 3)
    end

    g_next_stage_time = g_next_stage_time - 1
end

-- Point
function TOSHERO_INFO_SET_POINT(frame)
    local point = GET_CHILD_RECURSIVELY(frame, 'point_info')
    local nowPoint = GetTOSHeroPoint()

    point:SetTextByKey("point", GET_COMMAED_STRING(nowPoint))
end

-- Attribute
function TOSHERO_INFO_SET_ATTRIBUTE(frame)
    local attribute = GET_CHILD_RECURSIVELY(frame, 'attribute_pic')
    local nowAttribute = GetTOSHeroAttribute()
    GET_CHILD_RECURSIVELY(frame, 'attribute_txt'):ShowWindow(1)

    if nowAttribute > 1 then
        local attributeClass = GetClassByType("TOSHeroAttribute", nowAttribute)
        local attributeImage = TryGetProp(attributeClass, "Image", "None")
        
        GET_CHILD_RECURSIVELY(frame, 'attribute_txt'):ShowWindow(0)
        attribute:SetImage(attributeImage)
    end
end

function TOSHERO_INFO_SET_ATTRIBUTE_INFO(frame)
    local nowAttribute = GetTOSHeroAttribute()
    local nowAttributeClass = GetClassByType("TOSHeroAttribute", nowAttribute)

    for i = 2, 4 do
        local text = GET_CHILD_RECURSIVELY(frame, 'attribute_info_txt_'..i)
        local string = ""

        local attributeClass = GetClassByType("TOSHeroAttribute", i)

        string = string .. "{img " .. attributeClass.Image .. " 20 20}"

        local rate = TryGetProp(nowAttributeClass, attributeClass.ClassName, 0)

        if rate > 0 then
            string = string .. " {img hero_icon_up 11 10}"
        end

        if rate < 0 then
            string = string .. " {img hero_icon_down 11 10}"
        end

        text:SetText(string)
    end
end

-- Buff
function TOSHERO_INFO_SET_BUFF(frame)
    local buff = GET_CHILD_RECURSIVELY(frame, 'buff_pic')
    local buffBtn = GET_CHILD_RECURSIVELY(frame, 'buff_btn')
    local nowIndex = GetTOSHeroBuffIndex()

    if nowIndex == -1 then
        buff:SetImage("")
    else
        local nowType = GetTOSHeroBuffType(nowIndex)
        local nowBuff = GetClassByType("Buff", nowType + g_toshero_group_index)

        buff:SetImage("icon_"..nowBuff.Icon)
        buffBtn:SetTextTooltip(nowBuff.ToolTip)
    end
end

--  Reinforce
function TOSHERO_INFO_SET_REINFORCE(frame)
    if g_toshero_reinforce_image == "None" then
        GET_CHILD_RECURSIVELY(frame, 'reinforce_txt'):SetVisible(1)
    else
        GET_CHILD_RECURSIVELY(frame, 'reinforce_txt'):SetVisible(0)
    end

    GET_CHILD_RECURSIVELY(frame, 'reinforce_pic'):SetImage(g_toshero_reinforce_image)
end

-- Request
function TOSHERO_INFO_REQUEST_READY()
    local frame = ui.GetFrame("toshero_info")
    local skin = ""
    if GetTOSHeroState() == 1 then
        toshero.RequestReady(0)
        skin = "test_gray_button"
    else
        toshero.RequestReady(1)
        skin = "hero_btn_green2"
    end

    if g_stage_start == false then
        GET_CHILD_RECURSIVELY(frame, 'ready'):SetSkinName(skin)
    end
end