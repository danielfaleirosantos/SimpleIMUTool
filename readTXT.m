clc; close all; clearvars;

%% Files with sensor readings

fileID = fopen('outputAccel.txt','r');
formatSpec = '%f\t%f\t%f';
sizeA = Inf;
A = fscanf(fileID,formatSpec,sizeA);
A = A';

fileID2 = fopen('outputGyro.txt','r');
B = fscanf(fileID2,formatSpec,sizeA);
B = B';

%% Vector creation and storing for each sensor

% B length is smaller than A but last A values are when the robot is
% stationary.
len = length(B);

accelX = zeros(len/3,1);
accelY = zeros(len/3,1);
accelZ = zeros(len/3,1);

gyroX = zeros(len/3,1);
gyroY = zeros(len/3,1);
gyroZ = zeros(len/3,1);

for i = 1:len
    if mod((i-1),3) == 0
        accelX((i-1)/3 + 1) = A(i);
        gyroX((i-1)/3 + 1) = B(i);
    end
    if mod((i-1),3) == 1
        accelY((i-2)/3 + 1) = A(i) + 0.01;
        gyroY((i-2)/3 + 1) = B(i);
    end
    if mod((i-1),3) == 2
        accelZ((i-3)/3 + 1) = A(i);
        gyroZ((i-3)/3 + 1) = B(i);
    end
end

%% Interpolation using ifft

accelX = accelX(5:end-1);
accelY = accelY(5:end-1);
accelZ = accelZ(5:end-1);
gyroX = gyroX(7:end-1);
gyroY = gyroY(7:end-1);
gyroZ = gyroZ(7:end-1);

Ni = 10000;
xi = (0:Ni-1)/Ni;

N1 = length(accelX);
x1 = (0:N1-1)/N1;

Npad1 = floor(Ni/2 - N1/2);

N2 = length(gyroX);
x2 = (0:N2-1)/N2;

Npad2 = floor(Ni/2 - N2/2);

ft = fftshift(fft(accelX));
ft2 = fftshift(fft(accelY));
ft3 = fftshift(fft(accelZ));
ft4 = fftshift(fft(gyroX));
ft5 = fftshift(fft(gyroY));
ft6 = fftshift(fft(gyroZ));

ft_pad = [zeros(Npad1,1); ft; zeros(Npad1,1)];
accelX_int = real(ifft( fftshift(ft_pad) ))*Ni/N1;

ft_pad = [zeros(Npad1,1); ft2; zeros(Npad1,1)];
accelY_int = real(ifft( fftshift(ft_pad) ))*Ni/N1;

ft_pad = [zeros(Npad1,1); ft3; zeros(Npad1,1)];
accelZ_int = real(ifft( fftshift(ft_pad) ))*Ni/N1;

ft_pad = [zeros(Npad2,1); ft4; zeros(Npad2,1)];
gyroX_int = real(ifft( fftshift(ft_pad) ))*Ni/N2;

ft_pad = [zeros(Npad2,1); ft5; zeros(Npad2,1)];
gyroY_int = real(ifft( fftshift(ft_pad) ))*Ni/N2;

ft_pad = [zeros(Npad2,1); ft6; zeros(Npad2,1)];
gyroZ_int = real(ifft( fftshift(ft_pad) ))*Ni/N2;

%% Sensor reading plots

figure;
title('Values of X axis - Accelerometer', 'Interpreter','latex');
plot(x1, accelX, 'o')
hold on
plot(xi, accelX_int)
hold off
legend('Raw values', 'Interpolated Values')
xlabel('time', 'interpreter', 'latex');
ylabel('X acceleration (in g)', 'interpreter', 'latex');

figure;
title('Values of Y axis - Accelerometer', 'Interpreter','latex');
plot(x1, accelY, 'o')
hold on
plot(xi, accelY_int)
hold off
legend('Raw values', 'Interpolated Values')
xlabel('time', 'interpreter', 'latex');
ylabel('Y acceleration (in g)', 'interpreter', 'latex');

figure;
title('Values of Z axis - Accelerometer', 'Interpreter','latex');
plot(x1, accelZ, 'o')
hold on
plot(xi, accelZ_int)
hold off
legend('Raw values', 'Interpolated Values')
xlabel('time', 'interpreter', 'latex');
ylabel('Z acceleration (in g)', 'interpreter', 'latex');

figure;
title('Values of X axis - Gyroscope', 'Interpreter','latex');
plot(x2, gyroX, 'o')
hold on
plot(xi, gyroX_int)
hold off
legend('Raw values', 'Interpolated Values')
xlabel('time', 'interpreter', 'latex');
ylabel('X rotation (in degrees)', 'interpreter', 'latex');

figure;
title('Values of Y axis - Gyroscope', 'Interpreter','latex');
plot(x2, gyroY, 'o')
hold on
plot(xi, gyroY_int)
hold off
legend('Raw values', 'Interpolated Values')
xlabel('time', 'interpreter', 'latex');
ylabel('Y rotation (in degrees)', 'interpreter', 'latex');

figure;
title('Values of Z axis - Gyroscope', 'Interpreter','latex');
plot(x2, gyroZ, 'o')
hold on
plot(xi, gyroZ_int)
hold off
legend('Raw values', 'Interpolated Values')
xlabel('time', 'interpreter', 'latex');
ylabel('Z rotation (in degrees)', 'interpreter', 'latex');

%% Trajectory estimation

xtraj = cumsum(cumsum(accelX));
ytraj = cumsum(cumsum(accelY));

xReal = 20; % Supposed final x axis value
yReal = -6; % % Supposed final x axis value

xGain = max(xtraj)/xReal; x = xtraj/xGain;
yGain = min(ytraj)/yReal; y = ytraj/yGain;

figure;
title('Values of X axis - Position', 'Interpreter','latex');
plot(x1, x)
legend('X trajectory')
xlabel('time', 'interpreter', 'latex');
ylabel('X trajectory (in cm)', 'interpreter', 'latex');

figure;
title('Values of Y axis - Position', 'Interpreter','latex');
plot(x1, y)
legend('Y trajectory')
xlabel('time', 'interpreter', 'latex');
ylabel('Y trajectory (in cm)', 'interpreter', 'latex');

figure;
title('Trajectory', 'Interpreter','latex');
plot(x, y)
legend('IMU trajectory')
xlabel('X Axis Position (in cm)', 'interpreter', 'latex');
ylabel('Y Axis Position (in cm)', 'interpreter', 'latex');
