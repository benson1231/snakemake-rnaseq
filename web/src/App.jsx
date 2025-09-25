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
import ToolVersion from './info/ToolVersion';
import References from './info/References';
import GSEAIntro from './info/GSEAIntro';
import GSEAViewer from './viewer/GSEAViewer';
import GSEAGOMultiViewer from './viewer/GSEAGO_MultiViewer';


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
        <GSEAViewer />
        <GSEAGOMultiViewer />

        <ToolVersion />
        <References />
      </div>

      <BackToTop />
      <Footer />
    </>
  );
};

export default App;