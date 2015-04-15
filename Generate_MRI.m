function Merged_MRIs = Generate_MRI(patient_filenames,predict_1st, predict_2nd, predict_3rd,Location,NormV)
%% Generate MRI from Test Results.
MRI = spm_vol(fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','Average_T1.nii'));
MRI.dt = [16 0];
Merged_MRIs = cell(size(predict_1st),1);
predict_1st = char(predict_1st);
predict_2nd = char(predict_2nd);
predict_3rd = char(predict_3rd);
Location = char(Location);
NormV = char(NormV);
patient_filenames = char(patient_filenames);
for i = 1:size(predict_1st,1)
    [~,nam,~] = fileparts(patient_filenames(i,:));
    predict_1st_temp = deblank(predict_1st(i,:));
    predict_2nd_temp = deblank(predict_2nd(i,:));
    predict_3rd_temp = deblank(predict_3rd(i,:));
    location_temp = deblank(Location(i,:));
    
    [pth1,~,~] = fileparts(predict_1st_temp);
    [pth2,~,~] = fileparts(predict_2nd_temp);
    [pth3,~,~] = fileparts(predict_3rd_temp);

    MRI_V_1st = zeros(MRI.dim);
    MRI_V_2nd = zeros(MRI.dim);
    MRI_V_3rd = zeros(MRI.dim);

    prediction_initial = nam;

    fprintf('Now :%s\n',prediction_initial);
    Location_Info_fid = fopen(location_temp,'r');
    Location_Info_files_temp = textscan(Location_Info_fid,'%d,%d,%d\n');
    Location_Info_files(:,1) = Location_Info_files_temp{1};
    Location_Info_files(:,2) = Location_Info_files_temp{2};
    Location_Info_files(:,3) = Location_Info_files_temp{3};
    
    
    prediction_1st_fid = fopen(predict_1st_temp,'r');
    prediction_1st_files = textscan(prediction_1st_fid,'%f');
    prediction_1st_files = prediction_1st_files{1};
    
    prediction_2nd_fid = fopen(predict_2nd_temp,'r');
    prediction_2nd_files = textscan(prediction_2nd_fid,'%f');
    prediction_2nd_files = prediction_2nd_files{1};
    
    prediction_3rd_fid = fopen(predict_3rd_temp,'r');
    prediction_3rd_files = textscan(prediction_3rd_fid,'%f');
    prediction_3rd_files = prediction_3rd_files{1};
    
    fclose(prediction_1st_fid);
    fclose(prediction_2nd_fid);
    fclose(prediction_3rd_fid);
    fclose(Location_Info_fid);

    lines_num = min([size(prediction_1st_files,1), ...
        size(prediction_2nd_files,1), size(prediction_3rd_files,1),...
        size(Location_Info_files,1)]);
    for n = 1:lines_num
        temp_location = Location_Info_files(n,:);
        center_x = temp_location(1)+2;
        center_y = temp_location(2)+2;
        center_z = temp_location(3)+2;
        MRI_V_1st(center_x,center_y,center_z) = prediction_1st_files(n);
        MRI_V_2nd(center_x,center_y,center_z) = prediction_2nd_files(n);
        MRI_V_3rd(center_x,center_y,center_z) = prediction_3rd_files(n);
    end
    MRI_V_1st(MRI_V_1st<0) = 0;
    MRI_V_2nd(MRI_V_2nd<0) = 0;
    MRI_V_3rd(MRI_V_3rd<0) = 0;
    
    MRI_V_1st = MRI_V_1st/max(MRI_V_1st(:));
    MRI_V_2nd = MRI_V_2nd/max(MRI_V_2nd(:));
    MRI_V_3rd = MRI_V_3rd/max(MRI_V_3rd(:));
    
    MRI.fname = fullfile(pth1,['Prediction_1st_',prediction_initial,'.nii']); 
    spm_write_vol(MRI,MRI_V_1st);
    MRI.fname = fullfile(pth2,['Prediction_2nd_',prediction_initial,'.nii']); 
    spm_write_vol(MRI,MRI_V_2nd);
    MRI.fname = fullfile(pth3,['Prediction_3rd_',prediction_initial,'.nii']); 
    spm_write_vol(MRI,MRI_V_3rd);
    [vpth,vnam,~] = fileparts(NormV(i,:));
    VMRI = spm_vol(fullfile(vpth,[vnam,'.nii']));
    VMRI_V = spm_read_vols(VMRI);
    
    Merge_V = (MRI_V_1st + 3*MRI_V_2nd + 6*MRI_V_3rd)/10;
    Merge_V = Merge_V .* (1-VMRI_V);
    MRI.fname = fullfile(pth3,['Merge_',prediction_initial,'.nii']); 
    spm_write_vol(MRI,Merge_V);
    
    Merged_MRIs{i} = MRI.fname;
end
fprintf('MRI is Generated\n\n');