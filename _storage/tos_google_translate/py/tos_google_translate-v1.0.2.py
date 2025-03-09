# MIT License

# Copyright (c) 2024 norisan

# Version 1.0.1

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
# exe_dir = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Tree of Savior (Japanese Ver.)\\addons\\tos_google_translate\\tos_google_translate"

send_file = os.path.join(exe_dir, "send.json")
temp_file = os.path.join(exe_dir, "temp.json")
names_dat = os.path.join(exe_dir, "names.dat")
notice_dat = os.path.join(exe_dir, "notice.dat")
restart_dat = os.path.join(exe_dir, "restart.dat")
tempname_dat = os.path.join(exe_dir, "tempname.dat")


def get_process_id(process_name):
    for process in psutil.process_iter():
        if process.name() == process_name:
            return process.pid
    return None


def clear_files():
    empty_content = []
    files_to_clear = [send_file, temp_file]
    for file_path in files_to_clear:
        with open(file_path, "w", encoding="utf-8") as file:
            json.dump(empty_content, file, ensure_ascii=False, indent=4)


def monitor_process(process_name, check_interval=10):
    process_id = get_process_id(process_name)
    while process_id is not None and psutil.pid_exists(process_id):
        time.sleep(check_interval)
    else:
        clear_files()
        psutil.Process(os.getpid()).terminate()


def start_monitor_thread(process_name, check_interval=10):
    monitor_thread = threading.Thread(
        target=monitor_process, args=(process_name, check_interval)
    )
    monitor_thread.start()


# Client_tos_x64.exe を監視する
start_monitor_thread("Client_tos_x64.exe", check_interval=10)


def translate_text(lang, trans_text, max_attempts=5):
    # 新しいChrome WebDriverインスタンスを作成
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--incognito")
    driver = webdriver.Chrome(options=chrome_options)
    attempt = 0
    translated_text = trans_text  # 初期値として入力テキストを設定

    while attempt < max_attempts:
        try:
            driver.get(
                f"https://translate.google.co.jp/?sl=auto&tl={lang}&text={trans_text}"
            )
            wait = WebDriverWait(
                driver, 1 + attempt
            )  # 各試行で少しずつタイムアウトを増やす
            element = wait.until(
                EC.presence_of_element_located(
                    (By.CSS_SELECTOR, "span[jsname='W297wb']")
                )
            )
            translated_text = element.text
            break  # 成功した場合、ループを抜ける
        except TimeoutException:
            print(
                f"タイムアウトエラー: 翻訳の対象の要素が見つかりませんでした。試行回数: {attempt + 1}"
            )
        except Exception as e:
            print(f"エラー: {e}. 試行回数: {attempt + 1}")
        finally:
            attempt += 1  # attemptを増やして次の試行に進む

    driver.quit()  # WebDriverのインスタンスを最後に終了する
    return translated_text


def translate_name(lang, org_name, max_attempts=5):
    print("Before name:" + org_name)

    # 新しいChrome WebDriverインスタンスを作成
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--incognito")
    driver = webdriver.Chrome(options=chrome_options)

    attempt = 0
    translated_name = org_name  # 初期値として入力された名前を設定

    while attempt < max_attempts:
        try:
            driver.get(
                f"https://translate.google.co.jp/?sl=auto&tl={lang}&text={org_name}"
            )
            wait = WebDriverWait(
                driver, 1 + attempt
            )  # 各試行で少しずつタイムアウトを増やす
            element = wait.until(
                EC.presence_of_element_located(
                    (By.CSS_SELECTOR, "span[jsname='W297wb']")
                )
            )
            translated_name = element.text
            break  # 成功した場合、ループを抜ける
        except TimeoutException:
            print(
                f"タイムアウトエラー: 翻訳の対象の要素が見つかりませんでした。name (試行回数: {attempt + 1})"
            )
        except Exception as e:
            print(f"エラー: {e}. name (試行回数: {attempt + 1})")
        finally:
            attempt += 1  # attemptを増やして次の試行に進む

    driver.quit()  # WebDriverのインスタンスを最後に終了する

    return translated_name


def process_notification():
    # 通知がある場合に行う処理
    if os.path.exists(send_file):
        try:
            with open(send_file, "r", encoding="utf-8") as file:
                data = json.load(file)
        except Exception as e:
            print(f"Error reading send_file: {e}")
            data = []

        # ファイルを空にする
        try:
            with open(send_file, "w", encoding="utf-8") as file:
                json.dump([], file, ensure_ascii=False, indent=4)
        except Exception as e:
            print(f"Error writing to send_file: {e}")

        # データをtemp_fileに書き込む
        try:
            with open(temp_file, "w", encoding="utf-8") as file:
                json.dump(data, file, ensure_ascii=False, indent=4)
        except Exception as e:
            print(f"Error writing to temp_file: {e}")

        return data


def check_string(string):
    # 英数字と特定の半角記号を許可する正規表現パターン
    pattern = "^[a-zA-Z0-9\-_\@\#\$\%\&\*]+$"
    if re.match(pattern, string):
        return 0
    else:
        return 1


def save_dat_file(file_path, data):
    try:
        with open(file_path, "w", encoding="utf-8") as file:
            for key, value in data.items():
                line = f'"{key}" : "{value}"\n'
                file.write(line)
    except Exception as e:
        print(f"Error writing to {file_path}: {e}")


