function GenerateHealtyAverageMRI(healthy_filenames,withskull)
if nargin < 1
    healthy_filenames = spm_select([1 inf],'image','Select healthy control MR image(s)');
    withskull = 1;
elseif nargin < 2
    withskull = 1;
end
healthy_filenames = char(healthy_filenames);
AllT1_Skull = cell(size(healthy_filenames,1),1);
AllT1_NoSkull = cell(size(healthy_filenames,1),1);

GM = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_GM.nii'));
WM = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_WM.nii'));
CSF = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_CSF_NoVentricle.nii'));
Ventricle = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_Ventricle.nii'));
Air = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_Air.nii'));
Bone = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_Bone.nii'));
ST = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_SoftTissue.nii'));

Mask = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','BrainMask_02.nii'));
Mask_V = spm_read_vols(Mask);
%%
% withskull = 1;
for i = 1:size(healthy_filenames,1)
    MRI_temp = healthy_filenames(i,:);
    [pth,nam,~] = fileparts(MRI_temp);
    MRI_temp = fullfile(pth,[nam,'.nii']);
    % Segmentation Batch
    NewSeg = cell(1);
    NewSeg{1}.spm.tools.preproc8.channel.vols = {MRI_temp};
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
    NewSeg{1}.spm.tools.preproc8.tissue(5).tpm = {Air.fname};
    NewSeg{1}.spm.tools.preproc8.tissue(5).ngaus = 2;
    NewSeg{1}.spm.tools.preproc8.tissue(5).native = [0 0];
    NewSeg{1}.spm.tools.preproc8.tissue(5).warped = [0 0];
    if withskull ==  1
        NewSeg{1}.spm.tools.preproc8.tissue(6).tpm = {Bone.fname};
        NewSeg{1}.spm.tools.preproc8.tissue(6).ngaus = 3;
        NewSeg{1}.spm.tools.preproc8.tissue(6).native = [0 0];
        NewSeg{1}.spm.tools.preproc8.tissue(6).warped = [0 0];
        NewSeg{1}.spm.tools.preproc8.tissue(7).tpm = {ST.fname};
        NewSeg{1}.spm.tools.preproc8.tissue(7).ngaus = 3;
        NewSeg{1}.spm.tools.preproc8.tissue(7).native = [0 0];
        NewSeg{1}.spm.tools.preproc8.tissue(7).warped = [0 0];
    end
    
    NewSeg{1}.spm.tools.preproc8.warp.mrf = 0;
    NewSeg{1}.spm.tools.preproc8.warp.reg = 4;
    NewSeg{1}.spm.tools.preproc8.warp.affreg = 'mni';
    NewSeg{1}.spm.tools.preproc8.warp.samp = 3;
    NewSeg{1}.spm.tools.preproc8.warp.write = [1 1];
%     spm_jobman('initcfg');
    spm_jobman('run', NewSeg);
    % Normalization Batch
    Normlization = cell(1);
    Field_Filename = fullfile(pth, ['y_', nam,'.nii']);
    Normlization{1}.spm.util.defs.comp{1}.def = {Field_Filename};
    Normlization{1}.spm.util.defs.ofname = '';
    Normlization{1}.spm.util.defs.fnames = {[MRI_temp,',1']};
    Normlization{1}.spm.util.defs.savedir.saveusr = {pth};
    Normlization{1}.spm.util.defs.interp = 1;
%     spm_jobman('initcfg');
    spm_jobman('run',Normlization);
    % Zscore T1
    MRI = spm_vol(fullfile(pth,['w',nam,'.nii']));
    MRI_V = spm_read_vols(MRI);
    MRI_mean = mean(MRI_V(Mask_V>0));
    MRI_std = std(MRI_V(Mask_V>0));
    MRI_V_Z = (MRI_V - MRI_mean)/MRI_std;
    MRI.dt = [16 0];
    MRI.fname = fullfile(pth,['zw',nam,'.nii']);
    spm_write_vol(MRI,MRI_V_Z);
    % Save All Normalized T1 (with skull).
    AllT1_Skull{i} = MRI_V_Z;
    % Save All Normalized T1 (without skull).
    MRI_GM = spm_vol(fullfile(pth,['wc1',nam,'.nii']));
    MRI_GM_V = spm_read_vols(MRI_GM);
    MRI_WM = spm_vol(fullfile(pth,['wc2',nam,'.nii']));
    MRI_WM_V = spm_read_vols(MRI_WM);
    MRI_CSF = spm_vol(fullfile(pth,['wc3',nam,'.nii']));
    MRI_CSF_V = spm_read_vols(MRI_CSF);
    MRI_Ventricle = spm_vol(fullfile(pth,['wc4',nam,'.nii']));
    MRI_Ventricle_V = spm_read_vols(MRI_Ventricle);
    AllT1_NoSkull{i} = MRI_V_Z .* (MRI_GM_V + MRI_WM_V + MRI_CSF_V + MRI_Ventricle_V);
end
%%
Average_T1_Skull = zeros(size(Mask_V));
Average_T1_NoSkull = zeros(size(Mask_V));

for i = 1:size(healthy_filenames,1)
    Average_T1_Skull = AllT1_Skull{i} + Average_T1_Skull;
    Average_T1_NoSkull = AllT1_NoSkull{i} + Average_T1_NoSkull;
end
Average_T1_Skull = Average_T1_Skull/size(healthy_filenames,1);
MRI.fname = fullfile(pth,'Average_Skull.nii');
spm_write_vol(MRI,Average_T1_Skull);
Average_T1_NoSkull = Average_T1_NoSkull/size(healthy_filenames,1);
MRI.fname = fullfile(pth,'Average_NoSkull.nii');
spm_write_vol(MRI,Average_T1_NoSkull);