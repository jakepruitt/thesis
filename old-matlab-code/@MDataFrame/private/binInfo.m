function [data,colnames,rownames,notes,noteColNames] = binInfo(initData)
  %Usage: [data,colnames,rownames,notes,noteColNames] = binInfo(initData)
  %
  %binInfo function for MDataFrame. Splits information from cell array into components,
  %including: data, colnames, rownames, notes, noteColNames.
  %
  %Written - 10/29/2011
  %Updated - 03/31/2012
  
  %Prepare for finding boundaries of numeric data (inclusive).
  dclb = 1;                     %Column lower bound (index)
  %dcub = assigned later;       %Column upper bound (index)
  drlb = 1;                     %Row lower bound (index)
  drub = size(initData,1);      %Row upper bound (index)
  %Check row and column heads to set values for rnag and cnag.
  crh = checkRowNames(initData);      %Check row heads.
  cch = checkColHeads(initData);      %Check column heads.
%   disp(crh); disp(cch);
  if crh == 2 && cch == 2
    %Leave dclb and drlb unchanged.
    %Generate row and column names.
    rownames = cell(size(initData,1),1);
    for i = 1:size(rownames,1), rownames{i,1} = ['r',num2str(i)]; end%for
    colnames = cell(1,size(initData,2));
    for j = 1:size(colnames,2), colnames{1,j} = ['c',num2str(j)]; end%for
  elseif crh == -1 && cch == -2
    %Set dclb and leave drlb alone.
    dclb = 2;
    %Import all row names, generate column names.
    rownames = initData(1:end,1);
    colnames = cell(1,size(initData,2)-1);
    for j = 1:size(colnames,2), colnames{1,j} = ['c',num2str(j)]; end%for
  elseif crh == -2 && cch == -1
    %Leave dclb alone, set drlb.
    drlb = 2;
    %Import all column names, generate row names.
    rownames = cell(size(initData,1)-1,1);
    for i = 1:size(rownames,1), rownames{i,1} = ['r',num2str(i)]; end%for
    colnames = initData(1,:);
  elseif (crh == 1 && cch == 1) || (crh == -1 && cch == -1) || (crh == -1 && cch == 1)
    %Set both dclb and drlb.
    dclb = 2; drlb = 2;
    %Import row and column names, skip upper left corner.
    rownames = initData(2:end,1);
    colnames = initData(1,2:end);
%   elseif crh == -1 && cch == -1
%     %Deal with all strings
  elseif crh == -2 && cch == 1 %Will need to work on this more later...
    %Deal with mixed string and numeric headers; generate new row and column heads.
    %Leave dclb and drlb unchanged.
    %Generate row and column names.
    rownames = cell(size(initData,1),1);
    for i = 1:size(rownames,1), rownames{i,1} = ['r',num2str(i)]; end%for
    colnames = cell(1,size(initData,2));
    for j = 1:size(colnames,2), colnames{1,j} = ['c',num2str(j)]; end%for
  end%if
  %Scan from left to right to detect columns with char or mixed numeric/char
  %values; Constrain mdf.data column-upper-bound, dcub.
  dcub = findDCUB(initData,dclb,drlb,drub);
  %Import data; import notes if needed, otherwise set to blank.
  data = cell2mat(initData(drlb:drub,dclb:dcub));
  if dcub < size(initData,2)
    notes = initData(drlb:drub,dcub+1:end);
    noteColNames = colnames(1,dcub:end); %Use dcub (not dcub+1) b/c size(colnames,1) = size(data)-1.
%     %Reset colnames to match size(data,2), i.e. 1:dcub.
%     colnames = colnames(1:dcub-1);
  elseif dcub == size(initData,2)
    notes = ''; noteColNames = '';
  end%if
end%binInfo function