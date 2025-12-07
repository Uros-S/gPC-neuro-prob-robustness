function [results,t_end] = parameter_space_analysis(parameters_vec,x_0,model,robustness_region,uncertainty,user_settings,simulation_opts,modality)
% This function collects probabilistic robustness results in a selected
% region of a parameter space, either with LE approach (modality 3) or FG
% approach (modality 4), using changes in blob count for increasing
% parametric uncertainties.

    t_start = tic;

    % Initialise parameter space region to be analysed
    x_start = robustness_region(1,1);
    x_end = robustness_region(1,2);
    if size(robustness_region,1) == 2
        y_start = robustness_region(2,1);
        y_end = robustness_region(2,2);
    end

    % Compute orthogonal polynoimials once for the HR model and then just update the spectral coefficients
    if model == 1
        pce_order = simulation_opts{1,7};
        [states,parameters,inputs] = HR_struct_create(parameters_vec,x_0,uncertainty);
        sys = PoCETcompose(states,parameters,inputs,[],pce_order);
    else
        sys = [];
    end
    
    switch modality

        case 3  % LE approach

            % Initialise uncertain parameters at the beginning of the parameter space
            parameters_vec(uncertainty{1,1}(1)) = x_start;
            if size(robustness_region,1) == 2
                parameters_vec(uncertainty{1,1}(2)) = y_start;
            end
            
            blob_numbers = [];
            
            % Uncertain parameters value at each iteration of the algorithm
            x_iter = x_start;
            if size(robustness_region,1) == 2
                y_iter = y_start;   
            end
        
            counter = 0;
        
            if size(robustness_region,1) == 1
        
                for i=1:round((x_end-x_start)/uncertainty{1,2}(1))
                    tmp = LE_approach_1D(parameters_vec,x_0,sys,model,x_iter,user_settings,uncertainty,simulation_opts);
                    blob_numbers = [blob_numbers;tmp];
                    x_iter = x_iter+uncertainty{1,2}(1);
        
                    % Progression log
                    counter = counter+1;
                    disp(newline); disp(newline); disp(newline);
                    disp([num2str(counter),'/',num2str(round((x_end-x_start)/uncertainty{1,2}(1)))]);
                    disp(newline); disp(newline); disp(newline);
                end
        
            else
        
                for i=1:round((y_end-y_start)/uncertainty{1,2}(2))
                    for j=1:round((x_end-x_start)/uncertainty{1,2}(1))
                        tmp = LE_approach_2D(parameters_vec,x_0,sys,model,x_iter,y_iter,user_settings,uncertainty,simulation_opts);
                        blob_numbers = [blob_numbers;tmp];
                        x_iter = x_iter+uncertainty{1,2}(1);
            
                        % Progression log
                        counter = counter+1;
                        disp(newline); disp(newline); disp(newline);
                        disp([num2str(counter),'/',num2str(round((y_end-y_start)/uncertainty{1,2}(2))*round((x_end-x_start)/uncertainty{1,2}(1)))]);
                        disp(newline); disp(newline); disp(newline);
                    end
                    x_iter = x_start;
                    y_iter = y_iter+uncertainty{1,2}(2);
                end
        
            end
        
            results = blob_numbers;

        case 4  % FG approach

            delta_x = uncertainty{1,2}(1)/user_settings(4);
            
            n_x_points = user_settings(5);
            x_values = linspace(x_start,x_end,n_x_points);

            if size(robustness_region,1) == 2
                n_y_points = user_settings(6);
                y_values = linspace(y_start,y_end,n_y_points);
                robustness_limits = zeros(n_y_points,n_x_points,2);
            else
                n_y_points = 1;
                y_values = [];
                robustness_limits = zeros(1,n_x_points,2);
            end

            counter = 0;
            
            for j=1:max([1,length(y_values)])   % max needed when only x_values are selected
                for i=1:length(x_values)
                    parameters_vec(uncertainty{1,1}(1)) = x_values(i);
                    if size(robustness_region,1) == 2
                        parameters_vec(uncertainty{1,1}(2)) = y_values(j);
                    end
                    [blob_num,end_coord,blob_drop] = probabilistic_robustness(parameters_vec,x_0,sys,model,user_settings,uncertainty,simulation_opts);

                    if isnan(blob_drop)
                        robustness_limits(j,i,1) = NaN; % only numerical fluctuations detected as recurrence pattern
                    else
                        robustness_limits(j,i,1) = round((end_coord(1,1)-x_values(i))/delta_x); % end coordinates consider left-end fixed instead of the center, it does not matter in retrieving the preservation percentage
                    end
                    
                    robustness_limits(j,i,2) = blob_num;

                    % Progression log
                    counter = counter+1;
                    disp(newline); disp(newline); disp(newline);
                    disp([num2str(counter),'/',num2str(n_x_points*n_y_points)]);
                    disp(newline); disp(newline); disp(newline);

                end
            end
            
            if size(robustness_region,1) == 2
                robustness_limits = flip(robustness_limits);
            end
            results = robustness_limits;
    end

    t_end = toc(t_start);
end