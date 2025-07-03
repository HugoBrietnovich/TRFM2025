clc;
#clf;
clear all;

#rodar duas vezes pra atualizar o segundo gráfico a fim de mostrar o limite de sensibilidade do sensor de toxicicidade

#X = Pressao no ponto inicial
#Y = Pressao no ponto final
#Z = Deslocamento
#P = Pressao de A

#Como sao pressoes, foi utilizado limites de 0 a 1, mas fique a vontade para mudar os valores.

xinf=0; %limite minimo no eixo x
xsup=1; %limite maximo no eixo x
px=0.1; %passo no eixo x

yinf=0; %limite minimo no eixo y
ysup=1; %limite maximo no eixo y
py=0.1; %passo no eixo y

# z �` o tamanho do tubo. Sendo que inicia em 0 e vai at�` o tamanho total de 8. Fique a vontade para mudar os valores.
# Se mudar o valor de zsup mude o valor de L pois devem ser iguais.
zinf=0; %limite minimo no eixo z
zsup=8; %limite maximo no eixo z
pz=0.2; %passo no eixo z

pxs=0.1; %passo em x do grafico em fatias
pys=0.1; %passo em y do grafico em fatias
pzs=0.2; %passo em z do grafico em fatias

Nx = (xsup-xinf)/px;
Ny = (ysup-yinf)/py;
Nz = (zsup-zinf)/pz;

#slice vai dividir nosso volume em fatias para facilitar a visualização da distribuição da pressão no tubo
[x,y,z] = meshgrid(xinf:px:xsup,yinf:py:ysup,zinf:pz:zsup);
xslice = xinf:pxs:xsup;
yslice = yinf:pys:ysup;
zslice = zinf:pzs:zsup;

colormap(jet); #Vemelho maior toxicidade / Azul menor toxicidade

L=zsup; %comprimento do tubo

#Aqui foi mudada a equaçao abaixo, pois foi dada no exercicio sendo que no código base �` diferente.
v = (x-((x-y).*z/L));
s1=slice(x,y,z,v,xslice,yslice,zslice);
set(s1,'facealpha',0.05);
shading interp;
view(-45,30); #angulo de visualização
colorbar;

xlabel("Pressao inicial");
ylabel("Pressao final");
zlabel("Deslocamento");
title("Toxicidade de A");

k=1;
for c = 1:Nz+1
  for i = 1:Ny+1
    for j = 1:Nx+1
        v(i,j,c) = (x(i,j,c)-((x(i,j,c)-y(i,j,c)).*z(i,j,c)/L));  # �` necessario inserir (i,j,c) depois das variaveis x,y,z nessa linha.
        abc(k,1:4)=[x(i,j,c), y(i,j,c), z(i,j,c), v(i,j,c)];
        k = k + 1;
    end
  end
end

% === DADOS A SALVAR ===

% === NOMES DAS VARI�VEIS (Cabe�alho) ===
% Aqui voc� escreve manualmente os nomes das vari�veis/colunas:
cabecalho = {'Pressao inicial', 'Pressao final', 'Deslocamento', 'Toxicidade de A'};

% === NOME DO ARQUIVO ===
nome_arquivo = 'TRFM1_Ex.csv';

% === CRIAÇÃO DO ARQUIVO CSV ===
fid = fopen(nome_arquivo, 'w');  % abre o arquivo para escrita

% Escreve os nomes das colunas (cabeçalho)
fprintf(fid, '%s', cabecalho{1});
for i = 2:length(cabecalho)
    fprintf(fid, ';%s', cabecalho{i});  % usa ; como separador
end
fprintf(fid, '\n');  % pula para a próxima linha

% Escreve os dados numéricos
for i = 1:size(abc, 1)
    fprintf(fid, '%g', abc(i, 1));
    for j = 2:size(abc, 2)
        fprintf(fid, ';%g', abc(i, j));
    end
    fprintf(fid, '\n');  % nova linha a cada linha de dados
end

fclose(fid);  % fecha o arquivo

# Laço para encontrar a região onde o maximo valor da quarta dimemsão eh 3
figure(2)
colormap(jet); #zt = ajuste de sensibilidade do gráfico em relação a toxicidade
zt=0.4;  #Aqui deve ser mudado de acordo com seus valores, sendo que zt deve ser menor que que os limmites de suas pressões de x e y.
for k = 1:1:(Nx+1)*(Ny+1)*(Nz+1)
    if abc(k,4) < zt #Matriz que armazena os valores recalculados ponto a ponto
         scatter3( abc(k,1), abc(k,2), abc(k,3), 100, abc(k,4), "filled" ); hold on; #representação dos pontos com valor menor que zt (menor toxicidade), indicando a região segura.
        vmin=k;
    end
end
%colorbar ("west");

xlabel("Pressao inicial");
ylabel("Pressao final");
zlabel("Deslocamento");
title("Toxicidade de A");

#O primeiro grafico mostra a visão geral de pressao, mostrando que do lado direito de baixo pra cima :imagine uma pessoa andando no tubo da #fonte da toxicidade para o lado de menor toxicidade. Já o lado esquerdo, uma pessoa indo em direção a fonte de toxicidade.
#E o grafico 2 apresenta a região segura onde zt �` menor que o valor que você inseriu no código sendo o valor de toxidade maxima para uma #pessoa. Portanto vermelho �` a parte mais proxima de toxicidade maxima (zt) e azul as condições de menor toxidade e onde não aparece os pontos #são regiões que são maiores que zt.

