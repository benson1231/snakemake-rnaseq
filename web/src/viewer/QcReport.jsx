import './QcReport.css';

const QcReport = () => {
    return (
        <div className="block" id="QC">
            <h2>QC 報告（MultiQC）</h2>
            <p className="qc-description">
                此區塊展示使用 <strong>MultiQC</strong> 匯總的品質控制分析結果，涵蓋 FastQC、STAR、featureCounts 等工具。
            </p>
            <div className="qc-iframe-wrapper">
                <iframe
                    src="./04_multiqc_reports/multiqc_report.html"
                    title="MultiQC Report"
                    width="100%"
                    height="600px"
                    className="qc-iframe"
                ></iframe>
            </div>
        </div>
    );
};

export default QcReport;