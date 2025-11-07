-- v1.0.1 小数点第2位まで最適化
local addonName = "BOSS_GAUGE"
local addonNameLower = string.lower(addonName)
local author = "norisan"
local ver = "1.0.1"

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][author] = _G["ADDONS"][author] or {}
_G["ADDONS"][author][addonName] = _G["ADDONS"][author][addonName] or {}
local g = _G["ADDONS"][author][addonName]

g.settingsFileLoc = string.format('../addons/%s/settings.json', addonNameLower)

local acutil = require("acutil")

local base = {}

function g.SetupHook(func, baseFuncName)
    local addonUpper = string.upper(addonName)
    local replacementName = addonUpper .. "_BASE_" .. baseFuncName
    if (_G[replacementName] == nil) then
        _G[replacementName] = _G[baseFuncName];
        _G[baseFuncName] = func
    end
    base[baseFuncName] = _G[replacementName]
end

function BOSS_GAUGE_ON_INIT(addon, frame)

    g.addon = addon
    g.frame = frame
    acutil.setupEvent(addon, "TARGETINFOTOBOSS_TARGET_SET", "boss_gauge_TARGETINFOTOBOSS_TARGET_SET");
    acutil.setupEvent(addon, "TARGETINFOTOBOSS_UPDATE_SHIELD", "boss_gauge_TARGETINFOTOBOSS_UPDATE_SHIELD");
    acutil.setupEvent(addon, "TARGETINFOTOBOSS_ON_MSG", "boss_gauge_TARGETINFOTOBOSS_ON_MSG");
    g.stun_text = "STUN:(0.00%)"
    g.shield_text = "SHIELD:(0.00%)"
end

function boss_gauge_TARGETINFOTOBOSS_ON_MSG(frame, msg)
    local frame, msg, argStr, argNum = acutil.getEventArgs(msg)
    if msg == 'TARGET_UPDATE' or msg == 'TARGET_BUFF_UPDATE' then
        local stat = info.GetStat(session.GetTargetBossHandle());
        if stat ~= nil then
            local cur_faint = stat.cur_faint;
            local max_faint = stat.max_faint;
            if cur_faint > 0 and max_faint > 0 then
                local faint_gauge = GET_CHILD_RECURSIVELY(frame, "faint", "ui::CGauge");
                if faint_gauge ~= nil then
                    local diff_faint = max_faint - cur_faint;
                    local stun_richtext = GET_CHILD_RECURSIVELY(frame, "stun_richtext")
                    AUTO_CAST(stun_richtext)

                    if (tonumber(diff_faint) / tonumber(max_faint) * 100) > 0 then
                        g.stun_text = "STUN:" ..
                                          string.format("(%.2f%%)", (tonumber(diff_faint) / tonumber(max_faint) * 100))
                    else
                        g.stun_text = "STUN:(0.00%)"
                    end
                    stun_richtext:SetText(g.stun_text)
                end
            end
        end

    end
end

function boss_gauge_TARGETINFOTOBOSS_UPDATE_SHIELD(frame, msg)
    local data = acutil.getEventArgs(msg)
    local data_list = StringSplit(data, '/');
    if #data_list > 0 then
        local shield = data_list[1];
        local mhp = tonumber(data_list[2]);
        local frame = ui.GetFrame("targetinfotoboss");
        local shield_richtext = GET_CHILD_RECURSIVELY(frame, "shield_richtext")
        AUTO_CAST(shield_richtext)

        if (tonumber(shield) / tonumber(mhp) * 100) > 0 then
            g.shield_text = "SHIELD:" .. string.format("(%.2f%%)", (tonumber(shield) / tonumber(mhp) * 100))
        else
            g.shield_text = "SHIELD:(0.00%)"
        end
        shield_richtext:SetText(g.shield_text)

    end
end

function boss_gauge_TARGETINFOTOBOSS_TARGET_SET(frame, msg)
    local frame, msg, str, num = acutil.getEventArgs(msg)
    local nametext = GET_CHILD_RECURSIVELY(frame, "name", "ui::CRichText")
    AUTO_CAST(nametext)

    local text_y = nametext:GetY()
    local text_x = nametext:GetX()
    local text_width = nametext:GetWidth()

    if text_width > 190 then
        text_width = 190
    end
    local text_height = nametext:GetHeight()

    local stun_richtext = frame:CreateOrGetControl("richtext", "stun_richtext", text_x + text_width + 5, text_y, 120,
        text_height);
    AUTO_CAST(stun_richtext)
    stun_richtext:SetText(g.stun_text)
    stun_richtext:SetFontName("yellow_18_ol")
    stun_richtext:ShowWindow(1)

    local shield_richtext = frame:CreateOrGetControl("richtext", "shield_richtext", text_x + text_width + 145, text_y,
        120, text_height);
    AUTO_CAST(shield_richtext)

    shield_richtext:SetText(g.shield_text)
    shield_richtext:SetFontName("yellow_18_ol")
    shield_richtext:ShowWindow(1)
end

