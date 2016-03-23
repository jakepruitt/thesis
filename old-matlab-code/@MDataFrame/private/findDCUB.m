%findDCUB subfunction; pass lower col and row bounds, and upper row bound.
function dcub = findDCUB(initData,dclb,drlb,drub)
  mixedColFound = 0;
  dcub = size(initData,2); %In case no notes exist.
  for v = dclb:size(initData,2) %Move from left to right.
    numNumeric = 0; numChar = 0;
    for u = drlb:drub %Move top to bottom.
      if isnumeric(initData{u,v}) == 1
        numNumeric = numNumeric + 1;
      elseif ischar(initData{u,v}) == 1
        numChar = numChar + 1;
      end%if
    end%for
    %Make sure everything is numeric or char, otherwise break.
    if (numNumeric + numChar) ~= (size(initData,1) - drlb + 1)
      fprintf('\nError: some data are not strings or numeric.\n');
      break;
    elseif mixedColFound == 0 && numChar > 0
      dcub = v - 1;
      mixedColFound = 1; %Prevent changing dcub later.
    end%if
  end%for
end%findDCUB subfunction