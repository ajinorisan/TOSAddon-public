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

' JavaScript を使用して翻訳結果を取得
Dim jsCode
jsCode = "(function() { var text = ''; var interval = setInterval(function() { var translationElement = document.getElementsByClassName('translation')[0]; if (translationElement && translationElement.innerText.trim() !== '') { text = translationElement.innerText; clearInterval(interval); WScript.Echo(text); } }, 5000); })();"
translatedText = objWshShell.Exec("cmd.exe /c chrome.exe --headless --disable-gpu --dump-dom javascript:" & jsCode).StdOut.ReadAll

MsgBox translatedText