%checkRowNames subfunction
function importRowNames = checkRowNames(initData)
  numRowIdChar = 0; numRowIdNumeric = 0;
  for i = 1:size(initData,1)
    if i == 1 %Make sure this is not a string of spaces. If it is, treat is as numeric.
      if strcmp(strcat(initData{i,1},'test'),'test') == 1
        numRowIdNumeric = numRowIdNumeric + 1;
      else
        numRowIdChar = numRowIdChar + 1;
      end%if
    else
      if ischar(initData{i,1}) == 1 && isempty(initData{i,1}) == 0
        numRowIdChar = numRowIdChar + 1;
      elseif isnumeric(initData{i,1}) == 1
        numRowIdNumeric = numRowIdNumeric + 1;
      end%if
    end%if
  end%for
  if numRowIdNumeric ~= size(initData,1) && numRowIdChar > 1
    if numRowIdChar == size(initData,1)
      importRowNames = -1; %Import all row IDs.
    else
      importRowNames = 1;  %Import row IDs, skip first (possibly blank) row.
    end%if
  else 
    if numRowIdChar == 1 && ischar(initData{1,1})
      %Handle case where dataset has one row of data plus column names.
      if size(initData,1) <= 2
        importRowNames = 1; %Import row IDs, skip first (possibly blank) row.
      else
        importRowNames = -2;  %Generate new row IDs, skip first row (col heads present).
      end%if
    else
      importRowNames = 2;   %Generate new row IDs for all rows.
    end%if
  end%if
end%checkRowNames subfunction