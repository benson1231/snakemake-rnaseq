import React, { useEffect, useState } from "react";
import SingleImage from "../common/SingleImage.jsx";

// 🔁 靜態載入圖片清單
import { images } from "../assets/images.js";

const GSEAViewer = () => {
  // 每個圖類型的 group 清單與目前選擇
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

  // 初始化時依據靜態 images 建立群組與圖檔對應表
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

    // 更新 state
    const dotKeys = Object.keys(dot);
    const cnetKeys = Object.keys(cnet);
    const gseaKeys = Object.keys(gsea);
    const enrichKeys = Object.keys(enrich);

    setDotPlotGroups(dotKeys);
    setCnetPlotGroups(cnetKeys);
    setGseaPlotGroups(gseaKeys);
    setEnrichPlotGroups(enrichKeys);

    setDotSelected(dotKeys[0] || "");
    setCnetSelected(cnetKeys[0] || "");
    setGseaSelected(gseaKeys[0] || "");
    setEnrichSelected(enrichKeys[0] || "");

    setDotPlots(dot);
    setCnetPlots(cnet);
    setGseaPlots(gsea);
    setEnrichPlots(enrich);
  }, []);

  // 可重用的選單 + 圖片顯示子元件
  const renderViewer = (title, options, selected, onChange, images, alt) => (
    <div className="viewer-subblock">
      <h3>{title}</h3>
      <select
        className="viewer-select"
        value={selected}
        onChange={(e) => onChange(e.target.value)}
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
    <div className="viewer-block block" id="GSEA_GO">
      <h2>GSEA GO 多圖視覺化（各圖獨立選單）</h2>
      {renderViewer("Dot Plot", dotPlotGroups, dotSelected, setDotSelected, dotPlots, "Dot Plot")}
      {renderViewer("Cnet Plot", cnetPlotGroups, cnetSelected, setCnetSelected, cnetPlots, "Cnet Plot")}
      {renderViewer("GSEA Plot", gseaPlotGroups, gseaSelected, setGseaSelected, gseaPlots, "GSEA Plot")}
      {renderViewer("Enrichment Plot", enrichPlotGroups, enrichSelected, setEnrichSelected, enrichPlots, "Enrichment Plot")}
    </div>
  );
};

export default GSEAViewer;