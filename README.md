```markdown
# Digital Washing

> **[Paper Title Here]**  
> Presented at **[Conference Name, Year]**

This repository contains the MATLAB implementation of the Digital Washing method for improving sperm‐cell detection in time‐lapse imaging. It accompanies our paper listed above (please insert title, conference, and year).

---

## Requirements

- MATLAB R2018b or later
- No additional toolboxes beyond base MATLAB

## Installation & Setup

1. **Select a directory** on your machine to store this repository.  
   Example:  
```

C:/Users/YourName/Desktop/GitRepo/

````

2. **Open Git Bash** (or your terminal) and navigate to that directory:  
```bash
cd "C:/Users/YourName/Desktop/GitRepo/"
````

3. **Clone this repository** and enter it:

   ```bash
   git clone https://github.com/DFL-KamLab/DigitalWashing.git
   cd DigitalWashing/
   ```

4. **Install dependencies** (none beyond base MATLAB; skip if not needed).

## Usage

1. **Open MATLAB** and set the Current Folder to the cloned repository:

   ```
   .../DigitalWashing/
   ```

2. **Edit `DigitalWashing_Main.m`**:
   At the top, update the file paths:

   ```matlab
   % Path to input video
   video_address = 'C:/path/to/your/video.avi';
   % Path to ground-truth annotations
   gt_address    = 'C:/path/to/your/gt.mat';
   ```

3. **Run the main script**:

   * In MATLAB Command Window:

     ```matlab
     DigitalWashing_Main
     ```
   * Or from shell (if MATLAB is on your PATH):

     ```bash
     matlab -batch "DigitalWashing_Main"
     ```

The script will perform filtering, binarization, feature extraction, detection assessment, and compute F-beta scores as described in the paper.

## Repository Structure

```
DigitalWashing/
├── Average_Filter.m
├── Binarization_Method.m
├── Cent_Moment.m
├── Detection_Assessment.m
├── DigitalWashing_Main.m
├── Ellipse_and_Axes.m
├── F_Beta_Score.m
├── Feature_Vector.m
├── Features_Calculation.m
├── Features_and_Detections.m
├── Foreground_Background_Separation.m
├── Hungarian.m
├── Image_Around_Detected_Cells.m
├── LICENSE
├── Local_Detectors_Decisions.m
├── Localization_Sim.m
├── Log_Based_Binarization.m
├── Morph_Image.m
├── Morph_Image_Sauvola.m
├── Morph_Image_Urbano.m
├── MotionDetection_GaussianMixture.m
├── Otsu_Threshold.m
├── Rectangular_Box.m
├── Remove_Foreground.m
├── Sauvola_Threshold.m
└── Urbano_Seg.m
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

```
```
