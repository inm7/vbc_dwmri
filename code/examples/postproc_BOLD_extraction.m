clear
clc

% FSL ships with several MATLAB scripts for loading NIFTI files
% -------------------------------------------------------------
% setenv('FSLDIR','/usr/share/fsl/5.0');
% setenv('FSLOUTPUTTYPE','NIFTI_GZ')
% fsldir      = getenv('FSLDIR');
% fsldirmpath = sprintf('%s/etc/matlab',fsldir);
% path(path,fsldirmpath);
% curpath     = getenv('PATH');
% setenv('PATH',sprintf('%s:%s',fullfile(fsldir,'bin'),curpath));
% clear fsldir fsldirmpath curpath

% 116 subjects
% ------------
sbjList  = {'PD_020130404','PD_020130418','PD_020130429','PD_020130502','PD_020130527','PD_020130613','PD_020130706','PD_10121125','PD_10140513','PD_10140520','PD_10140526','PD_10140527','PD_10141110','PD_10141117','PD_10141124','PD_10141208','PD_10141216','PD_10150105','PD_10150113','PD_10150119','PD_10150126','PD_10150223','PD_10150302','PD_10150309','PD_10150316','PD_10150323','PD_10150413','PD_10150420','PD_10150601','PD_10150615','PD_10150713','PD_10150727','PD_10150810','PD_10150824','PD_11140513','PD_11140526','PD_11140527','PD_11141216','PD_20111111','PD_20111128','PD_20111208','PD_20111212','PD_20120105','PD_20120109','PD_20120126','PD_20120312','PD_20120315','PD_20120326','PD_20120423','PD_20120426','PD_20120503','PD_20120510','PD_20120531','PD_20120618','PD_20120625','PD_20120712','PD_20120820','PD_20120822','PD_20120905','PD_20120910','PD_20120924','PD_20121001','PD_20121029','PD_20130121','PD_20130307','PD_20130318','PD_20130328','PD_20130408','PD_20130411','PD_20130415','PD_20130425','PD_20130506','PD_20130624','PD_20130701','PD_20130708','PD_20130819','PD_20130826','PD_20140113','PD_20140116','PD_20140203','PD_20140220','PD_20140224','PD_20140331','PD_20140407','PD_20140722','PD_20140728','PD_20140804','PD_20140811','PD_20140825','PD_20140918','PD_20141110','PD_20141114','PD_20141117','PD_20141120','PD_20150108','PD_20150115','PD_20150116','PD_20150120','PD_20150306','PD_20150312','PD_20150316','PD_20150522','PD_20150610','PD_20150804','PD_20150910','PD_30150113','PD_30150119','PD_30150302','PD_30150309','PD_30150316','PD_30150323','PD_30150413','PD_30150601','PD_30150810','PD_40150113','PD_40150119'};
ageList  = [42,55,46,42,62,53,70,62,58,44,60,45,41,51,46,78,63,47,71,51,56,76,55,60,54,41,49,59,68,44,70,65,43,41,56,52,63,62,61,50,57,60,71,68,72,73,76,61,71,66,57,63,53,73,62,72,68,58,72,70,65,49,59,75,39,52,72,53,51,80,55,52,71,53,69,45,71,65,67,70,44,62,60,71,45,72,64,59,71,78,60,63,52,59,57,51,76,62,51,54,64,44,66,62,48,48,51,41,69,61,52,56,49,44,62,60];
Ma1_Fe2  = [2,2,2,2,2,1,2,2,1,2,1,1,1,2,1,1,2,1,1,1,2,2,1,2,2,1,1,2,2,1,1,2,2,1,1,1,1,1,1,1,1,2,1,2,1,1,1,1,1,1,1,1,1,1,1,2,2,2,1,1,2,2,2,2,1,1,1,2,1,1,2,1,1,2,1,1,1,1,1,2,1,2,1,1,1,1,1,1,1,2,1,2,1,2,2,1,1,1,1,1,1,2,1,1,2,1,2,1,1,1,1,2,1,1,2,1];
HC0_PD1  = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0];
finalQC  = [0 1 1 1 1 1 1 0 0 1 1 1 1 0 0 0 1 1 0 0 1 0 1 1 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 1 1 1 0 0 0 1 1 1 0 1 1 0 1 1 1 0 1 1 1 1 1 1 1 1 1 0 1 1 1 0 1 0 1 0 1 0 1 1 0 1 0 0 1 0 0 0 1 1 1 0 1 1 1 0 1 0 1 0 0 0 1 0 1 1 0 1 1 1 1 0 1 1 1 1 0 1];
cullDWI  = [1 0 0 0 0 0 0 1 1 0 0 0 0 1 1 1 0 0 1 1 0 1 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 0 0 0 1 1 1 0 0 0 1 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 1 0 1 0 1 0 1 0 0 1 0 1 1 0 1 1 1 0 0 0 1 0 0 0 1 0 1 0 1 1 1 0 1 0 0 1 0 0 0 0 1 0 0 0 0 1 0];
numSbj  = length(sbjList);

