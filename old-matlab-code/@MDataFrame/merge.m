function merged = merge(mdf,mdfObj)
  %Usage: merged = merge(mdf,mdfObj)
  %
  %Method for MDataFrame objects, allows two mdf's to merge if they are the same version.
  %
  %Written: 09/02/2012 - 09/03/2012
  %
  
  %Make sure the two MDataFrame objects being merged are the same version.
  if mdf.version ~= mdfObj.version
    fprintf('\nWarning: MDataFrame objects cannot be merged unless they are the same version.\n');
    return;
  end%if
  %Iterate mdf.dsCount since an additional dataset is being merged with the current one.
  mdf.dsCount = mdf.dsCount + mdfObj.dsCount;
  %Merge information stored in major mdf properties (except version, dsCount, colnames,
  %rownames, initData, data, notes, noteColNames). 
  propList = {'dataSource','datasetType','datasetName','delim','comment','sampleInfo',...
    'dataInfo'};
  if mdf.dsCount == 2 %Need to initialize cell arrays for properties.
    for p = 1:size(propList,2)
      tempField = {mdf.(propList{1,p})};
      mdf.(propList{1,p}) = cell(1,mdf.dsCount);
      mdf.(propList{1,p}) = [tempField,mdfObj.(propList{1,p})];
    end%for
  elseif mdf.dsCount > 2 %Append info from mdfObj to current arrays.
    for p = 1:size(propList,2)
      mdf.(propList{1,p}) = [mdf.(propList{1,p}),mdfObj.(propList{1,p})];
    end%for
  end%if
  %Merge data together, based on column names.
  if size(mdf.colnames,2) == size(mdfObj.colnames,2)
    %Check if colnames match. If so, call vertcat function. If not, append needed column(s) of blank
    %values (zeros) to each dataset and vertcat.
    noMatch = find(~strcmp(mdf.colnames,mdfObj.colnames)); %Indexes: dissimilar cols.
    if isempty(noMatch)
      %Save properties, call vertcat, and repopulate property list.
      temp = mdf;
      mdf = mdf.vertcat(mdfObj);
      mdf = repopulateProps(mdf,temp,['dsCount',propList]); clear temp;
    else %In case columns don't match. May have columns out of order, or unique columns.
%       disp('\n');
%       disp(mdf.dataSource);
%       disp(mdfObj.dataSource);
      mdf = expandMerge(mdf,mdfObj,noMatch,propList);
    end%if
  else %Deal with case where the number of colnames differ from one another.
    %Make copy of mdf to save property values.
    temp = mdf;
    objects = equalize(mdf,mdfObj);
    objects = equalize(objects{1,1},objects{1,2});
    %Refresh property lists for both objects.
    objects{1,1} = repopulateProps(objects{1,1},temp,['dsCount',propList]);
    objects{1,2} = repopulateProps(objects{1,2},temp,['dsCount',propList]);
    clear temp;
    %Call expandMerge subfunction.
    noMatch = find(~strcmp(objects{1,1}.colnames,objects{1,2}.colnames));%Indexes: dissimilar cols.
    mdf = expandMerge(objects{1,1},objects{1,2},noMatch,propList);
  end%if
  % - Check whether each colname in mdf is present in mdfObj.colnames. If all are present, make sure
  % they are in the same order and vertcat the data. If there are colnames unique to mdf or mdfObj,
  % create empty columns in the other at the right side of *.data (to left of notes). Sort columns
  % and vertcat. 
  
  %Return merged object. Houseclean.
  merged = mdf; clear mdf mdfObj;
end%merge function

%Subfunctions
%repopulateProps subfunction
function mdf = repopulateProps(mdf,props,propList)
  %Note: props is an MDataFrame object.
  for i = 1:size(propList,2)
    mdf.(propList{1,i}) = props.(propList{1,i});
  end%for
end%repopulateProps subfunction

