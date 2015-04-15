function Inverse_Normalize(Merged_MRIs, CleanMRIs, InverseMAT)
for i = 1:size(Merged_MRIs,1)
    [pth,~,~] = fileparts(Merged_MRIs{i});
    Normlization = cell(1);
    
    Field_Filename = InverseMAT{i};
    Normlization{1}.spm.util.defs.comp{1}.def = {Field_Filename};
    Normlization{1}.spm.util.defs.ofname = '';
    Normlization{1}.spm.util.defs.fnames = {[Merged_MRIs{i},',1']};
    Normlization{1}.spm.util.defs.savedir.saveusr = {pth};
    Normlization{1}.spm.util.defs.interp = 1;
    spm_jobman('initcfg');
    spm_jobman('run',Normlization);
end

for i = 1:size(CleanMRIs,1)
    [pth,~,~] = fileparts(CleanMRIs{i});
    Normlization = cell(1);
    
    Field_Filename = InverseMAT{i};
    Normlization{1}.spm.util.defs.comp{1}.def = {Field_Filename};
    Normlization{1}.spm.util.defs.ofname = '';
    Normlization{1}.spm.util.defs.fnames = {[CleanMRIs{i},',1']};
    Normlization{1}.spm.util.defs.savedir.saveusr = {pth};
    Normlization{1}.spm.util.defs.interp = 1;
    spm_jobman('initcfg');
    spm_jobman('run',Normlization);
end