function pose = iRobotPose(u)
%iRobotPose(u) Request the position (x,y) and orientation of iRobot Create
% Inputs:
%   u    = BLE object
% Outputs:
%   pose = A 1x3 vector containing the position and orientation of the
%   robot (x,y,yaw). Position is mm while orientation is in deci-degrees
%
%                           Author: Prof. E. Rodriguez-Seda
%                           Date:   November 30, 2022

decMessage = zeros(1,20);
decMessage(1) = 1;      %Motor device
decMessage(2) = 16;       %Command
decMessage(3) = u.packetID;

tempString = dec2bin(decMessage(1:19),8);
inputMsg = zeros(19*8,1);
for i = 1:19
    for j = 1:8
        inputMsg(8*(i-1)+j) = str2double(tempString(i,j));
    end
end

codeword = u.crc8(inputMsg);
checksum = codeword(end-7:end)';
decMessage(20) = bin2dec(num2str(checksum));

getPose = 1;
tStart = tic; 
while getPose
    write(u.dataTx,decMessage)
    dataRead = read(u.dataRx);
    if dataRead(2) == 16
        getPose = 0;
        x = typecast(fliplr(uint8(dataRead(8:11))), 'int32');  %in mm
        y = typecast(fliplr(uint8(dataRead(12:15))), 'int32'); %in mm
        yaw = typecast(fliplr(uint8(dataRead(16:17))), 'int16'); %in deci-degrees
        pose = [x,y,yaw];
    end
    if toc(tStart) > 1
        warning('Timeout, took longer than 1 seconds to get pose.')
        break;
    end

end

packetID = u.packetID + 1; 
if packetID > 255
    packetID = 0;
end
u.packetID = packetID;


end