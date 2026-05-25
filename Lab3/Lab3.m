% Лабораторна робота №3
% Тема: Відновлення зображень
clear variables; 
close all; 
clc;

%% Налаштування робочих директорій (згідно зі структурою папок)
dir_out = 'Results/';

% Перевіряємо, чи існує папка для результатів, якщо ні — створюємо
if exist(dir_out, 'dir') == 0
    mkdir(dir_out);
end

%% 1. Завантаження та виведення початкового зображення
% Якщо файлу немає в папці Photo, завантажиться стандартний з бібліотеки
try
    img_orig = imread([dir_in, 'Cameraman.jpg']);
catch
    img_orig = imread('cameraman.tif'); 
end

figure('Name', 'Крок 1: Оригінал');
imshow(img_orig); 
title('Вихідне зображення об''єкта');

%% 2. Моделювання перекручення (Змазання / Motion Blur)
% Задаємо параметри руху камери
shift_len = 21;    % Сила зсуву
shift_angle = 0;   % Кут зсуву (горизонтальний)

% Формуємо імпульсну характеристику (PSF)
psf_filter1 = fspecial('motion', shift_len, shift_angle);

% Застосовуємо фільтр до зображення (імітація розмиття)
img_blurred1 = imfilter(img_orig, psf_filter1, 'conv', 'circular');

figure('Name', 'Крок 2: Розмиття внаслідок руху');
imshow(img_blurred1); 
title('Змазане зображення (Без шуму)');

imwrite(img_blurred1, [dir_out, 'blur_step1.png']);

%% 3. Відновлення зображення за відсутності шуму
% Використовуємо деконволюцію (фільтр Вінера) з нульовим шумом (SNR = 0)
img_restored_clean = deconvwnr(img_blurred1, psf_filter1, 0);

figure('Name', 'Крок 3: Відновлення ідеального розмиття');
imshow(img_restored_clean); 
title('Відновлене зображення (Ідеальні умови)');

imwrite(img_restored_clean, [dir_out, 'restored_clean.png']);

%% 4. Моделювання розмиття з додаванням шуму
% Реальні системи завжди мають шум. Додаємо гаусівський шум.
img_noisy_blur = imnoise(img_blurred1, 'gaussian', 0, 0.001);

figure('Name', 'Крок 4: Розмиття + Шум');
imshow(img_noisy_blur); 
title('Змазане зображення із шумом');

imwrite(img_noisy_blur, [dir_out, 'blur_noisy.png']);

%% 5. Відновлення зашумленого зображення
% Для фільтра Вінера потрібно вказати відношення сигнал/шум (SNR)
estimated_snr = 0.01;

img_restored_noisy = deconvwnr(img_noisy_blur, psf_filter1, estimated_snr);

figure('Name', 'Крок 5: Відновлення реального сигналу');
imshow(img_restored_noisy); 
title('Відновлене зображення (З урахуванням шуму)');

imwrite(img_restored_noisy, [dir_out, 'restored_noisy.png']);

%% 6. Експеримент із іншими параметрами перекручення
% Змінюємо довжину та кут розмиття
shift_len2 = 35;
shift_angle2 = 45; 

psf_filter2 = fspecial('motion', shift_len2, shift_angle2);
img_blurred2 = imfilter(img_orig, psf_filter2, 'conv', 'circular');

figure('Name', 'Крок 6: Альтернативне перекручення');
subplot(1, 2, 1); 
imshow(img_blurred2); 
title('Змазане (Кут 45)');

% Відновлюємо другий варіант
img_restored2 = deconvwnr(img_blurred2, psf_filter2, 0);

subplot(1, 2, 2); 
imshow(img_restored2); 
title('Відновлене (Кут 45)');

imwrite(img_blurred2, [dir_out, 'blur_angle45.png']);
imwrite(img_restored2, [dir_out, 'restored_angle45.png']);

disp('Роботу скрипта завершено. Усі файли збережено у папку Results!');