function x = path2x(path,arcs)

    from = [];
    to = [];
    
    for i = 1:length(path)-1
        from(i) = path(i);
        to(i) = path(i+1);
    end
    
    needed = [from' to'];
    x = ismember(arcs,needed,'rows');
    
end