const ORAIntro = () => (
  <div className="viewer-block block" id="ora-intro">
    <h2>ORA（Over-Representation Analysis）介紹</h2>
    <p>
      Over-Representation Analysis（ORA）是一種常見的功能富集分析方法，藉由比較顯著差異基因與特定功能基因集（如 GO、KEGG、Reactome 等）之間的重疊比例，
      評估該功能是否在資料中被顯著富集。這種方法能快速指出哪些生物過程或通路可能與實驗條件變化相關。
    </p>
    <p>
      本報告中使用 ORA 對差異表現基因進行 GO 分類（BP, CC, MF）、KEGG 通路、Reactome 通路與 DO 疾病關聯分析，
      並以 <strong>Bar Plot</strong> 與 <strong>Dot Plot</strong> 圖形方式呈現結果，提供直觀的視覺化理解與比較不同群組間的富集趨勢。
    </p>
  </div>
);

export default ORAIntro;