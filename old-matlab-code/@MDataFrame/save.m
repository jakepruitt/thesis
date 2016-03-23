function save(mdf,varargin)
  %save function: saves MDataFrame contents to a delimited file. Use tag-value pairs.
  %Tags: filename, path, {delimiter,delim}, permission, mods.
  %
  %Updated: 07/02/2012
  %Updated: 10/14/2012 - Can now properly save with different delimeters, e.g. \t, ',', etc.
  % -If Sample Info or Data Info are present, they are saved.
  %Updated: 10/28/2012 - Can now properly save metadata (sampleInfo, dataInfo) for merged datasets.
  %Updated: 02/19/2014 - Can now optionally export data delimited for a LaTeX ctable. 'Blank' no
  % longer written in upper left corner, now outputs 'Sample'.
  
  %Default tag values:
  destFileName = 'none';
  destPath = 'none';
  sDelim = mdf.delim;
  permission = 'w';
  mods = 0;
  ctable = 0;
  if mod(size(varargin,2),2) ~= 0
    fprintf('\nError: expecting string tag-value pairs.\n');
  else %If tag-value pairs are provided, take specified actions.
    if size(varargin,2) >= 2
      tagList = {'filename','path','delimiter','delim','permission'};
      for i = 1:2:size(varargin,2)
        tagChk = find(strcmp(varargin{i},tagList));
        switch varargin{i}
          case {'filename','Filename'}
            destFileName = varargin{i+1};
          case {'path','Path'}
            destPath = varargin{i+1};
          case {'delim','delimiter','Delim','Delimiter'}
            sDelim = varargin{i+1};
          case 'permission'
            permission = varargin{i+1};
          case 'mods' %Tag = mods (Use filename modifiers? 1 = yes, 0 = no.)
            if isnumeric(varargin{i+1})
              mods = varargin{i+1};
            elseif ischar(varargin{i+1})
              if strcmp(varargin{i+1},'yes'), mods = 1; else mods = 0; end%if
            end%if
          case 'ctable'
            if isnumeric(varargin{i+1})
              if varargin{i+1} ~=0 
                ctable = 1; sDelim = ' & ';
              end%if
            elseif ischar(varargin{i+1})
              if numel(find(strcmp(varargin{i+1},{'yes','Yes','y','Y'}))) > 0
                ctable = 1; sDelim = ' & ';
              end%if
            end%if
        end%switch
      end%for
    end%if
  end%if
  %If destFileName == 'none', generate filename; otherwise, will use specified name.
  if strcmp(destFileName,'none') == 1
    modifier = genMod(mdf); %modifier based on datasetType.
    if strcmp(modifier,'void') == 0
      destFileName = ['mdf_',mdf.datasetName,'_',modifier,'_',datestr(now,'mm_dd_yyyy'),'.txt'];
    else %For mdf.datasetType 'void' or any other string.
      destFileName = ['mdf_',mdf.datasetName,'_',datestr(now,'mm_dd_yyyy'),'.txt'];
    end%if
    %If filename exists, append number and retest, unless permission == 'a'.
    if strcmp(permission,'a') ~= 1
      iterations = 0;
      while exist(destFileName,'file') == 2
        if iterations == 0
          numSuffix = 1;
          trim = 4;
        else
          numSuffix = numSuffix + 1;
          trim = 5 + size(numSuffix,2);
        end%if
        destFileName = [destFileName(1:end-trim),'_',num2str(numSuffix),'.txt'];
        iterations = iterations + 1;
      end%while
    end%if
  else %If user specified a filename, append modifiers if prefs allow.
    if mods == 1
      modifier = genMod(mdf);
      if strcmp(modifier,'void') == 0
        [~,name,ext] = fileparts(destFileName);
        destFileName = strcat(name,'_',modifier,ext);
      end%if
    end%if
  end%if
  %If destPath ~= 'none', append it to front of destFileName
  if strcmp(destPath,'none') == 0
    destFileName = [destPath,'/',destFileName];
  end%if
  %Open file to write to. Change output format to long.
  fid = fopen(destFileName,permission);
  %REMOVE       format('long');
  %If sample info or data info exist, write in header of file unless exporting LaTeX ctable.
  if ctable == 0
    if ~isempty(mdf.sampleInfo)
      fprintf(fid,'Begin Sample Info\n');
      if iscell(mdf.sampleInfo)
        %Get merged metadata for sampleInfo.
        sInfo = mergeMetaData(mdf.sampleInfo);
        %Write to file.
        for s = 1:size(sInfo,1)
          fprintf(fid,[sInfo{s,1},sDelim,sInfo{s,2},'\n']);
        end%for
        clear sInfo;
      elseif isstruct(mdf.sampleInfo)
        %Get fields from mdf.sampleInfo.
        fields = fieldnames(mdf.sampleInfo);
        %Write to file.
        for s = 1:size(fields,1)
          fprintf(fid,[fields{s,1},sDelim,mdf.sampleInfo.(fields{s,1}),'\n']);
        end%for
      end%if
      fprintf(fid,'End Sample Info\n');
    end%if
    if ~isempty(mdf.dataInfo)
      fprintf(fid,'Begin Data Info\n');
      if iscell(mdf.dataInfo)
        %Get merged metadata for dataInfo.
        dInfo = mergeMetaData(mdf.dataInfo);
        disp(dInfo);
        %Write to file.
        for s = 1:size(dInfo,1)
          fprintf(fid,[dInfo{s,1},sDelim,dInfo{s,2},'\n']);
        end%for
        clear dInfo;
      elseif isstruct(mdf.dataInfo)
        %Get fields from mdf.dataInfo.
        fields = fieldnames(mdf.dataInfo);
        %Write to file.
        for d = 1:size(fields,1)
          fprintf(fid,[fields{d,1},sDelim,mdf.dataInfo.(fields{d,1}),'\n']);
        end%for
      end%if
      fprintf(fid,'End Data Info\n');
    end%if
  else %Writing a ctable, produce empty template at top of file.
    fprintf(fid,'\\ctable[sideways,center,doinside=\\small,caption={Table caption here.}]{');
    %Write dummy column specifiers.
    colWidth = 1/(size(mdf.colnames,2)+1); %Add one to account for rownames.
    for i=1:size(mdf.colnames,2)+1
      if i == 1
        fprintf(fid,'>{\\raggedright}p{%1.3f\\textwidth} ',colWidth);
      elseif i > 1
        fprintf(fid,'>{\\centering}p{%1.3f\\textwidth} ',colWidth);
      end%if
    end%for
    %Leave footnote text blank and open curly bracket for data.
    fprintf(fid,'}{}{\n\\hline\\hline\\addlinespace\n');
  end%if
  %Write header row.
  fprintf(fid,'%s','Sample');
  for i=1:size(mdf.colnames,2)
    fprintf(fid,[sDelim,'%s'],mdf.colnames{i});
  end%for
  if ctable == 1
    fprintf(fid,' \\ML\n');
  else
    fprintf(fid,'\n');
  end%if
  %Write rows of data with row ID in first column
  for j=1:size(mdf.rownames,1)
    fprintf(fid,'%s',mdf.rownames{j});
    for k=1:size(mdf.data,2)
      %If writing to a data file, use 15 decimal places; if to LaTeX ctable, print as is.
      if ctable == 0
        fprintf(fid,[sDelim,'%.15g'],mdf.data(j,k));
      else
        fprintf(fid,[sDelim,'%G'],mdf.data(j,k));
      end%if
    end%for
    if isempty(mdf.notes) == 0
      for n = 1:size(mdf.notes,2)
        fprintf(fid,[sDelim,'%s'],mdf.notes{j,n});
      end%for
    end%if
    if j < size(mdf.rownames,1)
      if ctable == 1
        fprintf(fid,' \\NN\n');
      else
        fprintf(fid,'\n');
      end%if
    elseif j == size(mdf.rownames,1) %Write end of table commands if writing LaTeX ctable file.
      if ctable == 1
        fprintf(fid,' \\NN\n\\hline\\hline\\addlinespace\n}');
      end%if
    end%if
  end%for
  %fprintf(fid,'\n');
  %Housekeeping.
  fclose(fid);
  %REMOVE       format('short');
  %Nested subfunction: genMod (generate filename modifier)
  function modifier = genMod(mdf)
    test = find(strcmp(mdf.datasetType,{'Raw Data','Data','High Uncertainty',...
      'Low Uncertainty','High/Low Uncertainty','Noblesse'}));
    if isempty(test) == 0
      switch test
        case 1 %For mdf.datasetType 'Raw Data'
          modifier = 'rawDat';
        case 2 %For mdf.datasetType 'Data'
          modifier = 'dat';
        case 3 %For mdf.datasetType 'High Uncertainty'
          modifier = 'hiUnc';
        case 4 %For mdf.datasetType 'Low Uncertainty'
          modifier = 'loUnc';
        case 5 %When hiUncert and loUncert are the same.
          modifier = 'hiLoUnc';
        case 6 %For mdf.datasetType 'Noblesse'
          modifier = 'Noblesse';
      end%switch
    else %if isempty(test) == 1
      modifier = 'void';
    end%if
  end%genMod nested subfunction.
