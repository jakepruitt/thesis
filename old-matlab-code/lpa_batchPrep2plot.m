function lpa_batchPrep2plot(directory)
  %Usage: lpa_batchPrep2plot(directory)
  %
  %ARGUMENTS:
  % - directory - the folder containing ascii files of interferometer data.
  %
  
  %Get list of directory contents.
  list = dir([directory,'/*.asc']);
  list = {list.name}; 
  n = numel(list);
  %Loop over ascii files and prep them for plotting with Mathematica.
  fprintf('%%------------------------------------------------------------%%\n');
  fprintf('Preparing data files for plotting from %s\n',directory);
  fprintf('%%------------------------------------------------------------%%\n\n');
  for i = 1:n
    fprintf('Processing file: %s (%i of %i)... ',list{i},i,n);
    prep2plot([directory,'/',list{i}]);
    fprintf('Done.\n');
  end%for
  fprintf('\n%%------------------------------------------------------------%%\n');
  fprintf('All done!\n');
  fprintf('%%------------------------------------------------------------%%\n\n');
end%lpa_batchPrep2plot