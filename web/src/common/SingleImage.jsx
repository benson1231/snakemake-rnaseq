import React, { useState, useEffect } from 'react';

const SingleImage = ({ src, alt = '圖示' }) => {
  const [isZoomed, setIsZoomed] = useState(false);
  const [isBlank, setIsBlank] = useState(false);

  const toggleZoom = () => setIsZoomed(!isZoomed);

  useEffect(() => {
    const img = new Image();
    img.crossOrigin = "anonymous";
    img.src = src;

    img.onload = () => {
      const canvas = document.createElement('canvas');
      canvas.width = img.width;
      canvas.height = img.height;

      const ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0);

      const imageData = ctx.getImageData(0, 0, img.width, img.height);
      const pixels = imageData.data;

      let nonWhiteCount = 0;
      for (let i = 0; i < pixels.length; i += 4) {
        const r = pixels[i];
        const g = pixels[i + 1];
        const b = pixels[i + 2];

        if (!(r >= 245 && g >= 245 && b >= 245)) {
          nonWhiteCount++;
          if (nonWhiteCount > 10) break;
        }
      }

      setIsBlank(nonWhiteCount <= 10);
    };
  }, [src]);

  return (
    <div className="image-slider-block">
      <div className="image-slider-container">
        {isBlank ? (
          <div className="no-result-text">此圖無顯著結果</div>
        ) : (
          <img
            src={src}
            alt={alt}
            className="slider-image"
            onClick={toggleZoom}
          />
        )}
      </div>

      {/* ✅ 圖片路徑顯示 */}
      <div className="image-path">
        <code>{src}</code>
      </div>

      {isZoomed && !isBlank && (
        <div className="zoom-overlay" onClick={toggleZoom}>
          <img
            src={src}
            alt={`Zoomed ${alt}`}
            className="zoomed-image"
          />
        </div>
      )}
    </div>
  );
};

export default SingleImage;