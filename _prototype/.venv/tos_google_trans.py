
import json
import time
import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import ctypes

script_dir = os.path.dirname(os.path.abspath(__file__))


filename = os.path.join(script_dir, "settings.json")
#filename = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Tree of Savior (Japanese Ver.)\\addons\\tos_google_trans\\settings.json"
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
    wait = WebDriverWait(driver, 5)  # 最大5秒待機
    try:
        element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "span[jsname='W297wb']")))
        translated_text = element.text
    except:
        translated_text = "翻訳に失敗しました。"
    driver.quit()
    return translated_text

def message_box(text):
    ctypes.windll.user32.MessageBoxW(0, text, "google翻訳", 0)

output_file = os.path.join(script_dir, "output.json")
names_file = os.path.join(script_dir, "names.json")

if __name__ == "__main__":
    settings = load_settings(filename)
    initial_text = settings["trans_text"]  # 設定ファイルから初期テキストを読み込む
    current_text = initial_text

    while True:
        new_settings = load_settings(filename)  # 設定ファイルを再度読み込む
        new_text = new_settings["trans_text"]  # 新しいテキストを取得
        new_name = new_settings["name"]
        new_id = new_settings["chat_id"]

        if new_text != current_text:  # テキストが変更されたら翻訳する
            translated_text = translate_text(new_id + "@/@" + new_name + "@/@" + new_text)
            print(translated_text)
            converted_text =translated_text.replace("＠／＠", "@/@")
            print(converted_text)
            splitted_text = converted_text.split("@/@")
            chat_id = splitted_text[0]
            name = splitted_text[1]
            trans_text = splitted_text[2]

            # 結果を output.json ファイルに書き込む
            output_data = {chat_id:trans_text}
            if os.path.exists(output_file):
                with open(output_file, "r", encoding="utf-8") as f:
                    output_data = json.load(f)

            output_data[new_id] = translated_text
            with open(output_file, "w", encoding="utf-8") as f:
                json.dump(output_data, f, ensure_ascii=False, indent=4)

            # names.jsonファイルに新しい名前を追加する
            if os.path.exists(names_file):
                with open(names_file, "r", encoding="utf-8") as f:
                    existing_names = json.load(f)
            else:
                existing_names = {}

            existing_names[new_id] = new_name
            with open(names_file, "w", encoding="utf-8") as f:
                json.dump(existing_names, f, ensure_ascii=False, indent=4)

            current_text = new_text

        time.sleep(0.1)



"""if not os.path.exists(output_file):
    with open(output_file, "w") as f:
        json.dump({}, f)"""