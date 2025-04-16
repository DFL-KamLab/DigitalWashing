function [M]=Feature_Vector(A)
% This function Calculates the Seven Invariant Moments for the image A
% the output of this function is a Vector M ; called the Feature vector
% the vector M is a column vector containing M1,M2,....M7

% First Moment
n20=Cent_Moment(2,0,A);
n02=Cent_Moment(0,2,A);
n30=Cent_Moment(3,0,A);
n12=Cent_Moment(1,2,A);
n21=Cent_Moment(2,1,A);
n03=Cent_Moment(0,3,A);
n11=Cent_Moment(1,1,A);


M1=n20+n02;

% Second Moment
% n20=Cent_Moment(2,0,A);
% n02=Cent_Moment(0,2,A);
M2=(n20-n02)^2 + 4*n11^2;

% Third Moment

M3=(n30-3*n12)^2+(3*n21-n03)^2;

% Fourth Moment
% n30=Cent_Moment(3,0,A);
% n12=Cent_Moment(1,2,A);
% n21=Cent_Moment(2,1,A);
% n03=Cent_Moment(0,3,A);
M4=(n30+n12)^2+(n21+n03)^2;

% Fifth Moment
% n30=Cent_Moment(3,0,A);
% n12=Cent_Moment(1,2,A);
% n21=Cent_Moment(2,1,A);
% n03=Cent_Moment(0,3,A);
M5=(n30-3*n12)*(n30+n12)*[(n30+n12)^2-3*(n21+n03)^2]+(3*n21-n03)*(n21+n03)*[3*(n30+n12)^2-(n21+n03)^2]; %

% Sixth Moment
% n20=Cent_Moment(2,0,A);
% n02=Cent_Moment(0,2,A);
% n30=Cent_Moment(3,0,A);
% n12=Cent_Moment(1,2,A);
% n21=Cent_Moment(2,1,A);
% n03=Cent_Moment(0,3,A);
% n11=Cent_Moment(1,1,A);
M6=(n20-n02)*[(n30+n12)^2-(n21+n03)^2]+4*n11*(n30+n12)*(n21+n03);

% Seventh Moment
% n30=Cent_Moment(3,0,A);
% n12=Cent_Moment(1,2,A);
% n21=Cent_Moment(2,1,A);
% n03=Cent_Moment(0,3,A);
M7=(3*n21-n03)*(n30+n12)*[(n30+n12)^2-3*(n21+n03)^2]-(n30-3*n12)*(n21+n03)*[3*(n30+n12)^2-(n21+n03)^2];

% The vector M is a column vector containing M1,M2,....M7
M = [M1    M2     M3    M4     M5    M6    M7]';



%and this is the Feature vector