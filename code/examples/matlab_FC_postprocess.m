function matlab_FC_postprocess(input_options)
    
    % Get options
    % -----------
    preproc_dir = input_options.preproc_dir;
    target_dir  = input_options.target_dir;
    atlCond     = input_options.atlCond;
    atlList     = input_options.atlList;
    atlListCpt  = input_options.atlListCpt;
    filtCond    = input_options.filtCond;
    
    numVols     = input_options.numVols;
    TR          = input_options.TR;
    
    grp         = input_options.grp;
    sbj         = input_options.sbj;
    
    % START
    % =====================================================================
    fprintf('  -+- EPI post processing %s-%s\n',grp,sbj);
    tic
    
    % Check the target dir
    % --------------------
    if ~isfolder(fullfile(target_dir))
        unix(sprintf('mkdir -p %s',fullfile(target_dir)));
    end
    
    % Read EPI and 5 atlases
    % ---------------------------------------------------------------------
    fprintf('  [0] Read a detrended EPI and atlas images ... ')
    nii_epi = load_untouch_nii(fullfile(preproc_dir,sbj,'epi_sm_upsample_detrend.nii.gz'));
    nii_sch = load_untouch_nii(fullfile(preproc_dir,sbj,'Schaefer2018_100Parcels_17Networks_to_epi_upsample_native+subctx.nii.gz'));
    nii_dk  = load_untouch_nii(fullfile(preproc_dir,sbj,'DesikanKilliany_68Parcels_to_epi_upsample_native+subctx.nii.gz'));
    nii_kst = load_untouch_nii(fullfile(preproc_dir,sbj,'Kleist_98Parcels_to_epi_upsample_native+subctx.nii.gz'));
    nii_sth = load_untouch_nii(fullfile(preproc_dir,sbj,'Smith_88Parcels_to_epi_upsample_native+subctx.nii.gz'));
    nii_ho  = load_untouch_nii(fullfile(preproc_dir,sbj,'HarvardOxford_96Parcels_to_epi_upsample_native+subctx.nii.gz'));
    nii_sch200 = load_untouch_nii(fullfile(preproc_dir,sbj,'Schaefer2018_200Parcels_17Networks_to_epi_upsample_native+subctx.nii.gz'));
    fprintf('done.\n')
    
    % Take labeled voxels
    % ---------------------------------------------------------------------
    lgc_label = nii_sch.img > 0 | nii_dk.img > 0 | nii_kst.img > 0 | nii_sth.img > 0 | nii_ho.img > 0 | nii_sch200.img > 0;
    label_vec_sch = nii_sch.img(lgc_label);
    label_vec_dk  = nii_dk.img(lgc_label);
    label_vec_kst = nii_kst.img(lgc_label);
    label_vec_sth = nii_sth.img(lgc_label);
    label_vec_ho  = nii_ho.img(lgc_label);
    label_vec_sch200 = nii_sch200.img(lgc_label);

    numVox = sum(lgc_label(:));
    Y = nan(numVols,numVox);
    for nVol = 1:numVols
        temp_vol = squeeze(nii_epi.img(:,:,:,nVol));
        Y(nVol,:) = temp_vol(lgc_label);
    end
    
    % Nuisance regression
    % ---------------------------------------------------------------------
    fprintf('  [1] Nuisance regression ... ')
    glm_fn = fullfile(preproc_dir,sbj,'epi_sm_upsample_detrend_glm_wb_csf_global_Friston24.nii.gz');
    if isfile(glm_fn)
        
        % Read corrected values
        % ---------------------
        nii_epi_glm = load_untouch_nii(glm_fn);
        yRes = nan(numVols,numVox);
        for nVol = 1:numVols
            temp_vol = squeeze(nii_epi_glm.img(:,:,:,nVol));
            yRes(nVol,:) = temp_vol(lgc_label);
        end
        clear temp_vol nVol
        fprintf('checked!\n')
    else
        
        % Read regressors
        % ---------------
        regressor_Friston24 = dlmread(fullfile(preproc_dir,sbj,'Friston-24.txt'));
        regressor_wm        = dlmread(fullfile(preproc_dir,sbj,'regressor_wm.txt'));
        regressor_csf       = dlmread(fullfile(preproc_dir,sbj,'regressor_csf.txt'));
        regressor_global    = dlmread(fullfile(preproc_dir,sbj,'regressor_global.txt'));
        regressors          = [regressor_wm,regressor_csf,regressor_global,regressor_Friston24];
        regressors          = (regressors - repmat(mean(regressors,1),numVols,1)) ./ repmat(std(regressors,[],1),numVols,1);
        
        % Linear nuisance regression
        % --------------------------
        % yHat = X(:,2:end) * B(2:end,:) + repmat(B(1,:),numVols,1);
        X = [ones(numVols,1),regressors];
        B = (X' * X) \ X' * Y;
        yHat = X(:,2:end) * B(2:end,:);
        yRes = Y - yHat;
        
        % Update EPI voxels with corrected ones
        % -------------------------------------
        nii_epi_glm = nii_epi;
        for nVol = 1:numVols
            temp_vol = squeeze(nii_epi_glm.img(:,:,:,nVol));
            temp_vol(lgc_label) = yRes(nVol,:);
            nii_epi_glm.img(:,:,:,nVol) = temp_vol;
        end
        save_untouch_nii(nii_epi_glm,glm_fn);
        fprintf('has been saved as epi_sm_upsample_detrend_glm_wb_csf_global_Friston24.nii.gz.\n')
        fprintf('done.\n')
    end
    
    % No-centering
    % ------------
    yRes_notf = yRes;
    
    % Perform signal filtering by Matlab
    % ---------------------------------------------------------------------
    fprintf('  [2] Bandpass ([0.01,0.10] Hz) filtering by Matlab.\n')
    yRes_bptf_mat = bandpass(yRes_notf,[0.01,0.10],1/TR);
    fprintf('  [3] Bandpass ([0.01,0.05] Hz) filtering by Matlab.\n')
    yRes_l_bptf_mat = bandpass(yRes_notf,[0.01,0.05],1/TR);
    fprintf('  [4] Bandpass ([0.05,0.10] Hz) filtering by Matlab.\n')
    yRes_h_bptf_mat = bandpass(yRes_notf,[0.05,0.10],1/TR);
    
    % BOLD extraction
    % ---------------------------------------------------------------------
    %    PROOF OF EXPLAINED VARIANCE AS R-SQUARE OF PEARSON CORRELATION
    % ---------------------------------------------------------------------
    % temp_X = temp_mean_y(:,temp_lgc);
    % temp_Y = temp_yRes(:,temp_lgc);
    % nVoxel = 31211;
    %
    % y = temp_Y(:,nVoxel);
    % x = [ones(300,1),temp_X(:,nVoxel)];
    % b = (x' * x) \ x' * y;
    % r = y - x*b;
    % tss = sum((y - mean(y)).^2);
    % rss = sum(r.^2);
    % rsquare = (1 - rss / tss) * 100;
    % fprintf('\n  + R^2 = %0.4f\n',rsquare)
    %
    % c = corrcoef(temp_X(:,nVoxel),temp_Y(:,nVoxel));
    % c = c(1,2)^2 * 100;
    % fprintf('  + R^2 = %0.4f\n',c)
    %
    % x = temp_X(:,nVoxel);
    % y = temp_Y(:,nVoxel);
    % c = mean((x - mean(x)).*(y - mean(y))) / (std(x,1)*std(y,1));
    % c = c^2 * 100;
    % fprintf('  + R^2 = %0.4f\n',c)
    % ---------------------------------------------------------------------
    fprintf('  [5] BOLD extraction (mean and 1st eigenvariate).\n')
    for nAtl = 1:numel(atlCond)
        atl = atlCond{nAtl};
        fprintf('      Atlas: %s ... ',atlList{nAtl})
        eval(sprintf('temp_l = label_vec_%s;',atl));
        temp_N    = max(temp_l);
        for nFilt = 1:numel(filtCond)
            flt = filtCond{nFilt};
            temp_mean_bold = nan(numVols,temp_N);
            temp_eig1_bold = nan(numVols,temp_N);
            temp_mean_y = nan(size(yRes));
            temp_eig1_y = nan(size(yRes));
            eval(sprintf('temp_yRes = yRes_%s;',flt));
            for nLabel = 1:temp_N
                temp_lgc = temp_l == nLabel;
                temp_vec = temp_yRes(:,temp_lgc);
                
                % PCA
                % ---
                [COEFF,SCORE,LATENT] = pca(temp_vec);
                
                % BOLD
                % ----
                temp_mean_bold(:,nLabel) = mean(temp_vec,2);
                temp_eig1_bold(:,nLabel) = SCORE(:,1) * mean(COEFF(:,1));
                
                % Vector for EV
                % -------------
                temp_mean_y(:,temp_lgc) = repmat(mean(temp_vec,2),1,sum(temp_lgc));
                temp_eig1_y(:,temp_lgc) = repmat(SCORE(:,1),1,sum(temp_lgc));
                % temp_eig1_y(:,temp_lgc) = SCORE(:,1) * repmat(mean(COEFF(:,1)),1,size(temp_vec,2));
            end
            eval(sprintf('yRes_%s_%s_mean = temp_mean_y;',flt,atl));
            
            % Z-scoring
            % ---------
            % temp_mean_y = (temp_mean_y - repmat(mean(temp_mean_y,1),numVols,1)) ./ repmat(std(temp_mean_y,[],1),numVols,1);
            % temp_eig1_y = (temp_eig1_y - repmat(mean(temp_eig1_y,1),numVols,1)) ./ repmat(std(temp_eig1_y,[],1),numVols,1);
            
            % Write BOLD
            % ----------
            dlmwrite(fullfile(target_dir,sprintf('%s_postproc_%s_%s_mean_BOLD.csv',sbj,flt,atlListCpt{nAtl})),temp_mean_bold,'delimiter',',');
            dlmwrite(fullfile(target_dir,sprintf('%s_postproc_%s_%s_eig1_BOLD.csv',sbj,flt,atlListCpt{nAtl})),temp_eig1_bold,'delimiter',',');
            
            % Take the filtered signals
            % -------------------------
            temp_lgc = temp_l > 0;
            temp_Y = temp_yRes(:,temp_lgc);
            
            % Calculate R and R-square x 100 for the mean BOLD
            % ------------------------------------------------
            temp_ev = zeros(size(temp_l));
            temp_X = temp_mean_y(:,temp_lgc);
            temp_R = mean((temp_X - repmat(mean(temp_X,1),numVols,1)) .* (temp_Y - repmat(mean(temp_Y,1),numVols,1)),1) ./ (std(temp_X,1,1) .* std(temp_Y,1,1));
            temp_ev(temp_lgc) = (temp_R .^ 2)' * 100;
            eval(sprintf('ev_voxel_%s_%s_mean = temp_ev;',flt,atl));
            
            % Save an ExpVar map for the mean BOLD
            % ------------------------------------
            eval(sprintf('temp_nii = nii_%s;',atl))
            temp_nii.img = temp_nii.img * 0;
            temp_nii.img(lgc_label) = temp_ev;
            save_untouch_nii(temp_nii,fullfile(target_dir,sprintf('%s_postproc_rsquare_%s_%s_mean_voxel.nii.gz',sbj,flt,atlListCpt{nAtl})));
            
            % Calculate R and R-square x 100 for the 1st eigenvariate
            % -------------------------------------------------------
            temp_ev = zeros(size(temp_l));
            temp_X = temp_eig1_y(:,temp_lgc);
            temp_R = mean((temp_X - repmat(mean(temp_X,1),numVols,1)) .* (temp_Y - repmat(mean(temp_Y,1),numVols,1)),1) ./ (std(temp_X,1,1) .* std(temp_Y,1,1));
            temp_ev(temp_lgc) = (temp_R .^ 2)' * 100;
            eval(sprintf('ev_voxel_%s_%s_eig1 = temp_ev;',flt,atl));
            
            % Save an ExpVar map for the 1st eigenvariate
            % -------------------------------------------
            eval(sprintf('temp_nii = nii_%s;',atl))
            temp_nii.img = temp_nii.img * 0;
            temp_nii.img(lgc_label) = temp_ev;
            save_untouch_nii(temp_nii,fullfile(target_dir,sprintf('%s_postproc_rsquare_%s_%s_eig1_voxel.nii.gz',sbj,flt,atlListCpt{nAtl})));
            
        end
        fprintf('done.\n')
    end
    fprintf('  [v] ');toc
    clear temp_*
    fprintf('  -+- Done.\n')
end