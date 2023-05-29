local addonName = "FREEFROMLITTLESTRESS"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.0"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

local acutil = require("acutil")

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

g.settings = {
    rrfp_x = 1100,
    rrfp_y = 100
}

-- indunframe:ShowWindow(1)

function FREEFROMLITTLESTRESS_SAVE_SETTINGS()
    -- CHAT_SYSTEM("save")
    acutil.saveJSON(g.settingsFileLoc, g.settings);

end

function FREEFROMLITTLESTRESS_LOADSETTINGS()

    local settings, err = acutil.loadJSON(g.settingsFileLoc, g.settings)

    if err then
        -- 設定ファイル読み込み失敗時処理
        CHAT_SYSTEM(string.format("[%s] cannot load setting files", addonNameLower))
    end
    if not settings then
        settings = g.settings
    end

    g.settings = settings
end

function FREEFROMLITTLESTRESS_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    CHAT_SYSTEM(addonNameLower .. " loaded")

    acutil.setupHook(FREEFROMLITTLESTRESS_RAID_RECORD_INIT, "RAID_RECORD_INIT")
    addon:RegisterMsg("RESTART_HERE", "FREEFROMLITTLESTRESS_FRAME_MOVE")
    addon:RegisterMsg("RESTART_CONTENTS_HERE", "FREEFROMLITTLESTRESS_FRAME_MOVE")
    -- addon:RegisterMsg("INDUNINFO_MAKE_DETAIL_BOSS_SELECT_BY_RAID_TYPE", "FREEFROMLITTLESTRESS_INDUNINFO_UPDATE")
    -- acutil.setupHook(FREEFROMLITTLESTRESS_INDUNINFO_UPDATE, "INDUNINFO_DETAIL_BOSS_SELECT_LBTN_CLICK")
    acutil.setupHook(FREEFROMLITTLESTRESS_INDUNINFO_CHAT_OPEN, "INDUNINFO_CHAT_OPEN")
    FREEFROMLITTLESTRESS_LOADSETTINGS()
    FREEFROMLITTLESTRESS_FRAME_INIT()

end

function FREEFROMLITTLESTRESS_INDUNINFO_UPDATE(ctrl_set, btn, clicked)
    if ctrl_set == nil or btn == nil then
        return;
    end
    local parent = ctrl_set:GetParent();
    if IS_INDUNINFO_DETAIL_BOSS_SELECT_LOCK_STATE(ctrl_set) == true then
        return;
    end
    INDUNINFO_DETAIL_BOSS_SELECT_CHECK_UPDATE(parent, ctrl_set);
    if clicked == "click" then
        imcSound.PlaySoundEvent("button_click_7");
    end
    local frame = parent:GetTopParentFrame();
    local indun_cls_name = ctrl_set:GetName();
    local indunframe = ui.GetFrame("induninfo")
    local indungbox = indunframe:CreateOrGetControl("groupbox", "textbox_1", 200, 100, 400, 200)
    indungbox:SetSkinName("None")
    indungbox:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    local msgtexts = indungbox:CreateOrGetControl("richtext", "msgtexts_1", 0, 50, 295, 225)
    msgtexts:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    msgtexts:SetText("{@st55_a}Spreader Select")
    local msgtexts2 = indungbox:CreateOrGetControl("richtext", "msgtexts_2", 0, 0, 295, 225)
    msgtexts2:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    msgtexts2:SetText("{@st55_a}プロパゲ行くんか！？")
    local msgtextf = indungbox:CreateOrGetControl("richtext", "msgtextf_1", 0, 50, 295, 225)
    msgtextf:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    msgtextf:SetText("{@st55_a}Falouros Select")
    local msgtextf2 = indungbox:CreateOrGetControl("richtext", "msgtextf_2", 0, 0, 295, 225)
    msgtextf2:SetGravity(ui.CENTER_HORZ, ui.CENTER_VERT)
    msgtextf2:SetText("{@st55_a}ファロ行くんか！？")
    if string.match(indun_cls_name, "Goddess_Raid_Spreader_Auto") then
        msgtextf:ShowWindow(0)
        msgtexts:ShowWindow(1)
        msgtextf2:ShowWindow(0)
        msgtexts2:ShowWindow(1)
        ReserveScript(string.format('FREEFROMLITTLESTRESS_TEXT_DELETE()'), 5.0)

    elseif string.match(indun_cls_name, "Goddess_Raid_Falouros_Auto") then
        msgtextf:ShowWindow(1)
        msgtexts:ShowWindow(0)
        msgtextf2:ShowWindow(1)
        msgtexts2:ShowWindow(0)
        ReserveScript(string.format('FREEFROMLITTLESTRESS_TEXT_DELETE()'), 5.0)
    else
        msgtextf:ShowWindow(0)
        msgtexts:ShowWindow(0)
        msgtextf2:ShowWindow(0)
        msgtexts2:ShowWindow(0)
        return
    end

    local indun_cls = GetClass("Indun", indun_cls_name);
    if indun_cls == nil then
        return;
    end

    INDUNFINO_MAKE_DETAIL_COMMON_INFO_BY_CATEGORY_TYPE(frame, indun_cls);
    INDUNFINO_MAKE_DETAIL_DUNGEON_RESTRICT_BY_CATEGORY_TYPE(frame, indun_cls);
    INDUNFINO_MAKE_DETAIL_ITEM_LIST_INFO_SETTING(frame, indun_cls);

end

