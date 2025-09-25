const ToolVersion = () => {
  return (
    <div className="block" id="tools">
      <h2>分析工具與版本</h2>
      <p>為確保分析流程的準確性與可重複性，本研究使用以下生物資訊工具與 R 套件進行資料處理與功能分析。</p>
      <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: '20px' }}>
        <thead>
          <tr style={{ backgroundColor: '#ecf0f1' }}>
            <th style={{ border: '1px solid #ddd', padding: '12px', textAlign: 'left' }}>分析工具 / 套件</th>
            <th style={{ border: '1px solid #ddd', padding: '12px', textAlign: 'left' }}>版本</th>
          </tr>
        </thead>
        <tbody>
          {[
            { name: 'fastp', version: '0.24.0' },
            { name: 'FastQC', version: '0.12.0' },
            { name: 'MultiQC', version: '1.25.2' },
            { name: 'HISAT2', version: '2.2.1' },
            { name: 'featureCounts', version: '2.0.8' },
            { name: 'R', version: '4.4.2' },
            { name: 'DESeq2', version: '1.45.0' },
            { name: 'edgeR', version: '4.4.1' },
            { name: 'clusterProfiler', version: '4.14.4' },
            { name: 'DOSE', version: '4.0.0' },
            { name: 'EnhancedVolcano', version: '1.24.0' },
            { name: 'ReactomePA', version: '1.50.0' },
          ].map((tool, index) => (
            <tr key={index}>
              <td style={{ border: '1px solid #ddd', padding: '10px' }}>{tool.name}</td>
              <td style={{ border: '1px solid #ddd', padding: '10px' }}>{tool.version}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default ToolVersion;