# MIT License
# Copyright (c) 2024 norisan
# Version 1.0.1 (Final, full_snake_case, simplified)

import json
import os
import threading
import sys
import psutil
import time
import traceback
import tkinter as tk
from tkinter import messagebox
from deep_translator import GoogleTranslator

# --- 定数定義 ---
# 変更点：ファイル名の定数は、もう、いらないわ！
BASE_DIR = os.path.dirname(sys.executable) if hasattr(sys, 'frozen') else os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
TOS_PROCESS_NAME = "Client_tos_x64.exe"

# --- ユーティリティ関数 ---
def terminate_self():
    try:
        psutil.Process(os.getpid()).terminate()
    except Exception as e:
        print(f"プロセスの終了中にエラー: {e}")

def show_error_and_exit(title, message):
    detailed_message = f"{message}\n\nTraceback:\n{traceback.format_exc()}"
    print(f"重大なエラー: {title} - {detailed_message}")
    
    def display_messagebox():
        root = tk.Tk()
        root.withdraw()
        messagebox.showerror(title, detailed_message)
        root.destroy()
    
    threading.Thread(target=display_messagebox).start()

# --- コアクラス (スネークケース版) ---
class process_monitor:
    def __init__(self, process_name, restart_path, stop_callback, interval=5):
        self.process_name = process_name
        self.restart_path = restart_path
        self.stop_callback = stop_callback
        self.interval = interval
        self.thread = threading.Thread(target=self._monitor_loop, daemon=True)

    def _is_process_running(self):
        return any(proc.info['name'] == self.process_name for proc in psutil.process_iter(['name']))

    def _monitor_loop(self):
        while True:
            try:
                if not self._is_process_running() or os.path.exists(self.restart_path):
                    reason = "プロセスが終了しました" if not self._is_process_running() else "restart.datが検出されました"
                    print(f"{reason}。翻訳ツールを終了します。")
                    if os.path.exists(self.restart_path):
                        os.remove(self.restart_path)
                    self.stop_callback()
                    break
            except Exception as e:
                print(f"監視スレッドでエラー: {e}")
            time.sleep(self.interval)

    def start(self):
        self.thread.start()
        print(f"{self.process_name} の監視を開始しました。")

class translation_engine:
    def translate(self, text, dest_lang, src_lang='auto', max_attempts=3):
        if not text or not text.strip():
            return text

        attempt = 1
        while attempt <= max_attempts:
            try:
                translated_text = GoogleTranslator(source=src_lang, target=dest_lang).translate(text)
                
                if translated_text and not translated_text.strip().startswith("Error 500 (Server Error)!!1500"):
                    return translated_text
                else:
                    print(f"翻訳APIがエラーメッセージを返しました: '{translated_text}'")
                    raise ValueError("API returned an error message.")
            except Exception as e:
                print(f"翻訳エラー。試行: {attempt}, エラー: {e}")
                time.sleep(1)
                attempt += 1
        
        print(f"翻訳に最終的に失敗しました: '{text}'")
        return text

