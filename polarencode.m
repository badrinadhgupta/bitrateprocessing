function out = nrPolarEncode(msgcrc,in,E,varargin)
    narginchk(2,4)
    K = length(in);
    if iIL
        pi = nr5g.internal.polar.interleaveMap(K);
        inIntr = in(pi+1);
    else
        inIntr = in;
    end
    [F,qPC] = nr5g.internal.polar.construct(K,E,nMax);
    N = length(F);
    nPC = length(qPC);
    u = zeros(N,1);  
    if nPC > 0
        y0 = 0; y1 = 0; y2 = 0; y3 = 0; y4 = 0;
        k = 1;
        for idx = 1:N
            yt = y0; y0 = y1; y1 = y2; y2 = y3; y3 = y4; y4 = yt;
            if F(idx)  
                u(idx) = 0;
            else       
                if any(idx==(qPC+1))
                    u(idx) = y0;
                else
                    u(idx) = inIntr(k);
                    k = k+1;
                    y0 = double(xor(y0,u(idx)));
                end
            end
        end
    else
        u(F==0) = inIntr;  
    end
    n = log2(N);
    ak0 = [1 0; 1 1];  
    allG = cell(n,1);  
    for i = 1:n
        allG{i} = zeros(2^i,2^i);
    end
    allG{1} = ak0;     
    for i = 1:n-1
        allG{i+1} = kron(allG{i},ak0);
    end
    G = allG{n};
    outd = mod(u'*G,2)';
    out = cast(outd,class(in));
end
