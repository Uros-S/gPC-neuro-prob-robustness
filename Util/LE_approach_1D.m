function blob_numbers = LE_approach_1D(parameters_vec,x_0,existing_sys,model,x_iter,user_settings,uncertainty,simulation_opts)
% This function collects probabilistic robustness results with LE approach
% in the case of 1D parametric uncertainty for a single uncertain segment
% to be investigated.
    
    % Store blob count information and coordinates of the segments: {[x_1,x_2],blob count}
    blob_numbers = [];
    
    % Minimum interval of uncertainty setted
    uncert_min = uncertainty{1,2}(1)/user_settings(4);
    
    % Initialise parameter value
    parameters_vec(uncertainty{1,1}(1)) = x_iter;
    
    while 1
        % Run a blob count on the remaining segment
        [blobs,x_cutoff,blob_drop] = probabilistic_robustness(parameters_vec,x_0,existing_sys,model,user_settings, uncertainty, simulation_opts);

        if isnan(blob_drop)    % only numerical fluctuations detected as recurrence pattern, move to another region of uncertainty
            blob_drop = 1;
        end
        
        % Check if abrupt changes in the blob count happened
        if blob_drop

            % Save the computation made so far
            tmp = {[x_iter,x_cutoff],blobs};
            blob_numbers = [blob_numbers;tmp];

            % Update the new segment to be analysed
            uncertainty{1,2}(1) = x_iter + uncertainty{1,2}(1) - x_cutoff;
            parameters_vec(uncertainty{1,1}(1)) = x_cutoff;
            x_iter = x_cutoff;
            simulation_opts{1,8} = round(uncertainty{1,2}(1)/uncert_min);    % reduce number of uncertainty levels according to uncertain interval length
    
       % No abrupt change in the blob count in the segment
        else
            tmp = {[x_iter,x_iter+uncertainty{1,2}(1)],blobs};
            blob_numbers = [blob_numbers;tmp];
            break;
        end
    end
end