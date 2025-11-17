function TransCipher()
 % Transposition Cipher in MATLAB (Encryption + Decryption)

 % Input
 pl = input('Enter the plain text: ', 's');

 % Step 1: Remove spaces
 
 s = strrep(pl, ' ', ''); % direct space removal
 fprintf('Text without spaces: %s\n', s);

 % Step 2: Initialize encryption matrix
 
 k = length(s);
 col = 4; % fixed column size
 row = ceil(k / col); % ensure enough rows
 ch = repmat('#', row, col); % fill with '#'

 % Fill matrix row-wise
 
 l = 1;
 for i = 1:row
 for j = 1:col
 if l <= k
 ch(i,j) = s(l);
 l = l + 1;
 end
 end
 end
 
 % Step 3: Transpose (columnar arrangement)
 
 trans = ch.'; % transpose in MATLAB

 % Step 4: Read column-wise (encryption)
 
 enc = '';
 for i = 1:col
 for j = 1:row
 enc = [enc trans(i,j)];
 end
 end
 fprintf('Encrypted Text: %s\n', enc);

 % ---------------- Decryption ----------------
 
 % Step 5: Fill matrix column-wise from ciphertext
 
 decMat = repmat('#', col, row);
 l = 1;
 for i = 1:col
 for j = 1:row
 decMat(i,j) = enc(l);
 l = l + 1;
 end
 
 end
 
 % Step 6: Transpose back
 
 decMat2 = decMat.';

 % Step 7: Read row-wise to reconstruct message
 
 dec = '';
 for i = 1:row
 for j = 1:col
 dec = [dec decMat2(i,j)];
 end
 end

% Remove padding '#'

 dec = strrep(dec, '#', '');
fprintf('\nDecrypted Text: %s\n', dec);
end
