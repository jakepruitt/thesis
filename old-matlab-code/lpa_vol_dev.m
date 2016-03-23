function [lowest,middle,depth,x_cent,y_cent,volume] = lpa_vol_dev(dataset,diam,varargin)
  %Laser Pit Analysis - Volume Calculation
  %USAGE: [lowest,middle,depth,x_cent,y_cent,volume] = lpa_vol(dataset,diameter,varargin)
  %
  %PURPOSE: To determine the volume and depth of laser ablation pits using data from a white light
  %interferometric profilometer.
  %
  %INPUT ARGUMENTS:
  % - dataset - can be one of the following: 
  %   (1) Filename of a .csv file compiled by lpa_asciiprep.m (or via lpa_launcher.m, which calls 
  %       lpa_asciiprep.m and rascii.m). 
  %   (2) A 960x752 (r,c) numeric matrix containing vertically concatenated (480x752) arrays of 
  %       interferometer output (3D data and "void" data).
  % - diam - User-specified pit diameter.
  % - varargin - TO COME LATER: geometric region drawn, e.g. in LaSSiE, with image analysis tools to
  %   specify boundary of laser pit (square or circular).
  %
  %OUTPUT VARIABLES:
  % - lowest - Lowest point in laser pit relative to (calculated) zero surface.
  % - middle - Calculated middle depth of laser pit.
  % - depth  - Average depth of pit, ignoring pixels with z > 0, within pit radius of centroid.
  % - x_cent - Centroid of pit in x-direction (rows of dataset).
  % - y_cent - Centroid of pit in y-direction (columns of dataset).
  % - volume - Calculated volume of laser pit.
  %
  %DEVELOPMENT:
  % - Original script interferometer_volume.m written by Brian Montleone (July 17, 2010).
  % - Modified by Cameron M. Mercer (April 21, 2013).
  %
  
  %Set buffer value here (between 0-1).
  buffer = 0.08;
  
  %Make sure proper input argument(s) are given.
  if nargin < 1
    help(lpa_vol); return;
  end%if
  %Read input file if dataset is a string; initialize x, y, z, z_void (units in nanometers).
  %Note: this may be done by calling [x,y,z] = lpa_xyzPrep(dataset).
