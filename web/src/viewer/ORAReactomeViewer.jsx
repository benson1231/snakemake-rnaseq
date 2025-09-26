// src/ORAReactomeViewer.jsx
import React, { useState, useEffect } from "react";
import SingleImage from "../common/SingleImage";
import { images } from "../assets/images.js"; // ✅ 改為靜態匯入


const ORAReactomeViewer = () => {
  const [barGroups, setBarGroups] = useState([]);
  const [dotGroups, setDotGroups] = useState([]);
  const [barSelected, setBarSelected] = useState("");
  const [dotSelected, setDotSelected] = useState("");
  const [barImages, setBarImages] = useState({});
  const [dotImages, setDotImages] = useState({});

  useEffect(() => {
    const bar = {};
    const dot = {};

    images.forEach((img) => {
      const match = img.path.match(/04_pathway\/([^/]+)\/ORA\//);
      if (!match) return;
      const group = match[1];

      if (img.name === "ORA_Reactome_barPlot.png") {
        bar[group] = img.path;
      }

      if (img.name === "ORA_Reactome_dotPlot.png") {
        dot[group] = img.path;
      }
    });

    const barKeys = Object.keys(bar);
    const dotKeys = Object.keys(dot);

    setBarGroups(barKeys);
    setDotGroups(dotKeys);
    setBarSelected(barKeys[0] || "");
    setDotSelected(dotKeys[0] || "");
    setBarImages(bar);
    setDotImages(dot);
  }, []);

  const renderViewer = (title, options, selected, onChange, images, alt) => (
    <div className="viewer-subblock">
      <h3>{title}</h3>
      <select value={selected} onChange={(e) => onChange(e.target.value)} className="viewer-select">
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
    <div className="viewer-block block" id="ora-reactome">
      <h2>ORA Reactome 結果圖</h2>
      {renderViewer("Bar Plot", barGroups, barSelected, setBarSelected, barImages, "ORA_Reactome_barPlot")}
      {renderViewer("Dot Plot", dotGroups, dotSelected, setDotSelected, dotImages, "ORA_Reactome_dotPlot")}
    </div>
  );
};

export default ORAReactomeViewer;