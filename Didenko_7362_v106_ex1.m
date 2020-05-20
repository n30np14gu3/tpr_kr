function lab_1()
  
  size_f = 5; % ���� ����������� 
  size_s = 3; % ��� ������ 
  
  target = 90; % 0���� ���������� ���� � ����
  k = [ % ���������� ���������� 4����� ������� ����� ���� ������������
    16.9, 2.5, 8.4, 30.4; 
    20.7, 1.6, 6.0, 31.0;
    21.3, 2.2, 7.8, 36.6;
    20.7, 2.5, 8.1, 35.2;
    20.2, 2.4, 8.1, 31.7
  ];
  k_r = [20, 2, 8, 35] ;% ����������� �� ���������� ���������� ������� � �������� ����� 
  
  t2 = [ 12.6, 11.2, 11.2, 11.7, 7.0 ]; %�������������
  
  t = [  % ��������� ��������� 
    9.1, 36.0, 39.6;
    26.8, 43.3, 28.8;
    6.3, 36.9, 14.4;
    37.9, 36.1, 10.2;
    38.9, 12.6, 38.1
  ];  % 5 ����������� � 3 ������
 
  h = [19, 22, 22, 23, 27]; %�������� ������
  q = [34, 28, 48]; %����������� �������
  
  c=[]; %������� �������
  for i=1:size_f % 5�� �����������
    for j=1:size_s
      c( (i-1)*size_s+j ) = t([i], [j]) + t2(i);
    endfor
  endfor
  
  %������� ����� 
    %����� ����� === 70
    %������������ ����������� �������  1 2 3 
    %����������� �� ������� 
    %����������� �� ���������� ���������� �� ����� ������������ �������� 
    %����������� �� ��������������� 
  % coefficients
   A = [ones(1,size_f*size_s)];
  % bounds
   b = [target];
   ctype = ["S"]; % >= "L",  <= "U", === "S"
   
  %������������ ����������� �������  1 2 3 
  for i=1:size_s
    buf = zeros(1,size_f*size_s);
    for j=i:size_s:size_f*size_s
      buf( j ) = 1;
    endfor
    A([size(A)(1)+1],:) = buf;
    b = [b, q(i)];
    ctype = [ctype, "U"];
  endfor   
   
  %����������� �� ������� 
  for i=1:size(k)(2) % ����� �������� 
    buf = [];
    for j=1:size_f
        buf = [ buf, zeros(1,size_s).+(k([j],[i])/100) ];
    endfor
    A([size(A)(1)+1],:) = buf;
    b = [b, target*k_r(i)/100 ];
    ctype = [ctype, "U"];
  endfor
  
  %����������� �� ���������� ���������� �� ����� ������������ �������� 
  for i=1:size_s:size_f*size_s  
    buf = zeros(1, size_f*size_s);
    buf([1], i:(i+size_s-1) ) = ones(1,size_s);
    A([size(A)(1)+1],:) = buf;
    ctype = [ctype, "U"];
  endfor
  b = [b, h];
  
  lb=[]; %������ ������� ��� ������ ���������� ( �� ��������� 0 )
  ub=[]; %������� ������� ( �� ��������� ������������� )
  vtype = ["C";"C";"C";"C";"C";"C";"C";"C";"C";"C";"C";"C";"C";"C";"C"]; % ������ ��������, ���������� ���� ����������
  
  
  sense=1; % ������������ 
  [xopt,zmx,errnum]=glpk(c,A,b',lb,ub,ctype',vtype,sense); 
  buf = zmx; %��� ������� ������
  buf_2 = zmx; %��� �������� ������ 
  
  if(errnum != 0 ) % ������������ ������� ��� ��� ��������� �� ����� ��� ����� 
    xopt
    zmx
    errnum
    return
  endif
  
  printf("Under these conditions, a minimum distribution plan: \n");
  for i=1:size_f*size_s
    if( xopt(i) != 0 && xopt(i)>0.1 )
      p =  ceil(i/size_s);
      w = mod(i,size_s);
      if( w==0)
        w = size_s;
      endif
      printf("  production %d to warehouse number %d in quantity %d\n",
        p, w, xopt(i));
    endif
  endfor
  printf("Then the minimum cost of the enterprise will be %d \n\n", zmx);
  
  %������� ������ ����� ��� ���������� ������� �������� 
  for i=1:size_s
       b(i+1) = target; % ������� ���������� ������� ����� ! �� ���������� �� ������ ������ ������� A 
  endfor
  
  [xopt,zmx,errnum]=glpk(c,A,b',lb,ub,ctype',vtype,sense);
  
  if( errnum==0 )
    if( buf > zmx )
      difference = buf-zmx;
      printf("\nTotal costs decreased by %d and compose %d \n", difference, zmx);
      printf("Then to reduce costs you need to: \n");
      h_2 = 0;
      for i=1:size_s
        buf = 0;
        for j=i:size_s:size_s*size_f
          buf += xopt(j);
        endfor
        if( buf > q(i) )
          printf("  Increase warehouse %d by %d \n", i, buf - q(i) );
          h_2 += buf - q(i);
        endif
      endfor
      if( h_2 == 0 ) h_2 = 1; endif
   
      printf("the maximum daily cost of an additional unit of capacity at which  costs will be less than previous: %d",
        difference/h_2 );
      printf("\nThen the new distribution will be: \n");
      for i=1:size_f*size_s
         if( xopt(i) != 0 && xopt(i)>0.1 )
            p =  ceil(i/size_s);
            w = mod(i,size_s);
            if( w==0)
              w = size_s;
            endif
          
            printf("  production %d to warehouse number %d in quantity %d\n",
              p, w, xopt(i));
          endif
      endfor
        
    else
      printf("it is impossible to increase the capacity of warehouses to reduce costs\n\n");
    endif
  endif
  
  % ���������� �������� ������ ������ 1 
  for i=1:size_s
       b(i+1) = q(i);  
  endfor
  
  %������� ������ ����� ��� ���������� ������� ������  
  %������� ���������� ������� ����� !! � ������ ������ �� � 9������ ������ A 
  for i=9:(size_f+8)
    b(i) = 110;
  endfor
  
  [xopt,zmx,errnum]=glpk(c,A,b',lb,ub,ctype',vtype,sense);
  
  if( errnum==0 )
    if( buf_2 > zmx )
      difference = buf_2-zmx;
      printf("\nTotal costs decreased by %d and compose %d \n", difference, zmx);
      printf("Then to reduce costs you need to: \n");
      h_2 = 0;
      for i=1:size_s:size_f*size_s
        buf = 0;
        for j=i:(size_s+i-1)
          buf += xopt(j);
        endfor
        if( buf > h( ceil(i/size_s)) )
          printf("  Increase production of factory %d by %d \n",
            ceil(i/size_s), buf - h( ceil(i/size_s) ) );
          h_2 += buf - h( ceil(i/size_s));
        endif
      endfor
      if( h_2 == 0 ) h_2 = 1; endif
   
      printf("The maximum possible surcharge is: %d", difference/h_2 );
      printf("\nThen the new distribution will be: \n");
      for i=1:size_f*size_s
         if( xopt(i) != 0 && xopt(i)>0.1 )
            p =  ceil(i/size_s);
            w = mod(i,size_s);
            if( w==0)
              w = size_s;
            endif
          
            printf("  production %d to warehouse number %d in quantity %d\n",
              p, w, xopt(i));
          endif
      endfor
        
    else
      printf("it is impossible to increase the capacity of warehouses to reduce costs\n\n");
    endif
  endif
  
endfunction