%genInitData subfunction.
function [initMdf,initMdfObj] = genInitData(mdf,mdfObj)
  %Collect colnames, rownames, data, and notes (if needed) into cell array (initData) for both mdf
  %and mdfObj for use in concatenating MDataFrame objects.
  if size(mdf.notes,2) > 0
    initMdf = [[blanks(2),mdf.colnames];[mdf.rownames,num2cell(mdf.data),mdf.notes]];
  else
    initMdf = [[blanks(2),mdf.colnames];[mdf.rownames,num2cell(mdf.data)]];
  end%if
  if size(mdfObj.notes,2) > 0
    initMdfObj = [[blanks(2),mdfObj.colnames];[mdfObj.rownames,num2cell(mdfObj.data),mdfObj.notes]];
  else
    initMdfObj = [[blanks(2),mdfObj.colnames];[mdfObj.rownames,num2cell(mdfObj.data)]];
  end%if
end%genInitData subfunction

%equalize subfunction
function objects = equalize(mdf,mdfObj)
  %Store mdf and mdfObj in cell array, objects, put the largest (widest) one in {1,1}.
  if size(mdf.colnames,2) > size(mdfObj.colnames,2)
    objects = {mdf,mdfObj};
  else
    objects = {mdfObj,mdf};
  end%if
  %Determine which column names in objects{1,1} are present in objects{1,2}.
  located = zeros(1,size(objects{1,1}.colnames,2));
  for p = 1:size(objects{1,1}.colnames,2)
    for q = 1:size(objects{1,2}.colnames,2)
      if strcmp(objects{1,1}.colnames{1,p},objects{1,2}.colnames{1,q})
        %Store index of objects{1,2}.colnames{1,q} where objects{1,1}.colnames{1,p} matches.
        located(1,p) = q;
      end%if
    end%for
  end%for
  %Append columns to objects{1,2} with the unique names from objects{1,1}
  uniqueNames = find(located == 0);
  colNames2add = cell(1,size(uniqueNames,2));
  for i = 1:size(colNames2add,2)
    colNames2add{1,i} = objects{1,1}.colnames{1,uniqueNames(1,i)};
  end%for
  %Generate initData for objects{1,2}, then append new columns.
  [~,initData] = genInitData(objects{1,1},objects{1,2});
  initData = [initData,[colNames2add;num2cell(zeros(size(initData,1)-1,size(colNames2add,2)))]];
  %Construct new MDataFrame object for objects{1,2}.
  initData = scan4commonNotes(initData);
  objects{1,2} = MDataFrame(initData);
end%equalize subfunction

%expandMerge subfunction
function mdf = expandMerge(mdf,mdfObj,noMatch,propList)
  %Generate initData so notes are included in merger.
  [mdf.initData,mdfObj.initData] = genInitData(mdf,mdfObj);
  %Adjust values in noMatch to account for extra column (rownames) in initData.
  noMatch = noMatch + 1;
  %First see if the non-matching columns are just out of order.
  located = zeros(1,size(noMatch,2));
  for m = 1:size(noMatch,2)
    for n = 1:size(noMatch,2)
      %Note: mdf.initData{1,:} equivalent to [blanks,mdf.colnames]
      if strcmp(mdf.initData{1,noMatch(1,m)},mdfObj.initData{1,noMatch(1,n)})
        %Record mdfObj.colnames(n) index where mdf.colnames(m) name exists.
        located(1,m) = noMatch(1,n);
      end%if
    end%for
  end%for
  %If all mdf.colnames have been located in mdfObj.colnames (no zeros in located), sort
  %mdfObj.colnames to match mdf.colnames and vertcat.
  if isempty(find(located == 0,1))
    temp = mdfObj.initData;
    for j = 1:size(located,2)
      mdfObj.initData(:,noMatch(1,j)) = temp(:,located(1,j));
    end%for
    %Save properties, vertcat, scan for common note column names, construct new mdf, 
    %and repopulate property list.
    temp = mdf;
    mdf.initData = [mdf.initData;mdfObj.initData(2:end,:)];
    mdf.initData = scan4commonNotes(mdf.initData);
    mdf = MDataFrame(mdf.initData);
    mdf = repopulateProps(mdf,temp,['dsCount',propList]); clear temp;
  else %If there are unique columns, append needed column(s) of blank values and vertcat.
    %Make copy of mdf to save property values.
    temp = mdf;
    objects = equalize(mdf,mdfObj);
    objects = equalize(objects{1,1},objects{1,2});
    %Refresh property lists for both objects.
    objects{1,1} = repopulateProps(objects{1,1},temp,['dsCount',propList]);
    objects{1,2} = repopulateProps(objects{1,2},temp,['dsCount',propList]);
    clear temp;
    %Call expandMerge subfunction (recursively, in this case).
    noMatch = find(~strcmp(objects{1,1}.colnames,objects{1,2}.colnames));%Indexes: dissimilar cols.
    mdf = expandMerge(objects{1,1},objects{1,2},noMatch,propList);
