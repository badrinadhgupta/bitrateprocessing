function cbs = crcLDPCsegmentation(blk,bgn)
blk= randi([0,1],10000,1);
blkLen= 10000;
bgn = 1;


 % Cast the input to double
    blkd = double(blk);
    blkLen = length(blkd);
    typeFlag = islogical(blk) || isa(blk,'int8');
 
    % Get information of code block segments
    chsinfo = nr5g.internal.getCBSInfo(blkLen,bgn);

    % Perform code block segmentation and CRC encoding
    if chsinfo.C == 1
        cbCRC = blkd;
    else
        cb = reshape([blkd; zeros(chsinfo.CBZ*chsinfo.C-blkLen,1)], ...
            chsinfo.CBZ,chsinfo.C);
        cbCRC = nrCRCEncode(cb,'24B');
    end
    % Append filler bits
    cbsd = [cbCRC; -1*ones(chsinfo.F,chsinfo.C)];
        
     % Cast the output data type based on the input data type
    if typeFlag
        cbs = cast(cbsd,'int8');
    else
        cbs = cbsd;
    end

end
