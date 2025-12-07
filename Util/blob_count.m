function [blobs,figID] = blob_count(dist_mat,user_settings,figID)
% This function performs the automated blob counting of the input 
% normalised recurrence plot "dist_mat" with the selected user settings.
% If no meaningful persistency is detected, the blob number is assigned to 
% be Inf. If figID==0, then plots relative to blob counting are not shown.
    
    % Setup of thresholding and filtering variables
    delta_threshold = 0.01;     
    threshold = 0:delta_threshold:1;
    n_blobs = zeros(1,length(threshold));
    min_blob_area = user_settings(1);                % minimum blob area in pixels to be accepted
    acceptable_persistence = user_settings(2);       % minimum interval of persistence

    % Initialize variable for persistency
    persistency_matrix = [];  % [persistency,blob count,index at which persistency starts]
    
    for k=1:length(threshold)
        % Blobs identified by thresholding
        dist_mat_BW = dist_mat > threshold(k);
        
        % Count number of blobs
        s = regionprops(dist_mat_BW,'Area');
        s = s(vertcat(s.Area) > min_blob_area);  % exclude small noise blobs
        n_blobs(k) = numel(s);

        % Check persistency
        if k == 1                          % beginning of iteration
            tmp = [0,n_blobs(k),k];
            persistency_matrix = tmp;
        else
            if n_blobs(k) == n_blobs(k-1)   % there is persistency w.r.t. last blob count
                persistency_matrix(end,1) = persistency_matrix(end,1) + 1;
            else                            % there is a change in blob count
                tmp = [0,n_blobs(k),k];
                persistency_matrix = [persistency_matrix;tmp];
            end
        end
    end
    
    % Plot number of blobs counted with respect to the threshold level
    if figID~=0
        figID = figID+1;
        figure(figID)
        plot(threshold,n_blobs,'LineWidth',2.5);
        grid on;
        xlabel('Threshold level');
        ylabel('Blob count');

        ax = gca;
        ax.FontSize = 25;
    end

    % Retain only persistencies bigger than the accepted value and blob counts different from one
    persistency_matrix(:,1) = delta_threshold*persistency_matrix(:,1);
    persistency_matrix = persistency_matrix(persistency_matrix(:,1)>acceptable_persistence,:);
    persistency_matrix = persistency_matrix(persistency_matrix(:,2)~=1,:);

    % No significant persistency detected
    if isempty(persistency_matrix)
        blobs = Inf;
        return;
    end
    
    % Select persistencies at lower threshold values
    flag = 1;   % most persistent blob count is the right choice   
    persistency_matrix = sortrows(persistency_matrix);

    if size(persistency_matrix,1) == 1  % no doubt about persistency
        flag = 0;
        blobs = persistency_matrix(1,2);
    else
        for i=1:size(persistency_matrix,1)-1
            if persistency_matrix(end-i,3) < min(persistency_matrix(end-i+1:end,3)) % check if those persistencies occur for lower threshold values
                 flag = 0;
                 blobs = persistency_matrix(end-i,2);
            end
        end
    end

    if flag 
        blobs = persistency_matrix(end,2);
    end
   
    % Plot persistency bar chart
    if figID~=0
        persistency_matrix = sortrows(persistency_matrix,3); % order persistencies with respect to the threshold level

        figID = figID + 1;
        figure(figID);
        barh(flip(persistency_matrix(:,1)));
        hold on;
        xline(acceptable_persistence,'--r','LineWidth',2)
        yticklabels(flip(persistency_matrix(:,2)));
        xlabel('Persistency');
        ylabel('Blob count');
        title('Persistency bar chart');

        str = ['$BC^*=$',' ',num2str(blobs)];
        annotation('textbox',[.75,.75,.15,.15],'String',str,'Interpreter','latex','FitBoxToText','on','FontSize',25);

        ax = gca;
        ax.FontSize = 25;
    end
end