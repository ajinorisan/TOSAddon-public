# MIT License
# Copyright (c) 2024 norisan
# Version 0.0.4

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
# ★★★ webdriver-manager をインポート ★★★
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager

# --- 実行環境を自動で判定してパスを設定 ---
if hasattr(sys, 'frozen'):
    exe_dir = os.path.dirname(sys.executable)
else:
    script_dir = os.path.dirname(os.path.abspath(__file__))
    exe_dir = os.path.abspath(os.path.join(script_dir, ".."))

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
            elif os.path.exists(self.restart_path) and os.path.isfile(self.restart_path): # os.path.existsを追加
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

class OutgoingTranslator:
  
    def __init__(self, base_dir, driver, lang):
        self.base_dir = base_dir
        self.driver = driver
        self.lang = lang
        self.send_path = os.path.join(self.base_dir, "my_send.dat")
        self.recv_path = os.path.join(self.base_dir, "my_recv.dat")
        print(f"発言翻訳: -> {self.lang}")

    def _translate_str(self, text, max_attempts=5):

        if not text.strip():
            return ""
        
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
        if not os.path.exists(self.send_path) or os.path.getsize(self.send_path) == 0:
            return
        
        try: # ファイル操作はtry-exceptで囲むとより安全
            with open(self.send_path, 'r', encoding='utf-8') as f:
                line = f.read().strip()
            os.remove(self.send_path)
        except Exception as e:
            print(f"my_send.dat の読み込み/削除エラー: {e}")
            return

        if not line: return

        parts = line.split(':::')
        if len(parts) != 3:
            print(f"発言のフォーマットが不正です: {line}")
            if len(parts) >= 2:
                # Lua側が `msg_type .. trans_msg .. org_msg` を期待しているので、
                # `trans_msg`に元のメッセージ(parts[1])を、`org_msg`に空文字を設定して返す
                result_line = f"{parts[0]}:::{parts[1]}:::"
                with open(self.recv_path, 'w', encoding='utf-8') as f: f.write(result_line)
            return

        #msg_type,org_msg_retun,org_msg, sep = parts
        msg_type,org_msg_retun,org_msg = parts
        translated_msg = self._translate_str(org_msg)
        print(f"発言翻訳: {org_msg} -> {translated_msg}")
    
        result_line = f"{msg_type}:::{translated_msg}:::({org_msg_retun})"
        print(result_line)
        with open(self.recv_path, 'w', encoding='utf-8') as f: f.write(result_line)

class IncomingTranslator:

    def __init__(self, base_dir, driver, lang):
        self.base_dir = base_dir
        self.driver = driver
        self.lang = lang
        self.file_paths = {
            "send_msg": os.path.join(self.base_dir, "send_msg.dat"),
            "recv_msg": os.path.join(self.base_dir, "recv_msg.dat"),
            "send_name": os.path.join(self.base_dir, "send_name.dat"),
            "recv_name": os.path.join(self.base_dir, "recv_name.dat"),
        }
        self.translated_chat_ids = set()
        self.names_to_skip = set()
        print(f"受信翻訳: -> {self.lang}")

    def _translate_str(self, text, max_attempts=5):

        if not text.strip():
            return ""
        
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
        if not os.path.exists(send_path) or os.path.getsize(send_path) == 0: return 
        with open(send_path, 'r', encoding='utf-8') as f: lines = f.readlines()
        if not lines: return
        os.remove(send_path) 
        
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
            else: 
                updated_lines.append(line)
            
            self.names_to_skip.add(original_name)
        
        if updated_lines:
            with open(self.file_paths["recv_name"], 'a', encoding='utf-8') as f:
                f.writelines(updated_lines)

    def process_messages(self):
        send_path = self.file_paths["send_msg"]
        if not os.path.exists(send_path) or os.path.getsize(send_path) == 0: return
        with open(send_path, 'r', encoding='utf-8', errors='ignore') as f: lines = f.readlines()
        if not lines: return
        os.remove(send_path)
        
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


class TranslationManager:
    def __init__(self, base_dir):
        self.base_dir = base_dir
        self.driver = None
        self.incoming_translator = None
        self.outgoing_translator = None
      
        self.restart_file_path = os.path.join(self.base_dir, "restart.dat")

    def _create_driver(self):
        try:
            chrome_options = Options()
            chrome_options.add_argument("--headless")
            chrome_options.add_argument("--incognito")
          
            service = ChromeService(ChromeDriverManager().install())
            self.driver = webdriver.Chrome(service=service, options=chrome_options)
            print("WebDriverが正常に初期化されました。")
            return True
        except Exception as e:
            print(f"WebDriverの初期化中にエラーが発生しました: {e}")
            print("Chromeブラウザがインストールされているか、またはバージョンが古すぎないか確認してください。")
            return False
        
    def _load_settings(self):
        settings_path = os.path.join(self.base_dir, "settings.json")
       
        default_settings = {
            "lang": "ja",
            "recv_lang": "en"
        }
        
        loaded_settings = {}
        try:
            if os.path.exists(settings_path):
                with open(settings_path, 'r', encoding='utf-8') as f:
                    loaded_settings = json.load(f)
        except Exception as e:
            print(f"settings.json の読み込みエラー: {e}")
            return default_settings

        final_settings = {
            "lang": loaded_settings.get("lang", default_settings["lang"]),
            "recv_lang": loaded_settings.get("recv_lang", default_settings["recv_lang"]),
        }
        
        return final_settings

    def run(self):
        if not self._create_driver():
            time.sleep(10) # エラー時に即終了しないように少し待つ
            return
        
        settings = self._load_settings()
        incoming_lang = settings.get("lang", "ja")
        outgoing_lang = settings.get("recv_lang", "en")
        
        self.incoming_translator = IncomingTranslator(self.base_dir, self.driver, incoming_lang)
        self.outgoing_translator = OutgoingTranslator(self.base_dir, self.driver, outgoing_lang)
        self.incoming_translator.load_translated_data()
        
        monitor = ProcessMonitor(
            process_name="Client_tos_x64.exe",
            restart_path=self.restart_file_path,
            stop_callback=self.stop
        )
        monitor.start()

        print("ファイル監視を開始しました。")
        loop_counter = 0
        
        while True:
            try:
                # --- 毎回 (0.1秒ごと) 実行する処理 ---
                self.outgoing_translator.process_speech()

                # --- 特定の回数ごと (0.5秒ごと) に実行する処理 ---
                # loop_counter が 0, 5, 10, ... の時に実行される (0.1秒 * 5 = 0.5秒)
                if loop_counter % 5 == 0:
                    # print(f"--- 0.5秒ごとの処理を実行 (カウンター: {loop_counter}) ---")
                    self.incoming_translator.process_names()
                    self.incoming_translator.process_messages()

            except Exception as e:
                print(f"メインループでエラーが発生しました: {e}")

            # ループカウンターを更新
            loop_counter += 1
            if loop_counter >= 1000:
                loop_counter = 0

            time.sleep(0.1)

    def stop(self):
        if self.driver:
            self.driver.quit()
            print("WebDriverが正常に終了しました。")
        terminate_self()

if __name__ == "__main__":
    manager = TranslationManager(base_dir=exe_dir)
    manager.run()