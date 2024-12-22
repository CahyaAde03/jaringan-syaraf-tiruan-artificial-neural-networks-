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

% menyiapkan data uji normalisasi
tahun_latih = 4; % tahun 2019 s.d 2022
tahun_uji = 2; % tahun 2022 s.d 2023
jumlah_bulan = 12;
data_ujiRH_norm =  zeros(jumlah_bulan * tahun_uji - jumlah_bulan, jumlah_bulan);
% menyusun data uji normalisasi
for m = 1:jumlah_bulan * tahun_uji - jumlah_bulan
    for n = 1:jumlah_bulan
        data_ujiRH_norm(m,n) = dataRH_norm(m+n-1+(tahun_latih-1)*jumlah_bulan); % tahun 2022 -2023
    end
end

% menyiapkan target uji normalisasi
target_ujiRH_norm = zeros(jumlah_bulan * tahun_uji - jumlah_bulan, 1);
for m = 1:jumlah_bulan * tahun_uji - jumlah_bulan
    target_ujiRH_norm(m) = dataRH_norm(jumlah_bulan+m+(tahun_latih -1)*jumlah_bulan);
end

% melakukan transpose terhadap data uji dan target uji normalisasi
data_ujiRH_norm = data_ujiRH_norm';
target_ujiRH_norm = target_ujiRH_norm';

% memanggil arsitektur JST hasil pelatihan
load jaringan

% membaca hasil pengujian
hasil_ujiRH_norm = sim(jaringan, data_ujiRH_norm);

% melakukan de-normalisasi terhadap hasil uji normalisasi
hasil_ujiRH_asli = round(hasil_ujiRH_norm*(max_data_RH - min_data_RH)+min_data_RH);

% membaca target uji asli
target_ujiRH_asli = data_RH(jumlah_bulan + 1 + (tahun_latih-1)*jumlah_bulan:...
    jumlah_bulan*tahun_uji + (tahun_latih-1)*jumlah_bulan);

% menghitung nilai error MSE
nilai_error = hasil_ujiRH_norm-target_ujiRH_norm;
error_MSE = (1/n)*sum(nilai_error.^2);

% menampilkan grafik hasil pengujian
figure
plot(hasil_ujiRH_asli, 'ro-','LineWidth', 2)
hold on
plot(target_ujiRH_asli, 'ko-','LineWidth', 2)
grid on
title(['Grafik Keluaran JST vs Target dengan nilai MSE =',num2str(error_MSE)])
xlabel('Tahun 2023')
ylabel('Kelembaban (%)')
legend('keluaran JST', 'Target')
hold off



% menyiapkan data prediksi normalisasi
data_prediksiRH_norm = hasil_ujiRH_norm(end-11:end);
% melakukan transpose terhadap data prediksi normalisasi
data_prediksiRH_norm = data_prediksiRH_norm';

% melakukan prediksi
hasil_prediksiRH_norm = sim(jaringan, data_prediksiRH_norm);

for n = 1:11
    data_prediksiRH_norm = [data_prediksiRH_norm(end-10:end); hasil_prediksiRH_norm(end)];
    hasil_prediksiRH_norm = [hasil_prediksiRH_norm, sim(jaringan, data_prediksiRH_norm)];
end

% melakukan de-normalisasi hasil prediksi normalisasi
hasil_prediksiRH_asli = round(hasil_prediksiRH_norm * (max_data_RH-min_data_RH) + min_data_RH);



% menampilkan grafik hasil prediksi
figure
plot(hasil_prediksiRH_asli, 'bo-','LineWidth', 2)
grid on
title(['Grafik Keluaran JST'])
xlabel('Tahun 2024')
ylabel('Kelembaban (%)')
legend('keluaran JST')