function FREEFROMLITTLESTRESS_TEXT_DELETE()
    local indunframe = ui.GetFrame("induninfo")
    local indungbox = GET_CHILD_RECURSIVELY(indunframe, "textbox_1")
    local msgtexts = GET_CHILD_RECURSIVELY(indunframe, "msgtexts_1")
    local msgtexts2 = GET_CHILD_RECURSIVELY(indunframe, "msgtexts_2")
    local msgtextf = GET_CHILD_RECURSIVELY(indunframe, "msgtextf_1")
    local msgtextf2 = GET_CHILD_RECURSIVELY(indunframe, "msgtextf_2")
    msgtextf:ShowWindow(0)
    msgtexts:ShowWindow(0)
    msgtextf2:ShowWindow(0)
    msgtexts2:ShowWindow(0)

end

function FREEFROMLITTLESTRESS_UPDATESETTINGS(frame)
    if g.settings.rrfp_x ~= frame:GetX() or g.settings.rrfp_y ~= frame:GetY() then
        g.settings.rrfp_x = frame:GetX()
        g.settings.rrfp_y = frame:GetY()
        FREEFROMLITTLESTRESS_SAVE_SETTINGS()
    end
end

-- レイドクリアー時のフレームを移動して場所を覚えさせる。

function FREEFROMLITTLESTRESS_RAID_RECORD_INIT(frame)
    frame:SetOffset(g.settings.rrfp_x, g.settings.rrfp_y)
    frame:SetSkinName("shadow_box")
    frame:SetEventScript(ui.LBUTTONUP, "FREEFROMLITTLESTRESS_UPDATESETTINGS")

    local widgetList = {{
        name = "myInfo",
        font = "white_16_ol"
    }, {
        name = "friendInfo1",
        font = "white_16_ol"
    }, {
        name = "friendInfo2",
        font = "white_16_ol"
    }, {
        name = "friendInfo3",
        font = "white_16_ol"
    }}

    for i, widgetData in ipairs(widgetList) do
        local widget = GET_CHILD_RECURSIVELY(frame, widgetData.name)
        local name = GET_CHILD_RECURSIVELY(widget, "name")
        local time = GET_CHILD_RECURSIVELY(widget, "time")
        name:SetFontName(widgetData.font)
        time:SetFontName(widgetData.font)
    end

    GET_CHILD_RECURSIVELY(frame, "bgIndunClear"):ShowWindow(1)
    GET_CHILD_RECURSIVELY(frame, "textNewRecord"):ShowWindow(0)
end

--[[
function FREEFROMLITTLESTRESS_RAID_RECORD_INIT(frame)
    frame:SetOffset(g.settings.rrfp_x, g.settings.rrfp_y)
    -- frame:SetOffset(500, 300)
    frame:SetSkinName("shadow_box")
    frame:SetEventScript(ui.LBUTTONUP, "FREEFROMLITTLESTRESS_UPDATESETTINGS")
    FREEFROMLITTLESTRESS_UPDATESETTINGS(frame)

    local myInfo = GET_CHILD_RECURSIVELY(frame, "myInfo")
    local myInfo_name = GET_CHILD_RECURSIVELY(myInfo, "name")
    local myInfo_time = GET_CHILD_RECURSIVELY(myInfo, "time")
    myInfo_name:SetFontName("white_16_ol")
    myInfo_time:SetFontName("white_16_ol")

    local friendInfo1 = GET_CHILD_RECURSIVELY(frame, "friendInfo1")
    local friendInfo1_name = GET_CHILD_RECURSIVELY(friendInfo1, "name")
    local friendInfo1_time = GET_CHILD_RECURSIVELY(friendInfo1, "time")
    friendInfo1_name:SetFontName("white_16_ol")
    friendInfo1_time:SetFontName("white_16_ol")

    local friendInfo2 = GET_CHILD_RECURSIVELY(frame, "friendInfo2")
    local friendInfo2_name = GET_CHILD_RECURSIVELY(friendInfo2, "name")
    local friendInfo2_time = GET_CHILD_RECURSIVELY(friendInfo2, "time")
    friendInfo2_name:SetFontName("white_16_ol")
    friendInfo2_time:SetFontName("white_16_ol")

    local friendInfo3 = GET_CHILD_RECURSIVELY(frame, "friendInfo3")
    local friendInfo3_name = GET_CHILD_RECURSIVELY(friendInfo3, "name")
    local friendInfo3_time = GET_CHILD_RECURSIVELY(friendInfo3, "time")
    friendInfo3_name:SetFontName("white_16_ol")
    friendInfo3_time:SetFontName("white_16_ol")

    GET_CHILD_RECURSIVELY(frame, 'bgIndunClear'):ShowWindow(1)
    GET_CHILD_RECURSIVELY(frame, 'textNewRecord'):ShowWindow(0);

end
]]
-- 死んだ時に現れるフレームを移動可能に
function FREEFROMLITTLESTRESS_FRAME_MOVE()

    local rcframe = ui.GetFrame("restart_contents") -- フレームを移動可能に設定する
    rcframe:EnableMove(1)

    -- 多分コロニー時はこっちちゃうかな
    local rframe = ui.GetFrame("restart") -- フレームを移動可能に設定する
    rframe:EnableMove(1)
    rframe:SetSkinName("None")
    local buttonSkin = "chat_window" -- 適用したいスキンの名前
    local buttonNames = {"btn_restart_1", "btn_restart_2", "btn_restart_3", "btn_restart_4", "btn_restart_5"}

    for i, buttonName in ipairs(buttonNames) do
        local button = GET_CHILD_RECURSIVELY(rframe, buttonName)
        if button ~= nil then
            button:SetSkinName(buttonSkin)
        end
    end

end
