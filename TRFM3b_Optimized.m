clc;
clear all;

% 3D

% === PARTE 1: DEFINIÇÕES INICIAIS E MALHA ===

% Constantes físicas
ro = 1162;     % Densidade da substância [kg/m³]
Rg = 8.314;    % Constante dos gases [J/(mol*K)]
Rp = 0.05;     % Raio da partícula [m]
T = 298;       % Temperatura [K]
P = 10^5;      % Pressão total [Pa]

% Número de pontos laterais do grid
N = 50;

% Eixo X: Pressão de vapor da espécie que sublima [Pa]
pressao_vapor = linspace(120, 150, N);

% Eixo Y: Coeficiente de difusão (Dam) [m²/s]
difusividade = linspace(0.00005, 0.0001, N);

% Criando a malha para cálculo
[xx, yy] = meshgrid(pressao_vapor, difusividade);

% Precomputar logaritmo para otimização
log_term = log(P ./ (P - xx));

% Cálculo do fluxo molar Na
Na = ((4 .* pi .* yy .* P .* Rp) ./ (Rg .* T)) .* log_term;

% Cálculo do tempo de sublimação (z)
z = ((ro .* Rg .* (Rp.^2) .* T)) ./ ((2 .* yy .* xx .* Na) .* (1 ./ log_term));

% === PARTE 2: VISUALIZAÇÃO 3D ===

figure;
surf(xx, yy, z);
shading interp;
colormap(jet);
colorbar;
xlabel("Pressão de Vapor [Pa]");
ylabel("Coef. de Difusão (Dam) [m²/s]");
zlabel("Tempo de Sublimação [s]");
title("Tempo de Sublimação em Função da Pressão de Vapor e Difusão");

% Ajuste do eixo z
zlim([0, max(z(:))]);

% === PARTE 3: CRIAÇÃO DA MATRIZ DE DADOS ===

abc = zeros(N*N, 3);  % [Pressao, Dam, Tempo]
k = 1;
for i = 1:N
    for j = 1:N
        abc(k, :) = [xx(i, j), yy(i, j), z(i, j)];
        k = k + 1;
    end
end

% === PARTE 4: SALVANDO EM CSV ===

cabecalho = {'Pressao de Vapor [Pa]', 'Dam [m²/s]', 'Tempo de Sublimação [s]'};

limite = 2000;
num_linhas = min(limite, size(abc, 1));

nome_arquivo = 'TRFM3b_Optimized.csv';

fid = fopen(nome_arquivo, 'w');

% Escreve cabeçalho
fprintf(fid, '%s', cabecalho{1});
for i = 2:length(cabecalho)
    fprintf(fid, ';%s', cabecalho{i});
end
fprintf(fid, '\n');

% Escreve dados numéricos
for i = 1:num_linhas
    fprintf(fid, '%g', abc(i, 1));
    for j = 2:size(abc, 2)
        fprintf(fid, ';%g', abc(i, j));
    end
    fprintf(fid, '\n');
end

fclose(fid);

% === PARTE 5: ESTATÍSTICAS SIMPLES ===

t_max = max(abc(:,3));
t_min = min(abc(:,3));
fprintf("\nTempo máximo de sublimação: %.5f s", t_max);
fprintf("\nTempo mínimo de sublimação: %.5f s\n", t_min);

