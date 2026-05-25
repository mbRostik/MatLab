% Лабораторна робота №2
% Тема: Фільтрація й придушення шумів
clear variables; 
close all; 
clc;

%% 1. Налаштування шляхів та підготовка директорій
path_in = 'Photo/';
path_out = 'Results/';

% Створюємо папку для збереження результатів, якщо її ще немає
if exist(path_out, 'dir') == 0
    mkdir(path_out);
end

%% 2. Завантаження вихідних зображень
img_letter = imread([path_in, 'letter.jpg']);
img_three = imread([path_in, 'three.jpg']);

figure('Name', 'Оригінали');
subplot(1, 2, 1); imshow(img_letter); title('Оригінал: letter');
subplot(1, 2, 2); imshow(img_three); title('Оригінал: three');

%% 3. Генерування шумів
% 3.1 Гаусівський білий шум
noise_gauss_letter = imnoise(img_letter, 'gaussian', 0, 0.01);
noise_gauss_three = imnoise(img_three, 'gaussian', 0, 0.01);

figure('Name', 'Гаусівський шум');
subplot(1, 2, 1); imshow(noise_gauss_letter); title('Gaussian Noise: letter');
subplot(1, 2, 2); imshow(noise_gauss_three); title('Gaussian Noise: Three');

imwrite(noise_gauss_letter, [path_out, 'letter_gaussian.png']);
imwrite(noise_gauss_three, [path_out, 'three_gaussian.jpg']);

% 3.2 Імпульсний шум (Сіль і перець)
noise_sp_letter = imnoise(img_letter, 'salt & pepper', 0.05);
noise_sp_three = imnoise(img_three, 'salt & pepper', 0.05);

figure('Name', 'Шум Salt & Pepper');
subplot(1, 2, 1); imshow(noise_sp_letter); title('S&P Noise: letter');
subplot(1, 2, 2); imshow(noise_sp_three); title('S&P Noise: three');

imwrite(noise_sp_letter, [path_out, 'letter_sp.png']);
imwrite(noise_sp_three, [path_out, 'three_sp.jpg']);

%% 4. Лінійна низькочастотна фільтрація (згладжування)
% Використовуємо маску 3х3 для усереднення
mask_lp = ones(3, 3) / 9;

lp_letter = imfilter(noise_gauss_letter, mask_lp);
lp_three = imfilter(noise_gauss_three, mask_lp);

figure('Name', 'Низькочастотна фільтрація');
subplot(1, 2, 1); imshow(lp_letter); title('Low-pass: letter');
subplot(1, 2, 2); imshow(lp_three); title('Low-pass: three');

imwrite(lp_letter, [path_out, 'letter_lowpass.png']);
imwrite(lp_three, [path_out, 'three_lowpass.jpg']);

%% 5. Лінійна високочастотна фільтрація (підкреслення контурів)
% Маска для підкреслення перепадів яскравості
mask_hp = [0 -1 0; -1 5 -1; 0 -1 0];

hp_letter = imfilter(img_letter, mask_hp);
hp_three = imfilter(img_three, mask_hp);

figure('Name', 'Високочастотна фільтрація');
subplot(1, 2, 1); imshow(hp_letter); title('High-pass: letter');
subplot(1, 2, 2); imshow(hp_three); title('High-pass: three');

imwrite(hp_letter, [path_out, 'letter_highpass.png']);
imwrite(hp_three, [path_out, 'three_highpass.jpg']);

%% 6. Адаптивна вінерівська фільтрація
% Wiener працює з 2D масивами (градації сірого), тому перевіряємо формат
if ndims(noise_gauss_letter) == 3
    gray_gauss_letter = rgb2gray(noise_gauss_letter);
else
    gray_gauss_letter = noise_gauss_letter;
end

if ndims(noise_gauss_three) == 3
    gray_gauss_three = rgb2gray(noise_gauss_three);
else
    gray_gauss_three = noise_gauss_three;
end

wiener_letter = wiener2(gray_gauss_letter, [5 5]);
wiener_three = wiener2(gray_gauss_three, [5 5]);

figure('Name', 'Фільтр Вінера');
subplot(1, 2, 1); imshow(wiener_letter); title('Wiener: letter');
subplot(1, 2, 2); imshow(wiener_three); title('Wiener: three');

imwrite(wiener_letter, [path_out, 'letter_wiener.png']);
imwrite(wiener_three, [path_out, 'three_wiener.jpg']);

%% 7. Медіанна фільтрація (видалення імпульсних перешкод)
% Медіанний фільтр також вимагає 2D формату
if ndims(noise_sp_letter) == 3
    gray_sp_letter = rgb2gray(noise_sp_letter);
else
    gray_sp_letter = noise_sp_letter;
end

if ndims(noise_sp_three) == 3
    gray_sp_three = rgb2gray(noise_sp_three);
else
    gray_sp_three = noise_sp_three;
end

med_letter = medfilt2(gray_sp_letter);
med_three = medfilt2(gray_sp_three);

figure('Name', 'Медіанний фільтр');
subplot(1, 2, 1); imshow(med_letter); title('Median: letter');
subplot(1, 2, 2); imshow(med_three); title('Median: three');

imwrite(med_letter, [path_out, 'letter_median.png']);
imwrite(med_three, [path_out, 'three_median.jpg']);

%% 8. Використання спеціального фільтра (unsharp)
mask_unsharp = fspecial('unsharp');

unsharp_letter = imfilter(img_letter, mask_unsharp);
unsharp_three = imfilter(img_three, mask_unsharp);

figure('Name', 'Фільтр Unsharp (fspecial)');
subplot(1, 2, 1); imshow(unsharp_letter); title('Unsharp: letter');
subplot(1, 2, 2); imshow(unsharp_three); title('Unsharp: three');

imwrite(unsharp_letter, [path_out, 'letter_unsharp.png']);
imwrite(unsharp_three, [path_out, 'three_unsharp.jpg']);

disp('Всі операції успішно виконано. Файли збережено у папку results/');