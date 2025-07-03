clc;
clear;

% 4D

% === PARTE 1: DEFINIÇÕES E MALHA ===

% Eixos: R (distância), Dam (difusividade), Pa (pressão parcial)
Rinf = 0.01;  Rsup = 0.1;     pR = (Rsup - Rinf) / 10;
Daminf = 0.00005; Damsup = 0.0001; pDam = (Damsup - Daminf) / 10;
Painf = 2.88;   Pasup = 3.52;  pPa = (Pasup - Painf) / 10;

% Fatias para visualização
pRs = pR / 5;  pDams = pDam / 5;  pPas = pPa / 5;

% Número de divisões
NR = round((Rsup - Rinf) / pR);
NDam = round((Damsup - Daminf) / pDam);
NPa = round((Pasup - Painf) / pPa);

% Malha 3D
[R, Dam, Pa] = meshgrid(Rinf:pR:Rsup, Daminf:pDam:Damsup, Painf:pPa:Pasup);
Rslice = Rinf:pRs:Rsup;
Damslice = Daminf:pDams:Damsup;
Paslice = Painf:pPas:Pasup;

% Constantes físicas
colormap(jet);
nhz = 1;       % Contador de horizontes de eventos
Rg = 8.314;    % Constante dos gases [J/(mol*K)]
T = 298;       % Temperatura [K]

% Parâmetro variável
P = 4;         % Pressão inicial [Pa]
PLim = 100;    % Pressão limite [Pa]
passoP = 10;   % Passo da pressão [Pa]

% Vetor de armazenamento
abc = [];      % [R, Dam, Pa, Tempo, P]

% === PARTE 2: CÁLCULO E PLOTAGEM ===

while (P <= PLim)
    % Cálculo do tempo de sublimação
    log_term = log(P ./ (P - Pa));
    v = (R.^2) ./ (((Dam .* P) ./ (Rg * T)) .* log_term);

    % Gráfico 1: Distribuição com slices
    subplot(1,2,1);
    s1 = slice(R, Dam, Pa, v, Rslice, Damslice, Paslice);
    set(s1, 'FaceAlpha', 0.08);
    shading interp;
    view(-45, 25);
    colorbar('west');
    xlabel('Distância da Fonte (R) [m]');
    ylabel('Coef. Difusão (Dam) [m²/s]');
    zlabel('Pressão Parcial (Pa) [Pa]');
    title('Distribuição do Tempo de Sublimação');

    pause(0.0001);

    % Gráfico 2: Evolução de P
    subplot(1,2,2);
    scatter(nhz, P, 50, 'filled'); hold on;
    xlabel('Horizonte de Dados');
    ylabel('Pressão de Vapor (P) [Pa]');
    title('Evolução de P');
    nhz = nhz + 1;

    % Armazenar dados
    for c = 1:NPa+1
        for i = 1:NDam+1
            for j = 1:NR+1
                log_single = log(P / (P - Pa(i,j,c)));
                v_atual = (R(i,j,c)^2) / (((Dam(i,j,c) * P) / (Rg * T)) * log_single);
                abc = [abc; R(i,j,c), Dam(i,j,c), Pa(i,j,c), v_atual, P];
            end
        end
    end

    % Atualizar P
    P = P + passoP;
end

% === PARTE 3: EXPORTAÇÃO DOS DADOS ===

cabecalho = {'Distância da Fonte [R]', 'Dam [m²/s]', 'Pressao Parcial [Pa]', ...
             'Tempo de Sublimação [s]', 'Pressão Total [P]'};

limite = 2000;
num_linhas = min(limite, size(abc, 1));
nome_arquivo = 'TRFM3c_Optimized.csv';

fid = fopen(nome_arquivo, 'w');

% Cabeçalho
fprintf(fid, '%s', cabecalho{1});
for i = 2:length(cabecalho)
    fprintf(fid, ';%s', cabecalho{i});
end
fprintf(fid, '\n');

% Dados
for i = 1:num_linhas
    fprintf(fid, '%g', abc(i, 1));
    for j = 2:size(abc, 2)
        fprintf(fid, ';%g', abc(i, j));
    end
    fprintf(fid, '\n');
end

fclose(fid);

% === PARTE 4: MÍNIMOS E MÁXIMOS ===

[~, vmin] = min(abc(:,4));
[~, vmax] = max(abc(:,4));

fprintf('\nPonto de Mínimo:  R = %.5f  Dam = %.5f  Pa = %.5f  Tempo = %.5f  P = %.5f', abc(vmin,:));
fprintf('\nPonto de Máximo:  R = %.5f  Dam = %.5f  Pa = %.5f  Tempo = %.5f  P = %.5f\n', abc(vmax,:));
