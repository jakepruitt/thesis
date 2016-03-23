display('Enter pit diameter in microns: ')
diameter = input(' ');
display('Percentage Above Bottom Surface: ')
cutoff = input(' ');

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

lowest_point_1 = min(z_micron_minus_void);
Top_z = z_micron_minus_void(find(z_micron_minus_void > 0.5*lowest_point_1));
Top_surface = mode(Top_z);
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

z_bottom = z_micron_zeroed(find(abs(z_micron_zeroed) > abs(lowest_point) - (cutoff/100)*abs(lowest_point)));
x_bottom = x_micron_minus_void(find(abs(z_micron_zeroed) > abs(lowest_point) - (cutoff/100)*abs(lowest_point)));
y_bottom = y_micron_minus_void(find(abs(z_micron_zeroed) > abs(lowest_point) - (cutoff/100)*abs(lowest_point)));

figure
plot3(x_bottom,y_bottom,z_bottom,'r.')
title('Pit Bottom');
xlabel('microns');
ylabel('microns');
zlabel('microns');

mean_depth = mean(abs(z_bottom))
mode_depth = mode(abs(z_bottom))
depth_error = 2*std(abs(z_bottom))

depth_output = [mean_depth, depth_error];

csvwrite('interferometer_depth_output.csv',depth_output, 0,0);