

DEBUG_IS = false

# p is a U
# this routine is a simple check on whether we have
# a basic zero in our hands. It doesn't perform any
# calculations or simplifications.
isZeroAtomOrTensor = (p) ->
  i = 0
  switch (p.k)
    when NUM
      if (MZERO(p.q.a))
        return 1
    when DOUBLE
      if (p.d == 0.0)
        return 1
    when TENSOR
      for i in [0...p.tensor.nelem]
        if (!isZeroAtomOrTensor(p.tensor.elem[i]))
          return 0
      return 1
  return 0

# This is a key routine to try to determine whether
# the argument looks like zero/false, or non-zero/true,
# or undetermined.
# This is useful in two instances:
#  * to determine if a predicate is true/false
#  * to determine if particular quantity is zero
# Note that if one wants to check if we have a simple
# zero atom or tensor in our hands, then the isZeroAtomOrTensor
# routine is sufficient.
isZeroLikeOrNonZeroLikeOrUndetermined = (valueOrPredicate) ->
  # push the argument
  push(valueOrPredicate)

  # just like Eval but turns assignments into
  # equality checks
  Eval_predicate()
  evalledArgument = pop()

  # OK first check if we already have
  # a simple zero (or simple zero tensor)
  if isZeroAtomOrTensor evalledArgument
    return 0

  # also check if we have a simple numeric value, or a tensor
  # full of simple numeric values (i.e. straight doubles or fractions).
  # In such cases, since we
  # just excluded they are zero, then we take it as
  # a "true"
  if isNumericAtomOrTensor evalledArgument
    return 1

  # if we are here we are in the case of value that
  # is not a zero and not a simple numeric value.
  # e.g. stuff like
  # 'sqrt(2)', or 'sin(45)' or '1+i', or 'a'
  # so in such cases let's try to do a float()
  # so we might get down to a simple numeric value
  # in some of those cases

  push evalledArgument
  zzfloat()
  evalledArgument = pop()

  # anything that could be calculated down to a simple
  # numeric value is now indeed either a 
  # double OR a double with an imaginary component
  # e.g. 2.0 or 2.4 + i*5.6
  # (Everything else are things that don't have a numeric
  # value e.g. 'a+b')
  
  # So, let's take care of the case where we have
  # a simple numeric value with NO imaginary component,
  # things like sqrt(2) or sin(PI)
  # by doing the simple numeric
  # values checks again

  if isZeroAtomOrTensor evalledArgument
    return 0

  if isNumericAtomOrTensor evalledArgument
    return 1

  # here we still have cases of simple numeric values
  # WITH an imaginary component e.g. '1+i',
  # or things that don't have a numeric value e.g. 'a'

  # so now let's take care of the imaginary numbers:
  # since we JUST have to spot "zeros" we can just
  # calculate the absolute value and re-do all the checks
  # we just did

  if Find(evalledArgument, imaginaryunit)
    push evalledArgument
    absValFloat()

    Eval_predicate()
    evalledArgument = pop()

    # re-do the simple-number checks...

    if isZeroAtomOrTensor evalledArgument
      return 0

    if isNumericAtomOrTensor evalledArgument
      return 1

  # here we have stuff that is not reconducible to any
  # numeric value (or tensor with numeric values) e.g.
  # 'a+b', so it just means that we just don't know the
  # truth value, so we have
  # to leave the whole thing unevalled
  return null


# p is a U
isnegativenumber = (p) ->
  switch (p.k)
    when NUM
      if (MSIGN(p.q.a) == -1)
        return 1
    when DOUBLE
      if (p.d < 0.0)
        return 1
  return 0

# p is a U
ispositivenumber = (p) ->
  switch (p.k)
    when NUM
      if (MSIGN(p.q.a) == 1)
        return 1
    when DOUBLE
      if (p.d > 0.0)
        return 1
  return 0

# p is a U
isplustwo = (p) ->
  switch (p.k)
    when NUM
      if (MEQUAL(p.q.a, 2) && MEQUAL(p.q.b, 1))
        return 1
    when DOUBLE
      if (p.d == 2.0)
        return 1
  return 0

# p is a U
isplusone = (p) ->
  switch (p.k)
    when NUM
      if (MEQUAL(p.q.a, 1) && MEQUAL(p.q.b, 1))
        return 1
    when DOUBLE
      if (p.d == 1.0)
        return 1
  return 0

isminusone = (p) ->
  switch (p.k)
    when NUM
      if (MEQUAL(p.q.a, -1) && MEQUAL(p.q.b, 1))
        return 1
    when DOUBLE
      if (p.d == -1.0)
        return 1
  return 0

isone = (p) ->
  return isplusone(p) or isminusone(p)

isinteger = (p) ->
  if (p.k == NUM && MEQUAL(p.q.b, 1))
    return 1
  else
    return 0

