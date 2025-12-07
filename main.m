% Uros Sutulovic, 12/2025

% Script initialisation
clear; clc;  close all;
addpath([pwd,'/Systems/']) 
addpath([pwd,'/Util/'])
addpath([pwd,'/PoCET_util/'])
figID = 0;

% Model and modality setting
model = 1;              % 1 = Hindmarsh-Rose model
                        % 2 = Jansen-Rit model

modality = 4;           % 1 = nominal system realisation, recurrence plot and blob counting
                        % 2 = average system trajectory, recurrence plot and blob counting
                        % 3 = PRP plot with LE approach
                        % 4 = PRP plot with FG approach

uncertainty_type = 1;     % 1 = uniform distribution with uncertainty interval having nominal parameter values as left end value of the interval
                          % 2 = uniform distribution with uncertainty interval having nominal parameter values as center value of the interval
                          % 3 = uniform distribution with uncertainty interval having nominal parameter values as right end value of the interval

surr_model = 2;           % Galerkin = 1;
                          % collocation = 2;
                          % Monte Carlo = 3;         

switch model 
    %% Hindmarsh-Rose model
    case 1
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
        
        % Parameter name assignment for plots
        parameter_name = parameter_name_assignment(parameter_of_interest,model);

        % Construction of structs for PoCET toolbox
        [states,parameters,inputs] = HR_struct_create(parameters_vec,x_0,uncertainty);

    %% Jansen-Rit model
    case 2
        % Initial conditions setting
        x_0 = [0,0,0,0,0,0];    
        
        % Model parameters setting
        C = 135;         % Parameter 1 (nominal 135, fixed)
        A = 3.25;        % Parameter 2 (nominal 3.25, fixed) 
        B = 22;          % Parameter 3 (nominal 22, fixed)
        a = 100;         % Parameter 4 (nominal 100, fixed)
        b = 50;          % Parameter 5 (nominal 50, fixed)
        V_0 = 6;         % Parameter 6 (nominal 6, fixed)
        nu_max = 5;      % Parameter 7 (nominal 5, fixed)
        r = 0.56;        % Parameter 8 (nominal 0.56, fixed)
        p = 200;         % Parameter 9 (range [0,400])
        
        parameters_vec = [C, A, B, a, b, V_0, nu_max, r, p];
        
        % Setting of parameter that is uncertain around the nominal value
        parameter_of_interest = [2,3];    % parameter that will be uncertain, insert the parameter number
        uncertainty_data = [2,2];         % Delta_max for each parameter in parameter_of_interest
        uncertainty = {parameter_of_interest,uncertainty_data,uncertainty_type};
        
        % Parameter name assignment for plots
        parameter_name = parameter_name_assignment(parameter_of_interest,model);
        
        % Construction of structs for PoCET toolbox
        [states,parameters,inputs] = JR_struct_create(parameters_vec,x_0,uncertainty);
    otherwise
        disp('Model selected not available!');
        return;
end

%% User settings
% PRP settings 
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

%% Other simulation settings
% Simulation settings
t_init = 0;
switch model
    case 1
        t_fin = 1200; 
        delta_t = 0.01;
        t_trans = 600;
    case 2
        t_fin = 2.5;
        delta_t = 0.0001;
        t_trans = 1.75;
end

integrator = 'ode45';

% Settings for automatic blob counting
B_m = 150;      % minimum acceptable blob area to filter out noise blobs
P_m = 0.05;     % minimum acceptable persistency to detect meaningful persistencies
gamma = 0.5;    % to detect blob count abrupt changes (in %)

% Collect al user settings and simulation settings
user_settings = [B_m,P_m,gamma,N,n_points_x,n_points_y];
simulation_opts = {t_init,t_fin,delta_t,integrator,mc_samples,colloc_samples,pce_order,N,t_trans,surr_model};
if isempty(y_start) || isempty(y_end)
    robustness_region = [x_start,x_end];
else
    robustness_region = [x_start,x_end;y_start,y_end];
end

% Checks if uncertainty settings selected are valid
if length(parameter_of_interest) ~= length(uncertainty_data)
    disp('Number of uncertain parameters incompatible with uncertainty data!');
    return;
end

if length(parameter_of_interest) >= 3
    disp('Only analysis up to 2 uncertain parameters implement for now!');
    return;
end

if modality ~= 1
    if max(parameter_of_interest) <= 0 || max(parameter_of_interest) > length(parameters_vec)
        disp('Uncertainty settings incompatible with the model parameters!');
        return;
    end
    
    if uncertainty_type < 1 || uncertainty_type > 3 || surr_model < 1 || surr_model > 3
        disp('Uncertainty settings are not valid!');
        return;
    end
    
    if x_start > x_end
        if ~isempty('y_start') && ~isempty('y_end')
            if y_start > y_end
                disp('Settings for parameter space region to be investigated are not valid!');
                return;
            end
        end
    end
    
    if size(robustness_region,1) ~= length(uncertainty{1,1}) || ...
       round((x_end-x_start)/uncertainty{1,2}(1)) == 0 || (~isempty(y_start) && ~isempty(y_end) && round((y_end-y_start)/uncertainty{1,2}(2)) == 0)
        disp('Robustness region settings do not match uncertainty settings!');
        return;
    end
    
    % At least one iteration is required to count the blobs
    if simulation_opts{1,8} < 1
        disp('At least one level of uncertainty has to be selected!');
        return;
    end
end

%% Computation of the desired results
switch modality    
    case 1
       
        figID = plot_nom_system(model,parameters_vec,x_0,user_settings,simulation_opts,figID);

    case 2

        if  model == 2 && surr_model == 1
            disp('Galerkin approach not available for the selected model');
            return;
        end

        [results,t_end] = surrogate_model(states,parameters,inputs,[],1,surr_model,uncertainty,simulation_opts,model);
        
        disp(newline);
        disp(strcat(['Surrogate model computation time is ',num2str(round(t_end,3,'significant')),' seconds.']));
        
        figID = plot_average_trajectory(results,model,user_settings,simulation_opts,figID);
    
    case {3,4}

        if modality == 3
            uncertainty{1,3} = 1;   % nominal value on the left end of uncertainty intervals
        elseif modality == 4
            uncertainty{1,3} = 2;   % nominal value on the center of uncertainty intervals
        end

        [results,t_end] = parameter_space_analysis(parameters_vec,x_0,model,robustness_region,uncertainty,user_settings,simulation_opts,modality);

        disp(newline);
        disp('End of simulation.');
        disp(strcat(['Computation time needed is ',num2str(round(t_end/3600,3,'significant')),' hours.']));

        save('Results.mat','results');

        % Probabilistic regime preservation plot
        figID = PRP_plot(results,modality,model,user_settings,robustness_region,uncertainty,parameter_name,figID);

    otherwise
        disp('Modality selected not available!');
        return;
end
