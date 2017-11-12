function [data] = GetAudioFromSpectrogram(S, wnd, overlap, fftSize)

s = size(S);
 
cols = s(2);
xlen = fftSize + cols * (overlap);
data = zeros(1,xlen);

if rem(wnd, 2) == 0
  wnd = wnd + 1;
end

win = zeros(1, fftSize);

halff = fftSize / 2;
halflen = size(wnd, 1) / 2;
acthalflen = min(halff, halflen);

halfwin = 0.5 * ( 1 + cos( pi * (0:halflen)/halflen));
win((halff+1):(halff+acthalflen)) = halfwin(1:acthalflen);
win((halff+1):-1:(halff-acthalflen+2)) = halfwin(1:acthalflen);

for b = 0:overlap:(overlap*(cols-1))
  ft = S(:, 1 + b / overlap)';
  ft = [ ft, conj( ft([(fftSize / 2):-1:2]) ) ];
  px = real( ifft(ft) );
  data( (b + 1):(b + fftSize) ) = data( (b + 1):(b+fftSize) ) + px .* win;
end;

end
