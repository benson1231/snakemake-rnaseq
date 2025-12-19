// src/GSEAKEGGMultiViewer.jsx
import React, { useState, useEffect } from "react";
import { images } from "../assets/images.js"; // ✅ 靜態匯入圖片資料
import SingleImage from "../common/SingleImage";


const GSEAKEGGMultiViewer = () => {
  const [dotPlotGroups, setDotPlotGroups] = useState([]);
  const [cnetPlotGroups, setCnetPlotGroups] = useState([]);
  const [gseaPlotGroups, setGseaPlotGroups] = useState([]);
  const [enrichPlotGroups, setEnrichPlotGroups] = useState([]);
  const [treePlotGroups, setTreePlotGroups] = useState([]);

  const [dotSelected, setDotSelected] = useState("");
  const [cnetSelected, setCnetSelected] = useState("");
  const [gseaSelected, setGseaSelected] = useState("");
  const [enrichSelected, setEnrichSelected] = useState("");
  const [treeSelected, setTreeSelected] = useState("");

  const [dotPlots, setDotPlots] = useState({});
  const [cnetPlots, setCnetPlots] = useState({});
  const [gseaPlots, setGseaPlots] = useState({});
  const [enrichPlots, setEnrichPlots] = useState({});
  const [treePlots, setTreePlots] = useState({});

  useEffect(() => {
    const dot = {}, cnet = {}, gsea = {}, enrich = {}, tree = {};

    images.forEach((img) => {
      const match = img.path.match(/04_pathway\/([^/]+)\/KEGG\//);
      if (!match) return;
      const group = match[1];

      if (img.name === "GSEA_KEGG_dotPlot.png") dot[group] = img.path;
      if (img.name === "GSEA_KEGG_cnetPlot.png") cnet[group] = img.path;
      if (img.name === "GSEA_KEGG_gseaPlot.png") gsea[group] = img.path;
      if (img.name === "GSEA_KEGG_enrichmentPlot.png") enrich[group] = img.path;
      if (img.name === "GSEA_KEGG_treePlot.png") tree[group] = img.path;
    });

    const getKeys = (obj) => Object.keys(obj);

    setDotPlotGroups(getKeys(dot));
    setCnetPlotGroups(getKeys(cnet));
    setGseaPlotGroups(getKeys(gsea));
    setEnrichPlotGroups(getKeys(enrich));
    setTreePlotGroups(getKeys(tree));

    setDotSelected(getKeys(dot)[0] || "");
    setCnetSelected(getKeys(cnet)[0] || "");
    setGseaSelected(getKeys(gsea)[0] || "");
    setEnrichSelected(getKeys(enrich)[0] || "");
    setTreeSelected(getKeys(tree)[0] || "");

    setDotPlots(dot);
    setCnetPlots(cnet);
    setGseaPlots(gsea);
    setEnrichPlots(enrich);
    setTreePlots(tree);
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
    <div className="viewer-block block" id="gsea-kegg">
      <h2>GSEA KEGG 多圖視覺化（各圖獨立選單）</h2>
      {renderViewer("Dot Plot", dotPlotGroups, dotSelected, setDotSelected, dotPlots, "Dot Plot")}
      {renderViewer("Cnet Plot", cnetPlotGroups, cnetSelected, setCnetSelected, cnetPlots, "Cnet Plot")}
      {renderViewer("GSEA Plot", gseaPlotGroups, gseaSelected, setGseaSelected, gseaPlots, "GSEA Plot")}
      {renderViewer("Enrichment Plot", enrichPlotGroups, enrichSelected, setEnrichSelected, enrichPlots, "Enrichment Plot")}
      {renderViewer("Tree Plot", treePlotGroups, treeSelected, setTreeSelected, treePlots, "Tree Plot")}
    </div>
  );
};

export default GSEAKEGGMultiViewer;