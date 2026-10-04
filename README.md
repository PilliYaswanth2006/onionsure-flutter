# SIH26031: Mobile Computer Vision & Metric Calibration for Offline Onion Grading

**Smart India Hackathon 2026 Prototype**  
**Problem Statement ID:** SIH26031  
**Problem Statement:** *"Quality assessment and grading of onions are often subjective and vary across procurement centers, resulting in disputes and inconsistencies."*

---

## 1. Project Aim & Vision

The objective of this project is to prototype an offline-first mobile field-assaying tool for agricultural procurement centers (e.g., APMC Mandis, NAFED/NCCF procurement centers). By replacing subjective ocular inspection with standardized mobile computer vision assistance and explainable metric grading rules, the system aims to:
- Minimize grading disputes between farmers and procurement assayers.
- Enforce reproducible multi-sample statistical aggregation rather than basing procurement decisions on a single photograph.
- Provide dynamic, transparent grading configurations (e.g., Grade A vs. Under-Relaxed Specifications - URS).
- Deliver tamper-evident digital quality certificates with offline QR verification and PDF export capabilities.

---

## 2. Product Positioning & Ethical Scope Limitations

To ensure scientific honesty and prevent misleading claims, this prototype is explicitly positioned with clear boundaries:

| Dimension | Prototype Scope | What it is NOT |
| :--- | :--- | :--- |
| **Grading Status** | Demonstration & field-assaying prototype | NOT a production-certified government grading authority |
| **Role of Assayer** | Assayer-assistive tool | NOT a replacement for the human inspector or CWC official laboratory assay |
| **AI Inference** | Precomputed demonstration results (`samples.json`) | NOT live on-device neural network inference |
| **Internal Condition** | Manual physical verification workflow (cut test record) | Does NOT claim internal rot detection from 2D RGB surface photos |
| **Sampling Protocol** | Multi-sample representative aggregation (counts-based) | Does NOT claim one photograph represents a 10-tonne truck lot |
| **Metric Calibration** | Demo estimate with metric reference visibility checks | Does NOT claim sub-millimeter physically certified calibration |

---

## 3. Sample Dataset & Data Provenance

The prototype uses the validated demonstration dataset stored at `assets/data/samples.json` accompanied by paired raw and annotated high-resolution images in `assets/images/`:

| Sample ID | Sample Name | Total Onions | Healthy | Surface Defect | Severe Defect | Sprouting | Undersized | Avg Diam |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **S01** | Healthy Sample | 26 | 17 | 7 | 2 | 0 | 0 | 53.0 mm |
| **S02** | Mixed Quality Sample | 26 | 13 | 5 | 0 | 2 | 6 | 47.7 mm |
| **S03** | Sprouting Sample | 26 | 14 | 0 | 0 | 6 | 6 | 48.0 mm |
| **S04** | Surface Defect Sample | 26 | 13 | 7 | 1 | 0 | 5 | 48.7 mm |
| **S05** | Undersized Sample | 26 | 19 | 0 | 0 | 0 | 7 | 45.8 mm |

### Dataset Integrity Verification
Every sample in `samples.json` adheres to strict mathematical constraints verified by automated unit tests:
1. All sample IDs (`S01`–`S05`) are unique.
2. All raw images and annotated images exist and are paired 1-to-1.
3. For every sample: $\sum \text{category\_counts} == \text{total\_onions}$.
4. For every sample: $\text{length}(\text{diameters\_mm}) == \text{total\_onions}$.
5. No negative values exist across counts or diameters.

---

## 4. Multi-Sample Count-Based Aggregation Logic

In agricultural field assaying, averaging percentages from individual sample batches introduces statistical skew. This prototype implements **strict count-based aggregation**:

$$\text{Total Onions} = \sum_{i=1}^{N} \text{total\_onions}_i$$

$$\text{Category \%} = \frac{\sum_{i=1}^{N} \text{category\_count}_i}{\text{Total Onions}} \times 100$$

### Default Demo Scenario (S01 + S03 + S04)
When selecting S01, S03, and S04, the system calculates:
- **Total Onions:** $26 + 26 + 26 = 78$
- **Healthy:** $17 + 14 + 13 = 44$ (56.4%)
- **Surface Defect:** $7 + 0 + 7 = 14$ (17.9%)
- **Severe Defect (Visible Rot):** $2 + 0 + 1 = 3$ (3.8%)
- **Sprouting:** $0 + 6 + 0 = 6$ (7.7%)
- **Undersized:** $0 + 6 + 5 = 11$ (14.1%)
- **Sum:** $44 + 14 + 3 + 6 + 11 = 78$ ($100.0\%$)

---

## 5. Dynamic Grading Configuration & Immutable Snapshots

Rather than hardcoding arbitrary grading rules, the prototype features a **Dynamic Grading Engine**:
- **Configurable Criteria:** Minimum & maximum diameter (mm), Grade A and URS tolerances for sprouting, visible rot, surface defects, and undersized bulbs.
- **Explainable Decisions:** Clear rule evaluation logs explaining why a lot qualifies as **Grade A**, falls back to **URS**, is flagged for **Review Required**, or **Rejected**.
- **Immutable Audit Snapshot:** When an inspection is finalized and saved, an immutable snapshot of the exact grading rules in effect at that moment is permanently embedded in the inspection record. Modifying rules later never alters historical reports.

---

## 6. End-to-End User Workflow

```
Home Screen (Offline / Demo Status)
  │
  ▼
Lot Registration (Farmer, Mandi, Inspector, Variety, Lot Quantity)
  │
  ▼
Guided Sampling (Select representative sample captures: S01, S03, S04)
  │
  ▼
Smart Capture (Field camera simulation: framing, blur, scale card check)
  │
  ▼
AI Analysis (Prepared CV bounding boxes, count breakdown, per-onion modal)
  │
  ▼
Multi-Sample Aggregation (Strict count summation & diameter combining)
  │
  ▼
Dynamic Grading & Review (Engine outcome + physical cut test record)
  │
  ▼
Digital Quality Report (Complete certificate + photo evidence gallery)
  │
  ├──► PDF Export (Printable official assessment document)
  ├──► QR Verification (Offline verification passport)
  └──► Local Storage & History (100% offline persistence)
```

---

## 7. How to Run the Prototype

### Prerequisites
- Flutter SDK (3.10+ / 3.24+ / 3.47+)
- Android Studio / Android Emulator or Windows Desktop runner

### Installation & Execution
```bash
# 1. Navigate to project root
cd c:/sih/sih_onion_grading

# 2. Fetch Flutter packages
flutter pub get

# 3. Run automated tests
flutter test

# 4. Launch the application
flutter run
```

---

## 8. Offline Resilience

The entire application operates without an active internet connection:
- Assets and demonstration data are bundled locally within the app package.
- Inspection records and dynamic rule configurations persist using local storage (`shared_preferences`).
- PDF documents are compiled entirely on-device using the `pdf` engine.
- QR codes are dynamically generated and verified offline without external API calls.
