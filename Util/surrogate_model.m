function [results,tEnd] = surrogate_model(states,parameters,inputs,existing_sys,moment_order,surr_model,uncertainty,simulation_opts,model)
% This function computes the first moment_order statistics on the uncertainty
% structure specified by the structs "states" and "parameters" according to
% the surrogate model specified by "surr_model" and the simulation options
% specified by "simulation_opts". The time taken to compute the results is
% returned as well. If existing_sys is not empty, then the orthogonal
% polynomials are not recomputed.

    % Setting of simulation parameters
    simoptions.tspan = [simulation_opts{1,1}, simulation_opts{1,2}];
    simoptions.dt = simulation_opts{1,3};
    simoptions.setup = odeset;
    simoptions.solver = simulation_opts{1,4};

    tStart = tic;

    % Compose the PCE system
    if isempty(existing_sys)    % compute orthogonal polynomials from scratch
        pce_order = simulation_opts{1,7};
        sys = PoCETcompose(states,parameters,inputs,[],pce_order);  
    else                        % no need to recompute the orthogonal polynomials
        tmp1 = {parameters.name};
        tmp2 = {parameters.data};
        if length(uncertainty{1,1}) == 1
            sys = PoCETupdate(existing_sys,tmp1{uncertainty{1,1}(1)},tmp2{uncertainty{1,1}(1)});
        elseif length(uncertainty{1,1}) == 2
            sys = PoCETupdate(existing_sys,tmp1{uncertainty{1,1}(1)},tmp2{uncertainty{1,1}(1)}, ...
                                           tmp1{uncertainty{1,1}(2)},tmp2{uncertainty{1,1}(2)});
        end
    end

    % Write files
    PoCETwriteFiles(sys,'PoCET_deterministic_expanded_system',[],'PoCET_nominal_system');

    %% Galerkin approach
    if surr_model == 1 

        % Run galerkin-PCE simulation
        results = PoCETsimGalerkin(sys,'PoCET_deterministic_expanded_system',[],simoptions);  
        
        % Compute moments from simulation results
        sys.MomMats = PoCETmomentMatrices(sys,moment_order);
        results.x.moments = PoCETcalcMoments(sys,sys.MomMats,results.x.pcvals);
        
        % Computation time
        tEnd = toc(tStart);

    %% Collocation approach
    elseif surr_model == 2  

        % Run collocation-PCE simulation
        rng(123,'twister')   % for repeatability
        colloc_samples = simulation_opts{1,6};
        basis = PoCETsample(sys,'basis',colloc_samples);    % 'basis' samples from the stochastic basis \xi and not the actual random variable
        results = PoCETsimCollocation(sys,'PoCET_nominal_system',[],basis,simoptions);
        
        % Compute moments from simulation results for quantities of interest
        sys.MomMats = PoCETmomentMatrices(sys,moment_order);
        if model == 1
            results.x.moments = PoCETcalcMoments(sys,sys.MomMats,results.x.pcvals);
        elseif model == 2
            results.y_1.moments = PoCETcalcMoments(sys,sys.MomMats,results.y_1.pcvals);
            results.y_2.moments = PoCETcalcMoments(sys,sys.MomMats,results.y_2.pcvals);
            results.y_3.moments = PoCETcalcMoments(sys,sys.MomMats,results.y_3.pcvals);
        end

        % Computation time
        tEnd = toc(tStart);
    
    %% Monte Carlo
    elseif surr_model == 3 

        % Run Monte-Carlo simulations
        mc_samples = simulation_opts{1,5};
        rng(123,'twister')   % for repeatability
        results = PoCETsimMonteCarlo(sys,'PoCET_nominal_system',[],mc_samples,simoptions,'method','moments');

        % Computation time
        tEnd = toc(tStart);
    end

end