atlList = {'Schaefer2018_100Parcels_17Networks','HarvardOxford_96Parcels','Kleist_98Parcels','DesikanKilliany_68Parcels','Smith_88Parcels'};
atlListCpt = {'Sch100P','HvOx96P','Klst98P','DK68P','Smith88P'};

% Juseless setup
% --------------
% preproc_pp = '/data/project/personalized_pipeline/03_Functional_Connectivity/PD_HHU_by_KJung';
% target_dir = '/data/project/personalized_pipeline/03_Functional_Connectivity/Post_Proc_PD_HHU';

% Local (kyesamjung) setup
% ------------------------
preproc_pp = '/Volumes/KJung_2TB_TM/Data-FZJ/Functional_Connectivity/Post_Proc_PD_HHU/personal';
target_dir = '/Volumes/KJung_2TB_TM/Data-FZJ/Functional_Connectivity/Post_Proc_PD_HHU/postproc';

temp_dir   = fullfile(target_dir,'bptf');
if ~isfolder(temp_dir)
    unix(sprintf('mkdir -p %s',temp_dir));
end

boldCond = {'mean','eig1','eig2'};
filtCond = {'prefilter','FSL_filter','Matlab_filter'};

numVols = 300;
TR = 2.21;

% Band-pass filtering [0.01,0.1]
% Highpass sigma = 22.62443438914027149321, lowpass sigma = 2.26244343891402714932
HPS = '22.62443438914027149321';
LPS = '2.26244343891402714932';

