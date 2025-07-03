% =========================================================================
% PARTE 1: SIMULAÇÃO DO LEITO POROSO (Seu código original)
% =========================================================================

clc;
clear;

% Parâmetros físicos e geométricos
L = 10;
Dam = 0.0001;
Pa = 130000;
Rg = 8.314;
T = 298;

% Intervalos e passos
yinf = 0.1; ysup = 0.5; py = 0.2;
zinf = 0.1; zsup = 0.5; pz = 0.2;
xinf = 0.2; xsup = 1.0; px = 0.2;

pxs = 0.01; pys = 0.01; pzs = 0.01;

% Criando malha tridimensional
[x, y, z] = meshgrid(xinf:px:xsup, yinf:py:ysup, zinf:pz:zsup);
xslice = xinf:pxs:xsup;
yslice = yinf:pys:ysup;
zslice = zinf:pzs:zsup;

colormap(jet);

% Equação de fração vazia e tortuosidade
w = 40000.*(y + z) - 40000.*y ...
    - 36.114.*(log(max(1000*(y + z) + 0.21, eps))) ... % Removido log de y aqui, conforme sua fórmula
    - 31.42857.*(log(max(9524.93271*(y + z) + 2.00011, eps)) ...
    - log(max(9524.93271*(y + z) - 9524.93271*y + 2.00011, eps)) ...
    + log(max(9524.93271*y + 0.00011, eps)));


% Cálculo da vazão
v = (2.*pi.*(x ./ (pi .* ((z + y).^2 - y.^2))) .* Pa .* Dam) ./ (Rg .* T .* (w + eps));

% Encontrar o ponto ótimo de vazão (máxima vazão)
[max_vazao, idx] = max(v(:));
[x_idx, y_idx, z_idx] = ind2sub(size(v), idx); % Renomeado para não conflitar com as matrizes x,y,z

% Obter os valores das coordenadas do ponto ótimo
x_otimo = x(x_idx, y_idx, z_idx);
y_otimo = y(x_idx, y_idx, z_idx);
z_otimo = z(x_idx, y_idx, z_idx);

% Mostrar as coordenadas e o valor da vazão
disp('Ponto ótimo de vazão encontrado em:');
disp(['x (Volume) = ', num2str(x_otimo)]);
disp(['y (R1) = ', num2str(y_otimo)]);
disp(['z (Espessura) = ', num2str(z_otimo)]);
disp(['Vazão máxima: ', num2str(max_vazao)]);

% Plotagem dos slices 3D
figure(1);
s1 = slice(x, y, z, v, xslice, yslice, zslice);
set(s1, 'facealpha', 0.3);
shading interp;
view(-45, 30);
colorbar;
hold on;
plot3(x_otimo, y_otimo, z_otimo, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'DisplayName', 'Ponto de Vazão Máxima');
xlabel("Volume disponível [m³]");
ylabel("Valor de R1 [m]");
zlabel("Valor da Espessura do leito: R1 + Espessura = R2 [m]");
title("Color Bar: Vazão da espécie A (Na) [m³/s]");
hold off;


% =========================================================================
% PARTE 2: PREPARAÇÃO E EXPORTAÇÃO DOS DADOS PARA CSV (Sua lógica integrada)
% =========================================================================

fprintf('\nIniciando a preparação dos dados para exportação...\n');

% --- Passo 1: "Achatar" os dados 3D para uma matriz 2D ---
% Vamos criar uma matriz onde cada linha é um ponto (x,y,z) e sua vazão (v)
num_pontos = numel(x); % Número total de pontos na malha
dados_para_salvar = zeros(num_pontos, 4); % Pré-aloca a matriz (mais eficiente)

k = 1; % Contador de linha
for i = 1:size(x, 1)
    for j = 1:size(x, 2)
        for l = 1:size(x, 3)
            dados_para_salvar(k, 1) = x(i, j, l);
            dados_para_salvar(k, 2) = y(i, j, l);
            dados_para_salvar(k, 3) = z(i, j, l);
            dados_para_salvar(k, 4) = v(i, j, l);
            k = k + 1;
        end
    end
end

% --- Passo 2: Definir cabeçalho e nome do arquivo ---
cabecalho = {'x_Volume_m3', 'y_R1_m', 'z_Espessura_m', 'Vazao_Na_m3_s'};
nome_arquivo = 'TRFM5_Ex.csv';

% --- Passo 3: Limitar o número de linhas a salvar (opcional) ---
% Para salvar TODOS os dados, comente ou defina um limite muito alto
limite_de_linhas = 1000; % Salva no máximo 1000 linhas
num_linhas_a_salvar = min(limite_de_linhas, size(dados_para_salvar, 1));

% --- Passo 4: Escrever o arquivo CSV ---
fid = fopen(nome_arquivo, 'w');

% Escreve o cabeçalho
fprintf(fid, '%s', cabecalho{1});
for i = 2:length(cabecalho)
    fprintf(fid, ';%s', cabecalho{i});  % Usa ponto e vírgula como separador
end
fprintf(fid, '\n');

% Escreve os dados numéricos
for i = 1:num_linhas_a_salvar
    fprintf(fid, '%.6f', dados_para_salvar(i, 1)); % '%.6f' para salvar com 6 casas decimais
    for j = 2:size(dados_para_salvar, 2)
        fprintf(fid, ';%.6f', dados_para_salvar(i, j));
    end
    fprintf(fid, '\n');
end

fclose(fid);

fprintf('Dados exportados com sucesso para o arquivo "%s".\n', nome_arquivo);
fprintf('%d linhas de dados foram salvas.\n', num_linhas_a_salvar);
