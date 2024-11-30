# MIT License
# Copyright (c) 2024 norisan
# Version 0.0.3

import json
import os
import threading
import sys
import psutil
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
import time

# exeの時は下記2段を有効化
exe_path = sys.executable
exe_dir = os.path.dirname(exe_path)

# pyファイルでテストの時はこちらを有効化
#current_dir = os.path.dirname(os.path.abspath(__file__))
#exe_dir = os.path.abspath(os.path.join(current_dir, ".."))

send_msg = os.path.join(exe_dir, "send_msg.dat")
recv_msg = os.path.join(exe_dir, "recv_msg.dat")
send_name = os.path.join(exe_dir, "send_name.dat") 
recv_name = os.path.join(exe_dir, "recv_name.dat") 
restart = os.path.join(exe_dir, "restart.dat") 
settings_json = os.path.join(exe_dir, "settings.json") 

def load_settings(file_path):
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    else:
        return None  # ファイルが存在しない場合はNoneを返す

# 設定を読み込む
settings = load_settings(settings_json)

# 設定が存在しない場合のデフォルト値
if settings is None:
    settings = {
        "use": 1,
        "lang": "en"  # デフォルトの言語を英語に設定
    }

# langを取得
lang = settings.get("lang", "en")  # デフォルトは英語

print(f"使用する言語: {lang}")

# グローバル変数
driver = None


# プロセスIDを取得する関数
def get_process_id(process_name):
    for process in psutil.process_iter():
        try:
            if process.name() == process_name:
                return process.pid
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue  # プロセスが終了しているか、アクセスが拒否された場合は次へ
    return None

def terminate_self():
    try:
        print("自身のプロセスを終了します...")
        psutil.Process(os.getpid()).terminate()  # 自身のプロセスを終了
    except Exception as e:
        print(f"エラーが発生しました: {e}")

# WebDriverを終了する関数
def quit_driver():
    global driver
    if driver is not None:
        try:
            driver.quit()
            print("WebDriverが正常に終了しました。")
        except Exception as e:
            print(f"WebDriverの終了中にエラーが発生しました: {e}")
    
    terminate_self()  # WebDriverを終了した後に自身のプロセスを終了
  
# プロセスを監視する関数
def monitor_process(process_name, check_interval, restart):
    while True:
        process_id = get_process_id(process_name)
        
        if process_id is None or not psutil.pid_exists(process_id):
            print(f"{process_name} は終了しました。WebDriverを終了します。")
            quit_driver()  # プロセスが終了したらWebDriverを終了
            break
        elif os.path.isfile(restart):
            try:
                os.remove(restart)  # restart.datを削除
                print("restart.dat を削除しました。")
                quit_driver()  # WebDriverを終了
                break
            except OSError as e:
                print(f"削除に失敗しました: {e}")

        time.sleep(check_interval)  # チェック間隔を待つ
def start_monitor_thread(process_name, check_interval, restart):
    monitor_thread = threading.Thread(
        target=monitor_process, args=(process_name, check_interval, restart)
    )
    monitor_thread.start()

# Client_tos_x64.exe を監視するスレッドを開始
start_monitor_thread("Client_tos_x64.exe", check_interval=5, restart=restart)

# WebDriverを初期化する関数
def create_driver():
    global driver  # グローバル変数を参照
    try:
        chrome_options = Options()
        chrome_options.add_argument("--headless")  # ヘッドレスモード
        chrome_options.add_argument("--incognito")  # シークレットモード
        driver = webdriver.Chrome(options=chrome_options)
        print("WebDriverが正常に初期化されました。")
        return driver
    except Exception as e:
        print(f"WebDriverの初期化中にエラーが発生しました: {e}")
        return None
    
def translate_str(driver, lang, str, max_attempts=5):
    attempt = 1
    translated_str = str  # 初期値を設定

    while attempt <= max_attempts:
        try:
            driver.get(f"https://translate.google.co.jp/?sl=auto&tl={lang}&text={str}")
            wait = WebDriverWait(driver, 2)  # タイムアウトを10秒に設定
            element = wait.until(
                EC.presence_of_element_located((By.CSS_SELECTOR, "span[jsname='W297wb']"))
            )
            translated_str = element.text
            break  # 成功した場合、ループを抜ける
        except TimeoutException:
            print(f"タイムアウトエラー: 翻訳の対象の要素が見つかりませんでした。試行回数: {attempt + 1}")
        except Exception as e:
            print(f"エラー: {e}. 試行回数: {attempt + 1}")
        finally:
            attempt += 1  # attemptを増やして次の試行に進む

    return translated_str

# グローバル変数
names_to_skip = []

