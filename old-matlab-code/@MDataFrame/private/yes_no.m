%yes_no subfunction
function choice = yes_no(question)
  choice = 0;
  Q = strcat(question,' (yes or no)\n');
  ask = input(Q,'s');
  if (strcmp(ask,'yes') == 1)
    choice = 1;
  elseif (strcmp(ask,'y') == 1)
    choice = 1;
  end%if
end%yes_no subfunction