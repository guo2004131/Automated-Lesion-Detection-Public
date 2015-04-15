function [outEnantiomorphicNorm,patient_filenames,strokeSides] = EnantiomorphicNormalization(patient_filenames,withskull)
%%
% function EnantiomorphicNormalization (patient_filenames);
%
% This code was adapted for SPM8 by Dazhou Guo & Chris Rorden
% Original source:
% Enantiomorphic normalization of focally lesioned brains.
% Nachev P, Coulthard E, J??ger HR, Kennard C, Husain M.
% Neuroimage. 2008 39(3):1215-26.
% PMID: 18023365

%% in case no files specified
if nargin < 1
    patient_filenames = spm_select([1 inf],'image','Select image(s) to midline align');
    % Auto-lesion hemisphere detection
    strokeSides = massCenter(patient_filenames);
    outEnantiomorphicNorm = cell(size(patient_filenames,1),1);
    withskull = 1;
elseif nargin < 2
    patient_filenames = char(patient_filenames);
    strokeSides = massCenter(patient_filenames);
    outEnantiomorphicNorm = cell(size(patient_filenames,1),1);
    withskull = 1;
else
    patient_filenames = char(patient_filenames);
    strokeSides = massCenter(patient_filenames);
    outEnantiomorphicNorm = cell(size(patient_filenames,1),1);
end

