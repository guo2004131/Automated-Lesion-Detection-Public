function Lside = massCenter(MRI_filenames)
%%
if nargin <1
    MRI_filenames = spm_select(inf,'image','Select image(s)');
end
MRI_template_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','Average_T1.nii');
Lside = zeros(1,size(MRI_template_filename,1));

% Estimation begins:
for n = 1:size(MRI_filenames,1)
    [pth, nam, ~] = fileparts(MRI_filenames(n,:));
    filename = fullfile(pth,[nam,'.nii']);
    fprintf('Now: %s\n',nam);
    % SPM batch setup for smoothing and corregistration. 
    massCenterBatch = cell(2,1);
    massCenterBatch{1}.spm.spatial.smooth.data = {filename};
    massCenterBatch{1}.spm.spatial.smooth.fwhm = [8 8 8];
    massCenterBatch{1}.spm.spatial.smooth.dtype = 0;
    massCenterBatch{1}.spm.spatial.smooth.im = 0;
    massCenterBatch{1}.spm.spatial.smooth.prefix = 's';
    massCenterBatch{2}.spm.spatial.coreg.estwrite.ref = {MRI_template_filename};
    massCenterBatch{2}.spm.spatial.coreg.estwrite.source(1) = cfg_dep;
    massCenterBatch{2}.spm.spatial.coreg.estwrite.source(1).tname = 'Source Image';
    massCenterBatch{2}.spm.spatial.coreg.estwrite.source(1).tgt_spec{1}(1).name = 'filter';
    massCenterBatch{2}.spm.spatial.coreg.estwrite.source(1).tgt_spec{1}(1).value = 'image';
    massCenterBatch{2}.spm.spatial.coreg.estwrite.source(1).tgt_spec{1}(2).name = 'strtype';
    massCenterBatch{2}.spm.spatial.coreg.estwrite.source(1).tgt_spec{1}(2).value = 'e';
    massCenterBatch{2}.spm.spatial.coreg.estwrite.source(1).sname = 'Smooth: Smoothed Images';
    massCenterBatch{2}.spm.spatial.coreg.estwrite.source(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    massCenterBatch{2}.spm.spatial.coreg.estwrite.source(1).src_output = substruct('.','files');
    massCenterBatch{2}.spm.spatial.coreg.estwrite.other = {''};
    massCenterBatch{2}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    massCenterBatch{2}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    massCenterBatch{2}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    massCenterBatch{2}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    massCenterBatch{2}.spm.spatial.coreg.estwrite.roptions.interp = 1;
    massCenterBatch{2}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    massCenterBatch{2}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    massCenterBatch{2}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
%     spm_jobman('initcfg');
    spm_jobman('run',massCenterBatch);
    
    % Read in the smoothed and registered MRI (one for each time)
    Reg_S_MRI_filename = fullfile(pth,['rs' nam '.nii']);
    Reg_S_MRI = spm_vol(Reg_S_MRI_filename);
    Reg_S_MRI_V = spm_read_vols(Reg_S_MRI);
    % Compute the histogram of the input image. Reference: Zou et al,
    % "Texture enhaced image denosing via gradient histogram preservation",
    % CVPR 2013
    [~,X] = hist(Reg_S_MRI_V(:),10);
    Reg_S_MRI_V(Reg_S_MRI_V<=X(2)) = 0;
    % Initial x, y, and z for mass center computation.
    sum_x = 0;
    sum_y = 0;
    sum_z = 0;
    [d1,d2,d3] = size(Reg_S_MRI_V);
    % Use a bonding box to further restrict the area
    D1_Start = round(d1*0.2);
    D1_End = round(d1*0.8);
    D2_Start = round(d2*0.2);
    D2_End = round(d2*0.8);
    D3_Start = round(d3*0.3);
    D3_End = round(d3*0.75);
    temp_MRI = zeros(d1,d2,d3);
    % Compute the mass center
    for x = D1_Start:D1_End
        for y = D2_Start:D2_End
            for z = D3_Start:D3_End
                sum_x = sum_x + x*Reg_S_MRI_V(x,y,z);
                sum_y = sum_y + y*Reg_S_MRI_V(x,y,z);
                sum_z = sum_z + z*Reg_S_MRI_V(x,y,z);
                temp_MRI(x,y,z) = Reg_S_MRI_V(x,y,z);
            end
        end
    end
    % Measure the mass center based on the mat file. 
    M = sum(temp_MRI(:));
    loc_x = (sum_x/M);
    loc_y = (sum_y/M);
    loc_z = (sum_z/M);
    mm_loc = Reg_S_MRI.mat * [loc_x;loc_y;loc_z;1];
    if mm_loc(1) < 0
        fprintf('Lesion on Right\n');
        Lside(n) = 1;
    else
        fprintf('Lesion on Left\n');
        Lside(n) = -1;
    end
    fprintf('******************************************************\n\n');
    
    delete(Reg_S_MRI_filename);
    smooth_filename = fullfile(pth,['s', nam, '.nii']);
    delete(smooth_filename);
end
