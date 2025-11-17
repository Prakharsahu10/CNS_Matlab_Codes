a = 'abcdefghijklmnopqrstuvwxyz';
b = '@%&wvutsrq24nmlkjihg97dcba';   % Must be 26 chars

if length(b) ~= 26
    error('Cipher mapping misaligned: substitution vector must be 26 characters.');
end

inputStr = input('Enter any string: ', 's');
inputStr = lower(inputStr);

encrypted = '';
decrypted = '';

% --- Encryption ---
for i = 1:length(inputStr)
    c = inputStr(i);
    idx = find(a == c, 1);
    if ~isempty(idx)
        encrypted(end+1) = b(idx);
    else
        encrypted(end+1) = c;
    end
end

% --- Decryption ---
for i = 1:length(encrypted)
    c = encrypted(i);
    idx = find(b == c, 1);
    if ~isempty(idx)
        decrypted(end+1) = a(idx);
    else
        decrypted(end+1) = c;
    end
end

fprintf('Encrypted string : %s\n', encrypted);
fprintf('Decrypted string : %s\n', decrypted);
