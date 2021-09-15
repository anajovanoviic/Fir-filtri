clear all, close all, clc

M = 100;
%analogne frekv.
fs = 16e3; %16 kHz
f0 = 3.3e3; %3.3 kHz

%digitalna frekv. u rad - granicna frekv.
w0 = 2*pi*f0/fs;

%%

%fir1 - fja za projektovanje nerekurzivnih mreza koriscenjem Hamingove
%prozorske fje koja daje koeficijente polinoma u brojiocu;
%w0/pi-normalizacija granicne frekv. na opseg od 0 do 1 (zahtev fir funkcije) deljenjem sa pi jer
%je w0 u opsegu od 0 do pi;

h = fir1(M, w0/pi);


%H-frekventni odziv digitalnog filtra u digitalnom domenu;
%w-vektor frekvencija
%drugi argument je jedan jer je fir
%mreza u pitanju; treci arg. je broj tacaka u kojima se izracunava
%frekventni odziv
[H, w] = freqz(h, 1, 2048);


%umesto da w ide od 0 do pi, imacemo opseg od 0 do 1
%amplitudska k-ka je moduo frekv. odziva
%predstavljanje ampiltudske k-ke preko k-ke pojacanja u decibelima

%sa grafika vidimo: k-ka pojacanja je oko 0dB u propusnom opsegu
figure ('Name','Amplitudska karakteristika - k-ka pojacanja filtra','NumberTitle','off'),
plot(w / pi, 20*log10(abs(H)));

%%

%fazna k-ka je argument frekvencijskog odziva
figure ('Name','Fazna karakteristika filtra','NumberTitle','off'),
%plot(w/pi, unwrap(angle(H))/2) %fazna k-ka
%plot(w/pi, unwrap(2*angle(H))/pi)
plot(w/pi, unwrap(2*angle(H))/2/pi) %fazna k-ka - potpuno razmotana faza

figure ('Name','Karakteristika grupnog kasnjenja filtra','NumberTitle','off'),
%k-ka grupnog kasnjenja
%treci arg. je vektor frekvencije
gd = grpdelay(h,1,w);
plot(w/pi, gd);

%% 2.
f1 = 300;
f2 = 2500;
f3 = 5000;

w1 = 2*pi*f1/fs;
w2 = 2*pi*f2/fs;
w3 = 2*pi*f3/fs;

x1 = sin(w1 * (0:15999));
x2 = sin(w2 * (0:15999));
x3 = sin(w3 * (0:15999));

%spajanje signala
x = [x1 x2 x3];
n = 0:length(x) - 1;
%reprodukcija signala gde je x vektor vrednosti signala,a drugi argument je
%frekvencija odmeravanja
%koriscenjem zvucne kartice dobijamo 3 tona
sound(x, fs)

%%

%realizovati skrembler

%nosilac
s = 2 * cos(w0*n);

%propustanje signala x(n) kroz NF filtar;h-impulsni odziv
%filtra-brojilac;1-imenilac(FIR);x-pobudni signal;
%fja filter vraca odziv odnosno racuna konvolucionu sumu (1)
y0 = filter(h,1,x);
y1 = y0 .* s; %elementwise mnozenje jer se ne radi o matricnom mnozenju
y2 = filter(h, 1, y1);



%na izlazu skremblera dobijamo samo 2 tona
sound(y2, fs)

%fft-diskretna furijeove t.
%amplitudsku k-ku dobijamo pomocu fft-e pobodnog niza
X = fft(x);
figure,
stem(abs(X))

%P - broj tacaka kojima je odredjena Furijeova transformacija
P = length(X);
X = X(1:P /2); % od 0 do pi
w = 2 * pi /P * (0:P/2-1);

%amplitudska k-ka ulaznog signala
%figure,
figure('Name','Amplitudska karakteristika pobudnog niza','NumberTitle','off'),
stem(w / pi, abs(X)) %SPEKTAR pobudnog niza - curenje

%spektar odziva
Y2 = fft(y2)
Y2 = Y2(1:P/2)
figure('Name','Amplitudska karakteristika odziva','NumberTitle','off'),
stem(w / pi, abs(Y2))


% % sound(x, fs)
% % sound(y2, fs)

%% 3
%prelaz u format Q15
%h-koeficijenti impulsnog odziva
hQ15 = round(h*2^15)
%treba nam samo polovina mnozaca zato sto je fazna k-ka NF filtra linearna
%f-ja frekvencije, koef. simetricni
hfxp = hQ15(1 : 51);


fid = fopen('koef.txt','w');
for i = 1 :51
    fprintf(fid, '%d, ',hfxp(i));
end
fclose(fid);

%racunamo 160 odbiraka signala nosioca
N = 160;
n = 0:N-1; %redni brojevi odmeraka
s = 2 * cos(w0*n); %nosilac - jedna perioda

sfxp = round(s*(2^14-1));
fid = fopen('nosilac.txt','w');
for i = 1 :N 
    fprintf(fid, '%d, ',sfxp(i));
end
fclose(fid);









