function disp(mdf,varargin)
  %disp function: displays MDataFrame contents nicely. May use tag-value pairs.
  %Tags: decimals, format     %More tags may come later.
  %
  %Updated 07/23/2012 - Can now display merged MDataFrames; some properties stored as cell arrays. 
  %
  
  idfw = 9;       %Initialize idfw = ID column field width
  dfw = 4;        %dfw = decimal field width, default is 4.
  gfw = 5;        %gfw = general field width, default is 5.
  format = 'f';   %format default = f;
  if mod(size(varargin,2),2) ~= 0
    fprintf('\nError: expecting string tag-value pairs.\n');
  else %If tag-value pairs are provided, take specified action.
    if size(varargin,2) >= 2
      tagList = {'decimals','format'};
      for i = 1:2:size(varargin,2)
        tagChk = find(strcmp(varargin{i},tagList));
        switch tagChk
          case 1 %User specifying decimal field width
            if isnumeric(varargin{i+1})
              dfw = varargin{i+1};
            else
              dfw = str2double(varargin{i+1});
            end%if
          case 2 %User specifying scientific notation and gfw.
            if ischar(varargin{i+1}) == 1
              %Allow for more intuitive format tag-words
              if strcmp(varargin{i+1},'scientific') == 1 || strcmp(varargin{i+1},'sci') == 1
                format = 'g';
              else %Allow user to specify format vis. fprintf documentation.
                format = varargin{i+1};
              end%if
              if strcmp(format,'g') == 1 %Adjust gfw a bit.
                gfw = 7;
              end%if
            end%if
        end%switch
      end%for
    end%if
  end%if
  %Set general field width, adjusted by decimal field width.
  gfw = gfw + dfw; %gfw = general field width, adjusted for dfw.
  %Scan ID label widths, adjust if idfw too small
  for id = 1:size(mdf.rownames,1)
    if idfw < length(mdf.rownames{id})
      idfw = length(mdf.rownames{id});
    end%if
  end%for
  %Print dataset name; handle cell inputs for merged datasets.
  if strcmp('void',mdf.datasetType) == 1
    if iscell(mdf.datasetName)
      dsName = '';
      for i = 1:size(mdf.datasetName,2)
        if i == 1
          dsName = mdf.datasetName{1,i};
        else
          dsName = [dsName,', ',mdf.datasetName{1,i}]; %#ok<*AGROW>
        end%if
      end%for
      fprintf('Dataset label - %s\n\n',dsName);
      clear dsName;
    else
      fprintf('Dataset label - %s\n\n',mdf.datasetName);
    end%if
  else %Include datasetType; handle cell inputs for merged datasets.
    if iscell(mdf.datasetType)
      dsName = ''; dsType = '';
      for i = 1:size(mdf.datasetName,2)
        if i == 1
          dsName = mdf.datasetName{1,i};
          dsType = mdf.datasetType{1,i};
        else
          dsName = [dsName,', ',mdf.datasetName{1,i}];
          dsType = [dsType,', ',mdf.datasetType{1,i}];
        end%if
      end%for
      fprintf('Dataset label - %s: %s\n\n',dsType,dsName);
    else
      fprintf('Dataset label - %s: %s\n\n',mdf.datasetType,mdf.datasetName);
    end%if
  end%if
  %Write header row:
  fprintf('%*s',idfw,blanks(2));
  for i = 1:size(mdf.colnames,2)
    fprintf('%*s',gfw,mdf.colnames{i});
  end%for
%   %Include notes column names, if needed.
%   if ~isempty(mdf.noteColNames)
%     for ii = 1:size(mdf.noteColNames,2)
%       fprintf('%*s',gfw,mdf.noteColNames{1,ii});
%     end%for
%   end%if
  fprintf('\n');
  %Write rows of data with row ID in first column
  for j = 1:size(mdf.rownames,1)
    fprintf('%*s',idfw,mdf.rownames{j});
    for k = 1:size(mdf.data,2)
      if strcmp(format,'g') == 1
        fprintf('%*.*g',gfw,dfw,mdf.data(j,k));
      else
        fprintf('%*.*f',gfw,dfw,mdf.data(j,k));
      end%if
    end%for
    if ~isempty(mdf.notes)
      for n = 1:size(mdf.notes,2)
        fprintf('%4s%-s',blanks(2),mdf.notes{j,n});
      end%for
    end%if
    if j < size(mdf.rownames,1)
      fprintf('\n');
    end%if
  end%for
  fprintf('\n');
end%display function