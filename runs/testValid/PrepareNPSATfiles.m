% Parameters
R = 2000;
ho = 30;
K = 5;
b = 300;
Q = 2000;
T = K*b;
% Write mesh file
[p, MSH] = readOBJmesh('Circle_zbrush.OBJ', 4);
p = R * p;
writeMeshfile('circle_mesh.npsat', p(:,1:2), MSH)

% Constant head boundary file
[bnd_p, bnd_MSH] = readOBJmesh('DC_BND_file.obj', 40);
bnd_MSH = [bnd_MSH bnd_MSH(1)]';
bnd_p = R * bnd_p;

fid = fopen('dir_bc_circle.npsat','w');
fprintf(fid, '%d\n', 1);
fprintf(fid, 'EDGE 0 circle_bnd.npsat\n');
fclose(fid);

bc_nds = [bnd_p(bnd_MSH,1:2) ho*ones(length(bnd_MSH),1)];
fid = fopen('circle_bnd.npsat','w');
fprintf(fid, 'BOUNDARY_LINE\n');
fprintf(fid, '%d %d %f\n', [size(bc_nds,1) 1, 1.0]);
fprintf(fid, '%f %f %f\n', bc_nds');
fclose(fid);

% Well file
fid = fopen('circle_well.npsat','w');
fprintf(fid, '%d\n', 1);
fprintf(fid, '%f %f %f %f %f\n', [0 0 ho ho-b -Q]);
fclose(fid);

Niter = 4;
for ii = 1:Niter
    wtc{ii,1} = ReadWaterTableCloudPoints( struct('prefix','output/circleTest', 'iter',ii));
end

% Analytical solution for radial flow to a well
han = @(r) (Q/(2*pi*T))*log(r/R) + ho;

x = 1:5:2000;
y = zeros(1, length(x));
figure(10);hold on
for ii = 1:Niter
    F = scatteredInterpolant(wtc{ii,1}(:,1), wtc{ii,1}(:,2), wtc{ii,1}(:,3));
    plot(x,F(x,y))
end
plot(x, han(x),'k', 'linewidth',1.5)
