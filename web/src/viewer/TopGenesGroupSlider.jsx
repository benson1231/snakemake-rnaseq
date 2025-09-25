// src/TopGenesGroupSlider.jsx
import React, { useState, useEffect } from "react";
import { images } from "../assets/images.js"; 

const TopGenesGroupSlider = () => {
  const [groupOptions, setGroupOptions] = useState([]);
  const [selectedGroup, setSelectedGroup] = useState("");
  const [imagesByGroup, setImagesByGroup] = useState({});

  useEffect(() => {
    const upImages = images.filter((img) =>
      img.name.startsWith("top10_up_")
    );
    const downImages = images.filter((img) =>
      img.name.startsWith("top10_down_")
    );

    const grouped = {};

    upImages.forEach((img) => {
      const match = img.name.match(/^top10_up_(.*?)\.png$/);
      if (match) {
        const group = match[1];
        grouped[group] = grouped[group] || {};
        grouped[group]["up"] = img.path;
      }
    });

    downImages.forEach((img) => {
      const match = img.name.match(/^top10_down_(.*?)\.png$/);
      if (match) {
        const group = match[1];
        grouped[group] = grouped[group] || {};
        grouped[group]["down"] = img.path;
      }
    });

    setImagesByGroup(grouped);
    const keys = Object.keys(grouped);
    setGroupOptions(keys);
    setSelectedGroup(keys[0] || "");
  }, []);

  return (
    <div className="viewer-block block">
      <h2>群組 Top 10 基因瀏覽（上調與下調）</h2>
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
        <div className="topgenes-pair">
          {imagesByGroup[selectedGroup].up && (
            <img
              src={imagesByGroup[selectedGroup].up}
              alt={`Top 10 upregulated genes for ${selectedGroup}`}
              className="topgene-image"
            />
          )}
          {imagesByGroup[selectedGroup].down && (
            <img
              src={imagesByGroup[selectedGroup].down}
              alt={`Top 10 downregulated genes for ${selectedGroup}`}
              className="topgene-image"
            />
          )}
        </div>
      )}
    </div>
  );
};

export default TopGenesGroupSlider;