# 서론
프로젝트 명 : Digital Clock & Timer & Calculator 3-in-1
FPGA 설계 과목에서 배운 Timer와 Calculator와 직접 설계한 Digital Clock을 한 보드 내에 모드 전환을 concept로 구현

# 구현 기능
mode 1 – Digital Clock :

■ 월, 일, 시, 분이 각각 8 digits 7-segment의 두 자리를 차지한다.

■ 시와 분은 각각 0부터 23, 0부터 59까지만 입력되며, 그 외 숫자 입력은 무시된다.

■ 월은 1부터 12까지만 입력되며, 그 외의 숫자 입력은 무시된다.

■ 일의 입력은 ‘월’ 값에 따라 받아들여지는 입력 숫자가 달라진다.
 	1) 월을 1월부터 7월까지 나눈다.
	2) 1월부터 7월까지는 홀수 달, 8월부터는 짝수 달의 경우에 31일까지 입력을 받는다.
 	3) 나머지 달에 대해서는 30일까지만 입력을 받되, 2월은 29일까지만 받도록 예외 처리를 한다.
  
■ - +, -, x, / 연산자 버튼이 입력되면 각각 월, 일, 시, 분을 입력 받을 standby 모드로 도입된다. 그리고 그 자리는 입력을 받을 때까지 ‘__’로 표시된다.

■ tact switch 0을 누르면 reset을, tact switch 1을 누르면 start/stop을 기능한다.

mode 2 – Timer :

■ 시, 분, 초를 입력하는 logic은 직접 구현한 Digital Clock에서의 logic과 같다.

■ 시, 분, 초 각각이 8 digits 7-segment의 두 자리를 차지한다.

■ 가장 높은 두 7-segment 자리는 공란으로 둔다.

■ 분, 초는 0부터 59까지만 입력되며, 그 외의 숫자 입력은 무시된다.

■ 월은 1부터 12까지만 입력되며, 그 외의 숫자 입력은 무시된다.

■ tact switch 0을 누르면 reset을, tact switch 1을 누르면 start/stop을 기능한다.

■ Timer가 작동하면 1초마다 한 번씩 LED가 깜빡이며, timer 시간이 다 되면 ‘삐비빅’ 하며 buzzer가 울린다.

mode 3 – Calculator :

■ 1st operand > operator > 2nd operand 순으로 입력한다.

■ 2nd operand까지 입력한 후 ‘=‘를 입력해야 answer가 출력된다.

■ answer가 출력된 상태에서, ‘ESC’ 버튼을 클릭해야 숫자가 초기화되어 1st operand를 입력 받을 수 있다.

■ answer가 여덟 자리를 넘기거나 음수인 경우 ERROR를 출력한다.

위 시나리오를 진행시키기 위한 프로그램의 전체적인 Block도는 다음과 같다.
![image](https://github.com/user-attachments/assets/982bfa4f-ff31-4c6c-8e75-021d0255ff58)

# 시뮬레이션(Digital Clock 검증)
![image](https://github.com/user-attachments/assets/d3e29471-4819-4384-a53c-d74cc8b32026)
![image](https://github.com/user-attachments/assets/68c6a267-007a-4c06-b48e-691f4e046f84)

# 시뮬레이션(Timer 검증)
![image](https://github.com/user-attachments/assets/148fdb8f-f46d-4773-a24a-4efe75c78f7b)

# 시뮬레이션(Calculator 검증)
![image](https://github.com/user-attachments/assets/aa969b9b-ae13-44c9-a905-f50ac7bf6984)

# RTL Analysis
![image](https://github.com/user-attachments/assets/f117d6cc-3d25-48cd-aa2d-302a327b1029)

# FPGA 보드 검증
![image](https://github.com/user-attachments/assets/2e221022-a2b4-448c-ad4a-f4546eb98b5f)
![image](https://github.com/user-attachments/assets/d97d9288-6e41-478d-93b9-e464c6f33b0b)
![image](https://github.com/user-attachments/assets/015f17cc-be4c-47ec-a8f9-b8cee9909965)

