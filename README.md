[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=ekah1500/DGA_Diagnostic&file=https://github.com/ekah1500/DGA_Diagnostic/blob/main/DGA_Calculator.m)
# ⚡ MATLAB DGA Diagnostic Tool

A professional-grade MATLAB application designed to automate **Dissolved Gas Analysis (DGA)** for power transformer health assessment. This tool eliminates manual plotting on Duval Triangles and provides instant fault classification based on oil-dissolved gas concentrations.

---

## 🚀 Features

* **📉 Automated Fault Plotting:** Converts ppm values ($H_2$, $CH_4$, $C_2H_2$, $C_2H_4$, $C_2H_6$) into precise coordinates for **Duval Triangles 1**.
* **📜 Standardized Methods:** Implements industry-standard diagnostic logic:
    * **Rogers Ratio Method**
    * **Key Gas Analysis**
* **🖥️ Interactive UI:** A clean interface built with MATLAB App Designer featuring real-time data entry and visual feedback.
* **⚠️ Fault Identification:** Detects incipient faults including Partial Discharge (PD), Thermal Faults (T1, T2, T3), and High/Low Energy Arcing (D1, D2).

## 📚 Standards Compliance
This tool is built upon the mathematical frameworks established by:
* **🇺🇸 IEEE Std C57.104-2019:** Guidelines for the interpretation of gases generated in mineral oil-immersed transformers.
* **🇪🇺 IEC 60599:** Mineral oil-filled electrical equipment in service – Guidance on the interpretation of dissolved and free gases analysis.
* **📐 Duval's Methods:** Geometric coordinate mapping for Triangle 1
  
---

## ⚙️ How It Works

1. **📥 Input:** Enter gas concentrations in parts per million (ppm) from the laboratory oil sample report.
2. **🧮 Calculation:** The app normalizes the gas data to calculate relative percentages.
3. **🖼️ Visualization:** The tool maps these percentages onto the diagnostic grid using $x,y$ coordinate transformation.
4. **✅ Result:** The app identifies the specific fault zone and displays a clear text-based diagnosis.

---

## 🛠️ Installation & Usage

### 📋 Prerequisites
* MATLAB (R2021a or newer recommended)

### Running the App
1. Download or clone this repository.
2. Open MATLAB and navigate to the project folder.
3. Open the `DGA_Calculator.mlapp` file in **App Designer** or simply type the filename in the **Command Window** to run.

---

## Disclaimer

*This tool is intended for engineering assistance and educational purposes. All diagnostic results should be cross-referenced with certified laboratory reports and official IEEE C57.104 or IEC 60599 standards before taking any action on high-voltage equipment.*

---

**Developed by:** ekah
