clc;
clear;

%%  
% Read actual rates
actualRates = readmatrix('rates_N4_59_EXh_4T.dat'); % Adjust filename and format as needed

%%

% Assuming the temperatures of your 5 files are stored in a vector 'temperatures'
temperatures = [10000, 13000, 20000, 25000]; % Replace with actual temperatures

%% 
%{
%%%%%%%%%%%%%%%%%%%%%%%%% Read parameters file %%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen('fit_Exh_N4_4T.dat', 'r');
% Check if the file was opened successfully
if fid == -1
    error('File open failed.');
end
%%
% Initialize arrays to store A, B, and C
A = [];
B = [];
C = [];
%%
% Read the file line by line
while ~feof(fid)
    line = fgetl(fid);
    % Skip lines that don't contain parameter data
    if contains(line, ':')
        % Extract the part of the line after the colon
        paramPart = strsplit(line, ':');
        params = strsplit(strtrim(paramPart{2}), ',');
        % Convert string parameters to numeric and store them
        A(end+1) = str2double(params{1});
        B(end+1) = str2double(params{2});
        C(end+1) = str2double(params{3});
    end
end
fclose(fid);

%%
%%%%%%%%%%%%% Calculate fitted rates for each temperature %%%%%%%%%%%%%%%%%
fitted = zeros(size(A, 2), length(temperatures));
for i = 1:size(A, 2)
    for j = 1:length(temperatures)
        T = temperatures(j);
        fitted(i, j) = A(i) * T^B(i) * exp(-C(i) / (T)); 
    end
end
%%
%%%%%%%%%%%%%%%%%% Calculate K(T=2000k) for each process %%%%%%%%%%%%%%%%%%

k_2000 = zeros(size(A,2),1);
for i =1:size(A,2)
    k_2000(i) = A(i) * 2000^B(i) * exp(-C(i) / 2000); 
end

%%
%%%%%%%%%%%%% Calculate K(T=25000)-K(T=2000) for each process %%%%%%%%%%%%%

for i =1:size(A,2)
    K_diff = fitted(i,end) - k_2000;
end

%%%%%%%%%%%%%%% Calculate the RMS error (percentage) %%%%%%%%%%%%%%%%%%%%%%
rmsErrors = sqrt(mean((fitted./actualRates(:, 5:end) - 1).^2, 2));

%%
%%%%%%%%%%% Energy difference between products and reactants %%%%%%%%%%%%%%

energy_levels = load('E_low.dat');
% Dissociation energy for nitrogen (in appropriate units)
diss_energy_N2 = 9.765; %eV
% Initialize the vector to store energy differences
n = size(actualRates, 1); % Number of reactions
energy_diff = zeros(n, 1);
% Calculate the energy difference for each reaction
for i = 1:n
    E_reac = (energy_levels(actualRates(i,1),2)) + (energy_levels(actualRates(i,2),2));
    E_prod = (energy_levels(actualRates(i,3),2)) + (energy_levels(actualRates(i,4),2));
    energy_diff(i) = E_prod - E_reac;
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%% AUXILIAR VARIABLES:
temp_range = 6000:25000; % Specify the Range of temperature for plotting
r=23; % specify the post-collision quantum state

value_of_r = actualRates(:,3) == r;
p = actualRates(value_of_r,1);
q = actualRates(value_of_r,2);
rms = rmsErrors(value_of_r);
endoOrexo = energy_diff(value_of_r);
K_diff_plot = K_diff(value_of_r);

% Find indices of the five highest values
[sortedValues, sortedIndices] = sort(rmsErrors, 'descend');
topFiveIndices = sortedIndices(1:5);
% Get the y-values and x-positions for the top five bars
topFiveValues = rmsErrors(topFiveIndices);

process_1 = sprintf('process %d: N2(%d) + N2(%d) = N2(%d) + N2(%d)',topFiveIndices(1),actualRates(topFiveIndices(1),1), actualRates(topFiveIndices(1),2), actualRates(topFiveIndices(1),3), actualRates(topFiveIndices(1),4));
process_2 = sprintf('process %d: N2(%d) + N2(%d) = N2(%d) + N2(%d)',topFiveIndices(2),actualRates(topFiveIndices(2),1), actualRates(topFiveIndices(2),2), actualRates(topFiveIndices(2),3), actualRates(topFiveIndices(2),4));
process_3 = sprintf('process %d: N2(%d) + N2(%d) = N2(%d) + N2(%d)',topFiveIndices(3),actualRates(topFiveIndices(3),1), actualRates(topFiveIndices(3),2), actualRates(topFiveIndices(3),3), actualRates(topFiveIndices(3),4));
process_4 = sprintf('process %d: N2(%d) + N2(%d) = N2(%d) + N2(%d)',topFiveIndices(4),actualRates(topFiveIndices(4),1), actualRates(topFiveIndices(4),2), actualRates(topFiveIndices(4),3), actualRates(topFiveIndices(4),4));
process_5 = sprintf('process %d: N2(%d) + N2(%d) = N2(%d) + N2(%d)',topFiveIndices(5),actualRates(topFiveIndices(5),1), actualRates(topFiveIndices(5),2), actualRates(topFiveIndices(5),3), actualRates(topFiveIndices(5),4));

%}
%%
%%%%%%%%%%%%%%%%%%%%%%%%% RMS ERRORS BAR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
figure;
barHandle = bar(rmsErrors);
ylim([0,16]);
xlabel('Index of process based on the file "rates\_N4\_59\_DEXh.dat"');
ylabel('Percentage RMS Error');
title('Highest RMS Errors');
xPositions = 1:length(rmsErrors);
% Label the top five bars
for i = 1:length(topFiveIndices)
    text(xPositions(topFiveIndices(i)), topFiveValues(i), sprintf(' process: %d', topFiveIndices(i)),...
        'VerticalAlignment', 'bottom',...
        'HorizontalAlignment', 'center');