def get_name():
    global names_to_skip   
    loaded_names = []

    # names_to_skip が空でない場合にのみファイルを読み込む
    if os.path.exists(recv_name):
        with open(recv_name, 'r', encoding='utf-8') as f:
            # ファイルを読み込み、names_to_skip にない行のみ loaded_names に追加
            for line in f:
                original_name = line.strip().split(':::')[0]
                if line.strip() and original_name not in names_to_skip:
                    loaded_names.append(original_name)
        
    else:
        print(f"{recv_name} が存在しません。")
        return
    
    if os.path.exists(send_name):
        with open(send_name, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        updated_lines = []  # 更新された行を保持する

        for line in lines:
            line = line.strip()
            if not line:  # 空白行をスキップ
                continue

            parts = line.split(':::')
            if len(parts) != 2:
                continue

            original_name, replace_name = parts
            
            # すでに翻訳済みの名前か確認
            if original_name in names_to_skip:
                continue

            if original_name in loaded_names:
                continue

            if original_name == replace_name:
                translated_result = translate_str(driver, lang, original_name)
                print(f"{original_name}: {translated_result}")

                if translated_result != replace_name:
                    replace_name = "{#FF0000}★{/}" + translated_result
                    updated_lines.append(f"{original_name}:::{replace_name}\n")
                else:
                    # 変更されなかった名前を除外リストに追加
                    updated_lines.append(f"{original_name}:::{original_name}\n")
            
            names_to_skip.append(original_name)

        # 更新があった場合のみファイルに書き込む
        if updated_lines:
            # 更新された内容をrecv_nameに書き込む
            with open(recv_name, 'a', encoding='utf-8') as f:
                f.writelines(updated_lines)

# グローバル変数
translated_chat_ids = []  # 翻訳済みの chat_id を保持するリスト

def read_file(file_path):
    """ファイルを読み込む関数。エラーが発生した場合は何も返さない。"""
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            return f.readlines()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None  # エラー時に None を返す

def write_file(file_path, lines, mode):
    """ファイルに行を書く関数。"""
    try:
        with open(file_path, mode, encoding='utf-8') as f:
            f.writelines(lines)
    except Exception as e:
        print(f"Error writing {file_path}: {e}")

def get_msg():
    global translated_chat_ids  # グローバル変数を使用
    loaded_id = []
   
    # recv_msg から翻訳済みの chat_id を読み込む
    try:
        if os.path.exists(recv_msg):
            with open(recv_msg, 'r', encoding='utf-8') as f:
                for recv_line in f:
                    chat_id = recv_line.strip().split(':::')[0]
                    if recv_line.strip() and chat_id not in translated_chat_ids:
                        loaded_id.append(chat_id)
    except Exception as e:
        print(f"Error reading {recv_msg}: {e}")
   
    # send_msg が存在し、空でない場合のみ処理を実行
    if not os.path.exists(send_msg) or os.path.getsize(send_msg) == 0:
        #print(f"{send_msg} does not exist or is empty.")
        return

    lines = read_file(send_msg)

    updated_lines = []

    for line in lines:
        parts = line.strip().split(':::')
        
        # 必要な要素がない場合や不要な行はスキップ
        if len(parts) != 6:
            continue 
        
        chat_id, msg_type, msg, separate_msg, org_msg,org_name = parts
        
        # すでに翻訳済みの chat_id であればスキップ
        if chat_id in translated_chat_ids:
            continue
        if chat_id in loaded_id:
            continue
        # 翻訳処理
        translated_result = translate_str(driver, lang, msg)
        print(f"{chat_id}: {msg}: {translated_result}")

        # 翻訳結果に基づいて行を更新
        if translated_result:
            updated_lines.append(f"{chat_id}:::{msg_type}:::{"{#FF0000}★{/}"+translated_result}:::{separate_msg}:::{org_msg}:::{org_name}\n")
        else:
            updated_lines.append(f"{chat_id}:::{msg_type}:::{msg}:::{separate_msg}:::{org_msg}:::{org_name}\n")

        # 翻訳済みの chat_id を追加
        translated_chat_ids.append(chat_id)

    # 更新された行を recv_msg に追加
    if updated_lines:
        write_file(recv_msg, updated_lines, mode='a')

def check_name_files():
   
    if os.path.exists(send_name):
        get_name()  # 変更があった場合の処理
    else:
        print(f"{send_name} が存在しません。")


def check_msg_files():
  
    if os.path.exists(send_msg):
        get_msg()  # 変更があった場合の処理
    else:
        print(f"{send_msg} が存在しません。")

if __name__ == "__main__":
    driver = create_driver()  # WebDriverのインスタンスを作成

    print("ファイル監視を開始しました。")

    while True:
            try:
                check_name_files()
            except Exception as e:
                print(f"get_name()でエラーが発生しました: {e}")

            try:
                check_msg_files()  # 1秒ごとにファイルをチェック
            except Exception as e:
                print(f"get_msg()でエラーが発生しました: {e}")

            time.sleep(1)  # 監視を続ける
   
   