%     %Unique name(s) in mdf.colnames where located == 0. Generate ObjLoc list where unique names
%     %in mdfObj.colnames are indicated by ObjLoc == 0;
%     ObjLoc = zeros(1,size(noMatch,2));
%     for u = 1:size(noMatch,2)
%       for v = 1:size(noMatch,2)
%         if strcmp(mdfObj.initData{1,noMatch(1,u)},mdf.initData{1,noMatch(1,v)})
%           %Record mdf.colnames(u) index where mdfObj.colnames(v) exists.
%           ObjLoc(1,u) = noMatch(1,v);
%         end%if
%       end%for
%     end%for
%     %Append blank column(s) to right of initData arrays for mdf and mdfObj.
%     ObjUnique = find(ObjLoc == 0);% + size(mdfObj.initData,2) - size(ObjLoc,2);
%     disp(ObjUnique);
%     for i = 2:size(ObjUnique,2) %Operate on mdf.initData. Skip first (blank) colname.
%       mdf.initData = [mdf.initData,[mdfObj.initData{1,ObjUnique(1,i)};...
%         num2cell(zeros(size(mdf.initData,1)-1,1))]];
%     end%for
%     clear ObjUnique; disp(find(located == 0));
%     mdfUnique = find(located == 0);% + size(mdf.initData,2) - size(located,2);
%     disp(located); disp(mdfUnique);
%     for j = 2:size(mdfUnique,2) %Operate on mdfObj.initData. Skip first (blank) colname.
%       mdfObj.initData = [mdfObj.initData,[mdf.initData{1,mdfUnique(1,j)};...
%         num2cell(zeros(size(mdfObj.initData,1)-1,1))]];
%     end%for
% %     mdf.initData = [mdf.initData,mdfCol];
% %     mdfObj.initData = [mdfObj.initData,ObjCol];
%     clear mdfCol ObjCol;
%     disp(mdf.initData(1,:)); disp(mdfObj.initData(1,:));
%     %Sort mdfObj.initData to match mdf.initData colnames, then vertcat.
%     %Reassign located: search for indexes where mdf.colnames exist in mdfObj.colnames.
%     located = zeros(1,size(mdf.initData,2));
%     for a = 1:size(mdf.initData,2)
%       for b = 1:size(mdf.initData,2)
%         if strcmp(mdf.initData{1,a},mdfObj.initData{1,b})
%           located(1,a) = b;
%         end%if
%       end%for
%     end%for
%     %Sort mdfObj.initData.
%     temp = mdfObj.initData;
%     for c = 1:size(located,2)
%       disp(c); disp(located(1,c));
%       mdfObj.initData(:,c) = temp(:,located(1,c));
%     end%for
%     clear located noMatch;
%     %Save properties, vertcat, scan for common note column names, construct new mdf, 
%     %and repopulate property list.
%     temp = mdf;
%     mdf.initData = [mdf.initData;mdfObj.initData(2:end,:)];
%     mdf.initData = scan4commonNotes(mdf.initData);
%     mdf = MDataFrame(mdf.initData);
%     mdf = repopulateProps(mdf,temp,['dsCount',propList]); clear temp;
  end%if
end%expandMerge subfunction

%Scan for common note colnames subfunction.
function updated = scan4commonNotes(dataCell)
  commonNoteNames = {'Notes','notes','Reference','reference','references'};
  for i = 1:size(commonNoteNames,2)
    %Scan colnames of dataCell for each of the common names.
    for j = 1:size(dataCell,2)
      %If a match is found swap it to the end.
      if strcmp(commonNoteNames{1,i},dataCell{1,j})
        temp = dataCell(:,j);
        dataCell(:,j:end-1) = dataCell(:,j+1:end);
        dataCell(:,end) = temp;
        clear temp;
      end%if
    end%for
  end%for
  updated = dataCell;
end%scan4commonNotes