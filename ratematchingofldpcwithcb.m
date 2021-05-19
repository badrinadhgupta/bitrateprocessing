A = 1000; % Transport block length
rate = 449/1024; % 0<R<1
modulation = 'QPSK'; % QPSK, 16QAM, 64QAM, 256QAM
in = randi([0 1],A,1,'int8');
outlen = ceil(A/rate);
rv =0;
nlayers=1;
Nref= [];
[N,C] = size(in);
% Check against all possible lifting sizes
ZcVec = [2:16 18:2:32 36:4:64 72:8:128 144:16:256 288:32:384];
coder.internal.errorIf(~(any(N==(ZcVec.*66)) || any(N==(ZcVec.*50))), ...
'nr5g:nrLDPC:InvalidInputNumRows',N);

% Determine base graph number from N
if any(N==(ZcVec.*66))
       bgn = 1;
        ncwnodes = 66;
else 
        bgn = 2;
        ncwnodes = 50;
end
    Zc = N/ncwnodes;

% Get modulation order
 switch modulation
        case {'pi/2-BPSK', 'BPSK'}
            Qm = 1;
       case 'QPSK'
            Qm = 2;
        case '16QAM'
            Qm = 4;
        case '64QAM'
            Qm = 6;
        otherwise   % '256QAM'
            Qm = 8;
 end

 % Get code block soft buffer size
  if ~isempty(Nref)
        fcnName = 'nrRateMatchLDPC';
        validateattributes(Nref, {'numeric'}, ...
            {'scalar','integer','positive'},fcnName,'NREF');

        Ncb = min(N,Nref);
  else    % No limit on buffer size
        Ncb = N;
  end

 % Get starting position in circular buffer
  if bgn == 1
        if rv == 0
            k0 = 0;
        elseif rv == 1
            k0 = floor(17*Ncb/N)*Zc;
        elseif rv == 2
            k0 = floor(33*Ncb/N)*Zc;
        else % rv is equal to 3
            k0 = floor(56*Ncb/N)*Zc;
        end
  else
        if rv == 0
            k0 = 0;
        elseif rv == 1
            k0 = floor(13*Ncb/N)*Zc;
        elseif rv == 2
            k0 = floor(25*Ncb/N)*Zc;
        else % rv is equal to 3
            k0 = floor(43*Ncb/N)*Zc;
        end
   end

% code block concatenation 
out = [];
    for r = 0:C-1
        if r <= C-mod(outlen/(nlayers*Qm),C)-1
            E = nlayers*Qm*floor(outlen/(nlayers*Qm*C));
        else
            E = nlayers*Qm*ceil(outlen/(nlayers*Qm*C));
        end
        out = [out; cbsRateMatch(in(:,r+1),E,k0,Ncb,Qm)]; %#okARGOW
    end


function e = cbsRateMatch(d,E,k0,Ncb,Qm)
% Rate match a single code block segment 
    % Bit selection
k = 0;
j = 0;
e = zeros(E,1,class(d));
while k < E
     if d(mod(k0+j,Ncb)+1) ~= -1     % Filler bits
            e(k+1) = d(mod(k0+j,Ncb)+1);
            k = k+1;
        end
        j = j+1;
    end

    % Bit interleaving
e = reshape(e,E/Qm,Qm);
e = e.';
e = e(:);

end

