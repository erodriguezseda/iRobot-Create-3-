function u = iRobotConnect(name)
%iRobotConnect(name) Establishes connection with iRobot Create using
%Bluetooth Low Energy (BLE) communication port
%
%   Inputs:
%   name    = string containing the BLE name of robot (e.g., "BillTheBot01")
%   Outputs:
%   u       = BLE object
%
%                           Author: Prof. E. Rodriguez-Seda
%                           Date:   November 16, 2022

% Use Try-catch
u.robot = ble(name);   

u.dataRx = characteristic(u.robot, "6E400001-B5A3-F393-E0A9-E50E24DCCA9E","6E400003-B5A3-F393-E0A9-E50E24DCCA9E");
u.dataTx = characteristic(u.robot, "6E400001-B5A3-F393-E0A9-E50E24DCCA9E","6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
subscribe(u.dataRx)   %Most subscribe in order to read from this channel

u.packetID = 0;     
crc8 = comm.CRCGenerator('Polynomial','z^8 + z^2 + z + 1', ...
    'InitialConditions',0,'DirectMethod',true,'FinalXOR',0);
u.crc8 = crc8;
u.velMax = 300;
end