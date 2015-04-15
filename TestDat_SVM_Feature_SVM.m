function [Test_ZeroOrder,Test_FirstOrder,Test_SecondOrder,Test_Location] = TestDat_SVM_Feature_SVM(NormT1, NormGM, NormWM, NormCSF, NormLPM, NormGL)
%%
if nargin < 6
    T1_filenames = char(NormT1);
    GM_filenames = char(NormGM);
    WM_filenames = char(NormWM);
    CSF_filenames = char(NormCSF);
    LPM_filenames = char(NormLPM);
    
    T1_ALL = spm_vol(T1_filenames);
    GM_ALL = spm_vol(GM_filenames);
    WM_ALL = spm_vol(WM_filenames);
    CSF_ALL = spm_vol(CSF_filenames);
    LPM_ALL = spm_vol(LPM_filenames);
    
    T1_ALL_V = spm_read_vols(T1_ALL);
    GM_ALL_V = spm_read_vols(GM_ALL);
    WM_ALL_V = spm_read_vols(WM_ALL);
    CSF_ALL_V = spm_read_vols(CSF_ALL);
    LPM_ALL_V = spm_read_vols(LPM_ALL);
    Lesion_ALL_V = zeros(size(LPM_ALL_V));
    tag_lesion = 0;
else
    T1_filenames = char(NormT1);
    GM_filenames = char(NormGM);
    WM_filenames = char(NormWM);
    CSF_filenames = char(NormCSF);
    LPM_filenames = char(NormLPM);
    Lesion_filenames = char(NormGL);
    
    T1_ALL = spm_vol(T1_filenames);
    GM_ALL = spm_vol(GM_filenames);
    WM_ALL = spm_vol(WM_filenames);
    CSF_ALL = spm_vol(CSF_filenames);
    LPM_ALL = spm_vol(LPM_filenames);
    Lesion_ALL = spm_vol(Lesion_filenames);
    
    T1_ALL_V = spm_read_vols(T1_ALL);
    GM_ALL_V = spm_read_vols(GM_ALL);
    WM_ALL_V = spm_read_vols(WM_ALL);
    CSF_ALL_V = spm_read_vols(CSF_ALL);
    LPM_ALL_V = spm_read_vols(LPM_ALL);
    Lesion_ALL_V = spm_read_vols(Lesion_ALL);
    tag_lesion = 1;
end

BrainMask_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','BrainMask.nii');
BrainMask = spm_vol(BrainMask_filename);
BrainMask_V = spm_read_vols(BrainMask);

step_x_n = 1;
step_y_n = 1;
step_z_n = 1;

[pth, ~, ~] = fileparts(T1_filenames(1,:));
BlockSize = 5;
output_folder = pth;

[d1,d2,d3,d4] = size(T1_ALL_V);

Test_ZeroOrder = cell(d4,1);
Test_FirstOrder = cell(d4,1);
Test_SecondOrder = cell(d4,1);
Test_Location = cell(d4,1);

