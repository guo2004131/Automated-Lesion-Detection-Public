function outInitialLPM = InitialLesionEstimation(outEnantiomorphicNorm,strokeSides,template_filename)
%%
if nargin < 1
    patient_filenames = spm_select([1 inf], 'image', 'Please Select Normalized Patient Files');
    strokeSides = massCenter(patient_filenames);
    template_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','Average_T1.nii');
elseif nargin < 2
    patient_filenames = char(outEnantiomorphicNorm);
    strokeSides = massCenter(patient_filenames);
    template_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','Average_T1.nii');
elseif nargin < 3
    patient_filenames = char(outEnantiomorphicNorm);
    template_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','Average_T1.nii');
else
    patient_filenames = char(outEnantiomorphicNorm);
end
outInitialLPM = cell(size(patient_filenames,1),1);
Mask_wholeBrain_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','BrainMask.nii');
Mask_RightBrain_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','RightHemiMask.nii');
Mask_LeftBrain_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','LeftHemiMask.nii');

TMRI = spm_vol(template_filename);
MW_MRI = spm_vol(Mask_wholeBrain_filename);
MR_MRI = spm_vol(Mask_RightBrain_filename);
ML_MRI = spm_vol(Mask_LeftBrain_filename);

TMRI_V = spm_read_vols(TMRI);
MW_MRI_V = spm_read_vols(MW_MRI);
MR_MRI_V = spm_read_vols(MR_MRI);
ML_MRI_V = spm_read_vols(ML_MRI);

alpha = 0.4;
lambda = 5;
smooth = cell(1);
for n = 1:size(patient_filenames,1)
    strokeSide = strokeSides(n);
    [pth nam ~] = fileparts(patient_filenames(n,:));
    smooth{1}.spm.spatial.smooth.data = {fullfile(pth,[nam,'.nii'])};
    smooth{1}.spm.spatial.smooth.fwhm = [8 8 8];
    smooth{1}.spm.spatial.smooth.dtype = 0;
    smooth{1}.spm.spatial.smooth.im = 0;
    smooth{1}.spm.spatial.smooth.prefix = 's';
%     spm_jobman('initcfg');
    spm_jobman('run',smooth);
    
    PMRI = spm_vol(fullfile(pth,['s',nam,'.nii']));
    PMRI_V = spm_read_vols(PMRI);
    delete(fullfile(pth,['s',nam,'.nii']));
    if strokeSide == -1
        PMRI_Right_V = PMRI_V(MR_MRI_V>0);
        TMRI_Right_V = TMRI_V(MR_MRI_V>0);
        mean_PMRI = mean(PMRI_Right_V);
        std_PMRI = std(PMRI_Right_V);
        mean_TMRI = mean(TMRI_Right_V);
        std_TMRI = std(TMRI_Right_V);
    elseif strokeSide == 1
        PMRI_Left_V = PMRI_V(ML_MRI_V>0);
        TMRI_Left_V = TMRI_V(ML_MRI_V>0);
        mean_PMRI = mean(PMRI_Left_V);
        std_PMRI = std(PMRI_Left_V);
        mean_TMRI = mean(TMRI_Left_V);
        std_TMRI = std(TMRI_Left_V);
    else
        PMRI_Whole_V = PMRI_V(MW_MRI_V>0);
        TMRI_Whole_V = TMRI_V(MW_MRI_V>0);
        mean_PMRI = mean(PMRI_Whole_V);
        std_PMRI = std(PMRI_Whole_V);
        mean_TMRI = mean(TMRI_Whole_V);
        std_TMRI = std(TMRI_Whole_V);
    end
    
    PMRI_V_ZScore = (PMRI_V - mean_PMRI)/std_PMRI;
    TMRI_V_ZScore = (TMRI_V - mean_TMRI)/std_TMRI;
    PMRI.dt = [16 0];
    
    D_Matrix = tanh((PMRI_V_ZScore-TMRI_V_ZScore));
    
    temp = D_Matrix;
    temp(temp>0) = 0;
    temp = -temp;
    temp = temp .^lambda;
    temp = temp .* MW_MRI_V;
    PMRI.fname = fullfile(pth, ['Initial_LPM_',nam,'.nii']);
    spm_write_vol(PMRI,temp);
    outInitialLPM{n} = PMRI.fname;
end
fprintf('Initial Leison Probability Map Estimation Is Complete\n\n');