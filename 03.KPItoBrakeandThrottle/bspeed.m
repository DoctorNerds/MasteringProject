function [brake_speed] = bspeed(brake)

brake_speed = diff(brake);
% brake_speed(36880)=0; %Training data : A123_DYN_50_P25
 brake_speed(36814)=0; %Test data : A123_DYN_50_P35
end