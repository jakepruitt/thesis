function s = smooth(x,n)
  %Usage: s = smooth(x,n)
  %
  %Smooths a vector of data using a moving average.
  %
  %INPUT ARGUMENTS:
  % - x - Vector of data.
  % - n - Size of box car to use in smoothing; default = 5 if no value passed.
  %       Note, n must be odd, and the minimum size is 3.
  %
  %RETURNED ARGUMENT:
  % - s - vector of smoothed data; same size as x, with un-smoothed end points.
  %
  
  %Check if n is passed; use 5 by default.
  if nargin < 1
    help('smooth');
  elseif nargin < 2
    n = 5;
  end%if
  %Make sure x is a vector.
  x = x(:);
  %Make sure n is odd and greater than 3; if even and > 4, subtract 1.
  if mod(n,2) == 0
    if n >= 4
      n = n - 1;
    else
      n = 3;
    end%if
  end%if
  if n < 3
    n = 3;
  end%if
  %Define size of side of box car (exluding center); e.g., for n = 5, side = 2.
  side = (n-1)/2;
  %Loop over data and smooth it; ignore endpoints.
  s = x; clear x; num = numel(s);
  for i = 2:num-1
    %Deal with values closer to end points than size of box car.
    if (i - 1)*2+1 < n || (num - i)*2+1 < n
      %Use smaller box car.
      tempN = min([(i - 1)*2+1,(num - i)*2+1]);
      tempSide = (tempN-1)/2;
      idxList = (i - tempSide):(i + tempSide);
      s(i) = sum(s(idxList))/tempN;
    else
      %Use specified box car.
      idxList = (i - side):(i + side);
      s(i) = sum(s(idxList))/n;
    end%if
  end%for
end%smooth