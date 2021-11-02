clc
clear
addpath('/Applications/freesurfer/7.1.1/matlab')
sp      = '/Users/kyesamjung/Data/Mathematical_Modeling/ConvModel/Jureca';
ap      = '/Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/classifiers';
fp      = '/Users/kyesamjung/Projects/Neuroimage/Tools/freesurfer/subjects';
grp     = 'HCP';
sbjList = dlmread(fullfile(sp,'Experiment/HCP_351_Subjects.txt'));
numSbj  = numel(sbjList);
atlname = 'HarvardOxford_96Parcels';
%% cvs_avg35

% Left hemisphere
% ---------------
V = nan(139336,numSbj);
L = nan(139336,numSbj);
for nSbj = 1:numSbj
    sbj = sbjList(nSbj);
    fn = sprintf('lh.%s_%s_%i.annot',atlname,grp,sbj);
    [vertices,label,colortable] = read_annotation(fullfile(ap,'cvs_avg35_annot_HCP_N351',fn));
    V(:,nSbj) = vertices;
    L(:,nSbj) = label;
end
[M,F] = mode(L,2);
fprintf('\n -+- Left hemisphere \n\n')
fprintf('  # %i zeros for mode!\n',sum(M == 0));
fprintf('  # %i empty vertices!\n',sum(sum(L,2)==0));
lgc = F <= numSbj/2;
idx = find(lgc);
for n = 1:numel(idx)
    l = L(idx(n),:);
    [m,f] = mode(l(mode(l) ~= l));
    if f == F(idx(n))
        if f >= numSbj * 0.05
            fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f,idx(n),M(idx(n)),m);
        end
        if M(idx(n),1) == 0
            M(idx(n),1) = m;
            F(idx(n),1) = f;
        elseif m == 0
            % Do not replace in this case.
        else
            if rand(1) < 0.5
                M(idx(n),1) = m;
                F(idx(n),1) = f;
            end
        end
        if f >= numSbj * 0.05
            fprintf(' --> saved as %i\n',M(idx(n)));
        end
    end
end
disp(' ')
idx = find(M == 0);
if ~isempty(idx)
    for n = 1:numel(idx)
        if sum(L(idx(n),:)) > 0
            l = L(idx(n),:);
            l = l(l~=0);
            [m1,f1] = mode(l);
            if f1 <= numel(l)/2
                [m2,f2] = mode(l(l~=m1));
                if f1 == f2
                    if f1 > numSbj * 0.05
                        fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f1,idx(n),m1,m2);
                    end
                    if rand(1) < 0.5
                        M(idx(n),1) = m1;
                        F(idx(n),1) = f1;
                    else
                        M(idx(n),1) = m2;
                        F(idx(n),1) = f2;
                    end
                    if f1 > numSbj * 0.05
                        fprintf(' --> saved as %i\n',M(idx(n)));
                    end
                end
            else
                M(idx(n),1) = m1;
                F(idx(n),1) = f1;
            end
        end
        clear m1 f1 m2 f2 l
    end
end
fn = sprintf('lh.%s_%s%i_cvs_avg35.annot',atlname,grp,numSbj);
write_annotation(fullfile(ap,'cvs_avg35_annot_HCP_N351',fn),vertices,M,colortable);

% Right hemisphere
% ----------------
V = nan(134980,numSbj);
L = nan(134980,numSbj);
for nSbj = 1:numSbj
    sbj = sbjList(nSbj);
    fn = sprintf('rh.%s_%s_%i.annot',atlname,grp,sbj);
    [vertices,label,colortable] = read_annotation(fullfile(ap,'cvs_avg35_annot_HCP_N351',fn));
    V(:,nSbj) = vertices;
    L(:,nSbj) = label;
end
[M,F] = mode(L,2);
fprintf('\n -+- Right hemisphere \n\n')
fprintf('  # %i zeros for mode!\n',sum(M == 0));
fprintf('  # %i empty vertices!\n',sum(sum(L,2)==0));
lgc = F <= numSbj/2;
idx = find(lgc);
for n = 1:numel(idx)
    l = L(idx(n),:);
    [m,f] = mode(l(mode(l) ~= l));
    if f == F(idx(n))
        if f >= numSbj * 0.05
            fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f,idx(n),M(idx(n)),m);
        end
        if M(idx(n),1) == 0
            M(idx(n),1) = m;
            F(idx(n),1) = f;
        elseif m == 0
            % Do not replace in this case.
        else
            if rand(1) < 0.5
                M(idx(n),1) = m;
                F(idx(n),1) = f;
            end
        end
        if f >= numSbj * 0.05
            fprintf(' --> saved as %i\n',M(idx(n)));
        end
    end
