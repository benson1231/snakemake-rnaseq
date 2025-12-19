// SampleCorrelation.jsx
import SingleImage from '../common/SingleImage';

const SampleCorrelation = () => {
  return (
    <div className="block" id="sample-correlation">
      <h2>樣本相關性分析</h2>
      <p>
        為了評估樣本之間的相似性與分群情況，我們採用以下方法進行可視化分析：
      </p>

      <h3 style={{ fontSize: '18px', marginTop: '30px' }}>📌 歐式距離熱圖（Euclidean Distance Heatmap）</h3>
      <p>
        歐式距離衡量樣本間的直線距離，常用於樣本相似度評估與階層式聚類分析。
      </p>
      <SingleImage src="./05_results/02_figures/Euclidean Distance.png" alt="Euclidean Distance Heatmap" />

      <h3 style={{ fontSize: '18px', marginTop: '30px' }}>📌 主成分分析（Principal Component Analysis, PCA）</h3>
      <p>
        PCA 用來發掘資料的主要變異來源，將高維度的基因表現資料轉換為易於視覺化的二維表示。
      </p>
      <SingleImage src="./05_results/02_figures/PCA plot.png" alt="PCA Plot" />

      <h3 style={{ fontSize: '18px', marginTop: '30px' }}>📌 多維尺度分析（Multidimensional Scaling, MDS）</h3>
      <p>
        MDS 根據樣本間距離矩陣，將高維空間中的樣本嵌入至二維平面，利於觀察樣本間之相對關係。
      </p>
      <SingleImage src="./05_results/02_figures/MDS plot.png" alt="MDS Plot" />

      <h3 style={{ fontSize: '18px', marginTop: '30px' }}>📌 高變異基因熱圖（Top 100 High-Variance Genes Heatmap）</h3>
      <p>
        為了呈現在不同樣本間變異性最顯著的基因，本圖選取表現量變異最大的前 100 個基因，進行 Z-score 標準化後繪製熱圖。
      </p>
      <SingleImage src="./05_results/02_figures/Top100 high-variance genes heatmap.png" alt="Top 100 High-Variance Genes Heatmap" />
    </div>
  );
};

export default SampleCorrelation;