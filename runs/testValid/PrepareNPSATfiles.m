% Write mesh file
[p, MSH] = readOBJmesh('Circle_zbrush.OBJ', 4);
writeMeshfile('circle_mesh.npsat', 2000*p(:,1:2), MSH)