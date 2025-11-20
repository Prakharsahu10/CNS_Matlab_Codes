clc;
clear;
msg = input('Enter the string: ', 's');
msg_bin = reshape(dec2bin(msg,8).'-'0',1,[]);
mlen = length(msg_bin);
msg_bin = [msg_bin 1];
while mod(length(msg_bin),512) ~= 448
    msg_bin = [msg_bin 0];
end
len64 = dec2bin(mlen,64)-'0';
msg_bin = [msg_bin len64];
h = uint32([hex2dec('67452301'), hex2dec('EFCDAB89'), ...
    hex2dec('98BADCFE'), hex2dec('10325476'), ...
    hex2dec('C3D2E1F0')]);
for chunk = 1:512:length(msg_bin)
    block = msg_bin(chunk:chunk+511);
    w = zeros(1,80,'uint32');
    for i=0:15
        word = block(i*32+1:(i+1)*32);
        w(i+1) = uint32(bin2dec(char(word+'0')));
    end
    for i=17:80
        w(i) = bitrotate(bitxor(bitxor(bitxor(w(i-3), w(i-8)), w(i-14)), w(i-16)), 1);
    end
    a=h(1); b=h(2); c=h(3); d=h(4); e=h(5);
    for i=1:80
        if i<=20
            f = bitor(bitand(b,c), bitand(bitcmp(b),d));
            k = uint32(hex2dec('5A827999'));
        elseif i<=40
            f = bitxor(bitxor(b,c),d);
            k = uint32(hex2dec('6ED9EBA1'));
        elseif i<=60
            f = bitor(bitor(bitand(b,c), bitand(b,d)), bitand(c,d));
            k = uint32(hex2dec('8F1BBCDC'));
        else
            f = bitxor(bitxor(b,c),d);
            k = uint32(hex2dec('CA62C1D6'));
        end
        temp = mod(uint64(bitrotate(a,5)) + uint64(f) + uint64(e) + uint64(k) + uint64(w(i)), 2^32);
        temp = uint32(temp);
        e=d; d=c; c=bitrotate(b,30); b=a; a=temp;
    end
    
    % helper function 
    
    h(1) = uint32(mod(uint64(h(1)) + uint64(a),2^32));
    h(2) = uint32(mod(uint64(h(2)) + uint64(b),2^32));
    h(3) = uint32(mod(uint64(h(3)) + uint64(c),2^32));
    h(4) = uint32(mod(uint64(h(4)) + uint64(d),2^32));
    h(5) = uint32(mod(uint64(h(5)) + uint64(e),2^32));
end
digest = lower([dec2hex(h(1),8) dec2hex(h(2),8) dec2hex(h(3),8) dec2hex(h(4),8) dec2hex(h(5),8)]);
fprintf('SHA-1 Digest = %s\n', digest);
function r = bitrotate(x,n)
    r = bitor(bitshift(x,n,'uint32'), bitshift(x,int32(n)-32,'uint32'));
end
