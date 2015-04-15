function CleanMRIs = Final_CleanUp(Merged_MRIs, NormV)

Merge_MRIs = char(Merged_MRIs);
NormV = char(NormV);
BrainMask_MRI_filename = fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','BrainMask.nii');
BrainMask = spm_vol(BrainMask_MRI_filename);
BrainMask_V = spm_read_vols(BrainMask);

CleanMRIs = cell(size(Merged_MRIs,1),1);

for n = 1:size(Merged_MRIs,1)
    MRI_filename = Merge_MRIs(n,:);
    MRI_filename = deblank(MRI_filename);    

    V_filename = NormV(n,:);
    
    
    [pth,nam,~] = fileparts(MRI_filename);

    MRI = spm_vol(MRI_filename);
    MRI_V = spm_read_vols(MRI);
    
    V_MRI = spm_vol(V_filename);
    V_MRI_V = spm_read_vols(V_MRI);
    
    MRI_V = MRI_V .* BrainMask_V;
    MRI_V = MRI_V .* (1-V_MRI_V);
    max_value = max(MRI_V(:));

    lower_bound = 0.90*max_value;
    upper_bound = max_value;
    V_potential = zeros(size(MRI_V));
    [d1,d2,d3] = size(MRI_V);

    firstIndex = d1*d2*d3;
    Q = MakeStack(firstIndex);

    tic
    for i = 1:d1
        for j = 1:d2
            for k = 1:d3
                if MRI_V(i,j,k) <= upper_bound && MRI_V(i,j,k) >= lower_bound
                    checkElement = [i,j,k];
                    [firstIndex,Q] = EnStack(Q,checkElement,firstIndex);
                    V_potential(i,j,k) = MRI_V(i,j,k);
                end
            end
        end
    end
    toc
    fprintf('Now, done with writing potential nii file\n');

    colorMap = zeros(d1,d2,d3);
    outMRI = zeros(d1,d2,d3);
    Diff_lowerbound = 0.3*max_value;
    tic
    while (firstIndex ~= d1*d2*d3)
        [outElement,Q,firstIndex] = DeStack(Q,firstIndex);

        for i = -1:1
            for j = -1:1
                for k = -1:1
                    checkElement = [outElement(1)+i,outElement(2)+j,outElement(3)+k];
                    checkTag = checkBoundary(checkElement,MRI_V);
                    if checkTag == 1
                        if MRI_V(checkElement(1),checkElement(2),checkElement(3)) > Diff_lowerbound ...
                                && colorMap(checkElement(1),checkElement(2),checkElement(3)) == 0
                            colorMap(checkElement(1),checkElement(2),checkElement(3)) = 1;
                            outMRI(checkElement(1),checkElement(2),checkElement(3)) = ...
                                MRI_V(checkElement(1),checkElement(2),checkElement(3));
                            [firstIndex,Q] = EnStack(Q,checkElement,firstIndex);
                        end
                    end
                end
            end
        end
    end
    toc
    MRI.fname = fullfile(pth, [nam,'_Clean.nii']);
    spm_write_vol(MRI,outMRI);
    CleanMRIs{n} = MRI.fname;
    fprintf('%s is done\n',nam);
end
fprintf('All Finished\n\n');

function [outElement,Q,firstIndex] = DeStack(Q,firstIndex)
if isnan(firstIndex)
    firstIndex = NaN;
else
    firstIndex = firstIndex + 1;
    if ~isempty(Q{firstIndex})
        outElement = Q{firstIndex};
        Q{firstIndex} = [];
    else
        outElement = NaN;
        firstIndex = NaN;
    end
end
    
function [firstIndex,Q] = EnStack(Q,inElement,firstIndex)
%firstIndex = firstIndex - 1;
if firstIndex >= 1
    if isempty(Q{firstIndex})
    	Q{firstIndex} = inElement;
        firstIndex = firstIndex - 1;
	else
        fprintf('Place Taken\n');
        firstIndex = NaN;
    end
else
    fprintf('OverFlow\n');
    firstIndex = NaN;
end

function Q = MakeStack(QueueSize)

Q = cell(QueueSize,1);

function check_tag = checkBoundary(Input,I)
if Input(1) >= 1 && Input(1) <= size(I,1)
    check_tag_1 = 1;
else
    check_tag_1 = 0;
end
if Input(2) >= 1 && Input(2) <= size(I,2)
    check_tag_2 = 1;
else
    check_tag_2 = 0;
end
if Input(3) >= 1 && Input(3) <= size(I,3)
    check_tag_3 = 1;
else
    check_tag_3 = 0;
end
check_tag = check_tag_1*check_tag_2*check_tag_3;