end
disp(' ')
idx = find(M == 0);
if ~isempty(idx)
    for n = 1:numel(idx)
        if sum(L(idx(n),:)) > 0
            l = L(idx(n),:);
            l = l(l~=0);
            [m1,f1] = mode(l);
            if f1 <= numel(l)/2
                [m2,f2] = mode(l(l~=m1));
                if f1 == f2
                    if f1 > numSbj * 0.05
                        fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f1,idx(n),m1,m2);
                    end
                    if rand(1) < 0.5
                        M(idx(n),1) = m1;
                        F(idx(n),1) = f1;
                    else
                        M(idx(n),1) = m2;
                        F(idx(n),1) = f2;
                    end
                    if f1 > numSbj * 0.05
                        fprintf(' --> saved as %i\n',M(idx(n)));
                    end
                end
            else
                M(idx(n),1) = m1;
                F(idx(n),1) = f1;
            end
        end
        clear m1 f1 m2 f2 l
    end
end
fn = sprintf('rh.%s_%s%i_cvs_avg35.annot',atlname,grp,numSbj);
write_annotation(fullfile(ap,'cvs_avg35_annot_HCP_N351',fn),vertices,M,colortable);
%% fsaverage6
clc

% Left hemisphere
% ---------------
V = nan(40962,numSbj);
L = nan(40962,numSbj);
for nSbj = 1:numSbj
    sbj = sbjList(nSbj);
    fn = sprintf('lh.%s_%s_%i.annot',atlname,grp,sbj);
    [vertices,label,colortable] = read_annotation(fullfile(ap,'fsaverage6_annot_HCP_N351',fn));
    V(:,nSbj) = vertices;
    L(:,nSbj) = label;
end
[M,F] = mode(L,2);
fprintf('\n -+- Left hemisphere \n\n');
fprintf('  # %i zeros for mode!\n',sum(M == 0));
fprintf('  # %i empty vertices!\n',sum(sum(L,2)==0));
lgc = F <= numSbj/2;
idx = find(lgc);
for n = 1:numel(idx)
    l = L(idx(n),:);
    [m,f] = mode(l(mode(l) ~= l));
    if f == F(idx(n))
        if f >= numSbj * 0.05
            fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f,idx(n),M(idx(n)),m);
        end
        if M(idx(n),1) == 0
            M(idx(n),1) = m;
            F(idx(n),1) = f;
        elseif m == 0
            % Do not replace in this case.
        else
            if rand(1) < 0.5
                M(idx(n),1) = m;
                F(idx(n),1) = f;
            end
        end
        if f >= numSbj * 0.05
            fprintf(' --> saved as %i\n',M(idx(n)));
        end
    end
end
disp(' ')
idx = find(M == 0);
if ~isempty(idx)
    for n = 1:numel(idx)
        if sum(L(idx(n),:)) > 0
            l = L(idx(n),:);
            l = l(l~=0);
            [m1,f1] = mode(l);
            if f1 <= numel(l)/2
                [m2,f2] = mode(l(l~=m1));
                if f1 == f2
                    if f1 > numSbj * 0.05
                        fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f1,idx(n),m1,m2);
                    end
                    if rand(1) < 0.5
                        M(idx(n),1) = m1;
                        F(idx(n),1) = f1;
                    else
                        M(idx(n),1) = m2;
                        F(idx(n),1) = f2;
                    end
                    if f1 > numSbj * 0.05
                        fprintf(' --> saved as %i\n',M(idx(n)));
                    end
                end
            else
                M(idx(n),1) = m1;
                F(idx(n),1) = f1;
            end
        end
        clear m1 f1 m2 f2 l
    end
end
fn = sprintf('lh.%s_%s%i_fsaverage6.annot',atlname,grp,numSbj);
write_annotation(fullfile(ap,'fsaverage6_annot_HCP_N351',fn),vertices,M,colortable);

% Right hemisphere
% ----------------
V = nan(40962,numSbj);
L = nan(40962,numSbj);
for nSbj = 1:numSbj
    sbj = sbjList(nSbj);
    fn = sprintf('rh.%s_%s_%i.annot',atlname,grp,sbj);
    [vertices,label,colortable] = read_annotation(fullfile(ap,'fsaverage6_annot_HCP_N351',fn));
    V(:,nSbj) = vertices;
    L(:,nSbj) = label;
