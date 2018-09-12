% This script will create the input files for the first 3D test which will
% be included in the paper
%
msim_path = 'home/giorgk/CODES/msim';
% The domain a rectangle with dimensions 5 x 5 km.
L = 5000;
dom = [0 0; L 0; L L; 0 L];

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
end
%% write the stream file
fid = fopen('test3D_stream.npsat','w');
%fprintf(fid,
fclose(fid);
%%
rch = 0.0004;
% Therefore, the total recharge volume is
RCV_vol = rch*L*L;