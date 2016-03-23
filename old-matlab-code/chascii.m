function [xdim,ydim,nhl,ndl] = chascii(filename)
  %Usage: chascii(filename)
  %
  %Reads the header of an ascii file to determine the number of header lines and data lines output
  %from a white-light interferometric profilometer. Also determines the x and y pixel dimensions of
  %the input data.
  %
  %OUTPUT ARGUMENTS:
  % - xdim, ydim - dimensions, in nano-meters, of x and y pixels.
  % - nhl - number of header lines in the file.
  % - ndl - number of data lines in the file.
  %
  %Created: 11/25/2013
  %
  
  %Make sure proper number of arguments are given.
  if nargin ~= 1
    help(rascii);
    return;
  end%if
  %Initialize returned variables.
  xdim = 0; ydim = 0; nhl = 0; ndl = 0; %#ok<NASGU>
  %Open input file.
  fin = fopen(filename);
  %Set current-line counter.
  clc = 0;
  while(~feof(fin))
    %Iterate clc.
    clc = clc + 1;
    %Read line.
    line = fgetl(fin); 
    %Check for x,y pixel dimensions (in nm).
    if ~isempty(strfind(line,'x-length'))
      temp = regexp(line,' = ','split');
      xdim = str2double(temp(2));
    end%if
    if ~isempty(strfind(line,'y-length'))
      temp = regexp(line,' = ','split');
      ydim = str2double(temp(2));
    end%if
    %Check for beginning of data.
    if strcmp(line,'# Start of Data:')
      nhl = clc;
    end%if
  end%while
  %Close input file.
  fclose(fin);
  %Determine the number of data lines.
  ndl = clc - nhl;
end%chascii function.