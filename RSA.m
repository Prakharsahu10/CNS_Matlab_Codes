clc;
clear;

%% Step 1: Bank Generates RSA Keys

p = 47;
q = 59;
n = p * q;
phi = (p - 1) * (q - 1);

% Public exponent

e = 3;
while gcd(e, phi) ~= 1
 e = e + 2;
end

% Private exponent

d = modInverse(e, phi);
fprintf('Bank Public Key (e,n): (%d, %d)\n', e, n);
fprintf('Bank Private Key (d,n): (%d, %d)\n\n', d, n);

%% Step 2: User Prepares Transaction

cardNumber = '1234567890123456'; % Sample 16-digit card number
amount = 'Rs5000';
message = [cardNumber '|' amount]; % Combine data
fprintf('Original Transaction: %s\n', message);

% Convert message to ASCII

asciiData = double(message);

% Encrypt with bank's public key

cipher = arrayfun(@(x) modexp(x, e, n), asciiData);
fprintf('Encrypted Data Sent to Bank:\n');
disp(cipher);

%% Step 3: Bank Decrypts Transaction

decrypted = arrayfun(@(x) modexp(x, d, n), cipher);
decryptedMessage = char(decrypted);
fprintf('\nBank Received and Decrypted Transaction: %s\n', decryptedMessage);

%% Helper Functions

function g = gcd(a, b)
 while b ~= 0
 temp = b;
 b = mod(a, b);
 a = temp;
 end
 g = a;
end
function d = modInverse(e, phi)
 [g, x, ~] = extendedGCD(e, phi);
 if g ~= 1
 error('Modular inverse does not exist.');
 else
 d = mod(x, phi);
 end
end
function [g, x, y] = extendedGCD(a, b)
 if b == 0
 g = a; x = 1; y = 0;
 else
 [g, x1, y1] = extendedGCD(b, mod(a, b));
 x = y1;
 y = x1 - floor(a/b) * y1;
 end
end
function result = modexp(base, exponent, modval)
 result = 1;
 base = mod(base, modval);
 while exponent > 0
 if mod(exponent, 2) == 1
 result = mod(result * base, modval);
 end
 exponent = floor(exponent / 2);
 base = mod(base^2, modval);
 end
end
