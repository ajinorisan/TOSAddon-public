# MIT License
# Copyright (c) 2024 norisan
# Version 0.0.4

import json
import os
import threading
import sys
import psutil
import time

# 変更: メッセージボックス表示のためにtkinterをインポート
import tkinter as tk
from tkinter import messagebox

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
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

def show_error_and_exit(title, message):
  
    print(f"重大なエラー: {title} - {message}")
    # tkinterのウィンドウが裏に隠れちゃうのを防ぐおまじない
    root = tk.Tk()
    root.withdraw()
    messagebox.showerror(title, message)
   
    terminate_self()

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
        # 変更: ファイルの存在チェックを厳密にしたわ
        if not os.path.exists(self.send_path) or os.path.getsize(self.send_path) == 0:
            return
        
        # 変更: ファイルをリネームして処理することで、処理中のデータ損失を防ぐわ
        processing_path = self.send_path + ".processing"
        try:
            os.rename(self.send_path, processing_path)
        except OSError: # リネームしようとした瞬間にファイルが消えてた、なんて場合のため
            return

        try:
            with open(processing_path, 'r', encoding='utf-8') as f:
                line = f.read().strip()
        except Exception as e:
            print(f"my_send.dat の読み込みエラー: {e}")
            line = "" # エラーが起きても後処理は進める
        finally:
            # 変更: 処理が終わったリネーム後ファイルを削除
            os.remove(processing_path)

        if not line: return

        parts = line.split(':::')
        if len(parts) != 3:
            print(f"発言のフォーマットが不正です: {line}")
            if len(parts) >= 2:
                result_line = f"{parts[0]}:::{parts[1]}:::"
                with open(self.recv_path, 'w', encoding='utf-8') as f: f.write(result_line)
            return

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

    # 変更: ネストした関数をやめて、元の分かりやすい形に戻したわ
    def process_names(self):
        send_path = self.file_paths["send_name"]
        if not os.path.exists(send_path) or os.path.getsize(send_path) == 0: return

        # 安全なファイル処理（リネーム方式）はそのまま使うわよ
        processing_path = send_path + ".processing"
        try:
            os.rename(send_path, processing_path)
        except OSError:
            return

        lines = []
        try:
            with open(processing_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except Exception as e:
            print(f"send_name.dat の読み込みエラー: {e}")
        finally:
            os.remove(processing_path)
        
        if not lines: return

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

    # 変更: こっちも同じように、ネストした関数をやめて元の形に戻したわ
    def process_messages(self):
        send_path = self.file_paths["send_msg"]
        if not os.path.exists(send_path) or os.path.getsize(send_path) == 0: return
        
        # 安全なファイル処理（リネーム方式）はこっちでも活躍！
        processing_path = send_path + ".processing"
        try:
            os.rename(send_path, processing_path)
        except OSError:
            return

        lines = []
        try:
            with open(processing_path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
        except Exception as e:
            print(f"send_msg.dat の読み込みエラー: {e}")
        finally:
            os.remove(processing_path)

        if not lines: return

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
        self._is_stopping = False # 変更: 二重に終了処理が走らないようにするためのフラグよ

    def _create_driver(self):
        try:
            chrome_options = Options()
            chrome_options.add_argument("--headless")
            chrome_options.add_argument("--incognito")
            chrome_options.add_experimental_option('excludeSwitches', ['enable-logging']) # 変更: 余計なログを非表示にしてコンソールをスッキリさせたわ
          
            service = ChromeService(ChromeDriverManager().install())
            self.driver = webdriver.Chrome(service=service, options=chrome_options)
            print("WebDriverが正常に初期化されました。")
            return True
        except Exception as e:
             # 変更: WebDriver初期化失敗は致命的！メッセージボックスで通知するわ
            error_message = (
                f"翻訳エンジンの起動に失敗しました。\n\n"
                f"・Chromeブラウザがインストールされていますか？\n"
                f"・インターネットに接続されていますか？\n\n"
                f"エラー詳細: {e}"
            )
            show_error_and_exit("致命的なエラー", error_message)
            return False
        
    def _load_settings(self):
        settings_path = os.path.join(self.base_dir, "settings.json")
       
        default_settings = { "lang": "ja", "recv_lang": "en" }
        
        loaded_settings = {}
        try:
            if os.path.exists(settings_path):
                with open(settings_path, 'r', encoding='utf-8') as f:
                    loaded_settings = json.load(f)
        except Exception as e:
            print(f"settings.json の読み込みエラー: {e}")
            return default_settings

        final_settings = default_settings.copy()
        final_settings.update(loaded_settings)
        return final_settings

    def run(self):
        if not self._create_driver():
            return # _create_driverの中で終了処理までしちゃうから、ここはreturnするだけ
        
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
        
        while not self._is_stopping:
            try:
                self.outgoing_translator.process_speech()

                if loop_counter % 5 == 0:
                    self.incoming_translator.process_names()
                    self.incoming_translator.process_messages()

            except Exception as e:
                # 変更: メインループでの予期せぬエラーも、メッセージボックスで通知よ！
                error_message = f"翻訳処理中に予期せぬエラーが発生しました。\nプログラムを再起動してください。\n\nエラー詳細: {e}"
                # ここでは直接終了させず、stop()を呼んで綺麗に後片付けするわ
                self.stop() 
                show_error_and_exit("予期せぬエラー", error_message)
                break # ループを抜ける

            loop_counter = (loop_counter + 1) % 1000
            time.sleep(0.1)

    def stop(self):
        if self._is_stopping:
            return
        self._is_stopping = True
        print("終了処理を開始します...")

        if self.driver:
            # 変更: driverの終了処理もtry-exceptで囲んで、より安全にしたわ
            try:
                self.driver.quit()
                print("WebDriverが正常に終了しました。")
            except Exception as e:
                print(f"WebDriverの終了中にエラーが発生しました: {e}")

if __name__ == "__main__":
    manager = None
    try:
        manager = TranslationManager(base_dir=exe_dir)
        manager.run()
    except KeyboardInterrupt:
        print("\n手動で終了します...")
    except Exception as e:
        # 変更: ここで起きるエラーは、主にmanager.run()より前の段階。これも通知！
        error_message = f"プログラムの初期化中に予期せぬエラーが発生しました。\n\nエラー詳細: {e}"
        show_error_and_exit("起動エラー", error_message)
    finally:
        if manager:
            # 変更: stop()を呼んだ後、プロセスを終了させる
            manager.stop()
            terminate_self()
        else:
            # managerすらいない場合は、直接終了
            terminate_self()