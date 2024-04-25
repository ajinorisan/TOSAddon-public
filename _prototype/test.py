#https://qiita.com/ignorant/items/dcc00b68e602961b5744
import json

filename="C:\\Users\\TOYOC-304\\Desktop\\setting.json"
def load_settings(filename):
    with open(filename, "r", encoding="utf-8") as file:
        settings = json.load(file)
    return settings



from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# transを定義

settings = load_settings(filename)
trans_text = settings["trans_text"]
#trans_text = "this is a pen"
trans_sl = "auto"
trans_tl = "ja"
trans = "&sl=" + trans_sl + "&tl=" + trans_tl+"&text="+trans_text 

# Chromeオプションを設定
chrome_options = Options()
#chrome_options.add_argument('--headless')  # ヘッドレスモードを有効にする
chrome_options.add_argument('--incognito')  # シークレットモードを有効にする

# Chrome WebDriverを起動してGoogle翻訳を開く
driver = webdriver.Chrome(options=chrome_options)
driver.get("https://translate.google.co.jp/?" + trans)

   # 特定の要素が表示されるのを待つ
wait = WebDriverWait(driver, 10)  # 最大待機時間を10秒に設定
element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "span[jsname='W297wb']")))

# 翻訳結果のテキストを取得
translated_text = element.text

# 待機後、ドライバーを終了
driver.quit() 

    # ローカルファイルに翻訳結果を保存
output_file_path = "C:\\Users\\TOYOC-304\\Desktop\\translated_text.txt"  # 保存先ファイルのパス
with open(output_file_path, "w", encoding="utf-8") as f:
    f.write(translated_text)

    import ctypes
# メッセージボックスを表示する関数
def message_box():
    ctypes.windll.user32.MessageBoxW(0, translated_text, "google翻訳", 0)

# メッセージボックスを表示する
message_box()


