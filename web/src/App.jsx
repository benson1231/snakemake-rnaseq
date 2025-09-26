import './styles/main.css';

// Layout Components
import Navbar from './UI/Navbar/Navbar';
import Footer from './UI/Footer/Footer';
import BackToTop from './UI/BackToTop/BackToTop';
import Sidebar from './UI/Sidebar/Sidebar';
import SampleInfo from './info/SampleInfo';
import Workflow from './info/Workflow';
import QcReport from './viewer/QcReport';
import SampleCorrelation from './viewer/SampleCorrelation';
import TopGenesGroupSlider from './viewer/TopGenesGroupSlider';
import MAPlot from './viewer/MAPlot';
import VolcanoPlot from './viewer/VolcanoPlot';
import Tools from './info/Tools';
import References from './info/References';
import GSEAIntro from './info/GSEAIntro';
import GSEA_summary from './viewer/GSEA_summary';
import GSEAGOMultiViewer from './viewer/GSEAGO_MultiViewer';
import GSEAKEGGMultiViewer from './viewer/GSEAKEGGMultiViewer';
import TopKEGGPathwaysViewer from './viewer/TopKEGGPathwaysViewer';
import ORAIntro from './info/ORAIntro';
import ORA_summary from './viewer/ORA_summary';
import ORAGOViewer from './viewer/ORAGOViewer';
import ORAKEGGViewer from './viewer/ORAKEGGViewer';
import ORADOMultiViewer from './viewer/ORADOVIewer';
import ORAReactomeViewer from './viewer/ORAReactomeViewer';


const App = () => {
  return (
    <>
      <Navbar />
      <Sidebar/>

      <div className="main-content">
        <SampleInfo />
        <Workflow />
        <QcReport />
        <SampleCorrelation />

        <TopGenesGroupSlider />
        <MAPlot/>
        <VolcanoPlot />

        <GSEAIntro />
        <GSEA_summary />
        <GSEAGOMultiViewer />
        <GSEAKEGGMultiViewer />
        <TopKEGGPathwaysViewer />

        <ORAIntro />
        <ORA_summary />
        <ORAGOViewer />
        <ORAKEGGViewer />
        <ORADOMultiViewer />
        <ORAReactomeViewer />

        <Tools />
        <References />
      </div>

      <BackToTop />
      <Footer />
    </>
  );
};

export default App;