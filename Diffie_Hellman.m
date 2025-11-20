clc;
clear;
% Step 1: Input prime number p
p = input('Enter prime number: ');
% Step 2: Input primitive root g
g = input(['Enter primitive root of ', num2str(p), ': ']);
% Step 3: Input private key x (Sender side)
x = input(['Enter value for x less than ', num2str(p), ': ']);
% Compute R1 = g^x mod p
R1 = powermod(g, x, p);
fprintf('R1 = %d\n', R1);
% Step 4: Input private key y (Receiver side)
y = input(['Enter value for y less than ', num2str(p), ': ']);
% Compute R2 = g^y mod p
R2 = powermod(g, y, p);
fprintf('R2 = %d\n', R2);
% Step 5: Compute secret key at sender's side
K1 = powermod(R2, x, p);
fprintf('Key calculated at Sender''s side: %d\n', K1);
% Step 6: Compute secret key at receiver's side
K2 = powermod(R1, y, p);
fprintf('Key calculated at Receiver''s side: %d\n', K2);
disp('Diffie-Hellman secret key was calculated successfully.');
