  %raterec=RateRecoveryLDPC(chOut,trblklen,rate,rv,modulation,nlayers)
  trblklen = 4000;        
   rate = 0.5;             
   rv = 0;                 
   modulation = 'QPSK';    
   nlayers = 1;            
   sbits = ones(4500,1);
       numCB=[];%number of code block 
       Nref=[];%buffer size
    modulation = validateInputs(in,trblklen,R,rv,modulation,nlayers);
    typeIn = class(in);
    if isempty(in) || ~trblklen
        out = zeros(0,1,typeIn);
        return;
    end
    switch modulation
        case {'pi/2-BPSK', 'BPSK'}
            Qm = 1;
        case 'QPSK'
            Qm = 2;
        case '16QAM'
            Qm = 4;
        case '64QAM'
            Qm = 6;
        otherwise   
            Qm = 8;
    end
    cbsinfo = nrDLSCHInfo(trblklen,R);%code block segmentation input
    bgn = cbsinfo.BGN;%bgn graph
    Zc = cbsinfo.Zc;%expansion factor
    N = cbsinfo.N;
    if ~isempty(numCB)
        fcnName = 'nrRateRecoverLDPC';
        validateattributes(numCB, {'numeric'}, ...
            {'scalar','integer','positive','<=',cbsinfo.C},fcnName,'NUMCB');  

        C = numCB;      
    else
        C = cbsinfo.C;  
    end
    if ~isempty(Nref)
        fcnName = 'nrRateRecoverLDPC';
        validateattributes(Nref, {'numeric'}, ...
            {'scalar','integer','positive'},fcnName,'Nref');

        Ncb = min(N,Nref);
    else    
        Ncb = N;
    end
    if bgn == 1
        if rv == 0
            k0 = 0;
        elseif rv == 1
            k0 = floor(17*Ncb/N)*Zc;
        elseif rv == 2
            k0 = floor(33*Ncb/N)*Zc;
        else % rv == 3
            k0 = floor(56*Ncb/N)*Zc;
        end
    else
        if rv == 0
            k0 = 0;
        elseif rv == 1
            k0 = floor(13*Ncb/N)*Zc;
        elseif rv == 2
            k0 = floor(25*Ncb/N)*Zc;
        else % rv == 3
            k0 = floor(43*Ncb/N)*Zc;
        end
    end
    G = length(in);
    gIdx = 1;
    out = zeros(N,C,typeIn);
    for r = 0:C-1
        if r <= C-mod(G/(nlayers*Qm),C)-1
            E = nlayers*Qm*floor(G/(nlayers*Qm*C));
        else
            E = nlayers*Qm*ceil(G/(nlayers*Qm*C));
        end
        if G < E
            
            zeroPad = zeros(E-G,1,class(in));
            deconcatenated = [in; zeroPad];
        else
            deconcatenated = in(gIdx:gIdx+E-1,1);
        end
        gIdx = gIdx + E;
        out(:,r+1) = cbsRateRecover(deconcatenated,cbsinfo,k0,Ncb,Qm);
    end
    

function out = cbsRateRecover(in,cbsinfo,k0,Ncb,Qm)


    E = length(in);
    in = reshape(in,Qm,E/Qm);
    in = in.';
    in = in(:);
    K = cbsinfo.K - 2*cbsinfo.Zc;
    Kd = K - cbsinfo.F;     
    k = 0;
    j = 0;
    indices = zeros(E,1);
    while k < E
        idx = mod(k0+j,Ncb);
        if ~(idx >= Kd && idx < K)  
            indices(k+1) = idx+1;
            k = k+1;
        end
        j = j+1;
    end
    out = zeros(cbsinfo.N,1,class(in));
   
    out(Kd+1:K) = Inf;
    
    for n = 1:E
        out(indices(n)) = out(indices(n)) + in(n);
    end
    
end

function modulation = validateInputs(in,trblklen,R,rv,modulation,nlayers)


    fcnName = 'nrRateRecoverLDPC';

    
    validateattributes(in,{'double','single'},{'real','column'},fcnName,'IN');


    validateattributes(trblklen,{'numeric'}, ...
        {'scalar','integer','nonnegative','finite'},fcnName,'TRBLKLEN');

    validateattributes(R,{'numeric'}, ...
        {'real','scalar','>',0,'<',1},fcnName,'RATE');

   
    validateattributes(rv,{'numeric'}, ...
        {'scalar','integer','nonnegative','<=',3},fcnName,'RV');

    
    modulation = validatestring(modulation,{'pi/2-BPSK','BPSK','QPSK', ...
        '16QAM','64QAM','256QAM'},fcnName,'MODULATION');

    validateattributes(nlayers,{'numeric'}, ...
        {'scalar','integer','positive','<=',4},fcnName,'NLAYERS');
end
