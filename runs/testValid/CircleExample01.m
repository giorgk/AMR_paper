% create a circular polygon to be the outline of the mesh
clear
clc
% Parameters
Radius = 2000; % meter
SegmentSize = 100; % meter
Npoints = ceil(Radius*pi / SegmentSize);
t = linspace(0,2*pi,Npoints);
circle_points = Radius*[cos(t); sin(t)]';

domain.Geometry = 'Polygon';
domain.X = [circle_points(:,1)' nan];
domain.Y = [circle_points(:,2)' nan];

well.Geometry = 'Point';
well.X = 0;
well.Y = 0;
%well.DistMin = 50;
%well.DistMax = Radius/2;
%well.LcMin = 100;
%well.LcMax = 400;

circle_dom = CSGobj_v2(2,1,Npoints*2,Npoints*2,1); %Dim,Npoly,Nline,Npoints,usertol
circle_dom = circle_dom.readshapefile(domain);
circle_dom = circle_dom.readshapefile(well);
clf
circle_dom.plotCSGobj

meshopt=msim_mesh_options;
meshopt.lc_gen = 200; % size of maximum element
meshopt.embed_points = 0; % we want to embed the points into the mesh
meshopt.embed_lines = 0; 

circle_dom.writegeo('circle_domain',meshopt);
gmsh_path='/home/giorgk/Downloads/gmsh-4.5.1-Linux64/bin/gmsh';
circle_dom.runGmsh('circle_domain',gmsh_path,[])

[p, MSH]=read_2D_Gmsh('circle_domain', 0, 0);

% circle_dom.showGmsh('circle_domain',gmsh_path, 'msh');

Nel = size(MSH(3,1).elem.id,1);
Np = size(p,1);

R = 5e-4;
F_rch(1,1).id = (1:Nel)';
F_rch(1,1).val = R*ones(Nel,1);
F_rch(1,1).dim = 2;
F_rch(1,1).el_type = 'triangle';
F_rch(1,1).el_order = 'linear';
F_rch(1,1).id_el = 1;

id = find_elem_id_point(p,MSH(3,1).elem.id,[0 0], 10);
A = Calc_Area(p,MSH(3,1).elem(1,1).id(id,:));

F_wll(1,1).id = id;
F_wll(1,1).val = -R*(pi*Radius^2)/A;
F_wll(1,1).dim = 2;
F_wll(1,1).el_type = 'triangle';
F_wll(1,1).el_order = 'linear';
F_wll(1,1).id_el = 1;

Tel=30*ones(Nel,1)*10;

p_dst = sqrt(p(:,1).^2 + p(:,2).^2 );
ch_id = find(p_dst>Radius-10);

clf
plot(p(:,1), p(:,2), '.')
hold on
plot(p(ch_id,1), p(ch_id,2), '.r')

CH = [ch_id, 30*ones(length(ch_id),1)];
GHB = [];

simopt.dim=2;
simopt.el_type = 'triangle';
simopt.el_order = 'linear';
[Kglo, H]= Assemble_LHS(p, MSH(3,1).elem(1,1).id, Tel, CH, GHB, simopt);

F_r= Assemble_RHS(length(H),p, MSH,F_rch);
F_w = Assemble_RHS(length(H),p, MSH,F_wll);

Hsol = solve_system(Kglo, H, F_r+F_w);

clf
trisurf(MSH(3,1).elem(1,1).id,p(:,1),p(:,2),Hsol(1:size(p,1)))