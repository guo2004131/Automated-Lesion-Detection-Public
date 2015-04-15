function ALD_ModelTraining(job)
gamma = 5/6;
% Readin from "job" structure variable.
patient_filenames = job.PaMap;
GLesions = job.GLeMap;
withskull = job.withskull;
leave_one_out = job.leave_one_out;
% Perform the enantiomorphic normalization
[outEnantiomorphicNorm,patient_filenames,strokeSides] = ...
    EnantiomorphicNormalization(patient_filenames,withskull);
% Perform the initial lesion estimation procedure.
outInitialLPM = InitialLesionEstimation(outEnantiomorphicNorm,strokeSides);
% Perform the modified new segmentation using initial lesion estimation.
[NormT1, NormGM, NormWM, NormCSF, ~, NormLPM,~,NormGL] =...
    Modified_NewSegment('train',patient_filenames, outInitialLPM,gamma,strokeSides,withskull,GLesions);
% Generate the training data for SVM.
if leave_one_out
    [Train_ZeroOrder,Train_FirstOrder,Train_SecondOrder] =...
        TrainDat_Feature_SVM_Leave_One_Out(NormT1, NormGM, NormWM, NormCSF, NormLPM,NormGL);
else
    [Train_ZeroOrder,Train_FirstOrder,Train_SecondOrder] =...
        TrainDat_Feature_SVM(NormT1, NormGM, NormWM, NormCSF, NormLPM,NormGL);
end
% Choose among different OSs
if ismac
    SVM_pth = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','SVM_Mac');
elseif ispc
    SVM_pth = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','SVM_Windows');
elseif isunix
    SVM_pth = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','SVM_Linux');
end
% Train three models base on three different types of feature. 
[Model_0, Model_1, Model_2] =...
    SVM_Train(Train_ZeroOrder,Train_FirstOrder,Train_SecondOrder, SVM_pth);
