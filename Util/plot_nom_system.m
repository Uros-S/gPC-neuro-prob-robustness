function figID = plot_nom_system(model,parameters_vec,x_0,user_settings,simulation_opts,figID)
% This function plots the nominal system realisation, its recurrence plot,
% blob counting procedure, and phase portrait (for HR model only).

    % Setting simulation options
    t_span = simulation_opts{1,1}:simulation_opts{1,3}:simulation_opts{1,2};
    t_trans = simulation_opts{1,9};
    
    % Nominal system simulation
    if model == 1
        [t,Y] = ode45(@(t,Y)Hindmarsh_Rose(t,Y,parameters_vec),t_span,x_0);

        % Consider only the part of the signal after burn-in time
        cut_off_indx = find(t > t_trans,1);
        t= t(cut_off_indx:end);
        Y = Y(cut_off_indx:end,:);

        figID = figID+1;
        figure(figID);
        plot(t,Y(:,1),'LineWidth',2.5);
        grid on;
        title('Membrane potential');
        xlabel('t','Interpreter','latex');  
        ylabel('$x_1$','Interpreter','latex');

        ax = gca;
        ax.FontSize = 25;
        
        figID = figID+1;
        figure(figID);
        plot3(Y(:,1),Y(:,2),Y(:,3),'LineWidth',2.5);
        title('Phase portrait');
        xlabel('$x_1$','Interpreter','latex');  
        ylabel('$x_2$','Interpreter','latex');  
        zlabel('$x_3$','Interpreter','latex');
        grid on;

        ax = gca;
        ax.FontSize = 25;

        % Recurrence plot
        t = t(1:10:end);
        Y = Y(1:10:end,:);
        signal.time = t;
        signal.y = Y(:,1)';
        [dist_mat,figID] = recurrence_plot(signal,figID);

        % Automatic blob count
        [~,figID] = blob_count(dist_mat,user_settings,figID);

    else
        [t,Y] = ode45(@(t,Y)Jansen_Rit(t,Y,parameters_vec),t_span,x_0);

        % Consider only the part of the signal after burn-in time
        cut_off_indx = find(t > t_trans,1);
        t= t(cut_off_indx:end);
        Y = Y(cut_off_indx:end,:);

        figID = figID+1;
        figure(figID);
        plot(t,Y(:,2)-Y(:,3),'LineWidth',2.5);
        grid on;
        xlabel('t','Interpreter','latex');  
        ylabel('$y_2-y_3$','Interpreter','latex');

        ax = gca;
        ax.FontSize = 25;

        % Recurrence plot
        t = t(1:1:end);
        Y = Y(1:1:end,:);
        signal.time = t;
        signal.y = (Y(:,2)-Y(:,3))';
        [dist_mat,figID] = recurrence_plot(signal,figID);

        % Automatic blob count
        [~,figID] = blob_count(dist_mat,user_settings,figID);
        
    end

end