end
[M,F] = mode(L,2);
fprintf('\n -+- Right hemisphere \n\n')
fprintf('  # %i zeros for mode!\n',sum(M == 0));
fprintf('  # %i empty vertices!\n',sum(sum(L,2)==0));
lgc = F <= numSbj/2;
idx = find(lgc);
for n = 1:numel(idx)
    l = L(idx(n),:);
    [m,f] = mode(l(mode(l) ~= l));
    if f == F(idx(n))
        if f >= numSbj * 0.05
            fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f,idx(n),M(idx(n)),m);
        end
        if M(idx(n),1) == 0
            M(idx(n),1) = m;
            F(idx(n),1) = f;
        elseif m == 0
            % Do not replace in this case.
        else
            if rand(1) < 0.5
                M(idx(n),1) = m;
                F(idx(n),1) = f;
            end
        end
        if f >= numSbj * 0.05
            fprintf(' --> saved as %i\n',M(idx(n)));
        end
    end
end
disp(' ')
idx = find(M == 0);
if ~isempty(idx)
    for n = 1:numel(idx)
        if sum(L(idx(n),:)) > 0
            l = L(idx(n),:);
            l = l(l~=0);
            [m1,f1] = mode(l);
            if f1 <= numel(l)/2
                [m2,f2] = mode(l(l~=m1));
                if f1 == f2
                    if f1 > numSbj * 0.05
                        fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f1,idx(n),m1,m2);
                    end
                    if rand(1) < 0.5
                        M(idx(n),1) = m1;
                        F(idx(n),1) = f1;
                    else
                        M(idx(n),1) = m2;
                        F(idx(n),1) = f2;
                    end
                    if f1 > numSbj * 0.05
                        fprintf(' --> saved as %i\n',M(idx(n)));
                    end
                end
            else
                M(idx(n),1) = m1;
                F(idx(n),1) = f1;
            end
        end
        clear m1 f1 m2 f2 l
    end
end
fn = sprintf('rh.%s_%s%i_fsaverage6.annot',atlname,grp,numSbj);
write_annotation(fullfile(ap,'fsaverage6_annot_HCP_N351',fn),vertices,M,colortable);
%% fsaverage
clc

% Left hemisphere
% ---------------
V = nan(163842,numSbj);
L = nan(163842,numSbj);
for nSbj = 1:numSbj
    sbj = sbjList(nSbj);
    fn = sprintf('lh.%s_%s_%i.annot',atlname,grp,sbj);
    [vertices,label,colortable] = read_annotation(fullfile(ap,'fsaverage_annot_HCP_N351',fn));
    V(:,nSbj) = vertices;
    L(:,nSbj) = label;
end
[M,F] = mode(L,2);
fprintf('\n -+- Left hemisphere \n\n');
fprintf('  # %i zeros for mode!\n',sum(M == 0));
fprintf('  # %i empty vertices!\n',sum(sum(L,2)==0));
lgc = F <= numSbj/2;
idx = find(lgc);
for n = 1:numel(idx)
    l = L(idx(n),:);
    [m,f] = mode(l(mode(l) ~= l));
    if f == F(idx(n))
        if f >= numSbj * 0.05
            fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f,idx(n),M(idx(n)),m);
        end
        if M(idx(n),1) == 0
            M(idx(n),1) = m;
            F(idx(n),1) = f;
        elseif m == 0
            % Do not replace in this case.
        else
            if rand(1) < 0.5
                M(idx(n),1) = m;
                F(idx(n),1) = f;
            end
        end
        if f >= numSbj * 0.05
            fprintf(' --> saved as %i\n',M(idx(n)));
        end
    end
end
disp(' ')
idx = find(M == 0);
if ~isempty(idx)
    for n = 1:numel(idx)
        if sum(L(idx(n),:)) > 0
            l = L(idx(n),:);
            l = l(l~=0);
            [m1,f1] = mode(l);
            if f1 <= numel(l)/2
                [m2,f2] = mode(l(l~=m1));
                if f1 == f2
                    if f1 > numSbj * 0.05
                        fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f1,idx(n),m1,m2);
                    end
                    if rand(1) < 0.5
                        M(idx(n),1) = m1;
                        F(idx(n),1) = f1;
                    else
                        M(idx(n),1) = m2;
                        F(idx(n),1) = f2;
                    end
                    if f1 > numSbj * 0.05
                        fprintf(' --> saved as %i\n',M(idx(n)));
                    end
                end
            else
                M(idx(n),1) = m1;
                F(idx(n),1) = f1;
            end
        end
        clear m1 f1 m2 f2 l
    end
