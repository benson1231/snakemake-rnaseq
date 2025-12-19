// src/MAPlotViewer.jsx
import React, { useState, useEffect } from "react";
import SingleImage from "../common/SingleImage"; // ✅ 單圖顯示元件
import { images } from "../assets/images.js"; // 🔁 改為靜態匯入

const MAPlot = () => {
  const [groupOptions, setGroupOptions] = useState([]);
  const [selectedGroup, setSelectedGroup] = useState("");
  const [imagesByGroup, setImagesByGroup] = useState({});

  useEffect(() => {
    // 直接處理靜態 images 陣列
    const maImages = images.filter((img) =>
      img.name.startsWith("MA_plot_")
    );

    const grouped = {};
    maImages.forEach((img) => {
      const match = img.name.match(/^MA_plot_(.*?)\.png$/);
      if (match) {
        const group = match[1];
        grouped[group] = img.path;
      }
    });

    const keys = Object.keys(grouped);
    setImagesByGroup(grouped);
    setGroupOptions(keys);
    setSelectedGroup(keys[0] || "");
  }, []);

  return (
    <div className="viewer-block block" id="MA">
      <h2>MA plot 瀏覽</h2>

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
          alt={`MA plot for ${selectedGroup}`}
        />
      )}
    </div>
  );
};

export default MAPlot;