end%save function
%Subfunction: mergeMetaData.
function merged = mergeMetaData(metaData)
  %Make list of unique fields over all cell array elements (for merged datasets).
  %First get list of field names.
  initSize = size(fieldnames(metaData{1,1}),1);
  for i = 2:size(metaData,2), initSize = initSize + size(fieldnames(metaData{1,i}),1); end%for
  fields = cell(initSize,1); pointer = 1;
  for j = 1:size(metaData,2)
    tempFields = fieldnames(metaData{1,j});
    for jj = 1:size(tempFields,1)
      fields{pointer,1} = tempFields{jj,1};
      pointer = pointer + 1;
    end%for
  end%for
  clear tempFields pointer initSize;
  fields = unique(fields); disp(fields);
  %Now concatenate strings for every field from each set of metadata.
  mData = cell(size(fields,1),1);
  for m = 1:size(fields,1)
    for n = 1:size(metaData,2)
      %Only do this if field exists.
      if isfield(metaData{1,n},fields{m,1})
        %Make sure metadata are strings.
        if isnumeric(metaData{1,n}.(fields{m,1}))
          metaData{1,n}.(fields{m,1}) = num2str(metaData{1,n}.(fields{m,1}));
        end%if
        %Merge metadata from different datasets.
        if n == 1
          mData{m,1} = metaData{1,n}.(fields{m,1});
        else
          mData{m,1} = [mData{m,1},' ;; ',metaData{1,n}.(fields{m,1})];
        end%if
      else %Enter null value for nonexistent fields.
        if n ==1
          mData{m,1} = 'null';
        else
          mData{m,1} = [mData{m,1},' ;; ','null'];
        end%if
      end%if
    end%for
  end%for
  %Horzcat fields and mData, return merged.
  merged = [fields,mData];
  clear fields mData;
end%mergeMetaData subfunction.