# gPC_neuro_prob_robustness
Code used to generate the figures in Main Text and Supplementary Material of the paper "gPC-based robustness analysis of neural systems through probabilistic recurrence metrics" by U. Sutulovic, D. Proverbio, R. Katz, and G. Giordano.  
ArXiv version of the paper coming soon.

# License 
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

The full text of the GNU General Public License can be found in the file "LICENSE.txt".

# Usage
# b-I space HR model with LE approach (Fig. 6b1 in Main Text)

* Insert "model = 1;" and "modality = 3;"

* In "%% HR model" insert the following settings:
 
% Initial conditions setting   
x_0 = [0,0,0];
        
% Model parameters setting

a = 1.0;         % Parameter 1 (nominal 1.0, fixed)  
b = 3.0;         % Parameter 2 (nominal 3.0, plausible range [2, 5])   
c = 1.0;         % Parameter 3 (nominal 1.0, fixed)  
d = 5.0;         % Parameter 4 (nominal 5.0, fixed)  
I = 2.4;         % Parameter 5 (nominal 3.5, range [0.4, 5.6])  
r = 0.01;        % Parameter 6 (nominal 0.01, usual range [0.001, 0.035])  
s = 4.0;         % Parameter 7 (nominal 4.0, fixed)  
x_R = -8/5;      % Parameter 8 (nominal -8/5, fixed)  
        
parameters_vec = [a, b, c, d, I, r, s, x_R];
        
% Setting of parameter that is uncertain around the nominal value   
parameter_of_interest = [2,5];    % parameter that will be uncertain, insert the parameter number    
uncertainty_data = [0.1,0.2];   % Delta_max for each parameter in parameter_of_interest  
uncertainty = {parameter_of_interest,uncertainty_data,uncertainty_type};  

* In "%% User settings" insert the following settings:

N = 8;                         % maximum uncertainty level  
n_points_x = [];  
n_points_y = [];  

% Surrogate model settings  
pce_order = 5;  
colloc_samples = 250;  
mc_samples = [];

% Set the coordinates of the parameter space to be analysed  
x_start = 2.5;  
x_end = 3.3;  
y_start = 2.2;  
y_end = 4.4;

# b-I space HR model with FG approach (Fig. 6c1 in Main Text)

* Insert "model = 1;" and "modality = 4;"

* In "%% HR model" insert the following settings:
 
% Initial conditions setting  
x_0 = [0,0,0];
        
% Model parameters setting  
a = 1.0;         % Parameter 1 (nominal 1.0, fixed)  
b = 3.0;         % Parameter 2 (nominal 3.0, plausible range [2, 5])  
c = 1.0;         % Parameter 3 (nominal 1.0, fixed)  
d = 5.0;         % Parameter 4 (nominal 5.0, fixed)  
I = 3.5;         % Parameter 5 (nominal 3.5, range [0.4, 5.6])  
r = 0.01;        % Parameter 6 (nominal 0.01, usual range [0.001, 0.035])  
s = 4.0;         % Parameter 7 (nominal 4.0, fixed)  
x_R = -8/5;      % Parameter 8 (nominal -8/5, fixed)
        
parameters_vec = [a, b, c, d, I, r, s, x_R];
        
% Setting of parameter that is uncertain around the nominal value  
parameter_of_interest = [2,5];    % parameter that will be uncertain, insert the parameter number  
uncertainty_data = [0.1,0.2];   % Delta_max for each parameter in parameter_of_interest  
uncertainty = {parameter_of_interest,uncertainty_data,uncertainty_type};

* In "%% User settings" insert the following settings:

N = 8;                         % maximum uncertainty level  
n_points_x = 27;  
n_points_y = 36;  

% Surrogate model settings  
pce_order = 5;  
colloc_samples = 250;  
mc_samples = [];

% Set the coordinates of the parameter space to be analysed  
x_start = 2.5;  
x_end = 3.3;  
y_start = 2.2;  
y_end = 4.4;

# r-I space HR model with LE approach (Fig. 6b2 in Main Text)

