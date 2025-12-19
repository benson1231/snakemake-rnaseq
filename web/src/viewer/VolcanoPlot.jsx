// src/VolcanoGroupSlider.jsx
import React, { useState, useEffect } from "react";
import { images } from "../assets/images.js"; // ✅ 匯入靜態圖片資料
import SingleImage from "../common/SingleImage.jsx";     // ✅ 單圖放大元件

const VolcanoPlot = () => {
  const [groupOptions, setGroupOptions] = useState([]);
  const [selectedGroup, setSelectedGroup] = useState("");
  const [imagesByGroup, setImagesByGroup] = useState({});

  useEffect(() => {
    // 🔁 過濾出火山圖相關圖片
    const volcanoImages = images.filter((img) =>
      img.name.startsWith("Volcano_plot_")
    );

    const grouped = {};
    volcanoImages.forEach((img) => {
      const match = img.name.match(/^Volcano_plot_(.*?)\.png$/);
      if (match) {
        const group = match[1];
        grouped[group] = img.path;
      }
    });

    setImagesByGroup(grouped);
    const keys = Object.keys(grouped);
    setGroupOptions(keys);
    setSelectedGroup(keys[0] || "");
  }, []);

  return (
    <div className="viewer-block block" id="volcano">
      <h2>群組火山圖瀏覽</h2>
      <select
        value={selectedGroup}
        onChange={(e) => setSelectedGroup(e.target.value)}
        className="viewer-select"
      >
        {groupOptions.map((g) => (
          <option key={g} value={g}>
            {g}
          </option>
        ))}
      </select>

      {selectedGroup && imagesByGroup[selectedGroup] && (
        <SingleImage
          src={imagesByGroup[selectedGroup]}
          alt={`Volcano plot for ${selectedGroup}`}
        />
      )}
    </div>
  );
};

export default VolcanoPlot;