function iRobotVelCmd(u,vL,vR)
%iRobotVelCmd(u) Sends a velocity command to iRobot Create
% Inputs:
%   u  = BLE object
%   vL = Velocity command for left wheel (less than 300)
%   vR = Velocity command for right wheel (less than 300)
%
%                           Author: Prof. E. Rodriguez-Seda
%                           Date:   November 16, 2022

if u.velMax > 300 || u.velMax < 0
    u.velMax = 300;
    disp('Overide maximum velocity to 300.')
end

vL = round(vL);
vR = round(vR);
if vL > u.velMax
    vL = u.velMax;
elseif vL < -u.velMax
    vL = -u.velMax;
end
if vR > u.velMax
    vR = u.velMax;
elseif vR < -u.velMax
    vR = -u.velMax;
end

decMessage = zeros(1,20);
decMessage(1) = 1;      %Motor device
decMessage(2) = 4;       %Command
decMessage(3) = u.packetID;
decMessage(4:7) = fliplr(double(typecast(int32(vL), 'uint8')));
decMessage(8:11) = fliplr(double(typecast(int32(vR), 'uint8')));

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
write(u.dataTx,decMessage)
packetID = u.packetID + 1; 
if packetID > 255
    packetID = 0;
end
u.packetID = packetID;

end