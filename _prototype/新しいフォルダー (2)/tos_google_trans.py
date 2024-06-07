
import json
import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import ctypes

filename = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Tree of Savior (Japanese Ver.)\\addons\\tos_google_trans\\settings.json"

def load_settings(filename):
    with open(filename, "r", encoding="utf-8") as file:
        settings = json.load(file)
    return settings

def translate_text(text):
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--incognito')
    driver = webdriver.Chrome(options=chrome_options)
    driver.get("https://translate.google.co.jp/?sl=auto&tl=ja&text=" + text)
    wait = WebDriverWait(driver, 5)  # 最大10秒待機
    try:
        element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "span[jsname='W297wb']")))
        translated_text = element.text
    except:
        translated_text = "翻訳に失敗しました。"
    driver.quit()
    return translated_text

def message_box(text):
    ctypes.windll.user32.MessageBoxW(0, text, "google翻訳", 0)

if __name__ == "__main__":
    settings = load_settings(filename)
    initial_text = settings["trans_text"]  # 設定ファイルから初期テキストを読み込む
    current_text = initial_text
  
    while True:
        new_settings = load_settings(filename)  # 設定ファイルを再度読み込む
        new_text = new_settings["trans_text"]  # 新しいテキストを取得
       
        if new_text != current_text:  # テキストが変更されたら翻訳する
            translated_text = translate_text(new_text)
            print(translated_text)
            current_text = new_text
        time.sleep(0.1)
