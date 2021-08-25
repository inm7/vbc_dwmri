clear
clc

% 116 subjects
% ------------
sbjList  = {'PD_020130404','PD_020130418','PD_020130429','PD_020130502','PD_020130527','PD_020130613','PD_020130706','PD_10121125','PD_10140513','PD_10140520','PD_10140526','PD_10140527','PD_10141110','PD_10141117','PD_10141124','PD_10141208','PD_10141216','PD_10150105','PD_10150113','PD_10150119','PD_10150126','PD_10150223','PD_10150302','PD_10150309','PD_10150316','PD_10150323','PD_10150413','PD_10150420','PD_10150601','PD_10150615','PD_10150713','PD_10150727','PD_10150810','PD_10150824','PD_11140513','PD_11140526','PD_11140527','PD_11141216','PD_20111111','PD_20111128','PD_20111208','PD_20111212','PD_20120105','PD_20120109','PD_20120126','PD_20120312','PD_20120315','PD_20120326','PD_20120423','PD_20120426','PD_20120503','PD_20120510','PD_20120531','PD_20120618','PD_20120625','PD_20120712','PD_20120820','PD_20120822','PD_20120905','PD_20120910','PD_20120924','PD_20121001','PD_20121029','PD_20130121','PD_20130307','PD_20130318','PD_20130328','PD_20130408','PD_20130411','PD_20130415','PD_20130425','PD_20130506','PD_20130624','PD_20130701','PD_20130708','PD_20130819','PD_20130826','PD_20140113','PD_20140116','PD_20140203','PD_20140220','PD_20140224','PD_20140331','PD_20140407','PD_20140722','PD_20140728','PD_20140804','PD_20140811','PD_20140825','PD_20140918','PD_20141110','PD_20141114','PD_20141117','PD_20141120','PD_20150108','PD_20150115','PD_20150116','PD_20150120','PD_20150306','PD_20150312','PD_20150316','PD_20150522','PD_20150610','PD_20150804','PD_20150910','PD_30150113','PD_30150119','PD_30150302','PD_30150309','PD_30150316','PD_30150323','PD_30150413','PD_30150601','PD_30150810','PD_40150113','PD_40150119'};

% Set input options
% -----------------
input_options.preproc_dir   = '/Volumes/KJung_2TB_TM/Data-FZJ/Functional_Connectivity/PD_HHU_by_KJung';
input_options.target_dir    = '/Volumes/PROJECTS/Data/Functional_Connectivity/PD_HHU_QC_N116_postproc_native_subctx_BOLD';
input_options.atlCond       = {'sch','ho','kst','dk','sth'};
input_options.atlList       = {'Schaefer2018_100Parcels_17Networks','HarvardOxford_96Parcels','Kleist_98Parcels','DesikanKilliany_68Parcels','Smith_88Parcels'};
input_options.atlListCpt    = {'Sch100P','HvOx96P','Klst98P','DK68P','Smith88P'};
input_options.filtCond      = {'notf','bptf_mat','l_bptf_mat','h_bptf_mat'};

input_options.grp           = 'PD_HHU';
% input_options.sbj           = 'PD_10121125';
% input_options.sbj           = 'PD_20150522';
% input_options.sbj           = 'PD_40150113';

input_options.numVols       = 300;  % no. EPI volumes
input_options.TR            = 2.21; % in seconds

% Run post process
% ----------------
for nSbj = 1:numel(sbjList)
    sbj = sbjList{nSbj};
    input_options.sbj = sbj;
    matlab_FC_postprocess(input_options);
end

%% Plot and correlations
close all
nAtl  = 1;
nFilt = 1;
bold_n = dlmread(fullfile(input_options.target_dir,sprintf('%s_postproc_%s_%s_mean_BOLD.csv',input_options.sbj,input_options.filtCond{nFilt},input_options.atlListCpt{nAtl})));
nFilt = 2;
bold_a = dlmread(fullfile(input_options.target_dir,sprintf('%s_postproc_%s_%s_mean_BOLD.csv',input_options.sbj,input_options.filtCond{nFilt},input_options.atlListCpt{nAtl})));
nFilt = 3;
bold_l = dlmread(fullfile(input_options.target_dir,sprintf('%s_postproc_%s_%s_mean_BOLD.csv',input_options.sbj,input_options.filtCond{nFilt},input_options.atlListCpt{nAtl})));
nFilt = 4;
bold_h = dlmread(fullfile(input_options.target_dir,sprintf('%s_postproc_%s_%s_mean_BOLD.csv',input_options.sbj,input_options.filtCond{nFilt},input_options.atlListCpt{nAtl})));

l = size(bold_a,2);
fc_n = nan(l,l);
fc_a = nan(l,l);
fc_l = nan(l,l);
fc_h = nan(l,l);
for nr = 1:l
    for nc = 1:l
        if nr < nc
            r = corrcoef(bold_n(:,nr),bold_n(:,nc));
            fc_n(nr,nc) = r(1,2);
            fc_n(nc,nr) = r(1,2);
            r = corrcoef(bold_a(:,nr),bold_a(:,nc));
            fc_a(nr,nc) = r(1,2);
            fc_a(nc,nr) = r(1,2);
            r = corrcoef(bold_l(:,nr),bold_l(:,nc));
            fc_l(nr,nc) = r(1,2);
            fc_l(nc,nr) = r(1,2);
            r = corrcoef(bold_h(:,nr),bold_h(:,nc));
            fc_h(nr,nc) = r(1,2);
            fc_h(nc,nr) = r(1,2);
        elseif nr == nc
            fc_n(nr,nc) = 1;
            fc_a(nr,nc) = 1;
            fc_l(nr,nc) = 1;
            fc_h(nr,nc) = 1;
        end
    end
end
FC = [fc_n,zeros(l,3),fc_a,zeros(l,3),fc_l,zeros(l,3),fc_h];

load('RdBu_colormap.mat')
figure(1);clf;set(gcf,'Color','w','Position',[1,527,1680,420])
imagesc(FC,[-1,1]);colormap(colors);axis image;axis off

clc
lgc = triu(true(l,l),1);

fprintf(' - %s - \n',input_options.atlList{nAtl});

r = corrcoef(fc_n(lgc),fc_a(lgc));
fprintf('  notf vs.   bptf = %0.4f\n',r(1,2));
r = corrcoef(fc_n(lgc),fc_l(lgc));
fprintf('  notf vs. l_bptf = %0.4f\n',r(1,2));
r = corrcoef(fc_n(lgc),fc_h(lgc));
fprintf('  notf vs. h_bptf = %0.4f\n\n',r(1,2));

r = corrcoef(fc_a(lgc),fc_l(lgc));
fprintf('  bptf vs. l_bptf = %0.4f\n',r(1,2));
r = corrcoef(fc_a(lgc),fc_h(lgc));
fprintf('  bptf vs. h_bptf = %0.4f\n\n',r(1,2));

r = corrcoef(fc_l(lgc),fc_h(lgc));
fprintf('l_bptf vs. h_bptf = %0.4f\n\n',r(1,2));

