function [Model_1st, Model_2nd, Model_3rd] = SVM_Train(Train_ZeroOrder,Train_FirstOrder,Train_SecondOrder, SVM_pth)
%%  
Model_1st = cell(size(Train_ZeroOrder));
Model_2nd = cell(size(Train_FirstOrder));
Model_3rd = cell(size(Train_SecondOrder));

for i = 1:size(Train_ZeroOrder,1)
    Zero_filename = Train_ZeroOrder{i};
    First_filename = Train_FirstOrder{i};
    Second_filename = Train_SecondOrder{i};
    
    [pth,nam1,~] = fileparts(Zero_filename);
    [~,nam2,~] = fileparts(First_filename);
    [~,nam3,~] = fileparts(Second_filename);
%     key_index = strfind(nam,'_');
%     keywords = nam(key_index(3)+1:key_index(4)-1);
    
    Zero_Model = fullfile(pth,['Model_0_',nam1]);
    First_Model = fullfile(pth,['Model_1_',nam2]);
    Second_Model = fullfile(pth,['Model_2_',nam3]);
    
    cmd_1st = [fullfile(SVM_pth,'svm_learn'), ' ', Zero_filename, ' ',...
        Zero_Model];
    cmd_2nd = [fullfile(SVM_pth,'svm_learn'), ' ', First_filename, ' ',...
        First_Model];
    cmd_3rd = [fullfile(SVM_pth,'svm_learn'), ' ', Second_filename, ' ',...
        Second_Model];
    
    unix(cmd_1st);
    unix(cmd_2nd);
    unix(cmd_3rd);
    
    Model_1st{i} = Zero_Model;
    Model_2nd{i} = First_Model;
    Model_3rd{i} = Second_Model;
end
fprintf('Model training is completed\n\n');