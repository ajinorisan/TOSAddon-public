import json
import shutil
import time
import os
import sys
import psutil
import ctypes
import threading
import warnings
import subprocess

# import selenium

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

warnings.simplefilter("ignore")
from selenium.common.exceptions import TimeoutException


def message_box(text):
    ctypes.windll.user32.MessageBoxW(0, text, "google翻訳", 0)


def monitor_process():
    # Client_tos_x64.exe のプロセスIDを取得
    process_id = None
    for process in psutil.process_iter():
        if process.name() == "Client_tos_x64.exe":
            process_id = process.pid
            # print("Client_tos_x64.exe のプロセスID:", process_id)
            break

    # Client_tos_x64.exe のプロセスを監視して、終了したら tos_google_trans.py も終了する
    while process_id is not None and psutil.pid_exists(process_id):
        time.sleep(10)  # 1秒ごとにプロセスの状態を確認する
    else:
        message_box(
            "Since Tree Of Savior has been terminated, Tos Google translate will also be terminated."
        )
        # tos_google_trans.py も終了する
        tos_process = psutil.Process(os.getpid())
        tos_process.terminate()  # スクリプト自体のプロセスを終了
        return


def monitor_process_thread():
    monitor_process()


# monitor_process()関数を別スレッドで実行する
monitor_thread = threading.Thread(target=monitor_process_thread)
monitor_thread.start()


def translate_text(lang, trans_text):

    # 新しいChrome WebDriverインスタンスを作成
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--incognito")
    driver = webdriver.Chrome(options=chrome_options)

    try:
        driver.get(
            "https://translate.google.co.jp/?sl=auto&tl=" + lang + "&text=" + trans_text
        )
        wait = WebDriverWait(driver, 5)

        try:
            element = wait.until(
                EC.presence_of_element_located(
                    (By.CSS_SELECTOR, "span[jsname='W297wb']")
                )
            )
            translated_text = element.text
        except TimeoutException:
            print("タイムアウトエラー: 翻訳の対象の要素が見つかりませんでした。")
            translated_text = trans_text
            # pass

    finally:
        driver.quit()  # WebDriverのインスタンスを終了する

    return translated_text


def translate_name(lang, org_name):
    print("翻訳前名前" + org_name)

    # 新しいChrome WebDriverインスタンスを作成
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--incognito")
    driver = webdriver.Chrome(options=chrome_options)

    try:
        driver.get(
            "https://translate.google.co.jp/?sl=auto&tl=" + lang + "&text=" + org_name
        )
        wait = WebDriverWait(driver, 5)

        try:
            element = wait.until(
                EC.presence_of_element_located(
                    (By.CSS_SELECTOR, "span[jsname='W297wb']")
                )
            )
            translated_name = element.text
        except TimeoutException:
            print("タイムアウトエラー: 翻訳の対象の要素が見つかりませんでした。")
            translated_name = org_name

    finally:
        driver.quit()  # WebDriverのインスタンスを終了する

    return translated_name


# pyファイルでテストの時はこちらを有効化
# exe_dir = os.path.dirname(os.path.abspath(__file__))

# exeの時は下記2段を有効化
exe_path = sys.executable
exe_dir = os.path.dirname(exe_path)

output_file = os.path.join(exe_dir, "output.json")
names_file = os.path.join(exe_dir, "names.json")
temp_file = os.path.join(exe_dir, "temp.json")
send_file = os.path.join(exe_dir, "send.json")


def process_notification():
    # 通知がある場合に行う処理
    if os.path.exists(send_file):
        with open(send_file, "r", encoding="utf-8") as file:
            data = json.load(file)
            # print(data)

        # ファイルを空にする
        with open(send_file, "w", encoding="utf-8") as file:
            json.dump([], file, ensure_ascii=False, indent=4)

        # データをtemp_fileに書き込む
        with open(temp_file, "w", encoding="utf-8") as file:
            json.dump(data, file, ensure_ascii=False, indent=4)

        return data


if __name__ == "__main__":
    while True:
        # settingsファイルを読み込む
        with open(temp_file, "r", encoding="utf-8") as file:
            settings = json.load(file)

        # settingsが空の場合のみ通知の処理を行う
        if not settings:
            settings = process_notification()

        # データが存在する場合の処理
        if settings:
            chat_entry = settings[0]
            chat_id = chat_entry.get("chat_id")
            name = chat_entry.get("name")
            lang = chat_entry.get("lang")
            trans_text = chat_entry.get("trans_text")
            msgtype = chat_entry.get("msgtype")
            msgtime = chat_entry.get("time")
            del settings[0]
            print("翻訳前" + name + ":" + trans_text)

            with open(temp_file, "w", encoding="utf-8") as file:
                json.dump(settings, file, ensure_ascii=False, indent=4)

            with open(names_file, "r", encoding="utf-8") as file:
                existing_names = json.load(file)

            if name not in existing_names:
                existing_names[name] = translate_name(lang, name)
                print("翻訳後名前" + name)
                with open(names_file, "w", encoding="utf-8") as f:
                    json.dump(existing_names, f, ensure_ascii=False, indent=4)

            if trans_text != "" and trans_text != " ":
                translated_text = translate_text(lang, trans_text)
            else:
                translated_text = ""
            # print("翻訳後" + name + ":" + translated_text)

            with open(output_file, "r", encoding="utf-8") as file:
                existing_output = json.load(file)

                existing_output.append(
                    {
                        "chat_id": chat_id,
                        "org_name": name,
                        "trans_text": translated_text,
                        "msgtype": msgtype,
                        "time": msgtime,
                    }
                )

            with open(output_file, "w", encoding="utf-8") as f:
                json.dump(existing_output, f, ensure_ascii=False, indent=4)
            time.sleep(0.5)
        time.sleep(1)


