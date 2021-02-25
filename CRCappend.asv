function datacrc = CRCappend(data,type)
    polyIndex = nr5g.internal.validateCRCinputs(data,type,0,'nrCRCEncode');
    polyLengths = [6 11 16 24 24 24];
    
    len(:) = polyLengths(polyIndex);
    
    [codeLen,numCodeBlocks] = size(data);
    
    dataL = logical(data);
    
    
    if isempty(data)
        datacrc = zeros(codelen);
    else
        datacrcL = false(codeLen+len,numCodeBlocks);

        gPoly = getPoly(type);
        for i = 1:numCodeBlocks
            datacrcL(:,i) = crcEncode(double(dataL(:,i)),gPoly,len);
        end
        datacrc = [data; cast(datacrcL(end-len+1:end,:),class(data))];

    end
end
        
   function out = crcEncode(in,gPoly,gLen)

    inPad = [in; zeros(gLen,1)];
   
    remBits = [0; inPad(1:gLen,1)];
    for i = 1:length(inPad)-gLen
        dividendBlk = [remBits(2:end); inPad(i+gLen)];
        if dividendBlk(1) == 1
            remBits = rem(gPoly+dividendBlk,2);
        else
            remBits = dividendBlk;
        end
    end
    parityBits = remBits(2:end);

    out = logical([in; parityBits]);

end
    
    function gPoly = getPoly(poly)


    switch poly
        case '6'
            gPoly = [1 1 0 0 0 0 1]';
        case '11'
            gPoly = [1 1 1 0 0 0 1 0 0 0 0 1]';
        case '16'
            gPoly = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1]';
        case {'24a','24A'}
            gPoly = [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1]';
        case {'24b','24B'}
            gPoly = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 1 1]';
        otherwise % {'24c','24C'}
            gPoly = [1 1 0 1 1 0 0 1 0 1 0 1 1 0 0 0 1 0 0 0 1 0 1 1 1]';
    end
    
    end
