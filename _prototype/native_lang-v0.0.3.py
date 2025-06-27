# MIT License
# Copyright (c) 2024 norisan
# Version 0.2.0

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

# --- 実行環境を自動で判定してパスを設定 ---
if hasattr(sys, 'frozen'):
    exe_dir = os.path.dirname(sys.executable)
else:
    current_dir = os.path.dirname(os.path.abspath(__file__))
    exe_dir = os.path.abspath(os.path.join(current_dir, ".."))

# --- ユーティリティ関数 ---
def terminate_self():
    try:
        print("自身のプロセスを終了します...")
        psutil.Process(os.getpid()).terminate()
    except Exception as e:
        print(f"エラーが発生しました: {e}")

class ProcessMonitor:
    def __init__(self, process_name, restart_path, stop_callback, interval=5):
        self.process_name = process_name
        self.restart_path = restart_path
        self.stop_callback = stop_callback
        self.interval = interval

    def _get_process_id(self):
        for process in psutil.process_iter(['name']):
            if process.info['name'] == self.process_name:
                return process.pid
        return None

    def _monitor_loop(self):
        while True:
            pid = self._get_process_id()
            if pid is None or not psutil.pid_exists(pid):
                print(f"{self.process_name} は終了しました。翻訳ツールを終了します。")
                self.stop_callback()
                break
            elif os.path.isfile(self.restart_path):
                try:
                    os.remove(self.restart_path)
                    print("restart.dat を削除しました。翻訳ツールを終了します。")
                    self.stop_callback()
                    break
                except OSError as e:
                    print(f"削除に失敗しました: {e}")
            time.sleep(self.interval)

    def start(self):
        monitor_thread = threading.Thread(target=self._monitor_loop)
        monitor_thread.daemon = True
        monitor_thread.start()
        print(f"{self.process_name} の監視を開始しました。")

# 変更点: 新しく「発言を翻訳する」クラスを追加したわ
class OutgoingTranslator:
    def __init__(self, base_dir, driver, lang):
        self.base_dir = base_dir
        self.driver = driver
        self.lang = lang # Managerから渡された言語設定を使う
        self.send_path = os.path.join(self.base_dir, "my_send.dat")
        self.recv_path = os.path.join(self.base_dir, "my_recv.dat")
        
        # 変更点: どの言語で動作しているか表示するわ
        print(f"発言翻訳: -> {self.lang}")

    def _translate_str(self, text, max_attempts=5):
        attempt = 1
        translated_text = text
        while attempt <= max_attempts:
            try:
                self.driver.get(f"https://translate.google.com/?sl=auto&tl={self.lang}&text={text}")
                element = WebDriverWait(self.driver, 2).until(
                    EC.presence_of_element_located((By.CSS_SELECTOR, "span[jsname='W297wb']"))
                )
                translated_text = element.text
                break
            except Exception:
                print(f"発言の翻訳エラー。試行: {attempt}")
                attempt += 1
        return translated_text

    def process_speech(self):
        # my_send.dat が存在して、中身があるかチェック
        if not os.path.exists(self.send_path) or os.path.getsize(self.send_path) == 0:
            return
        
        # ファイルを読み込んで、すぐに削除。これで二重処理を防ぐの。
        with open(self.send_path, 'r', encoding='utf-8') as f:
            line = f.read().strip()
        os.remove(self.send_path)
        
        if not line: return

        # 受け取ったデータを ':::' で分解する
        parts = line.split(':::')
        
        # フォーマットが正しいかチェック ({chat_id}::{org_msg}::{sep} の3分割)
        if len(parts) != 3:
            print(f"発言のフォーマットが不正です: {line}")
            # 不正な場合は、元のテキストをそのまま返しちゃう
            with open(self.recv_path, 'w', encoding='utf-8') as f:
                f.write(line)
            return

        # 各パーツを変数に分かりやすく格納するわね
        chat_id, org_msg, sep = parts

        # 元のメッセージ(org_msg)を翻訳
        translated_msg = self._translate_str(org_msg)
        print(f"発言翻訳: {org_msg} -> {translated_msg}")

        # 新しいフォーマットで返却用の文字列を組み立てる
        result_line = f"{chat_id}:::{{#FF0000}}☆{{/}}{translated_msg}:::{sep}"

        # 翻訳結果を my_recv.dat に書き出す
        with open(self.recv_path, 'w', encoding='utf-8') as f:
            f.write(result_line)