end
fn = sprintf('lh.%s_%s%i_fsaverage.annot',atlname,grp,numSbj);
write_annotation(fullfile(ap,'fsaverage_annot_HCP_N351',fn),vertices,M,colortable);

% Right hemisphere
% ----------------
V = nan(163842,numSbj);
L = nan(163842,numSbj);
for nSbj = 1:numSbj
    sbj = sbjList(nSbj);
    fn = sprintf('rh.%s_%s_%i.annot',atlname,grp,sbj);
    [vertices,label,colortable] = read_annotation(fullfile(ap,'fsaverage_annot_HCP_N351',fn));
    V(:,nSbj) = vertices;
    L(:,nSbj) = label;
end
[M,F] = mode(L,2);
fprintf('\n -+- Right hemisphere \n\n')
fprintf('  # %i zeros for mode!\n',sum(M == 0));
fprintf('  # %i empty vertices!\n',sum(sum(L,2)==0));
lgc = F <= numSbj/2;
idx = find(lgc);
for n = 1:numel(idx)
    l = L(idx(n),:);
    [m,f] = mode(l(mode(l) ~= l));
    if f == F(idx(n))
        if f >= numSbj * 0.05
            fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f,idx(n),M(idx(n)),m);
        end
        if M(idx(n),1) == 0
            M(idx(n),1) = m;
            F(idx(n),1) = f;
        elseif m == 0
            % Do not replace in this case.
        else
            if rand(1) < 0.5
                M(idx(n),1) = m;
                F(idx(n),1) = f;
            end
        end
        if f >= numSbj * 0.05
            fprintf(' --> saved as %i\n',M(idx(n)));
        end
    end
end
disp(' ')
idx = find(M == 0);
if ~isempty(idx)
    for n = 1:numel(idx)
        if sum(L(idx(n),:)) > 0
            l = L(idx(n),:);
            l = l(l~=0);
            [m1,f1] = mode(l);
            if f1 <= numel(l)/2
                [m2,f2] = mode(l(l~=m1));
                if f1 == f2
                    if f1 > numSbj * 0.05
                        fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f1,idx(n),m1,m2);
                    end
                    if rand(1) < 0.5
                        M(idx(n),1) = m1;
                        F(idx(n),1) = f1;
                    else
                        M(idx(n),1) = m2;
                        F(idx(n),1) = f2;
                    end
                    if f1 > numSbj * 0.05
                        fprintf(' --> saved as %i\n',M(idx(n)));
                    end
                end
            else
                M(idx(n),1) = m1;
                F(idx(n),1) = f1;
            end
        end
        clear m1 f1 m2 f2 l
    end
end
fn = sprintf('rh.%s_%s%i_fsaverage.annot',atlname,grp,numSbj);
write_annotation(fullfile(ap,'fsaverage_annot_HCP_N351',fn),vertices,M,colortable);
%% fsaverage5
clc

% Left hemisphere
% ---------------
V = nan(10242,numSbj);
L = nan(10242,numSbj);
for nSbj = 1:numSbj
    sbj = sbjList(nSbj);
    fn = sprintf('lh.%s_%s_%i.annot',atlname,grp,sbj);
    [vertices,label,colortable] = read_annotation(fullfile(ap,'fsaverage5_annot_HCP_N351',fn));
    V(:,nSbj) = vertices;
    L(:,nSbj) = label;
end
[M,F] = mode(L,2);
fprintf('\n -+- Left hemisphere \n\n');
fprintf('  # %i zeros for mode!\n',sum(M == 0));
fprintf('  # %i empty vertices!\n',sum(sum(L,2)==0));
lgc = F <= numSbj/2;
idx = find(lgc);
for n = 1:numel(idx)
    l = L(idx(n),:);
    [m,f] = mode(l(mode(l) ~= l));
    if f == F(idx(n))
        if f >= numSbj * 0.05
            fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f,idx(n),M(idx(n)),m);
        end
        if M(idx(n),1) == 0
            M(idx(n),1) = m;
            F(idx(n),1) = f;
        elseif m == 0
            % Do not replace in this case.
        else
            if rand(1) < 0.5
                M(idx(n),1) = m;
                F(idx(n),1) = f;
            end
        end
        if f >= numSbj * 0.05
            fprintf(' --> saved as %i\n',M(idx(n)));
        end
    end
