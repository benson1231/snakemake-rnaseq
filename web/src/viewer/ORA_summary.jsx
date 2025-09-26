import React, { useState, useEffect } from "react";
import SingleImage from "../common/SingleImage.jsx";
import { images } from "../assets/images.js"; // ✅ 改為靜態匯入


const oraTypes = [
  "ORA_DO.png",
  "ORA_GO_BP.png",
  "ORA_GO_CC.png",
  "ORA_GO_MF.png",
  "ORA_KEGG.png",
  "ORA_Reactome.png",
];

const ORA_summary = () => {
  const [imagesByType, setImagesByType] = useState({}); // { ORA_GO_BP.png: { group: path } }
  const [selectedGroups, setSelectedGroups] = useState({}); // { ORA_GO_BP.png: group }

  useEffect(() => {
    const groupedByType = {};

    images.forEach((img) => {
      if (!oraTypes.includes(img.name)) return;

      const match = img.path.match(/04_pathway\/([^/]+)\/enrichment_results\/(ORA_.+\.png)$/);
      if (match) {
        const group = match[1];
        const fileName = match[2];

        if (!groupedByType[fileName]) groupedByType[fileName] = {};
        groupedByType[fileName][group] = img.path;
      }
    });

    const defaultSelections = {};
    for (const fileName of oraTypes) {
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
    <div className="viewer-block block" id="ora-table">
      <h2>ORA 富集結果瀏覽</h2>

      {oraTypes.map((fileName) => {
        const groupMap = imagesByType[fileName] || {};
        const groupKeys = Object.keys(groupMap);
        const selectedGroup = selectedGroups[fileName];
        const displayName = fileName
          .replace("ORA_", "")
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

export default ORA_summary;