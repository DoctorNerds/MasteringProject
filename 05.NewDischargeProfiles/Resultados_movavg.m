time = 1:7486;

%Plot UDDS 05°C - Parametros 1
figure(01); 
plot(time, SOCHAT,'r')
title('Real SOC')
xlabel('Time') 
ylabel('SOC')
hold on
plot(time, YTEST_30,'b')
legend({'Neural Network','Real SOC'},'Location','southwest')
hold off