% MAIN_DoubleTimeCovid19.m
% Purpose: use data from OurWorldInData.org to track the rate at which the
% infection is doubling in different countries around the world as a
% function of time. We would like to see which countries are bringing the
% number of new infections under control. 

%% clean up
clear all ; close all ; clc ; 

%% active folders
localDir = fileparts(mfilename('fullpath')) ;
restoredefaultpath ;
addpath(fullfile(localDir, 'active_functions')) ;
addpath(fullfile(localDir, 'data')) ;

%% load data
directory = 'data' ; 
date = today('datetime') ; 
data_table_raw = readtable( sprintf('%s/%s_total_cases.csv',directory,date) ) ; 
data_table = removevars(data_table_raw,{'date','Worldwide'}) ; 
data_table.Properties.DimensionNames{2} = 'data' ; 
% data_table{isnan(data_table.data)} = 0 ; % convert NaN to zero

% import .mat file containing existing tau and date matrices if existing
if isfile('data.mat')
    load('data.mat') ;
else
    all_dates = [] ; 
    all_tau = array2table(...
        zeros(1,size(data_table.Properties.VariableNames,2)),...
        'VariableNames',data_table.Properties.VariableNames) ;
end

% pull date data for use in calculating tau for all countries
date_data = table2array(data_table_raw(:,1)) ; 

% save time constant for every country
tau_ = zeros(1,size(data_table.data,2)) ; 

% function for calculating time constant (doubling rate), run on every
% country
for i = 1:size(data_table.data,2)
    tau_(i) = calc_tau(data_table{:,i}, date_data) ; 
end

tau_table = array2table(tau_,...
    'VariableNames',data_table.Properties.VariableNames) ; 

% save data for today in a new file as a backup
filename = sprintf('%s_tau_data.csv',date) ; 
writetable(tau_table, filename) ; 

% append tau values and dates to matrices in .mat file
all_dates = [all_dates ; date_data(end,1)] ; % append current date
all_tau = [all_tau ; tau_table] ; % append current taus
save('data.mat','all_dates','all_tau') ; 

% plot all data to date
% figure(1)
% for i = 1:size(all_tau,2)
%     plot(all_dates, all_tau{2:end,i}, 'o-')
%     hold on
% end
% title('Doubling Rates by Country') ; 
% xlabel('Date') ; ylabel('Doubling Rate (days)') ; 

% plot current tau in order of size
tau_table = rows2vars(tau_table) ; 
tau_table_sort = sortrows(tau_table,2,'ascend') ; 
figure(2)
x = categorical(tau_table_sort{:,1}) ; 
x = reordercats(x,tau_table_sort{:,1}) ; 
bar(x,tau_table_sort{:,2})
