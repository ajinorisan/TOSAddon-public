-- v1.0.1 1chが満員の場合にエラーになるのでギルドイベント地域に飛んでからチャンネルチェンジ
-- v1.0.2 23.09.05patch対応。ボルタからドラグーンに変更
-- v1.0.3 TPショップ開くと消えるのを修正
-- v1.0.4 UI気に食わなかったので修正
-- v1.0.5 ウルトラワイド対応。
local addonName = "GUILDEVENTWARP"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.5"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

-- local FRAME_X_POS = 1785
-- local FRAME_Y_POS = 4
local ICON_SIZE = 28
local ICON_SPACING = 35
local CH1_ID = 0

g.channel_change = false

function GUILDEVENTWARP_ON_INIT(addon, frame)
    g.addon = addon
    g.frame = frame
    g.lang = option.GetCurrentCountry()

    g.frame:SetSkinName('None')
    g.frame:SetGravity(ui.RIGHT, ui.TOP)
    local rect = g.frame:GetMargin();
    g.frame:SetMargin(rect.left, rect.top + 4, rect.right + 35, rect.bottom);
    -- g.frame:SetPos(FRAME_X_POS, FRAME_Y_POS)
    g.frame:SetTitleBarSkin("None")

    GUILDEVENTWARP_frame_init()

    if g.channel_change then
        g.channel_change = false
        g.addon:RegisterMsg("GAME_START_3SEC", "GUILDEVENTWARP_ch_change")
    end
end

function GUILDEVENTWARP_frame_init()
    g.frame:RemoveAllChild()

    local guild_event_info = {{
        name = "dragoon",
        event_id = 500,
        monster = "guild_boss_dragoon_ex",
        tooltip = g.lang == "Japanese" and "{ol}ギルドイベント、ドラグーンのマップに移動します" or
            "{ol}Guild event move to the Dragoon map",
        click_func_name = "GUILDEVENTWARP_move_to_guild_event"
    }, {
        name = "giltine",
        monster = "Legend_Boss_Giltine_Guild",
        event_id = 501,
        tooltip = g.lang == "Japanese" and "{ol}ギルドイベント、ギルティネのマップに移動します" or
            "{ol}Guild event move to the Guiltine map",
        click_func_name = "GUILDEVENTWARP_move_to_guild_event"
    }, {
        name = "baubas",
        monster = "GuildEvent_npc_baubas2",
        event_id = 502,
        tooltip = g.lang == "Japanese" and "{ol}ギルドイベント、バウバスのマップに移動します" or
            "{ol}Guild event move to the Baubus map",
        click_func_name = "GUILDEVENTWARP_move_to_guild_event"
    }}

    local current_x = 0

    for _, info in ipairs(guild_event_info) do
        local slot_name = info.name .. "_slot"
        local slot = g.frame:CreateOrGetControl("slot", slot_name, current_x, 0, ICON_SIZE, ICON_SIZE)
        AUTO_CAST(slot)
        slot:EnablePop(0)
        slot:EnableDrop(0)
        slot:EnableDrag(0)
        slot:SetEventScript(ui.LBUTTONUP, info.click_func_name)
        slot:SetEventScriptArgString(ui.LBUTTONUP, tostring(info.event_id))

        local mon_cls = GetClass("Monster", info.monster)
        if mon_cls then
            local icon = CreateIcon(slot);
            AUTO_CAST(icon)
            icon:SetImage(mon_cls.Icon)
            icon:SetTextTooltip(info.tooltip)
        end

        current_x = current_x + ICON_SPACING
    end

    g.frame:Resize(current_x - (ICON_SPACING - ICON_SIZE), ICON_SIZE)
    g.frame:ShowWindow(1)
end

function GUILDEVENTWARP_move_to_guild_event(_, _, event_id)
    g.channel_change = true
    _BORUTA_ZONE_MOVE_CLICK(event_id)
end

function GUILDEVENTWARP_ch_change()
    local current_channel_num = session.loginInfo.GetChannel() + 1
    if current_channel_num ~= 1 then
        RUN_GAMEEXIT_TIMER("Channel", CH1_ID);
    end
end

