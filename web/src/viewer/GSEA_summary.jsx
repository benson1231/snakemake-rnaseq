import React, { useState, useEffect } from "react";
import SingleImage from "../common/SingleImage.jsx";
import { images } from "../assets/images.js"; // ✅ 靜態匯入

// ✅ 只要這兩個 GSEA 類型
const gseaTypes = ["GSEA_KEGG.png", "GSEA_GO_ALL.png"];

const GSEA_summary = () => {
  const [imagesByType, setImagesByType] = useState({}); // { GSEA_KEGG.png: { group: path } }
  const [selectedGroups, setSelectedGroups] = useState({}); // { GSEA_KEGG.png: group }

  useEffect(() => {
    const groupedByType = {};

    images.forEach((img) => {
      if (!gseaTypes.includes(img.name)) return;

      // 🔎 路徑匹配規則：和 ORA 相同，套用到 GSEA
      const match = img.path.match(/04_pathway\/([^/]+)\/enrichment_results\/(GSEA_.+\.png)$/);
      if (match) {
        const group = match[1];
        const fileName = match[2];

        if (!groupedByType[fileName]) groupedByType[fileName] = {};
        groupedByType[fileName][group] = img.path;
      }
    });

    // 預設選第一個 group
    const defaultSelections = {};
    for (const fileName of gseaTypes) {
      const groups = groupedByType[fileName] || {};
      const groupKeys = Object.keys(groups);
      if (groupKeys.length > 0) {
        defaultSelections[fileName] = groupKeys[0];
      }
    }

    setImagesByType(groupedByType);
    setSelectedGroups(defaultSelections);
  }, []);

  const handleSelectChange = (fileName, newGroup) => {
    setSelectedGroups((prev) => ({
      ...prev,
      [fileName]: newGroup,
    }));
  };

  return (
    <div className="viewer-block block" id="gsea-table">
      <h2>GSEA 富集結果瀏覽</h2>

      {gseaTypes.map((fileName) => {
        const groupMap = imagesByType[fileName] || {};
        const groupKeys = Object.keys(groupMap);
        const selectedGroup = selectedGroups[fileName];
        const displayName = fileName
          .replace("GSEA_", "")
          .replace(".png", "")
          .replaceAll("_", " ");

        return (
          <div key={fileName} className="image-section">
            <h3>{displayName}</h3>
            <select
              className="viewer-select"
              value={selectedGroup || ""}
              onChange={(e) => handleSelectChange(fileName, e.target.value)}
            >
              {groupKeys.map((group) => (
                <option key={group} value={group}>
                  {group}
                </option>
              ))}
            </select>

            {selectedGroup && groupMap[selectedGroup] && (
              <SingleImage
                src={groupMap[selectedGroup]}
                alt={`${fileName} - ${selectedGroup}`}
              />
            )}
          </div>
        );
      })}
    </div>
  );
};

export default GSEA_summary;