for j=1:size(patient_filenames,1)
    % extract filename
    [pth,nam,ext] = spm_fileparts(deblank(patient_filenames(j,:)));
    fname = fullfile(pth,[nam ext]);
    fname_flip = fullfile(pth,['flip' nam ext]);
    strokeSide = strokeSides(j);
    
    % create mirror image file
    if (exist(fname,'file') ~= 2)
        fprintf('%s Error: unable to find image %s.\n',mfilename,fname);
        return;
    end;
    % create flipped image
    fhead = spm_vol(fname);
    fdata = spm_read_vols(fhead);
    fhead.fname = fname_flip;
    fhead.mat = [-1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1] * fhead.mat;
    spm_write_vol(fhead,fdata);
    fhead = spm_vol([fname,',1']);
    fhead_flip = spm_vol([fname_flip,',1']);
    x  = spm_coreg(fhead_flip,fhead);
    % apply transform
    x  = (x/2);
    M = spm_matrix(x);
    MM = spm_get_space(fname_flip);
    spm_get_space(fname_flip, M*MM); %reorient flip
    M  = inv(spm_matrix(x));
    MM = spm_get_space(fname);
    spm_get_space(fname, M*MM); %reorient original so midline is X=0
    % reslice
    P            = char([fname,',1'],[fname_flip,',1']);
    flags.mask   = 0;
    flags.mean   = 0;
    flags.interp = 1;
    flags.which  = 1;
    flags.wrap   = [0 0 0];
    flags.prefix = 'r';
    spm_reslice(P,flags);
    delete(fname_flip); %remove flipped file
    fname_flip = fullfile(pth,['rflip' nam ext]);%resliced flip file
    
    % create image with two intact hemispheres
    fhead = spm_vol([fname,',1']);
    fdata = spm_read_vols(fhead);
    xdata = fdata;
    fheadflip = spm_vol([fname_flip,',1']);
    fdataflip = spm_read_vols(fheadflip);
    
    for z=1:fhead.dim(3)
        for y=1:fhead.dim(2)
            for x=1:fhead.dim(1)
                XYZ_vx = [x; y; z; 1];
                XYZ_mm = fhead.mat * XYZ_vx;
                switch strokeSide
                    case -1
                        if (XYZ_mm(1) <= 0) %two right hemispheres
                            xdata(x,y,z) = fdataflip(x,y,z);
                        end
                    case 0
                        xdata(x,y,z) = XYZ_mm(1); %create a map of X coordinate
                    otherwise
                        if (XYZ_mm(1) > 0) %two left hemispheres
                            xdata(x,y,z) = fdataflip(x,y,z);
                        end
                end
            end;%x
        end;%y
    end;%z
    
    fname_x = fullfile(pth,['x', nam, ext]);%resliced flip file
    fhead.fname = fname_x; %save morphed image
    spm_write_vol(fhead,xdata);
    delete(fname_flip);
    
    
    %next: normalize mirror image with intact hemispheres
    if strokeSide == -1
        gtemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_rh_GM.nii');
        wtemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_rh_WM.nii');
        ctemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_rh_CSF.nii');
        btemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_rh_Bone.nii');
        stemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_rh_SoftTissue.nii');
        atemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_rh_Air.nii');
        
    elseif strokeSide == 0
        gtemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_GM.nii');
        wtemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_WM.nii');
        ctemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_CSF.nii');
        btemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_Bone.nii');
        stemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_SoftTissue.nii');
        atemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_whole_Air.nii');
    else
        gtemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_lh_GM.nii');
        wtemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_lh_WM.nii');
        ctemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_lh_CSF.nii');
        btemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_lh_Bone.nii');
        stemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_lh_SoftTissue.nii');
        atemplate = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','rTemplate_lh_Air.nii');
    end
    NewSeg = cell(1);
    % Enantiomormphic SPM "new segment" setup
    NewSeg{1}.spm.tools.preproc8.channel.vols = {fname_x};
    NewSeg{1}.spm.tools.preproc8.channel.biasreg = 0.0001;
    NewSeg{1}.spm.tools.preproc8.channel.biasfwhm = 60;
    NewSeg{1}.spm.tools.preproc8.channel.write = [0 0];
    NewSeg{1}.spm.tools.preproc8.tissue(1).tpm = {gtemplate};
    NewSeg{1}.spm.tools.preproc8.tissue(1).ngaus = 2;
    NewSeg{1}.spm.tools.preproc8.tissue(1).native = [0 0];
    NewSeg{1}.spm.tools.preproc8.tissue(1).warped = [0 0];
    NewSeg{1}.spm.tools.preproc8.tissue(2).tpm = {wtemplate};
    NewSeg{1}.spm.tools.preproc8.tissue(2).ngaus = 2;
    NewSeg{1}.spm.tools.preproc8.tissue(2).native = [0 0];
    NewSeg{1}.spm.tools.preproc8.tissue(2).warped = [0 0];
    NewSeg{1}.spm.tools.preproc8.tissue(3).tpm = {ctemplate};
    NewSeg{1}.spm.tools.preproc8.tissue(3).ngaus = 2;
    NewSeg{1}.spm.tools.preproc8.tissue(3).native = [0 0];
    NewSeg{1}.spm.tools.preproc8.tissue(3).warped = [0 0];
    NewSeg{1}.spm.tools.preproc8.tissue(4).tpm = {atemplate};
    NewSeg{1}.spm.tools.preproc8.tissue(4).ngaus = 2;
    NewSeg{1}.spm.tools.preproc8.tissue(4).native = [0 0];
    NewSeg{1}.spm.tools.preproc8.tissue(4).warped = [0 0];
    % If the input MRI is skull-striped, then please "bone, soft tissue"
    % will not be included in the segmentation process. 
    if withskull
        NewSeg{1}.spm.tools.preproc8.tissue(5).tpm = {btemplate};
        NewSeg{1}.spm.tools.preproc8.tissue(5).ngaus = 2;
        NewSeg{1}.spm.tools.preproc8.tissue(5).native = [0 0];
        NewSeg{1}.spm.tools.preproc8.tissue(5).warped = [0 0];
        NewSeg{1}.spm.tools.preproc8.tissue(6).tpm = {stemplate};
        NewSeg{1}.spm.tools.preproc8.tissue(6).ngaus = 4;
        NewSeg{1}.spm.tools.preproc8.tissue(6).native = [0 0];
        NewSeg{1}.spm.tools.preproc8.tissue(6).warped = [0 0];
    end
    
    NewSeg{1}.spm.tools.preproc8.warp.mrf = 0;
    NewSeg{1}.spm.tools.preproc8.warp.reg = 4;
    NewSeg{1}.spm.tools.preproc8.warp.affreg = 'mni';
    NewSeg{1}.spm.tools.preproc8.warp.samp = 3;
    NewSeg{1}.spm.tools.preproc8.warp.write = [1 1];
%     spm_jobman('initcfg');
    spm_jobman('run', NewSeg);
    % Perform a normalization using the same transformation matrix
    % generated from the segmentation procedure.
    Field_Filename = fullfile(pth, ['y_x', nam ,'.nii']);
    if exist(Field_Filename,'file')
        NewSegNorm = cell(1);
        fprintf('find transform field\n');
        NewSegNorm{1}.spm.util.defs.comp{1}.def = {Field_Filename};
        NewSegNorm{1}.spm.util.defs.ofname = '';
        Subject_filename = fullfile(pth, [nam, '.nii,1']);
        NewSegNorm{1}.spm.util.defs.fnames = {Subject_filename};
        NewSegNorm{1}.spm.util.defs.savedir.saveusr = {pth};
        NewSegNorm{1}.spm.util.defs.interp = 1;
%         spm_jobman('initcfg');
        spm_jobman('run',NewSegNorm);
        movefile(fullfile(pth,['w',nam,'.nii']),fullfile(pth,['Ew',nam,'.nii']));
        outEnantiomorphicNorm{j} = fullfile(pth,['Ew',nam,'.nii']);
    else
        fprintf('Error: unable to find %s\n',Field_Filename);
    end
end
fprintf('Enantiomorphic Normalization Is Complete\n\n');