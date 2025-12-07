function figID = PRP_plot(robustness_data,modality,model,user_settings,robustness_region,uncertainty,parameter_name,figID)
% This fuction construct the PRP plot for the HR model (model 1) and the JR
% model (model 2) from robustness_data according to the LE approach 
% (modality 3) or the FG approach (modality 4).

    x_start = robustness_region(1,1);
    x_end = robustness_region(1,2);

    if length(uncertainty{1,1}) == 2
        y_start = robustness_region(2,1);
        y_end = robustness_region(2,2);
    end

    if modality == 4
        n_x_points = user_settings(5);
        x_values = linspace(x_start,x_end,n_x_points);
    
        if length(uncertainty{1,1}) == 2
            n_y_points = user_settings(6);
            y_values = linspace(y_start,y_end,n_y_points);
        end
    end

    switch modality
        case 3
            figID = figID+1;
            figure(figID);
            hold on;
            blob_numbers = zeros(1,size(robustness_data,1));
            for i=1:size(robustness_data,1)

                if length(uncertainty{1,1}) == 1
                    plot(robustness_data{i,1},robustness_data{i,2}(1,1)*[1,1],'LineWidth',2,'Color',[0 0.4470 0.7410]);
                    hold on;
                    blob_numbers(i) = robustness_data{i,2};

                elseif length(uncertainty{1,1}) == 2
        
                    rect_x = [robustness_data{i,1}(1),robustness_data{i,1}(2),robustness_data{i,1}(2),robustness_data{i,1}(1)];
                    rect_y = [robustness_data{i,2}(1),robustness_data{i,2}(1),robustness_data{i,2}(2),robustness_data{i,2}(2)];
                    if isinf(robustness_data{i,3})     % no significant count detected
                        patch(rect_x,rect_y,'white','LineWidth',2);
                    else
                        patch(rect_x,rect_y,robustness_data{i,3},'LineWidth',2);
                    end
                    blob_numbers(i) = robustness_data{i,3};
                end
            end
        
            % For 1D uncertainty, highlight where regime persistence is lost
            if length(uncertainty{1,1}) == 1
                for i=1:size(robustness_data,1)
                    xline(robustness_data{i,1}(2),'red','LineStyle','--','LineWidth',2);
                end
            end
        
            blob_numbers = blob_numbers(~isinf(blob_numbers));
            hold off;
            title('Probabilistic regime preservation plot');
            xlabel(parameter_name{1,1},'interpreter','latex'); xlim([x_start,x_end]); 
            if length(uncertainty{1,1}) == 1
                ylabel('Blob count'); ylim([min(blob_numbers),max(blob_numbers)]);
            elseif length(uncertainty{1,1}) == 2
                ylabel(parameter_name{1,2},'interpreter','latex'); ylim([y_start,y_end]);
                colorbar;
                if model == 1 && (uncertainty{1,1}(1) == 5 && uncertainty{1,1}(2) == 6)
                    clim([0,500]);
                    view([90 -90]);
                elseif model == 2 
                    pbaspect([3/4,1,1]);
                    clim([0,90]);
                else
                    clim([0,100]);
                end
            end
            ax = gca;
            ax.FontSize = 25;

        case 4  % FG approach for PRP plot

            figID = figID+1;
            figure(figID);
            
            if model == 1
                subplot(2,1,1);
            else
                subplot(1,2,1);
            end
            
            if length(uncertainty{1,1}) == 2
                imagesc([x_values(1),x_values(end)],[y_values(1),y_values(end)],robustness_data(:,:,2),'AlphaData',~isnan(robustness_data(:,:,2)));
                colorbar;
            else
                stem(x_values,robustness_data(:,:,2),'LineWidth',1.5);
            end
            title('Blob count');

            % Adjust the y-tick labels since imagesc() plots them flipped
            ax = gca;
            ytl = get(ax,'YTickLabel');
            ytl = flip(ytl);
            set(ax,'YTickLabel',ytl);

            ax.FontSize = 25;
            if model == 1
                pbaspect([2.1,0.85,1]);
            else
                pbaspect([0.7,1,1]);
            end

            if model == 1
                if uncertainty{1,1}(1) == 5 && uncertainty{1,1}(2) == 6
                    clim([0,500]);
                    pbaspect([1/2.1,1/0.85,1]);
                    view([90 -90]);
                else
                    clim([0,100]);
                end
            else
                clim([0,90]);
            end
            
            if model == 1
                ax2 = subplot(2,1,2);
            else
                ax2 = subplot(1,2,2);
            end

            ax = gca;
            if length(uncertainty{1,1}) == 2
                imagesc([x_values(1),x_values(end)],[y_values(1),y_values(end)],100/user_settings(4)*robustness_data(:,:,1),'AlphaData',~isnan(robustness_data(:,:,1)));
                colorbar;
    
                % Adjust the y-tick labels since imagesc() plots them flipped
                ytl = get(ax,'YTickLabel');
                ytl = flip(ytl);
                set(ax,'YTickLabel',ytl);
    
                colorMapLength = user_settings(4);
                red = [150, 0, 24]/255;
                pink = [255, 230, 230]/255;
                colors_p = [linspace(red(1),pink(1),colorMapLength)', linspace(red(2),pink(2),colorMapLength)', linspace(red(3),pink(3),colorMapLength)'];
                colormap(ax2,flip(colors_p))
            else
                stem(x_values,100/user_settings(4)*robustness_data(:,:,1),'LineWidth',1.5);
            end
            title('Preservation percentage');

            ax.FontSize = 25;
            if model == 1
                pbaspect([2.1,0.85,1]);
                if uncertainty{1,1}(1) == 5 && uncertainty{1,1}(2) == 6
                    pbaspect([1/2.1,1/0.85,1]);
                    view([90 -90]);
                end
            else
                pbaspect([0.7,1,1]);
            end
    end
end