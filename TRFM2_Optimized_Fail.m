clc; clear;

# === PARAMETROS ===
Rg = 8.314;        % Constante dos gases [J/mol·K]
T = 298;           % Temperatura [K]
h = 0.1;           % Altura da camada de líquido [m]
delta = 0.01;      % Espessura da camada limite [m]

% Malhas
x = linspace(5e-5, 1e-4, 10);        % Dam [m²/s]
y = linspace(1000, 1200, 10);        % Densidade [mol/m³]
z = linspace(2.88, 3.52, 10);        % Pressão de vapor [Pa]

[X, Y, Z] = ndgrid(x, y, z);         % Grade 3D

% Concentração de saturação
Csat = Z ./ (Rg * T);                % mol/m³

% Coeficiente de transferência de massa
kc = X ./ delta;                     % m/s

% Tempo de evaporação (s)
v = (Y .* h) ./ (kc .* Csat);        % segundos

% === VISUALIZAÇÃO ===
slice_pos = {x(2:2:end), y(2:2:end), z(2:2:end)};
figure;
s1 = slice(X, Y, Z, v, slice_pos{1}, slice_pos{2}, slice_pos{3});
set(s1, 'FaceAlpha', 0.08);
shading interp;
xlabel('Difusividade (m²/s)');
ylabel('Densidade (mol/m³)');
zlabel('Pressão de vapor (Pa)');
title('Tempo de Evaporação Corrigido');
colorbar;

% === EXPORTAÇÃO PARA CSV ===
abc = [X(:), Y(:), Z(:), v(:)];
cabecalho = {'Dam (m²/s)', 'Densidade (mol/m³)', 'Pressão de vapor (Pa)', 'Tempo de evaporação (s)'};

fid = fopen("TRFM2_Optimized.csv", "w");
fprintf(fid, "%s;%s;%s;%s\n", cabecalho{:});
for i = 1:size(abc, 1)
    fprintf(fid, "%.5e;%.2f;%.2f;%.2f\n", abc(i,1), abc(i,2), abc(i,3), abc(i,4));
end
fclose(fid);

