%July_17_2010 - Brian Montleone

display('Enter pit diameter in microns: ')
diameter = input(' ');


z_nano = csvread('lpa_input.csv', 0,0,[0,0,479,751]);
x_nano = zeros(480,752);
y_nano = zeros(480,752);
z_nano_void = csvread('lpa_input.csv', 480,0,[480,0,959,751]);

for x = 1:752
  for y = 1:480
    x_nano(y,x) = 275103/752 * x;
    y_nano(y,x) = 204606/480 * y;
  end
end

z_nano_column = zeros(360960,1);
z_nano_void_column = zeros(360960,1);
x_nano_column = zeros(360960,1);
y_nano_column = zeros(360960,1);


for i = 1:360960
  z_nano_column(i) = z_nano(i);
  z_nano_void_column(i) = z_nano_void(i);
  x_nano_column(i) = x_nano(i);
  y_nano_column(i) = y_nano(i);
end

z_void_count = z_nano_column(find(z_nano_void_column == 0));
x_clip_column = zeros(numel(z_void_count),1);
y_clip_column = zeros(numel(z_void_count),1);
z_clip_column = zeros(numel(z_void_count),1);


x_clip_column = x_nano_column(find(z_nano_void_column == 0));
y_clip_column = y_nano_column(find(z_nano_void_column == 0));
z_clip_column = z_nano_column(find(z_nano_void_column == 0));

x_micron_column = x_clip_column./1000;
y_micron_column = y_clip_column./1000;
z_micron_column = z_clip_column./1000;


XYZ_micron = [x_micron_column,y_micron_column,z_micron_column];

figure
plot3(x_micron_column,y_micron_column,z_micron_column,'.')
title('Uncorrected Pit');
xlabel('microns');
ylabel('microns');
zlabel('microns');

z_micron_column_top = z_micron_column(find(z_micron_column > ((max(z_micron_column) + min(z_micron_column))/2)));


Top_surface = mode(z_micron_column_top);
z_micron_zeroed = z_micron_column - Top_surface;
Top = mode(z_micron_zeroed);

figure
plot3(x_micron_column,y_micron_column,z_micron_zeroed,'.')
title('Pit Top Surface = 0');
xlabel('microns');
ylabel('microns');
zlabel('microns');

XYZ_micron_zeroed = [x_micron_column, y_micron_column, z_micron_zeroed];

lowest_point = min(z_micron_zeroed)

middle_depth_calc = lowest_point/2


z_centroid_upper = z_micron_zeroed(find(z_micron_zeroed > middle_depth_calc - 0.5));
x_centroid_upper = x_micron_column(find(z_micron_zeroed > middle_depth_calc - 0.5));
y_centroid_upper = y_micron_column(find(z_micron_zeroed > middle_depth_calc - 0.5));

z_centroid_range = z_centroid_upper(find(z_centroid_upper < middle_depth_calc + 0.5));
x_centroid_range = x_centroid_upper(find(z_centroid_upper < middle_depth_calc + 0.5));
y_centroid_range = y_centroid_upper(find(z_centroid_upper < middle_depth_calc + 0.5));

x_centroid = mean(x_centroid_range)
y_centroid = mean(y_centroid_range)

figure
plot(x_centroid_range, z_centroid_range,'g.');
title('Centroid X vs. Z');
xlabel('X microns');
ylabel('depth microns');

figure
plot(y_centroid_range, z_centroid_range,'g.');
title('Centroid Y vs. Z');
xlabel(' Y microns');
ylabel('depth microns');




x_micron_centered = x_micron_column - x_centroid;
y_micron_centered = y_micron_column - y_centroid;

figure
plot3(x_micron_centered,y_micron_centered,z_micron_zeroed,'.');
title('Centered and Zeroed Pit');
xlabel('microns');
ylabel('microns');
zlabel('microns');


x_micron_below = x_micron_centered(find(z_micron_zeroed < 0));
y_micron_below = y_micron_centered(find(z_micron_zeroed < 0));
z_micron_below = z_micron_zeroed(find(z_micron_zeroed < 0));

