import React, { useState } from 'react';

const ImageSlider = ({ images }) => {
  const [index, setIndex] = useState(0);
  const [isZoomed, setIsZoomed] = useState(false);

  const prev = () => !isZoomed && setIndex((index - 1 + images.length) % images.length);
  const next = () => !isZoomed && setIndex((index + 1) % images.length);
  const toggleZoom = () => setIsZoomed(!isZoomed);

  if (!images || images.length === 0) return <p>無圖片資料</p>;

  return (
    <div className="image-slider-block">
      <div className="image-slider-container">
        <button className="arrow left" onClick={prev}>&lt;</button>
        <img
          src={images[index]}
          alt={`Image ${index}`}
          className="slider-image"
          onClick={toggleZoom}
        />
        <button className="arrow right" onClick={next}>&gt;</button>
      </div>

      {isZoomed && (
        <div className="zoom-overlay" onClick={toggleZoom}>
          <img
            src={images[index]}
            alt={`Zoomed ${index}`}
            className="zoomed-image"
          />
        </div>
      )}
    </div>
  );
};

export default ImageSlider;