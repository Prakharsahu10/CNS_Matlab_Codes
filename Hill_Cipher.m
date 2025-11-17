function hill_cipher()
% HILL CIPHER ENCRYPTION & DECRYPTION (3x3 key, 3-letter message)
% Get key matrix (3x3)
fprintf('Enter 3x3 key matrix (it should be invertible mod 26):\n');
key = zeros(3,3);
for i = 1:3
for j = 1:3
key(i,j) = input(sprintf('Enter element (%d,%d): ', i, j));
end
end

% Get message

msg = input('Enter a 3-letter lowercase message: ', 's');
if length(msg) ~= 3
error('Message must be exactly 3 characters.');
end
msg_vec = double(msg) - 97; % convert chars to numbers (0-25)

% Encrypt

encrypted_vec = mod(key * msg_vec', 26);
encrypted_msg = char(encrypted_vec' + 97); % convert back to characters
fprintf('\nEncrypted string is: %s\n', encrypted_msg);
% Inverse key modulo 26
inv_key = inverse_mod26(key);

% Decrypt

decrypted_vec = mod(inv_key * encrypted_vec, 26);
decrypted_msg = char(decrypted_vec' + 97);
fprintf('Decrypted string is: %s\n', decrypted_msg);
end
function inv = modinv(a, m)

% Modular inverse using extended Euclidean algorithm

[g, x, ~] = gcd_extended(a, m);
if g ~= 1
error('Modular inverse does not exist');
else
inv = mod(x, m);
end
end
function invA = inverse_mod26(A)

% Compute inverse of matrix A under mod 26 arithmetic

detA = round(det(A));
detA = mod(detA, 26);
if gcd(detA, 26) ~= 1
error('Key matrix is not invertible modulo 26');
end
det_inv = modinv(detA, 26); % modular inverse of determinant

% Cofactor matrix

cofactor = zeros(3,3);
for i = 1:3
for j = 1:3
minor = A;
minor(i,:) = [];
minor(:,j) = [];
cofactor(i,j) = (-1)^(i+j) * round(det(minor));
end
end
adjugate = cofactor'; % transpose of cofactor
invA = mod(det_inv * adjugate, 26);
end
function [g, x, y] = gcd_extended(a, b)

% Extended Euclidean Algorithm

if b == 0
g = a;
x = 1;
y = 0;
[g, x1, y1] = gcd_extended(b, mod(a,b));

x = y1;
y = x1 - floor(a/b)*y1;
end
end
