% Лабораторна робота №1: Аналіз і обробка зображень
clear variables; 
close all; 
clc;

%% 1. Шляхи до файлів та їх завантаження
% Тут ти можеш вказати шляхи до своїх зображень
path_img1 = 'input/Bunch-Bananas-1.jpg';
path_img2 = 'input/freshpoint-english-cucumber-scaled.jpg';
path_img3 = 'input/pomodoro-1.jpg';

pic1 = imread(path_img1);
pic2 = imread(path_img2);
pic3 = imread(path_img3);

%% 2. Виведення оригіналів на екран
figure; imshow(pic1); title('Вихідне: Банан');
figure; imshow(pic2); title('Вихідне: Огірок');
figure; imshow(pic3); title('Вихідне: Помідора');

%% 3. Отримання технічної інформації
disp('--- Характеристики першого зображення ---');
size(pic1)
whos pic1

disp('--- Характеристики другого зображення ---');
size(pic2)
whos pic2

disp('--- Характеристики третього зображення ---');
size(pic3)
whos pic3

%% 4. Перетворення у градації сірого (півтонові)
% Функція ndims перевіряє кількість вимірів. Якщо 3 — це RGB.
if ndims(pic1) == 3
    gray1 = rgb2gray(pic1);
else
    gray1 = pic1;
end

if ndims(pic2) == 3
    gray2 = rgb2gray(pic2);
else
    gray2 = pic2;
end

if ndims(pic3) == 3
    gray3 = rgb2gray(pic3);
else
    gray3 = pic3;
end

% Відображення результату перетворення
figure; imshow(gray1); title('Півтони: Banana');
figure; imshow(gray2); title('Півтони: Cucumber');
figure; imshow(gray3); title('Півтони: Pomodoro');

%% 5. Побудова гістограм
figure; imhist(gray1); title('Розподіл яскравостей: Banana');
figure; imhist(gray2); title('Розподіл яскравостей: Cucumber');
figure; imhist(gray3); title('Розподіл яскравостей: Pomodoro');

%% 6. Процедура лінійного контрастування
adj1 = imadjust(gray1);
adj2 = imadjust(gray2);
adj3 = imadjust(gray3);

figure; imshow(adj1); title('Після контрастування: Banana');
figure; imshow(adj2); title('Після контрастування: Cucumber');
figure; imshow(adj3); title('Після контрастування: Pomodoro');

%% 7. Отримання негативу
inv1 = imadjust(gray1, [0 1], [1 0]);
inv2 = imadjust(gray2, [0 1], [1 0]);
inv3 = imadjust(gray3, [0 1], [1 0]);

figure; imshow(inv1); title('Інверсія (Негатив): Banana');
figure; imshow(inv2); title('Інверсія (Негатив): Cucumber');
figure; imshow(inv3); title('Інверсія (Негатив): Pomodoro');

%% 8. Збереження оброблених зображень
out_dir = 'output/';

% Перевіряємо наявність папки, якщо немає — створюємо
if exist(out_dir, 'dir') == 0
    mkdir(out_dir);
end

imwrite(adj1, [out_dir, 'Banana_adjusted.png']);
imwrite(inv1, [out_dir, 'Banana_negative.png']);

imwrite(adj2, [out_dir, 'Cucumber_adjusted.png']);
imwrite(inv2, [out_dir, 'Cucumber_negative.png']);

imwrite(adj3, [out_dir, 'Pomodoro_adjusted.png']);
imwrite(inv3, [out_dir, 'Pomodoro_negative.png']);

disp('Обробку завершено. Файли успішно збережено у папку output.');