function [blk, err] = crcLDPCdesegmentation(cbs,bgn,blklen)
   %bgn = 1;
   %blklen = 10000;
   %cbs = crcLDPCsegmentation(randi([0 1],blklen,1),bgn);
   
    % Get information of code block segments
    chsinfo = nr5g.internal.getCBSInfo(blklen,bgn);

    % Validate dimensions of cbs if there is input for block length
    [K,C] = size(cbs);
    coder.internal.errorIf((C ~= chsinfo.C) || (K ~= chsinfo.K),'nr5g:nrCodeBlockDesegment:InvalidCBSize',K,C,chsinfo.K,chsinfo.C);

    % Remove filler bits
    cbi = cbs(1:end-chsinfo.F,:);

    % Perform code block desegmentation and CRC decoding
    if C == 1
        blk = cbi(:);
        err = zeros(0,1,'uint32');
    else
        [cb,err] = nrCRCDecode(cbi,'24B');
        blk = cb(:);
    end
    blk = blk(1:blklen);

end