"""if __name__ == "__main__":

    while True:
        # print(os.path.getsize(temp_file))
        if os.path.getsize(temp_file) > 2:
            with open(temp_file, "r", encoding="utf-8") as file:
                settings = json.load(file)
        else:
            settings = process_notification()
            
                    
            

        if settings and len(settings) > 0:
            chat_entry = settings[0]
            chat_id = chat_entry.get("chat_id")
            name = chat_entry.get("name")
            lang = chat_entry.get("lang")
            trans_text = chat_entry.get("trans_text")
            msgtype = chat_entry.get("msgtype")
            msgtime = chat_entry.get("time")

            if chat_id is not None:

                translated_text = translate_text(lang, chat_id, name, trans_text)
                converted_text = translated_text.replace("＿＿", "__")
                print("翻訳後のテキスト:", translated_text)

                try:
                    splitted_text = converted_text.split("__")
                    trans_name = splitted_text[0]
                    trans_text = splitted_text[1] or " "

                except IndexError:
                    print("Error: Failed to split the translated text.")
                    pass  # エラーが発生した場合に次の繰り返しに移る

                if os.path.exists(output_file):
                    with open(output_file, "r", encoding="utf-8") as file:
                        existing_output = json.load(file)
                        existing_output.append(
                            {
                                "chat_id": chat_id,
                                "org_name": trans_name,
                                "trans_text": trans_text,
                                "msgtype": msgtype,
                                "time": msgtime,
                            }
                        )

                    with open(output_file, "w", encoding="utf-8") as f:
                        json.dump(existing_output, f, ensure_ascii=False, indent=4)

                if os.path.exists(names_file):
                    with open(names_file, "r", encoding="utf-8") as file:
                        existing_names = json.load(file)

                if name not in existing_names:
                    existing_names[name] = trans_name

                    # ファイルに書き込む
                    with open(names_file, "w", encoding="utf-8") as f:
                        json.dump(existing_names, f, ensure_ascii=False, indent=4)

                # 処理したエントリーを削除

                del settings[0]

                # 更新した設定をファイルに書き込む
                with open(temp_file, "w", encoding="utf-8") as file:
                    json.dump(settings, file, ensure_ascii=False, indent=4)

                if len(settings) > 2:
                    data = "renotice"
                    with open(renotice, "w", encoding="utf-8") as file:
                        json.dump(data, file, ensure_ascii=False, indent=4)
                else:
                    os.remove(renotice)

        time.sleep(1)  # 1秒間スリープ"""


"""exe_dir = os.path.dirname(os.path.abspath(__file__))
filename = os.path.join(exe_dir, "settings.json")

def watch_notification():
    # Luaスクリプトからの通知を待機
    while True:
        if os.path.exists(filename):
            print("設定が変更されました。")
            try:
              with open(filename, "r", encoding="utf-8") as file:
                usedata = json.load(file)
            
            except json.JSONDecodeError as e:
               print(f"JSONデータの読み取り中にエラーが発生しました: {e}")
               continue
            # chatリストの最初の要素のみ処理
        use = usedata["use"]
        print(use)
        time.sleep(10)  # 1秒ごとに監視"""

"""if __name__ == "__main__":
    exe_dir = os.path.dirname(os.path.abspath(__file__))
    output_file = os.path.join(exe_dir, "output.json")
    names_file = os.path.join(exe_dir, "names.json")
   
   
    while True:
        # settings.json ファイルが存在する限り処理を続ける
        
        temp_file = os.path.join(exe_dir, "temp.json")
      
      
            
            with open(temp_file, "r", encoding="utf-8") as file:
                settings = json.load(file)
           
            
                        
            if settings and len(settings) > 0:
                chat_entry = settings[0]
                chat_id = chat_entry.get("chat_id")
                name = chat_entry.get("name")
                lang = chat_entry.get("lang")
                trans_text = chat_entry.get("trans_text")
                msgtype = chat_entry.get("msgtype")
                msgtime = chat_entry.get("time")

                if chat_id is not None:
                    if use == 1:
                        translated_text = translate_text(
                            lang, chat_id, name, trans_text
                        )
                        converted_text = translated_text.replace("＿＿", "__")
                        print("翻訳後のテキスト:", translated_text)

                    try:
                        splitted_text = converted_text.split("__")
                        trans_name = splitted_text[0]
                        trans_text = splitted_text[1] or " "

                    except IndexError:
                        # print("Error: Failed to split the translated text.")
                        pass  # エラーが発生した場合に次の繰り返しに移る

                    if os.path.exists(output_file):
                        with open(output_file, "r", encoding="utf-8") as file:
                            existing_output = json.load(file)
                            existing_output.append(
                                {
                                    "chat_id": chat_id,
                                    "org_name": trans_name,
                                    "trans_text": trans_text,
                                    "msgtype": msgtype,
                                    "time": msgtime,
                                }
                            )
                           
                        with open(output_file, "w", encoding="utf-8") as f:
                            json.dump(existing_output, f, ensure_ascii=False, indent=4)

                    if os.path.exists(names_file):
                        with open(names_file, "r", encoding="utf-8") as file:
                            existing_names = json.load(file)

                    if name not in existing_names:
                        existing_names[name] = trans_name

                        # ファイルに書き込む
                        with open(names_file, "w", encoding="utf-8") as f:
                            json.dump(existing_names, f, ensure_ascii=False, indent=4)

                    # 処理したエントリーを削除
                    
                    del settings[0]

                    # 更新した設定をファイルに書き込む
                    with open(temp_file, "w", encoding="utf-8") as file:
                        json.dump(settings, file, ensure_ascii=False, indent=4)

                # 適当な時間スリープする
                    time.sleep(1)  # 1秒間スリープ"""
