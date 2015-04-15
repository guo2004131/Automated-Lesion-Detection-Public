function [predict_1st, predict_2nd, predict_3rd] = SVM_Runner(Test_ZeroOrder,Test_FirstOrder,Test_SecondOrder, SVM_pth, SVM_model)
%%
predict_1st = cell(size(Test_ZeroOrder,1),1);
predict_2nd = cell(size(Test_FirstOrder,1),1);
predict_3rd = cell(size(Test_SecondOrder,1),1);

Test_ZeroOrder = char(Test_ZeroOrder);
Test_FirstOrder = char(Test_FirstOrder);
Test_SecondOrder = char(Test_SecondOrder);

for i = 1:size(Test_ZeroOrder,1)
    First_filename = deblank(Test_ZeroOrder(i,:));
    Second_filename = deblank(Test_FirstOrder(i,:));
    Third_filename = deblank(Test_SecondOrder(i,:));
    
    [pth,nam1,~] = fileparts(First_filename);
    [~,nam2,~] = fileparts(Second_filename);
    [~,nam3,~] = fileparts(Third_filename);
    
    First_predict = fullfile(pth,['First_',nam1]);
    Second_predict = fullfile(pth,['Second_',nam2]);
    Third_predict = fullfile(pth,['Third_',nam3]);
    
    cmd_1st = [fullfile(SVM_pth,'svm_classify'), ' ', First_filename, ' ',...
        SVM_model{1}, ' ', First_predict];
    cmd_2nd = [fullfile(SVM_pth,'svm_classify'), ' ', Second_filename, ' ',...
        SVM_model{2}, ' ', Second_predict];
    cmd_3rd = [fullfile(SVM_pth,'svm_classify'), ' ', Third_filename, ' ',...
        SVM_model{3}, ' ', Third_predict];
    
    unix(cmd_1st);
    unix(cmd_2nd);
    unix(cmd_3rd);
    
    predict_1st{i} = First_predict;
    predict_2nd{i} = Second_predict;
    predict_3rd{i} = Third_predict;
end
fprintf('Prediction is Complete\n\n');