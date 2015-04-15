function ALD_Tools = tbx_cfg_AutoLesionDetectioin_Tool
% Configuration file for toolbox 'AutoLesionDetection'

% Dazhou Guo
% $Id: tbx_cfg_AutoLesionDetection.m 

if ~isdeployed
	
	[p,nam] = fileparts(fileparts(mfilename('fullpath')));
    nam = fullfile(spm('Dir'),'toolbox',nam);
    if ~exist(nam, 'file') 
        fprintf('Error: please put %s in your SPM toolbox folder\n', mfilename('fullpath'));
    end
    addpath(nam);
	%addpath(fullfile(spm('Dir'),'toolbox','AutoLesionDetection')); 

end
%%
% ---------------------------------------------------------------------
% with/without skull MRI indicator
% ---------------------------------------------------------------------
%%Skull         = cfg_entry;
%%Skull.tag     = 'withskull';
%%Skull.name    = 'With or Without Skull';
%%Skull.help    = {'Input "1" if input MRI contains skull, and "0" otherwise.'};
%%Skull.strtype = 'e';
%%Skull.num     = [1 1];
%%Skull.val	  = {1};
Skull         = cfg_menu;
Skull.tag     = 'withskull';
Skull.name    = 'With skull and scalp';
Skull.val     = {1};
Skull.help    = {'Does this image still include the scalp? Choose true for raw images, false for images where the scalp has been removed (e.g. using FSL BET)'};
Skull.labels  = {
             'Yes'
             'No'
}';
Skull.values  = {1 0};


% ---------------------------------------------------------------------
% Leave-one-out cross validation indicator
% ---------------------------------------------------------------------
LOOCV         = cfg_entry;
LOOCV.tag     = 'leave_one_out';
LOOCV.name    = 'Leave one out cross validation';
LOOCV.help    = {'Input "1" if user wish to perform leave-one-out cross validation',...
    '"0" otherwise.'};
LOOCV.strtype = 'e';
LOOCV.num     = [1 1];
LOOCV.val	  = {1};

% ---------------------------------------------------------------------
% Healthy Control Volumes
% ---------------------------------------------------------------------
HeMRI         = cfg_files;
HeMRI.tag     = 'HealthyMRI';
HeMRI.name    = 'Healthy MRI';
HeMRI.help    = {'Select *.nii healthy control scans.'};
HeMRI.filter  = 'image';
HeMRI.ufilter = '.*';
HeMRI.num     = [1 Inf];

% ---------------------------------------------------------------------
% Averaged and Zsocred Healthy Control Volumes
% ---------------------------------------------------------------------
aHeMRI         = cfg_files;
aHeMRI.tag     = 'AverageHealthyMRI';
aHeMRI.name    = 'Averaged and Zscored Healthy MRI';
aHeMRI.help    = {'Select one *.nii averaged and zscored healthy control scan.'};
aHeMRI.filter  = 'image';
aHeMRI.ufilter = '.*';
aHeMRI.num     = [1 1];
aHeMRI.val{1}     = {fullfile(spm('Dir'),'toolbox','AutoLesionDetection','Templates','Average_T1.nii')}; 

% ---------------------------------------------------------------------
% Averaged and Zsocred Healthy Control Volumes
% ---------------------------------------------------------------------
Model1         = cfg_files;
Model1.tag     = 'Model1';
Model1.name    = 'SVM Model: Zero Order Statistical Feature Model';
Model1.help    = {'Select the zero order statistical feature model.'};
Model1.filter  = '*';
Model1.ufilter = '.*';
Model1.num     = [1 1];

% ---------------------------------------------------------------------
% Averaged and Zsocred Healthy Control Volumes
% ---------------------------------------------------------------------
Model2         = cfg_files;
Model2.tag     = 'Model2';
Model2.name    = 'SVM Model: First Order Statistical Feature Model';
Model2.help    = {'Select the first order statistical feature model.'};
Model2.filter  = '*';
Model2.ufilter = '.*';
Model2.num     = [1 1];

