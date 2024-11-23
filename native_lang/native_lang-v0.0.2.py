# MIT License
# Copyright (c) 2024 norisan
# Version 0.0.1

import json
import os
import threading
import sys
import psutil
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
import time

# exeの時は下記2段を有効化
exe_path = sys.executable
exe_dir = os.path.dirname(os.path.dirname(exe_path))

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




def get_name():
        
    names_to_skip = []
    if os.path.exists(recv_name):
        with open(recv_name, 'r', encoding='utf-8') as f:
            names_to_skip = [line.strip().split(':::')[0] for line in f if line.strip()]

    if os.path.exists(send_name):
        with open(send_name, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        updated_lines = []  # 更新された行を保持する
        unique_original_names = []  # ユニークなオリジナル名を追跡するリスト
        #all_translated = True  # 全ての行が翻訳されたかを示すフラグ

        for line in lines:
            line = line.strip()
            if not line:  # 空白行をスキップ
                continue

            parts = line.split(':::')
            if len(parts) != 2:
                continue

            original_name, replace_name = parts

            # 左側の名前に { が含まれている場合、または既にある名前の場合はスキップ
            if '{' in original_name or original_name in names_to_skip:
                continue
            
            # すでに翻訳済みの名前か確認
            if original_name in unique_original_names:
                continue

            unique_original_names.append(original_name)  # ユニークな名前を追加

            # original_nameとreplace_nameが異なる場合のみ翻訳
            if original_name == replace_name:
                translated_result = translate_str(driver, lang, original_name)
                print(f"{original_name}: {translated_result}")

                if translated_result != replace_name:
                    replace_name = "{#FF0000}★{/}" + translated_result
                    updated_lines.append(f"{original_name}:::{replace_name}\n")
                else:
                    # 変更されなかった名前を除外リストに追加
                    updated_lines.append(f"{original_name}:::{original_name}\n")

        # 更新があった場合のみファイルに書き込む
        if updated_lines:
            # 更新された内容をrecv_nameに書き込む
            with open(recv_name, 'a', encoding='utf-8') as f:
                f.writelines(updated_lines)
        # 更新があった場合のみファイルに書き込む
        if updated_lines: 
            # send_nameを空にする（内容を削除）
            with open(send_name, 'w', encoding='utf-8') as f:
                pass  # 何もしないことでファイルを空にする



def get_msg():
    # send_msg が存在し、空でない場合のみ処理を実行
    if os.path.exists(send_msg) and os.path.getsize(send_msg) > 0:
        try:
            with open(send_msg, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
        except Exception as e:
            print(f"Error reading {send_msg}: {e}")
            lines = []  # エラー発生時は空のリストを設定して処理を続行

        updated_lines = []  # 更新された行を保持する

        # recvファイルから既存のchat_idを読み込む
        existing_chat_ids = []  # リストに変更
        if os.path.exists(recv_msg):
            try:
                with open(recv_msg, 'r', encoding='utf-8', errors='ignore') as f:
                    for line in f:
                        parts = line.strip().split(':::')
                        if len(parts) == 5:
                            existing_chat_ids.append(parts[0])  # chat_idをリストに追加
            except Exception as e:
                print(f"Error reading {recv_msg}: {e}")
                # 既存のchat_idのリストは空のまま続行

        # recvに存在するchat_idを持つ行をスキップして、新しい行を処理
        for line in lines:
            line = line.strip()
            if not line:  # 空白行をスキップ
                continue

            parts = line.split(':::')
            if len(parts) == 5:
                chat_id, msg_type, msg, separate_msg, org_msg = parts  # 一度だけ取得
                
                if msg == "None":
                    continue
                # recvに既に存在するchat_idの場合、sendから削除
                if chat_id in existing_chat_ids:
                    continue  # この行をスキップ（削除）

                # ここで翻訳処理を行う
                translated_result = translate_str(driver, lang, msg)
                print(f"{msg}: {translated_result}")

                # 翻訳が成功した場合、または失敗した場合でも元のメッセージを保持
                if translated_result:  # 翻訳が成功した場合
                    updated_lines.append(f"{chat_id}:::{msg_type}:::{"{#FF0000}★{/}"+translated_result}:::{separate_msg}:::{org_msg}\n")
                else:  # 翻訳が失敗した場合
                    updated_lines.append(f"{chat_id}:::{msg_type}:::{msg}:::{separate_msg}:::{org_msg}\n")  # 元のメッセージを使用

        # recvに存在するchat_idを持つ行をsend_msgから削除
        try:
            with open(send_msg, 'w', encoding='utf-8') as f:  # 'w' モードで開く (上書き)
                for line in lines:
                    parts = line.strip().split(':::')
                    if len(parts) == 5:
                        chat_id = parts[0]  # chat_idを取得
                        if chat_id not in existing_chat_ids:  # recvに存在しない場合
                            f.write(line)  # 存在しない行を書き込む
        except Exception as e:
            print(f"Error writing {send_msg}: {e}")
            # 書き込み処理に失敗しても処理を続行する

        # 更新された行を recv_msg に書き込む（chat_idが存在しない場合のみ）
        if updated_lines:
            try:
                with open(recv_msg, 'a', encoding='utf-8') as f:  # 'a' モードで開く
                    for updated_line in updated_lines:
                        chat_id = updated_line.split(':::')[0]  # 更新された行からchat_idを取得
                        if chat_id not in existing_chat_ids:  # chat_idが存在しない場合
                            f.write(updated_line)  # 更新された行を書き込む
            except Exception as e:
                print(f"Error writing {recv_msg}: {e}")
                # 書き込み処理に失敗しても処理を続行する

class ChangeHandler(FileSystemEventHandler):
    def on_modified(self, event):
      
        if event.src_path == send_name:
            # name_file が存在するか確認
            if os.path.exists(send_name):
                # ファイルが存在する場合のみ get_name を呼び出す
                get_name()
            else:
                print(f"{send_name} が存在しません。")
        
        elif event.src_path == send_msg:
            #send_file が存在するか確認
            if os.path.exists(send_msg):
                #ファイルが存在する場合のみ get_msg を呼び出す
                get_msg()
            else:
                print(f"{send_msg} が存在しません。")

if __name__ == "__main__":
    driver = create_driver()  # WebDriverのインスタンスを作成

    event_handler = ChangeHandler()
    observer = Observer()
    observer.schedule(event_handler, path=exe_dir, recursive=False)
    observer.start()

    print("ファイル監視を開始しました。")

    try:
        while True:
            time.sleep(1)  # 監視を続ける
    except SystemExit:
        # 何らかの理由で SystemExit が発生した場合の処理
        pass
    except Exception as e:
        print(f"エラーが発生しました: {e}")
    finally:
        print("監視を停止します。")
        observer.stop()
        observer.join()



