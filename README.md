# AutomatedLesionDetection

**About**

This pipeline aims to automatically detect brain lesion in stroke patient using only T1-weighted MRIs. The pipeline combines both unsupervised and supervised method to detect brain lesion(s). First, unsupervised methods perform unified segmentation normalization images from native space into standard space and to generate probability maps for different tissue types (gray matter, white matter and fluid). This allows us to construct an initial lesion probability map (LPM) by comparing the normalized MRI to healthy control subjects. Then, we perform non-rigid and reversible atlas-based registration to refine the probability maps of gray matter, white matter, CSF, and lesions. These probability maps are combined with normalized MRI to construct three types of features, with which we use supervised methods to train three support vector machine (SVM) classifiers for a combined classifier. Finally, the combined classifier is used to accomplish lesion detection.

**Version**

April 15 2015

**Usage**

This pipeline is compatible with SPM8. Place the ‘AutomatedLesionDetection’ folder inside SPM’s toolbox folder.

**Modules**

(1) Generate Averaged & Zscored Healthy Control MRI: this module allows you to generate an average and z-scored MRI using input MRIs. 

(2) Automated Lesion Detection Model Training: this module allows you to train SVM classifiers for lesion detection. 

(3) Automated Lesion Detection Model Testing: This module allows you to detect lesion(s) using the trained SVM classifiers.

**Copyright**
This is code is adapted for SPM8 by Dazhou Guo. 
http://creativecommons.org/licenses/by-nc/3.0/legalcode