end

for i=1:5
    disp(sprintf('process %d: N2(%d) + N2(%d) = N2(%d) + 2N',topFiveIndices(i),actualRates(topFiveIndices(i),1), actualRates(topFiveIndices(i),2), actualRates(topFiveIndices(i),3)));
end
%}

%%
%%%%%%%%%%%%%%%%%%%%%%%% Fitted Rate Coefficients %%%%%%%%%%%%%%%%%%%%%%%%%

%{
figure;
for i=1:5
    k_T = A(topFiveIndices(i)) .* (temp_range.^B(topFiveIndices(i))) .* (exp(- C(topFiveIndices(i)) ./ temp_range));
    semilogy(temp_range,k_T,'LineWidth', 2);
    hold on
end
xlim([0,5000])
legend(process_1,process_2,process_3,process_4,process_5,'Location', 'best'); 
xlabel('Temperature (k)');
ylabel('Rate coeficient (cm^3 /s)');
title(' Fitted rate coefficients of N2(p)+N2(q)=N2(r)+2N reactions');
%}

%%
%%%%%%%%%% Fitted rate coefficients Vs Actual rate coefficients %%%%%%%%%%%
%{
figure;
for i=1:5
    k_T = A(topFiveIndices(i)) .* (temp_range.^B(topFiveIndices(i))) .* (exp(- C(topFiveIndices(i)) ./ temp_range));
    semilogy(temp_range,k_T,'LineWidth', 2);
    hold on
end
semilogy(temperatures,actualRates(topFiveIndices(1),6:end),'Color',[0, 0.4470, 0.7410],'LineStyle','-.','LineWidth',2);
hold on;
semilogy(temperatures,actualRates(topFiveIndices(2),6:end),'Color',[0.8500, 0.3250, 0.0980],'LineStyle','-.','LineWidth',2);
hold on;
semilogy(temperatures,actualRates(topFiveIndices(3),6:end),'Color',[0.9290, 0.6940, 0.1250],'LineStyle','-.','LineWidth',2);
hold on;
semilogy(temperatures,actualRates(topFiveIndices(4),6:end),'Color',[0.4940, 0.1840, 0.5560],'LineStyle','-.','LineWidth',2);
hold on;
semilogy(temperatures,actualRates(topFiveIndices(5),6:end),'Color',[0.4660, 0.6740, 0.1880],'LineStyle','-.','LineWidth',2);
hold on;
%xlim([5500,25000]);
%ylim([1e-13,1e-11]);
legend(process_1,process_2,process_3,process_4,process_5,sprintf('raw process %d',topFiveIndices(1)),sprintf('raw process %d',topFiveIndices(2)),sprintf('raw process %d',topFiveIndices(3)),sprintf('raw process %d',topFiveIndices(4)),sprintf('raw process %d',topFiveIndices(5)),'Location', 'best');
xlabel('Temperature (k)');
ylabel('Rate coefficient (cm^3 /s)');
title(' Fitted rate coefficients for N2(p)+N2(q)=N2(r)+N+N');
%}

%%
%%%%%%%%%% Exothermic and Endothermic reaction: scatter plot %%%%%%%%%%%%%%
%{
figure;
colors = zeros(length(endoOrexo), 3);  % RGB colors for each point
% Define colors
for i = 1:length(endoOrexo)
    if endoOrexo(i) > 0
        colors(i, :) = [0, 0, 1]; % blue for endothermic
    else
        colors(i, :) = [1, 1, 0]; % yellow for exothermic
    end
end
% Create scatter plot
scatter(p, q, 100, colors, 'filled');
legend('Blue:Endothermic Reactions','Location','Best');
xlabel('p');
ylabel('q');
title(sprintf(' r = %d',r));
%}
%%
%%%%%%%%%%%%%%%%%%%%%%%%% RMS Error: Scatter Plot %%%%%%%%%%%%%%%%%%%%%%%%%
%{
figure;
scatter(p, q, 100, rms, 'filled'); % 100 is the marker size, adjust as needed
colorbar; 
xlabel('p');
ylabel('q');
title(sprintf('Value of RMSE for the process N2(p) + N2(q) = N(%d) + N + N',r));
%}
%%
%%%%%%%%%%%%%%%%%%%%%%% PLOT K(25000) - K(20000) %%%%%%%%%%%%%%%%%%%%%%%%%%
%{
figure;
colors = zeros(length(K_diff_plot), 3);  % RGB colors for each point
% Define colors
for i = 1:length(K_diff_plot)
    if K_diff_plot(i) > 0
        colors(i, :) = [0, 0, 1]; % blue for positive
    else
        colors(i, :) = [1, 1, 0]; % yellow for negative
    end
end
% Create scatter plot
scatter(p, q, 100, colors, 'filled');
legend('Blue: K(25000) > K(2000)','Location','Best');
xlabel('p');
ylabel('q');
title(sprintf(' r = %d',r));
%}