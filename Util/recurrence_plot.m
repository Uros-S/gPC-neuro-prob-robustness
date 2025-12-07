function [dist_mat,figID] = recurrence_plot(signal,figID)
% This function computes the normalised recurrence plot of the input signal.
% If figID==0, the recurrence plot is not shown and only the distance
% matrix is computed.

    N = length(signal.time);
    dist_mat = zeros(N,N);

    for i=1:N
        dist_mat(:,i) = abs(repmat(signal.y(1,i),N,1)-signal.y(1,:)');
    end

    dist_mat = flip(dist_mat);

    % Normalize distance matrix
    dist_mat = 1/max(dist_mat,[],'all')*dist_mat;
    
    if figID ~= 0 
        figID = figID+1;
        figure(figID);
        imagesc(signal.time',flip(signal.time)',dist_mat);
        axis square;
        set(gca,'YDir','normal');
        set(gca,'YTickLabel',[]);
        set(gca,'XTickLabel',[]);
        colorbar;
        xticklabels('auto'); yticklabels('auto');
        xlabel('$t$','Interpreter','latex'); 
        ylabel('$t$','Interpreter','latex');
        title('Recurrence plot');
    
        ax = gca;
        ax.FontSize = 25;
    end

end