x_micron_above = x_micron_centered(find(z_micron_zeroed >= 0));
y_micron_above = y_micron_centered(find(z_micron_zeroed >= 0));
z_micron_above = z_micron_zeroed(find(z_micron_zeroed >= 0));

figure
plot3(x_micron_below,y_micron_below,z_micron_below,'b.',x_micron_above,y_micron_above,z_micron_above,'r.');
title('Data Less than and Greater than Zero');
xlabel('microns');
ylabel('microns');
zlabel('microns');

r = zeros(numel(x_micron_below),1);
theta = zeros(numel(x_micron_below),1);

r_above = zeros(numel(x_micron_above),1);
theta_above = zeros(numel(x_micron_above),1);



for i = 1:numel(x_micron_below)
  if x_micron_below(i) >= 0
    if y_micron_below(i) >= 0
      r(i) = sqrt(x_micron_below(i)^2 + y_micron_below(i)^2);
      theta(i) = atan(y_micron_below(i)/x_micron_below(i))* 57.2957795;
    else if y_micron_below(i) < 0
        r(i) = sqrt(x_micron_below(i)^2 + y_micron_below(i)^2);
        theta(i) = 360 - (atan(abs(y_micron_below(i))/x_micron_below(i))* 57.2957795);
      end
    end
  else if x_micron_below(i) < 0
      if y_micron_below(i) >= 0
        r(i) = sqrt(x_micron_below(i)^2 + y_micron_below(i)^2);
        theta(i) = 180 - (atan(y_micron_below(i)/abs(x_micron_below(i)))* 57.2957795);
      else if y_micron_below(i) < 0
          r(i) = sqrt(x_micron_below(i)^2 + y_micron_below(i)^2);
          theta(i) = 180 + (atan(abs(y_micron_below(i))/abs(x_micron_below(i)))* 57.2957795);
        end
      end
    end
  end
end

for i = 1:numel(x_micron_above)
  if x_micron_above(i) >= 0
    if y_micron_above(i) >= 0
      r_above(i) = sqrt(x_micron_above(i)^2 + y_micron_above(i)^2);
      theta_above(i) = atan(y_micron_above(i)/x_micron_above(i))* 57.2957795;
    else if y_micron_above(i) < 0
        r_above(i) = sqrt(x_micron_above(i)^2 + y_micron_above(i)^2);
        theta_above(i) = 360 - (atan(abs(y_micron_above(i))/x_micron_above(i))* 57.2957795);
      end
    end
  else if x_micron_above(i) < 0
      if y_micron_above(i) >= 0
        r_above(i) = sqrt(x_micron_above(i)^2 + y_micron_above(i)^2);
        theta_above(i) = 180 - (atan(y_micron_above(i)/abs(x_micron_above(i)))* 57.2957795);
      else if y_micron_above(i) < 0
          r_above(i) = sqrt(x_micron_above(i)^2 + y_micron_above(i)^2);
          theta_above(i) = 180 + (atan(abs(y_micron_above(i))/abs(x_micron_above(i)))* 57.2957795);
        end
      end
    end
  end
end



figure
plot3(r,theta,z_micron_below,'b.', r_above,theta_above,z_micron_above,'r.');
title('Polar Coordinates Greater than and Less than Zero');
xlabel('radius (microns)');
ylabel('Degrees');
zlabel('microns');




polar_coord_r_pit = r(find(r < min(r_above) + .15*diameter));
polar_coord_theta_pit = theta(find(r < min(r_above) + .15*diameter));
polar_coord_z_pit = z_micron_below(find(r < min(r_above) + .15*diameter));

polar_coord_r_nopit = r(find(r >= min(r_above) + .15*diameter));
polar_coord_theta_nopit = theta(find(r >= min(r_above) + .15*diameter));
polar_coord_z_nopit = z_micron_below(find(r >= min(r_above) + .15*diameter));





figure
plot3(polar_coord_r_pit, polar_coord_theta_pit, polar_coord_z_pit,'.',polar_coord_r_nopit, polar_coord_theta_nopit, polar_coord_z_nopit,'.',r_above,theta_above,z_micron_above,'.');
title('Polar Coordinates Sorted Data');
xlabel('radius (microns)');
ylabel('Degrees');
zlabel('microns');



