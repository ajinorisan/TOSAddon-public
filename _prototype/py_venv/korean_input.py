# korean_input.py
# 最後の仕上げ。コードそのものを美しくシェイプアップした、真の最終形態よ！

import tkinter as tk
from tkinter import font as tkFont
import os
import sys
import math
import json

# --- 定数定義 ---
# 設定値をここに集約。後からデザインを変えたくなっても、ここをいじるだけ！
BG_COLOR = "#2E2E2E"
FG_COLOR = "#EAEAEA"
ENTRY_BG = "#3C3C3C"
BTN_BG = "#555555"  # 枠線の色としても使う
FONT_NAME = "Yu Gothic UI"  # Meiryo UI #Yu Gothic UI # Malgun Gothic
INITIAL_WIDTH, INITIAL_HEIGHT = 250, 32  # あなたが調整した初期サイズ

# --- 実行環境の判定 ---
if hasattr(sys, "frozen"):
    base_dir = os.path.dirname(sys.executable)
else:
    base_dir = os.path.dirname(os.path.abspath(__file__))


# --- クラス定義 ---
class ToolTip:
    """マウスオーバーでヘルプを表示する、お姉さん特製のツールチップクラスよ"""

    def __init__(self, widget, text):
        self.widget = widget
        self.text = text
        self.tip_window = None
        self.schedule_id = None
        widget.bind("<Enter>", self.schedule_show_tip)
        widget.bind("<Leave>", self.schedule_hide_tip)

    def schedule_show_tip(self, event=None):
        self.schedule_id = self.widget.after(500, self.show_tip)

    def schedule_hide_tip(self, event=None):
        if self.schedule_id:
            self.widget.after_cancel(self.schedule_id)
        if self.tip_window:
            self.tip_window.destroy()
            self.tip_window = None

    def show_tip(self, event=None):
        if self.tip_window:
            return
        x = self.widget.winfo_rootx()
        y = self.widget.winfo_rooty() + self.widget.winfo_height() + 5
        self.tip_window = tk.Toplevel(self.widget)
        self.tip_window.wm_overrideredirect(True)
        self.tip_window.wm_geometry(f"+{x}+{y}")
        self.tip_window.attributes("-topmost", True)

        # 変更: 定義済みの定数を使って、見た目に一貫性を持たせる
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
# (ここから下の関数群は、もう完璧なので変更なしよ！)
user_input_result = None
_x, _y = 0, 0


def save_position(x, y):
    pos_file_path = os.path.join(base_dir, "position.json")
    try:
        with open(pos_file_path, "w") as f:
            json.dump({"x": x, "y": y}, f)
    except Exception as e:
        print(f"Failed to save position: {e}")


def load_position():
    pos_file_path = os.path.join(base_dir, "position.json")
    try:
        with open(pos_file_path, "r") as f:
            data = json.load(f)
            if "x" in data and "y" in data:
                return data["x"], data["y"]
    except (FileNotFoundError, json.JSONDecodeError):
        pass
    return None, None


def on_return_key(event=None):
    global user_input_result
    text = text_area.get("1.0", "end-1c").strip()
    user_input_result = text if text else None
    save_position(root.winfo_x(), root.winfo_y())
    root.destroy()
    return "break"


def on_cancel_key(event=None):
    global user_input_result
    user_input_result = None
    save_position(root.winfo_x(), root.winfo_y())
    root.destroy()


def start_move(event):
    global _x, _y
    _x = event.x
    _y = event.y


def do_move(event):
    global _x, _y
    deltax = event.x - _x
    deltay = event.y - _y
    x = root.winfo_x() + deltax
    y = root.winfo_y() + deltay
    root.geometry(f"+{x}+{y}")


def adjust_height(event=None):
    display_lines = max(1, text_area.count("1.0", "end", "displaylines")[0])
    new_height_in_lines = max(1, min(display_lines, 10))
    if text_area.cget("height") == new_height_in_lines:
        return
    text_area.config(height=new_height_in_lines)
    root.update_idletasks()
    required_height = root.winfo_reqheight()
    current_width = root.winfo_width()
    root.geometry(f"{current_width}x{required_height}")


def check_limit(event):
    if event.keysym in ("BackSpace", "Delete", "Left", "Right", "Up", "Down", "Return"):
        return
    current_lines = max(1, text_area.count("1.0", "end", "displaylines")[0])
    if current_lines >= 10:
        return "break"


# --- メイン処理 ---
root = tk.Tk()
root.overrideredirect(True)
root.attributes("-topmost", True)
root.configure(bg=ENTRY_BG, highlightbackground=BTN_BG, highlightthickness=1)
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
text_area.focus_set()

tooltip_text = (
    "Text Input Helper\n"
    "--------------------\n"
    "Enter: OK (if text exists)\n"
    "Enter (if empty): Cancel\n"
    "Escape: Cancel\n"
    "Drag to move"
)
ToolTip(text_area, tooltip_text)

x, y = load_position()
if x is None or y is None:
    x = (root.winfo_screenwidth() // 2) - (INITIAL_WIDTH // 2)
    y = (root.winfo_screenheight() // 2) - (INITIAL_HEIGHT // 2)
root.geometry(f"{INITIAL_WIDTH}x{INITIAL_HEIGHT}+{x}+{y}")

text_area.bind("<Return>", on_return_key)
root.bind("<Escape>", on_cancel_key)
text_area.bind("<KeyRelease>", adjust_height)
text_area.bind("<KeyPress>", check_limit)
text_area.bind("<ButtonPress-1>", start_move)
text_area.bind("<B1-Motion>", do_move)
root.mainloop()

# --- ファイル書き込み処理 ---
if user_input_result:
    output_path = os.path.join(base_dir, "kr_input.dat")
    try:
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(user_input_result)
    except Exception as e:
        print(f"File write error: {e}")
