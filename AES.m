clc;
fprintf('--- S-AES (16-bit) ---\n');
pt_hex = upper(strtrim(input('Enter 16-bit plaintext (4 hex chars, e.g., ABCD):','s')));
key_hex = upper(strtrim(input('Enter 16-bit key (4 hex chars, e.g., 3F27):','s')));
assert(all(isstrprop(pt_hex,'xdigit')) && numel(pt_hex)<=4, 'Plaintext must be hex (≤4 chars).');
assert(all(isstrprop(key_hex,'xdigit')) && numel(key_hex)<=4, 'Key must be hex (≤4 chars).');
pt = hex4_to_nibbles(pt_hex); % [S00 S10 S01 S11] = [n0 n1 n2 n3]
key = hex4_to_nibbles(key_hex);
[K0,K1,K2] = key_expand(key);
ct = s_encrypt(pt, K0,K1,K2);
dec = s_decrypt(ct, K0,K1,K2);
fprintf('Ciphertext : %s\n', nibbles_to_hex4(ct));
fprintf('Decrypted Plaintext : %s\n', nibbles_to_hex4(dec));

%% ---------------- Core S-AES ----------------

function C = s_encrypt(S, K0,K1,K2)
 S = add_key(S,K0); % Round 0
 S = sub_nibbles(S);
 S = shift_row(S);
 S = mix_columns(S);
 S = add_key(S,K1); % Round 1
 S = sub_nibbles(S);
 S = shift_row(S);
 S = add_key(S,K2); % Round 2 (no MixColumn)
 C = S;
end
function P = s_decrypt(C, K0,K1,K2)
 S = add_key(C,K2); % Inv Round 2
 S = shift_row(S); % ISR == SR for 2 columns
 S = inv_sub_nibbles(S);
 S = add_key(S,K1); % Inv Round 1
 S = inv_mix_columns(S);
 S = shift_row(S);
 S = inv_sub_nibbles(S);
 S = add_key(S,K0); % Inv Round 0
 P = S;
end

%% --------------- Round functions (nibble-level) ---------------

function out = add_key(a,b)
 out = bitxor(double(a), double(b));
end
function out = sub_nibbles(a)
 sbox = [9 4 10 11 13 1 8 5 6 2 0 3 12 14 15 7]; % Table D.1a
 out = arrayfun(@(x) sbox(x+1), a);
end
function out = inv_sub_nibbles(a)
 invs = [10 5 9 11 1 7 8 15 6 0 2 3 12 4 13 14]; % Table D.1b
 out = arrayfun(@(x) invs(x+1), a);
end
function out = shift_row(a)
 out = [a(1) a(4) a(3) a(2)];
end
function out = mix_columns(a)
 
 out = zeros(1,4);
 out(1) = bitxor(a(1), gf_mul(4,a(2)));
 out(2) = bitxor(gf_mul(4,a(1)), a(2));
 out(3) = bitxor(a(3), gf_mul(4,a(4)));
 out(4) = bitxor(gf_mul(4,a(3)), a(4));
end
function out = inv_mix_columns(a)

 out = zeros(1,4);
 out(1) = bitxor(gf_mul(9,a(1)), gf_mul(2,a(2)));
 out(2) = bitxor(gf_mul(2,a(1)), gf_mul(9,a(2)));
 out(3) = bitxor(gf_mul(9,a(3)), gf_mul(2,a(4)));
 out(4) = bitxor(gf_mul(2,a(3)), gf_mul(9,a(4)));
end

%% ------------------- Key expansion (Appendix D.3) -------------------

function [K0,K1,K2] = key_expand(k)
 % k = [k0 k1 k2 k3] nibbles; bytes are w0=[k0 k1], w1=[k2 k3]
 w0 = uint8(bitshift(k(1),4) + k(2));
 w1 = uint8(bitshift(k(3),4) + k(4));
 g1 = bitxor(uint8(128), subNib_byte(rotNib(w1))); % RCON1=0x80
 w2 = bitxor(w0, g1);
 w3 = bitxor(w2, w1);
 g2 = bitxor(uint8(48), subNib_byte(rotNib(w3))); % RCON2=0x30
 w4 = bitxor(w2, g2);
 w5 = bitxor(w4, w3);
 K0 = [bitshift(w0,-4), bitand(w0,15), bitshift(w1,-4), bitand(w1,15)];
 K1 = [bitshift(w2,-4), bitand(w2,15), bitshift(w3,-4), bitand(w3,15)];
 K2 = [bitshift(w4,-4), bitand(w4,15), bitshift(w5,-4), bitand(w5,15)];
End
function y = rotNib(b) % rotate two nibbles in a byte
 y = bitor(bitshift(b,4), bitshift(b,-4)); % implicit & 0xFF in uint8
end
function y = subNib_byte(b)
 sbox = uint8([9 4 10 11 13 1 8 5 6 2 0 3 12 14 15 7]);
 hi = bitshift(b,-4); lo = bitand(b,15);
 y = uint8(bitshift(sbox(double(hi)+1),4) + sbox(double(lo)+1));
end

%% ---------------- GF(2^4) multiply via table (Appendix D.2) ----------------

function z = gf_mul(m,a)
 % m,a in 0..15 (nibbles)
 % Full table from GF(2^4) mod x^4+x+1 (rows: multiplier, cols: multiplicand)
 persistent T;
 if isempty(T)
 T = [ ...
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; % 0*
 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; % 1*
 0 2 4 6 8 10 12 14 3 1 7 5 11 9 15 13; % 2*
 0 3 6 5 12 15 10 9 11 8 13 14 7 4 1 2; % 3*
 0 4 8 12 3 7 11 15 6 2 14 10 5 1 13 9; % 4*
 0 5 10 15 7 2 13 8 14 11 4 1 9 12 3 6; % 5*
 0 6 12 10 11 13 7 1 5 3 9 15 14 8 2 4; % 6*
 0 7 14 9 15 8 1 6 13 10 3 4 2 5 12 11; % 7*
 0 8 3 11 6 14 5 13 12 4 15 7 10 2 9 1; % 8*
 0 9 1 8 2 11 3 10 4 13 5 12 6 15 7 14; % 9*
 0 10 7 13 14 4 9 3 15 5 8 2 1 11 6 12; % A*
 0 11 5 14 10 1 15 4 7 12 2 9 13 6 8 3; % B*
 0 12 11 7 5 9 14 2 10 6 1 13 15 3 4 8; % C*
 0 13 9 4 1 12 8 5 2 15 11 6 3 14 10 7; % D*
 0 14 15 1 13 3 2 12 9 7 6 8 4 10 11 5; % E*
 0 15 13 2 9 6 4 11 1 14 12 3 8 7 5 10]; % F*
 end
 z = T(m+1, a+1);
end

%% ----------------- I/O helpers -----------------

function n = hex4_to_nibbles(h)
 if numel(h) < 4, h = pad(h,4,'left','0'); end
 v = hex2dec(h);
 n = [bitand(bitshift(v,-12),15), bitand(bitshift(v,-8),15), ...
 bitand(bitshift(v,-4),15), bitand(v,15)];
end
function h = nibbles_to_hex4(n)
 v = bitshift(n(1),12) + bitshift(n(2),8) + bitshift(n(3),4) + n(4);
 h = upper(sprintf('%04X', v));
end
end
