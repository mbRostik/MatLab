% Лабораторна робота №4
% Тема: Просторові перетворення зображень (ДПФ та частотна фільтрація)
clear variables; 
close all; 
clc;

%% Налаштування директорій
dir_out = 'Results/';

% Створення папки результатів, якщо вона відсутня
if exist(dir_out, 'dir') == 0
    mkdir(dir_out);
end

%% 1. Завантаження та підготовка зображень
% Намагаємося завантажити власні фото, якщо їх немає — використовуємо системні
try
    img1 = imread([dir_in, 'photo1.jpg']);
catch
    img1 = imread('cameraman.tif');
end

try
    img2 = imread([dir_in, 'photo2.jpg']);
catch
    img2 = imread('moon.tif');
end

% Перевірка та конвертація в градації сірого (якщо зображення кольорові)
if ndims(img1) == 3
    img1 = rgb2gray(img1);
end
if ndims(img2) == 3
    img2 = rgb2gray(img2);
end

figure('Name', 'Крок 1: Оригінали');
subplot(1, 2, 1); imshow(img1); title('Оригінал: Зображення 1');
subplot(1, 2, 2); imshow(img2); title('Оригінал: Зображення 2');

% Збереження оригіналів
imwrite(img1, [dir_out, '1_original_img1.png']);
imwrite(img2, [dir_out, '1_original_img2.png']);

%% 2. Виконання ДПФ та отримання амплітудних спектрів
F1 = fft2(double(img1));
F2 = fft2(double(img2));

% Обчислення модуля (амплітуди) та логарифмування для візуалізації
S1_log = log(1 + abs(F1));
S2_log = log(1 + abs(F2));

figure('Name', 'Крок 2: Спектри (без зсуву)');
subplot(1, 2, 1); imshow(S1_log, []); title('Спектр (Зобр. 1)');
subplot(1, 2, 2); imshow(S2_log, []); title('Спектр (Зобр. 2)');

imwrite(mat2gray(S1_log), [dir_out, '2_spectrum_corner_img1.png']);
imwrite(mat2gray(S2_log), [dir_out, '2_spectrum_corner_img2.png']);

%% 3. Центрування спектрів (fftshift)
F1_shifted = fftshift(F1);
F2_shifted = fftshift(F2);

S1_shifted_log = log(1 + abs(F1_shifted));
S2_shifted_log = log(1 + abs(F2_shifted));

figure('Name', 'Крок 3: Центровані спектри');
subplot(1, 2, 1); imshow(S1_shifted_log, []); title('Центрований спектр (Зобр. 1)');
subplot(1, 2, 2); imshow(S2_shifted_log, []); title('Центрований спектр (Зобр. 2)');

imwrite(mat2gray(S1_shifted_log), [dir_out, '3_spectrum_center_img1.png']);
imwrite(mat2gray(S2_shifted_log), [dir_out, '3_spectrum_center_img2.png']);

%% 4. Відновлення зображень (ОДПФ)
% 4.1. Зі звичайного спектра
img1_recovered = abs(ifft2(F1));
img2_recovered = abs(ifft2(F2));

figure('Name', 'Крок 4.1: Відновлення (ОДПФ без зсуву)');
subplot(1, 2, 1); imshow(img1_recovered, []); title('Відновлене Зобр. 1');
subplot(1, 2, 2); imshow(img2_recovered, []); title('Відновлене Зобр. 2');

% 4.2. Із центрованого спектра (повернення через ifftshift)
F1_unshifted = ifftshift(F1_shifted);
img1_recovered_from_shift = abs(ifft2(F1_unshifted));

figure('Name', 'Крок 4.2: Відновлення (ifftshift -> ifft2)');
imshow(img1_recovered_from_shift, []); title('Відновлення після зсуву (Зобр. 1)');

imwrite(mat2gray(img1_recovered), [dir_out, '4_restored_img1.png']);
imwrite(mat2gray(img1_recovered_from_shift), [dir_out, '4_restored_from_shift_img1.png']);

%% 5. Ручна побудова Гаусівського НЧ-фільтра у частотній області
[M1, N1] = size(img1);
[M2, N2] = size(img2);

% Створення просторової сітки для першого фото
[U1, V1] = meshgrid((-floor(N1/2)):(ceil(N1/2)-1), (-floor(M1/2)):(ceil(M1/2)-1));
Dist1 = sqrt(U1.^2 + V1.^2);

