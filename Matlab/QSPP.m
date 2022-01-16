function [optimal_route, candidates] = QSPP(a_m,s,t,theta,Q,c) 

    nodes = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N",...
        "O","P","Q","R","S","T"];
    
    s = find(nodes==s);
    t = find(nodes==t);

    a_n = sum(nonzeros(a_m));
    V = size(a_m,1);

    % Transpose to create arcs as list
    transposed_d_m = a_m';
    [row,col] = find(transposed_d_m(:,:,1)~=0);
    arcs = [col  row];

    % Creating Constraints 
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
    
    save('m1.mat','A');

    lb = zeros(a_n,1);
    ub = ones(a_n,1);

    objective = @(y) 0.5*theta*(y')*(Q)*y+(c')*y;
    mean_obj = @(y) (c')*y;
    var_obj = @(y) (y')*(Q)*y;

    % Step 1
    options = optimset('Display', 'off');
    x = quadprog(theta*Q,c,[],[],A,b,lb,ub,[],options); 
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
    
    all_nodes = [];
    all_edges = [];
    
    candidates = {};
    for i = 1:length(paths)-1
        x_path = path2x(paths{i},arcs);
        path = paths{i};
        all_nodes = [all_nodes path];
        
        for k = 1:length(path)-1
            edge = [path(k) path(k+1)];
            all_edges = [all_edges; edge];
        end
        
        candidates{i,1} = nodes(path);
        candidates{i,2} = sprintf('Mean = %f', mean_obj(x_path));
        candidates{i,3} = sprintf('Var. = %f', var_obj(x_path));
        candidates{i,4} = sprintf('Obj. = %f', objective(x_path));
        scores{i,1} = path;
        scores{i,2} = sprintf('Mean = %f', mean_obj(x_path));
        scores{i,3} = sprintf('Var. = %f', var_obj(x_path));
        scores{i,4} = sprintf('Obj. = %f', objective(x_path));
        best_candidate = [best_candidate [objective(x_path);i]];
    end
    
    [i,b] = min(best_candidate(1,:));
    best_path = scores{b,1};
    optimal_route = scores(b,:);

%   GRAPHING

%     names = {'{A}','{B}','{C}','{D}','{E}','{F}','{G}','{H}','{I}',...
%         '{J}','{K}','{L}','{M}','{N}','{O}','{P}','{Q}','{R}','{S}','{T}'};
% 
%     all_nodes = unique(all_nodes);
%     all_edges = unique(all_edges,'rows');
%     
% 
%     G = digraph(arcs(find(x~=0),1),arcs(find(x~=0),2),x(find(x~=0)),names);
%     edges = cell2mat(G.Edges.EndNodes);
%     
%     for i = 1:20
%        
%        if (sum(sum(edges(:,1:3) == names{i},2)-2) == 0) &&...
%                (sum(sum(edges(:,4:6) == names{i},2)-2) == 0)
%            G = rmnode(G,names{i});
%        end
%         
%     end
%     
%     H = plot(G,'EdgeLabel',G.Edges.Weight);
%     pl = names(optimal_route{1});
%     
%     for i = 1:size(pl,2)-1
%         highlight(H,[pl(i) pl(i+1)],'EdgeColor','r','LineWidth',2);
%     end

    optimal_route{1} = nodes(optimal_route{1});
    
end