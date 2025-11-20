% ECC_bitcoin_simple_verify.m
clc; clear;
disp('Simple Bitcoin Transaction Signing & Verification (Hash Match Only)');

% --- Curve (toy demo) ---

p = 233; a = 1; b = 1; G = [4,5]; n = 233;

% --- Key generation ---

d = randi([1 n-1]); % private key
Q = scalarMult(d, G, a, p); % public key

% --- Transaction input & simple hash (sum ASCII*position mod n) ---

Tx = input('Enter Bitcoin Transaction Data to SIGN: ','s');
h = 0;
for i = 1:length(Tx)
 h = mod(h + double(Tx(i)) * i, n);
end
fprintf('\nTransaction Hash (h) = %d\n', h);

% --- Single signature generation (one attempt) ---

k = randi([1 n-1]);
R = scalarMult(k, G, a, p);
if isempty(R)
 error('R is point at infinity. Re-run the script.');
end
r = mod(R(1), n);
s = mod(invmod(k, n) * (h + mod(d*r, n)), n);
fprintf('Generated Signature: (r=%d, s=%d)\n', r, s);

% ==============================
% --- Simple Verification ---
% ==============================

msg = input('\nEnter message to VERIFY: ','s');
h2 = 0;
for i = 1:length(msg)
 h2 = mod(h2 + double(msg(i)) * i, n);
end
fprintf('Computed Hash from entered message = %d\n', h2);
if h2 == h
 fprintf('\nVerification Result: VALID ✅ (hashes match)\n');
else
 fprintf('\nVerification Result: INVALID ❌ (hashes differ)\n');
end

%% ---- Helper functions ----

function y = invmod(x, m)
 x = mod(x, m);
 [g, u, ~] = gcd(x, m);
 if g ~= 1
 error('Modular inverse does not exist.');
 end
 y = mod(u, m);
end
function R = pointAdd(P, Q, a, p)
 if isempty(P), R = Q; return; end
 if isempty(Q), R = P; return; end
 x1 = P(1); y1 = P(2); x2 = Q(1); y2 = Q(2);
 if x1 == x2 && mod(y1 + y2, p) == 0
 R = []; return;
 end
 if x1 == x2 && y1 == y2
 den = mod(2*y1, p);
 if den == 0, R = []; return; end
 lam = mod((3*x1^2 + a) * invmod(den, p), p);
 else
 den = mod(x2 - x1, p);
if den == 0, R = []; return; end
 lam = mod((y2 - y1) * invmod(den, p), p);
 end
 xr = mod(lam^2 - x1 - x2, p);
 yr = mod(lam * (x1 - xr) - y1, p);
 R = [xr, yr];
end
function R = scalarMult(k, P, a, p)
 R = [];
 if isempty(P) || k == 0, return; end
 Q = P;
 while k > 0
 if bitand(k, 1)
 R = pointAdd(R, Q, a, p);
 end
 Q = pointAdd(Q, Q, a, p);
 k = floor(k/2);
 end
end
