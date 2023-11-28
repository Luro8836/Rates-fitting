clc;
clear;
%%
data1 = readtable('kf_DExh_N4_59_6000.dat', 'FileType', 'text');
data2 = readtable('kf_DExh_N4_59_10000.dat', 'FileType', 'text');
data3 = readtable('kf_DExh_N4_59_13000.dat', 'FileType', 'text');
data4 = readtable('kf_DExh_N4_59_20000.dat', 'FileType', 'text');
data5 = readtable('kf_DExh_N4_59_25000.dat', 'FileType', 'text');
%%
keyColumns = 1:3;

commonRows = innerjoin(data1(:, keyColumns), data2(:, keyColumns));
commonRows = innerjoin(commonRows, data3(:, keyColumns));
commonRows = innerjoin(commonRows, data4(:, keyColumns));
commonRows = innerjoin(commonRows, data5(:, keyColumns));

numRows = height(commonRows);

commonRows.newColumn1 = ones(numRows, 1);
commonRows.newColumn2 = ones(numRows, 1);


% Extracting the fifth column (values) from each dataset based on common keys
%commonRows.k1 = data1{ismember(data1{:, keyColumns}, commonRows{:, keyColumns}, 'rows'), 4};
commonRows.k2 = data2{ismember(data2{:, keyColumns}, commonRows{:, keyColumns}, 'rows'), 4};
commonRows.k3 = data3{ismember(data3{:, keyColumns}, commonRows{:, keyColumns}, 'rows'), 4};
commonRows.k4 = data4{ismember(data4{:, keyColumns}, commonRows{:, keyColumns}, 'rows'), 4};
commonRows.k5 = data5{ismember(data5{:, keyColumns}, commonRows{:, keyColumns}, 'rows'), 4};
% Write the result to a .dat file with space as the delimiter
writetable(commonRows, 'rates_N4_59_DEXh_4Tem.dat', 'Delimiter', ' ', 'WriteVariableNames', false);

