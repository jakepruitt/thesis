function prep2plot(filename)
  %Usage: prep2plot(data,file2save)
  %
  %ARGUMENTS:
  % - filename  - name of input file.
  %
  
  %Ingest datafile
  [data,xdim,ydim] = lpa_asciiprep(filename);
  
  %Trim array only to topography data; ignore clipping mask.
  data = data(1:480,:)/1000;
  
  %Find top surface of sample by taking the mode of the z-data; zero-out the surface.
  z = data(:);
  data = data - mode(z(z > ((max(z) + min(z))/2)));
  
  %Generate x-y meshgrid.
  x = linspace(0,xdim/1000,752);
  y = linspace(0,ydim/1000,480);
  [xmesh,ymesh] = meshgrid(x,y);
  
  data = [data;xmesh;ymesh];
  
  %Print x and y dimensions.
%   fprintf('xdim = %d\nydim = %d\n',xdim,ydim);
  
  %Save file.
  [path,name,~] = fileparts(filename);
  if isempty(path)
    foutName = [name,'_lpa_2plot.csv'];
  else
    foutName = [path,'/',name,'_lpa_2plot.csv'];
  end%if
  csvwrite(foutName,data);
  
end%prep2plot function.