function optimal_route  = exact(a_m,s,t,theta,Q,c)

    nodes = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N",...
        "O","P","Q","R","S","T"];
    
    s = find(nodes==s);
    t = find(nodes==t);

    a_n = sum(nonzeros(a_m));
    V = size(a_m,1);


%     Identify all the arcs
    [row col] = find(transpose(a_m) == 1);
    arcs = [col row]; 
    
%     Creating constraints 
    A = zeros(V,a_n);
    b = zeros(V,1);
    
    for i = 1:length(a_m)
    
        I_k = find(a_m(:,i) == 1);
        add_neg = find(ismember(arcs,[I_k i*ones(length(I_k),1)],...
            'rows')==1);
        O_k = find(a_m(i,:) == 1)';
        add_pos = find(ismember(arcs,[i*ones(length(O_k),1) O_k],...
            'rows')==1);

        if i == s

            A(i,add_pos) = 1;
            b(i) = 1;

        elseif i == t
            
            A(i,add_neg) = -1;
            b(i) = -1;
            
        else 
            
            A(i,add_pos) = 1;
            A(i,add_neg) = -1;
            
        end

    end
    
    lb = zeros(a_n,1);
    ub = ones(a_n,1);
    ctype = repmat('B', 1, a_n);
    opt = cplexoptimset('cplex');
    opt.timelimit = 10;
    [x,fval,exitflag,output] = cplexmiqp(theta*Q,c,[],[],A,b,...
        [],[],[],lb,ub,ctype,[],opt);
    arcs_1 = arcs(find(x~=0),:);
    
    
    objective = @(y) 0.5*theta*(y')*(Q)*y+(c')*y;
    mean_obj = @(y) (c')*y;
    var_obj = @(y) (y')*(Q)*y;
    
    path = [s];
    if size(arcs_1,1) == 1
            
            path = arcs_1;
            arcs_1 = [];
            
    else
        while size(arcs_1,1) ~=0


            next = arcs_1(find(arcs_1(:,1) == path(end)),2);
            ind = find(arcs_1(:,1) == path(end));
            path = [path next];
            arcs_1(ind,:) = [];


        end
    end
    x = path2x(path,arcs);
    optimal_route = {nodes(path),sprintf('Mean = %f', mean_obj(x)),...
        sprintf('Var. = %f', var_obj(x)),...
        sprintf('Obj. = %f', objective(x))};
    
    
end