import json
import time
import os
import sys
import psutil
import threading
import re
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

# exeの時は下記2段を有効化
exe_path = sys.executable
exe_dir = os.path.dirname(exe_path)

# pyファイルでテストの時はこちらを有効化
# current_dir = os.path.dirname(os.path.abspath(__file__))
# parent_dir = os.path.abspath(os.path.join(current_dir, "..", ".."))
# exe_dir = parent_dir

send_file = os.path.join(exe_dir, "send.json")
temp_file = os.path.join(exe_dir, "temp.json")
names_dat = os.path.join(exe_dir, "names.dat")
notice_dat = os.path.join(exe_dir, "notice.dat")
restart_dat = os.path.join(exe_dir, "restart.dat")
tempname_dat = os.path.join(exe_dir, "tempname.dat")

# WebDriverの初期化
def create_chrome_driver():
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--incognito")
    return webdriver.Chrome(options=chrome_options)

driver = create_chrome_driver()

# プロセスIDの取得
def get_process_id(process_name):
    for process in psutil.process_iter():
        if process.name() == process_name:
            return process.pid
    return None

# ファイルをクリア
def clear_files():
    files_to_clear = [send_file, temp_file]
    for file_path in files_to_clear:
        with open(file_path, "w", encoding="utf-8") as file:
            json.dump([], file, ensure_ascii=False, indent=4)

# プロセス監視
def monitor_process(process_name, check_interval=10):
    process_id = get_process_id(process_name)
    while process_id is not None and psutil.pid_exists(process_id):
        time.sleep(check_interval)
    else:
        clear_files()
        psutil.Process(os.getpid()).terminate()

def start_monitor_thread(process_name, check_interval=10):
    monitor_thread = threading.Thread(target=monitor_process, args=(process_name, check_interval))
    monitor_thread.start()

# Client_tos_x64.exe を監視する
start_monitor_thread("Client_tos_x64.exe", check_interval=10)

# テキストを翻訳
def translate_text(lang, trans_text, driver, initial_timeout=1, max_attempts=3):
    url = f"https://translate.google.co.jp/?sl=auto&tl={lang}&text={trans_text}"
    attempt = 0
    translated_text = trans_text  # 初期値として入力テキストを設定

    while attempt < max_attempts:
        try:
            driver.get(url)
            wait = WebDriverWait(driver, initial_timeout * (attempt + 1))
            element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "span[jsname='W297wb']")))
            translated_text = element.text
            break  # 成功した場合、ループを抜ける
        except TimeoutException:
            print(f"タイムアウトエラー: 翻訳の対象の要素が見つかりませんでした。text (試行回数: {attempt + 1})")
            attempt += 1

    return translated_text

# 名前を翻訳
def translate_name(lang, org_name, driver, initial_timeout=1, max_attempts=3):
    print("Original name:" + org_name)
    url = f"https://translate.google.co.jp/?sl=auto&tl={lang}&text={org_name}"
    attempt = 0
    translated_name = org_name  # 初期値として入力された名前を設定

    while attempt < max_attempts:
        try:
            driver.get(url)
            wait = WebDriverWait(driver, initial_timeout * (attempt + 1))
            element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "span[jsname='W297wb']")))
            translated_name = element.text
            break  # 成功した場合、ループを抜ける
        except TimeoutException:
            print(f"タイムアウトエラー: 翻訳の対象の要素が見つかりませんでした。name (試行回数: {attempt + 1})")
            attempt += 1

    return translated_name

# 通知を処理
def process_notification():
    if os.path.exists(send_file):
        try:
            with open(send_file, "r", encoding="utf-8") as file:
                data = json.load(file)
        except Exception as e:
            print(f"Error reading send_file: {e}")
            data = []

        try:
            with open(send_file, "w", encoding="utf-8") as file:
                json.dump([], file, ensure_ascii=False, indent=4)
        except Exception as e:
            print(f"Error writing to send_file: {e}")

        try:
            with open(temp_file, "w", encoding="utf-8") as file:
                json.dump(data, file, ensure_ascii=False, indent=4)
        except Exception as e:
            print(f"Error writing to temp_file: {e}")

        return data

# 文字列チェック
def check_string(string):
    pattern = "^[a-zA-Z0-9\-_\@\#\$\%\&\*]+$"
    return 0 if re.match(pattern, string) else 1

# DATファイルを保存
def save_dat_file(file_path, data):
    try:
        with open(file_path, "w", encoding="utf-8") as file:
            for key, value in data.items():
                line = f'"{key}" : "{value}"\n'
                file.write(line)
    except Exception as e:
        print(f"Error writing to {file_path}: {e}")

# DATファイルを読み込み
def load_dat_file(file_path):
    data = {}
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            for line in file:
                key, value = line.strip().split(" : ")
                key = key.strip('"')
                value = value.strip('"')
                data[key] = value
    except FileNotFoundError:
        try:
            with open(file_path, "w", encoding="utf-8") as file:
                pass
        except Exception as e:
            print(f"Error creating {file_path}: {e}")
    except Exception as e:
        print(f"Error reading from {file_path}: {e}")
    return data

# DATファイルに追加
def append_to_dat_file(file_path, data):
    if not os.path.exists(file_path):
        try:
            with open(file_path, "w", encoding="utf-8") as file:
                pass
        except Exception as e:
            print(f"Error creating {file_path}: {e}")

    try:
        with open(file_path, "a", encoding="utf-8") as file:
            for entry in data:
                line = f'"{entry["chat_id"]}" : "{entry["org_name"]}" : "{entry["trans_text"]}" : "{entry["msgtype"]}" : "{entry["time"]}"\n'
                file.write(line)
    except Exception as e:
        print(f"Error writing to {file_path}: {e}")

