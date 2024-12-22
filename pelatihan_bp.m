clc; clear; close all; warning off all;

% membaca data excel 
data_suhu = xlsread('data_iklim.xlsx',2,'E5:P9');
% melakukan transpose data
data_suhu =  data_suhu';
% mengubah matriks menjadi bentuk vektor
data_suhu = data_suhu(:);
% mencari nilai min dan max data
min_data = min(data_suhu);
max_data = max(data_suhu);

% normalisasi data
[m,n] = size(data_suhu);
data_norm = zeros(m,n);
for x = 1:m
    for y = 1:n
        data_norm(x,y) = (data_suhu(x,y)- min_data)/(max_data - min_data);
    end
end

%---------------------------------------------------------%
% menyiapkan data latih hasil normalisasi
tahun_latih = 4; % tahun 2019 s.d 2022
jumlah_bulan = 12; 
data_latih_norm = zeros(jumlah_bulan * tahun_latih - jumlah_bulan, jumlah_bulan);
% menyusun data latih normalisasi
for m = 1:jumlah_bulan * tahun_latih - jumlah_bulan
    for n = 1:jumlah_bulan
        data_latih_norm(m,n) = data_norm(m+n-1);
    end
end

% menyiapkan target latih normalisasi
target_latih_norm = zeros(jumlah_bulan * tahun_latih - jumlah_bulan, 1);
for m = 1:jumlah_bulan * tahun_latih - jumlah_bulan
    target_latih_norm(m) = data_norm(jumlah_bulan + m); % data 2022
end

% melakukan transpose data latih dan target latih normalisasi
data_latih_norm = data_latih_norm';
target_latih_norm = target_latih_norm';
%----------------------------------------------%

% menetapkan parameter Jaringan Syaraf Tiruan
jumlah_neuron1 = 100; %dapat di variasikan dengan angka lainnya
fungsi_aktivasi1 = 'logsig'; %sigmoid biner
fungsi_aktivasi2 = 'logsig';
fungsi_pelatihan = 'traingd';
%----------------------------------------------%

% membangun arsitektur JST dengan backpropagation (BP)
rng('default')
jaringan = newff(minmax(data_latih_norm),[jumlah_neuron1 1], ...
    {fungsi_aktivasi1, fungsi_aktivasi2}, fungsi_pelatihan); 

% melakukan pelatihan jaringan 
jaringan = train(jaringan, data_latih_norm, target_latih_norm);

% membaca hasil pelatihan
hasil_latih_norm = sim(jaringan,data_latih_norm);

% normalisasi de-normalisasi terhadap hasil latih normalisasi
hasil_latih_asli = round(hasil_latih_norm * (max_data - min_data) + min_data);

% membaca target latih asli
target_latih_asli = data_suhu(jumlah_bulan+1:jumlah_bulan*tahun_latih); %tahun 2022

%-----------------------------------------------%
% menghitung nilai MSE
nilai_error = hasil_latih_norm - target_latih_norm;
error_MSE = (1/n)*sum(nilai_error.^2);

%-----------------------------------------------%
% menampilkan grafik hasil pelatihan
figure
plot(hasil_latih_asli, 'bo-', 'LineWidth', 2)
hold on
plot(target_latih_asli, 'ro-', 'LineWidth', 2)
grid on
title(['Grafik Keluaran JST vs Target dengan nilai MSE = ',num2str(error_MSE)])
xlabel('Tahun 2019-2022')
ylabel('Suhu (Celcius)')
legend('keluaran JST', 'Target')
hold off

% menyimpan arsitektur JST hasil pelatihan 
save jaringan jaringan





