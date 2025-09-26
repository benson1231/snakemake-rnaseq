// src/ORAGOViewer.jsx
import React, { useState, useEffect } from "react";
import SingleImage from "../common/SingleImage";
import { images } from "../assets/images.js"; // ✅ 改為靜態匯入



const ORAGOViewer = () => {
  // 各種類圖的 state（群組、選擇項、路徑）
  const [bpBarGroups, setBpBarGroups] = useState([]);
  const [bpDotGroups, setBpDotGroups] = useState([]);
  const [ccBarGroups, setCcBarGroups] = useState([]);
  const [ccDotGroups, setCcDotGroups] = useState([]);
  const [mfBarGroups, setMfBarGroups] = useState([]);
  const [mfDotGroups, setMfDotGroups] = useState([]);

  const [bpBarSelected, setBpBarSelected] = useState("");
  const [bpDotSelected, setBpDotSelected] = useState("");
  const [ccBarSelected, setCcBarSelected] = useState("");
  const [ccDotSelected, setCcDotSelected] = useState("");
  const [mfBarSelected, setMfBarSelected] = useState("");
  const [mfDotSelected, setMfDotSelected] = useState("");

  const [bpBarPlots, setBpBarPlots] = useState({});
  const [bpDotPlots, setBpDotPlots] = useState({});
  const [ccBarPlots, setCcBarPlots] = useState({});
  const [ccDotPlots, setCcDotPlots] = useState({});
  const [mfBarPlots, setMfBarPlots] = useState({});
  const [mfDotPlots, setMfDotPlots] = useState({});

  useEffect(() => {
    const bpBar = {}, bpDot = {}, ccBar = {}, ccDot = {}, mfBar = {}, mfDot = {};

    images.forEach((img) => {
      const match = img.path.match(/04_pathway\/([^/]+)\/ORA\//);
      if (!match) return;
      const group = match[1];

      if (img.name === "ORA_BP_barPlot.png") bpBar[group] = img.path;
      if (img.name === "ORA_BP_dotPlot.png") bpDot[group] = img.path;
      if (img.name === "ORA_CC_barPlot.png") ccBar[group] = img.path;
      if (img.name === "ORA_CC_dotPlot.png") ccDot[group] = img.path;
      if (img.name === "ORA_MF_barPlot.png") mfBar[group] = img.path;
      if (img.name === "ORA_MF_dotPlot.png") mfDot[group] = img.path;
    });

    const getKeys = (obj) => Object.keys(obj);

    setBpBarGroups(getKeys(bpBar));
    setBpDotGroups(getKeys(bpDot));
    setCcBarGroups(getKeys(ccBar));
    setCcDotGroups(getKeys(ccDot));
    setMfBarGroups(getKeys(mfBar));
    setMfDotGroups(getKeys(mfDot));

    setBpBarSelected(getKeys(bpBar)[0] || "");
    setBpDotSelected(getKeys(bpDot)[0] || "");
    setCcBarSelected(getKeys(ccBar)[0] || "");
    setCcDotSelected(getKeys(ccDot)[0] || "");
    setMfBarSelected(getKeys(mfBar)[0] || "");
    setMfDotSelected(getKeys(mfDot)[0] || "");

    setBpBarPlots(bpBar);
    setBpDotPlots(bpDot);
    setCcBarPlots(ccBar);
    setCcDotPlots(ccDot);
    setMfBarPlots(mfBar);
    setMfDotPlots(mfDot);
  }, []);

  // 通用 viewer 渲染器
  const renderViewer = (title, groups, selected, setSelected, plots, alt) => (
    <div className="viewer-subblock">
      <h3>{title}</h3>
      <select value={selected} onChange={(e) => setSelected(e.target.value)} className="viewer-select">
        {groups.map((g) => (
          <option key={g} value={g}>{g}</option>
        ))}
      </select>
      {selected && plots[selected] && (
        <SingleImage src={plots[selected]} alt={`${alt} for ${selected}`} />
      )}
    </div>
  );

  return (
    <div className="viewer-block block" id="ORA-GO">
      <h2>ORA GO 分類圖視覺化（各圖獨立選單）</h2>

      {renderViewer("BP - Bar Plot", bpBarGroups, bpBarSelected, setBpBarSelected, bpBarPlots, "BP Bar Plot")}
      {renderViewer("BP - Dot Plot", bpDotGroups, bpDotSelected, setBpDotSelected, bpDotPlots, "BP Dot Plot")}
      {renderViewer("CC - Bar Plot", ccBarGroups, ccBarSelected, setCcBarSelected, ccBarPlots, "CC Bar Plot")}
      {renderViewer("CC - Dot Plot", ccDotGroups, ccDotSelected, setCcDotSelected, ccDotPlots, "CC Dot Plot")}
      {renderViewer("MF - Bar Plot", mfBarGroups, mfBarSelected, setMfBarSelected, mfBarPlots, "MF Bar Plot")}
      {renderViewer("MF - Dot Plot", mfDotGroups, mfDotSelected, setMfDotSelected, mfDotPlots, "MF Dot Plot")}
    </div>
  );
};

export default ORAGOViewer;