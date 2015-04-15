function ALD_ModelTesting(job)
gamma = 5/6;
% Readin from "job" structure variable.
patient_filenames = job.PaMap;
withskull = job.withskull;
Model1 = job.Model1;
Model2 = job.Model2;
Model3 = job.Model3;
% Store three different models into one "cell" SVM_model variable.
SVM_model(1) = Model1;
SVM_model(2) = Model2;
SVM_model(3) = Model3;
% Perform the enantiomorphic normalization
[outEnantiomorphicNorm,patient_filenames,strokeSides] = ...
    EnantiomorphicNormalization(patient_filenames,withskull);
% Perform the initial lesion estimation procedure.
outInitialLPM = InitialLesionEstimation(outEnantiomorphicNorm,strokeSides);
% Perform the modified new segmentation using initial lesion estimation.
[NormT1, NormGM, NormWM, NormCSF, NormV, NormLPM,InverseMAT,~] = ...
    Modified_NewSegment('test',patient_filenames, outInitialLPM,gamma,strokeSides,withskull);
% Generate testing data for SVM
[Test_ZeroOrder,Test_FirstOrder,Test_SecondOrder,Test_Location] = ...
    TestDat_SVM_Feature_SVM(NormT1, NormGM, NormWM, NormCSF, NormLPM);
% Choose among different OSs. 

SVM_model(1) = Model1;
SVM_model(2) = Model2;
SVM_model(3) = Model3;
if ismac
    SVM_pth = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','SVM_Mac');
elseif ispc
    SVM_pth = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','SVM_Windows');
elseif isunix
    SVM_pth = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','SVM_Linux');
end
% Predict lesion probability map using SVM
[predict_0, predict_1, predict_2] = ...
    SVM_Runner(Test_ZeroOrder,Test_FirstOrder,Test_SecondOrder, SVM_pth, SVM_model);
% Convert the predicted 1D vectors into 3D MRIs and merge 3 predictions
% into one.
Merged_MRIs = Generate_MRI(patient_filenames,predict_0, predict_1, predict_2,Test_Location, NormV);
% Eliminate the ventricle from predicted MRI and try to eliminate some
% potential false positive clusters
CleanMRIs = Final_CleanUp(Merged_MRIs, NormV);
% Perform the inverse normalization: normalize the predicted lesion
% probability map to the native space. 
Inverse_Normalize(Merged_MRIs,CleanMRIs,InverseMAT);