function [blob_num,end_coord,blob_drop] = probabilistic_robustness(nom_parameters,x_0,existing_sys,model,user_settings,uncertainty,simulation_opts)
% This function progressively widens an uncertainty region up to a maximum
% uncertainty level, starting from the parameter values in nom_parameters. 
% At each step the recurrence plot is computed according to the modality 
% specified by the variable method and the number of blobs in it are 
% counted. The function stops early if an abrupt change happens in the blob
% count (blob_drop is set to 1), which is quantified by the variable in 
% percentage gamma, or only numerical fluctuations are detected (blob_drop 
% is set to NaN). 

    % Setting of simulation parameters
    parameter_number = uncertainty{1,1};
    interval_max = uncertainty{1,2};
    t_trans = simulation_opts{1,9};
    surr_model = simulation_opts{1,10};
    eps = 1e-7;                          % to detect numerical fluctuations

    % User defined PRP plot settings
    gamma = user_settings(3);
    N = simulation_opts{1,8};
    
    % Define the uncertainty regions to analyse according to the maximum uncertainty level N
    intervals = [];
    for i=1:length(interval_max)
        interval_temp = 0:interval_max(i)/N:interval_max(i);
        interval_temp = interval_temp(2:end);
        intervals = [intervals,interval_temp'];
    end
    
    if isempty(intervals)
        disp('Uncertainty intervals not well-defined!');
        intervals = 0;
    end

    % Initialisation of blob count vector for each uncertainty region
    blobs = zeros(1,size(intervals,1));

    blob_drop = 0;
    
    % Iterate over the number of the uncertainty region subdivisions
    for k=1:size(intervals,1) 
        % Construction of structs for PoCET toolbox
        uncertainty{1,2} = intervals(k,:);
        if model == 1
            [states,parameters,inputs] = HR_struct_create(nom_parameters,x_0,uncertainty);
        else
            [states,parameters,inputs] = JR_struct_create(nom_parameters,x_0,uncertainty);
        end

        % Surrogate model results using collocation approach
        [signal,~] = surrogate_model(states,parameters,inputs,existing_sys,1,surr_model,uncertainty,simulation_opts,model);
    
        % Consider only the part of the signal after burn-in time
        cut_off_indx = find(signal.time > t_trans,1);
  
        signal.time = signal.time(1,cut_off_indx:end);
        if model == 1
            signal.y = signal.x.moments(1,cut_off_indx:end);
        else
            signal.y = signal.y_2.moments(1,cut_off_indx:end)-signal.y_3.moments(1,cut_off_indx:end);
        end

        % Check if at first iteration recurrence patterns are only due to numerical fluctuations
        if k == 1 && ((max(signal.y) - min(signal.y)) < eps)
            blob_drop = NaN;    % robustness properties are not significant
            x_end = nom_parameters(parameter_number(1))+intervals(1,1);
            if length(parameter_number) == 2
                y_end = nom_parameters(parameter_number(2))+intervals(1,2);
            end
            blob_num = NaN;
            if length(parameter_number) == 1
                end_coord = x_end;
            elseif length(parameter_number) == 2
                end_coord = [x_end,y_end];
            end
            return;
        end
        
        % Reduce the length of the signal to have manageable distance matrices
        if model == 1 
            signal.time = signal.time(1:50:end);      
            signal.y = signal.y(1:50:end);
        else
            signal.time = signal.time(1:6:end);      
            signal.y = signal.y(1:6:end);
        end
        
        % Compute the distance matrix
        [dist_mat,~] = recurrence_plot(signal,0);
        
        % Count the number of blobs in the recurrence plot
        [tmp,~] = blob_count(dist_mat,user_settings,0);
        blobs(1,k) = tmp;
        
        if k>1   % Always compute the first iteration
            % Detect abrupt changes in the blob count w.r.t. the first iteration
            % if the first count is not zero, or detect deviations from
            % zero if we start with a zero blob count
            if (blobs(1,1) ~= 0 && (blobs(1,k) <= (1-gamma)*blobs(1,1) || blobs(1,k) >= (1+gamma)*blobs(1,1))) ||...
               (blobs(1,1) == 0 && blobs(1,k) ~= 0)
                    blob_drop = 1;
                    % We need to know where the change in blob count happened
                    x_end = nom_parameters(parameter_number(1))+intervals(k-1,1);
                    if length(parameter_number) == 2
                        y_end = nom_parameters(parameter_number(2))+intervals(k-1,2);
                    end
                    blob_num = max(blobs(1,1:k-1));
                    if length(parameter_number) == 1
                        end_coord = x_end;
                    elseif length(parameter_number) == 2
                        end_coord = [x_end,y_end];
                    end
                    return;
            end

        else
            % No meaningul blob count detected in first iteration
            if isinf(blobs(1,1))
                blob_drop = 1;
                x_end = nom_parameters(parameter_number(1))+intervals(1,1);
                if length(parameter_number) == 2
                    y_end = nom_parameters(parameter_number(2))+intervals(1,2);
                end
                blob_num = NaN;
                if length(parameter_number) == 1
                    end_coord = x_end;
                elseif length(parameter_number) == 2
                    end_coord = [x_end,y_end];
                end
                return;
            end
        end
    end
  
    blob_num = max(blobs(1,:));

    x_end = nom_parameters(parameter_number(1))+intervals(end,1);
    if length(parameter_number) == 2
        y_end = nom_parameters(parameter_number(2))+intervals(end,2);
    end

    if length(parameter_number) == 1
        end_coord = x_end;
    elseif length(parameter_number) == 2
        end_coord = [x_end,y_end];
    end
end