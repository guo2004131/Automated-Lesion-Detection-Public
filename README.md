# AutomatedLesionDetection

**About**

This pipeline aims to automatically detect brain lesion in stroke patient using only T1-weighted MRI(s). The pipeline combines both unsupervised and supervised method to detect brain lesion(s). First, unsupervised methods perform unified segmentation normalization images from native space into standard space and to generate probability maps for different tissue types (gray matter, white matter and fluid). This allows us to construct an initial lesion probability map (LPM) by comparing the normalized MRI to healthy control subjects. Then, we perform non-rigid and reversible atlas-based registration to refine the probability maps of gray matter, white matter, CSF, and lesions. These probability maps are combined with normalized MRI to construct three types of features, with which we use supervised methods to train three support vector machine (SVM) classifiers for a combined classifier. Finally, the combined classifier is used to accomplish lesion detection.

**Version**

April 15 2015

**Usage**

Installation
 - This pipeline is requires that you have Matlab and SPM8 installed.
 - Place the ‘AutomatedLesionDetection’ folder and all its contents inside SPM’s toolbox folder.

Example lesion segmentation (using pre-generated images)
 - Launch Matlab and launch SPM8 (by typing 'spm fmri' from the Matlab command line).
 - Press the 'Batch' button from SPM's main window to display the 'Batch Editor' window
 - From the Batch window, select the SPM/Tools/AutoLesionDetect/AutomatedLesionModelTesting menu item
 - Double-click on the 'patient MRI', and choose the T1 scan you wish to analyze (in our case 'testT1.nii')
 - Double-click on the 'SVM Model: Zero Order Statistical Feature Model', and choose 1st database (in our case 'TestModel0')
 - Double-click on the 'SVM Model: First Order Statistical Feature Model', and choose 1st database (in our case 'TestModel1')
 - Double-click on the 'SVM Model: Second Order Statistical Feature Model', and choose 1st database (in our case 'TestModel2')
 - Double-click on the 'Average and Zscored Healty MRI, and choose healthy control images (in our case 'Templates/Average_T1.nii') 
 - Since our patient's T1 image still shows the scalp (e.g. the scalp was not removed with FSL BET) make sure the 'With Skull & Scalp' is set to 1 
 - Choose the File/RunBatch command to generate your lesion map

**Modules**
- (1) Generate Averaged & Zscored Healthy Control MRI: this module allows you to generate an average and z-scored MRI using input MRIs. 
- (2) Automated Lesion Detection Model Training: this module allows you to train SVM classifiers for lesion detection. 
- (3) Automated Lesion Detection Model Testing: This module allows you to detect lesion(s) using the trained SVM classifiers.

**Copyright**
- This code is adapted for SPM8 by Dazhou Guo. 
- http://creativecommons.org/licenses/by-nc/3.0/legalcode
