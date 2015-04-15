function [NormT1, NormGM, NormWM, NormCSF, NormV, NormLPM, InverseMAT, NormGL] = ...
    Modified_NewSegment(TrainOrTest,patient_filenames, outInitialLPM, gamma, strokeSides,withskull,GLeMRI)
%%
if strcmpi(deblank(TrainOrTest),'train') == 1
    if nargin < 3
        T1MRI = spm_select([1 inf], 'image', 'Please select the patient T1 MRI(s)');
        LeMRI = spm_select([1 inf], 'image', 'Please select the initial LPM(s)');
        gamma = 5/6;
        strokeSides = massCenter(T1MRI);
        withskull = 1;
        GLeMRI = spm_select([1 inf],'image','Please select the ground truth binary lesion map(s)');
    elseif nargin < 4
        T1MRI = char(patient_filenames);
        LeMRI = char(outInitialLPM);
        gamma = 5/6;
        strokeSides = massCenter(T1MRI);
        withskull = 1;
        GLeMRI = spm_select([1 inf],'image','Please select the ground truth binary lesion map(s)');
    elseif nargin < 5
        T1MRI = char(patient_filenames);
        LeMRI = char(outInitialLPM);
        strokeSides = massCenter(T1MRI);
        withskull = 1;
        GLeMRI = spm_select([1 inf],'image','Please select the ground truth binary lesion map(s)');
    elseif nargin < 6
        T1MRI = char(patient_filenames);
        LeMRI = char(outInitialLPM);
        withskull = 1;
        GLeMRI = spm_select([1 inf],'image','Please select the ground truth binary lesion map(s)');
    elseif nargin < 7
        T1MRI = char(patient_filenames);
        LeMRI = char(outInitialLPM);
        GLeMRI = spm_select([1 inf],'image','Please select the ground truth binary lesion map(s)');
    else
        T1MRI = char(patient_filenames);
        LeMRI = char(outInitialLPM);
        GLeMRI = char(GLeMRI);
    end
end
if strcmpi(deblank(TrainOrTest),'test') == 1
    if nargin < 3
        T1MRI = spm_select([1 inf], 'image', 'Please select the patient T1 MRI(s)');
        LeMRI = spm_select([1 inf], 'image', 'Please select the initial LPM(s)');
        gamma = 5/6;
        strokeSides = massCenter(T1MRI);
        withskull = 1;
    elseif nargin < 4
        T1MRI = char(patient_filenames);
        LeMRI = char(outInitialLPM);
        gamma = 5/6;
        strokeSides = massCenter(T1MRI);
        withskull = 1;
    elseif nargin < 5
        T1MRI = char(patient_filenames);
        LeMRI = char(outInitialLPM);
        strokeSides = massCenter(T1MRI);
        withskull = 1;
    elseif nargin < 6
        T1MRI = char(patient_filenames);
        LeMRI = char(outInitialLPM);
        withskull = 1;
    elseif nargin < 7
        T1MRI = char(patient_filenames);
        LeMRI = char(outInitialLPM);
    end
end

Vi = spm_vol(T1MRI);
n = size(Vi,1);                %-#images
if n==0
    error('no input images specified')
end
NormT1 = cell(size(T1MRI,1),1);
NormGM = cell(size(T1MRI,1),1);
NormWM = cell(size(T1MRI,1),1);
NormCSF = cell(size(T1MRI,1),1);
NormV = cell(size(T1MRI,1),1);
NormLPM = cell(size(T1MRI,1),1);
InverseMAT = cell(size(T1MRI,1),1);
NormGL = cell(size(T1MRI,1),1);

