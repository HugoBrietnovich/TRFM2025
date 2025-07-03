clc;
clear all;

#3D

#construa visualizações de dados
#Eixo x: a pressão de vapor da espécie que sublima
#Eixo y: o coeficiente de difusão (Dam)
#Eixo z: tempo para sublimação de uma camada da espécie

% Definição das constantes
ro = 1162;  % Densidade da substância [kg/m³]
Rg = 8.314; % Constante dos gases [J/(mol*K)]
Rp = 0.05;  % Raio da partícula [m]
T = 298;    % Temperatura [K] (convertida de 25°C para Kelvin)
P = 10^5;   % Pressão total [Pa]

% Número de pontos laterais do grid
N = 50;

% Eixo X: Pressão de vapor da espécie que sublima [Pa]
Var1 = linspace(120, 150, N);

% Eixo Y: Coeficiente de difusão (Dam) [m²/s]
Var2 = linspace(0.00005, 0.0001, N);

% Criando a malha para cálculo
[xx, yy] = meshgrid(Var1, Var2);

% Definição da equação para Na
Na = ((4 .* pi .* yy .* P .* Rp) ./ (Rg .* T)) .* log(P ./ (P - xx));

% Cálculo do tempo de sublimação (Eixo Z)
z = (((ro .* Rg .* (Rp.^2) .* T)) ./ ((2 .* yy .* xx .* Na) .* (1 ./ log(P ./ (P - xx)))));

% Gráfico 3D da superfície
figure;
surf(xx, yy, z);
shading interp;
colormap(jet);
colorbar;
xlabel("Pressão de Vapor [Pa]");
ylabel("Coef. de Difusão (Dam) [m²/s]");
zlabel("Tempo de Sublimação [s]");
title("Tempo de Sublimação em Função da Pressão de Vapor e Difusão");

% Ajuste de escala para melhor visualização
zlim([0, max(z(:))]);

% Criando o vetor de dados 4D
abc = zeros(N*N, 3);
k = 1;
for i = 1:N
    for j = 1:N
        abc(k, :) = [xx(i, j), yy(i, j), z(i, j)];
        k = k + 1;
    end
end

% === DADOS A SALVAR ===

%ATENCAO
%Insira esse código após o trecho em que foi definida e criada uma matriz, para fins de exemplificação irei definir uma matriz genérica.

% nomematriz = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16];



% === NOMES DAS VARIAVEIS (Cabecalho) ===

% Aqui voce escreve manualmente os nomes das variaveis/colunas que estarão no excell:

% Essa parte é só formatacao, nao vai interferir diretamente nos valores, apenas como eles são apresentador no excell

cabecalho = {'Pressao de Vapor [Pa]', 'Dam [m²/2]', 'Tempo de Sublimação [s]', 'Tempo de Sublimação em Função da Pressão de Vapor e Difusão'}; % O código vai adaptar as colunas com a quantidade de variaveis então se tiver 4+ variáveis basta acrescentar mais títulos com formatação igual aos anteriores, se tiver menos que 4 variaveis basta tirar os títulos.


% === LIMITAR DADOS/LINHAS DA PLANILHA ===

% numero maximo de linhas que desejar salvar
limite = 1000;

% limitador de linhas
num_linhas = min(limite, size(abc, 1));



% === NOME DO ARQUIVO ===
% Defina o nome do arquivo csv. Apenas nao tire o ".csv"

nome_arquivo = 'TRFM3b_Ex.csv'; % Aqui basta alterar qual o nome que vc deseja que o arquivo csv tenha, dá pra trocar o formato do arquivo, mas n recomendo pq deu erro.



% === CRIAÇÃO DO ARQUIVO CSV ===
% N precisa alterar nada aqui

% Nesse trecho o octave esta colocando os titulos no arquivo csv e pulando uma linha para que os dados da matriz sejam inseridos dali pra baixo.

fid = fopen(nome_arquivo, 'w');  % abre o arquivo para escrita

% Escreve os nomes das colunas (cabeçalho)
fprintf(fid, '%s', cabecalho{1});
for i = 2:length(cabecalho)
    fprintf(fid, ';%s', cabecalho{i});  % usa ; como separador
end
fprintf(fid, '\n');  % pula para a próxima linha

% ==============================

% === SALVANDO OS DADOS NO VSC ===

% agr o codigo vai estar inserindo os dados no arquivo

% ATENCAO

% Altere colocando o nome da matriz em todos os espaços aqui embaixo

% Escreve os dados numéricos
for i = 1:num_linhas                       % substitua "nomematriz" pelo nome da matriz que vc quer pegar os valores
    fprintf(fid, '%g', abc(i, 1));           % substitua "nomematriz"
    for j = 2:size(abc, 2)                   % substitua "nomematriz"
        fprintf(fid, ';%g', abc(i, j));      % substitua "nomematriz"
    end
    fprintf(fid, '\n');  % nova linha a cada linha de dados
end

fclose(fid);  % fecha o arquivo

% É isso por hoje pessoal.

% Gerador de planilhas concluido AH EHHHH!!
% Para esclarecer duvidas só falar com eu @zophictor

% Encontrando os valores máximo e mínimo do tempo de sublimação
t_max = max(abc(:,3));
t_min = min(abc(:,3));
fprintf("\nTempo máximo de sublimação: %.5f s", t_max);
fprintf("\nTempo mínimo de sublimação: %.5f s\n", t_min);
