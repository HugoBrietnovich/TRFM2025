% =========================================================================
% PARTE 1: SIMULAÇÃO DA MEMBRANA (Seu código original)
% =========================================================================

clc;
clear;
close all;

fprintf('Iniciando simulação da membrana...\n\n');

% Parâmetros do problema
F = 0.2;         % Fluxo volumétrico (assumido, [m/s] ou similar)
Cao = 1;         % Concentração inicial (mol/m³) [cite: 700]
RIn = 0.1;       % Raio interno da membrana (m) [cite: 719]
Rout = 0.2;      % Raio externo da membrana (m) [cite: 720]
delta1 = 8.314;  % Constante (representando CT*XAs*gamma1) [cite: 707, 718]

% Intervalos para as variáveis independentes
Dam_range = linspace(0.00001, 0.00002, 40); % Intervalo para Dam
Ca_range = linspace(0.5, 0.8, 40);        % Intervalo para Ca (concentração de saída)

% Função L(Dam, Ca) baseada na equação da aula
L = @(Dam, Ca) (F * (Cao - Ca) .* log(Rout / RIn)) ./ (2 * pi * Dam * Cao * delta1);

% Criando a malha de pontos para cálculo e plotagem
[X_dam, Y_ca] = meshgrid(Dam_range, Ca_range); % Matrizes 2D para Dam e Ca
Z_l = L(X_dam, Y_ca);                      % Matriz 2D com os resultados de L

% Encontrando o ponto mínimo e máximo diretamente das matrizes (mais eficiente)
[min_value, min_idx] = min(Z_l(:));
[min_row, min_col] = ind2sub(size(Z_l), min_idx);
min_Dam = X_dam(min_row, min_col);
min_Ca = Y_ca(min_row, min_col);

[max_value, max_idx] = max(Z_l(:));
[max_row, max_col] = ind2sub(size(Z_l), max_idx);
max_Dam = X_dam(max_row, max_col);
max_Ca = Y_ca(max_row, max_col);

% Exibindo os resultados
disp(['Valor mínimo do comprimento (L) = ', num2str(min_value), ' m']);
disp(['Ocorre para Dam = ', num2str(min_Dam), ' m²/s e Ca = ', num2str(min_Ca), ' mol/m³']);
disp('--------------------------------------------------------------------------------');
disp(['Valor máximo do comprimento (L) = ', num2str(max_value), ' m']);
disp(['Ocorre para Dam = ', num2str(max_Dam), ' m²/s e Ca = ', num2str(max_Ca), ' mol/m³']);

% Plotando a função L(Dam, Ca)
figure(1);
set(gcf, 'Position', [100, 100, 800, 600]);
surf(X_dam, Y_ca, Z_l);
colormap jet;
xlabel('Coeficiente de Difusão (Dam) [m²/s]');
ylabel('Concentração de Saída (Ca) [mol/m³]');
zlabel('Comprimento da Membrana (L) [m]');
title('Superfície de Resposta L(Dam, Ca)');
colorbar;
hold on;
% Marcando os pontos de mínimo e máximo no gráfico 3D
plot3(min_Dam, min_Ca, min_value, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 10, 'DisplayName', 'Mínimo');
plot3(max_Dam, max_Ca, max_value, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 10, 'DisplayName', 'Máximo');
legend('show');
hold off;


% =========================================================================
% PARTE 2: PREPARAÇÃO E EXPORTAÇÃO DOS DADOS PARA CSV
% =========================================================================

fprintf('\nIniciando a preparação dos dados para exportação...\n');

% --- Passo 1: "Achatar" os dados 2D para uma matriz de tabela ---
num_pontos = numel(X_dam); % Número total de pontos na malha
dados_para_salvar = zeros(num_pontos, 3); % Matriz com 3 colunas: Dam, Ca, L

% Preenchendo a matriz a partir das matrizes da malha
dados_para_salvar(:, 1) = X_dam(:); % Achatando a matriz de Dam para uma coluna
dados_para_salvar(:, 2) = Y_ca(:);  % Achatando a matriz de Ca para uma coluna
dados_para_salvar(:, 3) = Z_l(:);   % Achatando a matriz de L para uma coluna

% --- Passo 2: Definir cabeçalho e nome do arquivo ---
cabecalho = {'Dam_m2_s', 'Ca_mol_m3', 'L_membrana_m'};
nome_arquivo = 'TRFM6_Ex.csv';

% --- Passo 3: Escrever o arquivo CSV ---
fid = fopen(nome_arquivo, 'w');

% Escreve o cabeçalho
fprintf(fid, '%s', cabecalho{1});
for i = 2:length(cabecalho)
    fprintf(fid, ';%s', cabecalho{i});  % Usa ponto e vírgula como separador
end
fprintf(fid, '\n');

% Escreve os dados numéricos
for i = 1:size(dados_para_salvar, 1)
    fprintf(fid, '%.6e;%.6f;%.6f\n', ...
            dados_para_salvar(i, 1), ...
            dados_para_salvar(i, 2), ...
            dados_para_salvar(i, 3));
end

fclose(fid);

fprintf('Dados exportados com sucesso para o arquivo "%s".\n', nome_arquivo);
fprintf('%d linhas de dados foram salvas.\n', size(dados_para_salvar, 1));
