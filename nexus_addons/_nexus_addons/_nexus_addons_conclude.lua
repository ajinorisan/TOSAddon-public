local addon_name = "_NEXUS_ADDONS"
local addon_name_lower = string.lower(addon_name)
local author = "norisan"
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addon_name] = _G["ADDONS"][author][addon_name] or {}
local g = _G["ADDONS"][author][addon_name]
local json = require("json")

local function ts(...)
    local num_args = select("#", ...)
    if num_args == 0 then
        print("ts() -- 引数がありません")
        return
    end
    local string_parts = {}
    for i = 1, num_args do
        local arg = select(i, ...)
        local arg_type = type(arg)
        local is_success, value_str = pcall(tostring, arg)
        if not is_success then
            value_str = "[tostringでエラー発生]"
        end
        table.insert(string_parts, string.format("(%s) %s", arg_type, value_str))
    end
    print(table.concat(string_parts, "   |   "))
end

--[[function Indun_list_viewer_APPS_TRY_MOVE_BARRACK()
    if g.get_map_type() == "City" then
        Indun_list_viewer_save_current_char_counts()
    end
    if g.settings.instant_cc.use == 1 then
        Instant_cc_APPS_TRY_MOVE_BARRACK_(nil, nil, nil, 0)
        return
    end
    Indun_list_viewer_APPS_TRY_LEAVE("Barrack")
end

function Indun_list_viewer_APPS_TRY_LEAVE(type)
    if Indun_list_viewer_CHECK_ALERT(type) then
        return
    end
    if g.FUNCS["APPS_TRY_LEAVE"] then
        g.FUNCS["APPS_TRY_LEAVE"](type)
    end
end]]

--[[function Instant_cc_APPS_TRY_LEAVE(type)
    local use_icc = g.settings.instant_cc.use ~= 0
    local use_ilv = g.settings.indun_list_viewer.use ~= 0
    if use_icc then
        Instant_cc_APPS_TRY_LEAVE_(type)
        return
    end
    if use_ilv then
        Indun_list_viewer_APPS_TRY_LEAVE(type)
        return
    end
    if g.FUNCS["APPS_TRY_LEAVE"] then
        g.FUNCS["APPS_TRY_LEAVE"](type)
    end
end

function Instant_cc_EXPIREDITEM_ALERT_ON_MSG(frame, msg, arg_str, arg_num)
    if msg == "EXPIREDITEM_ALERT_OPEN" then
        Instant_cc_EXPIREDITEM_ALERT_OPEN(frame, arg_str)
        return
    end
end

function Instant_cc_EXPIREDITEM_ALERT_OPEN(frame, arg_str)
    local expireditem_alert = ui.GetFrame("expireditem_alert")
    local near_future_sec = tonumber(expireditem_alert:GetUserConfig("NearFutureSec"))
    local itemlist = GET_CHILD(expireditem_alert, "itemlist", "ui::CGroupBox")
    itemlist:RemoveAllChild()
    local start_index = 0
    local ypos = 0
    if g.instant_cc_sweep_tbl then
        for key, data in ipairs(g.instant_cc_sweep_tbl) do
            if type(data) == "table" then
                local ctrlset = itemlist:CreateOrGetControlSet("expireditem_ctrlset",
                    "expireditem_ctrlset" .. start_index + 1, 0, ypos)
                AUTO_CAST(ctrlset)
                local name = GET_CHILD_RECURSIVELY(ctrlset, "name", "ui::CRichText")
                local expiration_time = GET_CHILD_RECURSIVELY(ctrlset, "expirationTime", "ui::CRichText")
                local remaining_time = GET_CHILD_RECURSIVELY(ctrlset, "remainingTime", "ui::CRichText")
                local item_pic = GET_CHILD_RECURSIVELY(ctrlset, "item_pic", "ui::CPicture")
                local buff_cls = GetClassByType("Buff", data.buff_id)
                if buff_cls then
                    name:SetTextByKey("itemname", buff_cls.Name)
                    local icon_name = "icon_" .. buff_cls.Icon
                    item_pic:SetImage(icon_name)
                end
                local expiration_systime = geTime.GetServerSystemTime()
                expiration_systime = imcTime.AddSec(expiration_systime, data.buff_time / 1000)
                expiration_time:SetTextByKey("year", expiration_systime.wYear)
                expiration_time:SetTextByKey("month", GET_TWO_DIGIT_STR(expiration_systime.wMonth))
                expiration_time:SetTextByKey("day", GET_TWO_DIGIT_STR(expiration_systime.wDay))
                local buff_time = data.buff_time / 1000
                local days = math.floor(buff_time / 86400)
                local hours = math.floor((buff_time % 86400) / 3600)
                local mins = math.floor(((buff_time % 86400) % 3600) / 60)
                local sec = ((buff_time % 86400) % 3600) % 60
                local dif_sec_msg = ""
                if days > 0 then
                    dif_sec_msg = ScpArgMsg("{Day}Day{Hour}Hour{Min}Min", "Day", days, "Hour", hours, "Min", mins)
                elseif hours > 0 then
                    dif_sec_msg = ScpArgMsg("{Hour}Hour{Min}Min{Sec}Sec", "Hour", hours, "Min", mins, "Sec", sec)
                elseif mins > 0 then
                    dif_sec_msg = ScpArgMsg("{Min}Min{Sec}Sec", "Min", mins, "Sec", sec)
                else
                    dif_sec_msg = ScpArgMsg("{Sec}Sec", "Sec", sec)
                end
                remaining_time:SetText(dif_sec_msg)
                local time_parent = remaining_time:GetParent()
                local amend_h = remaining_time:GetY() + remaining_time:GetHeight()
                if amend_h < time_parent:GetHeight() then
                    amend_h = ctrlset:GetHeight()
                else
                    local addedHeight = amend_h - time_parent:GetHeight()
                    ctrlset:Resize(ctrlset:GetWidth(), ctrlset:GetHeight() + addedHeight)
                end
                ypos = ypos + ctrlset:GetHeight()
                start_index = start_index + 1
            end
        end
    end
    if IS_NEED_TO_ALERT_TOKEN_EXPIRATION(near_future_sec, itemlist) then
        ypos = ASK_EXPIREDITEM_ALERT_TOKEN(expireditem_alert, itemlist, start_index, ypos)
        start_index = start_index + 1
    end
    local list = GET_SCHEDULED_TO_EXPIRED_ITEM_LIST(near_future_sec)
    if list and #list >= 1 then
        ypos = ASK_EXPIREDITEM_ALERT_LIFETIME(expireditem_alert, itemlist, near_future_sec, start_index, ypos)
        start_index = start_index + #list
    end
    expireditem_alert:Resize(expireditem_alert:GetWidth(), expireditem_alert:GetOriginalHeight() + itemlist:GetHeight())
    if arg_str then
        expireditem_alert:SetUserValue("TimerType", arg_str)
    end
    expireditem_alert:ShowWindow(1)
end]]
