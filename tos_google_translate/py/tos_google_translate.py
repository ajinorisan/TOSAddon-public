import json
import time
import os
import sys
import psutil
import ctypes
import threading
import warnings
import subprocess
#import selenium

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
warnings.simplefilter('ignore')

"""chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--incognito')
driver = webdriver.Chrome(options=chrome_options)"""

#Tree of Savior (Kor) 韓国版
#TreeOfSavior　Papaya
#filename = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Tree of Savior (Japanese Ver.)\\addons\\tos_google_trans\\settings.json"
def load_settings(filename):
    try:
        with open(filename, "r", encoding="utf-8") as file:
            settings = json.load(file)
        return settings
    except FileNotFoundError:
        #print(f"File not found: {filename}")
        
        return {}  # 空の辞書を返すか、エラー処理を行う
    except json.JSONDecodeError as e:
        #print(f"Error decoding JSON: {e}")
      
        return {}  # 空の辞書を返すか、エラー処理を行う
# 新しいChrome WebDriverインスタンスを作成

def translate_text(lang, new_id, org_name, org_text):
    print(lang + new_id + "@@" + org_name + "@@" + org_text)
    
    # 新しいChrome WebDriverインスタンスを作成
    chrome_options = Options()
    chrome_options.add_argument('--headless')
    chrome_options.add_argument('--incognito')
    driver = webdriver.Chrome(options=chrome_options)
    
    try:
        driver.get("https://translate.google.co.jp/?sl=auto&tl="+lang+"&text="+ org_name + "@@" + org_text)
        wait = WebDriverWait(driver, 3)  # 最大2秒待機
        try:
            element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "span[jsname='W297wb']")))
            translated_text =  str(new_id)+ "@@"+element.text
        except:
            translated_text =str(new_id)+"@@" + "---" + "@@" + org_text+"※Translation failed."
    finally:
        driver.quit()  # WebDriverのインスタンスを終了する

    return translated_text

"""def translate_text(lang,new_id,org_name,org_text):
   
    print(lang+new_id + "@@" + org_name + "@@" + org_text)
   
    driver.get("https://translate.google.co.jp/?sl=auto&tl="+lang+"&text="+ org_name + "@@" + org_text)
    wait = WebDriverWait(driver, 3)  # 最大2秒待機
    try:
        element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "span[jsname='W297wb']")))
        translated_text =  str(new_id)+ "@@"+element.text
    except:
        translated_text =str(new_id)+"@@" + "---" + "@@" + org_text+"※Translation failed."
    driver.quit()
    return translated_text"""

def message_box(text):
    ctypes.windll.user32.MessageBoxW(0, text, "google翻訳", 0)

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
        message_box("Since Tree Of Savior has been terminated, Tos Google translate will also be terminated.")
        # tos_google_trans.py も終了する
        tos_process = psutil.Process(os.getpid())
        tos_process.terminate()  # スクリプト自体のプロセスを終了
        return

def monitor_process_thread():
    monitor_process()

# monitor_process()関数を別スレッドで実行する
monitor_thread = threading.Thread(target=monitor_process_thread)
monitor_thread.start()

def close_cmd(process):
    # コマンドプロンプトを閉じる
    process.terminate()

if __name__ == "__main__":
    current_id = "0"  # current_idを初期化
    #pyファイルでテストの時はこちらを有効化
    #exe_dir = os.path.dirname(os.path.abspath(__file__))
    #exeの時は下記2段を有効化
    exe_path = sys.executable
    exe_dir = os.path.dirname(exe_path)
    filename = os.path.join(exe_dir, "settings.json")
    output_file = os.path.join(exe_dir, "output.json")
    names_file = os.path.join(exe_dir, "names.json")     
    print("start")
    print(filename)
   
    while True:
        cmd_processes = []  # コマンドプロンプトのプロセスを格納するリスト      
        settings = load_settings(filename)
      
        # 新しい設定からIDを取得
        if 'chat_id' in settings:
            lang=settings['lang']
            new_id = settings['chat_id']
            org_text = settings.get("trans_text", "")  # "trans_text" キーが存在しない場合は空文字列を返す      
            org_name = settings.get("name", "")  # "name" キーが存在しない場合は空文字列を返す
            msgtype=settings["msgtype"]
            msgtime=settings["time"]
            use=settings["use"]
        else:
            #print("Error: 'chat_id' key not found in settings.")
            continue
       
        if new_id != current_id and use == 1:
            print(str(new_id)+str(current_id))
            
            translated_text = translate_text(lang,new_id,org_name,org_text)
            #translated_text = translate_text(new_id + "@@" + org_name + "@@" + org_text)
            #print(translated_text)
            converted_text = translated_text.replace("＠＠", "@@")
            
            print(converted_text)
            try:
                splitted_text = converted_text.split("@@")
                chat_id = splitted_text[0]
                name = splitted_text[1]
                trans_text = splitted_text[2]
            except IndexError:
                #print("Error: Failed to split the translated text.")
                continue  # エラーが発生した場合に次の繰り返しに移る

            # 結果を output.json ファイルに書き込む
            if os.path.exists(output_file):
                with open(output_file, "r", encoding="utf-8") as f:
                    existing_output = json.load(f)
            else:
                existing_output = {}
               
            #convert_id=chat_id.replace(" ", "")
            existing_output[str(new_id)] = {"org_name": org_name, "trans_text": trans_text,"msgtype":msgtype,"time":msgtime}
            with open(output_file, "w", encoding="utf-8") as f:
                json.dump(existing_output, f, ensure_ascii=False, indent=4)

            # names.jsonファイルに新しい名前を追加する
            if os.path.exists(names_file):
                with open(names_file, "r", encoding="utf-8") as f:
                    existing_names = json.load(f)
            else:
                existing_names = {}

            converted_name = name.replace(" ", "")
            existing_names[org_name] = converted_name 
            with open(names_file, "w", encoding="utf-8") as f:
                json.dump(existing_names, f, ensure_ascii=False, indent=4)
            
            current_id = new_id
            for process in cmd_processes:
             close_cmd(process)

            time.sleep(0.1)
   

