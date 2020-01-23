% Write mesh file
Radius = 2000;
[p, MSH] = readOBJmesh('Circle_zbrush.OBJ', 4);
p = Radius*p;
writeMeshfile('circle_mesh.npsat', p(:,1:2), MSH)

[bnd_p, bnd_MSH] = readOBJmesh('DC_BND_file.obj', 40);



fid = fopen('CH_BND.npsat','w');
fprintf(fid, 'BOUNDARY_LINE\n');


