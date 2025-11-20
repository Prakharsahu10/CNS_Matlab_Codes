clc; clear;
disp('=== DSA-style Digital Signature (Pure MATLAB, Hex Output) ===');
% --- DSA Parameters (small primes for demo) ---
p = 467; q = 233; g = 2;
% --- Private and Public Key ---
x = randi([1 q-1]); % private key
y = powermod(g, x, p); % public key
% --- Message and simple hash ---
msg = input('Enter message to sign: ','s');
h = mod(sum((1:length(msg)).*double(msg)), q); % simple hash
% --- Signature generation ---
while true
 k = randi([1 q-1]);
 r = mod(powermod(g, k, p), q);
 if r==0, continue; end
 s = mod(modinv(k, q)*(h + x*r), q);
 if s ~=0, break; end
end
% --- Convert signature to hex string ---
r_bytes = dec2hex(r, 2);
s_bytes = dec2hex(s, 2);
disp('(r, s) uniquely represent the digital signature of a given message (in dec) ')
r
s
signatureHexStr = [r_bytes s_bytes]; % concatenate hex of r and s
fprintf('\nDigital signature for given text (hex format):\n%s\n', signatureHexStr);
%% --- Helper functions ---
function x = modinv(a,m)
[g,u,~] = gcd(a,m);
if g ~= 1, error('No modular inverse exists'); end
x = mod(u,m);
end
function y = powermod(a,b,m)
y = 1; a = mod(a,m);
while b>0
 if bitand(b,1), y = mod(y*a,m); end
 a = mod(a*a,m); b=floor(b/2);
end
end
