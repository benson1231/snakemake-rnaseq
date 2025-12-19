#!/usr/bin/env python3
import os
import json
import argparse

def main():
    parser = argparse.ArgumentParser(
        description="收集圖片清單並輸出成 JSON 或 JS 檔案"
    )
    parser.add_argument(
        "--source", "-s",
        default="./web/public",
        help="來源圖片資料夾 (default: ./web/public)"
    )
    parser.add_argument(
        "--output", "-o",
        required=True,
        help="輸出檔案路徑 (例如 ./web/src/assets/images.json 或 images.js)"
    )
    parser.add_argument(
        "--ext", "-e",
        default="png",
        help="要收集的圖片副檔名 (default: png)"
    )

    args = parser.parse_args()

    source_dir = args.source
    output_path = args.output
    output_dir = os.path.dirname(output_path)
    ext = args.ext.lower()

    # 收集圖片
    image_list = []
    for root, dirs, files in os.walk(source_dir):
        for file in files:
            if file.lower().endswith(f".{ext}"):
                abs_path = os.path.join(root, file)
                # 相對於 results/ 資料夾，避免重複 results/ 前綴
                web_path = os.path.relpath(abs_path, "results").replace("\\", "/")
                image_list.append({
                    "name": file,
                    "path": f"./{web_path}"
                })

    # 確保輸出資料夾存在
    os.makedirs(output_dir, exist_ok=True)

    # 判斷輸出格式
    if output_path.endswith(".json"):
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(image_list, f, indent=2, ensure_ascii=False)
    elif output_path.endswith(".js"):
        with open(output_path, "w", encoding="utf-8") as f:
            f.write("export const images = ")
            json.dump(image_list, f, indent=2, ensure_ascii=False)
            f.write(";")
    else:
        raise ValueError("輸出檔案必須是 .json 或 .js")

    print(f"✅ 共找到 {len(image_list)} 張圖片，已輸出為 {output_path}")

if __name__ == "__main__":
    main()
