EP14とEP15地域の敵を倒した数をカウントします。

左上キャラ情報の右あたりにカウンターが出ます。

フォントダサイのなんとかしたい。

めにまにさんに直してもらったよ！ありがとう！

コードも洗練された感じになってカッコイイよね

あとはヴァカコの数じゃなく倒した数でイキってこ

メモ
function _G.KLCOUNT_TIME_UPDATE()
    local time = imcTime.GetAppTimeMS() - g.starttime
    local h = math.floor(time / (60 * 60 * 1000))
    local m = math.floor((time / (60 * 1000)) % 60)
    local s = math.floor((time / 1000) % 60)
    local frame = _G.ui.GetFrame("klcount")
    local timer = frame:CreateOrGetControl("richtext", "timer_text", 120, 60, 200, 30)
    timer:SetText(string.format("{s18}%02d:%02d:%02d{/}", h, m, s))
    ReserveScript("_G.KLCOUNT_TIME_UPDATE()", 1.0)
end
これで実行するとクライアント落ちる

ReserveScript("_G.KLCOUNT_TIME_UPDATE()", 1.0)ここをコメントアウトしたら落ちない
