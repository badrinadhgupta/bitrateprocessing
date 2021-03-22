function out = nrPolarEncode(in,E,varargin)
    narginchk(2,4);
    if nargin==2
        nMax = 9;       
        iIL = true;     
    elseif nargin==3
        coder.internal.errorIf(1,'nr5g:nrPolar:InvalidNumInputs');
    else
        nMax = varargin{1};
        iIL = varargin{2};
    end
    validateInputs(in,E,nMax,iIL);
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
function validateInputs(in,E,nMax,iIL)
    fcnName = 'nrPolarEncode';
    validateattributes(in,{'int8','double'},{'binary','column'}, ...
        fcnName,'IN');
    K = length(in);
 validateattributes(nMax,{'numeric'},{'scalar','integer'}, ...
        fcnName,'NMAX');
    coder.internal.errorIf( ~any(nMax == [9 10]),'nr5g:nrPolar:InvalidnMax');
    validateattributes(iIL, {'logical'}, {'scalar'}, fcnName, 'IIL');
    coder.internal.errorIf( nMax==9 && iIL && (K < 36 || K > 164), ...
        'nr5g:nrPolar:InvalidInputEncDLLength',K);
    coder.internal.errorIf( nMax==10 && ~iIL && (K<18 || (K>25 && K<31) ...
        || K>1023), 'nr5g:nrPolar:InvalidInputEncULLength',K);
    if (K>=18 && K<=25) % for PC-Polar
        nPC = 3;
    else
        nPC = 0;
    end
    validateattributes(E, {'numeric'}, ...
        {'real','scalar','integer','finite','>',K+nPC,'<=',8192}, ...
        fcnName,'E');
end
