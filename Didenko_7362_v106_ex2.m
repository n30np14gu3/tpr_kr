function lab_2()
  N = 3; %число ГОП
  M = 5; %число ГДП
  P = 5; %число мест для установки ГОП 
  
  h = M;
  
  buf = [];
  a = ones(1, h); 
  buf([size(buf)(1)+1],:) = a;
 
  [a, flag] = NextSet(a, N, M);
  while( flag )
    buf([size(buf)(1)+1],:) = a;
    [ a, flag] = NextSet(a, N, M);
  endwhile
  buf; %Все возможные комбинации ГОП 
  
  q = [ 1500, 600, 500, 1200, 1500]; % выработка ГДП в год
  w = [ 1320, 2553, 5269 ];% максимальная мощность ГОП 
 
  w_2 = [ 800, 1700, 3100]; %единовременные затраты ГОП  
  e = [ %по вертикали ГДП по горизонтали ГОП
    5.3, 1.7, 2.2, 2.0, 5.3;
    6.6, 5.3, 9.4, 3.3, 1.8;
    1.9, 8.1, 5.8, 1.9, 7.7;
    3.5, 7.4, 2.3, 7.3, 1.9;
    1.9, 3.6, 2.4, 3.3, 9.3
  ];
  A = []; %уравнения
  ctype = []; % >= "L",  <= "U", === "S"
  b = [];
  c = [];
  sense=1; % минимизируем 
  
  buf_2 = [];
  for i=1:P:M*P %ограничения по максимальной мощности каждого ГДП
    A([size(A)(1)+1],:) = zeros(1 ,M*P);
    A([size(A)(1)], i:(i+P-1) ) = ones(1, P);
    b = [b , q( ceil(i/P))];
    ctype = [ctype, "S"];
  endfor
  
  for i=1:P % целевая функция ( без учета единоразовой стоимости каждого ГОП )
   c = [c, e([i], :) ]; 
  endfor
    
  min = Inf;
  xopt_2 = [];
  var = [];
  vtype = []; % Массив столбцов, содержащий типы переменных
  for i=1:P*M
    vtype = [vtype, "C"];    
  endfor
  
  last_ind = size(A)(1);
  
  for i=1:size(buf)(1)
    % ограничения по мощности выбранной вариации ГОП
    for j=1:P
      A([last_ind+j],:) = zeros(1 ,M*P);
      A([last_ind+j], j:P:M*P) = ones(1, P);
      b(last_ind+j) = w( buf([i],[j]) );
      ctype(last_ind+j) = "U";
    endfor
  
    [xopt,zmx,errnum] = glpk(c,A,b',[],[],ctype',vtype,sense);
    h = 0; %учитываем единовременные затраты 
    for j=1:P
      h += w_2(buf([i],[j]));
    endfor
    
    %за пять лет эксплуатации , учитывая единовременные затраты на строительство 
    if( errnum==0 && (zmx*5+h)<min )
      min = zmx*5+h;
      xopt_2 = xopt;
      var = buf([i],:);
    endif  
  endfor
  printf("\n\nTaking into account single consumables and a five-year expedition, the minimum costs will be %d\n", min);
  h = 0;
  for i=1:P
    h += w_2( var(i) );
  endfor
  printf("one-time costs is %d ", h);
  printf("and transportation costs is %d \n", min-h);
  printf("provided that \n");
  xopt_2 = xopt_2'
  for i=1:M*P
    if( xopt_2(i)>0 )
      a = mod(i, P);
      if(a==0)
        a = P;  
      endif
      printf("  The traffic police number will carry %d raw materials to point number %d  to palece %d(GOP type number %d)\n"
        ,ceil(i/P),xopt_2(i), a, var( ceil(i/P) ) );
    endif
  endfor
 
  h = 0;
  for i=1:size(q)
    h += q(i);
  endfor
 printf(" in order for five years to pay off the project with a rate of 320 to 1, the minimum price should be %d",
  min/(h*5/320) );

endfunction
function [a, d] = NextSet(a, n, m)
  j = m;

  while( j>=1 && a(j)== n ) 
    j--;
  endwhile
  if( j < 1 ) 
    d = false;
    return
  endif

  if( a(j) >= n)
    j--;
  endif
  
  a(j)++;
  if( j == m )
    d=true;
    return
  endif
  
  for k=(j+1):m
    a(k) = 1;  
  endfor
  
  d=true;
endfunction

