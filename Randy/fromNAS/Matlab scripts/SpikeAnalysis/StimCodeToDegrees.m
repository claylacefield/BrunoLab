function degrees = StimCodeToDegrees(code)

%degrees = (-code - 21) * 45;

degrees = (mod(-code, 10) - 1) * 45;
