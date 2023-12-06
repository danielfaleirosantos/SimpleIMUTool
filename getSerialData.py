##############
## Script listens to serial port and writes contents into a file
##############
## requires pySerial to be installed 
import serial

serial_port = 'COM4'; # Here just write the serial port through which your Arduino readings come from
baud_rate = 9600; # In arduino, Serial.begin(baud_rate)
write_to_file_path1 = "outputAccel.txt";
write_to_file_path2 = "outputGyro.txt";

output_file1 = open(write_to_file_path1, "w+");
output_file2 = open(write_to_file_path2, "w+");
ser = serial.Serial(serial_port, baud_rate)

# Take 1000 readings - 3000 values
for i in range(1000):
    line = ser.readline();
    
    if line == b'Accelerometer: \r\n':
        line = line.decode("utf-8") #ser.readline returns a binary, convert to string
        print(line);
        line = ser.readline();
        line = line.decode("utf-8") #ser.readline returns a binary, convert to string
        print(line);
        output_file1.write(line);
    else:
        line = line.decode("utf-8") #ser.readline returns a binary, convert to string
        print(line);
        line = ser.readline();
        line = line.decode("utf-8") #ser.readline returns a binary, convert to string
        print(line);
        output_file2.write(line);
    i = i + 1


