function [vel,x,z,zlay,vlay]=flatmodel(dx,xmax,zmax,vhigh,vlow,nlayers,zlay)
% FlatMODEL : build a model representing a channel in a stratigraphic sequence
%
% [vel,x,z,zlay,vlay]=flatmodel(dx,xmax,zmax,vhigh,vlow,nlayers,flag,zlay)
%
% This function builds a velocity matrix representing a stratigraphic sequence. 
% The number of layers and the
% total model width and depth are specified. Layer thicknesses are chosen
% to fluctuate randomly about the nominal thickness of zmax/nlayers. Layer 
% velocities are chosen to grade uniformly from vmin to vmax. The
% model is created to use with the acoustic finite difference code.
%
% dx ... grid interval (distance between grid points in x and z)
% xmax ... maximum x coordinate (minimum is zero)
%  *********** default 2500 **********
% zmax ... maximum z coordinate (minimum is zero)
%  *********** default 1000 ************
% vhigh ... highest velocity used in the model
%  *********** default 4000 ************
% vlow ... lowest velocity used in the model
%  *********** default 2000 ************
% nlayers ... number of sedimentary layers
%  *********** default 4 *************
% zlay ... vector of layer depths
%  If provided, this overrides nlayers and flag
%  Must have at least 2 entries.
% ************ if not provided, then chosen randomly ********
%
% vel ... velocity model matrix
% x ... x coordinate vector for vel
% z ... z coordinate vector for vel
% zlay ... vector of layer depths
% vlay ... vector ov layer velocities
%
% NOTE: the simplest way to plot vel is: plotimage(vel-mean(vel(:)),z,x)
%


if(nargin<5)
    vlow=2000;
end
if(nargin<4)
    vhigh=4000;
end
if(nargin<3)
    zmax=1000;
end
if(nargin<2)
    xmax=2500;
end
if(nargin<6)
    nlayers=4;
end
if(nargin<7)
    zlay=[];
else
    flag2=0;
    if(length(zlay)<2)
        
       errordlg('must be at least two layers')
        vel=[];x=[];z=[];zlay=[];vlay=[];
        return;
    else
        zlay=sort(zlay);
    end
    test=diff(zlay);
    if(any(test<0))
        errordlg('layers must be in order of increasing depth')
        vel=[];x=[];z=[];zlay=[];vlay=[];return;
    end
    if ~flag2
    nlayers=length(zlay); %override nlayers
    end
end
%initialize
if(flag)
    thicknom=zmax/nlayers;
else
    thicknom=zmax/nlayers;%nominal thickness
end

x=0:dx:xmax;z=0:dx:zmax; % x and z coordinate vector
vrange=vhigh-vlow; % high and low velocities
vel=vhigh*ones(length(z),length(x));%initialize velocity matrix
xpoly=[-dx xmax+dx xmax+dx -dx]; 
vlay=zeros(nlayers,1);
vlay(end)=vhigh;
if(isempty(zlay))
    zlay=zeros(nlayers,1);   
    for k=2:nlayers
        tmp=thicknom*(rand(1)+.5);
        tmp=round(tmp/dx)*dx;
        zlay(k) = zlay(k-1)+tmp;    
        zpoly=[zlay(k-1)-dx zlay(k-1)-dx zlay(k) zlay(k)];
        vlay(k-1)=vlow+(k-1)*vrange/(nlayers);
        vel=afd_vmodel(dx,vel,vlay(k-1),xpoly,zpoly);%install layer
    end
else
    for k=2:nlayers
        zpoly=[zlay(k-1)-dx zlay(k-1)-dx zlay(k) zlay(k)];
        vlay(k-1)=vlow+(k-1)*vrange/(nlayers);
        vel=afd_vmodel(dx,vel,vlay(k-1),xpoly,zpoly);%install layer
    end
end

