clear
clc

% Subject IDs in BIDS
% -------------------
sbjList  = {'ID_0001','ID_0002'};

% Set input options
% -----------------
input_options.preproc_dir   = '/preprocessed/fmri/path';    % Directory contains 'epi_sm_upsample_detrend.nii.gz' file by 'container_FC_preprocess.sh'
input_options.target_dir    = '/postproceesed/fmri/path';
input_options.atlCond       = {'sch','ho','kst','dk','sth'};
input_options.atlList       = {'Schaefer2018_100Parcels_17Networks','HarvardOxford_96Parcels','Kleist_98Parcels','DesikanKilliany_68Parcels','Smith_88Parcels'};
input_options.atlListCpt    = {'Sch100P','HvOx96P','Klst98P','DK68P','Smith88P'};
input_options.filtCond      = {'notf','bptf_mat','l_bptf_mat','h_bptf_mat'};
input_options.grp           = 'Group_Name';
input_options.numVols       = 300;  % No. EPI volumes
input_options.TR            = 2.21; % Repetition time of EPI in seconds

% Run post process
% ----------------
for nSbj = 1:numel(sbjList)
    sbj = sbjList{nSbj};
    input_options.sbj = sbj;
    matlab_FC_postprocess(input_options);
end