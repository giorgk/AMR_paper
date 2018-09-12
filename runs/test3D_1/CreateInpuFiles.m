% This script will create the input files for the first 3D test which will
% be included in the paper
%
% The domain a rectangle with dimensions 5 x 5 km.
L = 5000;
% The recharge rate is 
rch = 0.0004;
% Therefore, the total recharge volume is
RCV_vol = rch*L*L;