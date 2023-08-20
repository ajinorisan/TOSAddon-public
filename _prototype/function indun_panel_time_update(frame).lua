frame:RunUpdateScript("indun_panel_time_update", 10) -- ipframeにセット

g.starttime = imcTime.GetAppTimeMS() -- ON_INITに
g.ex = 0 -- 関数の外に定義

function indun_panel_time_update(frame)

    if (imcTime.GetAppTimeMS() - g.starttime) >= 86400 or g.ex == 0 then
        REQ_PVP_MINE_SHOP_OPEN()
        local frame = ui.GetFrame('earthtowershop')

        ReserveScript(string.format("INDUN_PANEL_EARTHTOWERSHOP_CLOSE('%s')", frame), 1.0)
        g.ex = 1
    end
    return 1
end
