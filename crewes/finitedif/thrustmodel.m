function [vel,x,z]=thrustmodel(dx,xmax,zmax,vhigh,vlow,vbasement,targetflag)
% THRUSTMODEL : build a model representing a thrust sheet
%
% [vel,x,z]=thrustmodel(dx,xmax,zmax,vhigh,vlow,vbasement,targetflag)
%
% This function builds a velocity matrix representing a thrust sheet within 
% a lower velocity material. The model is created to use with the acoustic 
% finite difference code.
%
% dx ... grid interval (distance between grid points in x and z)
%  *********** default 10 ************
% xmax ... maximum x coordinate (minimum is zero)
%  *********** default 5100 **********
% zmax ... maximum z coordinate (minimum is zero)
%  *********** default 2500 ************
% vhigh ... velocity in the thrust sheet
%  *********** default 3145 ************
% vlow ... velocity of the surrounding material
%  *********** default 2500 ************
% vbasement ... velocity of the basement
%  *********** default 4000 ************
% targetflag ... if 1 put a small structure under the thrust
%  *********** default 1 **********
%
% vel ... velocity model matrix
% x ... x coordinate vector for vel
% z ... z coordinate vector for vel
%
% NOTE: the simplest way to plot vel is: plotimage(vel-mean(vel(:)),z,x)
%

if(nargin<7)
    targetflag=1;
end
if(nargin<6)
    vbasement=4000;
end
if(nargin<5)
    vlow=2500;
end
if(nargin<4)
    vhigh=3145;
end
if(nargin<3)
    zmax=2500;
end
if(nargin<2)
    xmax=5100;
end
if(nargin<1)
    dx=10;
end

%flood the model with vlow
nx=floor(xmax/dx)+1;
nz=floor(zmax/dx)+1;
x=(0:nx-1)*dx;
z=(0:nz-1)*dx;

vel=vlow*ones(nz,nx);

%put in basement (poly1)
xpoly=[-dx 1170 xmax+dx xmax+dx -dx];
zpoly=[1940 1940 1940 zmax+dx zmax+dx];
vel=afd_vmodel(dx,vel,vbasement,xpoly,zpoly);%install basement

% xpoly=[1400 1479 1590 1730 1925 2071 2255 2439 2568 2792 2998 3206 ... 
%         xmax+dx xmax+dx 990];
%     zpoly=[1802 1773 1751 1724 1714 1708 1708 1724 1729 1740 1743 1751 ...
%         1751 1940+dx 1940+dx];
%     zpoly=zpoly-100;
%     vel=afd_vmodel(dx,vel,vlow+(vhigh-vlow)/3,xpoly,zpoly);%target

%put in thrust sheet (poly2)
xpoly=[-dx 990.0 1170.0 -dx];
zpoly=[1410 1410 1940+dx 1940+dx];
vel=afd_vmodel(dx,vel,vhigh,xpoly,zpoly);%block 1

%put in thrust sheet (poly3)
xpoly=[990.0 1825.0 2165.0 1170.0-dx];
zpoly=[1410 920 1355 1940];
vel=afd_vmodel(dx,vel,vhigh,xpoly,zpoly);%block 2

%put in thrust sheet (poly4)
xpoly=[1825.0 2275.0 2700.0 2165.0];
zpoly=[920 390 725 1355];
vel=afd_vmodel(dx,vel,vhigh,xpoly,zpoly);%block 3

%put in thrust sheet (poly5)
xpoly=[2275.0 2500.0 3106.0 2700.0];
zpoly=[390 20 20 725];
vel=afd_vmodel(dx,vel,vhigh,xpoly,zpoly);%block 4

%target (poly6)
if(targetflag)
    xpoly=[1400 1479 1590 1730 1925 2071 2255 2439 2568 2792 2998 3206 ... 
        xmax+dx xmax+dx 990];
    zpoly=[1802 1773 1751 1724 1714 1708 1708 1724 1729 1740 1743 1751 ...
        1751 1940+dx 1940+dx];
    vel=afd_vmodel(dx,vel,(vhigh+vlow)/2,xpoly,zpoly);%target
end
