function hill_cipher()
    % --- Input Key ---
    K = input('Enter 3x3 key matrix: ');
    K = mod(round(K),26);

    % --- Input Message (3 letters) ---
    msg = input('Enter 3-letter lowercase message: ','s');
    if length(msg)~=3, error('Message must be 3 chars'); end
    v = double(msg)-97;

    % --- Encrypt ---
    enc = mod(K*v',26);
    fprintf('Encrypted: %s\n', char(enc'+97));

    % --- Inverse Key ---
    invK = mod26_inv(K);

    % --- Decrypt ---
    dec = mod(invK*enc,26);
    fprintf('Decrypted: %s\n', char(dec'+97));
end

% ---------- Helper Functions ----------
function invA = mod26_inv(A)
    detA = mod(round(det(A)),26);
    detInv = modinv(detA,26);

    C = zeros(3);
    for i=1:3
        for j=1:3
            M = A; M(i,:) = []; M(:,j) = [];
            C(i,j) = (-1)^(i+j)*round(det(M));
        end
    end
    invA = mod(detInv * C', 26);
end

function x = modinv(a,m)
    [g,u,~] = egcd(a,m);
    if g~=1, error('Matrix not invertible mod 26'); end
    x = mod(u,m);
end

function [g,x,y] = egcd(a,b)
    if b==0
        g = a; x = 1; y = 0;
    else
        [g,x1,y1] = egcd(b,mod(a,b));
        x = y1;
        y = x1 - floor(a/b)*y1;
    end
end