%   x = 275103/752*repmat(1:752,[480,1]); 
%   y = 204606/480*repmat((1:480)',[1,752]);
  x = 171939/752*repmat(1:752,[480,1]);       %[nm/px]
  y = 127879/480*repmat((1:480)',[1,752]);    %[nm/px]
  if ischar(dataset)
    z = csvread(dataset,0,0,[0,0,479,751]);
    z_void = csvread(dataset,480,0,[480,0,959,751]);
  else
    if size(dataset,1) > 480
      z = dataset(1:480,1:752); z_void = dataset(481:960,1:752);
    else
      %If clipping mask was not provided, assume all pixels should be kept.
      z = dataset(1:480,1:752); z_void = zeros(480,752);
    end%if
  end%if
  %Transform everything into column vectors.
  x = x(:); y = y(:); z = z(:); z_void = z_void(:);
  %Truncate (clip) variables to keep data where z_void == 0; convert to microns from nm.
  x = x(z_void == 0)./1000; y = y(z_void == 0)./1000; z = z(z_void == 0)./1000; %[µm/px]
  %Plot uncorrected pit data.
  figure; plot3(x,y,z,'.'); title('Uncorrected Pit'); 
  xlabel('X (microns)'); ylabel('Y (microns)'); zlabel('Z (microns)');
  %Find top surface of sample by taking the mode of the z-data; zero-out the surface.
  z = z - mode(z(z > ((max(z) + min(z))/2)));
  %Plot zeroed pit data.
  figure; plot3(x,y,z,'.'); title('Pit Top Surface = 0'); 
  xlabel('X (microns)'); ylabel('Y (microns)'); zlabel('Z (microns)');
  
  %%THIS COULD BE DRASTICALLY IMPROVED! GET AVERAGE DEPTH OVER SOME AREA, AFTER FINDING CENTROIDS.
  %Initialize lowest and middle output arguments. 
  lowest = min(z); middle = lowest/2;
  
  %Get user input to determine the centroid.
  figure; plot(x(z<0),y(z<0),'b.',x(z>0),y(z>0),'r.'); daspect([1,1,1]);
  xlabel('X (microns)'); ylabel('Y (microns)');title('Zeroed data: please pick the centroid.');
  [x_cent,y_cent] = ginput(1);
  if isempty(x_cent) && isempty(y_cent)
    %Find centroid of laser pit. First, isolate all x and y points that are within ± wht (see below)
    %microns from the middle depth of the pit, then take mean of the x and y values in that wafer.
    wht = 1.0; %waffer half thickness
    z_cent_range = z(z > middle - wht & z < middle + wht);
    x_cent_range = x(z > middle - wht & z < middle + wht); x_cent = mean(x_cent_range);
    y_cent_range = y(z > middle - wht & z < middle + wht); y_cent = mean(y_cent_range);
  end%if
%   %Plot x_cent and y_cent versus z_cent_range.
%   figure; plot(x_cent_range, z_cent_range,'g.'); title('Centroid X vs. Z');
%   xlabel('X (microns)'); ylabel('Depth (microns)');
%   figure; plot(y_cent_range, z_cent_range,'g.'); title('Centroid Y vs. Z');
%   xlabel('Y (microns)'); ylabel('Depth (microns)');

  %Prepare centroid arrays for looping.
  xCents = repmat((x_cent-2):(x_cent+2),5,1); xCents = xCents(:);
  yCents = repmat(transpose((y_cent-2):(y_cent+2)),1,5); yCents = yCents(:);
  %Launch into loop to test lots of centroids about the chosen point.
  for i = 1:25
    %Center x and y data.
    x = x - x_cent; y = y - y_cent;
    %Plot centered and zeroed laser pit data, color coded for above/below z = zero.
    figure; plot3(x(z<0),y(z<0),z(z<0),'b.',x(z>0),y(z>0),z(z>0),'r.');
    title('Centered and Zeroed Pit'); xlabel('X (microns)'); ylabel('Y (microns)'); zlabel('Z (microns)');
    %Convert data to cylindrical coordinates, with 0 > theta > 360, r > 0.
    r = sqrt(x.^2 + y.^2); theta = zeros(numel(x),1);
    theta(x>=0 & y>=0) = atan(y(x>=0 & y>=0)./x(x>=0 & y>=0))*180/pi;
    theta(x>=0 & y<0) = 360 - atan(abs(y(x>=0 & y<0))./x(x>=0 & y<0))*180/pi;
    theta(x<0 & y>=0) = 180 - atan(y(x<0 & y>=0)./abs(x(x<0 & y>=0)))*180/pi;
    theta(x<0 & y<0) = 180 + atan(abs(y(x<0 & y<0))./abs(x(x<0 & y<0)))*180/pi;
    %Plot color coded data for above/below z = zero in cylindrical coordinates.
    figure; plot3(r(z<0),theta(z<0),z(z<0),'b.', r(z>0),theta(z>0),z(z>0),'r.');
    title('Polar Coordinates Greater than and Less than Zero');
    xlabel('Radius (microns)'); ylabel('Theta (degrees)'); zlabel('Z (microns)');
    
    %EXPERIMENTAL: find pit edge automatically...
    %For every theta, take r elements with that theta and differentiate, find location of max.
    %   test = r(theta < 5 & theta >= 0); dtest = diff(test); disp(test(dtest==max(dtest)));
    %   disp(mode(r(z>-0.001&z<0.001)));
    
    %Separate data considered 'within' the pit (p) from those 'outside' the pit (o).
    r_p = r(r < min(r(z>=0)) + buffer*diam); t_p = theta(r < min(r(z>=0)) + buffer*diam);
    z_p = z(r < min(r(z>=0)) + buffer*diam);
    r_o = r(r >= min(r(z>=0)) + buffer*diam); t_o = theta(r >= min(r(z>=0)) + buffer*diam);
    z_o = z(r >= min(r(z>=0)) + buffer*diam);
    %Plot separated data in cylindrical coordinates, color coded.
    figure; plot3(r_p,t_p,z_p,'.',r_o,t_o,z_o,'.',r(z>=0),theta(z>=0),z(z>=0),'.');
    title('Polar Coordinates Sorted Data');
    xlabel('Radius (microns)'); ylabel('Theta (degrees)'); zlabel('Z (microns)');
    %Record the radius of the pit.
    radius = max(r_p);
    %Calculate the average depth of the pit (ignore z > 0; rim or plateau material).
    %   depth = mean(z_p(z_p<0));
    depth = mode(z_p(z_p<middle));
    figure; hist(z_p(z_p<middle),20);
    %Calculate the volume of the pit by integration (ignore values with z >= 0).
    dx = 275103/(752*1000); dy = 204606/(480*1000); %dx and dy in microns (pixel dimensions of data).
    intVol = sum(-z_p(z_p<0)*dx*dy);
    %Calculate the volume of the pit geometrically, pi*r^2*depth.
    %   geomVol = -pi*(radius - buffer*diam)^2*depth;
    geomVol = -numel(r_p(z_p<0))*dx*dy*mean(z_p(z_p<0));
    %Convert pit data back into x-y coordinates.
    x_p = zeros(numel(r_p),1); y_p = x_p; rad = pi/180;
    x_p(t_p>=0 & t_p<=90) = r_p(t_p>=0 & t_p<=90).*cos(t_p(t_p>=0 & t_p<=90)*rad);
    y_p(t_p>=0 & t_p<=90) = r_p(t_p>=0 & t_p<=90).*sin(t_p(t_p>=0 & t_p<=90)*rad);
    x_p(t_p>90 & t_p<=180) = -r_p(t_p>90 & t_p<=180).*cos(pi-t_p(t_p>90 & t_p<=180)*rad);
    y_p(t_p>90 & t_p<=180) = r_p(t_p>90 & t_p<=180).*sin(t_p(t_p>90 & t_p<=180)*rad);
    x_p(t_p>180 & t_p<=270) = -r_p(t_p>180 & t_p<=270).*cos(t_p(t_p>180 & t_p<=270)*rad-pi);
    y_p(t_p>180 & t_p<=270) = -r_p(t_p>180 & t_p<=270).*sin(t_p(t_p>180 & t_p<=270)*rad-pi);
    x_p(t_p>270 & t_p<=360) = r_p(t_p>270 & t_p<=360).*cos(2*pi-t_p(t_p>270 & t_p<=360)*rad);
    y_p(t_p>270 & t_p<=360) = -r_p(t_p>270 & t_p<=360).*sin(2*pi-t_p(t_p>270 & t_p<=360)*rad);
    %Convert outside-pit data back into x-y coordinates.
    x_out = zeros(numel(r_o),1); y_out = x_out;
    x_out(t_o>=0 & t_o<=90) = r_o(t_o>=0 & t_o<=90).*cos(t_o(t_o>=0 & t_o<=90)*rad);
    y_out(t_o>=0 & t_o<=90) = r_o(t_o>=0 & t_o<=90).*sin(t_o(t_o>=0 & t_o<=90)*rad);
    x_out(t_o>90 & t_o<=180) = -r_o(t_o>90 & t_o<=180).*cos(pi-t_o(t_o>90 & t_o<=180)*rad);
    y_out(t_o>90 & t_o<=180) = r_o(t_o>90 & t_o<=180).*sin(t_o(t_o>90 & t_o<=180)*rad);
    x_out(t_o>180 & t_o<=270) = -r_o(t_o>180 & t_o<=270).*cos(t_o(t_o>180 & t_o<=270)*rad-pi);
    y_out(t_o>180 & t_o<=270) = -r_o(t_o>180 & t_o<=270).*sin(t_o(t_o>180 & t_o<=270)*rad-pi);
    x_out(t_o>270 & t_o<=360) = r_o(t_o>270 & t_o<=360).*cos(2*pi-t_o(t_o>270 & t_o<=360)*rad);
    y_out(t_o>270 & t_o<=360) = -r_o(t_o>270 & t_o<=360).*sin(2*pi-t_o(t_o>270 & t_o<=360)*rad);
    %Plot all data, color coded for 'within' or 'outside' pit.
    figure; plot3(x_p,y_p,z_p,'b.',x_out,y_out,z_o,'g.',x(z>=0),y(z>=0),z(z>=0),'r.');
    title('Sorted Pit XYZ'); xlabel('X (microns)'); ylabel('Y (microns)'); zlabel('Z (microns)');
    %Plot just the measured pit.
    figure; plot3(x_p(z_p<0),y_p(z_p<0),z_p(z_p<0),'.');
    title('Measured Pit'); xlabel('X (microns)'); ylabel('Y (microns)'); zlabel('Z (microns)');
  end%for
  
  
  %If nargout ~= 5, print output arguments.
  fprintf('\nLowest Point (µm): %f\nMiddle Depth (µm): %f\nX_centroid (µm): %f\n',...
    lowest,middle,x_cent);
  fprintf('Y_centroid (µm): %f\nPit Radius (µm): %f\nDepth (µm): %f\n',y_cent,radius,depth); 
  fprintf('Integrated Volume (µm^3): %f\nGeometric Volume (µm^3): %f\n\n',intVol,geomVol);
  %Export csv of data.
  dlmwrite('lpa_vol_out.csv',[lowest,middle,depth,radius,intVol,geomVol],'delimiter',',',...
    'precision','%8.5f');
end%lpa_vol

