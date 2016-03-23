function lpa_launcher(filename,diam,script,tag)
  %Usage: lpa_launcher(filename,diam,script,tag)
  %
  %Laser Pit Analysis - Launch analysis scripts.
  %Prepares file (type specified by tag) for laser pit depth analysis and launches Brian Montleone's
  %script interferometer_depth2.m.
  %
  %INPUT ARGUMENTS:
  % - filename - Name of file containing interferometer data.
  % - diam - Diameter of laser pit.
  % - script - String specifying what type of analysis to do (depth2, volume).
  % - tag - String specifying the filetype for the input data (ascii).
  %
  %Created:  04/18/2013
  %Modified: 04/23/2013
  %
  
  %Check number of input arguments.
  if nargin == 0
    help(lpa_launcher);
    return;
  elseif nargin < 4
    tag = 'ascii'; %Assume this if tag not supplied.
  end%if
  %Switch on filetype tag to prepare data (more to come later).
  switch tag
    case 'ascii'
      %Prep ascii file.
      [data,xdim,ydim] = lpa_asciiprep(filename);
  end%switch
  %Switch on script type to launch appropriate script.
  switch script
    case {'Depth2','depth2'}
      %Launch interferometer_depth2.m
      interferometer_depth2;
    case 'autoVol'
      %Call lpa_autoVol, pass ingested data.
      lpa_autoVol(data,diam,xdim,ydim);
    case 'autoVol2'
      %Call lpa_autoVol2, pass ingested data.
      lpa_autoVol2(data,xdim,ydim);
    case {'Vol','vol','Volume','volume'}
      %Call lpa_vol, pass ingested data.
      lpa_vol(data,diam,xdim,ydim);
    case {'std_height','Std_height'}
      %Call lpa_hStd (interferometer height standard), pass ingested data.
      lpa_hstd(data,'suppress',1);
  end%switch
end%lpa_launchDepth2