% Loading Data and adjacency matrix

load('Data.mat') 
load('adjacency.mat')

% Calculating 
a_n = length(nonzeros(a_m));
c = nonzeros(transpose(mean(Data,3)));
Q = zeros(a_n,a_n);
[i j] = find(transpose(a_m) == 1);
arcs = [j i];
for i = 1:a_n
    
    a1 = arcs(i,1);
    a2 = arcs(i,2);
    x = reshape(Data(a1,a2,:),1,180);
    
    for j = i+1:a_n
        
        
        b1 = arcs(j,1);
        b2 = arcs(j,2); 
        y = reshape(Data(b1,b2,:),1,180);
        covv = cov(x,y);
        Q(i,j) = covv(2);
        Q(j,i) = covv(2);
        
    end
    Q(i,i) = var(x);
    
    
    
end

load('covariance(Q).mat')
load('expectation(c).mat')

s = input("Provide a source node: ");
t = input("Provide a sink node: ");
theta = input("Provide a risk aversion parameter theta: ");

% Heuristic solution by Sen et al.(2001)
% optimal_route provides the optimal route found by the heuristic and 
% candidates provides information about all the candidates.
[optimal_route_heuristic, candidates] = QSPP(a_m,s,t,theta,Q,c);
optimal_route_heuristic

% Solution by the exact algorithm using CPLEX functions 
optimal_route_exact  = exact(a_m,s,t,theta,Q,c);
optimal_route_exact