Mask_RightBrain_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','RightHemiMask.nii');
Mask_LeftBrain_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','LeftHemiMask.nii');
MRI_R = spm_vol(Mask_RightBrain_filename);
MRI_L = spm_vol(Mask_LeftBrain_filename);
MRI_R_V = spm_read_vols(MRI_R);
MRI_L_V = spm_read_vols(MRI_L);
for n=1:size(T1MRI,1)
    [pth_T1MRI,nam_T1MRI,~] = fileparts(T1MRI(n,:));
    T1MRI_temp = fullfile(pth_T1MRI,[nam_T1MRI,'.nii']);
    
    [pth_Le,nam_Le,~] = fileparts(LeMRI(n,:));
    LeMRI_temp = fullfile(pth_Le,[nam_Le,'.nii']);
    
    smooth = cell(1);
    smooth{1}.spm.spatial.smooth.data = {LeMRI_temp};
    smooth{1}.spm.spatial.smooth.fwhm = [8 8 8];
    smooth{1}.spm.spatial.smooth.dtype = 0;
    smooth{1}.spm.spatial.smooth.im = 0;
    smooth{1}.spm.spatial.smooth.prefix = 's';
    spm_jobman('run',smooth);
    
    fprintf('T1: %s\n', T1MRI_temp);
    fprintf('Le: %s\n', LeMRI_temp);
    
    % Correct template field
    GM = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_GM.nii'));
    WM = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_WM.nii'));
    CSF = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_CSF_NoVentricle.nii'));
    Ventricle = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_Ventricle.nii'));
    Lesion = spm_vol(fullfile(pth_Le,['s', nam_Le,'.nii']));
    
    GM_V = spm_read_vols(GM);
    WM_V = spm_read_vols(WM);
    CSF_V = spm_read_vols(CSF);
    Ventricle_V = spm_read_vols(Ventricle);
    Lesion_V = spm_read_vols(Lesion);
    
    [d1,d2,d3] = size(GM_V);
    
    for i = 1:d1
        for j = 1:d2
            for k = 1:d3
                if (Lesion_V(i,j,k)>0)
                    if Lesion_V(i,j,k) <= gamma
                        Lesion_V(i,j,k) = Lesion_V(i,j,k)/gamma;
                        beta = 1 - Lesion_V(i,j,k)/gamma;
                        GM_V(i,j,k) = beta*GM_V(i,j,k);
                        WM_V(i,j,k) = beta*WM_V(i,j,k);
                        CSF_V(i,j,k) = beta*CSF_V(i,j,k);
                    else
                        Lesion_V(i,j,k) = 1;
                        GM_V(i,j,k) = 0;
                        WM_V(i,j,k) = 0;
                        CSF_V(i,j,k) = 0;
                    end
                end
            end
        end
    end
    GM = CSF;
    WM = CSF;
    Ventricle = CSF;
    Lesion = CSF;
    
    GM.fname = fullfile(pth_T1MRI, [nam_T1MRI, '_Modified_GM.nii']);
    WM.fname = fullfile(pth_T1MRI, [nam_T1MRI, '_Modified_WM.nii']);
    CSF.fname = fullfile(pth_T1MRI,[nam_T1MRI, '_Modified_CSF.nii']);
    Ventricle.fname = fullfile(pth_T1MRI, [nam_T1MRI, '_Modified_Ventricle.nii']);
    Lesion.fname = fullfile(pth_T1MRI, [nam_T1MRI, '_Modified_Lesion.nii']);
    spm_write_vol(GM, GM_V);
    spm_write_vol(WM, WM_V);
    spm_write_vol(CSF, CSF_V);
    spm_write_vol(Ventricle, Ventricle_V);
    spm_write_vol(Lesion, Lesion_V);
    
    %
    Bone_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_Bone.nii');
    ST_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_SoftTissue.nii');
    Air_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_Air.nii');
    NewSeg = cell(1);
    NewSeg{1}.spm.tools.preproc8.channel.vols = {T1MRI_temp};
    NewSeg{1}.spm.tools.preproc8.channel.biasreg = 0.0001;
    NewSeg{1}.spm.tools.preproc8.channel.biasfwhm = 60;
    NewSeg{1}.spm.tools.preproc8.channel.write = [0 0];
    NewSeg{1}.spm.tools.preproc8.tissue(1).tpm = {GM.fname};
    NewSeg{1}.spm.tools.preproc8.tissue(1).ngaus = 3;
    NewSeg{1}.spm.tools.preproc8.tissue(1).native = [1 1];
    NewSeg{1}.spm.tools.preproc8.tissue(1).warped = [1 1];
    NewSeg{1}.spm.tools.preproc8.tissue(2).tpm = {WM.fname};
    NewSeg{1}.spm.tools.preproc8.tissue(2).ngaus = 3;
    NewSeg{1}.spm.tools.preproc8.tissue(2).native = [1 1];
    NewSeg{1}.spm.tools.preproc8.tissue(2).warped = [1 1];
    NewSeg{1}.spm.tools.preproc8.tissue(3).tpm = {CSF.fname};
    NewSeg{1}.spm.tools.preproc8.tissue(3).ngaus = 4;
    NewSeg{1}.spm.tools.preproc8.tissue(3).native = [1 1];
    NewSeg{1}.spm.tools.preproc8.tissue(3).warped = [1 1];
    NewSeg{1}.spm.tools.preproc8.tissue(4).tpm = {Ventricle.fname};
    NewSeg{1}.spm.tools.preproc8.tissue(4).ngaus = 2;
    NewSeg{1}.spm.tools.preproc8.tissue(4).native = [1 1];
    NewSeg{1}.spm.tools.preproc8.tissue(4).warped = [1 1];
    NewSeg{1}.spm.tools.preproc8.tissue(5).tpm = {Air_filename};
    NewSeg{1}.spm.tools.preproc8.tissue(5).ngaus = 2;
    NewSeg{1}.spm.tools.preproc8.tissue(5).native = [0 0];
    NewSeg{1}.spm.tools.preproc8.tissue(5).warped = [0 0];
    NewSeg{1}.spm.tools.preproc8.tissue(6).tpm = {Lesion.fname};
    NewSeg{1}.spm.tools.preproc8.tissue(6).ngaus = 3;
    NewSeg{1}.spm.tools.preproc8.tissue(6).native = [1 1];
    NewSeg{1}.spm.tools.preproc8.tissue(6).warped = [1 1];
    if withskull
        NewSeg{1}.spm.tools.preproc8.tissue(7).tpm = {Bone_filename};
        NewSeg{1}.spm.tools.preproc8.tissue(7).ngaus = 3;
        NewSeg{1}.spm.tools.preproc8.tissue(7).native = [0 0];
        NewSeg{1}.spm.tools.preproc8.tissue(7).warped = [0 0];
        NewSeg{1}.spm.tools.preproc8.tissue(8).tpm = {ST_filename};
        NewSeg{1}.spm.tools.preproc8.tissue(8).ngaus = 4;
        NewSeg{1}.spm.tools.preproc8.tissue(8).native = [0 0];
        NewSeg{1}.spm.tools.preproc8.tissue(8).warped = [0 0];
    end
    
    NewSeg{1}.spm.tools.preproc8.warp.mrf = 0;
    NewSeg{1}.spm.tools.preproc8.warp.reg = 4;
    NewSeg{1}.spm.tools.preproc8.warp.affreg = 'mni';
    NewSeg{1}.spm.tools.preproc8.warp.samp = 3;
    NewSeg{1}.spm.tools.preproc8.warp.write = [1 1];
    spm_jobman('run', NewSeg);
    Normlization = cell(1);
    Field_Filename = fullfile(pth_T1MRI, ['y_', nam_T1MRI,'.nii']);
    Normlization{1}.spm.util.defs.comp{1}.def = {Field_Filename};
    Normlization{1}.spm.util.defs.ofname = '';
    Normlization{1}.spm.util.defs.fnames = {[T1MRI_temp,',1']};
    Normlization{1}.spm.util.defs.savedir.saveusr = {pth_T1MRI};
    Normlization{1}.spm.util.defs.interp = 1;
    spm_jobman('run',Normlization);
    
    if exist('GLeMRI','var')
        [pth_GLeMRI,nam_GLeMRI,~] = fileparts(GLeMRI(n,:));
        GLeMRI_temp = fullfile(pth_GLeMRI,[nam_GLeMRI,'.nii']);
        Normlization = cell(1);
        Field_Filename = fullfile(pth_T1MRI, ['y_', nam_T1MRI,'.nii']);
        Normlization{1}.spm.util.defs.comp{1}.def = {Field_Filename};
        Normlization{1}.spm.util.defs.ofname = '';
        Normlization{1}.spm.util.defs.fnames = {[GLeMRI_temp,',1']};
        Normlization{1}.spm.util.defs.savedir.saveusr = {pth_GLeMRI};
        Normlization{1}.spm.util.defs.interp = 1;
        spm_jobman('run',Normlization);
        NormGL{n} = fullfile(pth_GLeMRI,['w',nam_GLeMRI,'.nii']);
    end
    
    if strokeSides(n) == -1
        MRI_T1 = spm_vol(fullfile(pth_T1MRI,['w',nam_T1MRI,'.nii']));
        
        MRI_T1_V = spm_read_vols(MRI_T1);
        MRI_Lesion = MRI_T1_V(MRI_L_V == 1);
        MRI_T1_V = (MRI_T1_V - mean(MRI_Lesion))/(std(MRI_Lesion));
        MRI_T1.fname = fullfile(pth_T1MRI,['zw',nam_T1MRI,'.nii']);
        MRI_T1.dt = [16 0];
        spm_write_vol(MRI_T1,MRI_T1_V);
    else
        MRI_T1 = spm_vol(fullfile(pth_T1MRI,['w',nam_T1MRI,'.nii']));
        
        MRI_T1_V = spm_read_vols(MRI_T1);
        MRI_Lesion = MRI_T1_V(MRI_R_V == 1);
        MRI_T1_V = (MRI_T1_V - mean(MRI_Lesion))/(std(MRI_Lesion));
        MRI_T1.fname = fullfile(pth_T1MRI,['zw',nam_T1MRI,'.nii']);
        MRI_T1.dt = [16 0];
        spm_write_vol(MRI_T1,MRI_T1_V);
    end
    
    NormT1{n} = fullfile(pth_T1MRI,['zw',nam_T1MRI,'.nii']);
    NormGM{n} = fullfile(pth_T1MRI,['wc1',nam_T1MRI,'.nii']);
    NormWM{n} = fullfile(pth_T1MRI,['wc2',nam_T1MRI,'.nii']);
    NormCSF{n} = fullfile(pth_T1MRI,['wc3',nam_T1MRI,'.nii']);
    NormV{n} = fullfile(pth_T1MRI,['wc4',nam_T1MRI,'.nii']);
    NormLPM{n} = fullfile(pth_T1MRI,['wc6',nam_T1MRI,'.nii']);
    InverseMAT{n} = fullfile(pth_T1MRI,['iy_',nam_T1MRI,'.nii']);
end
fprintf('Modified Segmentation is Complete\n\n');