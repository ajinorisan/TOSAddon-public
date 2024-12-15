local EVENTMSG_CNT_MAX = 3
local EVENTMSG_OPENMSG = {}
local EVENTMSG_STARTY = 380
local EVENTMSG_OPENCNT = 0

function EVENTMSG_ON_INIT(addon, frame)
end

function EVENTMSG_CLOSE(frame)
    local keyword = frame:GetUserValue("KEYWORD")
    for i = 1, #EVENTMSG_OPENMSG do
        if EVENTMSG_OPENMSG[i] == keyword then
            EVENTMSG_OPENMSG[i] = EVENTMSG_OPENMSG[#EVENTMSG_OPENMSG]
            EVENTMSG_OPENMSG[#EVENTMSG_OPENMSG] = nil
            break
        end
    end

    EVENTMSG_SORT_FRAME()
end

function ADD_EVENTMSG(icon, keyword, msg, second)
    if keyword == '' or keyword == nil then return end

    local frameName = "EVENT_MSG_"..keyword;
    local frame = ui.GetFrame(frameName)
    if frame ~= nil then
        EVENTMSG_UPDATE_FRAME(frame, icon, keyword, msg, second)
    else
        EVENTMSG_CREATE_FRAME(icon, keyword, msg, second)
    end

    EVENTMSG_SORT_FRAME()
end

function EVENTMSG_OPEN(frame)

end

function EVENTMSG_CREATE_FRAME(icon, keyword, msg, second)
    local frameName = "EVENT_MSG_"..keyword;
    local frame = ui.CreateNewFrame("eventmsg", frameName);
    if frame == nil then
        return nil;
    end
    
    EVENTMSG_OPENMSG[#EVENTMSG_OPENMSG + 1] = keyword
    EVENTMSG_OPENCNT = EVENTMSG_OPENCNT + 1
    frame:SetUserValue("cnt", EVENTMSG_OPENCNT)
    frame:SetUserValue("LAST_Y", frame:GetMargin().top)

    EVENTMSG_UPDATE_FRAME(frame, icon, keyword, msg, second)

    frame:ShowWindow(1)
end

function EVENTMSG_UPDATE_FRAME(frame, icon, keyword, msg, second)
    if frame == nil then return end

    frame:SetUserValue("KEYWORD", keyword)

    local bg = GET_CHILD_RECURSIVELY(frame, "bg", "ui::CGroupBox")
    local msg_text = GET_CHILD_RECURSIVELY(frame, "msg", "ui::CRichText")
    msg_text:SetTextByKey("value", msg)
    
    bg:SetColorTone("AAFFFFFF")

    bg:Resize(bg:GetWidth(), msg_text:GetHeight() + 24)
    frame:Resize(frame:GetWidth(), bg:GetHeight() + 10)

    frame:SetDuration(second)
end

local function EVENTMSG_FRAME_SORT_FILTER(frameA, frameB)
    if frameA["duration"] ~= frameB["duration"] then
        return frameA["duration"] < frameB["duration"]
    end

    local cntA = frameA["frame"]:GetUserIValue("cnt")
    local cntB = frameB["frame"]:GetUserIValue("cnt")

    return cntA < cntB
end

function EVENTMSG_SORT_FRAME()
    local framelist = {}
    for i = 1, #EVENTMSG_OPENMSG do
        local frameTemp = ui.GetFrame("EVENT_MSG_"..EVENTMSG_OPENMSG[i])
        if frameTemp ~= nil and frameTemp:GetDuration() > 0 then
            local frameinfo = {}
            frameinfo["frame"] = frameTemp
            frameinfo["duration"] = frameTemp:GetDuration()
            framelist[#framelist + 1] = frameinfo
        end
    end
    
    table.sort(framelist, EVENTMSG_FRAME_SORT_FILTER)
    
    for i = 1, #framelist - EVENTMSG_CNT_MAX do
        local frame = framelist[i]["frame"]
        ui.CloseFrame(frame:GetName())
    end

    local y = EVENTMSG_STARTY
    local moveY = 0
    local startIndex = 1
    if #framelist - EVENTMSG_CNT_MAX > 0 then
        startIndex = #framelist - EVENTMSG_CNT_MAX + 1
    end
    for i = startIndex, #framelist do
        local frame = framelist[i]["frame"]
        local lastY = frame:GetUserIValue("LAST_Y")
        local isFirstOpen = frame:GetUserValue("FIRST_OPEN")
        moveY = y - lastY
        if isFirstOpen == "NO" then
            UI_PLAYFORCE_CUSTOM_MOVE(frame, 0, moveY)
        else
            frame:SetUserValue("FIRST_OPEN", "NO")
            frame:SetMargin(0, y, frame:GetMargin().right, 0)
        end
        frame:SetUserValue("LAST_Y", y)
        y = y + frame:GetHeight()
    end
end