HaarFeature = get_Feature3D_filter_window([BlockSize,BlockSize,BlockSize]);
for MRI_n = 1:size(NormT1,1)
    [~,name,~] = fileparts(T1_ALL(MRI_n).fname);
    Test_ZeroOrder_name = fullfile(output_folder,['Test_ZeroOrder_',name,'.dat']);
    Test_FirstOrder_name = fullfile(output_folder,['Test_FirstOrder_',name,'.dat']);
    Test_SecondOrder_name = fullfile(output_folder,['Test_SecondOrder_',name,'.dat']);
    Location_name = fullfile(output_folder,['Location_',name,'.txt']);
    Label_name = fullfile(output_folder, ['Label_',name,'.txt']);
    
    fid_ZeroOrder = fopen(Test_ZeroOrder_name,'w');
    fid_FirstOrder = fopen(Test_FirstOrder_name,'w');
    fid_SecondOrder = fopen(Test_SecondOrder_name,'w');
    fid_Location = fopen(Location_name,'w');
    fid_Label = fopen(Label_name,'w');
    
    positive_key_count = 1;
    negative_key_count = 1;
    T1 = T1_ALL(MRI_n);
    T1_V = T1_ALL_V(:,:,:,MRI_n);
    GM = GM_ALL(MRI_n);
    GM_V = GM_ALL_V(:,:,:,MRI_n);
    WM = WM_ALL(MRI_n);
    WM_V = WM_ALL_V(:,:,:,MRI_n);
    CSF = CSF_ALL(MRI_n);
    CSF_V = CSF_ALL_V(:,:,:,MRI_n);
    LPM = LPM_ALL(MRI_n);
    LPM_V = LPM_ALL_V(:,:,:,MRI_n);
    
    fprintf('MRI:\t%s\n',T1.fname);
    fprintf('GM:\t%s\n',GM.fname);
    fprintf('WM:\t%s\n',WM.fname);
    fprintf('CSF:\t%s\n',CSF.fname);
    fprintf('LPM:\t%s\n',LPM.fname);
    if tag_lesion == 1
        Lesion = Lesion_ALL(MRI_n);
        Lesion_V = Lesion_ALL_V(:,:,:,MRI_n);
        fprintf('Lesion:\t%s\n',Lesion.fname);
    else
        Lesion_V = Lesion_ALL_V(:,:,:,MRI_n);
    end
    
    
    %-%-%-%-%-%-%-%-%-%-%-%-%
    %  Feature Computation  %
    %-%-%-%-%-%-%-%-%-%-%-%-%
    for x = 2:step_x_n:d1-BlockSize-1
        fprintf('Now: x is %d/%d\n',x,d1);
        for y = 2:step_y_n:d2-BlockSize-1
            for z = 2:step_z_n:d3-BlockSize-1
                testMaskBlock = BrainMask_V(x:x+BlockSize-1, ...
                    y:y+BlockSize-1, z:z+BlockSize-1);
                if sum(testMaskBlock(:)) >= 0.9*BlockSize^3
                    testLesionBlock = Lesion_V(x:x+BlockSize-1, ...
                        y:y+BlockSize-1, z:z+BlockSize-1);
                    %-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%
                    % compute the first order feature:                  %
                    % Voxel + Haar-Feature                              %
                    %-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%
                    %For T1 ZScored MRI
                    TempBlock = T1_V(x:x+BlockSize-1, ...
                        y:y+BlockSize-1, z:z+BlockSize-1);
                    HaarVector = zeros(size(HaarFeature,4),1);
                    for h = 1:size(HaarFeature,4)
                        HaarBlock = TempBlock .* HaarFeature(:,:,:,h);
                        HaarVector(h) = sum(HaarBlock(:));
                    end
                    ZeroOrderFeature_T1 = [TempBlock(:)',HaarVector'];
                    % For GM Probability MRI
                    TempBlock = GM_V(x:x+BlockSize-1, ...
                        y:y+BlockSize-1, z:z+BlockSize-1);
                    HaarVector = zeros(size(HaarFeature,4),1);
                    for h = 1:size(HaarFeature,4)
                        HaarBlock = TempBlock .* HaarFeature(:,:,:,h);
                        HaarVector(h) = sum(HaarBlock(:));
                    end
                    ZeroOrderFeature_GM = [TempBlock(:)',HaarVector'];
                    % For WM Probability MRI
                    TempBlock = WM_V(x:x+BlockSize-1, ...
                        y:y+BlockSize-1, z:z+BlockSize-1);
                    HaarVector = zeros(size(HaarFeature,4),1);
                    for h = 1:size(HaarFeature,4)
                        HaarBlock = TempBlock .* HaarFeature(:,:,:,h);
                        HaarVector(h) = sum(HaarBlock(:));
                    end
                    ZeroOrderFeature_WM = [TempBlock(:)',HaarVector'];
                    % For CSF Probability MRI
                    TempBlock = CSF_V(x:x+BlockSize-1, ...
                        y:y+BlockSize-1, z:z+BlockSize-1);
                    HaarVector = zeros(size(HaarFeature,4),1);
                    for h = 1:size(HaarFeature,4)
                        HaarBlock = TempBlock .* HaarFeature(:,:,:,h);
                        HaarVector(h) = sum(HaarBlock(:));
                    end
                    ZeroOrderFeature_CSF = [TempBlock(:)',HaarVector'];
                    % For LPM Probability MRI
                    TempBlock = LPM_V(x:x+BlockSize-1, ...
                        y:y+BlockSize-1, z:z+BlockSize-1);
                    HaarVector = zeros(size(HaarFeature,4),1);
                    for h = 1:size(HaarFeature,4)
                        HaarBlock = TempBlock .* HaarFeature(:,:,:,h);
                        HaarVector(h) = sum(HaarBlock(:));
                    end
                    ZeroOrderFeature_LPM = [TempBlock(:)',HaarVector'];
                    % Gether T1, GM, WM, CSF, LPM features into one
                    ZeroOrderFeature = [ZeroOrderFeature_T1,...
                        ZeroOrderFeature_GM, ZeroOrderFeature_WM, ...
                        ZeroOrderFeature_CSF, ZeroOrderFeature_LPM];
                    ZeroOrderFeatureRange = 1:size(ZeroOrderFeature,2);
                    
                    %-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%
                    % Compute the second order feature (set-feature):   %
                    % set voxel mean and set Haar-Feature mean          %
                    %-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%
                    %For T1 ZScored MRI
                    SetVoxelMeanBlock = zeros(BlockSize,BlockSize,BlockSize);
                    HaarSet_T1 = zeros(size(HaarFeature,4),27);
                    count = 0;
                    for i = x-1:x+1
                        for j = y-1:y+1
                            for k = z-1:z+1
                                count = count + 1;
                                HaarVector = zeros(size(HaarFeature,4),1);
                                TempBlock = T1_V(i:i+BlockSize-1, ...
                                    j:j+BlockSize-1, k:k+BlockSize-1);
                                for h = 1:size(HaarFeature,4)
                                    HaarBlock = TempBlock .* HaarFeature(:,:,:,h);
                                    HaarVector(h) = sum(HaarBlock(:));
                                end
                                HaarSet_T1(:,count) = HaarVector;
                                SetVoxelMeanBlock = SetVoxelMeanBlock + TempBlock;
                            end
                        end
                    end
                    SetVoxelMeanBlock = SetVoxelMeanBlock/count;
                    SetHaarMean_T1 = sum(HaarSet_T1,2)/count;
                    FirstOrderFeature_T1 = [SetVoxelMeanBlock(:)', SetHaarMean_T1'];
                    %For GM Probability MRI
                    SetVoxelMeanBlock = zeros(BlockSize,BlockSize,BlockSize);
                    HaarSet_GM = zeros(size(HaarFeature,4),27);
                    count = 0;
                    for i = x-1:x+1
                        for j = y-1:y+1
                            for k = z-1:z+1
                                count = count + 1;
                                HaarVector = zeros(size(HaarFeature,4),1);
                                TempBlock = GM_V(i:i+BlockSize-1, ...
                                    j:j+BlockSize-1, k:k+BlockSize-1);
                                for h = 1:size(HaarFeature,4)
                                    HaarBlock = TempBlock .* HaarFeature(:,:,:,h);
                                    HaarVector(h) = sum(HaarBlock(:));
                                end
                                HaarSet_GM(:,count) = HaarVector;
                                SetVoxelMeanBlock = SetVoxelMeanBlock + TempBlock;
                            end
                        end
                    end
                    SetVoxelMeanBlock = SetVoxelMeanBlock/count;
                    SetHaarMean_GM = sum(HaarSet_GM,2)/count;
                    FirstOrderFeature_GM = [SetVoxelMeanBlock(:)', SetHaarMean_GM'];
                    %For WM Probability MRI
                    SetVoxelMeanBlock = zeros(BlockSize,BlockSize,BlockSize);
                    HaarSet_WM = zeros(size(HaarFeature,4),27);
                    count = 0;
                    for i = x-1:x+1
                        for j = y-1:y+1
                            for k = z-1:z+1
                                count = count + 1;
                                HaarVector = zeros(size(HaarFeature,4),1);
                                TempBlock = WM_V(i:i+BlockSize-1, ...
                                    j:j+BlockSize-1, k:k+BlockSize-1);
                                for h = 1:size(HaarFeature,4)
                                    HaarBlock = TempBlock .* HaarFeature(:,:,:,h);
                                    HaarVector(h) = sum(HaarBlock(:));
                                end
                                HaarSet_WM(:,count) = HaarVector;
                                SetVoxelMeanBlock = SetVoxelMeanBlock + TempBlock;
                            end
                        end
                    end
                    SetVoxelMeanBlock = SetVoxelMeanBlock/count;
                    SetHaarMean_WM = sum(HaarSet_WM,2)/count;
                    FirstOrderFeature_WM = [SetVoxelMeanBlock(:)', SetHaarMean_WM'];
                    %For CSF Probability MRI
                    SetVoxelMeanBlock = zeros(BlockSize,BlockSize,BlockSize);
                    HaarSet_CSF = zeros(size(HaarFeature,4),27);
                    count = 0;
                    for i = x-1:x+1
                        for j = y-1:y+1
                            for k = z-1:z+1
                                count = count + 1;
                                HaarVector = zeros(size(HaarFeature,4),1);
                                TempBlock = CSF_V(i:i+BlockSize-1, ...
                                    j:j+BlockSize-1, k:k+BlockSize-1);
                                for h = 1:size(HaarFeature,4)
                                    HaarBlock = TempBlock .* HaarFeature(:,:,:,h);
                                    HaarVector(h) = sum(HaarBlock(:));
                                end
                                HaarSet_CSF(:,count) = HaarVector;
                                SetVoxelMeanBlock = SetVoxelMeanBlock + TempBlock;
                            end
                        end
                    end
                    SetVoxelMeanBlock = SetVoxelMeanBlock/count;
                    SetHaarMean_CSF = sum(HaarSet_CSF,2)/count;
                    FirstOrderFeature_CSF = [SetVoxelMeanBlock(:)', SetHaarMean_CSF'];
                    %For LPM Probability MRI
                    SetVoxelMeanBlock = zeros(BlockSize,BlockSize,BlockSize);
                    HaarSet_LPM = zeros(size(HaarFeature,4),27);
                    count = 0;
                    for i = x-1:x+1
                        for j = y-1:y+1
                            for k = z-1:z+1
                                count = count + 1;
                                HaarVector = zeros(size(HaarFeature,4),1);
                                TempBlock = LPM_V(i:i+BlockSize-1, ...
                                    j:j+BlockSize-1, k:k+BlockSize-1);
                                for h = 1:size(HaarFeature,4)
                                    HaarBlock = TempBlock .* HaarFeature(:,:,:,h);
                                    HaarVector(h) = sum(HaarBlock(:));
                                end
                                HaarSet_LPM(:,count) = HaarVector;
                                SetVoxelMeanBlock = SetVoxelMeanBlock + TempBlock;
                            end
                        end
                    end
                    SetVoxelMeanBlock = SetVoxelMeanBlock/count;
                    SetHaarMean_LPM = sum(HaarSet_LPM,2)/count;
                    FirstOrderFeature_LPM = [SetVoxelMeanBlock(:)', SetHaarMean_LPM'];
                    % Gether T1, GM, WM, CSF, LPM features into one
                    FirstOrderFeature = [FirstOrderFeature_T1, ...
                        FirstOrderFeature_GM, FirstOrderFeature_WM, ...
                        FirstOrderFeature_CSF, FirstOrderFeature_LPM];
                    FirstOrderFeatureRange = 1:size(FirstOrderFeature,2);
                    
                    %-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%
                    % Compute the third order feature (set-feature):    %
                    % set Haar-Feature Covarience                       %
                    %-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%
                    %For T1 ZScored MRI
                    SecondOrderFeature_T1 = zeros(size(HaarFeature,4));
                    for t = 1:27
                        diffHaar = HaarSet_T1(:,t) - SetHaarMean_T1;
                        CoDiffHaar = diffHaar*diffHaar';
                        SecondOrderFeature_T1 = SecondOrderFeature_T1 + CoDiffHaar;
                    end
                    SecondOrderFeature_T1 = SecondOrderFeature_T1(:)/26;
                    %For GM Probability MRI
                    SecondOrderFeature_GM = zeros(size(HaarFeature,4));
                    for t = 1:27
                        diffHaar = HaarSet_GM(:,t) - SetHaarMean_GM;
                        CoDiffHaar = diffHaar*diffHaar';
                        SecondOrderFeature_GM = SecondOrderFeature_GM + CoDiffHaar;
                    end
                    SecondOrderFeature_GM = SecondOrderFeature_GM(:)/26;
                    %For WM Probability MRI
                    SecondOrderFeature_WM = zeros(size(HaarFeature,4));
                    for t = 1:27
                        diffHaar = HaarSet_WM(:,t) - SetHaarMean_WM;
                        CoDiffHaar = diffHaar*diffHaar';
                        SecondOrderFeature_WM = SecondOrderFeature_WM + CoDiffHaar;
                    end
                    SecondOrderFeature_WM = SecondOrderFeature_WM(:)/26;
                    %For CSF Probability MRI
                    SecondOrderFeature_CSF = zeros(size(HaarFeature,4));
                    for t = 1:27
                        diffHaar = HaarSet_CSF(:,t) - SetHaarMean_CSF;
                        CoDiffHaar = diffHaar*diffHaar';
                        SecondOrderFeature_CSF = SecondOrderFeature_CSF + CoDiffHaar;
                    end
                    SecondOrderFeature_CSF = SecondOrderFeature_CSF(:)/26;
                    %For LPM Probability MRI
                    SecondOrderFeature_LPM = zeros(size(HaarFeature,4));
                    for t = 1:27
                        diffHaar = HaarSet_LPM(:,t) - SetHaarMean_LPM;
                        CoDiffHaar = diffHaar*diffHaar';
                        SecondOrderFeature_LPM = SecondOrderFeature_LPM + CoDiffHaar;
                    end
                    SecondOrderFeature_LPM = SecondOrderFeature_LPM(:)/26;
                    % Gether T1, GM, WM, CSF, LPM features into one
                    SecondOrderFeature = [SecondOrderFeature_T1', ...
                        SecondOrderFeature_GM', SecondOrderFeature_WM', ...
                        SecondOrderFeature_CSF', SecondOrderFeature_LPM'];
                    SecondOrderFeatureRange = 1:size(SecondOrderFeature,2);
                    
                    %-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%
                    % Write out the computed features:                  %
                    % 1st-, 2nd-, and 3rd-order features                %
                    %-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%
                    fprintf(fid_Location,'%d, %d, %d\n',x,y,z);
                    if tag_lesion == 1
                        if sum(testLesionBlock(:)) >= 0.9*BlockSize^3
                            fprintf(fid_Label,'1\n');
                            
                            fprintf(fid_ZeroOrder,'1\t');
                            fprintf(fid_ZeroOrder,'%d:%f\t', ...
                                [ZeroOrderFeatureRange;ZeroOrderFeature]);
                            fprintf(fid_ZeroOrder,'\n');
                            
                            fprintf(fid_FirstOrder,'1\t');
                            fprintf(fid_FirstOrder,'%d:%f\t', ...
                                [FirstOrderFeatureRange;FirstOrderFeature]);
                            fprintf(fid_FirstOrder,'\n');
                            
                            fprintf(fid_SecondOrder,'1\t');
                            fprintf(fid_SecondOrder,'%d:%f\t', ...
                                [SecondOrderFeatureRange;SecondOrderFeature]);
                            fprintf(fid_SecondOrder,'\n');
                            
                            positive_key_count = positive_key_count + 1;
                        else
                            fprintf(fid_Label,'-1\n');
                            
                            fprintf(fid_ZeroOrder,'-1\t');
                            fprintf(fid_ZeroOrder,'%d:%f\t', ...
                                [ZeroOrderFeatureRange;ZeroOrderFeature]);
                            fprintf(fid_ZeroOrder,'\n');
                            
                            fprintf(fid_FirstOrder,'-1\t');
                            fprintf(fid_FirstOrder,'%d:%f\t', ...
                                [FirstOrderFeatureRange;FirstOrderFeature]);
                            fprintf(fid_FirstOrder,'\n');
                            
                            fprintf(fid_SecondOrder,'-1\t');
                            fprintf(fid_SecondOrder,'%d:%f\t', ...
                                [SecondOrderFeatureRange;SecondOrderFeature]);
                            fprintf(fid_SecondOrder,'\n');
                            negative_key_count = negative_key_count + 1;
                        end
                    else
                        fprintf(fid_Label,'0\n');
                        
                        fprintf(fid_ZeroOrder,'1\t');
                        fprintf(fid_ZeroOrder,'%d:%f\t', ...
                            [ZeroOrderFeatureRange;ZeroOrderFeature]);
                        fprintf(fid_ZeroOrder,'\n');
                        
                        fprintf(fid_FirstOrder,'1\t');
                        fprintf(fid_FirstOrder,'%d:%f\t', ...
                            [FirstOrderFeatureRange;FirstOrderFeature]);
                        fprintf(fid_FirstOrder,'\n');
                        
                        fprintf(fid_SecondOrder,'1\t');
                        fprintf(fid_SecondOrder,'%d:%f\t', ...
                            [SecondOrderFeatureRange;SecondOrderFeature]);
                        fprintf(fid_SecondOrder,'\n');
                    end
                end
            end
        end
    end
    %-%-%-%-%
    % OVER  %
    %-%-%-%-%
    
    fprintf('Negative Sample #:%d\n',negative_key_count);
    fprintf('Positive Sample #:%d\n',positive_key_count);
    fclose(fid_ZeroOrder);
    fclose(fid_FirstOrder);
    fclose(fid_SecondOrder);
    fclose(fid_Location);
    fclose(fid_Label);
    
    Test_ZeroOrder{MRI_n} = Test_ZeroOrder_name;
    Test_FirstOrder{MRI_n} = Test_FirstOrder_name;
    Test_SecondOrder{MRI_n} = Test_SecondOrder_name;
    Test_Location{MRI_n} = Location_name;
end
fprintf('Test Data is Complete\n\n');