x_length_microns = 275103/1000;
y_length_microns = 204606/1000;

volume_parts = -polar_coord_z_pit*(x_length_microns/752)*(y_length_microns/480);
volume = sum(volume_parts)




%convert pit data back to XY coordinates

X_pit = zeros(numel(polar_coord_r_pit),1);
Y_pit = zeros(numel(polar_coord_r_pit),1);

X_nopit = zeros(numel(polar_coord_r_nopit),1);
Y_nopit = zeros(numel(polar_coord_r_nopit),1);
for j = 1:numel(polar_coord_r_pit)
  if polar_coord_theta_pit(j) <= 180
    if polar_coord_theta_pit(j) <= 90
      X_pit(j) = cos(polar_coord_theta_pit(j)/57.2957795)*polar_coord_r_pit(j);
      Y_pit(j) = sin(polar_coord_theta_pit(j)/57.2957795)*polar_coord_r_pit(j);
    else if polar_coord_theta_pit(j) > 90
        X_pit(j) = -cos((180 - polar_coord_theta_pit(j))/57.2957795)*polar_coord_r_pit(j);
        Y_pit(j) = sin((180 - polar_coord_theta_pit(j))/57.2957795)*polar_coord_r_pit(j);
      end
    end
  else if polar_coord_theta_pit(j) > 180
      if polar_coord_theta_pit(j) <= 270
        X_pit(j) = -cos((polar_coord_theta_pit(j) - 180)/57.2957795)*polar_coord_r_pit(j);
        Y_pit(j) = -sin((polar_coord_theta_pit(j) - 180)/57.2957795)*polar_coord_r_pit(j);
      else if polar_coord_theta_pit(j) > 270
          X_pit(j) = cos((360 - polar_coord_theta_pit(j))/57.2957795)*polar_coord_r_pit(j);
          Y_pit(j) = -sin((360 - polar_coord_theta_pit(j))/57.2957795)*polar_coord_r_pit(j);
        end
      end
    end
  end
end

for j = 1:numel(polar_coord_r_nopit)
  if polar_coord_theta_nopit(j) <= 180
    if polar_coord_theta_nopit(j) <= 90
      X_nopit(j) = cos(polar_coord_theta_nopit(j)/57.2957795)*polar_coord_r_nopit(j);
      Y_nopit(j) = sin(polar_coord_theta_nopit(j)/57.2957795)*polar_coord_r_nopit(j);
    else if polar_coord_theta_nopit(j) > 90
        X_nopit(j) = -cos((180 - polar_coord_theta_nopit(j))/57.2957795)*polar_coord_r_nopit(j);
        Y_nopit(j) = sin((180 - polar_coord_theta_nopit(j))/57.2957795)*polar_coord_r_nopit(j);
      end
    end
  else if polar_coord_theta_nopit(j) > 180
      if polar_coord_theta_nopit(j) <= 270
        X_nopit(j) = -cos((polar_coord_theta_nopit(j) - 180)/57.2957795)*polar_coord_r_nopit(j);
        Y_nopit(j) = -sin((polar_coord_theta_nopit(j) - 180)/57.2957795)*polar_coord_r_nopit(j);
      else if polar_coord_theta_nopit(j) > 270
          X_nopit(j) = cos((360 - polar_coord_theta_nopit(j))/57.2957795)*polar_coord_r_nopit(j);
          Y_nopit(j) = -sin((360 - polar_coord_theta_nopit(j))/57.2957795)*polar_coord_r_nopit(j);
        end
      end
    end
  end
end


figure
plot3(X_pit,Y_pit,polar_coord_z_pit,'b.',X_nopit,Y_nopit,polar_coord_z_nopit,'g.',x_micron_above,y_micron_above,z_micron_above,'r.');
title('Sorted Pit XYZ');
xlabel('microns');
ylabel('microns');
zlabel('microns');
figure
plot3(X_pit,Y_pit, polar_coord_z_pit,'.');
title('Measured Pit');
xlabel('microns');
ylabel('microns');
zlabel('microns');

csvwrite('pit_volume.csv', volume, 0,0);
