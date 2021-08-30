function out = RateMatchingUsingLDPC(in,outlen,modulation)
    %A = 1000; % Transport block length
    %rate = 449/1024; % 0<R<1
    %modulation = 'QPSK'; % QPSK, 16QAM, 64QAM, 256QAM
    %in = randi([0 1],A,1,'int8');
    %outlen = ceil(A/rate);
    [N,C] = size(in);
    % To Check against all possible lifting sizes
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

      % Get rate matching output for all code blocks
      out = [];
      for r = 0:C-1
         if r <= C-mod(outlen/Qm,C)-1
             E = Qm*floor(outlen/(Qm*C));
         else
             E = Qm*ceil(outlen/(Qm*C)); 
         end
           out = [out; cbsRateMatch(in(:,r+1),E,N,Qm)]; %#okARGOW
      end
end

function e = cbsRateMatch(d,E,N,Qm)
% Rate match a single code block segment 

    % Bit selection
    k = 0;
    j = 0;
    e = zeros(E,1,class(d));
    while k < E
        if d(mod(j,N)+1) ~= -1     % Filler bits
            e(k+1) = d(mod(j,N)+1);
            k = k+1;
        end
        j = j+1;
    end
    %interleaving
    e = reshape(e,E/Qm,Qm);
    e = e.';
    e = e(:);

end
