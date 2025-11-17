% Caesar Cipher in MATLAB

str = input('Enter any string: ', 's');
key = input('Enter the Key: ');

encrypted = encrypt(str, key);
fprintf('\nEncrypted String is: %s\n', encrypted);
decrypted = decrypt(encrypted, key);
fprintf('Decrypted String is: %s\n', decrypted);

function encrypted = encrypt(str, key)
encrypted = '';
key = mod(key, 26);
for i = 1:length(str)
ch = str(i);
if isstrprop(ch, 'upper')
c = double(ch) + key;
if c > double('Z')
c = c - 26;
end
elseif isstrprop(ch, 'lower')
c = double(ch) + key;
if c > double('z')
c = c - 26;
end
else
c = double(ch); % non-alphabetic characters remain unchanged
end
encrypted(end + 1) = char(c);
end
end

function decrypted = decrypt(str, key)
decrypted = '';
key = mod(key, 26);
for i = 1:length(str)
ch = str(i);
if isstrprop(ch, 'upper')
c = double(ch) - key;
if c < double('A')
c = c + 26;
end
elseif isstrprop(ch, 'lower')
c = double(ch) - key;
if c < double('a')
c = c + 26;
end
else
    c = double(ch);  % non-alphabetic characters remain unchanged
end
decrypted(end + 1) = char(c);
end
end
