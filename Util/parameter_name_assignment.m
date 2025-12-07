function parameter_name = parameter_name_assignment(parameter_of_interest, model)
% This function outputs the string of the name of the parameter in position 
% parameter_number according to the model given by the number model.
    parameter_name = cell(1,length(parameter_of_interest));

    for i=1:length(parameter_of_interest)
        if model == 1
            if parameter_of_interest(i) == 1
                parameter_name{1,i} = '$a$';
            elseif parameter_of_interest(i) == 2
                parameter_name{1,i} = '$b$';
            elseif parameter_of_interest(i) == 3
                parameter_name{1,i} = '$c$';
            elseif parameter_of_interest(i) == 4
                parameter_name{1,i} = '$d$';
            elseif parameter_of_interest(i) == 5
                parameter_name{1,i} = '$I$';
            elseif parameter_of_interest(i) == 6
                parameter_name{1,i} = '$r$';
            elseif parameter_of_interest(i) == 7
                parameter_name{1,i} = '$s$';
            else
                parameter_name{1,i} = '$x_R$';
            end
        else
            if parameter_of_interest(i) == 1
                parameter_name{1,i} = '$C$';
            elseif parameter_of_interest(i) == 2
                parameter_name{1,i} = '$A$';
            elseif parameter_of_interest(i) == 3
                parameter_name{1,i} = '$B$';
            elseif parameter_of_interest(i) == 4
                parameter_name{1,i} = '$a$';
            elseif parameter_of_interest(i) == 5
                parameter_name{1,i} = '$b$';
            elseif parameter_of_interest(i) == 6
                parameter_name{1,i} = '$V_0$';
            elseif parameter_of_interest(i) == 7
                parameter_name{1,i} = '$\nu_{\text{max}}$';
            elseif  parameter_of_interest(i) == 8
                parameter_name{1,i} = '$r$';
            else
                parameter_name{1,i} = '$p$';
            end
        end
    end
end