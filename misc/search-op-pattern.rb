#!/usr/bin/env ruby

# abstract
#   search-op-pattern.rb:
#   searchs code pattern to create appropriate values for printing ASCII chars
#
# output format
#   each line shows values joined with ", " as a separator;
#   1st value:
#     the corresponding D value in mod 94
#   rest:
#     3 values joined with ":";
#     character code:
#       ASCII code ( 10, 32 ~ 126 )
#     instruction string:
#       code for malconv.rb to be placed in C address
#     data string:
#       code for malconv.rb to be placed in D address
#

CRZMAP = [1,1,2,0,0,2,0,2,1]

OPS = 'DIRCPGEN'
OPBASES = [ 7, 65, 6, 29, 66, 84, 48, 35 ]
EOF = (?2*10).to_i(3)

def crazy(x,y)
  10.times.map{
    x,rx = x.divmod(3)
    y,ry = y.divmod(3)
    CRZMAP[rx*3+ry]
  }.reverse_each.reduce(0){|s,e| s*3+e }
end

def rotr1(x)
  x / 3 + x % 3 * 19683
end

SEARCH_DEPTH = 6
94.times{|pos|
  rnum = 96
  result = [ nil ] * rnum
  fregist=->a,ostr,dstr{
    n = a%256
    if n==10
      if !result[0]
        result[0] = [ostr,dstr]
	rnum-=1
      end
    elsif (32..126)===n
      if !result[n-31]
        result[n-31] = [ostr,dstr]
	rnum-=1
      end
    end
  }
  q = [ ['','',nil] ]
  SEARCH_DEPTH.times{|j|
    posc=pos+j
    qn = []
    while rnum>0 && ( cell = q.shift )
      ostr,dstr,a = cell
      qn.push([ostr+?N, dstr+??, a]) if j<SEARCH_DEPTH-1
      if a
        OPS.each_char.with_index{|c,i|
          an = crazy(a, (OPBASES[i]-posc) % 94 + 33)
	  ostrn = ostr+?C
	  dstrn = dstr+c
          qn.push([ostrn, dstrn, an]) if j<SEARCH_DEPTH-1
	  fregist[an,ostrn,dstrn]
        }
      else
        qn.push([ostr+?G, dstr+??, EOF]) if j<SEARCH_DEPTH-1
        OPS.each_char.with_index{|c,i|
          a = rotr1((OPBASES[i]-posc) % 94 + 33)
	  ostrn = ostr+?R
	  dstrn = dstr+c
          qn.push([ostrn,dstrn,a]) if j<SEARCH_DEPTH-1
	  fregist[a,ostrn,dstrn]
        }
      end
    end
    break if rnum==0
    q = qn
  }
  puts "#{pos}, " + 96.times.map{|i|
    c = i==0 ? 10 : i+31
    result[i] ? [c,*result[i]]*?: : "#{c}::"
  } * ', '
}
