# Modelagem da transferencia de massa de subst. A ao longo de uma distância X considerando duas formas de variação nessa área de difusão uma Linear e outra Não Linear
# Calcula a distribuição da concentração de A ao longo da distância
# Calcula a concentração em cada ponto X


% Definir os parâmetros
Ca1 = 10; #concentração A no início da região de interesse
Ca2 = 3; #concentração A no final da região de interesse
Ct = 1000; #Concentração total de A, que pode ser atingida na área
Dam = 10e-4; #Coeficiente de difusão de A no sistema
r1 = 0.1; #Raio no inicio da região
r2 = 0.35; #Raio no final da região

x1 = 0; #onde a concentração de A começa a ser considerada
x2 = 2; #onde a concentração de A termina de ser considerada
num_points = 21; #numero de pontos que será calculada a concentração de A

% Definindo os parâmetros para a função linear (como a área varia)
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

% Lista para armazenar os resultados de Ca para o caso linear e não linear
Ca_values_linear = [];
Ca_values_nonlinear = [];

% Função para a integral da área variável
integrand_function_linear = @(x) 1 / ((a * x + b)^2);  % Função linear
integrand_function_nonlinear = @(x) 1 / ((0.1 * x^2 + 0.2 * x + 0.1)^2);  % Função não linear arbitrária

% Calculando Ca para diferentes valores de x
for x = linspace(x1, x2, num_points)
    % Calcular a integral de x para a função linear de área
    integral_val_linear = 0;
    n_steps = 100;  % número de passos para integração
    dx = (x - x1) / n_steps;
    for i = 1:n_steps
        x_step = x1 + (i - 1) * dx;
        integral_val_linear = integral_val_linear + integrand_function_linear(x_step) * dx;
    endfor

    % Calcular Ca para o caso linear
    Ca_linear = Ct - ((Ct - Ca1) * exp((Na * integral_val_linear) / (pi * Dam * Ct)));
    Ca_values_linear = [Ca_values_linear, Ca_linear];  % Armazenar o valor de Ca para o caso linear

    % Calcular a integral de x para a função não linear de área
    integral_val_nonlinear = 0;
    for i = 1:n_steps
        x_step = x1 + (i - 1) * dx;
        integral_val_nonlinear = integral_val_nonlinear + integrand_function_nonlinear(x_step) * dx;
    endfor

    % Calcular Ca para o caso não linear
    Ca_nonlinear = Ct - ((Ct - Ca1) * exp((Na * integral_val_nonlinear) / (pi * Dam * Ct)));
    Ca_values_nonlinear = [Ca_values_nonlinear, Ca_nonlinear];  % Armazenar o valor de Ca para o caso não linear
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
limite = 200000;

% limitador de linhas
num_linhas = min(limite, size(Ca_values_nonlinear, 1));



% === NOME DO ARQUIVO ===
% Defina o nome do arquivo csv. Apenas nao tire o ".csv"

nome_arquivo = 'TRFM4_Ex.csv'; % Aqui basta alterar qual o nome que vc deseja que o arquivo csv tenha, dá pra trocar o formato do arquivo, mas n recomendo pq deu erro.



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
    fprintf(fid, '%g', Ca_values_nonlinear(i, 1));           % substitua "nomematriz"
    for j = 2:size(Ca_values_nonlinear, 2)                   % substitua "nomematriz"
        fprintf(fid, ';%g', Ca_values_nonlinear(i, j));      % substitua "nomematriz"
    end
    fprintf(fid, '\n');  % nova linha a cada linha de dados
end

fclose(fid);  % fecha o arquivo

% É isso por hoje pessoal.

% Gerador de planilhas concluido AH EHHHH!!
% Para esclarecer duvidas só falar com eu @zophictor

% Gerar o gráfico com ambos os casos
figure;
hold on;
plot(linspace(x1, x2, num_points), Ca_values_linear, 'b-', 'LineWidth', 2);  % Linha azul para o caso linear
plot(linspace(x1, x2, num_points), Ca_values_nonlinear, 'r--', 'LineWidth', 2);  % Linha vermelha para o caso não linear
xlabel('x (metros)');
ylabel('Ca (Kg/m^3)');
title('Concentração de A (Ca) ao longo de x');
legend({'Caso Linear', 'Caso Não Linear'}, 'Location', 'Best');
grid on;
hold off;
