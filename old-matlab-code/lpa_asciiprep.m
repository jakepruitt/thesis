function [data,xdim,ydim] = lpa_asciiprep(filename)
  %Usage: data = lpa_asciiprep(filename)
  %
  %Laser Pit Analysis - Prepare ascii file
  %
  %Prepares an ascii file output by the interferometer for analysis using Brian Montleone's
  %interferometer_depth2.m and interferometer_volume_calc_July_17_2010_singleinput.m scripts. This
  %script requires the ingest_ascii.m and rascii.m scripts.
  %
  %Created: 04/18/2013
  %
  
  %Read header information in ascii file.
  [xdim,ydim,nhl,ndl] = chascii(filename);
  %Read in numerical data from ascii file (calls ingest_ascii.m, which calls rascii.m).
  data = ingest_ascii(filename,nhl,ndl); 
  %Save data as a csv file for interferometer_depth2.m to read if nargout == 0.
  if nargout == 0;
    [path,name,~] = fileparts(filename);
    if isempty(path)
      foutName = [name,'_lpa_input.csv'];
    else
      foutName = [path,'/',name,'_lpa_input.csv'];
    end%if
    csvwrite(foutName,data);
  end%if
end%lpa_asciiprep