class file_processor:
    def __init__(self, base_dir, lang, engine):
        self.base_dir = base_dir
        self.lang = lang
        self.engine = engine
        # 変更点：ファイルパスは、ここで、直接、定義する！これが一番、分かりやすい！
        self.file_paths = {
            "send_msg": os.path.join(base_dir, "send_msg.dat"),
            "recv_msg": os.path.join(base_dir, "recv_msg.dat"),
            "send_name": os.path.join(base_dir, "send_name.dat"),
            "recv_name": os.path.join(base_dir, "recv_name.dat"),
        }
        self.translated_chat_ids = set()
        self.translated_names = {}
        print(f"ファイル処理準備完了: -> {self.lang}")

    def load_translated_data(self):
        try:
            if os.path.exists(self.file_paths["recv_msg"]):
                with open(self.file_paths["recv_msg"], 'r', encoding='utf-8') as f:
                    self.translated_chat_ids = {line.split(':::')[0] for line in f if ":::" in line}
            
            if os.path.exists(self.file_paths["recv_name"]):
                with open(self.file_paths["recv_name"], 'r', encoding='utf-8') as f:
                    for line in f:
                        if ":::" in line:
                            parts = line.strip().split(':::')
                            if len(parts) == 2:
                                self.translated_names[parts[0]] = parts[1]
            
            print(f"読み込み完了: 翻訳済みメッセージ {len(self.translated_chat_ids)}件, 名前 {len(self.translated_names)}件")
        except Exception as e:
            print(f"翻訳履歴の読み込みエラー: {e}")

    def _process_file(self, send_key, recv_key, process_line_func):
        send_path = self.file_paths[send_key]
        if not os.path.exists(send_path) or os.path.getsize(send_path) == 0:
            return

        processing_path = send_path + ".processing"
        try:
            os.rename(send_path, processing_path)
        except OSError:
            return

        lines_to_write = []
        try:
            with open(processing_path, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    processed_line = process_line_func(line)
                    if processed_line:
                        lines_to_write.append(processed_line)
        except Exception as e:
            print(f"{send_path} の処理中にエラー: {e}")
        finally:
            if os.path.exists(processing_path):
                os.remove(processing_path)

        if lines_to_write:
            with open(self.file_paths[recv_key], 'a', encoding='utf-8') as f:
                f.writelines(lines_to_write)

    def process_names(self):
        def _process_line(line):
            clean_line = line.strip()
            parts = clean_line.split(':::')
            if len(parts) != 2: return None
            
            original_name, replace_name = parts
            if original_name in self.translated_names: return None
            
            if original_name == replace_name:
                translated = self.engine.translate(original_name, dest_lang=self.lang)
                print(f"名前翻訳: {original_name} -> {translated}")
                if translated and translated.lower() != original_name.lower():
                    replace_name = f"{{#FF0000}}★{{/}}{translated}"
            
            self.translated_names[original_name] = replace_name
            return f"{original_name}:::{replace_name}\n"

        self._process_file("send_name", "recv_name", _process_line)
    
    def process_messages(self):
        def _process_line(line):
            clean_line = line.strip()
            parts = clean_line.split(':::')
            if len(parts) != 6: return None

            chat_id, msg_type, msg, sep, org_msg, org_name = parts
            if chat_id in self.translated_chat_ids: return None
            self.translated_chat_ids.add(chat_id)

            translated_msg = self.engine.translate(msg, dest_lang=self.lang)
            print(f"メッセージ翻訳: {chat_id}: '{msg}' -> '{translated_msg}'")
            
            final_msg = msg
            if translated_msg and translated_msg.lower() != msg.lower():
                final_msg = f"{{#FF0000}}★{{/}}{translated_msg}"

            final_org_name = self.translated_names.get(org_name, org_name)
            return f"{chat_id}:::{msg_type}:::{final_msg}:::{sep}:::{org_msg}:::{final_org_name}\n"

        self._process_file("send_msg", "recv_msg", _process_line)
        self._trim_log(self.file_paths["recv_msg"])

    def _trim_log(self, file_path, max_lines=350):
        try:
            if not os.path.exists(file_path): return
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            if len(lines) > max_lines:
                print(f"{file_path} が {max_lines}行を超えました。古い行を削除します。")
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.writelines(lines[-max_lines:])
        except Exception as e:
            print(f"ログの行数調整中にエラー: {e}")

class speech_processor:
    def __init__(self, base_dir, lang, engine):
        self.base_dir = base_dir
        self.lang = lang
        self.engine = engine
        # 変更点：ここも、直接、ファイル名を指定する！
        self.send_path = os.path.join(base_dir, "my_send.dat")
        self.recv_path = os.path.join(base_dir, "my_recv.dat")
        print(f"発言翻訳プロセッサ準備完了: -> {self.lang}")

    def process(self):
        if not os.path.exists(self.send_path) or os.path.getsize(self.send_path) == 0:
            return

        processing_path = self.send_path + ".processing"
        try:
            os.rename(self.send_path, processing_path)
        except OSError:
            return

        line = ""
        try:
            with open(processing_path, 'r', encoding='utf-8') as f:
                line = f.read().strip()
        finally:
            if os.path.exists(processing_path):
                os.remove(processing_path)

        if not line: return

        parts = line.split(':::')
        if len(parts) != 3: return
        
        msg_type, org_msg_return, org_msg = parts
        translated_msg = self.engine.translate(org_msg, dest_lang=self.lang)
        
        result_line = f"{msg_type}{translated_msg}({org_msg_return})" if translated_msg and translated_msg.lower() != org_msg.lower() else f"{msg_type}{org_msg_return}"
        
        print(f"  [送信] Luaへの返信データ: '{result_line}'")
        with open(self.recv_path, 'w', encoding='utf-8') as f:
            f.write(result_line)

class translation_manager:
    def __init__(self, base_dir):
        self.base_dir = base_dir
        self.engine = translation_engine()
        self.file_processor = None
        self.speech_processor = None
        # 変更点：ここも、直接、ファイル名を指定！
        self.restart_file_path = os.path.join(base_dir, "restart.dat")
        self._stop_lock = threading.Lock()
        self._is_stopping = False
        self.settings_path = os.path.join(self.base_dir, "settings.json")

    def _load_settings(self):
        settings = {"lang": "ja", "recv_lang": "en"}
        try:
            if os.path.exists(self.settings_path):
                with open(self.settings_path, 'r', encoding='utf-8') as f:
                    settings.update(json.load(f))
        except Exception as e:
            print(f"settings.json の読み込みエラー: {e}")
        return settings


    def run(self):
        settings = self._load_settings()
        
        self.file_processor = file_processor(self.base_dir, settings.get("lang", "ja"), self.engine)
        self.speech_processor = speech_processor(self.base_dir, settings.get("recv_lang", "en"), self.engine)
        
        self.file_processor.load_translated_data()
        
        monitor = process_monitor(TOS_PROCESS_NAME, self.restart_file_path, self.stop)
        monitor.start()
        
        print("ファイル監視を開始しました。")
        
        loop_counter = 0
        while not self._is_stopping:
            try:
                # 変更点2：ここがキモよ！
                # 10回に1回くらい、設定ファイルを、もう一度、読み直しに行く！
                if loop_counter % 10 == 0:
                    new_settings = self._load_settings()
                    new_speech_lang = new_settings.get("recv_lang", "en")
                    # もし、言語設定が変わってたら…
                    if self.speech_processor.lang != new_speech_lang:
                        print(f"発言の翻訳言語が変更されました: {self.speech_processor.lang} -> {new_speech_lang}")
                        # speech_processor の、言語設定だけを、こっそり、書き換えてあげる
                        self.speech_processor.lang = new_speech_lang
                
                self.speech_processor.process()
                
                if loop_counter % 5 == 0:
                    self.file_processor.process_names()
                    self.file_processor.process_messages()

            except Exception as e:
                show_error_and_exit("実行時エラー", f"翻訳処理中に予期せぬエラーが発生しました。\n\nエラー詳細: {e}")
                self.stop()
                break

            loop_counter = (loop_counter + 1) % 1000
            time.sleep(0.1)

    def stop(self):
        with self._stop_lock:
            if self._is_stopping: return
            self._is_stopping = True
        print("終了処理を開始します...")

if __name__ == "__main__":
    manager = None
    try:
        manager = translation_manager(base_dir=BASE_DIR)
        manager.run()
    except KeyboardInterrupt:
        print("\n手動で終了します...")
    except Exception as e:
        show_error_and_exit("起動エラー", f"プログラムの初期化中に予期せぬエラーが発生しました。\n\nエラー詳細: {e}")
    finally:
        if manager:
            manager.stop()
        terminate_self()

'''# MIT License
# Copyright (c) 2024 norisan
# Version 0.0.5 (deep-translator版)

import json
import os
import threading
import sys
import psutil
import time
import traceback

# GUIのメッセージボックスを表示するためにtkinterをインポート
import tkinter as tk
from tkinter import messagebox

# 変更点：googletransの代わりに、deep_translatorを使う！
# pip install deep-translator でインストールしてね！
from deep_translator import GoogleTranslator

# --- 実行環境のパス設定 ---
def get_base_dir():
    """実行環境を判定して、アドオンの基準パスを返す"""
    # .exe化された場合は実行ファイルがあるディレクトリ
    if hasattr(sys, 'frozen'):
        return os.path.dirname(sys.executable)
    # スクリプト実行時は、このファイルの親ディレクトリを基準にする
    else:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        return os.path.abspath(os.path.join(script_dir, ".."))

BASE_DIR = get_base_dir()

# --- ユーティリティ関数 ---
def terminate_self():
    """自分自身のプロセスを強制終了させる"""
    try:
        print("自身のプロセスを終了します...")
        psutil.Process(os.getpid()).terminate()
    except Exception as e:
        print(f"プロセスの終了中にエラーが発生しました: {e}")

def show_error_and_exit(title, message):
    """エラーメッセージをGUIで表示する"""
    detailed_message = f"{message}\n\nTraceback:\n{traceback.format_exc()}"
    print(f"重大なエラー: {title} - {detailed_message}")
    
    # メインスレッド以外からGUIを安全に呼び出すための処理
    def display_messagebox():
        root = tk.Tk()
        root.withdraw()
        messagebox.showerror(title, detailed_message)
        root.destroy()
    
    # GUI表示は別スレッドで行い、本体の終了処理をブロックしない
    threading.Thread(target=display_messagebox).start()

class ProcessMonitor:
    """ToSクライアントのプロセスを監視するクラス"""
    def __init__(self, process_name, restart_path, stop_callback, interval=5):
        self.process_name = process_name
        self.restart_path = restart_path
        self.stop_callback = stop_callback
        self.interval = interval
        self.thread = threading.Thread(target=self._monitor_loop)
        self.thread.daemon = True

    def _is_process_running(self):
        """プロセスが実行中か確認する"""
        for process in psutil.process_iter(['name']):
            if process.info['name'] == self.process_name:
                return True
        return False

    def _monitor_loop(self):
        """監視ループ"""
        while True:
            try:
                if not self._is_process_running():
                    print(f"{self.process_name} は終了しました。翻訳ツールを終了します。")
                    self.stop_callback()
                    break
                
                if os.path.exists(self.restart_path):
                    os.remove(self.restart_path)
                    print("restart.dat を検知しました。翻訳ツールを終了します。")
                    self.stop_callback()
                    break
            except Exception as e:
                print(f"監視スレッドでエラーが発生しました: {e}")
            
            time.sleep(self.interval)

    def start(self):
        """監視スレッドを開始する"""
        self.thread.start()
        print(f"{self.process_name} の監視を開始しました。")

class TranslationEngine:
    """翻訳処理を担うエンジン (deep-translator版)"""
    def __init__(self):
        print("翻訳エンジンを準備しました。")

    def translate(self, text, dest_lang, src_lang='auto', max_attempts=3):
        if not text or not text.strip():
            return None

        attempt = 1
        while attempt <= max_attempts:
            try:
                translated_text = GoogleTranslator(source=src_lang, target=dest_lang).translate(text)
                
               
                if translated_text and not translated_text.strip().startswith("Error 500 (Server Error)!!1500"):
                    if translated_text.lower() != text.lower():
                        return translated_text
                    else:
                        print(f"翻訳失敗 or 結果が同じ: '{text}'")
                        return text # あなたの元のコード通り、元のテキストを返す
                else:
                    print(f"翻訳APIがエラーメッセージを返しました: '{translated_text}'")
                   
                    raise ValueError("API returned an error message.")

            except Exception as e:
                print(f"翻訳エラー。試行: {attempt}, エラー: {e}")
                time.sleep(1)
                attempt += 1
        
        print(f"翻訳に最終的に失敗しました: '{text}'")
        return text

class FileProcessor:
    """
    ファイルの読み書きや翻訳処理を担うクラス。
    """
    def __init__(self, base_dir, lang, engine):
        self.base_dir = base_dir
        self.lang = lang
        self.engine = engine
        self.file_paths = {
            "send_msg": os.path.join(self.base_dir, "send_msg.dat"),
            "recv_msg": os.path.join(self.base_dir, "recv_msg.dat"),
            "send_name": os.path.join(self.base_dir, "send_name.dat"),
            "recv_name": os.path.join(self.base_dir, "recv_name.dat"),
        }
        self.translated_chat_ids = set()
        self.names_to_skip = set()

        self.translated_names = {}
        print(f"ファイル処理準備完了: -> {self.lang}")

    def load_translated_data(self):
        """過去の翻訳履歴をファイルから読み込む"""
        try:
            if os.path.exists(self.file_paths["recv_msg"]):
                with open(self.file_paths["recv_msg"], 'r', encoding='utf-8') as f:
                    self.translated_chat_ids = {line.split(':::')[0] for line in f if ":::" in line}
            
            if os.path.exists(self.file_paths["recv_name"]):
                with open(self.file_paths["recv_name"], 'r', encoding='utf-8') as f:
                    for line in f:
                        if ":::" in line:
                            parts = line.strip().split(':::')
                            if len(parts) == 2:
                                self.names_to_skip.add(parts[0])
                                # 変更点：ロードした名前も、ちゃんと、新しい箱に入れる！
                                self.translated_names[parts[0]] = parts[1]
            
            print(f"読み込み完了: 翻訳済みメッセージ {len(self.translated_chat_ids)}件, 名前 {len(self.names_to_skip)}件")
        except Exception as e:
            print(f"翻訳履歴の読み込みエラー: {e}")

    # 変更点：私がコピペし忘れてた、この大事な関数を、ちゃんとここに追加するわ！
    def _process_file(self, send_key, recv_key, process_line_func):
        """ファイルの読み込み、処理、書き込みを行う共通ロジック"""
        send_path = self.file_paths[send_key]
        if not os.path.exists(send_path) or os.path.getsize(send_path) == 0:
            return

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
            print(f"{send_path} の読み込みエラー: {e}")
        finally:
            if os.path.exists(processing_path):
                os.remove(processing_path)

        if not lines:
            return

        updated_lines = [process_line_func(line) for line in lines]
        updated_lines = [line for line in updated_lines if line]

        if updated_lines:
            with open(self.file_paths[recv_key], 'a', encoding='utf-8') as f:
                f.writelines(updated_lines)

    def process_names(self):
        def _process_line(line):
            clean_line = line.strip()
            parts = clean_line.split(':::')
            if len(parts) != 2: return None
            
            original_name, replace_name = parts
            if original_name in self.names_to_skip: return None
            
            self.names_to_skip.add(original_name)
            
            if original_name == replace_name:
                translated = self.engine.translate(original_name, dest_lang=self.lang)
                print(f"名前翻訳: {original_name} -> {translated}")
                if translated and translated.lower() != original_name.lower():
                    replace_name = f"{{#FF0000}}★{{/}}{translated}"
            
            # 変更点：翻訳したら、Python側のテーブルにも、ちゃんと保存する！
            self.translated_names[original_name] = replace_name
            return f"{original_name}:::{replace_name}\n"

        self._process_file("send_name", "recv_name", _process_line)
    
    def process_messages(self):
        def _process_line(line):
            clean_line = line.strip()
            parts = clean_line.split(':::')
            if len(parts) != 6: return None

            chat_id, msg_type, msg, sep, org_msg, org_name = parts
            
            if chat_id in self.translated_chat_ids: return None
            self.translated_chat_ids.add(chat_id)

            translated_msg = self.engine.translate(msg, dest_lang=self.lang)
            print(f"メッセージ翻訳: {chat_id}: '{msg}' -> '{translated_msg}'")
            
            final_msg = msg
            if translated_msg and translated_msg.lower() != msg.lower():
                final_msg = f"{{#FF0000}}★{{/}}{translated_msg}"

            # 変更点：これで、ちゃんと存在する self.translated_names を参照できる！
            final_org_name = self.translated_names.get(org_name, org_name)

            return f"{chat_id}:::{msg_type}:::{final_msg}:::{sep}:::{org_msg}:::{final_org_name}\n"

        self._process_file("send_msg", "recv_msg", _process_line)
        self._trim_log_to_latest_lines(self.file_paths["recv_msg"])

    def _trim_log_to_latest_lines(self, file_path, max_lines=350):
        try:
            if not os.path.exists(file_path): return
            with open(file_path, 'r', encoding='utf-8') as f:
                all_lines = f.readlines()
            if len(all_lines) > max_lines:
                print(f"{file_path} が {max_lines}行 を超えました。古い行を削除します。")
                lines_to_keep = all_lines[-max_lines:]
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.writelines(lines_to_keep)
        except Exception as e:
            print(f"ログの行数調整中にエラーが発生しました: {e}")

class SpeechProcessor:
    """自分の発言を翻訳するためのクラス"""
    def __init__(self, base_dir, lang, engine):
        self.base_dir = base_dir
        self.lang = lang
        self.engine = engine
        self.send_path = os.path.join(self.base_dir, "my_send.dat")
        self.recv_path = os.path.join(self.base_dir, "my_recv.dat")
        print(f"発言翻訳プロセッサ準備完了: -> {self.lang}")

    def process(self):
        if not os.path.exists(self.send_path) or os.path.getsize(self.send_path) == 0:
            return

        processing_path = self.send_path + ".processing"
        try:
            os.rename(self.send_path, processing_path)
        except OSError:
            return

        line = ""
        try:
            with open(processing_path, 'r', encoding='utf-8') as f:
                line = f.read().strip()
        finally:
            if os.path.exists(processing_path):
                os.remove(processing_path)

        if not line: return

        parts = line.split(':::')
        if len(parts) != 3: 
            print(f"  [エラー] my_send.datの形式が不正です。")
            return
        
        msg_type, org_msg_return, org_msg = parts
        
        translated_msg = self.engine.translate(org_msg, dest_lang=self.lang)
        
        result_line = f"{msg_type}{translated_msg}({org_msg_return})" if translated_msg else f"{msg_type}{org_msg_return}"
        
        print(f"  [送信] Luaへの返信データ: '{result_line}'")

        try:
            with open(self.recv_path, 'w', encoding='utf-8') as f:
                f.write(result_line)
        except Exception as e:
            print(f"my_recv.dat の書き込みエラー: {e}")

class TranslationManager:
    """アプリケーション全体を管理するクラス"""
    def __init__(self, base_dir):
        self.base_dir = base_dir
        self.engine = TranslationEngine()
        self.file_processor = None
        self.speech_processor = None
        self.restart_file_path = os.path.join(self.base_dir, "restart.dat")
        self._stop_lock = threading.Lock()
        self._is_stopping = False

    def _load_settings(self):
        settings_path = os.path.join(self.base_dir, "settings.json")
        settings = {"lang": "ja", "recv_lang": "en"}
        try:
            if os.path.exists(settings_path):
                with open(settings_path, 'r', encoding='utf-8') as f:
                    settings.update(json.load(f))
        except Exception as e:
            print(f"settings.json の読み込みエラー。デフォルト設定を使用します: {e}")
        return settings

    def run(self):
        """メインの実行ループ"""
        settings = self._load_settings()
        
        self.file_processor = FileProcessor(self.base_dir, settings.get("lang", "ja"), self.engine)
        self.speech_processor = SpeechProcessor(self.base_dir, settings.get("recv_lang", "en"), self.engine)
        
        self.file_processor.load_translated_data()
        
        monitor = ProcessMonitor("Client_tos_x64.exe", self.restart_file_path, self.stop)
        monitor.start()
        
        print("ファイル監視を開始しました。")
        
        loop_counter = 0
        while not self._is_stopping:
            try:
                self.speech_processor.process()
                
                # 負荷軽減のため、5ループに1回だけファイル処理を行う
                if loop_counter % 5 == 0:
                    self.file_processor.process_names()
                    self.file_processor.process_messages()

            except Exception as e:
                show_error_and_exit("実行時エラー", f"翻訳処理中に予期せぬエラーが発生しました。\n\nエラー詳細: {e}")
                self.stop() # エラーが発生したら、安全に停止処理を試みる
                break

            loop_counter = (loop_counter + 1) % 1000 # ループカウンターのリセット
            time.sleep(0.1)

    def stop(self):
        """安全に終了処理を行うためのフラグを立てる"""
        with self._stop_lock:
            if self._is_stopping: return
            self._is_stopping = True
        print("終了処理を開始します...")

if __name__ == "__main__":
    manager = None
    try:
        manager = TranslationManager(base_dir=BASE_DIR)
        manager.run()
    except KeyboardInterrupt:
        print("\n手動で終了します...")
    except Exception as e:
        # 起動時の致命的なエラー
        show_error_and_exit("起動エラー", f"プログラムの初期化中に予期せぬエラーが発生しました。\n\nエラー詳細: {e}")
    finally:
        if manager:
            manager.stop()
        
        # どのような経緯で終了しても、最後に自分自身を終了させる
        terminate_self()'''