isintegerorintegerfloat = (p) ->
  if p.k == DOUBLE
    if (p.d == Math.round(p.d))
      return 1
    return 0
  return isinteger(p)

isnonnegativeinteger = (p) ->
  if (isrational(p) && MEQUAL(p.q.b, 1) && MSIGN(p.q.a) == 1)
    return 1
  else
    return 0

isposint = (p) ->
  if (isinteger(p) && MSIGN(p.q.a) == 1)
    return 1
  else
    return 0

# both p,x are U
ispoly = (p,x) ->
  if (Find(p, x))
    return ispoly_expr(p, x)
  else
    return 0

ispoly_expr = (p,x) ->
  if (car(p) == symbol(ADD))
    p = cdr(p)
    while (iscons(p))
      if (!ispoly_term(car(p), x))
        return 0
      p = cdr(p)
    return 1
  else
    return ispoly_term(p, x)

ispoly_term = (p,x) ->
  if (car(p) == symbol(MULTIPLY))
    p = cdr(p)
    while (iscons(p))
      if (!ispoly_factor(car(p), x))
        return 0
      p = cdr(p)
    return 1
  else
    return ispoly_factor(p, x)

ispoly_factor = (p,x) ->
  if (equal(p, x))
    return 1
  if (car(p) == symbol(POWER) && equal(cadr(p), x))
    if (isposint(caddr(p)))
      return 1
    else
      return 0
  if (Find(p, x))
    return 0
  else
    return 1

isnegativeterm = (p) ->
  if (isnegativenumber(p))
    return 1
  else if (car(p) == symbol(MULTIPLY) && isnegativenumber(cadr(p)))
    return 1
  else
    return 0

hasNegativeRationalExponent = (p) ->
  if (car(p) == symbol(POWER) \
  && isrational(car(cdr(cdr(p)))) \
  && isnegativenumber(car(cdr(p))))
    if DEBUG_IS then console.log "hasNegativeRationalExponent: " + p.toString() + " has imaginary component"
    return 1
  else
    if DEBUG_IS then console.log "hasNegativeRationalExponent: " + p.toString() + " has NO imaginary component"
    return 0

isimaginarynumberdouble = (p) ->
  if ((car(p) == symbol(MULTIPLY) \
  && length(p) == 3 \
  && isdouble(cadr(p)) \
  && hasNegativeRationalExponent(caddr(p))) \
  || equal(p, imaginaryunit))
    return 1
  else 
    return 0

isimaginarynumber = (p) ->
  if ((car(p) == symbol(MULTIPLY) \
  && length(p) == 3 \
  && isNumericAtom(cadr(p)) \
  && equal(caddr(p), imaginaryunit)) \
  || equal(p, imaginaryunit) \
  || hasNegativeRationalExponent(caddr(p))
  )
    if DEBUG_IS then console.log "isimaginarynumber: " + p.toString() + " is imaginary number"
    return 1
  else 
    if DEBUG_IS then console.log "isimaginarynumber: " + p.toString() + " isn't an imaginary number"
    return 0

iscomplexnumberdouble = (p) ->
  if ((car(p) == symbol(ADD) \
  && length(p) == 3 \
  && isdouble(cadr(p)) \
  && isimaginarynumberdouble(caddr(p))) \
  || isimaginarynumberdouble(p))
    return 1
  else
    return 0

iscomplexnumber = (p) ->
  if DEBUG_IS then debugger
  if ((car(p) == symbol(ADD) \
  && length(p) == 3 \
  && isNumericAtom(cadr(p)) \
  && isimaginarynumber(caddr(p))) \
  || isimaginarynumber(p))
    if DEBUG then console.log "iscomplexnumber: " + p.toString() + " is imaginary number"
    return 1
  else
    if DEBUG then console.log "iscomplexnumber: " + p.toString() + " is imaginary number"
    return 0

iseveninteger = (p) ->
  if isinteger(p) && p.q.a.isEven()
    return 1
  else
    return 0

isnegative = (p) ->
  if (car(p) == symbol(ADD) && isnegativeterm(cadr(p)))
    return 1
  else if (isnegativeterm(p))
    return 1
  else
    return 0

# returns 1 if there's a symbol somewhere.
# not used anywhere. Note that PI and POWER are symbols,
# so for example 2^3 would be symbolic
# while -1^(1/2) i.e. 'i' is not, so this can
# be tricky to use.
issymbolic = (p) ->
  if (issymbol(p))
    return 1
  else
    while (iscons(p))
      if (issymbolic(car(p)))
        return 1
      p = cdr(p)
    return 0

# i.e. 2, 2^3, etc.

isintegerfactor = (p) ->
  if (isinteger(p) || car(p) == symbol(POWER) \
  && isinteger(cadr(p)) \
  && isinteger(caddr(p)))
    return 1
  else
    return 0

isNumberOneOverSomething = (p) ->
  if isfraction(p) \
  && Math.abs(p.q.a.value) == 1
    return 1
  else
    return 0


