clc;
clear;

% === DEFINIÇÃO DAS VARIÁVEIS ===
xinf = 0.00005; xsup = 0.0001; px = (xsup - xinf) / 10;
yinf = 1000;    ysup = 1200;   py = (ysup - yinf) / 10;
zinf = 2.88;    zsup = 3.52;   pz = (zsup - zinf) / 10;

pxs = px / 5; pys = py / 5; pzs = pz / 5;

Nx = round((xsup - xinf) / px);
Ny = round((ysup - yinf) / py);
Nz = round((zsup - zinf) / pz);

[x, y, z] = meshgrid(xinf:px:xsup, yinf:py:ysup, zinf:pz:zsup);
xslice = xinf:pxs:xsup;
yslice = yinf:pys:ysup;
zslice = zinf:pzs:zsup;

% === PARÂMETROS FÍSICOS ===
colormap(jet);
nhz = 1;
ht = 5;  % Altura do tanque [m]
h0 = 2.5;  % Altura inicial [m]
Rg = 8.314;  % Constante dos gases [J/(mol*K)]
T = 298;  % Temperatura [K]

p = 4; pLim = 100; passoP = 10;
abc = [];  % Matriz de resultados

% === LOOP PRINCIPAL ===
while (p <= pLim)
    v = (((ht * h0) - ((h0^2) / 2)) ./ (((x * p) ./ (y * Rg * T)) .* log(p ./ (p - z))));

    % === PLOTAGEM ===
    subplot(1,2,1);
    s1 = slice(x, y, z, v, xslice, yslice, zslice);
    set(s1, 'FaceAlpha', 0.08);
    shading interp;
    view(-45, 25);
    colorbar('west');
    xlabel('Dam (Difusividade no ar) [m²/s]');
    ylabel('Densidade [mol/m³]');
    zlabel('Pressão de vapor [Pa]');
    title('Distribuição do Tempo de Evaporação');

    pause(0.0001);

    subplot(1,2,2);
    scatter(nhz, p, 50, 'filled'); hold on;
    xlabel('Horizonte de Dados');
    ylabel('Parâmetro P [Pa]');
    title('Evolução de P');
    nhz = nhz + 1;

    % === ARMAZENAMENTO DOS RESULTADOS ===
    temp_abc = zeros((Nz+1)(Ny+1)(Nx+1), 6);
    idx = 1;
    for c = 1:Nz+1
        for i = 1:Ny+1
            for j = 1:Nx+1
                v_atual = (((ht * h0) - ((h0^2) / 2)) / (((x(i,j,c) * p) / (y(i,j,c) * Rg * T)) * log(p / (p - z(i,j,c)))));
                temp_abc(idx, :) = [x(i,j,c), y(i,j,c), z(i,j,c), v_atual, p, nhz-1];
                idx = idx + 1;
            end
        end
    end
    abc = [abc; temp_abc];

    p = p + passoP;
end

% === EXPORTAÇÃO PARA CSV ===
cabecalho = {'Dam (Difusividade no ar)', 'Densidade', 'Pressão de Vapor', ...
             'Tempo de Evaporacao', 'Pressão Total', 'Iteração de Pressão'};
nome_arquivo = 'tranfm_full.csv';

fid = fopen(nome_arquivo, 'w');
fprintf(fid, '%s', cabecalho{1});
for i = 2:length(cabecalho)
    fprintf(fid, ';%s', cabecalho{i});
end
fprintf(fid, '\n');

for i = 1:size(abc, 1)
    fprintf(fid, '%g', abc(i, 1));
    for j = 2:size(abc, 2)
        fprintf(fid, ';%g', abc(i, j));
    end
    fprintf(fid, '\n');
end
fclose(fid);

% === EXIBIÇÃO DO PONTO MÍNIMO E MÁXIMO DE EVAPORAÇÃO ===
[~, vmin] = min(abc(:,4));
[~, vmax] = max(abc(:,4));

fprintf('\nPonto de Mínimo:  x = %.5f  y = %.5f  z = %.5f  v = %.5f  p = %.5f\n', abc(vmin,1), abc(vmin,2), abc(vmin,3), abc(vmin,4), abc(vmin,5));
fprintf('Ponto de Máximo:  x = %.5f  y = %.5f  z = %.5f  v = %.5f  p = %.5f\n', abc(vmax,1), abc(vmax,2), abc(vmax,3), abc(vmax,4), abc(vmax,5));
