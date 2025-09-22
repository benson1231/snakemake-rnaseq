import os
import json

# 專案根目錄下的 public 圖片來源
source_dir = "./workflow/results"
# 目標輸出資料夾（放在 src/assets/ 中供 React 使用）
output_dir = "./web/src/assets"

# 儲存圖片資訊的 list
image_list = []

for root, dirs, files in os.walk(source_dir):
    for file in files:
        if file.lower().endswith(".png"):
            abs_path = os.path.join(root, file)
            # 相對於 public 的路徑轉為 web 路徑
            web_path = abs_path.replace(source_dir, ".").replace("\\", "/")
            image_list.append({
                "name": file,
                "path": web_path
            })

# 確保 assets 資料夾存在
os.makedirs(output_dir, exist_ok=True)

# 輸出 JSON 檔案到 src/assets/images.json
json_output_path = os.path.join(output_dir, "images.json")
with open(json_output_path, "w", encoding="utf-8") as f:
    json.dump(image_list, f, indent=2, ensure_ascii=False)

# 輸出 JS 檔案到 src/assets/images.js
js_output_path = os.path.join(output_dir, "images.js")
with open(js_output_path, "w", encoding="utf-8") as f:
    f.write("export const images = ")
    json.dump(image_list, f, indent=2, ensure_ascii=False)
    f.write(";")

print(f"✅ 共找到 {len(image_list)} 張圖片，已輸出為：")
print(f"- images.json ➜ {json_output_path}")
print(f"- images.js   ➜ {js_output_path}")