isoneover = (p) ->
  if (car(p) == symbol(POWER) \
  && isminusone(caddr(p)))
    return 1
  else
    return 0

isfraction = (p) ->
  if (p.k == NUM && !MEQUAL(p.q.b, 1))
    return 1
  else
    return 0

# p is a U, n an int
equaln = (p,n) ->
  switch (p.k)
    when NUM
      if (MEQUAL(p.q.a, n) && MEQUAL(p.q.b, 1))
        return 1
    when DOUBLE
      if (p.d == n)
        return 1
  return 0

# p is a U, a and b ints
equalq = (p, a, b) ->
  switch (p.k)
    when NUM
      if (MEQUAL(p.q.a, a) && MEQUAL(p.q.b, b))
        return 1
    when DOUBLE
      if (p.d == a / b)
        return 1
  return 0

# p == 1/2 ?

isoneovertwo = (p) ->
  if equalq(p, 1, 2)
    return 1
  else
    return 0

# p == -1/2 ?
isminusoneovertwo = (p) ->
  if equalq(p, -1, 2)
    return 1
  else
    return 0


# p == 1/sqrt(2) ?

isoneoversqrttwo = (p) ->
  if (car(p) == symbol(POWER) \
  && equaln(cadr(p), 2) \
  && equalq(caddr(p), -1, 2))
    return 1
  else
    return 0

# p == -1/sqrt(2) ?

isminusoneoversqrttwo = (p) ->
  if (car(p) == symbol(MULTIPLY) \
  && equaln(cadr(p), -1) \
  && isoneoversqrttwo(caddr(p)) \
  && length(p) == 3)
    return 1
  else
    return 0

isfloating = (p) ->
  if p.k == DOUBLE or p == symbol(FLOATF)
    return 1
  while (iscons(p))
    if (isfloating(car(p)))
      return 1
    p = cdr(p)
  return 0

isimaginaryunit = (p) ->
  if (equal(p, imaginaryunit))
    return 1
  else
    return 0

# n/2 * i * pi ?

# return value:

#  0  no

#  1  1

#  2  -1

#  3  i

#  4  -i

isquarterturn = (p) ->
  n = 0
  minussign = 0

  if (car(p) != symbol(MULTIPLY))
    return 0

  if (equal(cadr(p), imaginaryunit))

    if (caddr(p) != symbol(PI))
      return 0

    if (length(p) != 3)
      return 0

    return 2

  if (!isNumericAtom(cadr(p)))
    return 0

  if (!equal(caddr(p), imaginaryunit))
    return 0

  if (cadddr(p) != symbol(PI))
    return 0

  if (length(p) != 4)
    return 0

  push(cadr(p))
  push_integer(2)
  multiply()

  n = pop_integer()

  if (isNaN(n))
    return 0

  if (n < 1)
    minussign = 1
    n = -n

  switch (n % 4)
    when 0
      n = 1
    when 1
      if (minussign)
        n = 4
      else
        n = 3
    when 2
      n = 2
    when 3
      if (minussign)
        n = 3
      else
        n = 4

  return n

# special multiple of pi?

# returns for the following multiples of pi...

#  -4/2  -3/2  -2/2  -1/2  1/2  2/2  3/2  4/2

#  4  1  2  3  1  2  3  4

isnpi = (p) ->
  n = 0
  if (p == symbol(PI))
    return 2
  if (car(p) == symbol(MULTIPLY) \
  && isNumericAtom(cadr(p)) \
  && caddr(p) == symbol(PI) \
  && length(p) == 3)
    doNothing = 0
  else
    return 0
  push(cadr(p))
  push_integer(2)
  multiply()
  n = pop_integer()
  if (isNaN(n))
    return 0
  if (n < 0)
    n = 4 - (-n) % 4
  else
    n = 1 + (n - 1) % 4
  return n



$.isZeroAtomOrTensor                   = isZeroAtomOrTensor
$.isnegativenumber         = isnegativenumber          
$.isplusone                = isplusone   
$.isminusone               = isminusone    
$.isinteger                = isinteger   
$.isnonnegativeinteger     = isnonnegativeinteger              
$.isposint                 = isposint  
$.isnegativeterm           = isnegativeterm        
$.isimaginarynumber        = isimaginarynumber           
$.iscomplexnumber          = iscomplexnumber         
$.iseveninteger            = iseveninteger       
$.isnegative               = isnegative    
$.issymbolic               = issymbolic    
$.isintegerfactor          = isintegerfactor         
$.isoneover                = isoneover   
$.isfraction               = isfraction    
$.isoneoversqrttwo         = isoneoversqrttwo          
$.isminusoneoversqrttwo    = isminusoneoversqrttwo               
$.isfloating               = isfloating    
$.isimaginaryunit          = isimaginaryunit         
$.isquarterturn            = isquarterturn       
$.isnpi                    = isnpi

