// src/ORADOMultiViewer.jsx
import React, { useState, useEffect } from "react";
import SingleImage from "../common/SingleImage";
import { images } from "../assets/images.js"; // ✅ 改為靜態匯入


const ORADOMultiViewer = () => {
  const [barPlotGroups, setBarPlotGroups] = useState([]);
  const [dotPlotGroups, setDotPlotGroups] = useState([]);

  const [barSelected, setBarSelected] = useState("");
  const [dotSelected, setDotSelected] = useState("");

  const [barPlots, setBarPlots] = useState({});
  const [dotPlots, setDotPlots] = useState({});

  useEffect(() => {
    const bar = {}, dot = {};

    images.forEach((img) => {
      const match = img.path.match(/04_pathway\/([^/]+)\/ORA\//);
      if (!match) return;
      const group = match[1];

      if (img.name === "ORA_DO_barPlot.png") bar[group] = img.path;
      if (img.name === "ORA_DO_dotPlot.png") dot[group] = img.path;
    });

    const barKeys = Object.keys(bar);
    const dotKeys = Object.keys(dot);

    setBarPlotGroups(barKeys);
    setDotPlotGroups(dotKeys);
    setBarSelected(barKeys[0] || "");
    setDotSelected(dotKeys[0] || "");
    setBarPlots(bar);
    setDotPlots(dot);
  }, []);

  const renderViewer = (title, options, selected, onChange, images, alt) => (
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
      {selected && images[selected] && (
        <SingleImage src={images[selected]} alt={`${alt} for ${selected}`} />
      )}
    </div>
  );

  return (
    <div className="viewer-block block" id="ORA-DO">
      <h2>ORA DO 多圖視覺化（各圖獨立選單）</h2>

      {renderViewer("Bar Plot", barPlotGroups, barSelected, setBarSelected, barPlots, "Bar Plot")}
      {renderViewer("Dot Plot", dotPlotGroups, dotSelected, setDotSelected, dotPlots, "Dot Plot")}
    </div>
  );
};

export default ORADOMultiViewer;