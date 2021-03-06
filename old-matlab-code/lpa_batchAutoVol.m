function lpa_batchAutoVol(directory)
  %Laser Pit Analysis - Batch Automatic Volume Calculation
  %Usage: lpa_batchAutoVol(directory);
  %
  %PURPOSE: To automatically determine the volume and depth of many laser ablation pits using data 
  %from a white light interferometric profilometer.
  %
  %INPUT ARGUMENT:
  % - directory - path to the directory containing ascii files with interferometer topographic data
  %   for the laser pits.
  %
  %OUTPUT FILES:
  % Files are output to a directory named 'directoryName_Batch_Output', which is located in the 
  % same parent directory that contains the specified data directory.
  % - Tab delimited file named 'directoryName_Batch_Results.txt', that contains calculation results.
  % - Plots generated by lpa_autoVol3.m during operation.
  %
  
  %Get list of files from the specified directory and make it a cell array.
  list = dir([directory,'/*.asc']); list = {list.name}; n = numel(list);
  %Prepare numeric array to receive volumn calculation results.
  data = zeros(n,11);
  %Prepare destination directory for plot figures and results.
  [path,dirName,~] = fileparts(directory); 
  if isempty(path)
    dest = [pwd,'/',dirName,'_Batch_Output'];
  else
    dest = [path,'/',dirName,'_Batch_Output'];
  end%if
  if isempty(dir(dest)), mkdir(dest); end%if
  %Create MDataFrame to contain the results.
  results = MDataFrame(data); 
  results.colnames = {'Lowest (�m)','Middle (�m)','Depth (�m)','X Cent (�m)','Y Cent (�m)',...
    'Top Radius (�m)','Vol at Radius (�m^3)','Int Half Range (�m)','Mean Int Vol (MIV, �m^3)',...
    '1SD Mean Int Vol (�m^3)','MIV*sqrt((1SD MIV/MIV)^2 + (0.5%)^2) (�m^3)'}; %'Bottom Radius (�m)',
  sampNames = cell(n,1); %Will keep track of sample names.
  results.rownames = sampNames;
  results.dataInfo.Notes = 'Data processed by lpa_autoVol3.m via lpa_batchAutoVol.m';
  results.dataInfo.Date_Processed = date;
  %Loop over every file in the specified directory. Display progress.
  fprintf('%%------------------------------------------------------------%%\n');
  fprintf('Analyzing data files in %s\n',dirName);
  fprintf('%%------------------------------------------------------------%%\n\n');
  for i = 1:n
    fprintf('%%----------------------------------------%%\n');
    fprintf('Processing file: %s (%i of %i)\n',list{i},i,n);
    fprintf('%%----------------------------------------%%\n');
    %Ingest data from file.
    fprintf('Ingesting file...\n');
    [dataset,xdim,ydim] = lpa_asciiprep([directory,'/',list{i}]);
    %Parse sample name from the file name. EDIT THIS IF YOU HAVE A DIFFERENT NAMING SCHEME!!!
%     temp = regexp(list{i},'_','split'); sampNames{i,1} = [temp{1},'_',temp{2}]; %Apollo samp scheme.
    [~,sampNames{i,1},~] = fileparts(list{i}); %Full file name scheme.
    %Launch lpa_autoVol3.
    [data(i,1),data(i,2),data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),data(i,8),...
      data(i,9),data(i,10)] = lpa_autoVol3(dataset,xdim,ydim,dest,sampNames{i,1}); %,data(i,11)
    data(i,11) = data(i,9)*sqrt((data(i,10)/data(i,9))^2+0.005^2);
    %Save results to file.
    results.data = data;
    fprintf('Saving results to file: %s\n',[dirName,'_batch_out.txt']);
    results.save('path',dest,'filename',[dirName,'_Batch_Results.txt'],'delim','\t',...
      'permission','w+');
    fprintf('%%----------------------------------------%%\n');
    fprintf('Done processing file: %s (%i of %i)\n',list{i},i,n);
    fprintf('%%----------------------------------------%%\n');
  end%for
  fprintf('\n%%------------------------------------------------------------%%\n');
  %Closing message.
  fprintf('All done!\n');
  fprintf('%%------------------------------------------------------------%%\n\n');
end%lpa_batchAutoVol