import './Footer.css';

const Footer = () => {
  return (
    <footer className="footer">
      <div className="footer-content">
        <p>© {new Date().getFullYear()} RNA-seq 分析報告 | Chin-Yu Lee 製作</p>
      </div>
    </footer>
  );
};

export default Footer;