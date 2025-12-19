const GSEAIntro = () => (
  <div className="viewer-block block" id="gsea-intro">
    <h2>GSEA（Gene Set Enrichment Analysis）介紹</h2>
    <p>
      Gene Set Enrichment Analysis（GSEA）是一種基於整體基因表現趨勢進行功能詮釋的統計方法，廣泛應用於生物資訊與轉錄體研究。
      相較於僅聚焦於個別顯著差異基因，GSEA 評估預先定義的基因集（如 KEGG、GO、Reactome 等）在不同實驗條件下的累積表現差異，
      有助於揭示潛在的調控機制與生物學意義。
    </p>
    <p>
      在本報告中，GSEA 被用來分析各組別間的 KEGG 與 GO 富集情形，並透過多種圖形呈現，包括：
      <strong>Enrichment Plot</strong>、<strong>Dot Plot</strong>、<strong>Cnet Plot</strong>、<strong>Tree Plot</strong> 等，
      以利從不同角度理解通路活化趨勢與基因關聯網絡。
    </p>
  </div>
);

export default GSEAIntro;