% ---------------------------------------------------------------------
% Averaged and Zsocred Healthy Control Volumes
% ---------------------------------------------------------------------
Model3         = cfg_files;
Model3.tag     = 'Model3';
Model3.name    = 'SVM Model: Second Order Statistical Feature Model';
Model3.help    = {'Select the second order statistical feature model.'};
Model3.filter  = '*';
Model3.ufilter = '.*';
Model3.num     = [1 1];

% ---------------------------------------------------------------------
% Pathological Volumes
% ---------------------------------------------------------------------
PaMRI         = cfg_files;
PaMRI.tag     = 'PaMap';
PaMRI.name    = 'Patient MRI';
PaMRI.help    = {'Select *.nii patient scans.'};
PaMRI.filter = 'image';
PaMRI.ufilter = '.*';
PaMRI.num     = [1 Inf];

% ---------------------------------------------------------------------
% Lesion Volumes
% ---------------------------------------------------------------------
GLeMRI         = cfg_files;
GLeMRI.tag     = 'GLeMap';
GLeMRI.name    = 'Ground Truth Lesion Map';
GLeMRI.help    = {'Select *.nii ground truth binary lesion scans.'};
GLeMRI.filter = 'image';
GLeMRI.ufilter = '.*';
GLeMRI.num     = [1 Inf];


%%

% ---------------------------------------------------------------------
% Model Train 
% ---------------------------------------------------------------------
ModelTrain 	       = cfg_exbranch;
ModelTrain.tag     = 'ModelTrain';
ModelTrain.name    = 'Automated Lesion Detection Model Training';
ModelTrain.val     = {PaMRI GLeMRI aHeMRI Skull LOOCV};
ModelTrain.help    = {'This procedure is designed for training the automated lesion detection model.'...
    'Please select the corresponding T1-MRIs, ground truth binary lesion maps for training.',...
    'By default, all input T1-MRIs are assumed to contain skull.'};
ModelTrain.prog    = @RUN_ModelTraining;

% ---------------------------------------------------------------------
% Model Test
% ---------------------------------------------------------------------
ModelTest 	       = cfg_exbranch;
ModelTest.tag     = 'ModelTest';
ModelTest.name    = 'Automated Lesion Detection Model Testing';
ModelTest.val     = {PaMRI Model1 Model2 Model3 aHeMRI Skull};
ModelTest.help    = {'This procedure is designed for testing the automated lesion detection model.'...
    'Please select the corresponding T1-MRIs.',...
    'By default, all input T1-MRIs are assumed to contain skull.'};
ModelTest.prog    = @RUN_ModelTesting;

% ---------------------------------------------------------------------
% Healthy Average T1 
% ---------------------------------------------------------------------
HealthyAverageT1         = cfg_exbranch;
HealthyAverageT1.tag     = 'AverageT1';
HealthyAverageT1.name    = 'Generate Averaged & Zscored Healthy Control MRI';
HealthyAverageT1.val     = {HeMRI Skull};
HealthyAverageT1.help    = {'This procedure is designed for generating an averaged and zscored healthy control MRI'};
HealthyAverageT1.prog    = @RUN_GenerateAverageMRI;


%%
% ---------------------------------------------------------------------
% Automated Lesion Detection
% ---------------------------------------------------------------------
ALD_Tools         = cfg_choice;
ALD_Tools.tag     = 'AutoLesionDetection';
ALD_Tools.name    = 'AutoLesionDetection';
ALD_Tools.help    = {'Toolbox that aids in automatically segmenting brain lesion in T1-weighted MR image(s)'};
ALD_Tools.values  = {HealthyAverageT1 ModelTrain ModelTest};

%======================================================================
function RUN_ModelTraining(job)
ALD_ModelTraining(job);

function RUN_ModelTesting(job)
ALD_ModelTesting(job);

function RUN_GenerateAverageMRI(job)
ALD_GenerateAverageMRI(job);
