
import json
import time
import os
import sys
import psutil
import ctypes
import threading
import selenium

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

exe_path = sys.executable
exe_dir = os.path.dirname(exe_path)

# settings.json ファイルへの絶対パスを計算する
filename = os.path.join(exe_dir, "settings.json")
# exeファイルの場所を取得する

#Tree of Savior (Kor) 韓国版
#TreeOfSavior　Papaya
#filename = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Tree of Savior (Japanese Ver.)\\addons\\tos_google_trans\\settings.json"
def load_settings(filename):
    with open(filename, "r", encoding="utf-8") as file:
        settings = json.load(file)
    return settings

def translate_text(text):
    settings = load_settings(filename)
    lang=settings["lang"]
    #print(lang)
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--incognito')
    driver = webdriver.Chrome(options=chrome_options)
    driver.get("https://translate.google.co.jp/?sl=auto&tl="+lang+"&text=" + text)
    wait = WebDriverWait(driver, 2)  # 最大2秒待機
    try:
        element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "span[jsname='W297wb']")))
        translated_text = element.text
    except:
        translated_text = "翻訳に失敗しました。"
    driver.quit()
    return translated_text

def message_box(text):
    ctypes.windll.user32.MessageBoxW(0, text, "google翻訳", 0)

print(exe_dir)
  
def monitor_process():
    # Client_tos_x64.exe のプロセスIDを取得
    process_id = None
    for process in psutil.process_iter():
        if process.name() == "Client_tos_x64.exe":
            process_id = process.pid
            #print("Client_tos_x64.exe のプロセスID:", process_id)
            break
    

    # Client_tos_x64.exe のプロセスを監視して、終了したら tos_google_trans.py も終了する
    while process_id is not None and psutil.pid_exists(process_id):
        time.sleep(10)  # 1秒ごとにプロセスの状態を確認する
    else:
        message_box("Client_tos_x64.exe のプロセスが終了しました。")
        # tos_google_trans.py も終了する
        tos_process = psutil.Process(os.getpid())
        tos_process.terminate()  # スクリプト自体のプロセスを終了
        return
        #print("tos_google_trans.py も終了しました。")

output_file = os.path.join(exe_dir, "output.json")
names_file = os.path.join(exe_dir, "names.json")

def monitor_process_thread():
    monitor_process()

# monitor_process()関数を別スレッドで実行する
monitor_thread = threading.Thread(target=monitor_process_thread)
monitor_thread.start()

if __name__ == "__main__":

    settings = load_settings(filename)
    initial_text = settings["0"].get("trans_text", "")
    print(initial_text)
    
    current_text = initial_text
   
    while True:
        # 新しい設定を読み込む
        new_settings = load_settings(filename)
        
        # 新しい設定からIDを取得
        new_id = "0"
        
        # 新しいテキストを取得
        new_text = new_settings[new_id].get("trans_text", "")
        new_name = new_settings[new_id].get("name", "")
        
        
        if new_text != current_text:  # テキストが変更されたら翻訳する
            translated_text = translate_text(new_id + "@@" + new_name + "@@" + new_text)
   
            converted_text = translated_text.replace("＠＠", "@@")
            #print(converted_text)
            print(converted_text)
            splitted_text = converted_text.split("@@")
            chat_id = splitted_text[0]
            name = splitted_text[1]
            trans_text = splitted_text[2]

            # 結果を output.json ファイルに書き込む
            if os.path.exists(output_file):
                with open(output_file, "r", encoding="utf-8") as f:
                    existing_output = json.load(f)
            else:
                existing_output = {}

            existing_output[new_id].trans_text = trans_text
            with open(output_file, "w", encoding="utf-8") as f:
                json.dump(existing_output, f, ensure_ascii=False, indent=4)

            # names.jsonファイルに新しい名前を追加する
            if os.path.exists(names_file):
                with open(names_file, "r", encoding="utf-8") as f:
                    existing_names = json.load(f)
            else:
                existing_names = {}

            converted_name = name.replace(" ", "")
            existing_names[new_name].name = converted_name 
            with open(names_file, "w", encoding="utf-8") as f:
                json.dump(existing_names, f, ensure_ascii=False, indent=4)

            current_text = new_text

        time.sleep(0.5)

