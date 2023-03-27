Ver1.0.1--単純に倒した敵をカウント

Ver1.0.2--タイマーついてます

---------------------------------------------

EP14とEP15地域の敵を倒した数をカウントします。

左上キャラ情報の右あたりにカウンターが出ます。

フォントダサイのなんとかしたい。

めにまにさんに直してもらったよ！ありがとう！

コードも洗練された感じになってカッコイイよね

あとはヴァカコの数じゃなく倒した数でイキってこ

備忘メモ

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

これで実行するとクライアント落ちる　他のアドオン全部抜いても無理

ReserveScript("_G.KLCOUNT_TIME_UPDATE()", 1.0)ここをコメントアウトしたら落ちない

なんかちゃう方法で回避必要

なんかちゃう方法めにまにさんに教えてもらった→addon:RegisterMsg("FPS_UPDATE", "KLCOUNT_TIME_UPDATE")
