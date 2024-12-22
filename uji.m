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

% menyiapkan data uji normalisasi
tahun_latih = 4; % tahun 2019 s.d 2022
tahun_uji = 2; % tahun 2022 s.d 2023
jumlah_bulan = 12;
data_uji_norm =  zeros(jumlah_bulan * tahun_uji - jumlah_bulan, jumlah_bulan);
% menyusun data uji normalisasi
for m = 1:jumlah_bulan * tahun_uji - jumlah_bulan
    for n = 1:jumlah_bulan
        data_uji_norm(m,n) = data_norm(m+n-1+(tahun_latih-1)*jumlah_bulan); % tahun 2022 -2023
    end
end

% menyiapkan target uji normalisasi
target_uji_norm = zeros(jumlah_bulan * tahun_uji - jumlah_bulan, 1);
for m = 1:jumlah_bulan * tahun_uji - jumlah_bulan
    target_uji_norm(m) = data_norm(jumlah_bulan+m+(tahun_latih -1)*jumlah_bulan);
end

% melakukan transpose terhadap data uji dan target uji normalisasi
data_uji_norm = data_uji_norm';
target_uji_norm = target_uji_norm';

% memanggil arsitektur JST hasil pelatihan
load jaringan

% membaca hasil pengujian
hasil_uji_norm = sim(jaringan, data_uji_norm);

% melakukan de-normalisasi terhadap hasil uji normalisasi
hasil_uji_asli = round(hasil_uji_norm*(max_data - min_data)+min_data);

% membaca target uji asli
target_uji_asli = data_suhu(jumlah_bulan + 1 + (tahun_latih-1)*jumlah_bulan:...
    jumlah_bulan*tahun_uji + (tahun_latih-1)*jumlah_bulan);

% menghitung nilai error MSE
nilai_error = hasil_uji_norm-target_uji_norm;
error_MSE = (1/n)*sum(nilai_error.^2);

% menampilkan grafik hasil pengujian
figure
plot(hasil_uji_asli, 'ro-','LineWidth', 2)
hold on
plot(target_uji_asli, 'go-','LineWidth', 2)
grid on
title(['Grafik Keluaran JST vs Target dengan nilai MSE =',num2str(error_MSE)])
xlabel('Tahun 2023')
ylabel('Suhu (Celcius)')
legend('keluaran JST', 'Target')
hold off



% menyiapkan data prediksi normalisasi
data_prediksi_norm = hasil_uji_norm(end-11:end);
% melakukan transpose terhadap data prediksi normalisasi
data_prediksi_norm = data_prediksi_norm';

% melakukan prediksi
hasil_prediksi_norm = sim(jaringan, data_prediksi_norm);

for n = 1:11
    data_prediksi_norm = [data_prediksi_norm(end-10:end); hasil_prediksi_norm(end)];
    hasil_prediksi_norm = [hasil_prediksi_norm, sim(jaringan, data_prediksi_norm)];
end

% melakukan de-normalisasi hasil prediksi normalisasi
hasil_prediksi_asli = round(hasil_prediksi_norm * (max_data-min_data) + min_data);



% menampilkan grafik hasil prediksi
figure
plot(hasil_prediksi_asli, 'co-','LineWidth', 2)
grid on
title(['Grafik Keluaran JST'])
xlabel('Tahun 2024')
ylabel('Suhu (Celcius)')
legend('keluaran JST')