# tempファイルを作成
def create_temp_file(temp_file):
    if not os.path.exists(temp_file):
        try:
            with open(temp_file, "w", encoding="utf-8") as file:
                json.dump([], file, ensure_ascii=False, indent=4)
        except Exception as e:
            print(f"Error creating {temp_file}: {e}")

previous_text = None
repeat_count = 0
repeat_threshold = 5

# 再起動を監視
def monitor_for_restart():
    global previous_text, repeat_count

    while True:
        if os.path.exists(restart_dat):
            os.remove(restart_dat)
            psutil.Process(os.getpid()).terminate()

        if previous_text and repeat_count >= repeat_threshold:
            psutil.Process(os.getpid()).terminate()

        time.sleep(3)

# ファイル削除をリトライ
def remove_file_with_retry(file_path, retries=5, delay=1):
    for i in range(retries):
        try:
            os.remove(file_path)
            return True
        except PermissionError:
            print(f"Retrying to remove {file_path} ({i+1}/{retries})...")
            time.sleep(delay)
    return False

# メイン関数
def main():
    create_temp_file(temp_file)
    monitor_thread = threading.Thread(target=monitor_for_restart)
    monitor_thread.start()

    counter = 0  # カウンタを初期化
    temp = []
    previous_text = None
    repeat_count = 0
    repeat_threshold = 5

    while True:
        time.sleep(0.5)  # 0.5秒ごとに一度だけsleep

        if counter % 1 == 0:
            temp = read_temp_file()

        if counter % 1 == 0 and temp:
            handle_translation(temp, driver, previous_text, repeat_count, repeat_threshold)

        if counter % 1 == 0:
            check_and_translate_names(driver)

        if counter % 6 == 0:
            check_restart()

        counter += 1

    driver.quit()  # WebDriverのインスタンスを最後に終了する

# 一時ファイルを読み込み
def read_temp_file():
    try:
        with open(temp_file, "r", encoding="utf-8") as file:
            temp = json.load(file)
    except Exception as e:
        print(f"Error reading temp_file: {e}")
        temp = []
    return temp

# 翻訳処理を実行
def handle_translation(temp, driver, previous_text, repeat_count, repeat_threshold):
    unique_entries = []
    seen_chat_ids = set()

    for entry in temp:
        if entry["chat_id"] not in seen_chat_ids:
            unique_entries.append(entry)
            seen_chat_ids.add(entry["chat_id"])

    temp = unique_entries

    if not temp:
        temp = process_notification()

    if temp:
        chat_entry = temp[0]
        chat_id = chat_entry.get("chat_id")
        name = chat_entry.get("name")
        lang = chat_entry.get("lang")
        trans_text = chat_entry.get("trans_text")
        msgtype = chat_entry.get("msgtype")
        msgtime = chat_entry.get("time")
        del temp[0]
        print("Before translation:" + name + ":" + trans_text)

        if trans_text == previous_text:
            repeat_count += 1
        else:
            previous_text = trans_text
            repeat_count = 1

        if repeat_count >= repeat_threshold:
            print("Repeating text threshold reached. Clearing temp.json.")
            with open(temp_file, "w", encoding="utf-8") as file:
                json.dump([], file, ensure_ascii=False, indent=4)
            previous_text = None
            repeat_count = 0

        try:
            with open(temp_file, "w", encoding="utf-8") as file:
                json.dump(temp, file, ensure_ascii=False, indent=4)
        except Exception as e:
            print(f"Error writing to temp_file: {e}")

        existing_names = load_dat_file(names_dat)
        trans_name = existing_names.get(name, None)

        if trans_name is None:
            result = check_string(name)
            if result == 1:
                translated_name = translate_name(lang, name, driver)
                print("translated name:" + translated_name)
                existing_names[name] = translated_name
                trans_name = translated_name
            else:
                existing_names[name] = name
                trans_name = name

        save_dat_file(names_dat, existing_names)

        if trans_text and trans_text.strip():
            translated_text = translate_text(lang, trans_text, driver)
        else:
            translated_text = ""

        new_entry = {
            "chat_id": chat_id,
            "org_name": trans_name,
            "trans_text": translated_text,
            "msgtype": msgtype,
            "time": msgtime,
        }
        append_to_dat_file(notice_dat, [new_entry])
        print("after translation:" + trans_name + ":" + translated_text)

# 名前をチェックして翻訳
def check_and_translate_names(driver):
    if os.path.exists(tempname_dat):
        existing_names = load_dat_file(names_dat)
        with open(tempname_dat, "r", encoding="utf-8") as file:
            names_to_translate = file.readlines()

        for line in names_to_translate:
            tempname, lang = line.strip().split(" : ")
            result = check_string(tempname)

            if result == 1:
                translated_name = translate_name(lang, tempname, driver)
                print("translated name:", translated_name)
                existing_names[tempname] = translated_name
            else:
                existing_names[tempname] = tempname

        save_dat_file(names_dat, existing_names)

        if not remove_file_with_retry(tempname_dat):
            print(f"Failed to remove {tempname_dat} after multiple attempts.")

# 再起動をチェック
def check_restart():
    if os.path.exists(restart_dat):
        os.remove(restart_dat)
        psutil.Process(os.getpid()).terminate()

# メイン関数の実行
if __name__ == "__main__":
    main()

