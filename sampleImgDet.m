function samples = sampleImgDet(img,initstate,inrad,step)
% $Description:
%    -Compute the coordinate of sample image templates
% $Agruments
% Input;
%    -img: inpute image
%    -initistate: [x y width height] object position 
%    -inrad: outside radius of region
%    -outrad: inside radius of region
%    -maxnum: maximal number of samples
% Output:
%    -samples.sx: x coordinate vector,[x1 x2 ...xn]
%    -samples.sy: y ...
%    -samples.sw: width ...
%    -samples.sh: height...
% $ History $
%   - Created by Kaihua Zhang, on April 22th, 2011
%   - Revised by Kaihua Zhang, on May 25th, 2011
%   - Revised by Kaihua Zhang, 13/7/2012

%randn('state',0);%important

%inrad = ceil(inrad);

[row,col] = size(img);
x = initstate(1);
y = initstate(2);
w = initstate(3);
h = initstate(4);

rowsz = row - h - 1;
colsz = col - w - 1;

inradsq  = inrad^2;

minrow = max(1, y - inrad+1);
maxrow = min(rowsz-1, y+inrad);
mincol = max(1, x-inrad+1);
maxcol = min(colsz-1, x+inrad);
%--------------------------------------------------
% if nargin < 5
% a = round(repmat([y,x],600,1)+inrad*randn(600,2));
% rr = a(:,1);
% cc = a(:,2);
% rr = rr(rr>minrow);
% rr = rr(rr<maxrow);
% 
% cc = cc(cc>mincol);
% cc = cc(cc<maxcol);
% 
% len = min(length(rr),length(cc));
% rr = rr(1:len);
% cc = cc(1:len);
% dist = (rr-y).^2+(cc-x).^2;
% cc = cc(dist<inradsq);
% rr = rr(dist<inradsq);
% samples.sx = cc';
% samples.sy = rr';
% samples.sw = w*ones(1,length(rr(:)));
% samples.sh = h*ones(1,length(rr(:)));
%%
[r,c] = meshgrid(minrow:step:maxrow,mincol:step:maxcol);
dist  = (y-r).^2+(x-c).^2;
ind = dist<inradsq;
c = c(ind==1);
r = r(ind==1);
samples.sx = c';
samples.sy = r';
samples.sw = w*ones(1,length(r(:)));
samples.sh = h*ones(1,length(r(:)));
