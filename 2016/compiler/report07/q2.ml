let rec add i f =
  f+#(float_of_int (i+#1))-# 4.0
in print_float (add 1 2.)
