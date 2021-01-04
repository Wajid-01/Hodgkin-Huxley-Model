clc;

%%% (1)...Define the Constant parameters Required --> See Below for Further Details%%%

C_m=1; %Defined membrance capacitance...
E_Na=115; %Defined reversal sodium potential...
E_K = -12; %Defined reversal potassium potential...
E_L=10.6; %Defined reversal leak potential...
g_Na=120; %Defined sodium channel...
g_K=36; %Defined potassium channel...
g_L=0.3; %Defined leak channel...

%%% (2)...The application of time across neural firing%%%

t_End=100;
t_steps=0.01;
time=0:t_steps:t_End;

%%% (3)...The Specification of External Current I and Set the Baseline Voltage%%%

V=0; %Baseline voltage
InjectionStrength=[50]; %Change this to see effect of different currents on voltage (Suggested values: 3, 20, 50, 1000)
ElapsedTime=[0]; %Figures based on milliseconds###

%%% (4)...Set the initial Neuron Conditions by Calculating/Solving the Equations for [1] Sodium Activation & Inactivation Gating Variables, [2] The Potassium Activation Gating Variables%%%

a_n=0.01*((10-V)/(exp((10-V)/10)-1)); %Equation 12
b_n=0.125*exp(-V/80); %Equation 13
n(1)=a_n/(a_n+b_n); %Equation 9
a_m=0.1*((25-V)/(exp((25-V)/10)-1)); %Equation 20
b_m=4*exp(-V/18); %Equation 21
m(1)=a_m/(a_m+b_m); %Equation 18
a_h=0.07*exp(-V/20); %Equation 23
b_h=1/(exp((30-V)/10)+1); %Equation 24
h(1)=a_h/(a_h+b_h); %Equation 18


%%% (5...) %%%
%Set externally applied current across time
%Here, first 500 timesteps are at current of 50, next 1500 timesteps at
%current of zero (resets resting potential of neuron), and the rest of
%timesteps are at constant current
I(1:800)=0;I(801:1601)=0;I(1601:2400)=0;I(2401:3000)=InjectionStrength;I(3001:numel(time))=0;
numel_Start=1;
%Comment out the above line and uncomment the line below for constant current, and observe effects on voltage timecourse
%I(1:numel(t)) = currentLevels;

%%% (6)...Create for loop to merge required calculations and run across selected time-steps %%%

 for i=numel_Start:numel(time)-1 %For the neuron activity to be effectively monitored vs. time, the currents, coefficients and derivatives were calculated and matched to all time-steps...
    
    %%%The Calculations Relating to the Neuron Currents%%%
    
    I_Na=(m(i)^3)*g_Na*h(i)*(V(i)-E_Na); %Equations 3 and 14
    I_K=(n(i)^4)*g_K*(V(i)-E_K); %Equations 4 and 6
    I_L=g_L*(V(i)-E_L); %Equation 5
    current_ion=I(i)-I_K-I_Na-I_L; 

    %%%The Calculations Pertaining to the Coefficients and Derivatives using Euler First Approximation%%%
    
    V(i+1)=V(i)+t_steps*current_ion/C_m;
    a_m(i)=0.1*((25-V(i))/(exp((25-V(i))/10)-1));
    b_m(i)=4*exp(-V(i)/18);
    m(i+1)=m(i)+t_steps*(a_m(i)*(1-m(i))- b_m(i)*m(i)); %Equation 15
    a_h(i)=0.07*exp(-V(i)/20);
    b_h(i)=1/(exp((30-V(i))/10)+1);
    h(i+1)=h(i)+t_steps*(a_h(i)*(1-h(i))- b_h(i)*h(i)); %Equation 16
    a_n(i)=0.01*((10-V(i))/(exp((10-V(i))/10)-1));
    b_n(i)=0.125*exp(-V(i)/80);
    n(i+1)=n(i)+t_steps*(a_n(i)*(1-n(i))- b_n(i)*n(i)); %Equation 7

    resting_V=V-65; %Here, the resting potential is set for the neural model, with a value of -65, which is generally considered as the resting membrane potential in academia...
 end
 
%%% (7)...Appropriately Plot the Conductance and Voltage %%%
 
%%%The Voltage Plot%%%

plot_1=plot(time,resting_V,'b','LineWidth',1.5)
hold on
title('The Voltage Measured Over Time in Simulated Neuron')
xlabel('Time (milliseconds)')
ylabel('Voltage (mV)')
legend('Neuron Voltage (mV)')

%%%The Conductance Plot%%%

figure
plot_2=plot(time,g_K*n.^4,'r','LineWidth',1.5);
hold on
plot_3=plot(time,g_Na*(m.^3).*h,'k','LineWidth',1.5);
title('Potassium and Sodium Ions Conductance in Simulated Neuron Model')
xlabel('Time (milliseconds)')
ylabel('Potassium & Sodium Conductance')
legend([plot_2,plot_3],'Potassium Conductance','Sodium Conductance')