for nSbj = 73:100 % 53:72 % 45:52 %37:44 %33:36 %25:32 %17:24 %13:16
    tic
    sbj = sbjList{nSbj};
    
    % Local
    % -----
    detrend_pp = fullfile(preproc_pp,sbj,'epi_sm_upsample_detrend.nii.gz');
    prefilt_pp = fullfile(preproc_pp,sbj,'prefiltered_func_data.nii.gz');
    
    nCond = 0;
    
    % 3 filtering conditions
    % ----------------------
    for nFilt = 1:numel(filtCond)
        fprintf('--+ Filtering condition: %s\n',filtCond{nFilt})
        
        if nFilt == 1 % <------------------------------------------------- Prefiltering
            nii_epi_pp = load_untouch_nii(prefilt_pp);
        
        elseif nFilt == 2 % <--------------------------------------------- Filtering by FSL
            if ~isfile(sprintf('%s%s%s_epi_pp_bptf.nii.gz',temp_dir,filesep,sbj))
                cmd = sprintf('fslmaths %s -bptf %s %s %s%s%s_epi_pp_bptf.nii.gz',prefilt_pp,HPS,LPS,temp_dir,filesep,sbj);
                unix(cmd);
            end
            nii_epi_pp = load_untouch_nii(fullfile(temp_dir,sprintf('%s_epi_pp_bptf.nii.gz',sbj)));
        
        elseif nFilt == 3 % <--------------------------------------------- Filtering by Matlab
            nii_epi_pp = load_untouch_nii(prefilt_pp);
        end
        
        % 5 atlases
        % ---------
        for nAtl = 1:numel(atlList)
            nii_atl_pp = load_untouch_nii(fullfile(preproc_pp,sbj,sprintf('%s_to_epi_upsample_native+subctx.nii.gz',atlList{nAtl})));
            num = max(nii_atl_pp.img(:));
            
            bold_pp_mean = nan(numVols,num);
            bold_pp_eig1 = nan(numVols,num);
            bold_pp_eig2 = nan(numVols,num);
            
            EV_pp_mean = nan(num,2);
            EV_pp_eig1 = nan(num,2);
            EV_pp_eig2 = nan(num,2);
            
            % Mean BOLD
            % ---------
            
            
            % BOLD extraction (mean, eig1, and eig2)
            % --------------------------------------
            nCond = nCond + 1;
            fprintf(' -+ BOLD extractions: mean, eig1 and eig2\n')
            fprintf('  + Condition %i: mean, eig1 and eig2 BOLD %s for %s\n',nCond,filtCond{nFilt},atlList{nAtl})
            img_pp_mean = single(zeros(size(nii_atl_pp.img)));
            img_pp_eig1 = single(zeros(size(nii_atl_pp.img)));
            img_pp_eig2 = single(zeros(size(nii_atl_pp.img)));
            for n = 1:num

                % Personalized functional pipeline
                % --------------------------------
                lgc_label = nii_atl_pp.img == n;
                numVox = sum(lgc_label(:));
                if numVox > 1
                    vec = nii_epi_pp.img(repmat(lgc_label,1,1,1,numVols));
                    vec = reshape(vec,[sum(lgc_label(:)),numVols]);
                    if nFilt == 3
                        X = bandpass(vec',[0.01,0.10],1/TR);
                    else
                        X = vec';
                    end
                    fprintf('  + [personal %s (%i)] BOLD extractions for node %i (%i voxels) ... ',sbj,nSbj,n,numVox)
                    X = zscore(X,0,1);
                    
                    % Mean BOLD
                    % ---------
                    EV0_all = nan(size(X,2),1);
                    y_mean = mean(X,2);
                    for k = 1:size(X,2)
                        r = X(:,k) - y_mean;
                        PSS = sum(sum(y_mean.^2));
                        RSS = sum(sum(r.^2));
                        EV0_all(k,1) = 100*PSS/(PSS + RSS);
                    end
                    fprintf('EV (mean) = %0.4f, S.D. = %0.4f ... ',mean(EV0_all),std(EV0_all))
                    
                    % PCA
                    % ---
                    [COEFF,SCORE,LATENT] = pca(X);
                    
                    EV1_all = nan(size(X,2),1);
                    for k = 1:size(X,2)
                        y = SCORE(:,1)*COEFF(k,1);
                        r = X(:,k) - y;
                        PSS = sum(sum(y.^2));
                        RSS = sum(sum(r.^2));
                        EV1_all(k,1) = 100*PSS/(PSS + RSS);
                    end
                    
                    EV2_all = nan(size(X,2),1);
                    for k = 1:size(X,2)
                        y = SCORE(:,2)*COEFF(k,2);
                        r = X(:,k) - y;
                        PSS = sum(sum(y.^2));
                        RSS = sum(sum(r.^2));
                        EV2_all(k,1) = 100*PSS/(PSS + RSS);
                    end
                    EV  = LATENT/sum(LATENT) * 100;
                    fprintf('EV(eig1) = %0.4f, EV(eig2) = %0.4f\n',EV(1),EV(2))
                    
                    % EV_all = nan(size(X,2),1);
                    % for k = 1:size(X,2)
                    %     y = SCORE(:,1)*COEFF(k,1) + SCORE(:,2)*COEFF(k,2);
                    %     r = X(:,k) - y;
                    %     PSS = sum(sum(y.^2));
                    %     RSS = sum(sum(r.^2));
                    %     EV_all(k,1) = 100*PSS/(PSS + RSS);
                    % end
                    % mean(EV_all)
                    
                    img_pp_mean(lgc_label) = EV0_all;
                    img_pp_eig1(lgc_label) = EV1_all;
                    img_pp_eig2(lgc_label) = EV2_all;
                    
                    bold_pp_mean(:,n) = zscore(y_mean,0,1);
                    bold_pp_eig1(:,n) = zscore(SCORE(:,1),0,1);
                    bold_pp_eig2(:,n) = zscore(SCORE(:,2),0,1);
                    
                    EV_pp_mean(n,:) = [mean(EV0_all),numVox];
                    EV_pp_eig1(n,:) = [mean(EV1_all),numVox];
                    EV_pp_eig2(n,:) = [mean(EV2_all),numVox];
                elseif numVox == 1
                    vec = nii_epi_pp.img(repmat(lgc_label,1,1,1,numVols));
                    fprintf('  + [personal %s (%i)] BOLD extractions for node %i (%i voxels) !!!\n ',sbj,nSbj,n,numVox)
                    X = vec;
                    X = zscore(X,0,1);
                    img_pp_mean(lgc_label) = 100;
                    img_pp_eig1(lgc_label) = 100;
                    img_pp_eig2(lgc_label) = 100;
                    
                    bold_pp_mean(:,n) = X;
                    bold_pp_eig1(:,n) = X;
                    bold_pp_eig2(:,n) = X;
                    
                    EV_pp_mean(n,:) = [100,numVox];
                    EV_pp_eig1(n,:) = [100,numVox];
                    EV_pp_eig2(n,:) = [100,numVox];
                else
                    fprintf('  + [personal %s (%i)] BOLD extractions for node %i (%i voxels) ... ',sbj,nSbj,n,numVox)
                    error('----No voxels!!');
                end
            end
            
            nii_pp_mean = nii_atl_pp;
            nii_pp_eig1 = nii_atl_pp;
            nii_pp_eig2 = nii_atl_pp;
            
            nii_pp_mean.img = img_pp_mean;
            nii_pp_eig1.img = img_pp_eig1;
            nii_pp_eig2.img = img_pp_eig2;

            save_untouch_nii(nii_pp_mean,fullfile(target_dir,sprintf('%s_personal_%s_%s_mean_EVmap.nii.gz',sbj,filtCond{nFilt},atlListCpt{nAtl})));
            save_untouch_nii(nii_pp_eig1,fullfile(target_dir,sprintf('%s_personal_%s_%s_eig1_EVmap.nii.gz',sbj,filtCond{nFilt},atlListCpt{nAtl})));
            save_untouch_nii(nii_pp_eig2,fullfile(target_dir,sprintf('%s_personal_%s_%s_eig2_EVmap.nii.gz',sbj,filtCond{nFilt},atlListCpt{nAtl}))); 
            
            dlmwrite(fullfile(target_dir,sprintf('%s_personal_%s_%s_mean_BOLD.csv',sbj,filtCond{nFilt},atlListCpt{nAtl})),bold_pp_mean,'delimiter',',');
            dlmwrite(fullfile(target_dir,sprintf('%s_personal_%s_%s_eig1_BOLD.csv',sbj,filtCond{nFilt},atlListCpt{nAtl})),bold_pp_eig1,'delimiter',',');
            dlmwrite(fullfile(target_dir,sprintf('%s_personal_%s_%s_eig2_BOLD.csv',sbj,filtCond{nFilt},atlListCpt{nAtl})),bold_pp_eig2,'delimiter',',');
            
            dlmwrite(fullfile(target_dir,sprintf('%s_personal_%s_%s_mean_regionEV.txt',sbj,filtCond{nFilt},atlListCpt{nAtl})),EV_pp_mean,'delimiter',' ');
            dlmwrite(fullfile(target_dir,sprintf('%s_personal_%s_%s_eig1_regionEV.txt',sbj,filtCond{nFilt},atlListCpt{nAtl})),EV_pp_eig1,'delimiter',' ');
            dlmwrite(fullfile(target_dir,sprintf('%s_personal_%s_%s_eig2_regionEV.txt',sbj,filtCond{nFilt},atlListCpt{nAtl})),EV_pp_eig2,'delimiter',' ');
        end
    end
    toc
end

fprintf('  + Done.\n')