end
disp(' ')
idx = find(M == 0);
if ~isempty(idx)
    for n = 1:numel(idx)
        if sum(L(idx(n),:)) > 0
            l = L(idx(n),:);
            l = l(l~=0);
            [m1,f1] = mode(l);
            if f1 <= numel(l)/2
                [m2,f2] = mode(l(l~=m1));
                if f1 == f2
                    if f1 > numSbj * 0.05
                        fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f1,idx(n),m1,m2);
                    end
                    if rand(1) < 0.5
                        M(idx(n),1) = m1;
                        F(idx(n),1) = f1;
                    else
                        M(idx(n),1) = m2;
                        F(idx(n),1) = f2;
                    end
                    if f1 > numSbj * 0.05
                        fprintf(' --> saved as %i\n',M(idx(n)));
                    end
                end
            else
                M(idx(n),1) = m1;
                F(idx(n),1) = f1;
            end
        end
        clear m1 f1 m2 f2 l
    end
end
fn = sprintf('lh.%s_%s%i_fsaverage5.annot',atlname,grp,numSbj);
write_annotation(fullfile(ap,'fsaverage5_annot_HCP_N351',fn),vertices,M,colortable);

% Right hemisphere
% ----------------
V = nan(10242,numSbj);
L = nan(10242,numSbj);
for nSbj = 1:numSbj
    sbj = sbjList(nSbj);
    fn = sprintf('rh.%s_%s_%i.annot',atlname,grp,sbj);
    [vertices,label,colortable] = read_annotation(fullfile(ap,'fsaverage5_annot_HCP_N351',fn));
    V(:,nSbj) = vertices;
    L(:,nSbj) = label;
end
[M,F] = mode(L,2);
fprintf('\n -+- Right hemisphere \n\n')
fprintf('  # %i zeros for mode!\n',sum(M == 0));
fprintf('  # %i empty vertices!\n',sum(sum(L,2)==0));
lgc = F <= numSbj/2;
idx = find(lgc);
for n = 1:numel(idx)
    l = L(idx(n),:);
    [m,f] = mode(l(mode(l) ~= l));
    if f == F(idx(n))
        if f >= numSbj * 0.05
            fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f,idx(n),M(idx(n)),m);
        end
        if M(idx(n),1) == 0
            M(idx(n),1) = m;
            F(idx(n),1) = f;
        elseif m == 0
            % Do not replace in this case.
        else
            if rand(1) < 0.5
                M(idx(n),1) = m;
                F(idx(n),1) = f;
            end
        end
        if f >= numSbj * 0.05
            fprintf(' --> saved as %i\n',M(idx(n)));
        end
    end
end
disp(' ')
idx = find(M == 0);
if ~isempty(idx)
    for n = 1:numel(idx)
        if sum(L(idx(n),:)) > 0
            l = L(idx(n),:);
            l = l(l~=0);
            [m1,f1] = mode(l);
            if f1 <= numel(l)/2
                [m2,f2] = mode(l(l~=m1));
                if f1 == f2
                    if f1 > numSbj * 0.05
                        fprintf('  + Significantly competing (f = %i) on vertex %i !! %i <-> %i',f1,idx(n),m1,m2);
                    end
                    if rand(1) < 0.5
                        M(idx(n),1) = m1;
                        F(idx(n),1) = f1;
                    else
                        M(idx(n),1) = m2;
                        F(idx(n),1) = f2;
                    end
                    if f1 > numSbj * 0.05
                        fprintf(' --> saved as %i\n',M(idx(n)));
                    end
                end
            else
                M(idx(n),1) = m1;
                F(idx(n),1) = f1;
            end
        end
        clear m1 f1 m2 f2 l
    end
end
fn = sprintf('rh.%s_%s%i_fsaverage5.annot',atlname,grp,numSbj);
write_annotation(fullfile(ap,'fsaverage5_annot_HCP_N351',fn),vertices,M,colortable);
%% 
clc
lgc = F <= 351/2;
idx = find(lgc);
T = L(lgc,:);
histogram(F)
for n = 1:numel(idx)
    l = L(idx(n),:);
    [m,f] = mode(l(mode(l) ~= l));
    if f == F(idx(n))
        fprintf('  + Competing (f = %i) on vertex %i !! %i <-> %i\n',f,idx(n),M(idx(n)),m);
    end
end
