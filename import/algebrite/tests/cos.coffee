test_cos = ->
  run_test [

    "cos(x)",
    "cos(x)",

    "cos(-x)",
    "cos(x)",

    "cos(b-a)",
    "cos(a-b)",

    # check against the floating point math library

    "f(a,x)=1+cos(float(a/360*2*pi))-float(x)+cos(a/360*2*pi)-x",
    "",

    "f(0,1)",      # 0
    "1.0",

    "f(90,0)",      # 90
    "1.0",

    "f(180,-1)",      # 180
    "1.0",

    "f(270,0)",      # 270
    "1.0",

    "f(360,1)",      # 360
    "1.0",

    "f(-90,0)",      # -90
    "1.0",

    "f(-180,-1)",      # -180
    "1.0",

    "f(-270,0)",      # -270
    "1.0",

    "f(-360,1)",      # -360
    "1.0",

    "f(45,sqrt(2)/2)",    # 45
    "1.0",

    "f(135,-sqrt(2)/2)",    # 135
    "1.0",

    "f(225,-sqrt(2)/2)",    # 225
    "1.0",

    "f(315,sqrt(2)/2)",    # 315
    "1.0",

    "f(-45,sqrt(2)/2)",    # -45
    "1.0",

    "f(-135,-sqrt(2)/2)",    # -135
    "1.0",

    "f(-225,-sqrt(2)/2)",    # -225
    "1.0",

    "f(-315,sqrt(2)/2)",    # -315
    "1.0",

    "f(30,sqrt(3)/2)",    # 30
    "1.0",

    "f(150,-sqrt(3)/2)",    # 150
    "1.0",

    "f(210,-sqrt(3)/2)",    # 210
    "1.0",

    "f(330,sqrt(3)/2)",    # 330
    "1.0",

    "f(-30,sqrt(3)/2)",    # -30
    "1.0",

    "f(-150,-sqrt(3)/2)",    # -150
    "1.0",

    "f(-210,-sqrt(3)/2)",    # -210
    "1.0",

    "f(-330,sqrt(3)/2)",    # -330
    "1.0",

    "f(60,1/2)",      # 60
    "1.0",

    "f(120,-1/2)",      # 120
    "1.0",

    "f(240,-1/2)",      # 240
    "1.0",

    "f(300,1/2)",      # 300
    "1.0",

    "f(-60,1/2)",      # -60
    "1.0",

    "f(-120,-1/2)",      # -120
    "1.0",

    "f(-240,-1/2)",      # -240
    "1.0",

    "f(-300,1/2)",      # -300
    "1.0",

    "f=quote(f)",
    "",

    "cos(arccos(x))",
    "x",

    # bug fix for version 119

    "cos(1/12*pi)",
    "cos(1/12*pi)",

    "cos(arctan(4/3))",
    "3/5",

    "cos(-arctan(4/3))",
    "3/5",

    # phase

    "cos(x-8/2*pi)",
    "cos(x)",

    "cos(x-7/2*pi)",
    "-sin(x)",

    "cos(x-6/2*pi)",
    "-cos(x)",

    "cos(x-5/2*pi)",
    "sin(x)",

    "cos(x-4/2*pi)",
    "cos(x)",

    "cos(x-3/2*pi)",
    "-sin(x)",

    "cos(x-2/2*pi)",
    "-cos(x)",

    "cos(x-1/2*pi)",
    "sin(x)",

    "cos(x+0/2*pi)",
    "cos(x)",

    "cos(x+1/2*pi)",
    "-sin(x)",

    "cos(x+2/2*pi)",
    "-cos(x)",

    "cos(x+3/2*pi)",
    "sin(x)",

    "cos(x+4/2*pi)",
    "cos(x)",

    "cos(x+5/2*pi)",
    "-sin(x)",

    "cos(x+6/2*pi)",
    "-cos(x)",

    "cos(x+7/2*pi)",
    "sin(x)",

    "cos(x+8/2*pi)",
    "cos(x)",
  ]
