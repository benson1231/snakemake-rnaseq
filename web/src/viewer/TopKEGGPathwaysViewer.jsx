// src/TopKEGGPathwaysViewer.jsx
import React, { useState, useEffect } from "react";
import { images } from "../assets/images.js"; // ✅ 匯入靜態圖片清單
import SingleImage from "../common/SingleImage";



const TopKEGGPathwaysViewer = () => {
  const [groupOptions, setGroupOptions] = useState([]);
  const [imagesByRank, setImagesByRank] = useState({
    No1: {},
    No2: {},
    No3: {},
  });
  const [selectedGroups, setSelectedGroups] = useState({
    No1: "",
    No2: "",
    No3: "",
  });

  useEffect(() => {
    const rankImages = {
      No1: {},
      No2: {},
      No3: {},
    };

    images.forEach((img) => {
      const match = img.path.match(/04_pathway\/([^/]+)\/KEGG\/pathway\/(hsa\d+)\.No([1-3])\.png$/);
      if (match) {
        const group = match[1];         // e.g. BaP_vs_NC
        const rank = `No${match[3]}`;   // No1, No2, No3
        rankImages[rank][group] = img.path;
      }
    });

    const allGroups = Object.keys({
      ...rankImages.No1,
      ...rankImages.No2,
      ...rankImages.No3,
    });

    setGroupOptions(allGroups);
    setImagesByRank(rankImages);
    setSelectedGroups({
      No1: allGroups[0] || "",
      No2: allGroups[0] || "",
      No3: allGroups[0] || "",
    });
  }, []);

  const renderViewer = (rankLabel, rankKey) => (
    <div className="viewer-subblock">
      <h3>{rankLabel}</h3>
      <select
        value={selectedGroups[rankKey]}
        onChange={(e) =>
          setSelectedGroups((prev) => ({
            ...prev,
            [rankKey]: e.target.value,
          }))
        }
        className="viewer-select"
      >
        {groupOptions.map((g) => (
          <option key={g} value={g}>
            {g}
          </option>
        ))}
      </select>

      {selectedGroups[rankKey] && imagesByRank[rankKey][selectedGroups[rankKey]] ? (
        <SingleImage
          src={imagesByRank[rankKey][selectedGroups[rankKey]]}
          alt={`${rankLabel} for ${selectedGroups[rankKey]}`}
        />
      ) : (
        <p>查無顯著結果</p>
      )}
    </div>
  );

  return (
    <div className="viewer-block block" id='TopKEGGPathways'>
      <h2>Top 3 KEGG Pathway 圖示</h2>
      {renderViewer("第一名", "No1")}
      {renderViewer("第二名", "No2")}
      {renderViewer("第三名", "No3")}
    </div>
  );
};

export default TopKEGGPathwaysViewer;