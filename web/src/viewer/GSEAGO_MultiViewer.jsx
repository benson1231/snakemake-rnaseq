// src/GSEAGOMultiViewer.jsx
import React, { useState, useEffect } from "react";
import { images } from "../assets/images.js"; // ✅ 改為靜態匯入
import SingleImage from "../common/SingleImage";

const GSEAGOMultiViewer = () => {
  const [dotPlotGroups, setDotPlotGroups] = useState([]);
  const [cnetPlotGroups, setCnetPlotGroups] = useState([]);
  const [gseaPlotGroups, setGseaPlotGroups] = useState([]);
  const [enrichPlotGroups, setEnrichPlotGroups] = useState([]);

  const [dotSelected, setDotSelected] = useState("");
  const [cnetSelected, setCnetSelected] = useState("");
  const [gseaSelected, setGseaSelected] = useState("");
  const [enrichSelected, setEnrichSelected] = useState("");

  const [dotPlots, setDotPlots] = useState({});
  const [cnetPlots, setCnetPlots] = useState({});
  const [gseaPlots, setGseaPlots] = useState({});
  const [enrichPlots, setEnrichPlots] = useState({});

  useEffect(() => {
    const dot = {}, cnet = {}, gsea = {}, enrich = {};

    images.forEach((img) => {
      const match = img.path.match(/04_pathway\/([^/]+)\/GSEA\//);
      if (!match) return;
      const group = match[1];

      if (img.name === "GSEA_GO_dotPlot.png") dot[group] = img.path;
      if (img.name === "GSEA_GO_cnetPlot.png") cnet[group] = img.path;
      if (img.name === "GSEA_GO_gseaPlot.png") gsea[group] = img.path;
      if (img.name === "GSEA_GO_enrichmentPlot.png") enrich[group] = img.path;
    });

    const getKeys = (obj) => Object.keys(obj);

    setDotPlotGroups(getKeys(dot));
    setCnetPlotGroups(getKeys(cnet));
    setGseaPlotGroups(getKeys(gsea));
    setEnrichPlotGroups(getKeys(enrich));

    setDotSelected(getKeys(dot)[0] || "");
    setCnetSelected(getKeys(cnet)[0] || "");
    setGseaSelected(getKeys(gsea)[0] || "");
    setEnrichSelected(getKeys(enrich)[0] || "");

    setDotPlots(dot);
    setCnetPlots(cnet);
    setGseaPlots(gsea);
    setEnrichPlots(enrich);
  }, []);

  const renderViewer = (title, options, selected, onChange, images, alt) => (
    <div className="viewer-subblock">
      <h3>{title}</h3>
      <select value={selected} onChange={(e) => onChange(e.target.value)} className="viewer-select">
        {options.map((g) => (
          <option key={g} value={g}>{g}</option>
        ))}
      </select>
      {selected && images[selected] && (
        <SingleImage src={images[selected]} alt={`${alt} for ${selected}`} />
      )}
    </div>
  );

  return (
    <div className="viewer-block block" id='GSEA_GO'>
      <h2>GSEA GO 多圖視覺化（各圖獨立選單）</h2>
      {renderViewer("Dot Plot", dotPlotGroups, dotSelected, setDotSelected, dotPlots, "Dot Plot")}
      {renderViewer("Cnet Plot", cnetPlotGroups, cnetSelected, setCnetSelected, cnetPlots, "Cnet Plot")}
      {renderViewer("GSEA Plot", gseaPlotGroups, gseaSelected, setGseaSelected, gseaPlots, "GSEA Plot")}
      {renderViewer("Enrichment Plot", enrichPlotGroups, enrichSelected, setEnrichSelected, enrichPlots, "Enrichment Plot")}
    </div>
  );
};

export default GSEAGOMultiViewer;