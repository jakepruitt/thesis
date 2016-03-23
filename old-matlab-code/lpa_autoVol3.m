function [lowest,middle,depth,x_centFinal,y_centFinal,radius,intVol,runcBuff,meanIntVol,...
    intVolUncert] = lpa_autoVol3(dataset,xdim,ydim,destination,name)
  %Laser Pit Analysis - Volume Calculation
  %USAGE: [lowest,middle,depth,x_cent,y_cent,volume] = lpa_autoVol2(dataset,diameter,xdim,ydim,varargin)
  %
  %PURPOSE: To automatically determine the volume and depth of laser ablation pits using data 
  %from a white light interferometric profilometer.
  %
  %INPUT ARGUMENTS:
  % - dataset - can be one of the following: 
  %   (1) Filename of a .csv file compiled by lpa_asciiprep.m (or via lpa_launcher.m, which calls 
  %       lpa_asciiprep.m and rascii.m). 
  %   (2) A 960x752 (r,c) numeric matrix containing vertically concatenated (480x752) arrays of 
  %       interferometer output (3D data and "void" data).
  % - xdim, ydim - pixel dimensions, in nm, from ascii file header.
  % - destination - path to destination directory containing output files.
  % - name - sample name to prepend to output files.
  %
  %OUTPUT VARIABLES:
  % - lowest - Lowest point in laser pit relative to (calculated) zero surface.
  % - middle - Calculated middle depth of laser pit.
  % - depth  - Average depth of pit, ignoring pixels with z > 0, within pit radius of centroid.
  % - x_cent - Centroid of pit in x-direction (rows of dataset).
  % - y_cent - Centroid of pit in y-direction (columns of dataset).
  % - volume - Calculated volume of laser pit.
  %
  %OUTPUT FILES:
  % - Plot of centroid detection results: destination/name_centroidDetection.png.
  % - Plot of radius detection results: destination/name_radiusDetection#.png.
  % - Plot of categorized data in cylindrical coordinates: destination/name_categorized.fig.
  %
  %ACKNOWLEDGMENTS:
  % - This script uses Andrew W. Fitzgibbon, Maurizio Pilu, and Robert B. Fisher fitellipse.m script
  % to find the pit centroid; fitellipse.m is freely available at 
  % http://research.microsoft.com/en-us/um/people/awf/ellipse/
  % - This script uses a slightly modified version of Grzegorz Knor's waitinput.m script, 
  % which is freely available on the Matlab File Exchange: 
  % http://www.mathworks.com/matlabcentral/fileexchange
  % Also, the waitinput.m license may be found in the directory with this source code.
  %
  %DEVELOPMENT:
  % - Original script interferometer_volume.m written by Brian Montleone (July 17, 2010).
  % - Modified to create lpa_vol.m by Cameron M. Mercer (April 21, 2013).
  % - Modified to create lpa_autoVol.m, lpa_autoVol2.m, and lpa_autoVol3.m by Alka Tripathy and 
  % Cameron M. Mercer (November 20-30, 2013).
  % 
  
  %Make sure proper input argument(s) are given.
  if nargin < 1
    help(lpa_autoVol3); return;
  elseif nargin <= 3
    destination = pwd;
    name = 'lpa_autoVol3_out';
  end%if
  %Replace underscores in name with dashes.
  name(name=='_') = '-';
  
  %Set buffer value here (between 0-1).
  buffer = 0; 
  %Set true/false (0/1) value for applying ROI from centroid determination to global dataset. This
  %is usefull if there are pits adjacent to the one you are trying to analyze.
  applyROIglobally = 0;
  %Set radius detection and uncertainty determination buffer/step values here (units in µm).
  rdetLowerBuff = 5; rdetStep = 0.2; rdetMaxFrac = 0.65; 
  %Set curvature smoothing parameter for radius detection (looking for maxima in curvature of pit
  %volume vs. radius), and curvature magnitude threshold (as fraction) for identifying maxima.
  nSmooth = 3; curvThresh = 0.01;
  %rdetTol = 10; %Units in µm^3.
  runcFracBuff = 0.05; runcNsteps = 2^6;
  %Set pixel dimensions for integrations.
  dx = xdim/(752*1000); dy = ydim/(480*1000); %dx and dy in microns (pixel dimensions of data).
  %Read input file if dataset is a string; initialize x, y, z, z_void (units in nanometers).
  %Note: this may be done by calling [x,y,z] = lpa_xyzPrep(dataset).
  x = xdim/752*repmat(1:752,[480,1]);       %[nm/px]
  y = ydim/480*repmat((1:480)',[1,752]);    %[nm/px]

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
%   %Plot uncorrected pit data.
%   figure; plot3(x,y,z,'.'); title('Uncorrected Pit'); 
%   xlabel('X (microns)'); ylabel('Y (microns)'); zlabel('Z (microns)');
  %Find top surface of sample by taking the mode of the z-data; zero-out the surface.
  z = z - mode(z(z > ((max(z) + min(z))/2)));
%   %Plot zeroed pit data.
%   figure; plot3(x,y,z,'.'); title('Pit Top Surface = 0'); 
%   xlabel('X (microns)'); ylabel('Y (microns)'); zlabel('Z (microns)');
  
  %%THIS COULD BE DRASTICALLY IMPROVED! GET AVERAGE DEPTH OVER SOME AREA, AFTER FINDING CENTROIDS.
  %Initialize lowest and middle output arguments. 
  lowest = min(z); middle = lowest/2;
  
%   %Get user input to determine initial guess for the centroid.
%   f = figure; plot(x(z<0),y(z<0),'b.',x(z>0),y(z>0),'r.');
%   xlabel('X (microns)'); ylabel('Y (microns)');title('Zeroed data: please pick the centroid.');
%   [x_centFinal,y_centFinal] = ginput(1); close(f);
%   fprintf('You specified:\nx: %f\ny: %f\nOptimizing centroid',x_centInit,y_centInit);

  fprintf('Determining pit centroid...\n');
  %Find centroid of laser pit. First, isolate all x and y points that are within ± wht (see below)
  %microns from the middle depth of the pit, then take mean of the x and y values in that wafer.
  wht = 0.5; %wafer half thickness
  x_cent_range = x(z > middle - wht & z < middle + wht); x_centInit = mean(x_cent_range);
  y_cent_range = y(z > middle - wht & z < middle + wht); y_centInit = mean(y_cent_range);
  
  %Get user to specify ROI if they want to.
  if applyROIglobally == 0
    f = figure; plot(x_cent_range,y_cent_range,'b.');
  else
    f = figure; plot(x(z<0),y(z<0),'b.',x(z>0),y(z>0),'r.');
  end%if
  xlabel('X (microns)'); ylabel('Y (microns)');title('Pick an ROI for Centroid Determination?');
  choice = waitinput('Do you want to select an ROI for centroid detection (y/N)? 5 sec...',5,'s');
  if strcmp(choice,'y') || strcmp(choice,'Y') || strcmp(choice,'yes') || strcmp(choice,'Yes')
    x_cent_rangeInit = x_cent_range; y_cent_rangeInit = y_cent_range;
    title('Specify an ROI. Double click the ROI when done.');
    sel = imrect(); pos = wait(sel);
    x_cent_range = x_cent_rangeInit(x_cent_rangeInit>pos(1) & x_cent_rangeInit<pos(1)+pos(3) & ...
      y_cent_rangeInit>pos(2) & y_cent_rangeInit<pos(2)+pos(4));
    y_cent_range = y_cent_rangeInit(x_cent_rangeInit>pos(1) & x_cent_rangeInit<pos(1)+pos(3) & ...
      y_cent_rangeInit>pos(2) & y_cent_rangeInit<pos(2)+pos(4));
    delete(sel); clear x_cent_rangeInit y_cent_rangeInit;
    if applyROIglobally == 1
      xInit = x; yInit = y; zInit = z;
      x = xInit(xInit>pos(1) & xInit<pos(1)+pos(3) & yInit>pos(2) & yInit<pos(2)+pos(4));
      y = yInit(xInit>pos(1) & xInit<pos(1)+pos(3) & yInit>pos(2) & yInit<pos(2)+pos(4));
      z = zInit(xInit>pos(1) & xInit<pos(1)+pos(3) & yInit>pos(2) & yInit<pos(2)+pos(4));
      clear xInit yInit zInit;
    end%if
  end%if
  close(f);
  
  %Use Fitzgibbon et al., 1999 fitellipse.m script to find center of ellipse that fits the wafer.
  a = fitellipse(x_cent_range,y_cent_range); th = linspace(0,2*pi,60)'; %a = ellipse parameters.
  x_centFinal = a(1); y_centFinal = a(2); %Ellipse center points.
  ax1 = a(3); ax2 = a(4); phi = a(5); %Ellipse axes and rotation angle.
  %Generate plotable data for ellipse.
  X = x_centFinal + ax1*cos(th)*cos(phi) - ax2*sin(th)*sin(phi);
  Y = y_centFinal + ax1*cos(th)*sin(phi) + ax2*sin(th)*cos(phi);
  h = figure; plot(x_cent_range,y_cent_range,'b.',x_centInit,y_centInit,'ro',...
    x_centFinal,y_centFinal,'k*',X,Y,'k-'); 
  title(['Centroid Determination for ',name]); xlabel('X (microns)'); ylabel('Y (microns)'); 
  saveas(h,[destination,'/',name,'_centroidDetection.png']); close(h);
%   fprintf('Initial guess at centroid:\nx: %f\ny: %f\nOptimizing centroid',x_centInit,y_centInit);

%   %Try a range of x,y-centroid options to minimize variance in minimum radius where pixels are above
%   %the zero-surface.
%   step = 0.5; halfRange = 6;
%   x_cent = repmat((x_centInit-halfRange):step:(x_centInit+halfRange),2*halfRange/step+1,1);
%   x_cent = x_cent(:);
%   y_cent = repmat((y_centInit-halfRange):step:(y_centInit+halfRange),1,2*halfRange/step+1);
%   y_cent = y_cent(:);
%   %Optimize x-y centroid.
%   resid = zeros(numel(x_cent),1);
%   for i = 1:numel(x_cent)
%     if mod(i,floor(numel(x_cent)/10)) == 0, fprintf('.'); end%if
%     %'Center' x and y data.
%     x_temp = x - x_cent(i); y_temp = y - y_cent(i);
%     %Convert data to cylindrical coordinates, with 0 > theta > 360, r > 0.
%     r = sqrt(x_temp.^2 + y_temp.^2); theta = zeros(numel(x_temp),1);
%     theta(x_temp>=0 & y_temp>=0) = atan(y_temp(x_temp>=0 & y_temp>=0)./x_temp(x_temp>=0 & y_temp>=0))*180/pi;
%     theta(x_temp>=0 & y_temp<0) = 360 - atan(abs(y_temp(x_temp>=0 & y_temp<0))./x_temp(x_temp>=0 & y_temp<0))*180/pi;
%     theta(x_temp<0 & y_temp>=0) = 180 - atan(y_temp(x_temp<0 & y_temp>=0)./abs(x_temp(x_temp<0 & y_temp>=0)))*180/pi;
%     theta(x_temp<0 & y_temp<0) = 180 + atan(abs(y_temp(x_temp<0 & y_temp<0))./abs(x_temp(x_temp<0 & y_temp<0)))*180/pi;
%     %Check bins of theta values for minimum radius where pixel is above the zero-surface.
%     binWidth = 30; minR = zeros(360/binWidth,1);
% %     modeR = zeros(360/binWidth,1); optimBuffer = 10;
%     for j = 1:numel(minR)
%       minTheta = binWidth*(j-1); maxTheta = binWidth*j;
%       minR(j) = min(r(z>0 & theta>=minTheta & theta<maxTheta));
% %       minRgtz = min(r(z>0 & theta>=minTheta & theta<maxTheta)); %Minimum r with z > 0 in this bin.
% %       modeR(j) = mode(r(z>0 & r>minRgtz & r<minRgtz+optimBuffer));
%     end%for
%     resid(i) = sum((minR - min(minR))); %.^2
% %     resid(i) = sum((modeR - min(modeR))); 
%   end%for
%   x_centFinal = x_cent(resid==min(resid));
%   y_centFinal = y_cent(resid==min(resid));
%   fprintf(' Done!\n');
% %   fprintf('Done!\nNow Using:\nx: %f\ny: %f\n',x_centFinal,y_centFinal);
% %   figure; plot(x_cent,resid);
% %   return;

  %Center x and y data with optimized centroid values.
  x = x - x_centFinal; y = y - y_centFinal;
  %Convert data to cylindrical coordinates, with 0 > theta > 360, r > 0.
  r = sqrt(x.^2 + y.^2); theta = zeros(numel(x),1);
  theta(x>=0 & y>=0) = atan(y(x>=0 & y>=0)./x(x>=0 & y>=0))*180/pi;
  theta(x>=0 & y<0) = 360 - atan(abs(y(x>=0 & y<0))./x(x>=0 & y<0))*180/pi;
  theta(x<0 & y>=0) = 180 - atan(y(x<0 & y>=0)./abs(x(x<0 & y>=0)))*180/pi;
  theta(x<0 & y<0) = 180 + atan(abs(y(x<0 & y<0))./abs(x(x<0 & y<0)))*180/pi;

%   %Plot centered and zeroed laser pit data, color coded for above/below z = zero.
%   figure; plot3(x(z<0),y(z<0),z(z<0),'b.',x(z>0),y(z>0),z(z>0),'r.'); 
%   title('Centered and Zeroed Pit'); xlabel('X (microns)'); ylabel('Y (microns)'); zlabel('Z (microns)');
  
%   %Plot color coded data for above/below z = zero in cylindrical coordinates.
%   figure; plot3(r(z<0),theta(z<0),z(z<0),'b.', r(z>0),theta(z>0),z(z>0),'r.');
%   title('Cylindrical Coordinates Greater than and Less than Zero');
%   xlabel('Radius (microns)'); ylabel('Theta (degrees)'); zlabel('Z (microns)');
  
  %Automatically detect the pit radius by integrating the volume of the pit.
  fprintf('Determining Pit Radius...');
  rMinGTZ = floor(min(r(z>=0))); %Minimum radius with a pixel above zero.
  %Set detection mesh about rMinGTZ.
  radiiDet = (rMinGTZ-rdetLowerBuff):rdetStep:(rdetMaxFrac*max(r));
  %Prep array for volumes calculated during radius detection.
  detVols = zeros(numel(radiiDet),1); 
  for d = 1:numel(radiiDet)
    %Calculate the volume of the pit by integration (ignore values with z >= 0).
    detVols(d) = sum(-z(z<0 & r<radiiDet(d))*dx*dy);
  end%for
%   %Scan over results to find radius where change in volume is below the specified tolerance.
%   radius = rMinGTZ;
%   for s = 2:numel(detVols)
%     if detVols(s) - detVols(s-1) < rdetTol
%       radius = radiiDet(s); break;
%     end%if
%   end%for
  %Find minimum in the dVdr (slope) of the detVols vs. radiiDet curve.
  dVdr = smooth(diff(detVols),7); %radius = radiiDet(find(dVdr==min(dVdr))+1);
  %Find minimum in third derivative of detVols. Ignored unsmoothed end points.
  d2Vdr2 = smooth(diff(dVdr),7); 
  %Find maximum of curvature, k; smooth k multiple times to keep most robust peaks.
  %See wikipedia: http://en.wikipedia.org/wiki/Curvature#Curvature_of_a_graph
  k = abs(d2Vdr2) ./ (1 + dVdr(2:end).^2).^1.5; 
  for i = 1:nSmooth
    k = smooth(k);
  end%for
  maxima = findmaxima(k) + 2;
  %Find the first maximum that is over 10% of the range of values of k.
  radius = radiiDet(maxima(find(k(maxima)>min(k)+curvThresh*range(k),1,'first')));
  fprintf(' Done!\n');
  %Plot radius detection results.
  h = figure; plot(radiiDet,detVols,[radius,radius],[min(detVols),max(detVols)]);
  title(['Auto-Detected Pit Radius for ',name,': r = ',num2str(radius),' µm']);
  xlabel('Radius (microns)'); ylabel('Volume (cubic microns)');
  saveas(h,[destination,'/',name,'_radiusDetection1.png']); close(h);
  h = figure; plot(radiiDet(2:end),dVdr,[radius,radius],[min(dVdr),max(dVdr)]);
  title(['Auto-Detected Pit Radius for ',name,': r = ',num2str(radius),' µm']);
  xlabel('Radius (microns)'); ylabel('dV/dr (square microns)');
  saveas(h,[destination,'/',name,'_radiusDetection2.png']); close(h);
%   h = figure; plot(radiiDet(3:end),d2Vdr2,[radius,radius],[min(d2Vdr2),max(d2Vdr2)]);
%   title(['Auto-Detected Pit Radius for ',name,': r = ',num2str(radius),' µm']);
%   xlabel('Radius (microns)'); ylabel('d2V/dr2 (microns)');
%   saveas(h,[destination,'/',name,'_radiusDetection3.png']); close(h);
  h = figure; plot(radiiDet(3:end),k,radiiDet(maxima),k(maxima),'ro',...
    [radius,radius],[min(k),max(k)]);
  title(['Auto-Detected Pit Radius for ',name,': r = ',num2str(radius),' µm']);
  xlabel('Radius (microns)'); ylabel('Curvature of Volume');
  saveas(h,[destination,'/',name,'_radiusDetection3.png']); close(h);

  %Separate data considered 'within' the pit (p) from those 'outside' the pit (o).
%   r_p = r(r < min(r(z>=0)) + buffer*diam); t_p = theta(r < min(r(z>=0)) + buffer*diam);
%   z_p = z(r < min(r(z>=0)) + buffer*diam);
%   r_o = r(r >= min(r(z>=0)) + buffer*diam); t_o = theta(r >= min(r(z>=0)) + buffer*diam);
%   z_o = z(r >= min(r(z>=0)) + buffer*diam);
%   r_p = r(r < diam/2 + buffer*diam); t_p = theta(r < diam/2 + buffer*diam);
%   z_p = z(r < diam/2 + buffer*diam);
%   r_o = r(r >= diam/2 + buffer*diam); t_o = theta(r >= diam/2 + buffer*diam);
%   z_o = z(r >= diam/2 + buffer*diam);
%   %Separate data, but add 2 µm buffer for several volume integrations to get grip on uncertainty.
%   r_p = r(r < diam/2 + runcBuff); t_p = theta(r < diam/2 + runcBuff);
%   z_p = z(r < diam/2 + runcBuff);
%   r_o = r(r >= diam/2 + runcBuff); t_o = theta(r >= diam/2 + runcBuff);
%   z_o = z(r >= diam/2 + runcBuff);
  %Plot separated data in cylindrical coordinates, color coded.
  h = figure; %set(h,'Visible','off'); 
  plot3(r(r<radius & z<0),theta(r<radius & z<0),z(r<radius & z<0),'.',...
    r(r>=radius & z<0),theta(r>=radius & z<0),z(r>=radius & z<0),'.',...
    r(z>=0),theta(z>=0),z(z>=0),'.'); 
  view(0,90); title(['Cylindrical Coordinates Sorted Data for ',name]);
  xlabel('Radius (microns)'); ylabel('Theta (degrees)'); zlabel('Z (microns)');
  saveas(h,[destination,'/',name,'_categorized.png']);
  saveas(h,[destination,'/',name,'_categorized.fig']); close(h);
%   %Record the radius of the pit.
%   radius = max(r_p);
%   radius = diam/2;
  %Calculate the average depth of the pit (ignore z > 0; rim or plateau material).
%   depth = mean(z_p(z_p<0));
  depth = mode(z(r<radius & z<middle));
%   figure; hist(z_p(z_p<middle),20);
  %Integrate pit volume for many possible radii to estimate the volume uncertainty.
  runcBuff = round(20*radius*runcFracBuff)/10; runcStep = 2*runcBuff/(runcNsteps-1);
  radii = (radius-runcBuff):runcStep:(radius+runcBuff);
  nIntegrations = numel(radii);
  intVols = zeros(nIntegrations,1);
  for i = 1:numel(radii)
    %Calculate the volume of the pit by integration (ignore values with z >= 0).
    intVols(i) = sum(-z(z<0 & r<radii(i))*dx*dy);
  end%for
  %Take mean and stdev of intVols to estimate final volume uncertainty.
  intVol = intVols(ceil(numel(intVols)/2));
  meanIntVol = mean(intVols); intVolUncert = std(intVols);
%   figure; plot(radii,intVols);
  
%   fprintf('\nVol of entire scan: %f\n',sum(-z(z<0)*dx*dy));

  %Calculate the volume of the pit geometrically, pi*r^2*depth.
%   geomVol = -pi*(radius - buffer*diam)^2*depth;
  geomVol = -pi*(radius)^2*depth;
  %geomVol = -numel(r_p(z_p<0))*dx*dy*mean(z_p(z_p<0));
%   %Convert pit data back into x-y coordinates.
%   x_p = zeros(numel(r_p),1); y_p = x_p; rad = pi/180;
%   x_p(t_p>=0 & t_p<=90) = r_p(t_p>=0 & t_p<=90).*cos(t_p(t_p>=0 & t_p<=90)*rad);
%   y_p(t_p>=0 & t_p<=90) = r_p(t_p>=0 & t_p<=90).*sin(t_p(t_p>=0 & t_p<=90)*rad);
%   x_p(t_p>90 & t_p<=180) = -r_p(t_p>90 & t_p<=180).*cos(pi-t_p(t_p>90 & t_p<=180)*rad);
%   y_p(t_p>90 & t_p<=180) = r_p(t_p>90 & t_p<=180).*sin(t_p(t_p>90 & t_p<=180)*rad);
%   x_p(t_p>180 & t_p<=270) = -r_p(t_p>180 & t_p<=270).*cos(t_p(t_p>180 & t_p<=270)*rad-pi);
%   y_p(t_p>180 & t_p<=270) = -r_p(t_p>180 & t_p<=270).*sin(t_p(t_p>180 & t_p<=270)*rad-pi);
%   x_p(t_p>270 & t_p<=360) = r_p(t_p>270 & t_p<=360).*cos(2*pi-t_p(t_p>270 & t_p<=360)*rad);
%   y_p(t_p>270 & t_p<=360) = -r_p(t_p>270 & t_p<=360).*sin(2*pi-t_p(t_p>270 & t_p<=360)*rad);
%   %Convert outside-pit data back into x-y coordinates.
%   x_out = zeros(numel(r_o),1); y_out = x_out;
%   x_out(t_o>=0 & t_o<=90) = r_o(t_o>=0 & t_o<=90).*cos(t_o(t_o>=0 & t_o<=90)*rad);
%   y_out(t_o>=0 & t_o<=90) = r_o(t_o>=0 & t_o<=90).*sin(t_o(t_o>=0 & t_o<=90)*rad);
%   x_out(t_o>90 & t_o<=180) = -r_o(t_o>90 & t_o<=180).*cos(pi-t_o(t_o>90 & t_o<=180)*rad);
%   y_out(t_o>90 & t_o<=180) = r_o(t_o>90 & t_o<=180).*sin(t_o(t_o>90 & t_o<=180)*rad);
%   x_out(t_o>180 & t_o<=270) = -r_o(t_o>180 & t_o<=270).*cos(t_o(t_o>180 & t_o<=270)*rad-pi);
%   y_out(t_o>180 & t_o<=270) = -r_o(t_o>180 & t_o<=270).*sin(t_o(t_o>180 & t_o<=270)*rad-pi);
%   x_out(t_o>270 & t_o<=360) = r_o(t_o>270 & t_o<=360).*cos(2*pi-t_o(t_o>270 & t_o<=360)*rad);
%   y_out(t_o>270 & t_o<=360) = -r_o(t_o>270 & t_o<=360).*sin(2*pi-t_o(t_o>270 & t_o<=360)*rad);
%   %Plot all data, color coded for 'within' or 'outside' pit.
%   figure; plot3(x_p,y_p,z_p,'b.',x_out,y_out,z_o,'g.',x(z>=0),y(z>=0),z(z>=0),'r.');
%   title('Sorted Pit XYZ'); xlabel('X (microns)'); ylabel('Y (microns)'); zlabel('Z (microns)');
%   %Plot just the measured pit.
%   figure; plot3(x_p(z_p<0),y_p(z_p<0),z_p(z_p<0),'.');
%   title('Measured Pit'); xlabel('X (microns)'); ylabel('Y (microns)'); zlabel('Z (microns)');
  
  %Change sign of returned depths.
  lowest = -lowest; middle = -middle; depth = -depth;
  
  %If nargout ~= 5, print output arguments.
  fprintf('\nLowest Point (µm): %f\nMiddle Depth (µm): %f\nX_centroid (µm): %f\n',...
    lowest,middle,x_centFinal);
  fprintf('Y_centroid (µm): %f\nPit Radius (µm): %f\nDepth (µm): %f\n',y_centFinal,radius,depth); 
  fprintf('Integrated Volume at Detected Radius (µm^3): %f\n',intVol);
  fprintf('Mean Integrated Volume ± 1SD (µm^3, n = %i): %f ± %f\n',...
    nIntegrations,meanIntVol,intVolUncert);
  fprintf('Geometric Volume (µm^3): %f\n\n',geomVol);
%   %Export csv of data.
%   dlmwrite('lpa_vol_out.csv',[lowest,middle,depth,radius,intVol,geomVol],'delimiter',',',...
%     'precision','%8.5f');
end%lpa_vol

