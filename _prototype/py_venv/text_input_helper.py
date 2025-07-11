# MIT License
# Copyright (c) 2025 norisan
# Version 0.0.1
# Filename: text_input_helper.py
# Description: A custom text input tool with multi-language support.

import tkinter as tk
import os
import sys
import json

# --- 定数定義 ---
# UIの外観と挙動を定義する定数
BG_COLOR = "#0D0D0D"  # 背景色
FG_COLOR = "#FFFFFF"  # 前景色 (文字色)
ENTRY_BG = "#0D0D0D"  # テキストエリアの背景色
BORDER_COLOR = "#A9A9A9"  # ウィンドウ枠線の色
FONT_NAME = "Yu Gothic UI"  # UI全体のフォント
INITIAL_WIDTH, INITIAL_HEIGHT = 250, 32  # ウィンドウの初期サイズ

# --- 実行環境の判定 ---
# .exe化された場合とスクリプト実行の場合で、基準パスを切り替える
if hasattr(sys, "frozen"):
    base_dir = os.path.dirname(sys.executable)
else:
    base_dir = os.path.dirname(os.path.abspath(__file__))


# --- クラス定義 ---
class ToolTip:
    """指定されたウィジェットにマウスオーバーでヘルプテキストを表示するクラス。"""

    def __init__(self, widget, text):
        self.widget = widget
        self.text = text
        self.tip_window = None
        self.schedule_id = None
        # マウスカーソルがウィジェット領域に出入りした際のイベントをバインド
        widget.bind("<Enter>", self.schedule_show_tip)
        widget.bind("<Leave>", self.schedule_hide_tip)

    def schedule_show_tip(self, event=None):
        """指定時間後(500ms)にツールチップを表示するタイマーを設定する。"""
        self.schedule_id = self.widget.after(500, self.show_tip)

    def schedule_hide_tip(self, event=None):
        """ツールチップの表示予約をキャンセルし、表示中の場合は破棄する。"""
        if self.schedule_id:
            self.widget.after_cancel(self.schedule_id)
        if self.tip_window:
            self.tip_window.destroy()
            self.tip_window = None

    def show_tip(self, event=None):
        """ツールチップウィンドウを生成し、親ウィジェットの直下に表示する。"""
        if self.tip_window:
            return
        # 表示座標を計算
        x = self.widget.winfo_rootx()
        y = self.widget.winfo_rooty() + self.widget.winfo_height() + 5

        # OSのウィンドウ管理外のトップレベルウィンドウとして生成
        self.tip_window = tk.Toplevel(self.widget)
        self.tip_window.wm_overrideredirect(True)
        self.tip_window.wm_geometry(f"+{x}+{y}")
        self.tip_window.attributes("-topmost", True)

        label = tk.Label(
            self.tip_window,
            text=self.text,
            justify="left",
            background=BG_COLOR,
            foreground=FG_COLOR,
            font=(FONT_NAME, 9),
            relief="solid",
            borderwidth=1,
        )
        label.pack(ipadx=4, ipady=4)


# --- 関数定義 ---
user_input_result = None  # ユーザー入力の最終結果を格納するグローバル変数
_x, _y = 0, 0  # ウィンドウのドラッグ移動用の座標を保持するグローバル変数


def save_position(x, y):
    """ウィンドウの座標をJSONファイルに保存する。"""
    pos_file_path = os.path.join(base_dir, "position.json")
    try:
        with open(pos_file_path, "w") as f:
            json.dump({"x": x, "y": y}, f)
    except Exception as e:
        print(f"Failed to save position: {e}")


def load_position():
    """JSONファイルからウィンドウの座標を読み込む。"""
    pos_file_path = os.path.join(base_dir, "position.json")
    try:
        with open(pos_file_path, "r") as f:
            data = json.load(f)
            if "x" in data and "y" in data:
                return data["x"], data["y"]
    except (FileNotFoundError, json.JSONDecodeError):
        # ファイルが存在しない、または形式が不正な場合はNoneを返す
        pass
    return None, None


def on_return_key(event=None):
    """Enterキー押下時のイベントハンドラ。入力内容に応じて処理を分岐し、ウィンドウを閉じる。"""
    global user_input_result
    text = text_area.get("1.0", "end-1c").strip()
    user_input_result = text if text else None
    save_position(root.winfo_x(), root.winfo_y())
    root.destroy()
    return "break"  # Textウィジェットのデフォルトの改行動作をキャンセル


