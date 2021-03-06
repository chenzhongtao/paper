function init(mop)


    global subproblems params idealpoint nadpoint parDim objDim EP;
    idealpoint=ones(mop.od,1)*inf;
    nadpoint = ones(mop.od,1)*(-inf);
    parDim = mop.pd;
    objDim = mop.od;
    
    subproblems = init_weights(params.popsize, params.niche, mop.od);
    params.popsize = length(subproblems);
    
    %initial the subproblem's initital state.
    for i=1:params.popsize
        ind = randompoint(mop);
        [value, ind] = evaluate( mop, ind );
        idealpoint = min(idealpoint, value);
        nadpoint = max(nadpoint, value);
        subproblems(i).curpoint = ind;
        subproblems(i).oldpoint = ind;
        EP(i).parameter = ind.parameter;
        EP(i).objective = ind.objective;
        EP(i).index=zeros( params.niche,1);
        EP(i).result=zeros( params.niche,1);
        %initialize external population
    end  
end

function subp=init_weights(popsize, niche, objDim)

global ind1 subproblems
temp_ind1 = get_structure('ind1');
ind1 = repmat(temp_ind1, length(subproblems),1);
    
    subp = [];
    
    %to load the parameter from the given file.
    filename = sprintf('weight/W%uD_%u.dat',objDim, popsize);
    
    if (exist(filename, 'file'))
        % copy from the exist file. 
        p=get_structure('subproblem');
        subp=repmat(p, popsize,1);
        allws = importdata(filename);
        for i=1:popsize
            subp(i).weight = allws(i,:)';
        end
    else
        %generate on the fly.
        for (i=1:popsize)
            if (objDim==2)
                p=get_structure('subproblem');
                weight=zeros(2,1);
                weight(1)=i/popsize;
                weight(2)=(popsize-i)/popsize;
                p.weight=weight;
                subp=[subp p];
            elseif objDim==3
            %TODO
            end
        end
    end

    %Set up the neighbourhood.
    leng=length(subp);
    distanceMatrix=zeros(leng, leng);
    for i=1:leng
        for j=i+1:leng
            A=subp(i).weight;B=subp(j).weight;
            distanceMatrix(i,j)=(A-B)'*(A-B);
            distanceMatrix(j,i)=distanceMatrix(i,j);
        end
        [s,sindex]=sort(distanceMatrix(i,:));
        subp(i).neighbour=sindex(1:niche)';
        ind1(i).index(1)=subp(i).neighbour(1);
    end
end