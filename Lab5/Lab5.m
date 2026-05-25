% Лабораторна робота №5
% Тема: Стиснення зображень (Основи алгоритму JPEG, ДКП, Квантування)
clear variables; 
close all; 
clc;

%% Створення папки для збереження результатів
out_dir = 'Results/';
if exist(out_dir, 'dir') == 0
    mkdir(out_dir);
end

%% 1 & 2. Завантаження зображень та перетворення в градації сірого
% Спробуємо завантажити твоє зображення
try
    img_orig = imread('Photo/my_image.jpg');
catch
    % Якщо твого немає, беремо 'autumn.tif' (це кольорове фото з бази MATLAB)
    img_orig = imread('autumn.tif'); 
end

% Перевіряємо, кольорове воно чи вже чорно-біле
if ndims(img_orig) == 3
    img_gray = rgb2gray(img_orig);
    is_color = true;
else
    img_gray = img_orig;
    is_color = false;
end

% Відображаємо оригінал та результат перетворення
figure('Name', 'Пункти 1-2: Вихідні зображення');
if is_color
    subplot(1, 2, 1); imshow(img_orig); title('Оригінал (Кольорове)');
    subplot(1, 2, 2); imshow(img_gray); title('Градації сірого');
    
    % Зберігаємо кольоровий оригінал у папку результатів
    imwrite(img_orig, [out_dir, '1a_original_color.png']);
else
    imshow(img_gray); title('Оригінал (Вже чорно-біле)');
end

% Зберігаємо чорно-білу версію
imwrite(img_gray, [out_dir, '1b_original_gray.png']);

%% 3. Дискретне косинусне перетворення (ДКП / dct2)
% Виконуємо ДКП для чорно-білого зображення
dct_coeff = dct2(img_gray);

% Відображаємо спектр у логарифмічному масштабі для наочності
dct_log_vis = log(abs(dct_coeff));

figure('Name', 'Пункт 3: Спектр ДКП');
imshow(dct_log_vis, []); title('Спектр ДКП (логарифмічний масштаб)');
colormap(gca, jet); colorbar; % Додаємо кольорову шкалу для наочності

imwrite(mat2gray(dct_log_vis), [out_dir, '2_dct_spectrum.png']);

%% 4. Відновлення зображення за його ДКП-спектром (idct2)
% Відновлення без втрат (до квантування)
img_restored_perfect = idct2(dct_coeff);

figure('Name', 'Пункт 4: Ідеальне відновлення');
imshow(img_restored_perfect, [0 255]); title('Відновлене зображення (без втрат)');

imwrite(mat2gray(img_restored_perfect), [out_dir, '3_restored_perfect.png']);

%% 5 & 6. Квантування коефіцієнтів ДКП
% Крок квантування N. Що він більший, то сильніше стиснення і гірша якість
N1 = 20; 
N2 = 80;

% Процедура квантування: ділимо на N, округлюємо, множимо на N
dct_quant_20 = N1 * round(dct_coeff / N1);
dct_quant_80 = N2 * round(dct_coeff / N2);

% Візуалізація квантованих спектрів
dct_q20_vis = log(abs(dct_quant_20));
dct_q80_vis = log(abs(dct_quant_80));

% Замінюємо нескінченності (де log(0)) на 0 для нормального відображення
dct_q20_vis(isinf(dct_q20_vis)) = 0;
dct_q80_vis(isinf(dct_q80_vis)) = 0;

figure('Name', 'Пункти 5-6: Квантовані спектри ДКП');
subplot(1, 2, 1); imshow(dct_q20_vis, []); title(['Спектр (Крок N=', num2str(N1), ')']);
subplot(1, 2, 2); imshow(dct_q80_vis, []); title(['Спектр (Крок N=', num2str(N2), ')']);

imwrite(mat2gray(dct_q20_vis), [out_dir, '4_dct_quantized_N20.png']);
imwrite(mat2gray(dct_q80_vis), [out_dir, '5_dct_quantized_N80.png']);

%% 7. Відновлення зображення за квантованим ДКП-спектром
img_restored_q20 = idct2(dct_quant_20);
img_restored_q80 = idct2(dct_quant_80);

figure('Name', 'Пункт 7: Відновлення після квантування ДКП');
subplot(1, 2, 1); imshow(img_restored_q20, [0 255]); title(['Відновлене (N=', num2str(N1), ')']);
subplot(1, 2, 2); imshow(img_restored_q80, [0 255]); title(['Відновлене (N=', num2str(N2), ')']);

imwrite(mat2gray(img_restored_q20), [out_dir, '6_restored_q20.png']);
imwrite(mat2gray(img_restored_q80), [out_dir, '7_restored_q80.png']);

%% 9. Квантування самого вихідного зображення (просторова область)
% Перевіряємо, що буде, якщо квантувати самі пікселі, а не спектр
N_img = 50;
img_gray_quantized = N_img * round(double(img_gray) / N_img);

figure('Name', 'Пункт 9: Пряме квантування пікселів');
subplot(1, 2, 1); imshow(img_gray); title('Оригінал');
subplot(1, 2, 2); imshow(img_gray_quantized, [0 255]); title(['Квантовані пікселі (N=', num2str(N_img), ')']);

imwrite(mat2gray(img_gray_quantized), [out_dir, '8_spatial_quantization.png']);

disp('Роботу успішно завершено! Всі результати збережено у папку Results/');