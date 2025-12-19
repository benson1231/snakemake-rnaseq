import "./Sidebar.css";

// 引入 react-icons 中的常用圖示
import { FaAddressBook, FaTools, FaBookOpen ,FaDatabase } from "react-icons/fa";
import { FaChartLine,FaImage } from "react-icons/fa6";
import { BsListTask } from "react-icons/bs";
import { RiFlowChart } from "react-icons/ri";
import { BiTable } from "react-icons/bi";
import { IoMdDocument } from "react-icons/io";
import { IoShieldCheckmark } from "react-icons/io5";

// 側邊欄元件
const Sidebar = () => {
  return (
    <div className="sidebar">
      {/* 導覽清單 */}
      <ul className="menu">
        <li><a href="#sample-info"><BsListTask /> 樣本資訊</a></li>
        <li><a href="#analysis-workflow"><RiFlowChart /> 分析流程介紹</a></li>
        <li><a href="#QC"><IoShieldCheckmark /> 定序資料品質管理</a></li>
        <li><a href="#sample-correlation"><FaChartLine /> 樣本相關性分析 </a></li>
        <li><a href="#MA"><FaImage /> MA plot </a></li>
        <li><a href="#volcano"><FaImage /> Volcano plot </a></li>
        <li><a href="#gsea-intro"><IoMdDocument /> GSEA介紹 </a></li>
        <li><a href="#gsea-table"><BiTable /> GSEA table </a></li>
        <li><a href="#GSEA_GO"><FaDatabase /> GSEA in GO </a></li>
        <li><a href="#gsea-kegg"><FaDatabase /> GSEA in KEGG </a></li>
        <li><a href="#TopKEGGPathways"><FaDatabase /> Top 3 KEGG </a></li>
        <li><a href="#ora-intro"><IoMdDocument /> ORA介紹 </a></li>
        <li><a href="#ora-table"><BiTable /> ORA table </a></li>
        <li><a href="#ORA-GO"><FaDatabase /> ORA in GO</a></li>
        <li><a href="#ORA-KEGG"><FaDatabase /> ORA in KEGG </a></li>
        <li><a href="#ORA-DO"><FaDatabase /> ORA in DO </a></li>
        <li><a href="#ora-reactome"><FaDatabase /> ORA in Reactome </a></li>
        <li><a href="#tools"><FaTools /> 生物資訊分析工具</a></li>
        <li><a href="#ref"><FaBookOpen /> 參考文獻</a></li>
      </ul>
    </div>
  );
};

export default Sidebar;