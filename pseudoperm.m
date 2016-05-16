function A = pseudoperm( A, varargin )
%PSEUDOPERM  returns pseudo permutated version of A

if nargin>1
    rng(varargin{1});
end


for i = 1:length(A)
   
   temp = A(i);
   
   r = randi(length(A));
   A(i) = A(r);
   A(r) = temp;
   
    
end

end

