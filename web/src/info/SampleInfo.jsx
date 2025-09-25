// SampleInfo.jsx
import SingleImage from '../common/SingleImage';

const SampleInfo = () => {
  return (
    <>
      <div className="block" id="sample-info">
        <h2>樣本資訊</h2>
        <p>以下為本次 RNA-seq 分析中使用的樣本基本資訊與分組對照：</p>

        <SingleImage
          src="./05_results/02_figures/Sample information.png"
          alt="Sample Information"
        />

        <p>本次比較組別與對應之 Treatment / Control 群組：</p>

        <SingleImage
          src="./05_results/02_figures/Sample comparisons.png"
          alt="Sample Comparisons"
        />
      </div>
    </>
  );
};

export default SampleInfo;