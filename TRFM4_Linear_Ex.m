% Definir os parâmetros
Ca1 = 10;
Ca2 = 3;
Ct = 1000;
Dam = 10e-4;
r1 = 0.1;
r2 = 0.35;

x1 = 0;
x2 = 2;
num_points = 21;

% Definindo a e b
a = (r2 - r1) / (x2 - x1);
b = r1 - ((r2 - r1) / (x2 - x1)) * x1;

% Calculando a integral de Ca de Ca1 a Ca2 usando uma aproximação numérica (Método Trapezoidal)
integrand_Ca = @(Cax) 1 / (Ct - Cax);  % Função para integrar
% Aproximando a integral de Ca
IntCa = (integrand_Ca(Ca1) + integrand_Ca(Ca2)) * (Ca2 - Ca1) / 2;

% Integral calculada de x:
IntX = 57.14612;

% Calculando Na
Na = (-pi) * Dam * Ct * (IntCa / IntX);

% Lista para armazenar os resultados de Ca
Ca_values = [];

% Função de verificação da integral para evitar grandes erros numéricos
integrand_function = @(x) 1 / ((a * x + b)^2);

% Calculando Ca para diferentes valores de x
for x = linspace(x1, x2, num_points)
    % Calcular a integral de x de forma explícita (sem usar trapz)
    integral_val = 0;
    % Somando a integral de forma simples usando o método do somatório
    n_steps = 100;  % número de passos para integração
    dx = (x - x1) / n_steps;
    for i = 1:n_steps
        x_step = x1 + (i - 1) * dx;
        integral_val = integral_val + integrand_function(x_step) * dx;
    endfor

    % Calcular Ca usando a equação fornecida
    Ca = Ct - ((Ct - Ca1) * exp((Na * integral_val) / (pi * Dam * Ct)));
    Ca_values = [Ca_values, Ca];  % Armazenar o valor de Ca
endfor

% === DADOS A SALVAR ===

%ATENCAO
%Insira esse código após o trecho em que foi definida e criada uma matriz, para fins de exemplificação irei definir uma matriz genérica.


% === NOMES DAS VARIAVEIS (Cabecalho) ===

% Aqui voce escreve manualmente os nomes das variaveis/colunas que estarão no excell:

% Essa parte é só formatacao, nao vai interferir diretamente nos valores, apenas como eles são apresentador no excell

cabecalho = {'Pressao inicial', 'Pressao final', 'Deslocamento', 'Toxicidade de A'}; % O código vai adaptar as colunas com a quantidade de variaveis então se tiver 4+ variáveis basta acrescentar mais títulos com formatação igual aos anteriores, se tiver menos que 4 variaveis basta tirar os títulos.


% === LIMITAR DADOS/LINHAS DA PLANILHA ===

% numero maximo de linhas que desejar salvar
limite = 20000;

% limitador de linhas
num_linhas = min(limite, size(Ca_values, 1));



% === NOME DO ARQUIVO ===
% Defina o nome do arquivo csv. Apenas nao tire o ".csv"

nome_arquivo = 'TRFM4_Linear_Ex.csv'; % Aqui basta alterar qual o nome que vc deseja que o arquivo csv tenha, dá pra trocar o formato do arquivo, mas n recomendo pq deu erro.



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
    fprintf(fid, '%g', Ca_values(i, 1));           % substitua "nomematriz"
    for j = 2:size(Ca_values, 2)                   % substitua "nomematriz"
        fprintf(fid, ';%g', Ca_values(i, j));      % substitua "nomematriz"
    end
    fprintf(fid, '\n');  % nova linha a cada linha de dados
end

fclose(fid);  % fecha o arquivo

% É isso por hoje pessoal.

% Gerador de planilhas concluido AH EHHHH!!
% Para esclarecer duvidas só falar com eu @zophictor

% Gerar o gráfico
plot(linspace(x1, x2, num_points), Ca_values);
xlabel('x (metros)');
ylabel('Ca (Kg/m^3)');
title('Concentração de A (Ca) ao longo de x');
legend('Ca');
grid on;

