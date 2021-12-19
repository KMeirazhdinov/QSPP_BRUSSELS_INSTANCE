function best  = qspp(a_m,s,t,theta,covariance,f) 


    a_n = sum(nonzeros(a_m));
    V = size(a_m,1);

    % Transpose to create arcs as list
    transposed_d_m = a_m';
    [row,col] = find(transposed_d_m(:,:,1)~=0);
    arcs = [col  row];

    % Creating Constraints 
    A = zeros(V,a_n);
    b = zeros(V,1);

    for i = 1:V

        I_k = find(a_m(:,i)==1);
        O_k = find(a_m(i,:)==1);

        out_from = length(find(a_m(1:i,:)==1)) - length(O_k) + 1;
        out_to = length(find(a_m(1:i,:)==1));

        [z,n] = find(a_m(:,i)==1);
        fill_in = [];

        for q = 1:length(z)
            w = (length(find(a_m(1:z(q),:)==1))-length(find(a_m(z(q),:)...
                ==1))) + length(find(a_m(z(q),1:i-1))) + 1;
            fill_in = [fill_in w];
        end

        if i==s

            A(i,out_from:out_to) = ones(1,length(out_from:out_to));
            b(i) = 1;

        elseif i==t

            A(i,fill_in) = -ones(1,length(fill_in));
            b(i) = -1;

        else
            A(i,out_from:out_to) = ones(1,length(out_from:out_to));
            A(i,fill_in) = -ones(1,length(fill_in));
            b(i) = 0;
        end

    end

    lb = zeros(a_n,1);
    ub = ones(a_n,1);

    objective = @(y) 0.5*theta*(y')*(covariance)*y+(f')*y;
    mean_obj = @(y) (f')*y;
    var_obj = @(y) (y')*(covariance)*y;

    % Step 1
    x = quadprog(theta*covariance,f,[],[],A,b,lb,ub);
    x = round(x,4);

    arcs_in_x = arcs(find(x~=0),:);
    no = find(x~=0);
    mat = zeros(20,20);
    for i = 1:size(arcs_in_x,1)
        mat(arcs_in_x(i,1),arcs_in_x(i,2)) = x(no(i));
    end
    
    paths = fordfulkerson(mat,s,t);
    scores = {};
    best_candidate = [];
    
    for i = 1:length(paths)-1
        x_path = path2x(paths{i},arcs);
        path = paths{i};
        scores{i,1} = path;
        scores{i,2} = mean_obj(x_path);
        scores{i,3} = var_obj(x_path);
        scores{i,4} = objective(x_path);
        best_candidate = [best_candidate [objective(x_path);i]];
    end
    
    [i,b] = min(best_candidate(1,:));
    best_path = scores{b,1};
    best = scores(b,:);
    
    
end