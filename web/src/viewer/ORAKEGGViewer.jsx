// src/ORAKEGGViewer.jsx
import React, { useState, useEffect } from "react";
import SingleImage from "../common/SingleImage";
import { images } from "../assets/images.js"; // ✅ 靜態匯入圖片清單



const ORAKEGGViewer = () => {
  // State for groups and selections
  const [barGroups, setBarGroups] = useState([]);
  const [dotGroups, setDotGroups] = useState([]);

  const [barSelected, setBarSelected] = useState("");
  const [dotSelected, setDotSelected] = useState("");

  const [barPlots, setBarPlots] = useState({});
  const [dotPlots, setDotPlots] = useState({});

  useEffect(() => {
    const bar = {};
    const dot = {};

    images.forEach((img) => {
      const match = img.path.match(/04_pathway\/([^/]+)\/ORA\//);
      if (!match) return;
      const group = match[1];

      if (img.name === "ORA_KEGG_barPlot.png") bar[group] = img.path;
      if (img.name === "ORA_KEGG_dotPlot.png") dot[group] = img.path;
    });

    const barKeys = Object.keys(bar);
    const dotKeys = Object.keys(dot);

    setBarGroups(barKeys);
    setDotGroups(dotKeys);
    setBarSelected(barKeys[0] || "");
    setDotSelected(dotKeys[0] || "");
    setBarPlots(bar);
    setDotPlots(dot);
  }, []);

  const renderViewer = (title, options, selected, onChange, plots, alt) => (
    <div className="viewer-subblock">
      <h3>{title}</h3>
      <select
        value={selected}
        onChange={(e) => onChange(e.target.value)}
        className="viewer-select"
      >
        {options.map((g) => (
          <option key={g} value={g}>
            {g}
          </option>
        ))}
      </select>
      {selected && plots[selected] && (
        <SingleImage src={plots[selected]} alt={`${alt} for ${selected}`} />
      )}
    </div>
  );

  return (
    <div className="viewer-block block" id="ORA-KEGG">
      <h2>ORA KEGG 視覺化（Bar / Dot Plot 分開選單）</h2>
      {renderViewer("KEGG - Bar Plot", barGroups, barSelected, setBarSelected, barPlots, "KEGG Bar Plot")}
      {renderViewer("KEGG - Dot Plot", dotGroups, dotSelected, setDotSelected, dotPlots, "KEGG Dot Plot")}
    </div>
  );
};

export default ORAKEGGViewer;