def on_cancel_key(event=None):
    """Escapeキー押下時のイベントハンドラ。無条件で入力をキャンセルし、ウィンドウを閉じる。"""
    global user_input_result
    user_input_result = None
    save_position(root.winfo_x(), root.winfo_y())
    root.destroy()


def start_move(event):
    """ウィンドウのドラッグ移動開始時の座標を記録する。"""
    global _x, _y
    _x = event.x
    _y = event.y


def do_move(event):
    """マウスの移動量に合わせてウィンドウを移動させる。"""
    global _x, _y
    deltax = event.x - _x
    deltay = event.y - _y
    x = root.winfo_x() + deltax
    y = root.winfo_y() + deltay
    root.geometry(f"+{x}+{y}")


def adjust_height(event=None):
    """テキストエリアの表示行数に応じて、ウィジェットとウィンドウの高さを動的に調整する。"""
    # Textウィジェットの組み込み機能で表示行数を取得
    display_lines = max(1, text_area.count("1.0", "end", "displaylines")[0])
    new_height_in_lines = max(1, min(display_lines, 10))  # 1～10行の範囲に制限

    # 現在の高さと変わらない場合は、不要な再描画をスキップ
    if text_area.cget("height") == new_height_in_lines:
        return

    text_area.config(height=new_height_in_lines)
    root.update_idletasks()  # UIの変更を即時反映

    # 新しい高さに基づいてウィンドウ全体のサイズを更新
    required_height = root.winfo_reqheight()
    current_width = root.winfo_width()
    root.geometry(f"{current_width}x{required_height}")


def check_limit(event):
    """最大行数(10行)を超えるキー入力を無効化する。"""
    # 文字の削除やカーソル移動に関するキーは制限対象外
    if event.keysym in ("BackSpace", "Delete", "Left", "Right", "Up", "Down", "Return"):
        return

    current_lines = max(1, text_area.count("1.0", "end", "displaylines")[0])
    if current_lines >= 10:
        return "break"  # "break"を返すと、キー入力をキャンセルする


# -----------------------------------------------------------------------------
# --- メイン処理 ---
# -----------------------------------------------------------------------------

# 1. メインウィンドウの生成と基本設定
root = tk.Tk()
root.overrideredirect(True)  # OS標準のタイトルバーを非表示
root.attributes("-topmost", True)  # 常に最前面に表示
root.configure(bg=ENTRY_BG, highlightbackground=BORDER_COLOR, highlightthickness=1)

# 2. テキストエリアウィジェットの生成と配置
text_area = tk.Text(
    root,
    bg=ENTRY_BG,
    fg=FG_COLOR,
    font=(FONT_NAME, 10),
    relief="flat",
    insertbackground=FG_COLOR,
    width=30,
    height=1,
    wrap="word",
    padx=8,
    pady=4,
)
text_area.pack(fill="both", expand=True)
text_area.focus_set()  # 起動時にフォーカスを設定

# 3. ToolTipクラスのインスタンス化とウィジェットへの適用
tooltip_text = (
    "Text Input Helper\n"
    "--------------------\n"
    "Enter: OK (if text exists)\n"
    "Enter (if empty): Cancel\n"
    "Escape: Cancel\n"
    "Drag to move"
)
ToolTip(text_area, tooltip_text)

# 4. ウィンドウの初期位置を決定 (保存された位置があればそこから、なければ中央)
x, y = load_position()
if x is None or y is None:
    x = (root.winfo_screenwidth() // 2) - (INITIAL_WIDTH // 2)
    y = (root.winfo_screenheight() // 2) - (INITIAL_HEIGHT // 2)
root.geometry(f"{INITIAL_WIDTH}x{INITIAL_HEIGHT}+{x}+{y}")

# 5. 各種イベントと対応する関数をバインド
text_area.bind("<Return>", on_return_key)
root.bind("<Escape>", on_cancel_key)
text_area.bind("<KeyRelease>", adjust_height)
text_area.bind("<KeyPress>", check_limit)
text_area.bind("<ButtonPress-1>", start_move)
text_area.bind("<B1-Motion>", do_move)

# 6. イベントループを開始 (この行でウィンドウが表示され、ユーザー操作の待受が始まる)
root.mainloop()

# -----------------------------------------------------------------------------
# --- ファイル書き込み処理 ---
# -----------------------------------------------------------------------------

# mainloopが終了後(ウィンドウが閉じられた後)に実行される
if user_input_result:  # user_input_resultに有効な文字列が格納されている場合
    output_path = os.path.join(base_dir, "input.dat")
    try:
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(user_input_result)
    except Exception as e:
        print(f"File write error: {e}")