% Створення просторової сітки для другого фото
[U2, V2] = meshgrid((-floor(N2/2)):(ceil(N2/2)-1), (-floor(M2/2)):(ceil(M2/2)-1));
Dist2 = sqrt(U2.^2 + V2.^2);

% Параметри зрізу частот (радіус)
D0_narrow = 20; % Вузькосмуговий (сильне розмиття)
D0_wide = 50;   % Широкосмуговий (слабке розмиття)

% Формування масок фільтра
H1_narrow = exp(-(Dist1.^2) / (2 * D0_narrow^2));
H1_wide   = exp(-(Dist1.^2) / (2 * D0_wide^2));

H2_narrow = exp(-(Dist2.^2) / (2 * D0_narrow^2));
H2_wide   = exp(-(Dist2.^2) / (2 * D0_wide^2));

%% 6. Візуалізація частотної характеристики фільтрів
figure('Name', 'Крок 6: АЧХ фільтрів (Зобр. 1)');
subplot(1, 2, 1); imshow(H1_narrow, []); title('АЧХ (D0 = 20)');
subplot(1, 2, 2); imshow(H1_wide, []); title('АЧХ (D0 = 50)');

imwrite(mat2gray(H1_narrow), [dir_out, '5_filter_response_D20.png']);
imwrite(mat2gray(H1_wide), [dir_out, '5_filter_response_D50.png']);

%% 7. Частотна фільтрація (множення спектрів)
% Множимо центровані спектри на маски фільтрів
G1_narrow = F1_shifted .* H1_narrow;
G1_wide   = F1_shifted .* H1_wide;

G2_narrow = F2_shifted .* H2_narrow;
G2_wide   = F2_shifted .* H2_wide;

% Зворотне перетворення (ОДПФ) для отримання результату
filt_freq_img1_narrow = real(ifft2(ifftshift(G1_narrow)));
filt_freq_img1_wide   = real(ifft2(ifftshift(G1_wide)));

filt_freq_img2_narrow = real(ifft2(ifftshift(G2_narrow)));
filt_freq_img2_wide   = real(ifft2(ifftshift(G2_wide)));

figure('Name', 'Крок 7: Результат частотної фільтрації (Зобр. 1)');
subplot(1, 2, 1); imshow(mat2gray(filt_freq_img1_narrow)); title('Частотний ФНЧ (D0=20)');
subplot(1, 2, 2); imshow(mat2gray(filt_freq_img1_wide)); title('Частотний ФНЧ (D0=50)');

imwrite(mat2gray(filt_freq_img1_narrow), [dir_out, '6_freq_filtered_img1_D20.png']);
imwrite(mat2gray(filt_freq_img1_wide), [dir_out, '6_freq_filtered_img1_D50.png']);

%% 8. Спектри після фільтрації
S1_narrow_log = log(1 + abs(G1_narrow));
S1_wide_log   = log(1 + abs(G1_wide));

figure('Name', 'Крок 8: Спектри після обрізки частот');
subplot(1, 2, 1); imshow(mat2gray(S1_narrow_log)); title('Спектр після ФНЧ (D0=20)');
subplot(1, 2, 2); imshow(mat2gray(S1_wide_log)); title('Спектр після ФНЧ (D0=50)');

imwrite(mat2gray(S1_narrow_log), [dir_out, '7_filtered_spectrum_D20.png']);
imwrite(mat2gray(S1_wide_log), [dir_out, '7_filtered_spectrum_D50.png']);

%% 9. Просторова фільтрація (через fspecial та imfilter)
% Створюємо маски для просторової фільтрації (аналоги sigma=1 та sigma=5)
h_spatial_narrow = fspecial('gaussian', [15 15], 1);
h_spatial_wide   = fspecial('gaussian', [15 15], 5);

filt_spatial_img1_narrow = imfilter(double(img1), h_spatial_narrow, 'replicate');
filt_spatial_img1_wide   = imfilter(double(img1), h_spatial_wide, 'replicate');

figure('Name', 'Крок 9: Просторова фільтрація (Згортка)');
subplot(1, 2, 1); imshow(mat2gray(filt_spatial_img1_narrow)); title('Просторова згортка (sigma=1)');
subplot(1, 2, 2); imshow(mat2gray(filt_spatial_img1_wide)); title('Просторова згортка (sigma=5)');

imwrite(mat2gray(filt_spatial_img1_narrow), [dir_out, '8_spatial_filtered_sigma1.png']);
imwrite(mat2gray(filt_spatial_img1_wide), [dir_out, '8_spatial_filtered_sigma5.png']);

disp('Скрипт успішно завершив роботу. Усі результати збережено у папку Results!');