function maxima = findmaxima(x)
  %Usage: maxima = findmaxima(x)
  %
  %INPUT ARGUMENT:
  % - x - vector of data.
  %
  %OUTPUT ARGUMENT:
  % - maxima - array of indexes where maxima occur.
  %
  %ACKNOWLEDGEMENT:
  % This script was inspired by, and draws from, the example by David Sampson at the following site:
  % http://www.eng.cam.ac.uk/help/tpl/programs/Matlab/minmax.html
  %
  
  %Make sure x is a vector.
  x = x(:);
  %Determine if slope is positive or negative.
  slopeSign = sign(diff(x));
  %Find where second derivative is negative.
  maxTest = [slopeSign(1)<0;diff(slopeSign)<0];
  %Return array of indexes where maxima occur.
  maxima = find(maxTest);
end%findmaxima