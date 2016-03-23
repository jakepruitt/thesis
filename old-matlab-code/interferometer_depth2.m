display('Enter pit diameter in microns: ')
diameter = input(' ');

x_pixels = csvread('interferometer_depth_input.csv', 0,0,[0,0,0,0]);
x_length = csvread('interferometer_depth_input.csv', 1,0,[1,0,1,0]);
y_pixels = csvread('interferometer_depth_input.csv', 0,1,[0,1,0,1]);
y_length = csvread('interferometer_depth_input.csv', 1,1,[1,1,1,1]);

z_nano = csvread('interferometer_depth_input.csv', 3,0,[3,0,3 + y_pixels - 1, x_pixels - 1]);
x_nano = zeros(y_pixels,x_pixels);
y_nano = zeros(y_pixels,x_pixels);

for x = 1:x_pixels    
    for y = 1:y_pixels
        x_nano(y,x) = x_length/x_pixels * x;
        y_nano(y,x) = y_length/y_pixels * y;
    end
end

z_nano_column = zeros(x_pixels * y_pixels,1);
x_nano_column = zeros(x_pixels * y_pixels,1);
y_nano_column = zeros(x_pixels * y_pixels,1);

for i = 1:x_pixels*y_pixels
    z_nano_column(i) = z_nano(i);
    x_nano_column(i) = x_nano(i);
    y_nano_column(i) = y_nano(i);
end

x_micron_column = x_nano_column./1000;
y_micron_column = y_nano_column./1000;
z_micron_column = z_nano_column./1000;


XYZ_micron = [x_micron_column,y_micron_column,z_micron_column];

figure
plot3(x_micron_column,y_micron_column,z_micron_column,'.')
title('Uncorrected Pit');
xlabel('microns');
ylabel('microns');
zlabel('microns');

%identify void max value
Void_top_surface = max(z_micron_column);

%remove void max values
z_micron_minus_void = z_micron_column(find(z_micron_column ~= Void_top_surface));
x_micron_minus_void = x_micron_column(find(z_micron_column ~= Void_top_surface));
y_micron_minus_void = y_micron_column(find(z_micron_column ~= Void_top_surface));

%Find top surface and set to zero, adjust all z values
Top_surface = mode(z_micron_minus_void);
z_micron_zeroed = z_micron_minus_void - Top_surface;
Top = mode(z_micron_zeroed)

figure
plot3(x_micron_minus_void,y_micron_minus_void,z_micron_minus_void,'.')
title('Pit Minus Void Max');
xlabel('microns');
ylabel('microns');
zlabel('microns');


figure
plot3(x_micron_minus_void,y_micron_minus_void,z_micron_zeroed,'.')
title('Zeroed Pit Minus Void Max');
xlabel('microns');
ylabel('microns');
zlabel('microns');


lowest_point = min(z_micron_zeroed)

z_bottom = z_micron_zeroed(find(z_micron_zeroed < 0));
x_bottom = x_micron_minus_void(find(z_micron_zeroed < 0));
y_bottom = y_micron_minus_void(find(z_micron_zeroed < 0));

figure
plot3(x_bottom,y_bottom,z_bottom,'r.')
title('Pit Bottom');
xlabel('microns');
ylabel('microns');
zlabel('microns');

mean_depth = mean(abs(z_bottom))
mode_depth = mode(abs(z_bottom))
depth_error = 2*std(abs(z_bottom))

% Define centroid of pit in complex images
x_bottom_centroid = x_bottom(find(abs(z_bottom) == mode_depth));
y_bottom_centroid = y_bottom(find(abs(z_bottom) == mode_depth));
z_bottom_centroid = z_bottom(find(abs(z_bottom) == mode_depth));

x_centroid = mean(x_bottom_centroid);
y_centroid = mean(y_bottom_centroid);

x_bottom_centered = x_bottom - x_centroid;
y_bottom_centered = y_bottom - y_centroid;

figure
plot3(x_bottom_centered,y_bottom_centered,z_bottom,'.')
title('Zeroed Centered Pit Minus Void Max');
xlabel('microns');
ylabel('microns');
zlabel('microns');

% convert centered bottom values to polar coordinates

for i = 1:numel(x_bottom_centered)
    if x_bottom_centered(i) >= 0
        if y_bottom_centered(i) >= 0
            r(i) = sqrt(x_bottom_centered(i)^2 + y_bottom_centered(i)^2);
            theta(i) = atan(y_bottom_centered(i)/x_bottom_centered(i))* 57.2957795;
        else if y_bottom_centered(i) < 0
            r(i) = sqrt(x_bottom_centered(i)^2 + y_bottom_centered(i)^2);
            theta(i) = 360 - (atan(abs(y_bottom_centered(i))/x_bottom_centered(i))* 57.2957795);
            end
        end
    else if x_bottom_centered(i) < 0
            if y_bottom_centered(i) >= 0
                r(i) = sqrt(x_bottom_centered(i)^2 + y_bottom_centered(i)^2);
                theta(i) = 180 - (atan(y_bottom_centered(i)/abs(x_bottom_centered(i)))* 57.2957795);
            else if y_bottom_centered(i) < 0
                 r(i) = sqrt(x_bottom_centered(i)^2 + y_bottom_centered(i)^2);
                 theta(i) = 180 + (atan(abs(y_bottom_centered(i))/abs(x_bottom_centered(i)))* 57.2957795);
                end
            end
        end
    end  
end

figure
plot3(r,theta,z_bottom,'.')
title('Zeroed Centered Pit Minus Void Max');
xlabel('microns');
ylabel('microns');
zlabel('microns');


r_pit_bottom = r(find(r <= diameter/2));
theta_pit_bottom = theta(find(r <= diameter/2));
z_pit_bottom = z_bottom(find(r <= diameter/2));

figure
plot3(r_pit_bottom,theta_pit_bottom,z_pit_bottom,'.')
title('Zeroed Centered Pit Minus Void Max');
xlabel('microns');
ylabel('microns');
zlabel('microns');


for j = 1:numel(r_pit_bottom)
    if theta_pit_bottom(j) <= 180
        if theta_pit_bottom(j) <= 90
            X_pit(j) = cos(theta_pit_bottom(j)/57.2957795)*r_pit_bottom(j);
            Y_pit(j) = sin(theta_pit_bottom(j)/57.2957795)*r_pit_bottom(j);
        else if theta_pit_bottom(j) > 90
            X_pit(j) = -cos((180 - theta_pit_bottom(j))/57.2957795)*r_pit_bottom(j);
            Y_pit(j) = sin((180 - theta_pit_bottom(j))/57.2957795)*r_pit_bottom(j);
            end
        end
    else if theta_pit_bottom(j) > 180
            if theta_pit_bottom(j) <= 270
                X_pit(j) = -cos((theta_pit_bottom(j) - 180)/57.2957795)*r_pit_bottom(j);
                Y_pit(j) = -sin((theta_pit_bottom(j) - 180)/57.2957795)*r_pit_bottom(j);
            else if theta_pit_bottom(j) > 270
                    X_pit(j) = cos((360 - theta_pit_bottom(j))/57.2957795)*r_pit_bottom(j);
                    Y_pit(j) = -sin((360 - theta_pit_bottom(j))/57.2957795)*r_pit_bottom(j);
                end
            end
        end
    end
end


figure
plot3(X_pit,Y_pit,z_pit_bottom,'.')
title('Zeroed Centered Pit');
xlabel('microns');
ylabel('microns');
zlabel('microns');
