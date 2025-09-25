// src/components/sections/AnalysisWorkflow.jsx

const Workflow = () => (
  <div className="viewer-block block" id="analysis-workflow">
    <h2>分析流程介紹</h2>
    <p>
      本報告涵蓋 RNA-seq 資料的完整處理與下游功能分析，從原始讀取檔（FASTQ）出發，經由品質控制與比對，取得可信賴的基因表現量，進一步進行統計與生物意義解釋。
    </p>

    <h3>🔧 流程步驟</h3>
    <ul>
      <li><strong>1. 資料品質檢查：</strong>使用 FastQC 檢視每個樣本的序列品質，篩選潛在污染或低品質樣本。</li>
      <li><strong>2. 轉錄體比對：</strong>採用 STAR 或 HISAT2 將 reads 比對至參考基因組（如 GRCh38）。</li>
      <li><strong>3. 基因定量：</strong>使用 featureCounts 或 HTSeq 計算各基因的讀取數，生成 count matrix。</li>
      <li><strong>4. 差異表現分析：</strong>以 edgeR 或 DESeq2 對樣本群組進行比較，產出差異表現基因（DEGs）。</li>
      <li><strong>5. 視覺化分析：</strong>包含火山圖（Volcano）、MA 圖、Top 表現基因熱圖與樣本間相關性圖。</li>
      <li><strong>6. 功能富集分析：</strong>對 DEGs 進行 GSEA 與 ORA 分析，探索潛在調控路徑與生物功能。</li>
    </ul>

    <h3>📁 結果輸出</h3>
    <p>
      所有圖像與表格皆已整合於本網頁報告中，並附上分析使用之軟體版本資訊，以利追蹤與重現。
    </p>
  </div>
);

export default Workflow;