import './Navbar.css';

const Navbar = () => {
  return (
    <div className="navbar">
      <div className="navbar-left">
        <span className="navbar-title">RNA-seq 分析報告</span>
      </div>
      <div className="navbar-actions">
        <a href="#">Home</a>
        <a href="https://github.com/benson1231" target="_blank" rel="noreferrer">Website</a>
      </div>
    </div>
  );
};

export default Navbar;