* Insert "model = 1;" and "modality = 3;"

* In "%% HR model" insert the following settings:
 
% Initial conditions setting  
x_0 = [0,0,0];
        
% Model parameters setting  
a = 1.0;         % Parameter 1 (nominal 1.0, fixed)  
b = 3.0;         % Parameter 2 (nominal 3.0, plausible range [2, 5])  
c = 1.0;         % Parameter 3 (nominal 1.0, fixed)  
d = 5.0;         % Parameter 4 (nominal 5.0, fixed)  
I = 3.5;         % Parameter 5 (nominal 3.5, range [0.4, 5.6])  
r = 0.01;        % Parameter 6 (nominal 0.01, usual range [0.001, 0.035])  
s = 4.0;         % Parameter 7 (nominal 4.0, fixed)  
x_R = -8/5;      % Parameter 8 (nominal -8/5, fixed)  
        
parameters_vec = [a, b, c, d, I, r, s, x_R];
        
% Setting of parameter that is uncertain around the nominal value  
parameter_of_interest = [5,6];    % parameter that will be uncertain, insert the parameter number  
uncertainty_data = [0.1,0.005];   % Delta_max for each parameter in parameter_of_interest  
uncertainty = {parameter_of_interest,uncertainty_data,uncertainty_type};

* In "%% User settings" insert the following settings:

N = 8;                         % maximum uncertainty level  
n_points_x = [];  
n_points_y = [];

% Surrogate model settings  
pce_order = 5;  
colloc_samples = 250;  
mc_samples = [];

% Set the coordinates of the parameter space to be analysed  
x_start = 2.4;  
x_end = 3.4;      
y_start = 0.005;  
y_end = 0.03;  

# r-I space HR model with FG approach (Fig. 6c2 in Main Text)

* Insert "model = 1;" and "modality = 4;"

* In "%% HR model" insert the following settings:
 
% Initial conditions setting  
x_0 = [0,0,0];
        
% Model parameters setting  
a = 1.0;         % Parameter 1 (nominal 1.0, fixed)  
b = 3.0;         % Parameter 2 (nominal 3.0, plausible range [2, 5])   
c = 1.0;         % Parameter 3 (nominal 1.0, fixed)  
d = 5.0;         % Parameter 4 (nominal 5.0, fixed)  
I = 3.5;         % Parameter 5 (nominal 3.5, range [0.4, 5.6])  
r = 0.01;        % Parameter 6 (nominal 0.01, usual range [0.001, 0.035])  
s = 4.0;         % Parameter 7 (nominal 4.0, fixed)  
x_R = -8/5;      % Parameter 8 (nominal -8/5, fixed)  
        
parameters_vec = [a, b, c, d, I, r, s, x_R];
        
% Setting of parameter that is uncertain around the nominal value  
parameter_of_interest = [5,6];    % parameter that will be uncertain, insert the parameter number  
uncertainty_data = [0.1,0.005];   % Delta_max for each parameter in parameter_of_interest  
uncertainty = {parameter_of_interest,uncertainty_data,uncertainty_type};

* In "%% User settings" insert the following settings:

N = 8;                         % maximum uncertainty level  
n_points_x = 18;  
n_points_y = 30;  

% Surrogate model settings  
pce_order = 5;  
colloc_samples = 250;  
mc_samples = [];

% Set the coordinates of the parameter space to be analysed  
x_start = 2.4;  
x_end = 3.4;  
y_start = 0.005;  
y_end = 0.03;  

# A-B space JR model with FG (Fig. 7 in Main Text)

* Insert "model = 2;" and "modality = 4;"

* In "%% Jansen-Rit model" insert the desired values of C and p

* In "%% User settings" insert the following settings: 

N = 8;                         % maximum uncertainty level  
n_points_x = 20;  
n_points_y = 20;  

% Surrogate model settings  
pce_order = 5;  
colloc_samples = 250;  
mc_samples = [];

% Set the coordinates of the parameter space to be analysed  
x_start = 2;  
x_end = 12;  
y_start = 15;  
y_end = 31;
