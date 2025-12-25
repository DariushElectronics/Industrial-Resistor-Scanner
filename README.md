# 🛡️ Industrial Resistor Scanner (ApexEngine)

An advanced Computer Vision system built in MATLAB for automated **6-band resistor** color code recognition. Powered by the custom **ApexEngine**, this system eliminates edge noise and adheres to **IEC 60062** standards.

## 🚀 Key Features
- **ApexEngine Logic:** Smartly differentiates between 4, 5, and 6-band resistors.
- **Edge Clipping:** Auto-removes ceramic caps and wire leads for noise-free analysis.
- **TCR Detection:** Full support for Temperature Coefficient bands (6th band).
- **Lab Color Space:** High-precision color matching calibrated for metallic gold/silver bands.

## 💻 How to Run
1. Clone the repository or download the ZIP.
2. Ensure `Resistor.png` is in the main folder.
3. Run `LAUNCH_SYSTEM.m` in MATLAB.

## 📊 Result on Test Data
- **Input:** Green-Blue-Black-Orange-Gold-Yellow
- **Output:**
    - Value: **560 kΩ**
    - Tolerance: **±5%**
    - TCR: **25 ppm/K**

---
*Verified with MATLAB R2024a*
