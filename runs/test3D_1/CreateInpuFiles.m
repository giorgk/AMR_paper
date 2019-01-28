% This script will create the input files for the first 3D test which will
% be included in the paper
%
msim_path = 'home/giorgk/CODES/msim';
% The domain a rectangle with dimensions 5 x 5 km.
L = 5000;
dom = [0 0; L 0; L L; 0 L];
%% Create BC file
bx = 1500;
by = 1500;
w = 57;
%%
fid = fopen('test3D_BC.npsat','w');
fprintf(fid, '%d\n', 1);
fprintf(fid, 'TOP 4 %f\n', 35);
fprintf(fid,'%f %f\n',[bx-w by-w; bx+w by-w; bx+w by+w; bx-w by+w]');
fclose(fid);
%% load stream from the NPSAT tutorial
strm = shaperead([msim_path '/html_help/DATA/Streams_exampl_buff']);
% the stream ids inside the domain of this example are 
% The recharge rate is 14-18.
% The segment 14 needs trim on the top
strm(14,1).Y(strm(14,1).Y > 5000) = L;
strm(17,1).Y(strm(17,1).Y < 0) = 0;
strm = strm(14:18,:);
for ii = 1:size(strm,1)
    strm(ii,1).area = polyarea(strm(ii,1).X(1:end-1), strm(ii,1).Y(1:end-1));
    strm(ii,1).Q_rate = 1*strm(ii,1).Q_rate;
end
%% write the stream file
fid = fopen('test3D_stream.npsat','w');
fprintf(fid, '%d\n', size(strm,1));
for ii = 1:size(strm,1)
    fprintf(fid, '%d %f\n', [4 strm(ii,1).Q_rate]);
    fprintf(fid, '%f %f\n', [strm(ii,1).X(1:4)' strm(ii,1).Y(1:4)']');
end
fclose(fid);
%% Calculate the total volume of water that comes in the aquifer
rch = 0.0004;
% Therefore, the total recharge volume is
RCV_vol = rch*L*L;
STRM_vol = sum([strm.Q_rate]'.*[strm.area]');
Tot_rch = RCV_vol + STRM_vol
%
%% Generate wells
% make a list of the stream segments to calculate faster the distances
% from the streams
clf
plot(dom([1 2 3 4 1], 1), dom([1 2 3 4 1], 2), 'linewidth', 1.5)
hold on
mapshow(strm)
axis equal
strmLines = [];
for i = 1:size(strm,1)
   [xi, yi] = polysplit(strm(i,1).X, strm(i,1).Y);
   for j = 1:size(xi,1)
      for k = 1:length(xi{j,1}) - 1
          strmLines = [strmLines; xi{j,1}(k) yi{j,1}(k) xi{j,1}(k+1) yi{j,1}(k+1)];
      end
   end
end
wells = [];
wellsXY=[];
Q_tot_well = 0;
while Q_tot_well < Tot_rch
    xw = 400 + (4600 - 400)*rand; % we dont want the wells very close
    yw = 400 + (4600 - 400)*rand; % to the boundaries
    if ~isempty(wellsXY)
        dst = sqrt((xw - wellsXY(:,1)).^2 + (yw - wellsXY(:,2)).^2);
        if min(dst) < 400
            continue;
        end
    end
    
    % find the distance between the dirichlet BC
    if pdist([xw yw;bx by]) < 650
        continue;
    end
    
    % find the minimum distance from the streams
    dst = Dist_Point_LineSegment(xw,yw,strmLines);
    if min(dst) < 400
        continue;
    end
    
    wellsXY = [wellsXY;xw yw];
    Q = abs(normrnd(650,200));
    zt = normrnd(-30,50);
    if zt > 30
        zt = -10;
    end
    zb = zt - max(normrnd(100,80), 50);
    if zb < -270
        zb = -220;
    end
    wells = [wells; xw yw zt zb -Q];
    Q_tot_well = Q_tot_well + Q;
    plot(xw,yw,'.')
    title(['Q: ' num2str(Q_tot_well/Tot_rch*100)])
    drawnow
    
end
%% print the wells
fid = fopen('test3D_wells.npsat','w');
fprintf(fid, '%d\n', size(wells,1));
fprintf(fid, '%f %f %f %f %f\n', wells');
fclose(fid);
%% plot for debuging
clf
hold on
dx = 0:500:5000;
for ii = 1:length(dx)-1
    for jj = 1:length(dx)-1
        plot([dx(ii) dx(ii+1) dx(ii+1) dx(ii) dx(ii)],...
             [dx(jj) dx(jj) dx(jj+1) dx(jj+1) dx(jj)],'b');
    end
end
for ii = 1:size(strm,1)
    plot(strm(ii,1).X([1:4 1]), strm(ii,1).Y([1:4 1]),'r')
end
axis equal
%% Paper plot
wells = readWells('test3D_wells.npsat');
strm = readStreams('test3D_stream.npsat');
clf
hold on
dx = 0:500:5000;
for ii = 1:length(dx)-1
    for jj = 1:length(dx)-1
        plot([dx(ii) dx(ii+1) dx(ii+1) dx(ii) dx(ii)],...
             [dx(jj) dx(jj) dx(jj+1) dx(jj+1) dx(jj)],'--k');
    end
end
plot(dom([1 2 3 4 1], 1), dom([1 2 3 4 1], 2), 'linewidth', 2, 'color', [0    0.4470    0.7410])

for ii = 1:size(strm,1)
    patch(strm(ii,1).poly(:,1), strm(ii,1).poly(:,2),[0.9290    0.6940    0.1250])
    text(mean(strm(ii,1).poly(:,1))+100, mean(strm(ii,1).poly(:,2)), num2str(strm(ii,1).Q), 'color', [0.4392 0.3216 0.0549]); 
end
plot(wells(:,1), wells(:,2),'o','color',[0.8500    0.3250    0.0980],'MarkerFaceColor',[0.8500    0.3250    0.0980])
axis equal
for ii = 1:size(wells,1)
    text(wells(ii,1)+50, wells(ii,2)+50, num2str(wells(ii,5),'%.0f'),'color',[0.4471 0.1686 0.051]);
end
bc = [bx-w by-w; bx+w by-w; bx+w by+w; bx-w by+w];
patch(bc(:,1), bc(:,2), [0.3010    0.7450    0.9330])
axis off

%% Create output statistics plot
load('MultiCoreStats');
iter = 1:12;
%%
clf
yyaxis left
semilogy(iter, sum(Stats.n1,2),'-ob')
hold on
semilogy(iter, sum(Stats.n3,2),'-og')
semilogy(iter, sum(Stats.n6,2),'-or')
ylabel('Time [sec]')

yyaxis right
semilogy(iter, Stats.dof,'.-')
ylim([0 1000000])
legend('# proc: 1', '# proc: 3', '# proc: 6', 'dofs', 'location', 'Northwest')
ylabel('Degrees of freedom')
xlabel('Iterations')
title('Simulation time')
xlim([1 12])
%%
clf
subplot(2,2,1);
semilogy(iter, Stats.n1(:,1), '.-b', 'DisplayName', '# proc: 1')
hold on
semilogy(iter, Stats.n3(:,1), '.-g', 'DisplayName', '# proc: 3')
semilogy(iter, Stats.n6(:,1), '.-r', 'DisplayName', '# proc: 6')
ylabel('Time [sec]')
title('Assemble');
grid on
ylim([0.0001 20])
xlim([1 12])

subplot(2,2,2);
semilogy(iter, Stats.n1(:,2), '.-b', 'DisplayName', '# proc: 1')
hold on
semilogy(iter, Stats.n3(:,2), '.-g', 'DisplayName', '# proc: 3')
semilogy(iter, Stats.n6(:,2), '.-r', 'DisplayName', '# proc: 6')
title('Output');
grid on
ylim([0.0001 20])
xlim([1 12])

subplot(2,2,3);
semilogy(iter, Stats.n1(:,3), '.-b', 'DisplayName', '# proc: 1')
hold on
semilogy(iter, Stats.n3(:,3), '.-g', 'DisplayName', '# proc: 3')
semilogy(iter, Stats.n6(:,3), '.-r', 'DisplayName', '# proc: 6')
ylabel('Time [sec]')
xlabel('Iterations')
title('Setup');
grid on
ylim([0.0001 20])
xlim([1 12])

subplot(2,2,4);
semilogy(iter, Stats.n1(:,4), '.-b', 'DisplayName', '# proc: 1')
hold on
semilogy(iter, Stats.n3(:,4), '.-g', 'DisplayName', '# proc: 3')
semilogy(iter, Stats.n6(:,4), '.-r', 'DisplayName', '# proc: 6')
xlabel('Iterations')
title('Solve');
grid on
ylim([0.0001 20])
xlim([1 12])
