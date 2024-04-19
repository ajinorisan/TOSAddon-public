Dim objWshShell
Dim GC

Dim translateText
translateText = "hello"
 
Set objWshShell = WScript.CreateObject("WScript.Shell")
Set GC = CreateObject("WScript.Shell")
'シークレットモードで起動
GC.Run ("chrome.exe --incognito -url https://translate.google.co.jp/?sl=auto&tl=ja&text=" & translateText & "&op=translate")
 
objWshShell.AppActivate "chrome.exe"
WScript.Sleep 4000

' 翻訳結果を取得
Dim translatedText
translatedText = GetTranslatedText()


Function GetTranslatedText()
    ' 翻訳結果を取得するXPath
    Dim resultXPath
    resultXPath = ".//span[contains(@class, 'result-text')]//span"
MsgBox "翻訳結果: " & translatedText
    ' 翻訳結果を取得
    Dim translatedText
    translatedText = chrome.FindElement(By.XPath(resultXPath)).Text

    ' 翻訳結果を返す
    Set GetTranslatedText = translatedText
End Function