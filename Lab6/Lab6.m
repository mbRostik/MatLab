% Лабораторна робота №6
% Тема: Блокова обробка. Реалізація алгоритму JPEG
clear variables; 
close all; 
clc;

%% Налаштування папки для збереження
out_dir = 'Results/';
if exist(out_dir, 'dir') == 0
    mkdir(out_dir);
end

%% 1 & 2. Завантаження та підготовка зображення
% Завантажуємо кольорове зображення
try
    img_color = imread('my_photo.jpg'); 
catch
    img_color = imread('peppers.png'); % Резервне кольорове з MATLAB
end

% Перевірка на колір і перетворення в градації сірого
if ndims(img_color) == 3
    img_gray = rgb2gray(img_color);
else
    img_gray = img_color;
end

% Виводимо кольорове та чорно-біле поруч
figure('Name', 'Крок 1-2: Вихідні зображення');
subplot(1, 2, 1); imshow(img_color); title('Оригінал (Кольорове)');
subplot(1, 2, 2); imshow(img_gray); title('Оригінал (Чорно-біле)');

% Зберігаємо обидва оригінали
imwrite(img_color, [out_dir, '01_original_color.png']);
imwrite(img_gray, [out_dir, '02_original_gray.png']);

%% 3 & 4. Поблочне ДКП (Блоки 8х8)
% Переводимо в double (0..1) для точності
img_double = im2double(img_gray);
T = dctmtx(8);

% Функція прямого ДКП для одного блоку
dct_func = @(block_struct) T * block_struct.data * T';
dct_blocks = blockproc(img_double, [8 8], dct_func);

% Відображення спектра поблочного ДКП
dct_vis = log(abs(dct_blocks) + 1e-5);
figure('Name', 'Крок 4: Поблочне ДКП');
imshow(dct_vis, []); title('Спектр ДКП (блоки 8х8)');
colormap(gca, jet); colorbar;

imwrite(mat2gray(dct_vis), [out_dir, '03_block_dct_spectrum.png']);

%% 5. Відновлення зображення за ДКП-спектром (без квантування)
idct_func = @(block_struct) T' * block_struct.data * T;
img_restored_clean = blockproc(dct_blocks, [8 8], idct_func);

figure('Name', 'Крок 5: Відновлення без втрат');
imshow(img_restored_clean); title('Відновлене зображення (Ідеальне)');

imwrite(mat2gray(img_restored_clean), [out_dir, '04_restored_clean.png']);

%% 6 & 7. Квантування коефіцієнтів ДКП (Рівномірне та Матрицею JPEG)
% Беремо три різні кроки для рівномірного квантування, щоб було з чим порівняти
N1 = 0.05; % Слабке стиснення
N2 = 0.15; % Середнє стиснення
N3 = 0.30; % Сильне стиснення (будуть сильні квадрати)

% Рівномірне квантування
dct_quant_1 = N1 * round(dct_blocks / N1);
dct_quant_2 = N2 * round(dct_blocks / N2);
dct_quant_3 = N3 * round(dct_blocks / N3);

% Квантування матрицею JPEG
Q_matrix = [16 11 10 16 24 40 51 61;
            12 12 14 19 26 58 60 55;
            14 13 16 24 40 57 69 56;
            14 17 22 29 51 87 80 62;
            18 22 37 56 68 109 103 77;
            24 35 55 64 81 104 113 92;
            49 64 78 87 103 121 120 101;
            72 92 95 98 112 100 103 99];

% Масштабуємо для матриці JPEG (бо вона розрахована на 0-255)
dct_scaled = dct_blocks * 255;
quant_matrix_func = @(block_struct) Q_matrix .* round(block_struct.data ./ Q_matrix);
dct_quant_jpeg = blockproc(dct_scaled, [8 8], quant_matrix_func) / 255;

%% Візуалізація та збереження квантованих спектрів
vis_q1 = log(abs(dct_quant_1) + 1e-5);
vis_q2 = log(abs(dct_quant_2) + 1e-5);
vis_q3 = log(abs(dct_quant_3) + 1e-5);
vis_qjpeg = log(abs(dct_quant_jpeg) + 1e-5);

figure('Name', 'Спектри після квантування');
subplot(2, 2, 1); imshow(vis_q1, []); title(['Спектр (N=', num2str(N1), ')']);
subplot(2, 2, 2); imshow(vis_q2, []); title(['Спектр (N=', num2str(N2), ')']);
subplot(2, 2, 3); imshow(vis_q3, []); title(['Спектр (N=', num2str(N3), ')']);
subplot(2, 2, 4); imshow(vis_qjpeg, []); title('Спектр (JPEG Matrix)');

imwrite(mat2gray(vis_q1), [out_dir, '05_spectrum_quant_N05.png']);
imwrite(mat2gray(vis_q2), [out_dir, '06_spectrum_quant_N15.png']);
imwrite(mat2gray(vis_q3), [out_dir, '07_spectrum_quant_N30.png']);
imwrite(mat2gray(vis_qjpeg), [out_dir, '08_spectrum_quant_jpeg.png']);

%% 8. Відновлення зображень після квантування
img_restored_1 = blockproc(dct_quant_1, [8 8], idct_func);
img_restored_2 = blockproc(dct_quant_2, [8 8], idct_func);
img_restored_3 = blockproc(dct_quant_3, [8 8], idct_func);
img_restored_jpeg = blockproc(dct_quant_jpeg, [8 8], idct_func);

figure('Name', 'Крок 8: Відновлення після квантування');
subplot(2, 2, 1); imshow(img_restored_1, []); title(['Відновлене (N=', num2str(N1), ')']);
subplot(2, 2, 2); imshow(img_restored_2, []); title(['Відновлене (N=', num2str(N2), ')']);
subplot(2, 2, 3); imshow(img_restored_3, []); title(['Відновлене (N=', num2str(N3), ')']);
subplot(2, 2, 4); imshow(img_restored_jpeg, []); title('Матриця JPEG');

% Зберігаємо фінальні відновлені зображення
imwrite(mat2gray(img_restored_1), [out_dir, '09_restored_uniform_05.png']);
imwrite(mat2gray(img_restored_2), [out_dir, '10_restored_uniform_15.png']);
imwrite(mat2gray(img_restored_3), [out_dir, '11_restored_uniform_30.png']);
imwrite(mat2gray(img_restored_jpeg), [out_dir, '12_restored_jpeg_matrix.png']);

disp('Алгоритм успішно завершено! Всі 12 файлів збережено у папку Results/');