def load_dat_file(file_path):
    data = {}
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            for line in file:
                key, value = line.strip().split(" : ")
                key = key.strip('"')  # ダブルクォーテーションを削除
                value = value.strip('"')  # ダブルクォーテーションを削除
                data[key] = value
    except FileNotFoundError:
        # ファイルが存在しない場合、新しいファイルを作成
        try:
            with open(file_path, "w", encoding="utf-8") as file:
                pass
        except Exception as e:
            print(f"Error creating {file_path}: {e}")
    except Exception as e:
        print(f"Error reading from {file_path}: {e}")
    return data


def append_to_dat_file(file_path, data):
    # ファイルが存在しない場合は作成
    if not os.path.exists(file_path):
        try:
            with open(file_path, "w", encoding="utf-8") as file:
                pass  # 空のファイルを作成
        except Exception as e:
            print(f"Error creating {file_path}: {e}")

    # ファイルにデータを追記
    try:
        with open(file_path, "a", encoding="utf-8") as file:
            for entry in data:
                line = f'"{entry["chat_id"]}" : "{entry["org_name"]}" : "{entry["trans_text"]}" : "{entry["msgtype"]}" : "{entry["time"]}"\n'
                file.write(line)
    except Exception as e:
        print(f"Error writing to {file_path}: {e}")


# temp.jsonが存在しない場合に作成する関数
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


def monitor_for_restart():
    global previous_text, repeat_count

    while True:
        if os.path.exists(restart_dat):
            os.remove(restart_dat)  # 再起動ファイルを削除
            psutil.Process(os.getpid()).terminate()  # 自身のプロセスを終了

        # 同じテキストが10回続いた場合にプロセスを終了
        if previous_text and repeat_count >= repeat_threshold:
            psutil.Process(os.getpid()).terminate()

        time.sleep(3)


def remove_file_with_retry(file_path, retries=5, delay=1):
    for i in range(retries):
        try:
            os.remove(file_path)
            return True
        except PermissionError:
            print(f"Retrying to remove {file_path} ({i+1}/{retries})...")
            time.sleep(delay)
    return False


if __name__ == "__main__":
    create_temp_file(temp_file)

    # monitor_for_restart 関数を別スレッドで実行する
    monitor_thread = threading.Thread(target=monitor_for_restart)
    monitor_thread.start()

    while True:
        try:
            # settingsファイルを読み込む
            with open(temp_file, "r", encoding="utf-8") as file:
                temp = json.load(file)
        except Exception as e:
            print(f"Error reading temp_file: {e}")
            temp = []
        # 同じ chat_id を持つエントリを削除し、1個だけ残す
        unique_entries = []
        seen_chat_ids = set()

        for entry in temp:
            if entry["chat_id"] not in seen_chat_ids:
                unique_entries.append(entry)
                seen_chat_ids.add(entry["chat_id"])

        temp = unique_entries
        # settingsが空の場合のみ通知の処理を行う
        if not temp:
            temp = process_notification()

        # データが存在する場合の処理
        if temp:
            chat_entry = temp[0]
            chat_id = chat_entry.get("chat_id")
            name = chat_entry.get("name")
            lang = chat_entry.get("lang")
            trans_text = chat_entry.get("trans_text")
            msgtype = chat_entry.get("msgtype")
            msgtime = chat_entry.get("time")
            del temp[0]
            print("Before:" + name + ":" + trans_text)

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

            # DATファイルからデータを読み込む
            existing_names = load_dat_file(names_dat)

            # 名前のチェックと更新
            trans_name = ""
            if name not in existing_names:
                result = check_string(name)  # nameをチェックする必要があります
                if result == 1:
                    # 翻訳後の名前を取得
                    translated_name = translate_name(lang, name)
                    print("After name:" + translated_name)

                    # 翻訳後の名前をexisting_namesに保存
                    existing_names[name] = translated_name
                    trans_name = translated_name

                else:
                    # 翻訳しない場合は元の名前を保持
                    existing_names[name] = name
                    trans_name = name
            else:
                trans_name = existing_names[name]

            # 処理が全て終了した後にexisting_namesをDATファイルに保存
            save_dat_file(names_dat, existing_names)

            if trans_text != "" and trans_text != " ":
                translated_text = translate_text(lang, trans_text)
            else:
                translated_text = ""

            new_entry = {
                "chat_id": chat_id,
                "org_name": trans_name,
                "trans_text": translated_text,
                "msgtype": msgtype,
                "time": msgtime,
            }
            data_to_append = [new_entry]
            append_to_dat_file(notice_dat, data_to_append)
            print("After:" + trans_name + ":" + translated_text)

        if os.path.exists(tempname_dat):
            existing_names = load_dat_file(
                names_dat
            )  # tempname.datが存在する場合の処理

            with open(tempname_dat, "r", encoding="utf-8") as file:
                names_to_translate = file.readlines()

            for line in names_to_translate:
                tempname, lang = line.strip().split(" : ")
                result = check_string(tempname)

                if result == 1:
                    translated_name = translate_name(lang, tempname)
                    print("After name:", translated_name)
                    existing_names[tempname] = translated_name
                else:
                    existing_names[tempname] = tempname
            save_dat_file(names_dat, existing_names)

            # tempname.datを削除
            if not remove_file_with_retry(tempname_dat):
                print(f"Failed to remove {tempname_dat} after multiple attempts.")
            # time.sleep(0.3)

        if os.path.exists(restart_dat):
            os.remove(restart_dat)
            psutil.Process(os.getpid()).terminate()
        time.sleep(0.5)
