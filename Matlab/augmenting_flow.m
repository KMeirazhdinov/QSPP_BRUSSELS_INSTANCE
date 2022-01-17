function paths = augmenting_flow(arcs,weight,s,t)
    paths = {}; 
    counter = 0;
    while size(arcs,1) ~= 0
        
        [path arcs weight] = move(arcs,weight,s,t);
        if length(path) > 1

            counter = counter + 1;
            paths(counter) = {path}; 
            
        end
        
        if sum(ismember(arcs,s),'all') == 0
            arcs = [];
            weights = [];
        end
        
        if  size(arcs,1)==0 || sum(arcs(:,1)==s) == 0
            return
        end
        
    end
        
    
    
    
    
    function [p arcs weight]= move(arcs,weight,s,t)
        
        p = [s];
        
        w_check = [];
        
        arcs_path = [];
        information = [];
        while p(end) ~= t
            
            ind = find(arcs(:,1)==p(end));
            if length(ind) == 0
                if length(p)~=1
                    last_arc = p(end-1:end);
                    x = ismember(arcs,last_arc,'rows');
                    x_ind = find(x==1);
                    arcs(x_ind,:) = [];
                    weight(x_ind,:) = [];
                    p(end) = [];
                    ind = find(arcs(:,1)==p(end));
                    y = ismember(information(:,2:3),last_arc,'rows');
                    y_ind = find(y==1);
                    information(y_ind,:) = [];
                    arcs_path = [];
                    w_check = [];
                else
                    p = [];
                    return
                end
                
            end
            if sum(ismember(arcs,t),'all') == 0
                arcs = [];
                return
            end
                
            if length(arcs(ind,2))==0 && sum(ismember(arcs,t),'all') == 0%Check where I can go next
                p = [];
                arcs = [];
                weight = [];
                return
                
            elseif length(arcs(ind,2))==0 && sum(ismember(arcs,t),'all') ~= 0
                p = [];
                return
            end
            go_to = arcs(ind,2);
            to_go_weight = weight(ind(1)); %Record the capacities
            
            go_to = go_to(1);
            
            p = [p go_to];
            arcs_path = [arcs_path; arcs(ind(1),:) ind(1)];
            w_check = [w_check to_go_weight(1)];
            
            information = [information; ind(1) arcs(ind(1),:) to_go_weight(1)];
            if isequal(unique(p),sort(p)) == 0 || p(end) == s
                [smallest index] = min(w_check); %index can locate the arc with the smallest weight (row)
                flow = smallest;
                information(:,4) = flow; 
                arcs_involved = information(:,2:3);
                indices = find(ismember(arcs,arcs_involved,'rows')==1);
                weight(indices) = weight(indices) - flow;
                to_delete = find(weight == 0);
                weight(to_delete) = [];
                arcs(to_delete,:) = [];
                q = weight<0.00000000001;
                weight(q) = [];
                arcs(q,:) = [];
                p = [s];
                information = [];
                arcs_path = [];
                w_check = [];
                
            end
           
        end
        if sum(weight<0.000001) == length(weight)
            p = [];
            arcs = [];
            weight = [];
            return 
        end
        [smallest index] = min(w_check); %index can locate the arc with the smallest weight (row)
        flow = smallest;
        information(:,4) = flow;
        weight(information(:,1)) = weight(information(:,1)) - flow;
        to_delete = find(weight == 0);
        weight(to_delete) = [];
        arcs(to_delete,:) = [];
        q = weight<0.00000000001;
        weight(q) = [];
        arcs(q,:) = [];
       
        
    end

end 