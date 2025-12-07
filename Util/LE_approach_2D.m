function blob_numbers = LE_approach_2D(parameters_vec,x_0,existing_sys,model,x_iter,y_iter,user_settings,uncertainty,simulation_opts)
% This function collects probabilistic robustness results with LE approach
% in the case of 2D parametric uncertainty for a single uncertain rectangle
% to be investigated.
    
    % Store blob count information and coordinates of the rectangle as: {[x_1,x_2],[y_1,y_2],blob count}
    blob_numbers = [];

    eps = 1e-10;    % for numerical errors in computing total area covered
    
    % Settings of rectangle coordinates
    x_begin = x_iter;
    x_end = x_iter + uncertainty{1,2}(1);
    y_begin = y_iter;
    y_end = y_iter + uncertainty{1,2}(2);
    
    % Initialise parameter values
    parameters_vec(uncertainty{1,1}(1)) = x_iter;
    parameters_vec(uncertainty{1,1}(2)) = y_iter;

    % Run the first blob count
    [blobs,cutoff_coord,blob_drop] = probabilistic_robustness(parameters_vec,x_0,existing_sys,model,user_settings,uncertainty,simulation_opts);

    if isnan(blob_drop)    % only numerical fluctuations detected as recurrence pattern, move to another region of uncertainty
        blob_drop = 1;
    end

    if ~blob_drop || abs(cutoff_coord(1)-x_end) < eps   % we are done with no further partitions
        tmp = {[x_begin,x_end],[y_begin,y_end],blobs};
        blob_numbers = [blob_numbers;tmp];
        return;
    else
        % Initialise variables to store information on rectangle partitions
        uncert_min_x = uncertainty{1,2}(1)/user_settings(4);
        uncert_min_y = uncertainty{1,2}(2)/user_settings(4);
        total_area = (x_end-x_begin)*(y_end-y_begin);

        % Store the computation already made
        x_cutoffs = [x_begin;cutoff_coord(1)];
        y_cutoffs = cutoff_coord(2);
        
        uncertainty{1,2}(1) = x_end - cutoff_coord(1);
        simulation_opts{1,8} = round(uncertainty{1,2}(1)/uncert_min_x);
        N = simulation_opts{1,8};
        uncertainty{1,2}(2) = simulation_opts{1,8}*uncert_min_y;    % uncertainty scales the same in both directions

        parameters_vec(uncertainty{1,1}(1)) = cutoff_coord(1);      % keep same y-coordinate
        x_iter = cutoff_coord(1);

        tmp = {[x_begin,cutoff_coord(1)],[y_begin,cutoff_coord(2)],blobs};
        blob_numbers = [blob_numbers;tmp];
        area_covered = (cutoff_coord(1)-x_begin)*(cutoff_coord(2)-y_begin);

        % Iterate until the whole rectangle is completed
        while abs(area_covered-total_area) > eps
            
            % Proceed first in the x-direction
            while abs(x_iter-x_end) > eps

                [blobs,cutoff_coord,blob_drop] = probabilistic_robustness(parameters_vec,x_0,existing_sys,model,user_settings,uncertainty,simulation_opts);

                if isnan(blob_drop)    % only numerical fluctuations detected as recurrence pattern, move to another region of uncertainty
                    blob_drop = 1;
                end

                x_cutoffs = [x_cutoffs;cutoff_coord(1)];
                y_cutoffs = [y_cutoffs;cutoff_coord(2)];
                
                % update uncertainty limits if a blob drop occurs or if we are at risk of exceeding the borders of the uncertain rectangle to be investigated
                if abs(cutoff_coord(1)-x_end) > eps && (blob_drop || (x_end-cutoff_coord(1) < uncertainty{1,2}(1)))
                    simulation_opts{1,8} = min([round((x_end - cutoff_coord(1))/uncert_min_x),N]);
                    uncertainty{1,2}(1) = simulation_opts{1,8}*uncert_min_x;
                    uncertainty{1,2}(2) = simulation_opts{1,8}*uncert_min_y;
                end

                tmp = {[x_iter,cutoff_coord(1)],[y_iter,cutoff_coord(2)],blobs};
                blob_numbers = [blob_numbers;tmp];

                area_covered = area_covered + (cutoff_coord(1)-x_iter)*(cutoff_coord(2)-y_iter);
                x_iter = cutoff_coord(1);
                parameters_vec(uncertainty{1,1}(1)) = cutoff_coord(1);  % keep same y-coordinate

            end
            
            % Compute the remaining areas in the stripe [y_iter,max(y_cutoffs)]
            y_cutoffs_max = max(y_cutoffs);
            rem_rectangles = [];    % at each row [x-coord lower left corner,y-coord lower left corner,delta_min x uncertainty levels, delta_min y uncertainty levels]

            % Individuate the uncomputed regions
            for i=1:length(y_cutoffs)
                if y_cutoffs(i) < y_cutoffs_max
                    rem_rectangles = [rem_rectangles; ...
                                      x_cutoffs(i),y_cutoffs(i), ...
                                      round((x_cutoffs(i+1)-x_cutoffs(i))/uncert_min_x), ...
                                      round((y_cutoffs_max-y_cutoffs(i))/uncert_min_y)];
                end
            end

            % Analyse each remaining region
            for k=1:size(rem_rectangles,1)
                % Compute the blob count in the whole rectangle
                simulation_opts{1,8} = 1;
                parameters_vec(uncertainty{1,1}(1)) = rem_rectangles(k,1);
                parameters_vec(uncertainty{1,1}(2)) = rem_rectangles(k,2);
                uncertainty{1,2}(1) = rem_rectangles(k,3)*uncert_min_x;
                uncertainty{1,2}(2) = rem_rectangles(k,4)*uncert_min_y;

                [blobs,~,~] = probabilistic_robustness(parameters_vec,x_0,existing_sys,model,user_settings,uncertainty,simulation_opts);
                
                if (~isnan(blobs(1)) && blobs(1)~=0) || (rem_rectangles(k,3)==1 && rem_rectangles(k,4)==1) % we accept the outcome
                    tmp = {[rem_rectangles(k,1),rem_rectangles(k,1)+uncertainty{1,2}(1)], ...
                        [rem_rectangles(k,2),rem_rectangles(k,2)+uncertainty{1,2}(2)],blobs};
                    blob_numbers = [blob_numbers;tmp];

                    area_covered = area_covered + uncertainty{1,2}(1)*uncertainty{1,2}(2);
                else    % a finer partition is needed
                    increment_x = 0;
                    increment_y = 0;
                    uncertainty{1,2}(1) = uncert_min_x;
                    uncertainty{1,2}(2) = uncert_min_y;
                    for j=1:rem_rectangles(k,4)
                        for i=1:rem_rectangles(k,3)
                            parameters_vec(uncertainty{1,1}(1)) = rem_rectangles(k,1) + increment_x;
                            parameters_vec(uncertainty{1,1}(2)) = rem_rectangles(k,2) + increment_y;
    
                            [blobs,~,~] = probabilistic_robustness(parameters_vec,x_0,existing_sys,model,user_settings,uncertainty,simulation_opts);

                            tmp = {[parameters_vec(uncertainty{1,1}(1)),parameters_vec(uncertainty{1,1}(1))+uncert_min_x], ...
                            [parameters_vec(uncertainty{1,1}(2)),parameters_vec(uncertainty{1,1}(2))+uncert_min_y],blobs};
                            blob_numbers = [blob_numbers;tmp];

                            area_covered = area_covered + uncert_min_x*uncert_min_y;

                            increment_x = increment_x + uncert_min_x;
                        end
                        increment_x = 0;
                        increment_y = increment_y + uncert_min_y;
                    end
                end
            end
            
            % Update variables for next iteration on the new y-level
            if abs(y_cutoffs_max-y_end) > eps 
                y_iter = y_cutoffs_max;
            end
            x_iter = x_begin;
            parameters_vec(uncertainty{1,1}(1)) = x_iter;
            parameters_vec(uncertainty{1,1}(2)) = y_iter;
            simulation_opts{1,8} = round((y_end-y_iter)/uncert_min_y);
            N = simulation_opts{1,8};
            uncertainty{1,2}(1) = simulation_opts{1,8}*uncert_min_x;
            uncertainty{1,2}(2) = simulation_opts{1,8}*uncert_min_y;
            
            % Reset the vectors of the subdivsion information
            x_cutoffs = x_begin;
            y_cutoffs = [];
        end
    end
end