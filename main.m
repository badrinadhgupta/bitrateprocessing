clc;
clear all;
close all;

A = 3000;
rate = 449/1024;
modulation = 'BPSK';
rv = 0;
nlayers = 1;

cbsInfo = nrDLSCHInfo(A,rate);
disp('DL-SCH coding parameters')
disp(cbsInfo)

% Random transport block data generation
in = randi([0 1],A,1,'int8');

% Transport block CRC attachment
tbIn = CRCappend(in,cbsInfo.CRC);

% Code block segmentation and CRC attachment
cbsIn = crcLDPCsegmentation(tbIn,cbsInfo.BGN);

% LDPC encoding
enc = LdpcEncoder(cbsIn,cbsInfo.BGN);

% Rate matching and code block concatenation
outlen = ceil(A/rate);
chIn = RateMatchingUsingLDPC(enc,outlen,modulation);

chOut = double(1-2*(chIn));

% Rate recovery
raterec = RateRecoveryLDPC(chOut,A,rate,rv,modulation,nlayers);
%raterec = nrRateRecoverLDPC(chOut,A,rate,rv,modulation,nlayers);

% LDPC decoding
decBits = nrLDPCDecode(raterec,cbsInfo.BGN,25);
%decBits = LdpcDecoder(raterec,cbsInfo.BGN,25);

% Code block desegmentation and CRC decoding
[blk,blkErr] = crcLDPCdesegmentation(decBits,cbsInfo.BGN,A+cbsInfo.L);

disp(['CRC error per code-block: [' num2str(blkErr) ']'])

% Transport block CRC decoding
[out,tbErr] = nrCRCDecode(blk,cbsInfo.CRC);

disp(['Transport block CRC error: ' num2str(tbErr)])
disp(['Recovered transport block with no error: ' num2str(isequal(out,in))])
