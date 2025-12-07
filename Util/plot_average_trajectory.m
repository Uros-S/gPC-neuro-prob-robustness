function figID = plot_average_trajectory(results,model,user_settings,simulation_opts,figID)
% This function plots the average state trajectory, its recurrence plot,
% blob counting procedure.

    % Setting simulation options
    t_end = simulation_opts{1,2};
    t_trans = simulation_opts{1,9};

    if model == 1
        % Plot of mean membrane potential
        figID = figID+1;
        figure(figID);
        hold on;
        plot(results.time,results.x.moments(1,:),'LineWidth',2.5);
        grid on;
        xlim([t_trans,t_end]);

        xlabel('$t$','Interpreter','latex');  
        ylabel('$E[x_1]$','Interpreter','latex');
        title('Mean membrane potential')

        ax = gca;
        ax.FontSize = 25;

        % Recurrence plot
        cut_off_indx = find(results.time > t_trans,1);
        results.time = results.time(1,cut_off_indx:end);
        results.y = results.x.moments(1,cut_off_indx:end);
        results.time = results.time(1:50:end);
        results.y = results.y(1:50:end);
        [dist_mat,figID] = recurrence_plot(results,figID);

        % Automatic blob count
        [~,figID] = blob_count(dist_mat,user_settings,figID);

    else
        % Plot y_2 - y_3
        figID = figID+1;
        figure(figID);
        plot(results.time,results.y_2.moments(1,:) - results.y_3.moments(1,:),'LineWidth',1.5);
        grid on;
        xlim([t_trans,t_end]);

        xlabel('$t$','Interpreter','latex');  
        ylabel('$E[y_2-y_3]$','Interpreter','latex');
        title('Mean EEG-like signal')

        ax = gca;
        ax.FontSize = 25;

        % Recurrence plot
        cut_off_indx = find(results.time > t_trans,1);
        results.time = results.time(1,cut_off_indx:end);
        results.y = results.y_2.moments(1,cut_off_indx:end)-results.y_3.moments(1,cut_off_indx:end);
        % results.time = results.time(1:50:end);
        % results.y = results.y(1:50:end);
        [dist_mat,figID] = recurrence_plot(results,figID);

        % Automatic blob count
        [~,figID] = blob_count(dist_mat,user_settings,figID);

    end

end