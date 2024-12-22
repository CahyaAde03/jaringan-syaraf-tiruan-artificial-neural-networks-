clc; clear; close all; warning off all;

% membaca data excel 
data_RH = xlsread('data_iklim.xlsx',2,'E16:P20');
% melakukan transpose data
data_RH =  data_RH';
% mengubah matriks menjadi bentuk vektor
data_RH = data_RH(:);
% mencari nilai min dan max data
min_data_RH = min(data_RH);
max_data_RH = max(data_RH);

% normalisasi data
[m,n] = size(data_RH);
dataRH_norm = zeros(m,n);
for x = 1:m
    for y = 1:n
        dataRH_norm(x,y) = (data_RH(x,y)- min_data_RH)/(max_data_RH - min_data_RH);
    end
end

%---------------------------------------------------------%
% menyiapkan data latih hasil normalisasi
tahun_latih = 4; % tahun 2019 s.d 2022
jumlah_bulan = 12; 
data_latihRH_norm = zeros(jumlah_bulan * tahun_latih - jumlah_bulan, jumlah_bulan);
% menyusun data latih normalisasi
for m = 1:jumlah_bulan * tahun_latih - jumlah_bulan
    for n = 1:jumlah_bulan
        data_latihRH_norm(m,n) = dataRH_norm(m+n-1);
    end
end

% menyiapkan target latih normalisasi
target_latihRH_norm = zeros(jumlah_bulan * tahun_latih - jumlah_bulan, 1);
for m = 1:jumlah_bulan * tahun_latih - jumlah_bulan
    target_latihRH_norm(m) = dataRH_norm(jumlah_bulan + m); % data 2022
end

% melakukan transpose data latih dan target latih normalisasi
data_latihRH_norm = data_latihRH_norm';
target_latihRH_norm = target_latihRH_norm';
%----------------------------------------------%

% menetapkan parameter Jaringan Syaraf Tiruan
jumlah_neuron1 = 100; %dapat di variasikan dengan angka lainnya
fungsi_aktivasi1 = 'logsig'; %sigmoid biner
fungsi_aktivasi2 = 'logsig';
fungsi_pelatihan = 'traingd';
%----------------------------------------------%

% membangun arsitektur JST dengan backpropagation (BP)
rng('default')
jaringan = newff(minmax(data_latihRH_norm),[jumlah_neuron1 1], ...
    {fungsi_aktivasi1, fungsi_aktivasi2}, fungsi_pelatihan); 

% melakukan pelatihan jaringan 
jaringan = train(jaringan, data_latihRH_norm, target_latihRH_norm);

% membaca hasil pelatihan
hasil_latihRH_norm = sim(jaringan,data_latihRH_norm);

% normalisasi de-normalisasi terhadap hasil latih normalisasi
hasil_latihRH_asli = round(hasil_latihRH_norm * (max_data_RH - min_data_RH) + min_data_RH);

% membaca target latih asli
target_latihRH_asli = data_RH(jumlah_bulan+1:jumlah_bulan*tahun_latih); %tahun 2022

%-----------------------------------------------%
% menghitung nilai MSE
nilai_error = hasil_latihRH_norm - target_latihRH_norm;
error_MSE = (1/n)*sum(nilai_error.^2);

%-----------------------------------------------%
% menampilkan grafik hasil pelatihan
figure
plot(hasil_latihRH_asli, 'mo-', 'LineWidth', 2)
hold on
plot(target_latihRH_asli, 'co-', 'LineWidth', 2)
grid on
title(['Grafik Keluaran JST vs Target dengan nilai MSE = ',num2str(error_MSE)])
xlabel('Tahun 2019-2022')
ylabel('Kelembaban (%)')
legend('keluaran JST', 'Target')
hold off

% menyimpan arsitektur JST hasil pelatihan 
save jaringan jaringan





