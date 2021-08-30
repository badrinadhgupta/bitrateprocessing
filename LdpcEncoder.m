function out = LdpcEncoder(in,bgn)
    typeIn = class(in);

    if isempty(in)
        out = zeros(0,size(in,2),typeIn);
        return;
    end
    
    [L, M] = size(in);

    if bgn==1
        nsys = 22;
        ncw = 66;
    else
        nsys = 10;
        ncw = 50;
    end

    Zc = L/nsys;
    N = Zc*ncw;

    locs = find(in(:,1)==-1);   
    in(locs,:) = 0;

    outCBall = nr5g.internal.ldpc.encode(double(in),bgn,Zc);
    outCBall(locs,:) = -1;

    out = zeros(N,M,typeIn);
    out(:,:) = cast(outCBall(2*Zc+1:end,:),typeIn);
end