class IncomingTranslator:
    # 変更点: __init__で言語設定(lang)を直接受け取るようにしたわ
    def __init__(self, base_dir, driver, lang):
        self.base_dir = base_dir
        self.driver = driver # WebDriverは共有
        self.lang = lang # Managerから渡された言語設定を使う
        self.file_paths = {
            "send_msg": os.path.join(self.base_dir, "send_msg.dat"),
            "recv_msg": os.path.join(self.base_dir, "recv_msg.dat"),
            "send_name": os.path.join(self.base_dir, "send_name.dat"),
            "recv_name": os.path.join(self.base_dir, "recv_name.dat"),
        }
        # 削除: self.settings や _load_settings() はManagerに任せるから、ここでは不要よ
        
        self.translated_chat_ids = set()
        self.names_to_skip = set()
        
        # 変更点: どの言語で動作しているか分かりやすく表示するわね
        print(f"受信翻訳: -> {self.lang}")

    def _load_settings(self):
        settings_path = self.file_paths["settings"]
        if os.path.exists(settings_path):
            with open(settings_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        return {"use": 1, "lang": "en"}

    def _translate_str(self, text, max_attempts=5):
        attempt = 1
        translated_text = text
        while attempt <= max_attempts:
            try:
                # 受信メッセージは自動検出(auto)から指定言語へ
                self.driver.get(f"https://translate.google.com/?sl=auto&tl={self.lang}&text={text}")
                element = WebDriverWait(self.driver, 2).until(
                    EC.presence_of_element_located((By.CSS_SELECTOR, "span[jsname='W297wb']"))
                )
                translated_text = element.text
                break
            except Exception:
                print(f"受信メッセージの翻訳エラー。試行: {attempt}")
                attempt += 1
        return translated_text

    def load_translated_data(self):
        if os.path.exists(self.file_paths["recv_msg"]):
            with open(self.file_paths["recv_msg"], 'r', encoding='utf-8') as f:
                self.translated_chat_ids = {line.split(':::')[0] for line in f if ":::" in line}
        if os.path.exists(self.file_paths["recv_name"]):
            with open(self.file_paths["recv_name"], 'r', encoding='utf-8') as f:
                self.names_to_skip = {line.split(':::')[0] for line in f if ":::" in line}
        print(f"読み込み完了: 翻訳済みメッセージ {len(self.translated_chat_ids)}件, 名前 {len(self.names_to_skip)}件")

    def process_names(self):
        send_path = self.file_paths["send_name"]
        if not os.path.exists(send_path): return
        with open(send_path, 'r', encoding='utf-8') as f: lines = f.readlines()
        
        updated_lines = []
        for line in lines:
            parts = line.strip().split(':::')
            if len(parts) != 2: continue
            
            original_name, replace_name = parts
            if original_name in self.names_to_skip: continue

            if original_name == replace_name:
                translated = self._translate_str(original_name)
                print(f"名前翻訳: {original_name} -> {translated}")
                if translated != original_name:
                    replace_name = f"{{#FF0000}}★{{/}}{translated}"
                updated_lines.append(f"{original_name}:::{replace_name}\n")
            
            self.names_to_skip.add(original_name)
        
        if updated_lines:
            with open(self.file_paths["recv_name"], 'a', encoding='utf-8') as f:
                f.writelines(updated_lines)

    def process_messages(self):
        send_path = self.file_paths["send_msg"]
        if not os.path.exists(send_path) or os.path.getsize(send_path) == 0: return
        with open(send_path, 'r', encoding='utf-8', errors='ignore') as f: lines = f.readlines()

        updated_lines = []
        for line in lines:
            parts = line.strip().split(':::')
            if len(parts) != 6: continue
            
            chat_id, msg_type, msg, sep, org_msg, org_name = parts
            if chat_id in self.translated_chat_ids: continue
            
            translated = self._translate_str(msg)
            print(f"メッセージ翻訳: {chat_id}: {msg} -> {translated}")
            if translated and translated != msg:
                updated_lines.append(f"{chat_id}:::{msg_type}:::{{#FF0000}}★{{/}}{translated}:::{sep}:::{org_msg}:::{org_name}\n")
            else:
                updated_lines.append(line)
            self.translated_chat_ids.add(chat_id)

        if updated_lines:
            with open(self.file_paths["recv_msg"], 'a', encoding='utf-8') as f:
                f.writelines(updated_lines)

# 変更点: 司令塔となるクラスを追加して、全体を管理するようにしたわ
class TranslationManager:
    def __init__(self, base_dir):
        self.base_dir = base_dir
        self.driver = None
        self.incoming_translator = None
        self.outgoing_translator = None

    def _create_driver(self):
        try:
            chrome_options = Options()
            chrome_options.add_argument("--headless")
            chrome_options.add_argument("--incognito")
            self.driver = webdriver.Chrome(options=chrome_options)
            print("WebDriverが正常に初期化されました。")
            return True
        except Exception as e:
            print(f"WebDriverの初期化中にエラーが発生しました: {e}")
            return False
        
    def _load_settings(self): # 新しく設定読み込みメソッドを作る
        settings_path = os.path.join(self.base_dir, "settings.json")
        if os.path.exists(settings_path):
            with open(settings_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        # デフォルト設定
        return {"use": 1, "incoming_lang": "ja", "outgoing_lang": "en"}

    def run(self):
        if not self._create_driver(): return
        
        # Managerが設定を読み込む
        settings = self._load_settings()
        incoming_lang = settings.get("incoming_lang", "ja") # なかったら日本語に
        outgoing_lang = settings.get("outgoing_lang", "en") # なかったら英語に
        
        # それぞれのクラスに、別々の言語設定を渡す
        self.incoming_translator = IncomingTranslator(self.base_dir, self.driver, incoming_lang)
        self.outgoing_translator = OutgoingTranslator(self.base_dir, self.driver, outgoing_lang)

        # 過去の翻訳データを読み込む
        self.incoming_translator.load_translated_data()
        
        # 監視スレッドを開始
        monitor = ProcessMonitor(
            process_name="Client_tos_x64.exe",
            restart_path=self.incoming_translator.file_paths["restart"],
            stop_callback=self.stop
        )
        monitor.start()

        print("ファイル監視を開始しました。")
        while True:
            try:
                # 受信と発言の両方を処理する
                self.incoming_translator.process_names()
                self.incoming_translator.process_messages()
                self.outgoing_translator.process_speech()
            except Exception as e:
                print(f"メインループでエラーが発生しました: {e}")
            time.sleep(0.5) # 変更点: チェック間隔を少し短くしてみたわ

    def stop(self):
        if self.driver:
            self.driver.quit()
            print("WebDriverが正常に終了しました。")
        terminate_self()


if __name__ == "__main__":
    # 司令塔のインスタンスを作って、実行するだけ！
    manager = TranslationManager(base_dir=exe_dir)
    manager.run()